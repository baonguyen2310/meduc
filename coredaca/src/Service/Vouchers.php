<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Datasource\ConnectionManager;
use Cake\Log\Log;
use Cake\ORM\TableRegistry;
use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;

final class Vouchers
{
    public const KINDS = [
        'common' => 'Mã chung',
        'study' => 'Thưởng thời gian học',
        'loyalty' => 'Khách hàng thân thiết',
        'referral' => 'Mã giới thiệu',
    ];
    public const SCOPES = [
        'all' => 'Tất cả đơn',
        'shop' => 'MedUC Shop',
        'academy' => 'MedUC Academy · Tất cả khoá học',
        'knowledge' => CoursePricing::LABELS['knowledge'],
        'exam_solution' => CoursePricing::LABELS['exam_solution'],
        'quiz' => 'Đề thi',
        'document' => 'Lượt tải tài liệu',
    ];
    public const SHOP_FORM = '61CQ0U3H9I';
    private const ACADEMY_KINDS = ['knowledge', 'exam_solution'];

    private static function db()
    {
        return ConnectionManager::get('default');
    }

    public static function installed(): bool
    {
        static $installed;
        if ($installed === null) {
            // This is the last table created by the additive migration.
            $installed = (bool)self::db()->execute("SHOW TABLES LIKE 'voucher_uses'")->fetch();
        }
        return $installed;
    }

    public static function currentWeek(int $now): array
    {
        $monday = (new DateTimeImmutable('@' . $now))->setTimezone(new DateTimeZone('Asia/Ho_Chi_Minh'))
            ->modify('monday this week')->setTime(0, 0);
        return [$monday->getTimestamp(), $monday->modify('+1 week')->getTimestamp()];
    }

    public static function recordStudyMinute(int $customer, int $minute): void
    {
        [$week] = self::currentWeek($minute * 60);
        self::db()->execute(
            'INSERT INTO voucher_study_weeks (customer_id,week_start,active_minutes,last_minute) VALUES (?,?,1,?)
             ON DUPLICATE KEY UPDATE active_minutes=active_minutes+(last_minute<VALUES(last_minute)),
                 last_minute=GREATEST(last_minute,VALUES(last_minute))',
            [$customer, $week, $minute]
        );
    }

    public static function hasStudyCampaign(): bool
    {
        return self::installed() && (bool)self::db()->execute(
            "SELECT 1 FROM voucher_campaigns WHERE kind='study' AND active=1 AND starts_at<=? AND (ends_at IS NULL OR ends_at>?) LIMIT 1",
            [time(), time()]
        )->fetchColumn(0);
    }

    public static function available(string $kind, int $now): bool
    {
        return self::installed() && (bool)self::db()->execute(
            "SELECT 1 FROM voucher_campaigns WHERE scope IN ('all',?,?) AND active=1 AND starts_at<=?
             AND (ends_at IS NULL OR ends_at>?) LIMIT 1", [$kind, self::groupScope($kind), $now, $now]
        )->fetchColumn(0);
    }

    public static function campaigns(): array
    {
        return self::db()->execute(
            'SELECT v.*, c.code AS partner_code FROM voucher_campaigns v LEFT JOIN customers c ON c.id=v.partner_id ORDER BY v.id DESC'
        )->fetchAll('assoc');
    }

    public static function partner(string $code): ?array
    {
        if ($code === '' || strlen($code) > 64) {
            return null;
        }
        return self::db()->execute(
            'SELECT id,code FROM customers WHERE code=? AND is_partner_affiliate=1 AND status=1 AND deleted=0 LIMIT 1',
            [$code]
        )->fetch('assoc') ?: null;
    }

    public static function affiliateTerms(string $code, int $customer, int $total): array
    {
        if ($code === '' || strlen($code) > 64) {
            return [];
        }
        $partner = self::db()->execute(
            'SELECT id,code,affiliate_percent FROM customers
             WHERE code=? AND is_partner_affiliate=1 AND status=1 AND deleted=0 LIMIT 1', [$code]
        )->fetch('assoc');
        if (!$partner || (int)$partner['id'] === $customer) {
            return [];
        }
        $terms = ['affiliateCode' => $partner['code']];
        $rate = $partner['affiliate_percent'];
        if (empty($rate)) {
            $settings = TableRegistry::get('Settings')->getSettingWebsite();
            $rate = $settings['website_info']['vi_affiliate_percent'] ?? null;
        }
        if ($rate !== null) {
            $terms += [
                'affiliatePercent' => (float)$rate,
                'affiliateAmount' => round($total * (float)$rate / 100),
                'affiliatePaidStatus' => 'unpaid',
            ];
        }
        return $terms;
    }

