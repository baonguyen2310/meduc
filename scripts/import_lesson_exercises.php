<?php
/** CLI companion for publish_lesson_exercises.py. Never performs public HTTP imports. */
declare(strict_types=1);
if(PHP_SAPI!=='cli')exit(1);
function ensure($ok,string $message):void{if(!$ok)throw new RuntimeException($message);}
function js($value):string{return json_encode($value,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);}
$mode=$argv[1]??'plan';ensure(in_array($mode,['plan','apply','verify'],true),'Usage: plan|apply|verify payload.json backup.json');
$input=json_decode(file_get_contents($argv[2]),true,512,JSON_THROW_ON_ERROR);
$root=realpath($input['app_root']);ensure($root!==false,'App root missing.');
define('SOURCE_DOMAIN',$root);
require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';require $root.'/coredaca/config/bootstrap.php';
use App\Lib\LessonMetadata;
use App\Lib\LessonQuizzes;
use App\Lib\QuestionMetadata;
use App\Lib\QuizQuestions;
$db=\Cake\Datasource\ConnectionManager::get('default');
$rows=$db->execute("SELECT p.id,p.course_kind,pa.id attribute_id,pa.value FROM products p JOIN products_item i ON i.product_id=p.id AND i.deleted=0 JOIN products_attribute pa ON pa.product_id=p.id AND pa.attribute_id=11 WHERE i.code=:code AND p.deleted=0",['code'=>$input['product_code']])->fetchAll('assoc');
ensure(count($rows)===1&&$rows[0]['course_kind']==='quiz','Expected one public quiz course.');$course=$rows[0];
$lock='meduc_lesson_json_'.$course['id'];ensure((int)$db->execute('SELECT GET_LOCK(:n,0)',['n'=>$lock])->fetchColumn(0)===1,'Another import is running.');
$snapshot=[];$modified=[];$plans=[];$codes=[];
try{
 $outline=LessonQuizzes::lessons($course['value']);
 foreach($input['lessons'] as $lesson){
  $matches=array_values(array_filter($outline,function($l)use($lesson){return !LessonMetadata::isGroup($l)&&LessonMetadata::type($l)==='regular'&&(int)($l['source_lesson_number']??0)===$lesson['lesson_number'];}));
  ensure(count($matches)===1,'Cannot uniquely find lesson '.$lesson['lesson_number']);$target=$matches[0];
  ensure($target['code']===$lesson['lesson_code']&&$target['name_vi']===$lesson['lesson_name'],'Lesson name/code differs from approved outline.');
  $quizzes=LessonQuizzes::of($target);ensure(count($quizzes)===2,'A lesson needs exactly two existing exercise slots.');
  ensure(count($lesson['exams'])===2,'Expected two input exercises.');
  foreach($lesson['exams'] as $index=>$exam){
   $slot=$index+1;ensure((int)$exam['metadata']['exercise_number']===$slot,'Exercise order differs.');
   $id=(int)$quizzes[$index]['id'];ensure(!isset($snapshot[$id]),'Duplicate target exercise.');
   $owner=$db->execute('SELECT * FROM course_quiz_slots WHERE quiz_id=:id',['id'=>$id])->fetch('assoc');
   ensure($owner&&(int)$owner['product_id']===(int)$course['id']&&$owner['lesson_code']===$target['code']&&(int)$owner['slot']===$slot,'Exercise ownership differs.');
   $q=$db->execute('SELECT * FROM quizs WHERE id=:id',['id'=>$id])->fetch('assoc');ensure($q&&!$q['deleted']&&!$q['fa_only']&&$q['course_only'],'Invalid or private target exercise.');
   $attr=$db->execute('SELECT * FROM quizs_attribute WHERE quiz_id=:id AND attribute_id=18',['id'=>$id])->fetchAll('assoc');ensure(count($attr)===1,'Missing or duplicate question attribute.');$attr=$attr[0];
   $content=$db->execute("SELECT * FROM quizs_content WHERE quiz_id=:id AND lang='vi'",['id'=>$id])->fetch('assoc');ensure($content,'Exercise title missing.');
   $meta=$db->execute('SELECT * FROM quiz_exam_metadata WHERE quiz_id=:id',['id'=>$id])->fetch('assoc');
   $attempts=(int)$db->execute('SELECT COUNT(*) FROM quizs_answer WHERE quiz_id=:id',['id'=>$id])->fetchColumn(0);
   $questions=$exam['questions'];ensure(count($questions)===20,'Expected 20 questions.');$clinical=0;
   foreach($questions as $position=>&$question){
    $question=QuestionMetadata::normalize($question);
    ensure($question['ai_subject_code']===$input['subject_code']&&$question['ai_lesson_code']===$target['code'],'Question maps to another lesson.');
    ensure(!empty($question['code'])&&!isset($codes[$question['code']]),'Duplicate/missing question code.');$codes[$question['code']]=true;
    ensure($question['question_type']==='MULTIPLE_CHOICE'&&$question['order_index']===$position+1,'Invalid question type/order.');
    ensure(isset(QuestionMetadata::CATEGORIES[$question['question_category']])&&isset(QuestionMetadata::LEVELS[$question['difficulty_level']]),'Missing question classification.');
    $options=$question['options'];ensure(count($options)>=4&&count($options)<=5,'Invalid choice count.');$right=[];
    foreach($options as $i=>$option){if($option['is_correct']===true)$right[]=$i+1;ensure(trim($option['content'])!==''&&trim($option['ai_explanation'])!=='','Incomplete choice/explanation.');}
    ensure(count($right)===1&&(int)$question['answer_vi']===$right[0],'Answer key differs.');
    ensure(trim($question['ai_general_explanation'])!=='','Missing concept explanation.');
    if($question['question_category']==='clinical'){$clinical++;ensure($question['difficulty_level']==='application','Clinical level differs.');}
   }unset($question);
   ensure($clinical===6,'Expected six clinical questions per exercise.');
   $value=js($questions);$player=QuizQuestions::fromValue($value);ensure(count($player)===20,'Player dropped a question.');
   foreach($player as $rendered)ensure(!empty($rendered['explanation_parts']['concept'])&&count($rendered['explanation_parts']['options'])===count($rendered['options']),'Player lost explanations.');
   $old=json_decode($attr['value'],true,512,JSON_THROW_ON_ERROR);ensure(is_array($old),'Invalid existing question JSON.');
   $same=$old===$questions;
   if(!$same&&count($old)>0){ensure(!empty($input['replace']),'Target contains different questions; explicit --replace required.');ensure($attempts===0,'Changed exercise already has history; publish a new version instead.');}
   $hash=hash('sha256',$value);$metadataSame=$meta&&$meta['source_system']==='meduc-lesson-json'&&$meta['source_hash']===$hash&&(int)$meta['question_count']===20&&(int)$meta['staff_only']===0;
   $changed=!$same||!$metadataSame||$content['name']!==$exam['metadata']['name'];
   $snapshot[$id]=['attribute'=>$attr,'content'=>$content,'metadata'=>$meta?:null,'attempts'=>$attempts];
   $plans[]=['id'=>$id,'lesson'=>$lesson['lesson_number'],'lesson_code'=>$target['code'],'slot'=>$slot,'questions'=>$questions,'value'=>$value,'hash'=>$hash,'name'=>$exam['metadata']['name'],'changed'=>$changed,'clinical'=>$clinical];
   if($mode==='verify')ensure(!$changed,'Exercise differs on readback: '.$id);
  }
 }
 $assets=$input['assets']??[];
 foreach($assets as $asset){
  ensure((bool)preg_match('/^[a-f0-9]{64}\.(jpg|jpeg|png|webp|gif)$/D',$asset['filename']),'Invalid asset filename.');
  ensure($asset['relative_path']==='cdn/media/lesson-exercises/'.$asset['filename'],'Invalid image destination.');
  ensure(hash_file('sha256',$asset['staged_path'])===$asset['sha256']&&getimagesize($asset['staged_path'])!==false,'Invalid image data.');
  if($mode==='verify')ensure(is_file($root.'/'.$asset['relative_path'])&&hash_file('sha256',$root.'/'.$asset['relative_path'])===$asset['sha256'],'Published image differs.');
 }
 $changes=array_values(array_filter($plans,function($p){return $p['changed'];}));$backup=$argv[3]??'';
 if($mode==='apply'&&$changes){
  $parent=realpath(dirname($backup));ensure($parent&&strpos($parent,$root)!==0&&!file_exists($backup),'A new private backup path is required.');
  $f=fopen($backup,'x');ensure($f!==false,'Cannot create backup.');try{ensure(fwrite($f,js(['course'=>$course,'quizzes'=>$snapshot]))!==false,'Backup failed.');}finally{fclose($f);}chmod($backup,0600);
  ensure($db->execute('SELECT value FROM products_attribute WHERE id=:id',['id'=>$course['attribute_id']])->fetchColumn(0)===$course['value'],'Outline changed concurrently.');
  foreach($assets as $asset){
   $dest=$root.'/'.$asset['relative_path'];$dir=dirname($dest);
   if(!is_dir($dir))ensure(mkdir($dir,0755,true),'Cannot create image directory.');
   if(is_file($dest))ensure(hash_file('sha256',$dest)===$asset['sha256'],'Image file conflicts.');
   else{ensure(copy($asset['staged_path'],$dest),'Cannot publish image.');chmod($dest,0644);}
  }
  try{
   foreach($changes as $p){
    $id=$p['id'];$old=$snapshot[$id];
    $attempts=(int)$db->execute('SELECT COUNT(*) FROM quizs_answer WHERE quiz_id=:id',['id'=>$id])->fetchColumn(0);
    ensure($attempts===$old['attempts'],'Attempt count changed during import.');
    $saved=$db->execute('UPDATE quizs_attribute SET value=:v WHERE id=:id AND BINARY value=BINARY :old',['v'=>$p['value'],'id'=>$old['attribute']['id'],'old'=>$old['attribute']['value']]);
    ensure($saved->rowCount()===1||$old['attribute']['value']===$p['value'],'Question content changed concurrently.');$modified[$id]=true;
    $db->execute('UPDATE quizs_content SET name=:n,search_unicode=:n WHERE id=:id',['n'=>$p['name'],'id'=>$old['content']['id']]);
    $db->execute("INSERT INTO quiz_exam_metadata (quiz_id,source_system,source_exam_id,import_topic,source_quiz_type,curriculum_type,source_is_pro,question_count,source_question_count,source_hash,imported_at,staff_only) VALUES (:id,'meduc-lesson-json',:source,:topic,'TRAC_NGHIEM','lesson',:pro,20,20,:hash,NOW(),0) ON DUPLICATE KEY UPDATE source_system=VALUES(source_system),source_exam_id=VALUES(source_exam_id),import_topic=VALUES(import_topic),source_quiz_type=VALUES(source_quiz_type),curriculum_type=VALUES(curriculum_type),source_is_pro=VALUES(source_is_pro),question_count=20,source_question_count=20,source_hash=VALUES(source_hash),imported_at=VALUES(imported_at),staff_only=0",['id'=>$id,'source'=>(int)$course['id']*1000000+$p['lesson']*10+$p['slot'],'topic'=>$input['subject_code'],'pro'=>$p['slot']===2?1:0,'hash'=>$p['hash']]);
    $actual=QuizQuestions::load($id);ensure($actual&&count($actual['questions'])===20,'Player readback failed.');
    ensure($db->execute('SELECT value FROM quizs_attribute WHERE id=:id',['id'=>$old['attribute']['id']])->fetchColumn(0)===$p['value'],'Saved questions differ.');
   }
  }catch(\Throwable $e){
   foreach(array_keys($modified) as $id){
    $old=$snapshot[$id];$db->execute('UPDATE quizs_attribute SET value=:v WHERE id=:id',['v'=>$old['attribute']['value'],'id'=>$old['attribute']['id']]);
    $db->execute('UPDATE quizs_content SET name=:n,search_unicode=:s WHERE id=:id',['n'=>$old['content']['name'],'s'=>$old['content']['search_unicode'],'id'=>$old['content']['id']]);
    if($old['metadata']){ $meta=$old['metadata'];unset($meta['quiz_id']);$set=[];$params=['id'=>$id];foreach($meta as $key=>$v){$set[]='`'.$key.'`=:'.$key;$params[$key]=$v;}$db->execute('UPDATE quiz_exam_metadata SET '.implode(',',$set).' WHERE quiz_id=:id',$params); }
    else $db->execute('DELETE FROM quiz_exam_metadata WHERE quiz_id=:id',['id'=>$id]);
   }
   \Cake\Cache\Cache::clearAll();throw $e;
  }
  \Cake\Cache\Cache::clearAll();
 }
 $result=[];foreach($plans as $p)$result[]=['lesson'=>$p['lesson'],'exercise'=>$p['slot'],'quiz_id'=>$p['id'],'questions'=>20,'clinical'=>$p['clinical'],'action'=>$p['changed']?($mode==='apply'?'imported':'pending'):'unchanged'];
 echo js(['mode'=>$mode,'course_id'=>(int)$course['id'],'subject'=>$input['subject_code'],'total_questions'=>count($plans)*20,'changed_exercises'=>count($changes),'backup'=>$mode==='apply'&&$changes?$backup:null,'assets'=>count($assets),'exercises'=>$result]).PHP_EOL;
}finally{$db->execute('SELECT RELEASE_LOCK(:n)',['n'=>$lock]);}
