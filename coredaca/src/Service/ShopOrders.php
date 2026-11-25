<?php
declare(strict_types=1);

namespace App\Service;

use App\Lib\BookCheckout;
use InvalidArgumentException;
use RuntimeException;

/** Store Shop checkout in the same order and payment ledgers as digital purchases. */
final class ShopOrders
{
    public const ARCHIVE_CODE_PREFIX = 'meduc-shop-legacy:';

    public static function place(array $customer, array $data, callable $saveOrder, callable $savePayment): array
    {
        $reference = is_string($data['cartId'] ?? null) ? $data['cartId'] : '';
        $method = $data['payment'] ?? '';
        if (!preg_match('/^MEDUC[0-9]{6,24}$/D', $reference) || !in_array($method, [BANK, COD], true)) {
            throw new InvalidArgumentException('Vui lòng kiểm tra lại mã đơn và phương thức thanh toán.');
        }

        $db = CommercePurchases::db();
        $customerId = (int)$customer['id'];
        // A stable key makes a repeated checkout request return the original order.
        $publicCode = self::publicCode($reference);
        return $db->transactional(function () use ($db, $customer, $customerId, $reference, $publicCode, $method, $data, $saveOrder, $savePayment) {
            $account = $db->execute('SELECT status,deleted FROM customers WHERE id=? FOR UPDATE', [$customerId])->fetch('assoc');
            if (!$account || (int)$account['status'] !== 1 || $account['deleted']) {
                throw new InvalidArgumentException('Tài khoản không còn hoạt động.');
            }
            $existing = $db->execute('SELECT order_id,customer_id,kind FROM commerce_purchases WHERE public_code=?', [$publicCode])->fetch('assoc');
            if ($existing) {
                if ($existing['kind'] !== 'shop' || (int)$existing['customer_id'] !== $customerId) {
                    throw new InvalidArgumentException('Mã đơn đã được sử dụng. Vui lòng tạo lại giỏ hàng.');
                }
                return self::receipt((int)$existing['order_id'], $customerId);
            }

            $contact = CheckoutContact::validate($data, $customer, true);
            $contact['phone'] = preg_replace('/[ .()-]/', '', $contact['phone']);
            if (!preg_match('/^(?:0|\+84)[0-9]{9,10}$/D', $contact['phone'])) {
                throw new InvalidArgumentException('Vui lòng kiểm tra lại số điện thoại nhận hàng.');
            }
            $rawItems = $data['cartProducts'] ?? '';
            $decoded = is_string($rawItems) ? json_decode($rawItems, true) : null;
            $items = BookCheckout::quote(is_array($decoded) ? $decoded : []);
            $subtotal = array_sum(array_column($items, 'total'));
            $voucherInput = Vouchers::checkoutInput($data);
            if (empty($voucherInput['voucher_referral']) && is_string($data['affiliateCode'] ?? null)) {
                $voucherInput['voucher_referral'] = $data['affiliateCode'];
                if (!array_key_exists('voucher_expected_amount', $voucherInput)) $voucherInput['voucher_skip_referral'] = '1';
            }
            $voucher = Vouchers::confirm($customer, 'shop', (int)round($subtotal), $voucherInput);
            $amount = $voucher['total'];
            if (!is_numeric($data['cartTotal'] ?? null) || abs((float)$data['cartTotal'] - $amount) > 0.5) {
                throw new InvalidArgumentException('Giá sản phẩm vừa thay đổi. Vui lòng kiểm tra số tiền trước khi đặt hàng.');
            }

            $lines = [];
            foreach ($items as $item) {
                $lines[] = [
                    'product_id' => $item['product_id'],
                    'product_item_id' => $item['id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price_special'],
                    'vat_value' => 0,
                ];
            }
            $saved = $saveOrder([
                'type' => ORDER, 'source' => WEBSITE, 'status' => NEW_ORDER, 'note' => 'MedUC Shop',
                'contact' => $contact + ['customer_id' => $customerId, 'full_address' => $contact['address']],
                'discount_type' => MONEY, 'discount_value' => $subtotal - $amount,
                'discount_note' => $voucher['discounts'] ? implode(', ', array_column($voucher['discounts'], 'code')) : null,
                'items' => $lines,
            ]);
            if (($saved[CODE] ?? null) !== SUCCESS || empty($saved[DATA]['id'])) {
                throw new RuntimeException($saved[MESSAGE] ?? 'Chưa tạo được đơn Shop.');
            }
            $orderId = (int)$saved[DATA]['id'];
            $savedTotal = $db->execute('SELECT total FROM orders WHERE id=?', [$orderId])->fetchColumn(0);
            if (!is_numeric($savedTotal) || abs((float)$savedTotal - $amount) > 0.001) {
                throw new RuntimeException('Số tiền đã lưu của đơn Shop không khớp với giỏ hàng.');
            }
            $affiliate = Vouchers::affiliateTerms($voucher['partner']['code'] ?? '', $customerId, $amount);
            $db->update('orders', ['code' => $reference, 'orderStatus' => 'initial'] + $affiliate, ['id' => $orderId]);
            $now = time();
            $db->insert('commerce_purchases', [
                'order_id' => $orderId, 'public_code' => $publicCode, 'customer_id' => $customerId,
                'kind' => 'shop', 'package_id' => 0, 'package_name' => 'MedUC Shop',
                'amount' => $amount, 'original_amount' => (int)round($subtotal),
                'reported_at' => $method === BANK ? $now : null, 'created_at' => $now, 'updated_at' => $now,
                'context_json' => json_encode([
                    'payment_method' => $method, 'items' => $items, 'discounts' => $voucher['discounts'],
                ], JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
            ]);
            Vouchers::recordUses('order', $orderId, $customerId, $voucher['discounts']);
            if ($method === BANK) {
                $payment = $savePayment([
                    'foreign_id' => $orderId, 'foreign_type' => ORDER, 'object_type' => CUSTOMER,
                    'object_id' => $customerId, 'full_name' => $contact['full_name'], 'type' => 1,
                    'amount' => $amount, 'payment_method' => BANK, 'reference' => $reference, 'status' => 2,
                ]);
                if (($payment[CODE] ?? null) !== SUCCESS) {
                    throw new RuntimeException('Chưa lưu được báo chuyển khoản cho đơn Shop.');
                }
            }
            return self::receipt($orderId, $customerId);
        });
    }

    public static function byReference(string $reference, int $customerId): array
    {
        if (!preg_match('/^MEDUC[0-9]{6,24}$/D', $reference) || !$customerId) {
            return [];
        }
        $order = CommercePurchases::owned(self::publicCode($reference), $customerId);
        return $order && $order['kind'] === 'shop' && (int)$order['order_customer'] === $customerId
            ? self::formatReceipt($order) : [];
    }

    /** Move an open record into Orders for reconciliation, with its saved prices. */
    public static function importOpenArchive(int $contactId, callable $saveOrder): int
    {
        $db = CommercePurchases::db();
        return $db->transactional(function () use ($db, $contactId, $saveOrder) {
            $row = $db->execute('SELECT c.value,c.created FROM contacts c JOIN contacts_form f ON f.id=c.form_id
                WHERE c.id=? AND c.deleted=0 AND f.code=? FOR UPDATE', [$contactId,Vouchers::SHOP_FORM])->fetch('assoc');
            $data = $row ? json_decode((string)$row['value'], true) : null;
            if (!is_array($data) || !in_array($data['orderStatus'] ?? '', ['', 'initial'], true)) {
                throw new InvalidArgumentException('Chỉ chuyển các đơn Shop cũ còn mở.');
            }
            $public = self::archiveCode($contactId);
            $existing = self::linkedArchive($contactId);
            if ($existing) return $existing;
            $items = $data['cartProducts'] ?? null;
            if (is_string($items)) $items = json_decode($items, true);
            $method = $data['payment'] ?? '';
            $amount = $data['totalPrice'] ?? null;
            $reference = $data['cartId'] ?? '';
            if (!is_array($items) || !$items || count($items) > 100 || !in_array($method, [BANK, COD], true)
                || !is_numeric($amount) || (float)$amount < 1 || !is_string($reference) || !preg_match('/^MEDUC[0-9]{6,24}$/D', $reference)) {
                throw new InvalidArgumentException('Đơn cũ thiếu mã, giá hoặc phương thức. Đối chiếu hồ sơ trước khi nhập lại.');
            }
            $lines = [];
            $gross = 0.0;
            foreach ($items as $item) {
                if (!is_array($item)) {
                    throw new InvalidArgumentException('Danh sách sản phẩm cũ cần được đối chiếu.');
                }
                $sku = (int)($item['id'] ?? 0);
                $product = (int)($item['product_id'] ?? 0);
                $quantity = (int)($item['quantity'] ?? 0);
                $total = $item['total'] ?? null;
                $exists = $db->execute('SELECT 1 FROM products_item WHERE id=? AND product_id=? AND deleted=0', [$sku,$product])->fetchColumn(0);
                if (!$exists || $quantity < 1 || $quantity > 999 || !is_numeric($total) || (float)$total < 0) {
                    throw new InvalidArgumentException('Có sản phẩm cũ không còn mã hàng hoặc thiếu giá. Vui lòng đối chiếu hồ sơ.');
                }
                $unit = round((float)$total / $quantity, 2);
                $lines[] = ['product_id'=>$product,'product_item_id'=>$sku,'quantity'=>$quantity,'price'=>$unit,'vat_value'=>0];
                $gross += $unit * $quantity;
            }
            $discounts = $data['voucher_discounts'] ?? [];
            $discount = is_array($discounts) ? array_sum(array_column($discounts, 'amount')) : 0;
            if (abs($gross - $discount - (float)$amount) > 0.001 || (float)$amount !== (float)(int)$amount) {
                throw new InvalidArgumentException('Giá từng sản phẩm và tổng tiền trong hồ sơ cũ chưa khớp.');
            }
            $contact = [];
            foreach (['full_name'=>255,'phone'=>20,'email'=>255,'address'=>512] as $field => $limit) {
                $value = $data[$field] ?? '';
                $contact[$field] = is_string($value) ? trim($value) : '';
                if (mb_strlen($contact[$field]) > $limit) {
                    throw new InvalidArgumentException('Thông tin người nhận cũ cần được đối chiếu.');
                }
            }
            if (!$contact['full_name'] || !$contact['phone'] || !$contact['address']) {
                throw new InvalidArgumentException('Đơn cũ thiếu thông tin người nhận.');
            }
            // Only an authenticated buyer recorded by the earlier Shop checkout may inherit access.
            $customerId = (int)($data['voucher_buyer_id'] ?? 0);
            $owner = $customerId ? CheckoutContact::customer($customerId) : [];
            if (!$owner || strcasecmp($contact['email'], (string)$owner['email']) !== 0) $customerId = 0;
            $saved = $saveOrder([
                'type'=>ORDER,'source'=>WEBSITE,'status'=>DRAFT,'note'=>'MedUC Shop · đơn trước đây ' . $reference,
                'contact'=>$contact+['customer_id'=>$customerId,'full_address'=>$contact['address']],
                'discount_type'=>MONEY,'discount_value'=>$discount,'items'=>$lines,
            ]);
            if (($saved[CODE] ?? null) !== SUCCESS || empty($saved[DATA]['id'])) {
                throw new RuntimeException('Chưa chuyển được đơn Shop cũ sang sổ đơn hàng.');
            }
            $id = (int)$saved[DATA]['id'];
            $recorded = $db->execute('SELECT total FROM orders WHERE id=?', [$id])->fetchColumn(0);
            if (!is_numeric($recorded) || abs((float)$recorded-(float)$amount)>0.001) {
                throw new RuntimeException('Tổng tiền đơn Shop cũ không khớp với hồ sơ.');
            }
            $changes = ['status'=>NEW_ORDER,'orderStatus'=>'initial','created'=>(int)($row['created'] ?: time())];
            $partner = $data['affiliateCode'] ?? '';
            $commission = $data['affiliateAmount'] ?? 0;
            if (is_string($partner) && strlen($partner) <= 64 && $partner !== '' && is_numeric($commission)
                && (float)$commission > 0 && (float)$commission <= (float)$amount) {
                $changes += ['affiliateCode'=>$partner,'affiliateAmount'=>$commission,'affiliatePaidStatus'=>'unpaid'];
            }
            $db->update('orders', $changes, ['id'=>$id]);
            $now = time();
            $db->insert('commerce_purchases', [
                'order_id'=>$id,'public_code'=>$public,'customer_id'=>$customerId,
                'kind'=>'shop','package_id'=>0,'package_name'=>'MedUC Shop','amount'=>(int)$amount,
                'original_amount'=>(int)round($gross),'created_at'=>(int)($row['created'] ?: $now),'updated_at'=>$now,
                'context_json'=>json_encode([
                    'payment_method'=>$method,'items'=>$items,'discounts'=>$discounts,
                    'archive_id'=>$contactId,'archive_reference'=>$reference,
                ], JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR),
            ]);
            return $id;
        });
    }

    public static function linkedArchive(int $contactId): int
    {
        return (int)CommercePurchases::db()->execute(
            "SELECT order_id FROM commerce_purchases WHERE public_code=? AND kind='shop'", [self::archiveCode($contactId)]
        )->fetchColumn(0);
    }

    private static function archiveCode(int $contactId): string
    {
        return substr(hash('sha256', self::ARCHIVE_CODE_PREFIX . $contactId), 0, 32);
    }

    public static function archiveReference(array $purchase): string
    {
        $context = json_decode((string)$purchase['context_json'], true) ?: [];
        return (string)($context['archive_reference'] ?? '');
    }

    public static function receipt(int $orderId, int $customerId): array
    {
        $order = CommercePurchases::get($orderId);
        return $order && $order['kind'] === 'shop' && (int)$order['order_customer'] === $customerId
            && (int)$order['customer_id'] === $customerId ? self::formatReceipt($order) : [];
    }

    public static function method(array $purchase): string
    {
        $context = json_decode((string)$purchase['context_json'], true) ?: [];
        return ($context['payment_method'] ?? '') === COD ? COD : BANK;
    }

    private static function formatReceipt(array $order): array
    {
        $context = json_decode((string)$order['context_json'], true) ?: [];
        return [
            'order_id' => (int)$order['order_id'], 'cartId' => $order['order_code'],
            'customer_id' => (int)$order['customer_id'], 'full_name' => $order['full_name'],
            'email' => $order['email'], 'phone' => $order['phone'], 'address' => $order['address'],
            'payment' => self::method($order), 'totalPrice' => (int)$order['amount'],
            'totalQuantity' => array_sum(array_column($context['items'] ?? [], 'quantity')),
            'cartProducts' => json_encode($context['items'] ?? [], JSON_UNESCAPED_UNICODE),
            'voucher_discounts' => $context['discounts'] ?? [],
            'paid' => (bool)$order['approved_at'] && CommercePurchases::paid($order),
            'cancelled' => $order['order_status'] === CANCEL || (bool)$order['order_deleted'],
        ];
    }

    private static function publicCode(string $reference): string
    {
        return substr(hash('sha256', 'meduc-shop:' . $reference), 0, 32);
    }
}
