<?php
/** Private CLI importer; paired with publish_subject_exams.py. MyISAM rows have explicit undo snapshots. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
function ensure($ok, string $message): void { if (!$ok) throw new RuntimeException($message); }
function js($value): string { return json_encode($value, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR); }
$mode = $argv[1] ?? 'plan';
ensure(in_array($mode, ['plan','apply','verify'], true), 'Expected plan, apply or verify.');
$input = json_decode(file_get_contents($argv[2]), true, 512, JSON_THROW_ON_ERROR);
$root = realpath($input['app_root']); ensure($root !== false, 'Missing app root.');
define('SOURCE_DOMAIN', $root);
require $root.'/config_database.php'; require $root.'/coredaca/vendor/autoload.php'; require $root.'/coredaca/config/bootstrap.php';
use App\Lib\LessonMetadata;
use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;
$db = \Cake\Datasource\ConnectionManager::get('default');
$rows = $db->execute("SELECT p.id,p.course_kind,pa.id attribute_id,pa.value FROM products p JOIN products_item i ON i.product_id=p.id AND i.deleted=0 JOIN products_attribute pa ON pa.product_id=p.id AND pa.attribute_id=11 WHERE i.code=:code AND p.deleted=0", ['code'=>$input['product_code']])->fetchAll('assoc');
ensure(count($rows) === 1 && $rows[0]['course_kind'] === 'quiz', 'Expected one quiz course.');
$course = $rows[0]; $productId = (int)$course['id'];
$lock = 'meduc_lesson_json_'.$productId;
ensure((int)$db->execute('SELECT GET_LOCK(:n,0)', ['n'=>$lock])->fetchColumn(0) === 1, 'Another course import is running.');
$created = []; $changed = []; $snapshots = []; $plans = []; $reports = [];
try {
    $outline = LessonQuizzes::lessons($course['value']);
    $oldSlots = $db->execute('SELECT * FROM course_quiz_slots WHERE product_id=:p', ['p'=>$productId])->fetchAll('assoc');
    $slotsSchema = $db->execute('SHOW CREATE TABLE course_quiz_slots')->fetch('assoc')['Create Table'];
    $needsMigration = strpos($slotsSchema, 'slot_two_only') !== false;
    $oldExamLessons = [];
    foreach ($outline as $l) if (!LessonMetadata::isGroup($l) && LessonMetadata::isExam($l)) $oldExamLessons[$l['code']] = $l;
    $seenCodes = []; $seenIds = [];
    foreach ($input['groups'] as $groupIndex=>&$group) {
        ensure(in_array($group['lesson_type'], ['midterm','practical','final'], true), 'Invalid exam lesson type.');
        ensure(count($group['exams']) <= 255, 'Too many exams for one lesson.');
        $oldLesson = $oldExamLessons[$group['lesson_code']] ?? null;
        if (!$oldLesson) {
            $sameType = array_values(array_filter($oldExamLessons, function($l) use ($group) {
                return LessonMetadata::type($l) === $group['lesson_type'];
            }));
            ensure(count($sameType) <= 1, 'Multiple existing exam lessons match the requested type.');
            if ($sameType) {
                $oldLesson = $sameType[0];
                $group['lesson_code'] = $oldLesson['code'];
            }
        }
        $attached = $oldLesson ? LessonQuizzes::of($oldLesson) : [];
        $groupIds = [];
        foreach ($group['exams'] as $index=>$exam) {
            $meta = $exam['metadata']; $questions = $exam['questions'];
            ensure(!isset($seenCodes[$meta['code']]), 'Duplicate exam code.'); $seenCodes[$meta['code']] = true;
            // Keep identities stable when an optional practical group is absent.
            $sourceGroup = ['midterm'=>1, 'practical'=>2, 'final'=>3][$group['lesson_type']];
            $sourceId = $productId*1000000 + $sourceGroup*10000 + $index+1;
            $existing = $db->execute("SELECT quiz_id FROM quiz_exam_metadata WHERE source_system='meduc-subject-json' AND source_exam_id=:s", ['s'=>$sourceId])->fetchColumn(0);
            $id = (int)$existing;
            if (!$id && isset($attached[$index])) $id = (int)$attached[$index]['id'];
            $free = $index === 0;
            $snapshot = null;
            if ($id) {
                ensure(!isset($seenIds[$id]), 'Duplicate target quiz.'); $seenIds[$id] = true;
                $quiz = $db->execute('SELECT * FROM quizs WHERE id=:id', ['id'=>$id])->fetch('assoc');
                $owner = $db->execute('SELECT * FROM course_quiz_slots WHERE quiz_id=:id', ['id'=>$id])->fetch('assoc');
                ensure($quiz && !$quiz['deleted'] && !$quiz['fa_only'] && $quiz['course_only'] && $owner && (int)$owner['product_id'] === $productId && $owner['lesson_code'] === $group['lesson_code'], 'Target quiz ownership differs.');
                $attrs = $db->execute('SELECT * FROM quizs_attribute WHERE quiz_id=:id', ['id'=>$id])->fetchAll('assoc');
                $content = $db->execute("SELECT * FROM quizs_content WHERE quiz_id=:id AND lang='vi'", ['id'=>$id])->fetchAll('assoc');
                ensure(count($content) === 1, 'Missing or duplicate title.');
                $questionAttrs = array_values(array_filter($attrs, function($a) { return (int)$a['attribute_id'] === 18; }));
                ensure(count($questionAttrs) === 1, 'Missing or duplicate question JSON.');
                $oldQuestions = json_decode($questionAttrs[0]['value'], true, 512, JSON_THROW_ON_ERROR);
                $attempts = (int)$db->execute('SELECT COUNT(*) FROM quizs_answer WHERE quiz_id=:id', ['id'=>$id])->fetchColumn(0);
                // JSON encodes a rubric's 1.0 as 1; compare the persisted representation, not PHP scalar types.
                $sameQuestions = js($oldQuestions) === js($questions);
                ensure($sameQuestions || $attempts === 0, 'Cannot change a quiz with student history.');
                $oldMeta = $db->execute('SELECT * FROM quiz_exam_metadata WHERE quiz_id=:id', ['id'=>$id])->fetch('assoc');
                ensure(!$oldMeta || $oldMeta['source_system'] === 'meduc-subject-json' || !$oldQuestions, 'Would overwrite an unrelated quiz.');
                $snapshot = ['quiz'=>$quiz,'attributes'=>$attrs,'content'=>$content[0],'metadata'=>$oldMeta?:null,'attempts'=>$attempts];
                $snapshots[$id] = $snapshot;
                if ($oldLesson) $free = $attached[$index]['free'] ?? $free;
            }
            ensure(count($questions) === (int)$meta['total_questions'] && count($questions)>0, 'Question count mismatch.');
            $questionTypes = array_values(array_unique(array_column($questions, 'question_type')));
            ensure(count($questionTypes) === 1, 'Mixed question types are not supported.');
            $quizType = $questionTypes[0] === 'TULUAN' ? 'TULUAN' : 'TRAC_NGHIEM';
            foreach ($questions as $position=>$question) {
                ensure($question['ai_subject_code'] === $input['subject_code'] && (int)$question['order_index'] === $position+1, 'Subject/order mismatch.');
                ensure(!empty($question['ai_general_explanation']), 'Missing concept.');
                if ($question['question_type'] === 'TULUAN') ensure($group['lesson_type'] === 'practical' && !empty($question['answer_vi']), 'Invalid practical reference question.');
                else {
                    ensure($question['question_type'] === 'MULTIPLE_CHOICE' && !empty($question['assembly_source']), 'Missing lesson source reference.');
                    $correct = []; foreach ($question['options'] as $i=>$option) { if ($option['is_correct']) $correct[]=$i+1; ensure(trim($option['ai_explanation']) !== '', 'Missing option explanation.'); }
                    ensure(count($correct)===1 && (int)$question['answer_vi']===$correct[0], 'Answer key mismatch.');
                }
            }
            $value = js($questions); $hash = hash('sha256',$value);
            $rendered = QuizQuestions::fromValue($value);
            ensure(count($rendered) === count($questions), 'Player dropped questions; deploy the practical parser first.');
            $school = trim((string)($meta['school'] ?? ''));
            $title = $meta['name'];
            $minutes = (int)$meta['duration_minutes'];
            $same = false;
            if ($snapshot) {
                $m = $snapshot['metadata'];
                $minutesAttr = array_values(array_filter($snapshot['attributes'],function($a){return (int)$a['attribute_id']===19;}));
                $same = $sameQuestions && $snapshot['content']['name'] === $title && $m && $m['source_system']==='meduc-subject-json' && $m['source_hash']===$hash && (string)$m['school_name']===$school && $m['source_quiz_type']===$quizType && (int)$m['staff_only']===0 && count($minutesAttr)===1 && (int)$minutesAttr[0]['value']===$minutes;
            }
            if ($mode==='verify') ensure($same, 'Readback differs: '.$meta['code']);
            $plan = ['id'=>$id,'source_id'=>$sourceId,'code'=>$meta['code'],'lesson_code'=>$group['lesson_code'],'lesson_type'=>$group['lesson_type'],'quiz_type'=>$quizType,'slot'=>$index+1,'free'=>$free,'name'=>$title,'school'=>$school,'minutes'=>$minutes,'value'=>$value,'hash'=>$hash,'count'=>count($questions),'same'=>$same];
            $plans[] = $plan; $groupIds[]=$id;
        }
        // Existing references may only be replaced by the exact imported exam set.
        foreach ($attached as $q) ensure(in_array($q['id'],$groupIds,true), 'Existing exam would be detached.');
    } unset($group);
    foreach ($oldExamLessons as $code=>$l) ensure(in_array($code,array_column($input['groups'],'lesson_code'),true), 'Unexpected exam lesson would be removed.');
    foreach ($input['assets'] as $asset) {
        ensure((bool)preg_match('/^[a-f0-9]{64}\.(png|jpg|jpeg|webp)$/D',$asset['filename']) && $asset['relative_path']==='cdn/media/lesson-exercises/'.$asset['filename'], 'Invalid image path.');
        ensure(hash_file('sha256',$asset['staged_path'])===$asset['sha256'] && getimagesize($asset['staged_path'])!==false,'Invalid practical image.');
        if ($mode==='verify') ensure(is_file($root.'/'.$asset['relative_path']) && hash_file('sha256',$root.'/'.$asset['relative_path'])===$asset['sha256'], 'Published image differs.');
    }
    $backup = $argv[3] ?? '';
    if ($mode==='apply') {
        $parent = realpath(dirname($backup));
        ensure($parent && strpos($parent,$root)!==0 && !file_exists($backup), 'Need a new private backup path.');
        $f = fopen($backup,'x'); ensure($f!==false,'Backup failed.');
        try { ensure(fwrite($f,js(['course'=>$course,'slots'=>$oldSlots,'slots_schema'=>$slotsSchema,'quizzes'=>$snapshots]))!==false,'Backup write failed.'); } finally { fclose($f); }
        chmod($backup,0600);
        if ($needsMigration) $db->execute('ALTER TABLE course_quiz_slots DROP CONSTRAINT slot_two_only, ADD CONSTRAINT slot_positive CHECK (slot >= 1)');
        foreach ($input['assets'] as $asset) {
            $dest = $root.'/'.$asset['relative_path'];
            if (!is_dir(dirname($dest))) ensure(mkdir(dirname($dest),0755,true),'Cannot create image directory.');
            if (is_file($dest)) ensure(hash_file('sha256',$dest)===$asset['sha256'],'Conflicting image.');
            else { ensure(copy($asset['staged_path'],$dest),'Image copy failed.'); chmod($dest,0644); }
        }
        $db->begin();
        try {
            ensure($db->execute('SELECT value FROM products_attribute WHERE id=:id',['id'=>$course['attribute_id']])->fetchColumn(0)===$course['value'],'Outline changed concurrently.');
            foreach ($plans as &$p) {
                if ($p['same']) continue;
                $id=$p['id'];
                if ($id) {
                    $old=$snapshots[$id];
                    ensure((int)$db->execute('SELECT COUNT(*) FROM quizs_answer WHERE quiz_id=:id',['id'=>$id])->fetchColumn(0)===$old['attempts'],'Student history changed during import.');
                    $attr=array_values(array_filter($old['attributes'],function($a){return (int)$a['attribute_id']===18;}))[0];
                    $r=$db->execute('UPDATE quizs_attribute SET value=:v WHERE id=:id AND BINARY value=BINARY :old',['v'=>$p['value'],'id'=>$attr['id'],'old'=>$attr['value']]);
                    ensure($r->rowCount()===1 || $p['value']===$attr['value'],'Questions changed concurrently.'); $changed[$id]=true;
                    $db->execute('UPDATE quizs_content SET name=:n,search_unicode=:n WHERE id=:id',['n'=>$p['name'],'id'=>$old['content']['id']]);
                    $db->execute('DELETE FROM quizs_attribute WHERE quiz_id=:id AND attribute_id=19',['id'=>$id]);
                    $db->execute('INSERT INTO quizs_attribute (quiz_id,attribute_id,value) VALUES (:id,19,:v)',['id'=>$id,'v'=>(string)$p['minutes']]);
                } else {
                    $now=time();
                    $db->execute('INSERT INTO quizs (created,updated,status,draft,deleted,fa_only,course_only) VALUES (:now,:now,1,0,0,0,1)',['now'=>$now]);
                    $id=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0); $p['id']=$id; $created[]=$id;
                    $db->execute("INSERT INTO quizs_content (quiz_id,name,lang,search_unicode) VALUES (:id,:n,'vi',:n)",['id'=>$id,'n'=>$p['name']]);
                    $db->execute('INSERT INTO quizs_attribute (quiz_id,attribute_id,value) VALUES (:id,18,:v),(:id,19,:t)',['id'=>$id,'v'=>$p['value'],'t'=>(string)$p['minutes']]);
                    $db->execute("INSERT INTO links (foreign_id,type,url,lang,created,updated,deleted) VALUES (:id,'quiz_detail',:url,'vi',:now,:now,0)",['id'=>$id,'url'=>'bai-tap-'.$productId.'-'.$id,'now'=>$now]);
                }
                $db->execute("INSERT INTO quiz_exam_metadata (quiz_id,source_system,source_exam_id,import_topic,school_name,source_quiz_type,curriculum_type,source_is_pro,question_count,source_question_count,source_hash,source_remote_id,imported_at,staff_only) VALUES (:id,'meduc-subject-json',:source,:topic,:school,:type,'subject',:pro,:count,:count,:hash,:code,NOW(),0) ON DUPLICATE KEY UPDATE source_system=VALUES(source_system),source_exam_id=VALUES(source_exam_id),import_topic=VALUES(import_topic),school_name=VALUES(school_name),source_quiz_type=VALUES(source_quiz_type),curriculum_type='subject',source_is_pro=VALUES(source_is_pro),question_count=VALUES(question_count),source_question_count=VALUES(source_question_count),source_hash=VALUES(source_hash),source_remote_id=VALUES(source_remote_id),staff_only=0",['id'=>$id,'source'=>$p['source_id'],'topic'=>$input['subject_code'],'school'=>$p['school'],'type'=>$p['quiz_type'],'pro'=>$p['free']?0:1,'count'=>$p['count'],'hash'=>$p['hash'],'code'=>$p['code']]);
                $actual=QuizQuestions::load($id); ensure($actual && count($actual['questions'])===$p['count'],'Player readback failed.');
            } unset($p);
            $newOutline=[];
            foreach ($outline as $l) if (LessonMetadata::isGroup($l) || !LessonMetadata::isExam($l)) $newOutline[]=$l;
            foreach ($input['groups'] as $g) {
                $l=$oldExamLessons[$g['lesson_code']] ?? ['code'=>$g['lesson_code'],'outline_type'=>'lesson','chapter_vi'=>'n','tags'=>[]];
                $l['name_vi']=$g['lesson_name']; $l['lesson_type']=$g['lesson_type'];
                $list=[];
                foreach ($plans as $p) if ($p['lesson_code']===$g['lesson_code']) $list[]=['id'=>$p['id'],'free'=>$p['free']?'y':'n'];
                $l['quizzes_vi']=js($list); $l['quiz_id_vi']=(string)$list[0]['id']; $newOutline[]=$l;
                $db->execute('DELETE FROM course_quiz_slots WHERE product_id=:p AND lesson_code=:l',['p'=>$productId,'l'=>$g['lesson_code']]);
                foreach ($list as $i=>$q) $db->execute('INSERT INTO course_quiz_slots (product_id,lesson_code,slot,quiz_id) VALUES (:p,:l,:s,:q)',['p'=>$productId,'l'=>$g['lesson_code'],'s'=>$i+1,'q'=>$q['id']]);
            }
            $newValue=js($newOutline);
            $saved=$db->execute('UPDATE products_attribute SET value=:v WHERE id=:id AND BINARY value=BINARY :old',['v'=>$newValue,'id'=>$course['attribute_id'],'old'=>$course['value']]);
            ensure($saved->rowCount()===1 || $newValue===$course['value'],'Outline changed concurrently.');
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollback();
            foreach ($created as $id) {
                $db->execute('DELETE FROM links WHERE foreign_id=:id AND type=\'quiz_detail\'',['id'=>$id]);
                $db->execute('DELETE FROM quizs_attribute WHERE quiz_id=:id',['id'=>$id]); $db->execute('DELETE FROM quizs_content WHERE quiz_id=:id',['id'=>$id]); $db->execute('DELETE FROM quizs WHERE id=:id',['id'=>$id]);
            }
            foreach (array_keys($changed) as $id) {
                $old=$snapshots[$id];
                $db->execute('DELETE FROM quizs_attribute WHERE quiz_id=:id',['id'=>$id]);
                foreach ($old['attributes'] as $a) $db->execute('INSERT INTO quizs_attribute (id,quiz_id,attribute_id,value) VALUES (:id,:quiz,:attr,:v)',['id'=>$a['id'],'quiz'=>$id,'attr'=>$a['attribute_id'],'v'=>$a['value']]);
                $db->execute('UPDATE quizs_content SET name=:n,search_unicode=:s WHERE id=:id',['n'=>$old['content']['name'],'s'=>$old['content']['search_unicode'],'id'=>$old['content']['id']]);
            }
            $db->execute('UPDATE products_attribute SET value=:v WHERE id=:id',['v'=>$course['value'],'id'=>$course['attribute_id']]);
            \Cake\Cache\Cache::clearAll(); throw $e;
        }
        \Cake\Cache\Cache::clearAll();
    }
    if ($mode==='verify') {
        foreach ($input['groups'] as $g) {
            $l=$oldExamLessons[$g['lesson_code']] ?? [];
            ensure(($l['name_vi']??'')===$g['lesson_name'] && count(LessonQuizzes::of($l))===count($g['exams']),'Outline differs on readback.');
            ensure(count(\App\Service\CourseTypes::quizzes($l,'quiz'))===count($g['exams']),'Public helper truncated exams.');
        }
        ensure(!$needsMigration,'Slot schema still limits exams to two.');
    }
    foreach ($plans as $p) { unset($p['value']); $reports[]=$p; }
    echo js(['mode'=>$mode,'course_id'=>$productId,'exams'=>count($plans),'question_slots'=>array_sum(array_column($plans,'count')),'assets'=>count($input['assets']),'created'=>count($created),'changed'=>count($changed),'needs_slot_migration'=>$needsMigration,'backup'=>$mode==='apply'?$backup:null,'quizzes'=>$reports]).PHP_EOL;
} finally { $db->execute('SELECT RELEASE_LOCK(:n)',['n'=>$lock]); }