    public static function saveCampaign(int $id, array $input): void
    {
        $row = self::campaignData($input);
        self::db()->transactional(function ($db) use ($id, $row) {
            if ($id) {
                $kind = $db->execute('SELECT kind FROM voucher_campaigns WHERE id=? FOR UPDATE', [$id])->fetchColumn(0);
                if (!$kind || $kind !== $row['kind']) {
                    throw new InvalidArgumentException('Loại mã đã cố định khi tạo chương trình.');
                }
            }
            if ($row['code'] !== null && $db->execute(
                'SELECT id FROM voucher_campaigns WHERE code=? AND id<>?', [$row['code'], $id]
            )->fetchColumn(0)) {
                throw new InvalidArgumentException('Mã ưu đãi này đã được sử dụng cho chương trình khác.');
            }
            if ($id) {
                $db->update('voucher_campaigns', $row, ['id' => $id]);
            } else {
                $db->insert('voucher_campaigns', $row);
            }
        });
    }

    private static function campaignData(array $input): array
    {
        $kind = (string)($input['kind'] ?? '');
        $scope = (string)($input['scope'] ?? '');
        $name = trim((string)($input['name'] ?? ''));
        $type = (string)($input['discount_type'] ?? '');
        $value = filter_var($input['discount_value'] ?? null, FILTER_VALIDATE_INT);
        if (!isset(self::KINDS[$kind], self::SCOPES[$scope]) || $name === '' || mb_strlen($name) > 160
            || !in_array($type, ['fixed', 'percent'], true) || !$value || $value < 1
            || $value > ($type === 'percent' ? 100 : 999999999999)) {
            throw new InvalidArgumentException('Kiểm tra tên, loại mã, phạm vi và mức giảm.');
        }

        $starts = self::date($input['starts_at'] ?? '');
        $ends = self::date($input['ends_at'] ?? '', true);
        if ($starts === null || ($ends !== null && $ends <= $starts)) {
            throw new InvalidArgumentException('Kiểm tra ngày bắt đầu và kết thúc sử dụng mã.');
        }
        $row = [
            'name' => $name, 'kind' => $kind, 'scope' => $scope, 'code' => null,
            'discount_type' => $type, 'discount_value' => $value, 'starts_at' => $starts,
            'ends_at' => $ends, 'active' => empty($input['active']) ? 0 : 1,
            'required_spend' => null, 'spend_from' => null, 'spend_until' => null,
            'study_minutes' => null, 'partner_id' => null,
        ];
        if (in_array($kind, ['common', 'referral'], true)) {
            $row['code'] = strtoupper(trim((string)($input['code'] ?? '')));
            if (!preg_match('/^[A-Z0-9][A-Z0-9-]{2,31}$/D', $row['code']) || strpos($row['code'], 'MV-') === 0) {
                throw new InvalidArgumentException('Mã cần 3–32 ký tự chữ, số hoặc dấu gạch ngang. Tiền tố MV- dành cho mã cá nhân.');
            }
        }
        if ($kind === 'study') {
            $minutes = filter_var($input['study_minutes'] ?? null, FILTER_VALIDATE_INT);
            if (!$minutes || $minutes < 1 || $minutes > 10080) {
                throw new InvalidArgumentException('Nhập số phút tích lũy trong tuần.');
            }
            $row['scope'] = in_array($scope, self::ACADEMY_KINDS, true) ? $scope : 'academy';
            $row['study_minutes'] = $minutes;
        }
        if ($kind === 'loyalty') {
            $from = self::date($input['spend_from'] ?? '');
            $until = self::date($input['spend_until'] ?? '', true);
            $spend = filter_var($input['required_spend'] ?? null, FILTER_VALIDATE_INT);
            if (!$spend || $spend < 1 || $spend > 999999999999 || $from === null || $until === null || $from >= $until) {
                throw new InvalidArgumentException('Nhập ngưỡng chi tiêu và khoảng ngày tích lũy hợp lệ.');
            }
            $row['required_spend'] = $spend;
            $row['spend_from'] = $from;
            $row['spend_until'] = $until;
        }
        if ($kind === 'referral') {
            $partner = self::partner(trim((string)($input['partner_code'] ?? '')));
            if (!$partner) {
                throw new InvalidArgumentException('Mã đối tác giới thiệu đang hoạt động là bắt buộc.');
            }
            $row['partner_id'] = $partner['id'];
        }
        return $row;
    }

