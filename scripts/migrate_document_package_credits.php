<?php
declare(strict_types=1);

use Cake\Datasource\ConnectionManager;

if (PHP_SAPI !== 'cli') {
    exit(1);
}

$apply = in_array('--apply', $argv, true);
$root = getenv('MEDUC_APP_ROOT') ?: dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
$db = ConnectionManager::get('default');

$changes = $db->transactional(static function () use ($db, $apply): array {
    $previous = [1, 3, 5];
    $target = [3, 6, 10];
    $lock = $apply ? ' FOR UPDATE' : '';
    $lists = $db->execute(
        "SELECT id FROM course_price_lists WHERE slug=? AND course_type='document' AND status=1" . $lock,
        ['luot-tai-tai-lieu']
    )->fetchAll('assoc');
    if (count($lists) !== 1) {
        throw new RuntimeException('Cần đúng một bảng giá lượt tải đang hoạt động.');
    }

    $packages = $db->execute(
        'SELECT id, name, credit_count FROM course_price_packages WHERE price_list_id=? AND status=1 ORDER BY position,id' . $lock,
        [$lists[0]['id']]
    )->fetchAll('assoc');
    $counts = array_map('intval', array_column($packages, 'credit_count'));
    if ($counts !== $previous && $counts !== $target) {
        throw new RuntimeException('Số lượt của các gói đã thay đổi. Cần đối chiếu bảng giá trước khi cập nhật.');
    }

    $changes = [];
    foreach ($packages as $index => $package) {
        $id = (int)$package['id'];
        $credits = $target[$index];
        $name = $package['name'] === $previous[$index] . ' lượt tải' ? $credits . ' lượt tải' : $package['name'];
        $changes[] = ['id' => $id, 'before' => $counts[$index], 'after' => $credits];
        if ($apply && ($credits !== $counts[$index] || $name !== $package['name'])) {
            $db->update('course_price_packages', ['credit_count' => $credits, 'name' => $name, 'updated' => time()], ['id' => $id]);
        }
    }
    return $changes;
});

echo json_encode(['applied' => $apply, 'packages' => $changes], JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR) . PHP_EOL;
