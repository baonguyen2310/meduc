<?php
/** Import reviewed question enrichment into the live curriculum without modifying source answers. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
$mode=$argv[1]??'plan';
if (!in_array($mode,['plan','apply','verify'],true) || empty($argv[2])) throw new RuntimeException('Usage: plan|apply|verify payload.json [backup.json.gz]');
require dirname(__DIR__).'/config_database.php';
$db=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USERNAME,DB_PASSWORD,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
function check($ok,string $msg):void {if(!$ok)throw new RuntimeException($msg);}
function sql(string $q,array $p=[]):PDOStatement {global $db;$s=$db->prepare($q);$s->execute($p);return $s;}
function enc($x):string{return json_encode($x,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);}
function dec(string $x):array{$v=json_decode($x,true,512,JSON_THROW_ON_ERROR);check(is_array($v),'Expected JSON array');return $v;}
function insert(string $t,array $r):int{global $db;$keys=array_keys($r);sql('INSERT INTO `'.$t.'` (`'.implode('`,`',$keys).'`) VALUES ('.implode(',',array_fill(0,count($r),'?')).')',array_values($r));return (int)$db->lastInsertId();}
function update(string $t,int $id,array $r):void{$keys=array_keys($r);sql('UPDATE `'.$t.'` SET '.implode(',',array_map(fn($k)=>'`'.$k.'`=?',$keys)).' WHERE id=?',array_merge(array_values($r),[$id]));}
function attr(int $id):array{$r=sql('SELECT * FROM quizs_attribute WHERE quiz_id=? AND attribute_id=18',[$id])->fetch();check((bool)$r,'Missing quiz questions '.$id);return $r;}
function linksOf(array $l):array{if(!empty($l['quizzes_vi']))return is_array($l['quizzes_vi'])?$l['quizzes_vi']:dec($l['quizzes_vi']);return empty($l['quiz_id_vi'])?[]:[['id'=>(int)$l['quiz_id_vi'],'free'=>($l['trial_vi']??'n')]];}
function sameSource(array $old,array $new):bool{return $old['name_vi']===$new['name_vi'] && (string)$old['answer_vi']===(string)$new['answer_vi'] && array_map(fn($o)=>[$o['id'],$o['content'],$o['is_correct']],$old['options'])===array_map(fn($o)=>[$o['id'],$o['content'],$o['is_correct']],$new['options']);}
$p=dec(file_get_contents($argv[2]));
check(($p['subject_code']??'')==='MV2-S001','Unexpected subject');
check(count($p['exams'])===4,'Expected four source exams');
check((int)sql("SELECT GET_LOCK('meduc_curriculum_subject1_batch',0)")->fetchColumn()===1,'Another batch is running');
$newIds=[];$backup=null;$backupPath=$argv[3]??'';
try{
 $course=sql("SELECT cv.product_id,pa.id,pa.value FROM curriculum_v2_courses cv JOIN products_attribute pa ON pa.product_id=cv.product_id AND pa.attribute_id=11 WHERE cv.subject_code=?",[$p['subject_code']])->fetch();
 check((bool)$course,'Missing course');$outline=dec($course['value']);$byCode=[];
 foreach($outline as $i=>$l)$byCode[$l['code']]=$i;
 check(isset($byCode[$p['review_lesson_code']]),'Missing review lesson');$ri=$byCode[$p['review_lesson_code']];
 $reviewLinks=linksOf($outline[$ri]);check((int)($reviewLinks[0]['id']??0)===2715 && ($reviewLinks[0]['free']??'n')==='y','Existing free review changed');
 $allQ=[];$newByLesson=[];$existingReviews=[];$total=0;$originalKeys=[];
 foreach($p['exams'] as $exam){
  $m=$exam['metadata'];$eid=(int)$m['id'];check(in_array($eid,[2432,2437,2438,2439],true),'Unexpected source exam');
  check(count($exam['questions'])===(int)$m['total_questions'],'Exam count mismatch');
  $existingReviews[$eid]=sql("SELECT * FROM quiz_exam_metadata WHERE source_system='meduc-source-v2' AND source_exam_id=?",[$eid])->fetch();
  if($existingReviews[$eid]){
   $old=$existingReviews[$eid];check($old['source_hash']===$exam['source_hash'],'Existing source hash changed');
   check(dec(attr((int)$old['quiz_id'])['value'])===$exam['questions'],'Existing exam differs');
   check(in_array((int)$old['quiz_id'],array_map(fn($r)=>(int)$r['id'],$reviewLinks),true),'Imported exam missing from review');
  }
  foreach($exam['questions'] as $j=>$q){
   $qid=(int)$q['source_question_id'];check(!isset($allQ[$qid]),'Duplicate source ID');$allQ[$qid]=$q;$total++;
   check((int)$q['source_exam_id']===$eid && (int)$q['source_question_order']===$j+1,'Source order differs');
   check(count($q['options'])===4 && count(array_filter($q['options'],fn($o)=>$o['is_correct']))===1,'Invalid answer structure');
   $key=(int)$q['answer_vi'];check($key>=1 && $key<=4 && $q['options'][$key-1]['is_correct'],'Answer differs from original option');
   check(trim($q['ai_general_explanation'])!=='' && in_array($q['difficulty_level'],['easy','medium','upper_medium','hard'],true),'Incomplete enrichment');
   foreach($q['options'] as $o)check(trim($o['ai_explanation'])!=='','Missing option explanation');
   $code=$q['ai_lesson_code'];
   if($code){check(isset($byCode[$code]) && ($outline[$byCode[$code]]['review_vi']??'n')!=='y','Lesson outside course');$newByLesson[$code][]=$q;}
   else check($q['ai_lesson_match']==='none','Missing lesson match state');
   $originalKeys[$qid]=$key;
  }
 }
 check($total===251 && count($allQ)===251,'Unexpected batch size');
 $practice=[];$snapAttr=[];$snapMeta=[];
 foreach($newByLesson as $code=>$questions){
  $i=$byCode[$code];$l=$outline[$i];$qid=(int)$l['quiz_id_vi'];
  check($qid>0 && count(linksOf($l))===1,'Expected first lesson exercise only');
  $a=attr($qid);$m=sql("SELECT * FROM quiz_exam_metadata WHERE quiz_id=? AND source_system='curriculum-v2-lesson'",[$qid])->fetch();
  check((bool)$m,'Missing lesson metadata');$old=dec($a['value']);$combined=$old;$existing=[];
  foreach($old as $q)$existing[(int)$q['source_question_id']]=$q;
  foreach($questions as $q){$sid=(int)$q['source_question_id'];if(isset($existing[$sid]))check(sameSource($existing[$sid],$q),'Existing lesson question differs');else{$q['code']='source_'.$sid;$combined[]=$q;$existing[$sid]=$q;}}
  check(count($combined)<=40,'Lesson exceeds 40; requires another exercise: '.$code);
  $practice[$code]=['quiz_id'=>$qid,'attr_id'=>(int)$a['id'],'questions'=>$combined,'old_count'=>count($old),'new_count'=>count($combined),'source_id'=>(int)$m['source_exam_id']];
  $snapAttr[]=$a;$snapMeta[]=$m;
 }
 $summary=['mode'=>$mode,'product_id'=>(int)$course['product_id'],'source_exams'=>array_map(fn($e)=>(int)$e['metadata']['id'],$p['exams']),'questions'=>$total,'options'=>$total*4,'mapped'=>array_sum(array_map('count',$newByLesson)),'review_only'=>$total-array_sum(array_map('count',$newByLesson)),'lessons'=>count($practice),'existing_reviews'=>count(array_filter($existingReviews))];
 if($mode==='plan'){echo enc($summary).PHP_EOL;exit;}
 if($mode==='apply'){
  check($backupPath!=='' && !is_file($backupPath),'A new backup path outside web root is required');
  $parent=realpath(dirname($backupPath));$root=realpath(dirname(__DIR__));check($parent && strpos($parent,$root)!==0,'Backup must be outside web root');
  $backup=['products_attribute'=>$course,'quizs_attribute'=>$snapAttr,'quiz_exam_metadata'=>$snapMeta,'payload_sha256'=>hash_file('sha256',$argv[2])];
  check(file_put_contents($backupPath,gzencode(enc($backup),6))!==false,'Cannot save backup');chmod($backupPath,0600);
  check(sql('SELECT value FROM products_attribute WHERE id=?',[$course['id']])->fetchColumn()===$course['value'],'Course changed during preflight');
  $now=time();
  foreach($p['exams'] as $exam){
   $m=$exam['metadata'];$eid=(int)$m['id'];
   if($existingReviews[$eid])continue;
   $id=insert('quizs',['status'=>0,'draft'=>1,'deleted'=>0,'created'=>$now,'updated'=>$now,'created_by'=>1,'position'=>1]);$newIds[]=$id;
   insert('quizs_content',['quiz_id'=>$id,'name'=>$m['name'],'search_unicode'=>$m['name'],'lang'=>'vi']);
   insert('quizs_attribute',['quiz_id'=>$id,'attribute_id'=>18,'value'=>enc($exam['questions'])]);
   insert('quizs_attribute',['quiz_id'=>$id,'attribute_id'=>19,'value'=>(string)($m['duration_minutes']?:60)]);
   preg_match('/(?<!\d)(19\d\d|20\d\d)(?!\d)/',$m['name'],$year);
   insert('quiz_exam_metadata',['quiz_id'=>$id,'source_system'=>'meduc-source-v2','source_exam_id'=>$eid,'source_remote_id'=>$m['remote_id'],'source_category_id'=>$m['category_id'],'source_category_name'=>$m['source_category_name'],'import_topic'=>'Sinh học - Di truyền','school_name'=>$m['school_name'],'year_in_title'=>isset($year[1])?(int)$year[1]:null,'source_quiz_type'=>$m['quiz_type'],'curriculum_type'=>'subject','source_is_pro'=>$m['is_pro'],'question_count'=>count($exam['questions']),'source_question_count'=>count($exam['questions']),'source_hash'=>$exam['source_hash'],'imported_at'=>date('Y-m-d H:i:s'),'staff_only'=>0]);
   insert('links',['foreign_id'=>$id,'type'=>'quiz_detail','url'=>'de-tong-on-mv2-'.$eid,'lang'=>'vi','created'=>$now,'updated'=>$now,'deleted'=>0]);
   $reviewLinks[]=['id'=>$id,'free'=>'n'];$existingReviews[$eid]=['quiz_id'=>$id];
  }
  foreach($practice as $r){
   update('quizs_attribute',$r['attr_id'],['value'=>enc($r['questions'])]);
   sql('UPDATE quiz_exam_metadata SET question_count=?,source_question_count=?,staff_only=0,source_hash=? WHERE quiz_id=?',[$r['new_count'],$r['new_count'],hash('sha256',enc(array_column($r['questions'],'source_question_id'))),$r['quiz_id']]);
  }
  $outline[$ri]['quizzes_vi']=enc($reviewLinks);
  update('products_attribute',(int)$course['id'],['value'=>enc($outline)]);
 }
 foreach($p['exams'] as $exam){
  $eid=(int)$exam['metadata']['id'];$id=(int)$existingReviews[$eid]['quiz_id'];
  $stored=dec(attr($id)['value']);check($stored===$exam['questions'],'Readback exam mismatch '.$eid);
  foreach($stored as $q)check($originalKeys[(int)$q['source_question_id']]===(int)$q['answer_vi'],'Readback answer changed');
 }
 foreach($practice as $r)check(dec(attr($r['quiz_id'])['value'])===$r['questions'],'Readback exercise mismatch');
 $saved=dec(sql('SELECT value FROM products_attribute WHERE id=?',[$course['id']])->fetchColumn());$savedReview=linksOf($saved[$ri]);
 check(count($savedReview)===5 && (int)$savedReview[0]['id']===2715 && $savedReview[0]['free']==='y','Review/free link verification failed');
 $summary['review_quizzes']=array_map(fn($r)=>(int)$r['id'],$savedReview);
 $summary['practice_counts']=array_map(fn($r)=>$r['new_count'],$practice);
 $summary['new_quiz_ids']=$newIds;$summary['backup']=$backupPath;
 echo enc($summary).PHP_EOL;
}catch(Throwable $e){
 if($backup!==null){
  foreach($backup['quizs_attribute'] as $r){$id=(int)$r['id'];unset($r['id']);update('quizs_attribute',$id,$r);}
  foreach($backup['quiz_exam_metadata'] as $r){$id=(int)$r['quiz_id'];unset($r['quiz_id']);$keys=array_keys($r);sql('UPDATE quiz_exam_metadata SET '.implode(',',array_map(fn($k)=>'`'.$k.'`=?',$keys)).' WHERE quiz_id=?',array_merge(array_values($r),[$id]));}
  update('products_attribute',(int)$course['id'],['value'=>$course['value']]);
  foreach($newIds as $id){sql("DELETE FROM links WHERE foreign_id=? AND type='quiz_detail'",[$id]);foreach(['quizs_attribute','quizs_content','quiz_exam_metadata'] as $t)sql('DELETE FROM '.$t.' WHERE quiz_id=?',[$id]);sql('DELETE FROM quizs WHERE id=?',[$id]);}
 }
 fwrite(STDERR,'ERROR: '.$e->getMessage().PHP_EOL);exit(1);
}finally{sql("SELECT RELEASE_LOCK('meduc_curriculum_subject1_batch')");}
