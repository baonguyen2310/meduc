<?php
/** Civo integration fixtures only. Roll back all palette rows; never configure an email transport. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli' || !in_array('--fixtures', $argv, true)) exit(1);
$root = dirname(__DIR__);
foreach ($argv as $arg) if (strpos($arg, '--root=') === 0) $root = substr($arg, 7);
$_SERVER['HTTP_HOST']='meducv3.duckdns.org'; $_SERVER['SERVER_NAME']=$_SERVER['HTTP_HOST']; $_SERVER['HTTPS']='on';
$_SERVER['DOCUMENT_ROOT']=$root; $_SERVER['SCRIPT_FILENAME']=$root.'/index.php'; chdir($root);
require 'config.php'; require 'config_database.php'; require 'coredaca/config/requirements.php';
if (!defined('SOURCE_DOMAIN')) define('SOURCE_DOMAIN', $root);
require 'coredaca/vendor/autoload.php'; (new \App\Application($root.'/coredaca/config'))->bootstrap();

use App\Service\ThemeUsage as Theme;
function expectTheme($condition, $message) { if (!$condition) throw new RuntimeException($message); }
$db = Theme::db();
$customer = random_int(1900000000, 2000000000);
expectTheme(!$db->execute('SELECT customer_id FROM theme_usage_customers WHERE customer_id=:id', ['id'=>$customer])->fetch(), 'Fixture ID collision.');
$browser = hash('sha256', random_bytes(32)); $other = hash('sha256', random_bytes(32));
$key = function () { return bin2hex(random_bytes(16)); };
$count = function () use ($db, $browser) { return (int)$db->execute('SELECT COUNT(*) FROM theme_usage_events WHERE browser_key=:browser', ['browser'=>$browser])->fetchColumn(0); };
$db->begin();
try {
    expectTheme(Theme::initial($customer)['theme'] === 'light', 'Unknown account starts light.');
    expectTheme(Theme::record($browser, 'dark', $customer, 'sync')['theme'] === 'light', 'Initial account sync must not import dark from local storage.');
    Theme::record($browser, 'dark', $customer, 'change', $first = $key());
    expectTheme(Theme::initial($customer)['theme'] === 'dark', 'Explicit changes persist on the backend.');
    expectTheme(Theme::record($other, 'light', $customer, 'sync')['theme'] === 'dark', 'Another device follows the account.');
    $before = $count();
    Theme::record($browser, 'dark', $customer, 'sync'); Theme::record($browser, 'dark', $customer, 'sync');
    expectTheme($count() === $before, 'Repeat page views are not switches.');
    Theme::record($browser, 'light', $customer, 'change', $key());
    $before = $count();
    expectTheme(Theme::record($browser, 'dark', $customer, 'change', $first)['theme'] === 'light', 'An old retry cannot undo a later preference.');
    expectTheme($count() === $before, 'Retries must not duplicate history.');
    $db->execute("UPDATE theme_usage_customers SET theme='dark', preference_version=0 WHERE customer_id=:id", ['id'=>$customer]);
    $db->execute("UPDATE theme_usage_browsers SET theme='dark', preference_version=0 WHERE browser_key=:browser", ['browser'=>$browser]);
    expectTheme(Theme::initial($customer)['theme'] === 'light', 'Pre-rollout backend snapshots do not override the reset.');
    Theme::record($browser, 'light', $customer, 'sync', null, 'dark');
    $event = $db->execute('SELECT * FROM theme_usage_events WHERE browser_key=:browser ORDER BY id DESC LIMIT 1', ['browser'=>$browser])->fetch('assoc');
    expectTheme($event['reason'] === 'reset' && $event['previous_theme'] === 'dark' && $event['theme'] === 'light', 'Retain the reset in history.');
    Theme::record($browser, 'dark', $customer, 'change', $key());
    Theme::record($browser, 'light', $customer, 'sync');
    expectTheme(Theme::initial($customer)['theme'] === 'dark', 'Sync never repeats the reset or saves a stale browser over the account.');
    Theme::record($other, 'light', $customer, 'sync');
    $event = $db->execute('SELECT * FROM theme_usage_events WHERE browser_key=:browser ORDER BY id DESC LIMIT 1', ['browser'=>$other])->fetch('assoc');
    expectTheme($event['customer_id'] == $customer, 'History ties each browser transition to the authenticated account.');
    $guest = hash('sha256', random_bytes(32));
    Theme::record($guest, 'light', 0, 'sync', null, 'dark');
    Theme::record($guest, 'dark', 0, 'change', $key());
    expectTheme(Theme::record($guest, 'dark', 0, 'sync')['theme'] === 'dark', 'Guests retain their post-reset browser choice.');
    Theme::summary();

    // Exercise the actual admin SQL, filters and pagination on each view, not only the template.
    foreach (['history', 'users', 'browsers'] as $view) {
        $request = new \Cake\Http\ServerRequest(['query'=>['view'=>$view, 'customer'=>$customer, 'theme'=>'dark']]);
        $controller = new \Admin\Controller\ThemeUsageController($request);
        $controller->index();
        $listed = $controller->viewBuilder()->getVars();
        expectTheme($listed['view'] === $view && $listed['total'] > 0, 'Admin filters return the fixture in ' . $view);
        foreach ($listed['rows'] as $listedRow) expectTheme((int)$listedRow['customer_id'] === $customer && $listedRow['theme'] === 'dark', 'Admin filters must not mix accounts or themes.');
    }

    $compile = sys_get_temp_dir().'/meduc-theme-'.bin2hex(random_bytes(8)); mkdir($compile,0700);
    try {
        $smarty = new Smarty(); $smarty->setCompileDir($compile);
        $smarty->assign('this', new class { public function element($name) { return '<p>Summary fixture</p>'; } });
        $reasons = ['change'=>'Người dùng đổi', 'reset'=>'Đặt lại mặc định sáng', 'initial'=>'Ghi nhận lần đầu', 'account_sync'=>'Đồng bộ từ tài khoản', 'browser_sync'=>'Đồng bộ trình duyệt'];
        $row = $event + ['full_name'=>'Fixture <script>bad</script>', 'customer_code'=>'FIXTURE', 'email'=>'fixture@example.invalid', 'browser_label'=>substr($other,0,12), 'current'=>true, 'last_seen'=>time()];
        foreach (['history','users','browsers'] as $view) {
            foreach (['view'=>$view, 'theme'=>'all', 'reason'=>'all', 'reasons'=>$reasons, 'q'=>'', 'customer'=>0, 'browser'=>'', 'rows'=>[$row], 'total'=>1, 'page'=>1, 'pages'=>1, 'previous_url'=>'', 'next_url'=>''] as $name=>$value) $smarty->assign($name,$value);
            $html = $smarty->fetch($root.'/coredaca/plugins/Admin/templates/ThemeUsage/index.tpl');
            expectTheme(strpos($html, 'Lựa chọn và lịch sử giao diện') !== false && strpos($html, '<script>bad</script>') === false, 'Admin views render and escape account details.');
        }
    } finally { foreach (glob($compile.'/*') ?: [] as $file) unlink($file); rmdir($compile); }
    echo "PASS: backend precedence, cross-device sync, one-time reset, history attribution, retry idempotency, guest persistence, admin templates. All fixture writes rolled back; no emails.\n";
} finally { $db->rollback(); }