    private static function date($value, bool $throughDay = false): ?int
    {
        if ($value === '') {
            return null;
        }
        $date = DateTimeImmutable::createFromFormat('!Y-m-d', (string)$value, new DateTimeZone('Asia/Ho_Chi_Minh'));
        if (!$date || $date->format('Y-m-d') !== $value || $date->getTimestamp() < 0) {
            throw new InvalidArgumentException('Ngày phải theo định dạng năm-tháng-ngày.');
        }
        return ($throughDay ? $date->modify('+1 day') : $date)->getTimestamp();
    }

    private static function paidSpend(array $customer, int $from, int $until): int
    {
        $id = (int)$customer['id'];
        $approval = CommercePurchases::installed()
            ? '(SELECT paid.approved_at FROM commerce_purchases paid WHERE paid.order_id=o.id)'
            : 'NULL';
        $sold = self::db()->execute(
            "SELECT COALESCE(SUM(o.total),0) FROM orders o
             WHERE o.deleted=0 AND o.type='order' AND o.status<>'cancel'
               AND o.total>0
               AND EXISTS (SELECT 1 FROM orders_contact c WHERE c.order_id=o.id AND c.customer_id=?)
               AND o.total<=(SELECT COALESCE(SUM(CASE WHEN p.type=1 THEN p.amount ELSE -p.amount END),0)
                 FROM payments p WHERE p.foreign_type='order' AND p.foreign_id=o.id AND p.status=1)
               AND COALESCE($approval, (SELECT MAX(COALESCE(NULLIF(r.payment_time,0), r.created))
                 FROM payments r WHERE r.foreign_type='order' AND r.foreign_id=o.id AND r.status=1 AND r.type=1),
                 o.created) BETWEEN ? AND ?",
            [$id, $from, $until - 1]
        )->fetchColumn(0);

        $email = strtolower(trim((string)($customer['email'] ?? '')));
        // Earlier Shop orders with an affiliate stored the partner's ID. Their
        // checkout email is the authenticated buyer's email, set on the server.
        $shop = self::db()->execute(
            "SELECT COALESCE(SUM(j.total),0) FROM (
               SELECT CAST(JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.totalPrice')) AS DECIMAL(16,0)) total,
                 NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.voucher_buyer_id')), 'null') buyer,
                 NULLIF(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.customer_id')), 'null'), '') legacy_customer,
                 NULLIF(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.affiliateCode')), 'null'), '') legacy_partner,
                 LOWER(JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.email'))) email,
                 JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.orderStatus')) order_status,
                 COALESCE(NULLIF(CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(c.payload,'$.voucher_paid_at')), 'null') AS UNSIGNED),0),
                   c.created) paid_at
               FROM (SELECT CASE WHEN JSON_VALID(r.value) THEN r.value ELSE '{}' END payload, r.created
                 FROM contacts r JOIN contacts_form f ON f.id=r.form_id WHERE f.code=? AND r.deleted=0) c
             ) j WHERE j.order_status='success' AND j.total>0 AND j.paid_at BETWEEN ? AND ?
               AND (j.buyer=? OR (j.buyer IS NULL AND (
                 (j.legacy_partner IS NULL AND j.legacy_customer=?) OR
                 ((j.legacy_partner IS NOT NULL OR j.legacy_customer IS NULL) AND ?<>'' AND j.email=?)
               )))",
            [self::SHOP_FORM, $from, $until - 1, (string)$id, (string)$id, $email, $email]
        )->fetchColumn(0);
        return (int)$sold + (int)$shop;
    }

