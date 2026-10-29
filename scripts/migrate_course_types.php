<?php
/** Add the four course types and mark the existing source library private.
 * Usage: php scripts/migrate_course_types.php /var/www/html /secure/backup-directory
 * Run before deploying code using course_kind. DDL is additive; DML is transactional.
 */
if (PHP_SAPI !== 'cli' || empty($argv[1]) || empty($argv[2])) throw new RuntimeException('Pass application root and an existing backup directory.');
$root=rtrim($argv[1],'/'); $backupDir=rtrim($argv[2],'/');
if (!is_dir($backupDir) || !is_writable($backupDir)) throw new RuntimeException('Backup directory is not writable.');
require $root.'/config_database.php';
$db=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USERNAME,DB_PASSWORD,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$expected=(int)$db->query('SELECT COUNT(*) FROM curriculum_v2_courses')->fetchColumn();
if ($expected!==108) throw new RuntimeException('Expected the approved 108 source subjects.');
$backup=[]; foreach(['products','quizs'] as $table) $backup[$table]=$db->query('SELECT * FROM '.$table)->fetchAll();
$backup['products_attribute']=$db->query('SELECT a.* FROM products_attribute a JOIN curriculum_v2_courses c ON c.product_id=a.product_id')->fetchAll();
$backupPath=$backupDir.'/course-types-before-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json.gz';
if (file_put_contents($backupPath,gzencode(json_encode($backup,JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_SUBSTITUTE),6))===false) throw new RuntimeException('Backup failed.');
chmod($backupPath,0600);
$sql=file_get_contents(__DIR__.'/meduc_course_types.sql');
$pos=strpos($sql,'UPDATE products'); $db->exec(substr($sql,0,$pos));
$db->beginTransaction();
try {
    $db->exec(substr($sql,$pos));
    $ids=[];
    foreach($backup['products_attribute'] as $a) if ((int)$a['attribute_id']===11) {
        foreach((array)json_decode($a['value'],true) as $lesson) {
            if (($lesson['chapter_vi']??'')==='y') continue;
            $quizzes=$lesson['quizzes_vi']??[];
            if (is_string($quizzes)) $quizzes=json_decode($quizzes,true);
            foreach((array)$quizzes as $q) if (!empty($q['id'])) $ids[(int)$q['id']]=true;
            if (!empty($lesson['quiz_id_vi'])) $ids[(int)$lesson['quiz_id_vi']]=true;
        }
    }
    if ($ids) $db->exec('UPDATE quizs SET fa_only=1 WHERE id IN ('.implode(',',array_keys($ids)).')');
    if ((int)$db->query("SELECT COUNT(*) FROM curriculum_v2_courses c JOIN products p ON p.id=c.product_id WHERE p.course_kind='fa'")->fetchColumn()!==$expected) throw new RuntimeException('Fa migration is incomplete.');
    $db->commit();
    echo "Four course types ready. Backup: $backupPath\n";
} catch (Throwable $error) { $db->rollBack(); throw $error; }
