<?php
declare(strict_types=1);

/** Install the purchase gift ledger. Plan mode reads schema without changing it. */
if (PHP_SAPI !== 'cli' || !in_array($argv[1] ?? 'plan', ['plan', 'apply'], true)) exit(1);

$root = getenv('MEDUC_APP_ROOT') ?: dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
$db = App\Service\CommercePurchases::db();

$check = static function () use ($db): array {
    $tables = $db->execute(
        "SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES
         WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('customers','commerce_purchases','document_credit_uses','purchase_gifts','purchase_gift_products')"
    )->fetchAll('assoc');
    $engines = array_column($tables, 'ENGINE', 'TABLE_NAME');
    foreach (['customers', 'commerce_purchases', 'document_credit_uses'] as $table) {
        if (($engines[$table] ?? '') !== 'InnoDB') throw new RuntimeException($table . ' must be transactional.');
    }
    if (isset($engines['purchase_gifts']) && $engines['purchase_gifts'] !== 'InnoDB') {
        throw new RuntimeException('The existing gift ledger must be transactional.');
    }
    $fields = $db->execute(
        "SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
         AND TABLE_NAME='document_credit_uses' AND COLUMN_NAME IN ('gift_id','subject_key')"
    )->fetchAll('assoc');
    $index = $db->execute(
        "SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE()
         AND TABLE_NAME='document_credit_uses' AND INDEX_NAME='idx_credit_gift'"
    )->fetchColumn(0);
    return [
        'gift_ledger' => isset($engines['purchase_gifts']),
        'shop_mapping' => ($engines['purchase_gift_products'] ?? '') === 'InnoDB',
        'ticket_columns' => array_column($fields, 'COLUMN_NAME'),
        'ticket_index' => (bool)$index,
    ];
};

