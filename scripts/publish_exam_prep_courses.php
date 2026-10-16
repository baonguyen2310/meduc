<?php
/** Publish the 88 exam-prep courses (Khóa học > Khóa luyện thi) made by scripts/import_private_exams.php.
 *
 * Each course becomes one chapter "Tổng ôn" with one lesson "Bài tổng ôn" holding all of the course's exams as a quiz
 * list (quizzes_vi, App\Lib\LessonQuizzes), in the order they were imported. The first exam is free to try; the others
 * are for students of the course. The course, its exams and its price row become public (staff_only = 0, status = 1),
 * and its address changes from khoa-luyen-thi-noi-bo-<id> to luyen-thi-<name>.
 * Courses whose lessons already have this shape keep their lessons (and the free flags the admin set); they are only
 * published again if needed. The exams stay out of the exam lists (/danh-sach-de-thi): only their private flag changes.
 *
 * CLI only. Without "apply" it only reports what it would change.
 *   php scripts/publish_exam_prep_courses.php                 report
 *   php scripts/publish_exam_prep_courses.php apply           back up the rows it changes, then change them
 * Options: --config=<config_database.php> (default /home/kbbcutgf/public_html/config_database.php),
 *          --backup-dir=<folder outside the web root> (default /home/kbbcutgf/meduc-import-backups).
 * To go back: the backup is one JSON object per line ({"table", "row"}) of every changed row before the change.
 */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);

$options = ['config' => '/home/kbbcutgf/public_html/config_database.php', 'backup-dir' => '/home/kbbcutgf/meduc-import-backups'];
$apply = false;
foreach (array_slice($argv, 1) as $arg) {
    if ($arg === 'apply') $apply = true;
    elseif (preg_match('/^--(config|backup-dir)=(.+)$/', $arg, $m)) $options[$m[1]] = $m[2];
    else { fwrite(STDERR, "Usage: php publish_exam_prep_courses.php [apply] [--config=…] [--backup-dir=…]\n"); exit(1); }
}

require $options['config'];
$db = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4', DB_USERNAME, DB_PASSWORD, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
function sql(string $query, array $values = []) { global $db; $s = $db->prepare($query); $s->execute($values); return $s; }
function encoded($value): string { return json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR); }

/** "Hóa sinh & Miễn dịch (Y Dược Huế)" → "hoa-sinh-mien-dich-y-duoc-hue" */
function slug(string $text): string
{
    $map = ['àáạảãâầấậẩẫăằắặẳẵ' => 'a', 'èéẹẻẽêềếệểễ' => 'e', 'ìíịỉĩ' => 'i', 'òóọỏõôồốộổỗơờớợởỡ' => 'o', 'ùúụủũưừứựửữ' => 'u', 'ỳýỵỷỹ' => 'y', 'đ' => 'd'];
    $text = mb_strtolower($text, 'UTF-8');
    foreach ($map as $letters => $plain) $text = preg_replace('/[' . $letters . ']/u', $plain, $text);
    $text = preg_replace('/[^a-z0-9]+/', '-', $text);
    return trim(substr($text, 0, 120), '-');
}

/** Quiz ids of a course's lessons, in order (one per lesson after the import; a quiz list once restructured). */
function quizIds(array $lessons): array
{
    $ids = [];
    foreach ($lessons as $lesson) {
        if (!is_array($lesson) || ($lesson['chapter_vi'] ?? null) === 'y') continue;
        $list = $lesson['quizzes_vi'] ?? null;
        if (is_string($list) && trim($list) !== '') $list = json_decode($list, true);
        if (is_array($list)) { foreach ($list as $entry) $ids[] = (int)(is_array($entry) ? ($entry['id'] ?? 0) : $entry); }
        else $ids[] = (int)trim((string)($lesson['quiz_id_vi'] ?? ''));
    }
    return array_values(array_unique(array_filter($ids)));
}

function restructured(array $lessons): bool
{
    return count($lessons) === 2 && ($lessons[0]['chapter_vi'] ?? null) === 'y' && !empty($lessons[1]['quizzes_vi']);
}

$courses = sql(
    "SELECT e.product_id, e.staff_only, p.status, p.draft, pc.name, pa.id AS lessons_id, pa.value AS lessons,
            l.id AS link_id, l.url
     FROM exam_prep_courses e
     JOIN products p ON p.id = e.product_id AND p.deleted = 0
     LEFT JOIN products_content pc ON pc.product_id = p.id AND pc.lang = 'vi'
     LEFT JOIN products_attribute pa ON pa.product_id = p.id AND pa.attribute_id = 11
     LEFT JOIN links l ON l.foreign_id = p.id AND l.type = 'product_detail' AND l.lang = 'vi' AND l.deleted = 0
     ORDER BY p.position, p.id"
)->fetchAll(PDO::FETCH_ASSOC);
if (!$courses) { fwrite(STDERR, "No exam-prep courses found.\n"); exit(1); }

