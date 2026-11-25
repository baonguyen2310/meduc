<?php
declare(strict_types=1);

namespace App\Service;

use InvalidArgumentException;
use RuntimeException;

final class AffiliateCommissions
{
    public static function approve(int $orderId): void
    {
        $db = CommercePurchases::db();
        $code = $db->execute('SELECT affiliateCode FROM orders WHERE id=?', [$orderId])->fetchColumn(0);
        if (!$code) {
            throw new InvalidArgumentException('Đơn này chưa có đối tác giới thiệu.');
        }

        $db->transactional(function () use ($db, $orderId, $code) {
            // Lock the partner before the invoice in both approval and payout.
            $partner = $db->execute(
                'SELECT id,status,deleted,is_partner_affiliate FROM customers WHERE code=? FOR UPDATE',
                [$code]
            )->fetch('assoc');
            $order = $db->execute(
                'SELECT type,deleted,status,affiliateCode,affiliateAmount,orderStatus,affiliatePaidStatus FROM orders WHERE id=? FOR UPDATE',
                [$orderId]
            )->fetch('assoc');
            if (!$order || $order['type'] !== ORDER || $order['deleted'] || $order['status'] === CANCEL || $order['affiliateCode'] !== $code) {
                throw new InvalidArgumentException('Đơn hàng không còn đủ điều kiện duyệt hoa hồng.');
            }
            if ($order['orderStatus'] === 'success' || $order['affiliatePaidStatus'] === 'paid') return;
            if (!$partner || (int)$partner['status'] !== 1 || $partner['deleted'] || (int)$partner['is_partner_affiliate'] !== 1) {
                throw new InvalidArgumentException('Đối tác giới thiệu chưa được kích hoạt.');
            }

            $payment = OrderPayments::summaries([$orderId])[$orderId] ?? [];
            if (empty($payment['received'])) {
                throw new InvalidArgumentException('Cần xác nhận đã thu đủ tiền trước khi duyệt hoa hồng.');
            }
            $amount = round((float)$order['affiliateAmount'], 2);
            if ($amount <= 0 || $amount > $payment['amount']) {
                throw new InvalidArgumentException('Khoản hoa hồng chưa hợp lệ.');
            }
            $db->update('orders', ['orderStatus' => 'success', 'affiliatePaidStatus' => 'unpaid'], ['id' => $orderId]);
            $db->execute('UPDATE customers SET affiliate_amount=COALESCE(affiliate_amount,0)+?,
                affiliate_amount_unpaid=COALESCE(affiliate_amount_unpaid,0)+? WHERE id=?', [$amount, $amount, $partner['id']]);
        });
    }

    public static function payable(string $code): float
    {
        return array_sum(self::payableOrders($code));
    }

    /** Record money already transferred to the partner, against the displayed amount. */
    public static function settle(int $partnerId, float $expected): void
    {
        if ($expected <= 0 || !is_finite($expected)) {
            throw new InvalidArgumentException('Vui lòng kiểm tra lại số tiền hoa hồng đã chi.');
        }
        $db = CommercePurchases::db();
        $db->transactional(function () use ($db, $partnerId, $expected) {
            $partner = $db->execute(
                'SELECT code,affiliate_amount_unpaid FROM customers WHERE id=? AND deleted=0 FOR UPDATE',
                [$partnerId]
            )->fetch('assoc');
            if (!$partner) {
                throw new InvalidArgumentException('Không tìm thấy đối tác.');
            }
            $orders = self::payableOrders((string)$partner['code'], true);
            $amount = array_sum($orders);
            if (abs($amount - $expected) > 0.001 || (float)$partner['affiliate_amount_unpaid'] < $amount) {
                throw new InvalidArgumentException('Số dư hoặc đơn đủ điều kiện đã thay đổi. Tải lại hồ sơ để đối soát.');
            }
            foreach (array_keys($orders) as $id) {
                if ($db->update('orders', ['affiliatePaidStatus' => 'paid'], ['id' => $id])->rowCount() !== 1) {
                    throw new RuntimeException('Chưa cập nhật được trạng thái chi hoa hồng.');
                }
            }
            $db->execute('UPDATE customers SET affiliate_amount_unpaid=affiliate_amount_unpaid-? WHERE id=?', [$amount, $partnerId]);
        });
    }

    private static function payableOrders(string $code, bool $lock = false): array
    {
        if ($code === '') return [];
        $rows = CommercePurchases::db()->execute(
            "SELECT id,affiliateAmount FROM orders WHERE type='order' AND deleted=0 AND status<>'cancel'
             AND affiliateCode=? AND affiliateAmount>0 AND orderStatus='success'
             AND (affiliatePaidStatus IS NULL OR affiliatePaidStatus<>'paid') ORDER BY id" . ($lock ? ' FOR UPDATE' : ''),
            [$code]
        )->fetchAll('assoc');
        $payments = OrderPayments::summaries(array_column($rows, 'id'));
        $orders = [];
        foreach ($rows as $row) {
            $id = (int)$row['id'];
            if (!empty($payments[$id]['received'])) {
                $orders[$id] = round((float)$row['affiliateAmount'], 2);
            }
        }
        return $orders;
    }
}