$apply = ($argv[1] ?? 'plan') === 'apply';
$state = $check();
$seeded = 0;
if ($apply) {
    $db->execute('SET SESSION lock_wait_timeout=10');
    $add = [];
    if (!in_array('gift_id', $state['ticket_columns'], true)) $add[] = 'ADD gift_id BIGINT UNSIGNED NULL';
    if (!in_array('subject_key', $state['ticket_columns'], true)) $add[] = 'ADD subject_key VARCHAR(191) NULL';
    if (!$state['ticket_index']) $add[] = 'ADD INDEX idx_credit_gift (gift_id,used_at)';
    if ($add) $db->execute('ALTER TABLE document_credit_uses ' . implode(', ', $add));
    $db->execute("CREATE TABLE IF NOT EXISTS purchase_gifts (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL,
        customer_id INT NOT NULL,
        course_product_id INT NOT NULL DEFAULT 0,
        subject_key VARCHAR(191) NULL,
        subject_name VARCHAR(255) NULL,
        download_credits SMALLINT UNSIGNED NOT NULL,
        quiz_months SMALLINT UNSIGNED NOT NULL,
        granted_at BIGINT UNSIGNED NOT NULL,
        quiz_product_id INT NULL,
        quiz_started_at BIGINT UNSIGNED NULL,
        UNIQUE KEY uq_order_gift_subject (order_id,course_product_id),
        KEY idx_purchase_gifts_customer (customer_id,course_product_id,subject_key)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    $db->execute("CREATE TABLE IF NOT EXISTS purchase_gift_products (
        product_id INT NOT NULL PRIMARY KEY,
        quiz_product_id INT NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    // Seed books with an explicit related subject. The admin owns the mapping after installation.
    $seeded = $db->transactional(static function () use ($db): int {
        $started = $db->execute('INSERT IGNORE INTO commerce_migrations (name,created_at) VALUES (?,?)',
            ['shop-purchase-gift-subjects-v1', time()])->rowCount();
        if (!$started) return 0;
        $booksByQuiz = [
            'tieng-anh-chuyen-nganh' => [
                'tieng-anh-y-khoa-song-ngu-in-den-trang-3-tap-khoa-hoc-theo-sach',
                'tieng-anh-y-khoa-song-ngu-in-full-mau-3-tap-khoa-hoc-theo-sach-tai-lieu-mien-phi',
                'the-language-of-medicine-2-tap-ban-tieng-anh-in-full-mau-khoa-hoc-theo-sach',
                'the-language-of-medicine-2-tap-ban-tieng-anh-in-den-trang-khoa-hoc-xay-dung-nen-tang',
            ],
            'giai-phau-hoc' => [
                'ca-giai-phau-ban-song-ngu-in-den-trang-khoa-hoc-theo-sach',
                'ca-lam-sang-giai-phau-in-den-trang-khoa-hoc-theo-sach',
                'giai-phau-cat-lop-ct-mri-3-tap-in-full-mau',
            ],
            'sinh-ly-hoc' => [
                'atlas-sinh-ly-hoc-netter-ban-tieng-viet-in-full-mau-khoa-hoc-theo-sach',
                'bo-sach-sinh-ly-guyton-2-tap-ban-tieng-viet-in-den-trang-khoa-hoc-theo-sach',
                'bo-sach-sinh-ly-guyton-2-tap-ban-tieng-viet-full-mau-khoa-hoc-xay-dung-nen-tang',
                'combo-sach-sinh-ly-guyton-2-tap-tieng-viet-full-mau-sach-trac-nghiem-tang-khoa-hoc-xay-dung-nen-tang',
                'trac-nghiem-sinh-ly-guyton-ban-tieng-viet-in-den-trang-bo-trac-nghiem-khoa-hoc-theo-sach',
                'ca-lam-sang-sinh-ly-in-den-trang-khoa-hoc-theo-sach',
            ],
            'noi-khoa' => [
                'cam-nang-chan-doan-va-dieu-tri-benh-noi-khoa-in-full-mau-khoa-hoc-theo-sach',
                'ca-lam-sang-noi-khoa-ban-tieng-viet-in-full-mau-khoa-hoc-theo-sach',
                'ca-lam-sang-noi-khoa-ban-tieng-viet-in-den-trang-khoa-hoc-theo-sach',
                'tiep-can-lam-sang-theo-nguyen-ly-noi-khoa-harrisons-a5-in-mau-khoa-hoc-theo-sach',
            ],
            'nhi-khoa' => [
                'tiep-can-chan-doan-va-dieu-tri-nhi-khoa-nxb-khoa-hoc-theo-sach',
                'thuc-hanh-cap-cuu-nhi-khoa-2023-nxb-khoa-hoc-theo-sach',
                'ca-lam-sang-nhi-khoa-cap-cuu-ban-tieng-viet-in-full-mau-khoa-hoc-theo-sach',
            ],
            'san-phu-khoa' => ['sieu-am-trong-san-khoa-va-phu-khoa-in-full-mau-khoa-hoc-theo-sach'],
            'hoa-sinh' => ['hoa-sinh-y-hoc-nxb-khoa-hoc-theo-sach'],
            'huyet-hoc' => ['ky-thuat-xet-nghiem-huyet-hoc-va-truyen-mau-ung-dung-trong-lam-sang-nxb'],
            'rang-ham-mat' => ['chinh-hinh-rang-mat-co-ban-nxb'],
            'he-tim-mach' => [
                'the-ecg-made-easy-in-full-mau-a5-khoa-hoc-theo-sach',
                'ecg-cho-nguoi-moi-bat-dau-in-mau-a5-khoa-hoc-theo-sach',
                'bai-tap-dien-tam-do-in-full-mau-khoa-hoc-theo-sach',
                'the-ecg-in-practice-in-full-mau-a5-khoa-hoc-theo-sach',
                'the-ecg-problem-a5-in-mau-khoa-hoc-theo-sach',
                'atlas-sieu-am-tim-trong-hoi-suc-in-full-mau-khoa-hoc-theo-sach',
            ],
            'he-than-kinh' => ['huong-dan-doc-ct-so-cat-lop-so-nao-phan-1-phan-2-in-mau'],
            'he-da-co-xuong-khop' => ['thuc-hanh-sieu-am-co-xuong-khop-co-ban-in-full-mau'],
        ];
        $changed = 0;
        foreach ($booksByQuiz as $quizSlug => $books) {
            $quiz = $db->execute("SELECT DISTINCT p.id FROM products p JOIN links l ON l.foreign_id=p.id
                WHERE p.course_kind='quiz' AND p.deleted=0 AND l.type='product_detail' AND l.lang='vi' AND l.deleted=0 AND l.url=?",
                ['trac-nghiem-' . $quizSlug . '-v1'])->fetchAll('assoc');
            if (count($quiz) !== 1) continue;
            $placeholders = implode(',', array_fill(0, count($books), '?'));
            $changed += $db->execute(
                "INSERT IGNORE INTO purchase_gift_products (product_id,quiz_product_id)
                 SELECT DISTINCT p.id,? FROM products p JOIN links l ON l.foreign_id=p.id
                 JOIN categories_product cp ON cp.product_id=p.id JOIN categories c ON c.id=cp.category_id
                 WHERE p.deleted=0 AND COALESCE(p.course_kind,'')='' AND (c.id=79 OR c.path_id LIKE '%|79|%')
                 AND l.type='product_detail' AND l.lang='vi' AND l.deleted=0 AND l.url IN ($placeholders)",
                array_merge([(int)$quiz[0]['id']], $books)
            )->rowCount();
        }
        return $changed;
    });
    $state = $check();
}
echo json_encode(['mode'=>$apply ? 'apply' : 'plan', 'shop_products_seeded'=>$seeded] + $state, JSON_THROW_ON_ERROR) . PHP_EOL;