$plan = [];
$used_urls = [];
foreach ($courses as $course) {
    $lessons = json_decode((string)$course['lessons'], true);
    if (!is_array($lessons)) $lessons = [];
    $ids = quizIds($lessons);
    $new_lessons = null;
    if (!restructured($lessons) && $ids) {
        $new_lessons = [
            ['code' => 'tong_on', 'name_vi' => 'Tổng ôn', 'chapter_vi' => 'y', 'trial_vi' => 'n', 'review_vi' => 'n', 'quiz_id_vi' => '', 'youtube_id_vi' => '', 'description_vi' => '', 'files' => '', 'filestwo' => ''],
            ['code' => 'bai_tong_on', 'name_vi' => 'Bài tổng ôn', 'chapter_vi' => 'n', 'trial_vi' => 'n', 'review_vi' => 'y', 'quiz_id_vi' => (string)$ids[0],
             'quizzes_vi' => encoded(array_map(function ($id, $index) { return ['id' => $id, 'free' => $index === 0 ? 'y' : 'n']; }, $ids, array_keys($ids))),
             'youtube_id_vi' => '', 'description_vi' => '', 'files' => '', 'filestwo' => '']
        ];
    }

    $url = null;
    if (!empty($course['link_id']) && strpos((string)$course['url'], 'khoa-luyen-thi-noi-bo-') === 0) {
        $base = 'luyen-thi-' . (slug((string)$course['name']) ?: (string)$course['product_id']);
        $url = $base;
        $taken = sql('SELECT 1 FROM links WHERE url = ? AND deleted = 0 AND NOT (foreign_id = ? AND type = ?)', [$url, $course['product_id'], 'product_detail'])->fetchColumn();
        if ($taken || isset($used_urls[$url])) $url = $base . '-' . $course['product_id'];
        $used_urls[$url] = true;
    }

    $plan[] = ['course' => $course, 'ids' => $ids, 'lessons' => $new_lessons, 'url' => $url,
               'publish' => (int)$course['staff_only'] !== 0 || (int)$course['status'] !== 1 || (int)$course['draft'] !== 0];
}

$exams = array_sum(array_map(function ($item) { return count($item['ids']); }, $plan));
printf("%d courses, %d exams. Lessons to regroup: %d. Courses to publish: %d. Addresses to change: %d.\n",
    count($plan), $exams,
    count(array_filter($plan, function ($item) { return $item['lessons'] !== null; })),
    count(array_filter($plan, function ($item) { return $item['publish']; })),
    count(array_filter($plan, function ($item) { return $item['url'] !== null; })));
foreach (array_slice($plan, 0, 5) as $item) {
    printf("  #%d %s: %d exams, first free #%s%s\n", $item['course']['product_id'], $item['course']['name'], count($item['ids']),
        $item['ids'][0] ?? '-', $item['url'] ? ', /' . $item['url'] : '');
}
if (!$apply) { echo "Report only. Run with \"apply\" to change the database.\n"; exit(0); }

// Back up every row this run changes.
if (!is_dir($options['backup-dir'])) mkdir($options['backup-dir'], 0700, true);
$backup = rtrim($options['backup-dir'], '/') . '/before-publish-exam-prep-' . date('Ymd-His') . '.jsonl.gz';
$out = gzopen($backup, 'wb6');
chmod($backup, 0600);
$product_ids = array_map(function ($item) { return (int)$item['course']['product_id']; }, $plan);
$quiz_ids = array_values(array_unique(array_merge(...array_map(function ($item) { return $item['ids']; }, $plan))));
$in = function (array $ids) { return implode(',', array_map('intval', $ids)) ?: '0'; };
foreach ([
    'products' => 'SELECT * FROM products WHERE id IN (' . $in($product_ids) . ')',
    'products_item' => 'SELECT * FROM products_item WHERE product_id IN (' . $in($product_ids) . ')',
    'products_attribute' => 'SELECT * FROM products_attribute WHERE attribute_id = 11 AND product_id IN (' . $in($product_ids) . ')',
    'exam_prep_courses' => 'SELECT * FROM exam_prep_courses WHERE product_id IN (' . $in($product_ids) . ')',
    'quiz_exam_metadata' => 'SELECT quiz_id, staff_only FROM quiz_exam_metadata WHERE quiz_id IN (' . $in($quiz_ids) . ')',
    'links' => "SELECT * FROM links WHERE type = 'product_detail' AND foreign_id IN (" . $in($product_ids) . ')'
] as $table => $query) {
    foreach ($db->query($query)->fetchAll(PDO::FETCH_ASSOC) as $row) gzwrite($out, encoded(['table' => $table, 'row' => $row]) . "\n");
}
gzclose($out);
echo 'Backup: ' . $backup . "\n";

$db->beginTransaction();
try {
    $now = time();
    foreach ($plan as $item) {
        $id = (int)$item['course']['product_id'];
        if ($item['lessons'] !== null) {
            sql('UPDATE products_attribute SET value = ? WHERE id = ?', [encoded($item['lessons']), $item['course']['lessons_id']]);
        }
        if ($item['url'] !== null) {
            sql('UPDATE links SET url = ?, updated = ? WHERE id = ?', [$item['url'], $now, $item['course']['link_id']]);
        }
        sql('UPDATE products SET status = 1, draft = 0, updated = ? WHERE id = ?', [$now, $id]);
        sql('UPDATE products_item SET status = 1 WHERE product_id = ? AND deleted = 0', [$id]);
        sql('UPDATE exam_prep_courses SET staff_only = 0 WHERE product_id = ?', [$id]);
    }
    if ($quiz_ids) sql('UPDATE quiz_exam_metadata SET staff_only = 0 WHERE quiz_id IN (' . $in($quiz_ids) . ')');
    $db->commit();
} catch (Throwable $e) {
    $db->rollBack();
    fwrite(STDERR, $e->getMessage() . "\n");
    exit(1);
}
echo "Done. Clear the website cache from the admin bar.\n";
