<?php
/** Additive migration. Preserve prior observations; reset preferences on the next visit. */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
if (!in_array('--apply', $argv, true)) { fwrite(STDERR, "Use --apply.\n"); exit(1); }
$root = dirname(__DIR__);
foreach ($argv as $arg) if (strpos($arg, '--root=') === 0) $root = substr($arg, 7);
$_SERVER['HTTP_HOST']='meducv3.duckdns.org'; $_SERVER['SERVER_NAME']=$_SERVER['HTTP_HOST']; $_SERVER['HTTPS']='on';
$_SERVER['DOCUMENT_ROOT']=$root; $_SERVER['SCRIPT_FILENAME']=$root.'/index.php'; chdir($root);
require 'config.php'; require 'config_database.php'; require 'coredaca/config/requirements.php';
if (!defined('SOURCE_DOMAIN')) define('SOURCE_DOMAIN',$root);
require 'coredaca/vendor/autoload.php'; $app=new \App\Application($root.'/coredaca/config'); $app->bootstrap();
$db=\Cake\Datasource\ConnectionManager::get('default');
$db->execute("CREATE TABLE IF NOT EXISTS theme_usage_browsers (
 browser_key CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL PRIMARY KEY,
 theme VARCHAR(5) CHARACTER SET ascii NOT NULL, identified TINYINT UNSIGNED NOT NULL DEFAULT 0,
 first_seen BIGINT UNSIGNED NOT NULL, last_seen BIGINT UNSIGNED NOT NULL,
 KEY idx_theme_guest(identified,theme)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
$db->execute("CREATE TABLE IF NOT EXISTS theme_usage_customers (
 customer_id INT NOT NULL PRIMARY KEY, theme VARCHAR(5) CHARACTER SET ascii NOT NULL,
 first_seen BIGINT UNSIGNED NOT NULL, last_seen BIGINT UNSIGNED NOT NULL,
 KEY idx_theme_customer(theme)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
foreach (['theme_usage_browsers', 'theme_usage_customers'] as $table) {
    if (!$db->execute("SHOW COLUMNS FROM {$table} LIKE 'preference_version'")->fetch()) {
        $db->execute("ALTER TABLE {$table} ADD preference_version INT UNSIGNED NOT NULL DEFAULT 0");
    }
}
if (!$db->execute("SHOW COLUMNS FROM theme_usage_browsers LIKE 'customer_id'")->fetch()) {
    $db->execute('ALTER TABLE theme_usage_browsers ADD customer_id INT UNSIGNED NOT NULL DEFAULT 0, ADD KEY idx_theme_browser_customer(customer_id)');
}
$db->execute("CREATE TABLE IF NOT EXISTS theme_usage_events (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 browser_key CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 customer_id INT UNSIGNED NOT NULL DEFAULT 0,
 previous_theme VARCHAR(5) CHARACTER SET ascii NULL, customer_previous_theme VARCHAR(5) CHARACTER SET ascii NULL,
 theme VARCHAR(5) CHARACTER SET ascii NOT NULL, reason VARCHAR(20) CHARACTER SET ascii NOT NULL,
 preference_version INT UNSIGNED NOT NULL,
 event_key CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL, created BIGINT UNSIGNED NOT NULL,
 UNIQUE KEY idx_theme_event_retry(browser_key,event_key),
 KEY idx_theme_event_customer(customer_id,id), KEY idx_theme_event_browser(browser_key,id), KEY idx_theme_event_reason(reason,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
echo "Theme preferences and transition history ready.\n";
