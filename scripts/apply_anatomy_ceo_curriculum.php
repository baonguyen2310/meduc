<?php
/** Apply only the approved Giải phẫu roadmap to the two selected-32 public courses. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
$root=dirname(__DIR__);
define('SOURCE_DOMAIN',$root);
require $root.'/config_database.php';
require $root.'/coredaca/vendor/autoload.php';
require $root.'/coredaca/config/bootstrap.php';
use App\Lib\LessonMetadata;
use App\Lib\LessonQuizzes;
use App\Service\CourseTypes;

$db=\Cake\Datasource\ConnectionManager::get('default');
$apply=($argv[1]??'plan')==='apply';
$backup=$argv[2]??'';
if($apply && (!$backup || !is_dir(dirname($backup)) || file_exists($backup))) throw new RuntimeException('A new backup file outside the web root is required.');
function ensure($ok,string $message):void {if(!$ok)throw new RuntimeException($message);}
function jsonData($value):string {return json_encode($value,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);}
$spec=json_decode(file_get_contents($root.'/data/curricula/anatomy-ceo-20261103.json'),true,512,JSON_THROW_ON_ERROR);
$base=[];$counts=['units'=>0,'chapters'=>0,'lessons'=>0,'priority'=>0];
foreach($spec['units'] as $unit){
    $counts['units']++;
    $base[]=['name_vi'=>$unit['name'],'code'=>'CEO-GP-U'.$unit['number'],'outline_type'=>'unit','curriculum_version'=>$spec['version']];
    foreach($unit['chapters'] as $chapter){
        $counts['chapters']++;
        $base[]=['name_vi'=>$chapter['name'],'code'=>'CEO-GP-C'.$chapter['number'],'outline_type'=>'chapter','curriculum_version'=>$spec['version']];
        foreach($chapter['lessons'] as $lesson){
            $counts['lessons']++;
            if(in_array('Trọng tâm',$lesson['tags'],true))$counts['priority']++;
            $base[]=['name_vi'=>$lesson['name'],'code'=>sprintf('CEO-GP-L%02d',$lesson['number']),'outline_type'=>'lesson',
                'lesson_type'=>$lesson['lesson_type'],'tags'=>$lesson['tags'],'curriculum_version'=>$spec['version']];
        }
    }
}
ensure($counts===['units'=>2,'chapters'=>7,'lessons'=>29,'priority'=>16],'Approved curriculum counts differ.');
$courses=$db->execute("SELECT p.id,p.course_kind,pa.id attribute_id,pa.value FROM products p
    JOIN products_item pi ON pi.product_id=p.id AND pi.deleted=0
    JOIN products_attribute pa ON pa.product_id=p.id AND pa.attribute_id=11
    WHERE p.deleted=0 AND pi.code IN ('MEDUC-32V1-S-MV2-S004','MEDUC-32V1-Q-MV2-S004') ORDER BY p.id")->fetchAll('assoc');
ensure(count($courses)===2,'Expected the two selected-32 anatomy courses.');
$pending=[];$copy=[];$snapshot=['attributes'=>$courses,'quiz_content'=>[],'slots'=>[],'course_content'=>[]];
foreach($courses as $course){
    ensure(in_array($course['course_kind'],['quiz','exam_solution'],true),'Unexpected course type.');
    $content=$db->execute("SELECT * FROM products_content WHERE product_id=:id AND lang='vi'",['id'=>$course['id']])->fetch('assoc');
    $snapshot['course_content'][]=$content;
    if($course['course_kind']==='quiz'){
        $generated='Luyện trắc nghiệm theo 25 bài trong lộ trình MedUC version 1.';
        foreach(['description','seo_description'] as $field)if(($content[$field]??'')===$generated){
            $copy[]=['id'=>$content['id'],'field'=>$field,'old'=>$generated,'new'=>'Luyện trắc nghiệm Giải phẫu học theo 2 học phần, 7 chương và 29 bài trong lộ trình đã chốt.'];
        }
    }
    $old=LessonQuizzes::lessons($course['value']);
    if($old && ($old[0]['curriculum_version']??'')===$spec['version']){
        $actual=array_count_values(array_map([LessonMetadata::class,'outlineType'],$old));
        ensure(($actual['unit']??0)===2 && ($actual['chapter']??0)===7 && ($actual['lesson']??0)===29,'Existing approved outline differs.');
        continue;
    }
    foreach($old as $item){
        ensure(empty($item['youtube_id_vi']) && empty($item['files']) && empty($item['filestwo']),'Existing media needs explicit mapping before replacement.');
    }
    $ids=LessonQuizzes::ids($old);
    if($ids){
        $idList=implode(',',$ids);
        $quizzes=$db->execute('SELECT q.id,qa.value FROM quizs q LEFT JOIN quizs_attribute qa ON qa.quiz_id=q.id AND qa.attribute_id=18 WHERE q.id IN ('.$idList.')')->fetchAll('assoc');
        ensure(count($quizzes)===count($ids),'Missing legacy exercise.');
        foreach($quizzes as $quiz) ensure(json_decode($quiz['value']??'[]',true)===[],'Existing question content needs explicit mapping.');
        ensure((int)$db->execute('SELECT COUNT(*) FROM quizs_answer WHERE quiz_id IN ('.$idList.')')->fetchColumn(0)===0,'Existing exercise history must be preserved.');
        $snapshot['quiz_content']=array_merge($snapshot['quiz_content'],$db->execute('SELECT * FROM quizs_content WHERE quiz_id IN ('.$idList.')')->fetchAll('assoc'));
    }
    $snapshot['slots']=array_merge($snapshot['slots'],$db->execute('SELECT * FROM course_quiz_slots WHERE product_id=:id',['id'=>$course['id']])->fetchAll('assoc'));
    $outline=$base;$position=0;
    foreach($outline as &$item){
        if(!LessonMetadata::isGroup($item) && $course['course_kind']==='quiz'){
            $pair=[];
            for($slot=0;$slot<2;$slot++)if(isset($ids[$position]))$pair[]=['id'=>$ids[$position++],'free'=>$slot===0?'y':'n'];
            $item['quizzes_vi']=jsonData($pair);
            $item['quiz_id_vi']=(string)($pair[0]['id']??'');
        }
        $item=LessonMetadata::normalize($item);
    }
    unset($item);
    ensure($position===count($ids),'Not all empty exercise slots were reused.');
    $pending[]=['course'=>$course,'outline'=>$outline];
}
if($apply && ($pending || $copy)){
    ensure(file_put_contents($backup,jsonData($snapshot),LOCK_EX)!==false,'Backup could not be saved.');
    chmod($backup,0600);
    foreach($pending as $plan){
        $course=$plan['course'];$outline=$plan['outline'];
        $saved=$db->execute('UPDATE products_attribute SET value=:v WHERE id=:id AND BINARY value=BINARY :old',
            ['v'=>jsonData($outline),'id'=>$course['attribute_id'],'old'=>$course['value']]);
        ensure($saved->rowCount()===1,'Outline changed concurrently; review the backup before retrying.');
        foreach($outline as $lesson)foreach(LessonQuizzes::of($lesson) as $i=>$quiz){
            $name='Bài tập '.($i+1).' · '.$lesson['name_vi'];
            $db->execute("UPDATE quizs_content SET name=:n,search_unicode=:n WHERE quiz_id=:id AND lang='vi'",['n'=>$name,'id'=>$quiz['id']]);
        }
        // Group rows are skipped; only the 29 lessons receive their two empty exercise slots.
        CourseTypes::syncLessons((int)$course['id']);
    }
    foreach($copy as $item){
        $field=$item['field'];
        $db->execute('UPDATE products_content SET '.$field.'=:new WHERE id=:id AND BINARY '.$field.'=BINARY :old',
            ['id'=>$item['id'],'old'=>$item['old'],'new'=>$item['new']]);
    }
    \Cake\Cache\Cache::clearAll();
}
echo jsonData(['applied'=>$apply,'courses'=>array_map(fn($p)=>(int)$p['course']['id'],$pending),'description_fields'=>count($copy),'counts_per_course'=>$counts]).PHP_EOL;