    private static function reachedLoyaltyThreshold(array $customer, array $campaign, array &$totals): bool
    {
        $from = (int)$campaign['spend_from'];
        $until = (int)$campaign['spend_until'];
        $window = $from . ':' . $until;
        $totals[$window] = $totals[$window] ?? self::paidSpend($customer, $from, $until);
        return $totals[$window] >= (int)$campaign['required_spend'];
    }

    private static function grant(array $campaign, int $customer, int $period, ?int $expires, int $now): array
    {
        $select = 'SELECT * FROM voucher_grants WHERE campaign_id=? AND customer_id=? AND period_start=?';
        $params = [$campaign['id'], $customer, $period];
        $db = self::db();
        $existing = $db->execute($select, $params)->fetch('assoc');
        if ($existing) {
            return $existing;
        }
        $db->execute(
            'INSERT INTO voucher_grants (campaign_id,customer_id,period_start,code,expires_at,issued_at)
             VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE id=id',
            array_merge($params, ['MV-' . strtoupper(bin2hex(random_bytes(9))), $expires, $now])
        );
        return $db->execute($select . ' LOCK IN SHARE MODE', $params)->fetch('assoc') ?: [];
    }

    public static function awardLoyalty(array $customer, int $now): void
    {
        if (empty($customer['id']) || !self::installed()) {
            return;
        }
        $campaigns = self::db()->execute(
            "SELECT * FROM voucher_campaigns WHERE kind='loyalty' AND active=1
             AND starts_at<=? AND (ends_at IS NULL OR ends_at>?) ORDER BY id", [$now, $now]
        )->fetchAll('assoc');
        $totals = [];
        foreach ($campaigns as $campaign) {
            if (self::reachedLoyaltyThreshold($customer, $campaign, $totals)) {
                self::grant($campaign, (int)$customer['id'], 0, $campaign['ends_at'] === null ? null : (int)$campaign['ends_at'], $now);
            }
        }
    }

    public static function awardAfterPayment(int $order): void
    {
        if (self::db()->inTransaction()) {
            return;
        }
        try {
            if (!self::installed()) {
                return;
            }
            $purchase = CommercePurchases::get($order);
            if ($purchase && $purchase['approved_at'] && CommercePurchases::paid($purchase)) {
                self::awardLoyalty(['id' => $purchase['customer_id'], 'email' => $purchase['email']], time());
            }
        } catch (\Throwable $error) {
            Log::error('Could not issue a loyalty voucher for order ' . $order . ': ' . $error->getMessage());
        }
    }

    private static function groupScope(string $kind): string
    {
        return in_array($kind, self::ACADEMY_KINDS, true) ? 'academy' : $kind;
    }

    private static function applies(array $campaign, string $kind, int $now): bool
    {
        return (int)$campaign['active'] === 1 && (int)$campaign['starts_at'] <= $now
            && ($campaign['ends_at'] === null || (int)$campaign['ends_at'] > $now)
            && in_array($campaign['scope'], ['all', $kind, self::groupScope($kind)], true);
    }

    public static function personalOffers(array $customer, string $kind, int $now): array
    {
        if (!$customer || !self::installed()) {
            return [];
        }
        $id = (int)$customer['id'];
        [$week, $nextWeek] = self::currentWeek($now);
        $minutes = (int)self::db()->execute(
            'SELECT active_minutes FROM voucher_study_weeks WHERE customer_id=? AND week_start=?', [$id, $week]
        )->fetchColumn(0);
        $campaigns = self::db()->execute(
            "SELECT * FROM voucher_campaigns WHERE kind IN ('loyalty','study') AND active=1
             AND starts_at<=? AND (ends_at IS NULL OR ends_at>?) ORDER BY discount_value DESC,id",
            [$now, $now]
        )->fetchAll('assoc');
        $offers = [];
        $spend = [];
        foreach ($campaigns as $campaign) {
            if (!self::applies($campaign, $kind, $now)) {
                continue;
            }
            $study = $campaign['kind'] === 'study';
            $eligible = $study ? $minutes >= (int)$campaign['study_minutes']
                : self::reachedLoyaltyThreshold($customer, $campaign, $spend);
            if (!$eligible) {
                continue;
            }
            $expiry = $campaign['ends_at'] === null ? null : (int)$campaign['ends_at'];
            if ($study) {
                $expiry = min($expiry ?? $nextWeek, $nextWeek);
            }
            $grant = self::grant($campaign, $id, $study ? $week : 0, $expiry, $now);
            if ($grant && $grant['used_at'] === null && ($grant['expires_at'] === null || (int)$grant['expires_at'] > $now)) {
                $offers[] = [
                    'kind' => $campaign['kind'], 'name' => $campaign['name'], 'code' => $grant['code'],
                    'value' => (int)$campaign['discount_value'], 'type' => $campaign['discount_type'],
                    'expires_at' => $grant['expires_at'] === null ? null : (int)$grant['expires_at'],
                ];
            }
        }
        return $offers;
    }

