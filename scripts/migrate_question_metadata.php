<?php
/** Add nullable classification fields and map legacy levels without changing any question content. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
$mode = $argv[1] ?? 'plan';
if (!in_array($mode, ['plan', 'apply'], true)) throw new RuntimeException('Usage: plan|apply [private-backup.jsonl.gz]');
$root = getenv('MEDUC_APP_ROOT') ?: dirname(__DIR__);
require $root . '/config_database.php';
require $root . '/coredaca/src/Lib/QuestionMetadata.php';
use App\Lib\QuestionMetadata;
$db = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4', DB_USERNAME, DB_PASSWORD, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$changes = [];
$stats = ['mode' => $mode, 'changed_quizzes' => 0, 'questions' => 0, 'mapped_levels' => [], 'unclassified' => 0, 'skipped_invalid_quiz_ids' => []];
foreach ($db->query('SELECT id,quiz_id,value FROM quizs_attribute WHERE attribute_id=18') as $row) {
    if ($row['value'] === null || in_array(trim($row['value']), ['', 'null'], true)) continue;
    $questions = json_decode($row['value'], true);
    if (!is_array($questions)) {
        // A few legacy TEXT values were already truncated at 65,535 bytes. Preserve them verbatim.
        $stats['skipped_invalid_quiz_ids'][] = (int)$row['quiz_id'];
        continue;
    }
    $changed = false;
    foreach ($questions as &$question) {
        if (!is_array($question)) throw new RuntimeException('Invalid question in attribute ' . $row['id']);
        $before = $question;
        $question = QuestionMetadata::normalize($question + ['question_category' => null, 'difficulty_level' => null]);
        $stats['questions']++;
        if ($question['question_category'] === null) $stats['unclassified']++;
        if (($before['difficulty_level'] ?? null) !== $question['difficulty_level']) {
            $key = $before['difficulty_level'] . ' → ' . $question['difficulty_level'];
            $stats['mapped_levels'][$key] = ($stats['mapped_levels'][$key] ?? 0) + 1;
        }
        if ($before !== $question) $changed = true;
    }
    unset($question);
    if ($changed) {
        $row['new_value'] = json_encode($questions, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
        $changes[] = $row;
    }
}
$stats['changed_quizzes'] = count($changes);
if ($mode === 'apply' && $changes) {
    $backup = $argv[2] ?? '';
    $directory = realpath(dirname($backup));
    if ($backup === '' || !$directory || strpos($directory . '/', realpath($root) . '/') === 0) {
        throw new RuntimeException('Backup must be outside the web root.');
    }
    umask(0077);
    $stream = fopen($backup, 'xb');
    if (!$stream) throw new RuntimeException('A new private backup file is required.');
    $gz = gzopen($backup, 'wb6');
    if (!$gz) throw new RuntimeException('Cannot open compressed backup.');
    foreach ($changes as $row) {
        unset($row['new_value']);
        $line = json_encode($row, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR) . "\n";
        if (gzwrite($gz, $line) !== strlen($line)) throw new RuntimeException('Cannot write backup.');
    }
    if (!gzclose($gz)) throw new RuntimeException('Cannot finish backup.');
    fclose($stream);
    $db->beginTransaction();
    try {
        $update = $db->prepare('UPDATE quizs_attribute SET value=? WHERE id=? AND BINARY value=BINARY ?');
        foreach ($changes as $row) {
            $update->execute([$row['new_value'], $row['id'], $row['value']]);
            if ($update->rowCount() !== 1) throw new RuntimeException('Question changed concurrently: ' . $row['id']);
        }
        $db->commit();
    } catch (Throwable $e) {
        if ($db->inTransaction()) $db->rollBack();
        throw $e;
    }
}
echo json_encode($stats, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . PHP_EOL;
