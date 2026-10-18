<?php
/** Seed editable study-year categories for the 108 curriculum-v2 exam courses.
 * CLI: php scripts/production_exam_prep_study_years.php [--apply --backup-dir=/private/path]
 * Re-running only adds missing categories/memberships; it never removes admin assignments.
 */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__) . '/config_database.php';
$db = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4', DB_USERNAME, DB_PASSWORD,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
$apply = in_array('--apply', $argv, true);
$backupDir = null;
foreach ($argv as $arg) if (strpos($arg, '--backup-dir=') === 0) $backupDir = substr($arg, 13);
$mapping = json_decode(file_get_contents(__DIR__ . '/exam_prep_study_years.json'), true, 512, JSON_THROW_ON_ERROR)['subjects'];
$courses = $db->query('SELECT cv.subject_code, cv.product_id, p.main_category_id, p.deleted FROM curriculum_v2_courses cv JOIN products p ON p.id=cv.product_id')->fetchAll();
$byCode = array_column($courses, null, 'subject_code');
if (count($mapping) !== 108 || count($byCode) !== 108) throw new RuntimeException('Expected exactly 108 curriculum-v2 courses.');
$counts = array_fill(1, 6, 0);
foreach ($mapping as $row) {
    $course = $byCode[$row['code']] ?? null;
    if (!$course || (int)$course['main_category_id'] !== 125 || (int)$course['deleted'] !== 0 || !$row['years']) throw new RuntimeException('Invalid course mapping: ' . $row['code']);
    foreach ($row['years'] as $year) {
        if (!is_int($year) || $year < 1 || $year > 6) throw new RuntimeException('Invalid study year.');
        $counts[$year]++;
    }
}
if (!$apply) { echo json_encode(['dry_run'=>true, 'courses'=>count($mapping), 'year_memberships'=>$counts], JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT) . "\n"; exit; }
if (!$backupDir || !is_dir($backupDir) || !is_writable($backupDir) || strpos(realpath($backupDir) . '/', realpath(dirname(__DIR__)) . '/') === 0) throw new RuntimeException('A writable backup directory outside the web root is required.');
$ids = implode(',', array_map('intval', array_column($courses, 'product_id')));
$backup = ['created_at'=>gmdate('c'), 'categories'=>$db->query('SELECT * FROM categories')->fetchAll(),
    'categories_content'=>$db->query('SELECT * FROM categories_content')->fetchAll(),
    'category_links'=>$db->query("SELECT * FROM links WHERE type='category_product'")->fetchAll(),
    'categories_product'=>$db->query("SELECT * FROM categories_product WHERE product_id IN ($ids)")->fetchAll()];
$backupPath = rtrim($backupDir,'/') . '/exam-prep-years-before-' . gmdate('Ymd-His') . '-' . bin2hex(random_bytes(3)) . '.json.gz';
if (file_put_contents($backupPath, gzencode(json_encode($backup, JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR), 6), LOCK_EX) === false) throw new RuntimeException('Backup failed.');
chmod($backupPath, 0600);
$db->beginTransaction();
try {
    $parent = $db->query('SELECT * FROM categories WHERE id=125 FOR UPDATE')->fetch();
    if (!$parent || $parent['type'] !== 'product' || (int)$parent['parent_id'] !== 50 || (int)$parent['deleted'] !== 0) throw new RuntimeException('Exam-prep parent category is invalid.');
    $yearIds = [];
    $newMemberships = 0;
    $now = time();
    for ($year=1; $year<=6; $year++) {
        $slug = 'luyen-thi-sinh-vien-nam-' . $year;
        $name = 'Sinh viên năm ' . $year;
        $q = $db->prepare('SELECT l.*,c.parent_id,c.type AS category_type,c.deleted AS category_deleted FROM links l LEFT JOIN categories c ON c.id=l.foreign_id WHERE l.url=? AND l.deleted=0 FOR UPDATE');
        $q->execute([$slug]);
        $links = $q->fetchAll();
        if ($links) {
            if (count($links)!==1 || $links[0]['type']!=='category_product' || $links[0]['lang']!=='vi' || (int)$links[0]['parent_id']!==125 || (int)$links[0]['category_deleted']!==0 || $links[0]['category_type']!=='product') throw new RuntimeException('Study-year slug collision: ' . $slug);
            $categoryId = (int)$links[0]['foreign_id'];
        } else {
            $q=$db->prepare("INSERT INTO categories(type,parent_id,path_id,created,updated,position,status,draft,deleted) VALUES ('product',125,'|50|125|',?,?,?,1,0,0)");
            $q->execute([$now,$now,$year]);
            $categoryId=(int)$db->lastInsertId();
            $q=$db->prepare("INSERT INTO categories_content(category_id,name,search_unicode,description,seo_title,lang) VALUES (?,?,?,?,?,'vi')");
            $q->execute([$categoryId,$name,'sinh vien nam '.$year,'Các môn luyện thi dành cho sinh viên năm '.$year.'. Một môn có thể thuộc nhiều năm tùy chương trình của trường.','Luyện thi · '.$name.' | MedUC']);
            $q=$db->prepare("INSERT INTO links(foreign_id,type,url,lang,created,updated,deleted) VALUES (?,'category_product',?,'vi',?,?,0)");
            $q->execute([$categoryId,$slug,$now,$now]);
        }
        $yearIds[$year]=$categoryId;
    }
    $exists=$db->prepare('SELECT 1 FROM categories_product WHERE product_id=? AND category_id=? LIMIT 1');
    $insert=$db->prepare('INSERT INTO categories_product(product_id,category_id) VALUES (?,?)');
    foreach ($mapping as $row) {
        $pid=(int)$byCode[$row['code']]['product_id'];
        foreach ($row['years'] as $year) {
            $cid=$yearIds[$year];
            $exists->execute([$pid,$cid]);
            if (!$exists->fetchColumn()) { $insert->execute([$pid,$cid]); $newMemberships++; }
        }
    }
    $db->commit();
    echo json_encode(['categories'=>$yearIds,'courses'=>count($mapping),'year_memberships'=>$counts,'memberships_added'=>$newMemberships,'backup'=>$backupPath],JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT)."\n";
} catch (Throwable $e) { $db->rollBack(); throw $e; }
