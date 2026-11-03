<?php
/** CLI only: plan, or apply with an explicit backup path outside the public directory. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
require dirname(__DIR__).'/config_database.php';
require dirname(__DIR__).'/coredaca/src/Lib/LessonMetadata.php';

$apply = ($argv[1] ?? 'plan') === 'apply';
$backup = $argv[2] ?? '';
if ($apply && (!$backup || !is_dir(dirname($backup)) || file_exists($backup))) {
    throw new RuntimeException('Provide a new backup file in an existing directory.');
}
$db = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4', DB_USERNAME, DB_PASSWORD,
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$db->beginTransaction();
$written = [];
try {
    $rows = $db->query('SELECT id,product_id,value FROM products_attribute WHERE attribute_id=11 FOR UPDATE')->fetchAll();
    $changes = [];
    $counts = ['courses'=>0, 'lessons'=>0, 'converted_mock_exams'=>0, 'types'=>[]];
    foreach ($rows as $row) {
        if ($row['value'] === null || trim($row['value']) === '') continue;
        $outline = json_decode($row['value'], true, 512, JSON_THROW_ON_ERROR);
        if (!is_array($outline)) throw new RuntimeException('Invalid outline: '.$row['product_id']);
        $before = $outline;
        foreach ($outline as &$lesson) {
            if (!is_array($lesson)) continue;
            if (($lesson['chapter_vi'] ?? '') !== 'y') {
                if (empty($lesson['lesson_type']) && ($lesson['review_vi'] ?? '') === 'y') {
                    $lesson['lesson_type'] = 'final';
                    $counts['converted_mock_exams']++;
                }
                $counts['lessons']++;
            }
            $lesson = \App\Lib\LessonMetadata::normalize($lesson);
            if (($lesson['chapter_vi'] ?? '') !== 'y') {
                $type = $lesson['lesson_type'];
                $counts['types'][$type] = ($counts['types'][$type] ?? 0) + 1;
            }
        }
        unset($lesson);
        if ($outline !== $before) $changes[] = ['id'=>$row['id'], 'original'=>$row['value'], 'value'=>json_encode($outline, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR)];
    }
    $counts['courses'] = count($changes);
    if ($apply) {
        if (file_put_contents($backup, json_encode($rows, JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR), LOCK_EX) === false) {
            throw new RuntimeException('Could not write backup.');
        }
        chmod($backup, 0600);
        // The legacy attribute table can be MyISAM: use guarded writes and explicit recovery too.
        $update = $db->prepare('UPDATE products_attribute SET value=:value WHERE id=:id AND attribute_id=11 AND BINARY value=BINARY :original');
        foreach ($changes as $row) {
            $update->execute($row);
            if ($update->rowCount() !== 1) throw new RuntimeException('Outline changed concurrently: '.$row['id']);
            $written[] = $row;
        }
        $db->commit();
    } else $db->rollBack();
    echo json_encode(['applied'=>$apply, 'counts'=>$counts], JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT)."\n";
} catch (Throwable $e) {
    if ($db->inTransaction()) $db->rollBack();
    $restore = $db->prepare('UPDATE products_attribute SET value=:original WHERE id=:id AND attribute_id=11 AND BINARY value=BINARY :value');
    foreach (array_reverse($written) as $row) $restore->execute($row);
    throw $e;
}
