<?php
/** Create the exam-prep child category used by the production course editor. */
declare(strict_types=1);

require '/home/kbbcutgf/public_html/config_database.php';

$db = new PDO(
    'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
    DB_USERNAME,
    DB_PASSWORD,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

const CATEGORY_ID = 125;
const CATEGORY_SLUG = 'trac-nghiem';
const CATEGORY_NAME = 'Khóa luyện thi';

$db->beginTransaction();
try {
    $parent = $db->query('SELECT id, type, deleted FROM categories WHERE id = 50 FOR UPDATE')->fetch(PDO::FETCH_ASSOC);
    if (!$parent || $parent['type'] !== 'product' || (int)$parent['deleted'] !== 0) {
        throw new RuntimeException('Parent course category 50 is missing or inactive.');
    }

    $existing = $db->query('SELECT id, type, parent_id, path_id, status, deleted FROM categories WHERE id = 125 FOR UPDATE')->fetch(PDO::FETCH_ASSOC);
    if ($existing && ($existing['type'] !== 'product' || (int)$existing['parent_id'] !== 50 || $existing['path_id'] !== '|50|' || (int)$existing['status'] !== 1 || (int)$existing['deleted'] !== 0)) {
        throw new RuntimeException('Category ID 125 is already used by another category.');
    }

    $slug = $db->prepare('SELECT foreign_id, type, lang, deleted FROM links WHERE url = ? FOR UPDATE');
    $slug->execute([CATEGORY_SLUG]);
    $slugRows = $slug->fetchAll(PDO::FETCH_ASSOC);
    foreach ($slugRows as $row) {
        if ((int)$row['foreign_id'] !== CATEGORY_ID || $row['type'] !== 'category_product' || $row['lang'] !== 'vi' || (int)$row['deleted'] !== 0) {
            throw new RuntimeException('The course category slug is already in use.');
        }
    }

    if (!$existing) {
        $now = time();
        $stmt = $db->prepare('INSERT INTO categories (id, type, parent_id, path_id, created, updated, position, status, deleted) VALUES (125, ?, 50, ?, ?, ?, 125, 1, 0)');
        $stmt->execute(['product', '|50|', $now, $now]);
    }

    $content = $db->prepare('SELECT id, name FROM categories_content WHERE category_id = 125 AND lang = ? FOR UPDATE');
    $content->execute(['vi']);
    $row = $content->fetch(PDO::FETCH_ASSOC);
    if ($row && $row['name'] !== CATEGORY_NAME) {
        throw new RuntimeException('Category 125 already has different Vietnamese content.');
    }
    if (!$row) {
        $stmt = $db->prepare('INSERT INTO categories_content (category_id, name, search_unicode, seo_title, lang) VALUES (125, ?, ?, ?, ?)');
        $stmt->execute([CATEGORY_NAME, 'khoa luyen thi', CATEGORY_NAME, 'vi']);
    }

    if (!$slugRows) {
        $now = time();
        $stmt = $db->prepare('INSERT INTO links (foreign_id, type, url, lang, created, updated, deleted) VALUES (125, ?, ?, ?, ?, ?, 0)');
        $stmt->execute(['category_product', CATEGORY_SLUG, 'vi', $now, $now]);
    }

    $db->commit();
    echo "Category 125: Khóa học > Khóa luyện thi (trac-nghiem)\n";
} catch (Throwable $e) {
    $db->rollBack();
    fwrite(STDERR, $e->getMessage() . "\n");
    exit(1);
}
