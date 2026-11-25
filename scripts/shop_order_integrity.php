<?php
declare(strict_types=1);

/** Prepare the shared receipts/affiliate ledgers. With no option, print a read-only plan. */
if (PHP_SAPI !== 'cli' || !in_array($argv[1] ?? 'plan', ['plan', 'apply'], true)) {
    exit(1);
}

$root = getenv('MEDUC_APP_ROOT') ?: dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
$db = Cake\Datasource\ConnectionManager::get('default');
$apply = ($argv[1] ?? '') === 'apply';
if ($apply) $db->execute('SET SESSION lock_wait_timeout=12');

$tables = [
    'customers' => [],
    'payments' => [],
    'orders_contact' => ['address'=>512, 'full_address'=>768],
    'shippings' => ['address'=>512, 'full_address'=>768],
];
$engines = [];
$addressLengths = [];
foreach ($tables as $table => $columns) {
    $engine = $db->execute('SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?', [$table])->fetchColumn(0);
    if (!in_array($engine, ['MyISAM', 'InnoDB'], true)) {
        throw new RuntimeException('Unexpected storage engine for ' . $table);
    }
    $engines[$table] = $engine;
    $changes = $engine === 'InnoDB' ? [] : ['ENGINE=InnoDB'];
    foreach ($columns as $column => $expected) {
        $current = (int)$db->execute('SELECT CHARACTER_MAXIMUM_LENGTH FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?', [$table, $column])->fetchColumn(0);
        if (!$current) throw new RuntimeException('Missing address field ' . $table . '.' . $column);
        if ($current < $expected) $changes[] = 'MODIFY ' . $column . ' VARCHAR(' . $expected . ') NULL DEFAULT NULL';
        $addressLengths[$table . '.' . $column] = $apply ? max($current, $expected) : $current;
    }
    if ($apply && $changes) {
        $db->execute('ALTER TABLE ' . $table . ' ' . implode(', ', $changes));
        $engines[$table] = 'InnoDB';
    }
}

$migration = 'shop-orders-affiliate-carryover';
$done = $db->execute('SELECT 1 FROM commerce_migrations WHERE name=?', [$migration])->fetchColumn(0);
$findPartners = function () use ($db): array {
    // The previous checkout accepted general customer codes. Carry over partners
    // with a recorded payout, an active account and a settled order of their own.
    return $db->execute(
        "SELECT c.id FROM customers c WHERE c.deleted=0 AND c.status=1 AND COALESCE(c.is_partner_affiliate,0)=0
         AND c.code IS NOT NULL AND c.code<>'' AND COALESCE(c.affiliate_amount,0)>COALESCE(c.affiliate_amount_unpaid,0)
         AND (EXISTS (
             SELECT 1 FROM orders o WHERE o.affiliateCode=c.code AND o.deleted=0 AND o.type='order'
               AND o.status<>'cancel' AND o.orderStatus='success' AND o.affiliatePaidStatus='paid' AND o.affiliateAmount>0
         ) OR EXISTS (
             SELECT 1 FROM contacts r JOIN contacts_form f ON f.id=r.form_id WHERE f.code=? AND r.deleted=0
               AND CASE WHEN JSON_VALID(r.value) THEN
                 JSON_UNQUOTE(JSON_EXTRACT(r.value,'$.affiliateCode'))=c.code
                 AND JSON_UNQUOTE(JSON_EXTRACT(r.value,'$.orderStatus'))='success'
                 AND JSON_UNQUOTE(JSON_EXTRACT(r.value,'$.affiliatePaidStatus'))='paid'
                 AND CAST(JSON_UNQUOTE(JSON_EXTRACT(r.value,'$.affiliateAmount')) AS DECIMAL(18,2))>0
               ELSE 0 END
         )) ORDER BY c.id",
        [App\Service\Vouchers::SHOP_FORM]
    )->fetchAll('assoc');
};

$candidates = $done ? [] : $findPartners();
$restored = 0;
if ($apply && !$done) {
    $restored = $db->transactional(function () use ($db, $migration, $findPartners): int {
        $started = $db->execute('INSERT IGNORE INTO commerce_migrations (name,created_at) VALUES (?,?)', [$migration,time()])->rowCount();
        if (!$started) return 0;
        $restored = 0;
        foreach ($findPartners() as $partner) {
            $restored += $db->execute(
                'UPDATE customers SET is_partner_affiliate=1 WHERE id=? AND deleted=0 AND status=1 AND COALESCE(is_partner_affiliate,0)=0',
                [$partner['id']]
            )->rowCount();
        }
        return $restored;
    });
}
echo json_encode([
    'mode' => $apply ? 'apply' : 'plan', 'engines' => $engines, 'address_lengths' => $addressLengths,
    'legacy_candidates' => count($candidates), 'legacy_restored' => $restored, 'carryover_previously_run' => (bool)$done,
], JSON_THROW_ON_ERROR) . PHP_EOL;
