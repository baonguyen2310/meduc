<?php
declare(strict_types=1);

namespace App\Service;

final class OrderDiscounts
{
    public static function forMember(array $order, int $customer, ?string $courseSnapshot): array
    {
        $id = (int)($order['id'] ?? 0);
        if ($id <= 0 || $customer <= 0) return ['lines' => [], 'total' => 0, 'subtotal' => null];

        $purchase = CommercePurchases::installed() ? CommercePurchases::db()->execute(
            'SELECT kind, original_amount, amount, context_json FROM commerce_purchases WHERE order_id=? AND customer_id=?',
            [$id, $customer]
        )->fetch('assoc') : [];
        $shop = ($purchase['kind'] ?? '') === 'shop';
        $context = self::decode($purchase['context_json'] ?? null);
        $quote = self::decode($courseSnapshot);
        $saved = $shop ? ($context['discounts'] ?? []) : ($context['vouchers']['discounts'] ?? $quote['vouchers']['discounts'] ?? []);
        $vouchers = self::voucherLines($id, $customer, is_array($saved) ? $saved : []);
        $voucherTotal = array_sum(array_column($vouchers, 'amount'));
        $voucherCodes = array_column($vouchers, 'code');

        $original = (float)($purchase['original_amount'] ?? $quote['package']['price'] ?? 0);
        $packagePrice = (float)($quote['package']['amount'] ?? $context['vouchers']['base'] ?? $quote['vouchers']['base']
            ?? ((float)($purchase['amount'] ?? $quote['amount'] ?? 0) + $voucherTotal));
        $packageDiscount = !$shop && $packagePrice > 0 ? $original - $packagePrice : 0.0;
        $shopSavings = $shop ? self::shopSavings($context['items'] ?? []) : 0.0;
        $original += $shopSavings;

        $coupon = (float)($order['total_coupon'] ?? 0);
        $affiliate = (float)($order['total_affiliate'] ?? 0);
        $orderDiscount = (float)($order['total_discount'] ?? 0);
        $itemDiscount = (float)($order['total_discount_items'] ?? 0);
        if ($shop) {
            // The Shop checkout also stores its voucher total as the order discount.
            $orderDiscount -= $voucherTotal;
        } elseif (!$purchase && $coupon > 0 && ($order['source'] ?? '') === 'website') {
            // The previous website checkout recorded the coupon in both totals.
            $orderDiscount -= $coupon;
            if (abs($itemDiscount - $coupon) < 0.01) $itemDiscount = 0.0;
        }

        $lines = [];
        foreach ([
            ['Ưu đãi theo gói', '', $packageDiscount],
            ['Giảm giá sản phẩm', '', $shopSavings + $itemDiscount],
            ['Phiếu giảm giá', $order['coupon_code'] ?? '', $coupon],
            ['Mã giới thiệu', $order['affiliate_code'] ?? '', $affiliate],
            ['Giảm giá đơn hàng', '', $orderDiscount],
        ] as [$label, $code, $amount]) {
            if ($amount <= 0 || ($code !== '' && in_array($code, $voucherCodes, true))) continue;
            $lines[] = ['label' => $label, 'name' => '', 'code' => $code, 'amount' => $amount];
        }
        $lines = array_merge($lines, $vouchers);
        $total = array_sum(array_column($lines, 'amount'));
        $reconciled = $original - $total + (float)($order['shipping_fee_customer'] ?? 0) + (float)($order['total_vat'] ?? 0);
        $subtotal = $original > 0 && abs($reconciled - (float)$order['total']) < 0.01 ? $original : null;

        return ['lines' => $lines, 'total' => $total, 'subtotal' => $subtotal];
    }

    private static function voucherLines(int $order, int $customer, array $snapshot): array
    {
        $rows = [];
        foreach ($snapshot as $entry) {
            if (!is_array($entry) || !is_string($entry['kind'] ?? null)
                || !isset(Vouchers::KINDS[$entry['kind']]) || !is_numeric($entry['amount'] ?? null)) continue;
            $kind = $entry['kind'];
            $rows[$kind] = [
                'label' => Vouchers::KINDS[$kind],
                'name' => is_string($entry['name'] ?? null) ? $entry['name'] : '',
                'code' => is_string($entry['code'] ?? null) ? $entry['code'] : '',
                'amount' => (int)$entry['amount'],
            ];
        }
        if (Vouchers::installed()) {
            $uses = CommercePurchases::db()->execute(
                "SELECT kind, code, amount FROM voucher_uses WHERE order_source='order' AND order_id=? AND customer_id=?",
                [$order, $customer]
            )->fetchAll('assoc');
            foreach ($uses as $use) {
                $kind = $use['kind'];
                $saved = $rows[$kind] ?? [];
                $rows[$kind] = [
                    'label' => Vouchers::KINDS[$kind] ?? 'Mã giảm giá',
                    'name' => ($saved['code'] ?? '') === $use['code'] ? ($saved['name'] ?? '') : '',
                    'code' => $use['code'],
                    'amount' => (int)$use['amount'],
                ];
            }
        }
        $rows = array_replace(array_intersect_key(Vouchers::KINDS, $rows), $rows);
        return array_values(array_filter($rows, static function (array $line): bool { return $line['amount'] > 0; }));
    }

    private static function shopSavings($items): float
    {
        $total = 0.0;
        foreach (is_array($items) ? $items : [] as $item) {
            $sellingPrice = (float)($item['price_special'] ?? 0);
            if ($sellingPrice > 0) {
                $total += max(0, (float)($item['price'] ?? 0) - $sellingPrice) * max(0, (int)($item['quantity'] ?? 0));
            }
        }
        return $total;
    }

    private static function decode(?string $json): array
    {
        $data = $json === null ? null : json_decode($json, true);
        return is_array($data) ? $data : [];
    }
}
