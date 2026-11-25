<?php
declare(strict_types=1);

// Run plan, prepare the grant columns, deploy Vouchers.php, then run apply.
$mode = $argv[1] ?? 'plan';
if (PHP_SAPI !== 'cli' || !in_array($mode, ['plan', 'prepare', 'apply'], true)) exit(1);

$root = getenv('MEDUC_APP_ROOT') ?: dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
$db = Cake\Datasource\ConnectionManager::get('default');
$db->execute('SET SESSION lock_wait_timeout=10');
$db->execute('SET SESSION innodb_lock_wait_timeout=10');

$columns = $db->execute("SELECT COLUMN_NAME FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='voucher_grants' AND COLUMN_NAME IN ('discount_type','discount_value')")
    ->fetchAll('assoc');
$columns = array_column($columns, 'COLUMN_NAME');
if ($mode === 'prepare') {
    $add = [];
    if (!in_array('discount_type', $columns, true)) $add[] = 'ADD discount_type VARCHAR(8) CHARACTER SET ascii NULL';
    if (!in_array('discount_value', $columns, true)) $add[] = 'ADD discount_value BIGINT UNSIGNED NULL';
    if ($add) $db->execute('ALTER TABLE voucher_grants ' . implode(', ', $add));
    echo json_encode(['mode' => $mode, 'columns_added' => count($add)], JSON_THROW_ON_ERROR) . PHP_EOL;
    exit;
}

$zone = new DateTimeZone('Asia/Ho_Chi_Minh');
$spendFrom = (new DateTimeImmutable('2026-11-25', $zone))->getTimestamp();
$spendUntil = (new DateTimeImmutable('2027-01-01', $zone))->getTimestamp();
$endsAt = (new DateTimeImmutable('2027-02-01', $zone))->getTimestamp();

$online = [
    'study-week-1h' => [60, 20000, 10000],
    'study-week-3h' => [180, 50000, 20000],
    'study-week-5h' => [300, 100000, 30000],
];
$loyalty = [
    [500000, 500000, 20000, 10000],
    [1500000, 1000000, 50000, 20000],
    [3000000, 3000000, 100000, 100000],
];

$load = static function () use ($db, $online, $loyalty, $spendFrom, $spendUntil, $endsAt): array {
    $query = "SELECT id, kind, name, discount_value, required_spend FROM voucher_campaigns
        WHERE active=1 AND scope='knowledge' AND discount_type='fixed'";
    $steps = [];
    foreach ($online as $key => [$minutes, $oldAmount, $amount]) {
        $row = $db->execute($query . " AND kind='study' AND preset_key=? AND study_minutes=?", [$key, $minutes])
            ->fetch('assoc');
        if (!$row || !in_array((int)$row['discount_value'], [$oldAmount, $amount], true)) {
            throw new RuntimeException('Unexpected online tier ' . $key);
        }
        $steps[] = [$row, ['discount_value' => $amount]];
    }
    foreach ($loyalty as [$oldSpend, $spend, $oldAmount, $amount]) {
        $rows = $db->execute($query . " AND kind='loyalty' AND starts_at=? AND ends_at=?
            AND spend_from=? AND spend_until=? AND required_spend IN (?,?)",
            [$spendFrom, $endsAt, $spendFrom, $spendUntil, $oldSpend, $spend])->fetchAll('assoc');
        if (count($rows) !== 1 || !in_array((int)$rows[0]['discount_value'], [$oldAmount, $amount], true)) {
            throw new RuntimeException('Unexpected loyalty tier ' . $spend);
        }
        $target = ['discount_value' => $amount, 'required_spend' => $spend,
            'name' => 'Mốc chi tiêu ' . number_format($spend, 0, ',', '.') . 'đ'];
        $steps[] = [$rows[0], $target];
    }
    return $steps;
};

$preserved = 0;
$changed = 0;
if ($mode === 'apply') {
    if (count($columns) !== 2) throw new RuntimeException('Run prepare before apply.');
    [$preserved, $changed] = $db->transactional(static function () use ($db, $load): array {
        $steps = $load();
        $preserved = $changed = 0;
        // Checkout locks the grant before the campaign. Keep that order while updating the tiers.
        foreach ($steps as [$row]) {
            $preserved += $db->execute("UPDATE voucher_grants
                SET discount_type=COALESCE(discount_type,'fixed'), discount_value=COALESCE(discount_value,?)
                WHERE campaign_id=? AND (discount_type IS NULL OR discount_value IS NULL)",
                [$row['discount_value'], $row['id']])->rowCount();
        }
        foreach ($steps as [$row, $target]) {
            $current = array_intersect_key($row, $target);
            $current['discount_value'] = (int)$current['discount_value'];
            if (isset($current['required_spend'])) $current['required_spend'] = (int)$current['required_spend'];
            if ($current == $target) continue;
            $where = ['id' => $row['id'], 'active' => 1, 'scope' => 'knowledge', 'discount_type' => 'fixed'] + $current;
            if ($db->update('voucher_campaigns', $target, $where)->rowCount() !== 1) {
                throw new RuntimeException('Campaign changed during the update. Retry after checking the current configuration.');
            }
            $changed++;
        }
        return [$preserved, $changed];
    });
}

echo json_encode(['mode' => $mode, 'grant_columns' => $columns, 'grants_preserved' => $preserved,
    'campaigns_changed' => $changed, 'tiers' => $load()], JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR) . PHP_EOL;
