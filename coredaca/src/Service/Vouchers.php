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
        'study' => 'Thưởng thời gian online',
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

    public static function available(string $kind, int $now, int $customer = 0): bool
    {
        return self::installed() && (bool)self::db()->execute(
            "SELECT 1 FROM voucher_campaigns c WHERE c.scope IN ('all',?,?) AND c.active=1 AND c.starts_at<=?
             AND (c.ends_at IS NULL OR c.ends_at>?) AND (c.kind<>'study' OR (?='knowledge' AND ? > 0 AND EXISTS (
                SELECT 1 FROM voucher_grants g WHERE g.campaign_id=c.id AND g.customer_id=?
                AND g.period_start=? AND g.used_at IS NULL AND g.expires_at>?
             ))) LIMIT 1",
            [$kind, self::groupScope($kind), $now, $now, $kind, $customer, $customer, WeeklyOnlineTime::week($now)[0], $now]
        )->fetchColumn(0);
    }

    public static function campaigns(): array
    {
        return self::db()->execute(
            'SELECT v.*, c.code AS partner_code FROM voucher_campaigns v LEFT JOIN customers c ON c.id=v.partner_id ORDER BY v.id DESC'
        )->fetchAll('assoc');
    }

    public static function memberOffers(array $customer, string $affiliate, int $now): array
    {
        $offers = ['common' => [], 'loyalty' => [], 'referral' => []];
        if (!$customer || (int)$customer['status'] !== 1 || !self::installed()) {
            return $offers;
        }
        $id = (int)$customer['id'];
        $partner = self::partner($affiliate);
        $partnerId = $partner && (int)$partner['id'] !== $id ? (int)$partner['id'] : 0;
        $campaigns = self::db()->execute(
            "SELECT * FROM voucher_campaigns WHERE active=1 AND starts_at<=? AND (ends_at IS NULL OR ends_at>?)
             AND (kind IN ('common','loyalty') OR (kind='referral' AND partner_id=?))
             ORDER BY discount_value DESC,id",
            [$now, $now, $partnerId]
        )->fetchAll('assoc');
        $spend = [];
        foreach ($campaigns as $campaign) {
            $kind = $campaign['kind'];
            $expires = $campaign['ends_at'] === null ? null : (int)$campaign['ends_at'];
            $offer = [
                'name' => $campaign['name'], 'scope' => self::SCOPES[$campaign['scope']] ?? $campaign['scope'],
                'code' => $campaign['code'], 'type' => $campaign['discount_type'],
                'value' => (int)$campaign['discount_value'], 'expires_at' => $expires, 'remaining_spend' => 0,
            ];
            if ($kind === 'loyalty') {
                $from = (int)$campaign['spend_from'];
                $until = (int)$campaign['spend_until'];
                $offer['spend_from'] = $from;
                $offer['spend_until'] = $until;
                if (self::reachedLoyaltyThreshold($customer, $campaign, $spend)) {
                    $grant = self::grant($campaign, $id, 0, $expires, $now);
                    if (!$grant || $grant['used_at'] !== null || ($grant['expires_at'] !== null && (int)$grant['expires_at'] <= $now)) {
                        continue;
                    }
                    $offer['code'] = $grant['code'];
                    $offer['type'] = $grant['discount_type'] ?? $offer['type'];
                    $offer['value'] = (int)($grant['discount_value'] ?? $offer['value']);
                } else {
                    $offer['remaining_spend'] = (int)$campaign['required_spend'] - $spend[$from . ':' . $until];
                }
            }
            $offers[$kind][] = $offer;
        }
        return $offers;
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
        $scope = $kind === 'study' ? 'knowledge' : (string)($input['scope'] ?? '');
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
        $hasPurchases = CommercePurchases::installed();
        $join = $hasPurchases ? 'LEFT JOIN commerce_purchases cp ON cp.order_id=o.id' : '';
        $approval = $hasPurchases ? 'cp.approved_at' : 'NULL';
        $value = $hasPurchases ? "CASE WHEN cp.kind='shop' THEN cp.amount ELSE o.total END" : 'o.total';
        $owner = $hasPurchases ? ' AND (cp.order_id IS NULL OR cp.customer_id=c.customer_id)' : '';
        return (int)self::db()->execute(
            "SELECT COALESCE(SUM($value),0) FROM orders o $join
             WHERE o.deleted=0 AND o.type='order' AND o.status<>'cancel'
               AND o.total>0
               AND EXISTS (SELECT 1 FROM orders_contact c WHERE c.order_id=o.id AND c.customer_id=? $owner)
               AND o.total<=(SELECT COALESCE(SUM(CASE WHEN p.type=1 THEN p.amount ELSE -p.amount END),0)
                 FROM payments p WHERE p.foreign_type='order' AND p.foreign_id=o.id AND p.status=1)
               AND COALESCE($approval, (SELECT MAX(COALESCE(NULLIF(r.payment_time,0), r.created))
                 FROM payments r WHERE r.foreign_type='order' AND r.foreign_id=o.id AND r.status=1 AND r.type=1),
                 o.created) BETWEEN ? AND ?",
            [$id, $from, $until - 1]
        )->fetchColumn(0);

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
            'INSERT INTO voucher_grants (campaign_id,customer_id,period_start,code,expires_at,issued_at,discount_type,discount_value)
             VALUES (?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE id=id',
            array_merge($params, ['MV-' . strtoupper(bin2hex(random_bytes(9))), $expires, $now,
                $campaign['discount_type'], $campaign['discount_value']])
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
            && ($campaign['kind'] !== 'study' || $kind === 'knowledge')
            && in_array($campaign['scope'], ['all', $kind, self::groupScope($kind)], true);
    }

    public static function claimOnlineReward(int $customer, int $campaignId, int $week, int $now): string
    {
        $progress = WeeklyOnlineTime::total($customer, $now);
        if ($week !== $progress['week_start']) {
            throw new InvalidArgumentException('Đã sang tuần mới. Hãy kiểm tra lại mốc thưởng.');
        }
        $campaign = self::db()->execute(
            "SELECT * FROM voucher_campaigns WHERE id=? AND kind='study'", [$campaignId]
        )->fetch('assoc');
        if (!$campaign || !self::applies($campaign, 'knowledge', $now)) {
            throw new InvalidArgumentException('Mốc thưởng này đã hết hiệu lực.');
        }
        if ($progress['seconds'] < (int)$campaign['study_minutes'] * 60) {
            throw new InvalidArgumentException('Bạn chưa đủ thời gian online để nhận mã này.');
        }
        $expiry = min((int)($campaign['ends_at'] ?? $progress['resets_at']), $progress['resets_at']);
        $grant = self::grant($campaign, $customer, $week, $expiry, $now);
        if (!$grant || $grant['used_at'] !== null || (int)$grant['expires_at'] <= $now) {
            throw new InvalidArgumentException('Mã tuần này đã dùng hoặc đã hết hạn.');
        }
        return $grant['code'];
    }

    public static function onlineProgress(int $customer, int $now): array
    {
        $progress = WeeklyOnlineTime::total($customer, $now);
        $campaigns = self::db()->execute(
            "SELECT c.*, g.code AS grant_code, g.used_at, g.expires_at,
                    g.discount_type AS grant_discount_type, g.discount_value AS grant_discount_value
             FROM voucher_campaigns c
             LEFT JOIN voucher_grants g ON g.campaign_id=c.id AND g.customer_id=? AND g.period_start=?
             WHERE c.kind='study' AND c.active=1 AND c.starts_at<=?
               AND (c.ends_at IS NULL OR c.ends_at>?) ORDER BY c.study_minutes, c.id",
            [$customer, $progress['week_start'], $now, $now]
        )->fetchAll('assoc');
        $rewards = [];
        $goal = 0;
        foreach ($campaigns as $campaign) {
            if (!self::applies($campaign, 'knowledge', $now)) {
                continue;
            }
            $target = (int)$campaign['study_minutes'] * 60;
            $goal = max($goal, $target);
            $claimed = $campaign['grant_code'] !== null;
            if ($campaign['used_at'] !== null || ($claimed && (int)$campaign['expires_at'] <= $now)) {
                continue;
            }
            $rewards[] = [
                'id' => (int)$campaign['id'],
                'name' => $campaign['name'],
                'target_seconds' => $target,
                'type' => $campaign['grant_discount_type'] ?? $campaign['discount_type'],
                'value' => (int)($campaign['grant_discount_value'] ?? $campaign['discount_value']),
                'code' => $campaign['grant_code'],
                'claimable' => !$claimed && $progress['seconds'] >= $target,
                'expires_at' => $claimed ? (int)$campaign['expires_at'] : null,
            ];
        }
        return $progress + ['enabled' => $goal > 0, 'goal_seconds' => $goal, 'server_at' => $now, 'rewards' => $rewards];
    }

    public static function personalOffers(array $customer, string $kind, int $now): array
    {
        if (!$customer || !self::installed()) {
            return [];
        }
        $id = (int)$customer['id'];
        $campaigns = self::db()->execute(
            "SELECT * FROM voucher_campaigns WHERE kind='loyalty' AND active=1
             AND starts_at<=? AND (ends_at IS NULL OR ends_at>?) ORDER BY discount_value DESC,id",
            [$now, $now]
        )->fetchAll('assoc');
        $offers = [];
        $spend = [];
        foreach ($campaigns as $campaign) {
            if (!self::applies($campaign, $kind, $now) || !self::reachedLoyaltyThreshold($customer, $campaign, $spend)) {
                continue;
            }
            $expiry = $campaign['ends_at'] === null ? null : (int)$campaign['ends_at'];
            $grant = self::grant($campaign, $id, 0, $expiry, $now);
            if ($grant && $grant['used_at'] === null && ($grant['expires_at'] === null || (int)$grant['expires_at'] > $now)) {
                $offers[] = [
                    'kind' => $campaign['kind'], 'name' => $campaign['name'], 'code' => $grant['code'],
                    'value' => (int)($grant['discount_value'] ?? $campaign['discount_value']),
                    'type' => $grant['discount_type'] ?? $campaign['discount_type'],
                    'expires_at' => $grant['expires_at'] === null ? null : (int)$grant['expires_at'],
                ];
            }
        }
        if ($kind === 'knowledge') {
            $progress = self::onlineProgress($id, $now);
            foreach ($progress['rewards'] as $reward) {
                if ($reward['code'] !== null) {
                    $offers[] = [
                        'kind' => 'study', 'name' => $reward['name'], 'code' => $reward['code'],
                        'value' => $reward['value'], 'type' => $reward['type'], 'expires_at' => $reward['expires_at'],
                    ];
                }
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
            if ($campaign['kind'] === 'study' && (int)($grant['period_start'] ?? 0) !== WeeklyOnlineTime::week($now)[0]) {
                throw new InvalidArgumentException('Mã thưởng thời gian online chỉ dùng trong tuần nhận mã.');
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
            $value = (int)($grant['discount_value'] ?? $campaign['discount_value']);
            $discountType = $grant['discount_type'] ?? $campaign['discount_type'];
            $amount = $discountType === 'percent'
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
