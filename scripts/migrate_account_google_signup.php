<?php
/** CLI only. Add verification state and allow full email usernames; existing accounts are preserved. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
require dirname(__DIR__) . '/config_database.php';
$db = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4', DB_USERNAME, DB_PASSWORD,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
$apply = ($argv[1] ?? 'plan') === 'apply';
$steps = [];
if (!$db->query("SHOW COLUMNS FROM customers LIKE 'email_verified'")->fetch()) {
    $steps[] = 'ALTER TABLE customers ADD COLUMN email_verified TINYINT(1) NOT NULL DEFAULT 0';
}
$username = $db->query("SHOW COLUMNS FROM customers_account LIKE 'username'")->fetch();
if (!$username || !preg_match('/varchar\((\d+)\)/i', $username['Type'], $match)) throw new RuntimeException('Unexpected username schema.');
if ((int)$match[1] < 255) $steps[] = 'ALTER TABLE customers_account MODIFY username VARCHAR(255) NOT NULL';
if ($apply) foreach ($steps as $sql) $db->exec($sql);
echo json_encode(['applied' => $apply, 'schema_changes' => $steps], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n";
