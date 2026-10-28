<?php
/** Install once, using PHP CLI: php scripts/theme_usage.php --apply */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
if (!in_array('--apply', $argv, true)) { fwrite(STDERR,"Use --apply to install palette statistics.\n"); exit(1); }
$root=dirname(__DIR__);
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
echo "Theme usage tables ready.\n";