    private static function codes($value): array
    {
        if (is_string($value)) {
            $value = json_decode($value, true);
        }
        if (!is_array($value) || count($value) > count(self::KINDS)) {
            throw new InvalidArgumentException('Chọn tối đa một mã cho mỗi loại ưu đãi.');
        }
        $codes = [];
        foreach ($value as $code) {
            if (!is_string($code) || !preg_match('/^[A-Z0-9][A-Z0-9-]{2,31}$/D', strtoupper(trim($code)))) {
                throw new InvalidArgumentException('Mã ưu đãi không hợp lệ.');
            }
            $codes[] = strtoupper(trim($code));
        }
        sort($codes, SORT_STRING);
        return array_values(array_unique($codes));
    }

    public static function quote(array $customer, string $kind, int $base, array $data, bool $lock = false): array
    {
        $codes = self::codes($data['voucher_codes'] ?? []);
        $result = ['base' => $base, 'total' => $base, 'discounts' => [], 'partner' => null];
        if (!self::installed()) {
            if ($codes) {
                throw new InvalidArgumentException('Ưu đãi đang được cập nhật.');
            }
            return $result;
        }
        $owner = (int)($customer['id'] ?? 0);
        $now = time();
        $referral = $data['voucher_referral'] ?? '';
        $result['partner'] = is_string($referral) ? self::partner(trim($referral)) : null;
        if ($result['partner'] && (int)$result['partner']['id'] === $owner) {
            $result['partner'] = null;
        }

        $selected = [];
        $campaignLock = $lock ? ' LOCK IN SHARE MODE' : '';
        $spend = [];
        foreach ($codes as $code) {
            $grant = null;
            if (strpos($code, 'MV-') === 0) {
                $grant = self::db()->execute(
                    'SELECT * FROM voucher_grants WHERE code=? AND customer_id=?' . ($lock ? ' FOR UPDATE' : ''),
                    [$code, $owner]
                )->fetch('assoc');
                if (!$grant || $grant['used_at'] !== null || ($grant['expires_at'] !== null && (int)$grant['expires_at'] <= $now)) {
                    throw new InvalidArgumentException('Mã cá nhân đã dùng, hết hạn hoặc không thuộc tài khoản này.');
                }
                $campaign = self::db()->execute('SELECT * FROM voucher_campaigns WHERE id=?' . $campaignLock, [$grant['campaign_id']])->fetch('assoc');
            } else {
                $campaign = self::db()->execute('SELECT * FROM voucher_campaigns WHERE code=?' . $campaignLock, [$code])->fetch('assoc');
            }
            if (!$campaign || !self::applies($campaign, $kind, $now)) {
                throw new InvalidArgumentException('Mã ' . $code . ' đã hết hạn hoặc chưa áp dụng cho đơn này.');
            }
            if (isset($selected[$campaign['kind']])) {
                throw new InvalidArgumentException('Mỗi đơn dùng một mã ' . self::KINDS[$campaign['kind']] . '.');
            }
            if ($campaign['kind'] === 'loyalty' && !self::reachedLoyaltyThreshold($customer, $campaign, $spend)) {
                throw new InvalidArgumentException('Tổng chi tiêu trong kỳ tích lũy hiện chưa đủ để dùng mã này.');
            }
            if ($campaign['kind'] === 'referral') {
                $partner = self::db()->execute(
                    'SELECT id,code FROM customers WHERE id=? AND is_partner_affiliate=1 AND status=1 AND deleted=0',
                    [$campaign['partner_id']]
                )->fetch('assoc');
                if (!$partner || (int)$partner['id'] === $owner
                    || ($result['partner'] && (int)$result['partner']['id'] !== (int)$partner['id'])) {
                    throw new InvalidArgumentException('Mã giới thiệu không phù hợp với lượt giới thiệu của đơn này.');
                }
                $result['partner'] = $partner;
            }
            $selected[$campaign['kind']] = [$campaign, $grant, $code, false];
        }

        if (!isset($selected['referral']) && $result['partner'] && empty($data['voucher_skip_referral'])) {
            $campaign = self::db()->execute(
                "SELECT * FROM voucher_campaigns WHERE kind='referral' AND partner_id=? AND active=1
                 AND scope IN ('all',?,?) AND starts_at<=? AND (ends_at IS NULL OR ends_at>?) ORDER BY id DESC LIMIT 1" . $campaignLock,
                [$result['partner']['id'], $kind, self::groupScope($kind), $now, $now]
            )->fetch('assoc');
            if ($campaign) {
                $selected['referral'] = [$campaign, null, $campaign['code'], true];
            }
        }

        foreach (self::KINDS as $type => $label) {
            if (!isset($selected[$type])) {
                continue;
            }
            [$campaign, $grant, $code, $automatic] = $selected[$type];
            $value = (int)$campaign['discount_value'];
            $amount = $campaign['discount_type'] === 'percent'
                ? intdiv($base, 100) * $value + intdiv(($base % 100) * $value, 100)
                : $value;
            if ($automatic && ($amount < 1 || $amount >= $result['total'])) {
                continue;
            }
            $amount = min($result['total'], $amount);
            if ($amount < 1) {
                throw new InvalidArgumentException('Mã ' . $code . ' không tạo khoản giảm cho đơn này.');
            }
            $result['total'] -= $amount;
            $result['discounts'][] = [
                'kind' => $type, 'label' => $label, 'name' => $campaign['name'], 'amount' => $amount, 'code' => $code,
                'campaign_id' => (int)$campaign['id'], 'grant_id' => $grant ? (int)$grant['id'] : null,
            ];
        }
        if ($result['total'] < 1) {
            throw new InvalidArgumentException('Luồng thanh toán hiện cần số tiền dương. Hãy đổi mã hoặc chọn thêm sản phẩm.');
        }
        return $result;
    }

    public static function checkoutInput(array $input): array
    {
        return array_intersect_key($input, array_flip(['voucher_codes', 'voucher_referral', 'voucher_expected_amount', 'voucher_skip_referral']));
    }

    /** Re-evaluate within the same transaction that creates the order and records its uses. */
    public static function confirm(array $customer, string $kind, int $base, array $data): array
    {
        $quote = self::quote($customer, $kind, $base, $data, true);
        $expected = $data['voucher_expected_amount'] ?? null;
        if (($quote['discounts'] || $expected !== null) && filter_var($expected, FILTER_VALIDATE_INT) !== $quote['total']) {
            throw new InvalidArgumentException('Ưu đãi hoặc giá đã thay đổi. Kiểm tra lại số tiền trước khi đặt hàng.');
        }
        return $quote;
    }

    public static function recordUses(string $source, int $order, int $customer, array $discounts): void
    {
        $db = self::db();
        $now = time();
        foreach ($discounts as $line) {
            if ($line['grant_id'] !== null) {
                $updated = $db->execute('UPDATE voucher_grants SET used_at=? WHERE id=? AND used_at IS NULL', [$now, $line['grant_id']]);
                if ($updated->rowCount() !== 1) {
                    throw new InvalidArgumentException('Mã cá nhân đã được dùng cho đơn khác.');
                }
            }
            $db->insert('voucher_uses', [
                'order_source' => $source, 'order_id' => $order, 'customer_id' => $customer,
                'kind' => $line['kind'], 'campaign_id' => $line['campaign_id'], 'grant_id' => $line['grant_id'],
                'code' => $line['code'], 'amount' => $line['amount'], 'created_at' => $now,
            ]);
        }
    }
}
