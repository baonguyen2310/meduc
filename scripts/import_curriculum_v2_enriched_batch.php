<?php
/** Import enriched source exams and append lesson questions in groups of at most 40. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
$mode=$argv[1]??'plan';
if (!in_array($mode,['plan','apply','verify'],true)||empty($argv[2])) throw new RuntimeException('Usage: plan|apply|verify payload.json [backup.json.gz]');
require dirname(__DIR__).'/config_database.php';
$db=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USERNAME,DB_PASSWORD,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
function check($ok,string $msg):void{if(!$ok)throw new RuntimeException($msg);}
function sql(string $q,array $p=[]):PDOStatement{global $db;$s=$db->prepare($q);$s->execute($p);return $s;}
function enc($v):string{return json_encode($v,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);}
function dec(string $v):array{$a=json_decode($v,true,512,JSON_THROW_ON_ERROR);check(is_array($a),'Invalid JSON');return $a;}
function insert(string $table,array $row):int{global $db;$keys=array_keys($row);sql('INSERT INTO `'.$table.'` (`'.implode('`,`',$keys).'`) VALUES ('.implode(',',array_fill(0,count($keys),'?')).')',array_values($row));return(int)$db->lastInsertId();}
function update(string $table,int $id,array $row):void{$keys=array_keys($row);sql('UPDATE `'.$table.'` SET '.implode(',',array_map(fn($k)=>'`'.$k.'`=?',$keys)).' WHERE id=?',array_merge(array_values($row),[$id]));}
function attr(int $quiz):array{$r=sql('SELECT * FROM quizs_attribute WHERE quiz_id=? AND attribute_id=18',[$quiz])->fetch();check((bool)$r,'Missing questions '.$quiz);return $r;}
function linksOf(array $lesson):array{if(!empty($lesson['quizzes_vi']))return is_array($lesson['quizzes_vi'])?$lesson['quizzes_vi']:dec($lesson['quizzes_vi']);return empty($lesson['quiz_id_vi'])?[]:[['id'=>(int)$lesson['quiz_id_vi'],'free'=>$lesson['trial_vi']??'n']];}
function sameQuestion(array $a,array $b):bool{unset($a['code'],$b['code']);return $a==$b;}
function createQuiz(string $name,array $questions,array $metadata,string $url):int{
 global $newIds;
 $now=time();$id=insert('quizs',['status'=>0,'draft'=>1,'deleted'=>0,'created'=>$now,'updated'=>$now,'created_by'=>1,'position'=>1]);$newIds[]=$id;
 insert('quizs_content',['quiz_id'=>$id,'name'=>$name,'search_unicode'=>$name,'lang'=>'vi']);
 insert('quizs_attribute',['quiz_id'=>$id,'attribute_id'=>18,'value'=>enc($questions)]);
 insert('quizs_attribute',['quiz_id'=>$id,'attribute_id'=>19,'value'=>'60']);
 unset($metadata['quiz_id'],$metadata['updated_at']);
 $metadata['quiz_id']=$id;$metadata['question_count']=count($questions);$metadata['source_question_count']=count($questions);
 $metadata['imported_at']=date('Y-m-d H:i:s');$metadata['staff_only']=0;
 insert('quiz_exam_metadata',$metadata);
 insert('links',['foreign_id'=>$id,'type'=>'quiz_detail','url'=>$url,'lang'=>'vi','created'=>$now,'updated'=>$now,'deleted'=>0]);
 return $id;
}
$p=dec(file_get_contents($argv[2]));$subject=$p['subject_code']??'';
check((bool)preg_match('/^MV2-S\d{3}$/D',$subject),'Invalid subject');
check(!empty($p['exams']),'Empty exam batch');
$examIds=array_map(fn($e)=>(int)$e['metadata']['id'],$p['exams']);
check(count(array_unique($examIds))===count($examIds)&&min($examIds)>0,'Duplicate/invalid exams');
$lock='meduc_enriched_batch_'.$subject;
check((int)sql('SELECT GET_LOCK(?,0)',[$lock])->fetchColumn()===1,'Another batch is running');
$backup=null;$newIds=[];$backupPath=$argv[3]??'';$writing=false;
try{
 $course=sql('SELECT cv.product_id,pa.id,pa.value FROM curriculum_v2_courses cv JOIN products_attribute pa ON pa.product_id=cv.product_id AND pa.attribute_id=11 WHERE cv.subject_code=?',[$subject])->fetch();
 check((bool)$course,'Missing course');$outline=dec($course['value']);$byCode=[];
 foreach($outline as $i=>$l)$byCode[$l['code']]=$i;
 $reviewCode=$p['review_lesson_code'];check(isset($byCode[$reviewCode]),'Missing review lesson');$ri=$byCode[$reviewCode];
 $reviewLinks=linksOf($outline[$ri]);$originalReviewLinks=$reviewLinks;
 check(count($reviewLinks)>0,'Missing original review links');
 $all=[];$byLesson=[];$existing=[];$total=0;$newReviews=0;
 foreach($p['exams'] as $exam){
  $m=$exam['metadata'];$eid=(int)$m['id'];check(count($exam['questions'])===(int)$m['total_questions'],'Exam count differs');
  $existing[$eid]=sql("SELECT * FROM quiz_exam_metadata WHERE source_system='meduc-source-v2' AND source_exam_id=?",[$eid])->fetch();
  if($existing[$eid]){
   check($existing[$eid]['source_hash']===$exam['source_hash'],'Existing source hash differs');
   check(dec(attr((int)$existing[$eid]['quiz_id'])['value'])===$exam['questions'],'Existing review differs');
   check(in_array((int)$existing[$eid]['quiz_id'],array_map(fn($l)=>(int)$l['id'],$reviewLinks),true),'Review link missing');
  }else $newReviews++;
  foreach($exam['questions'] as $i=>$q){
   $sid=(int)$q['source_question_id'];check(!isset($all[$sid]),'Duplicate source question');$all[$sid]=$q;$total++;
   check((int)$q['source_exam_id']===$eid&&(int)$q['source_question_order']===$i+1,'Source order differs');
   check($q['ai_subject_code']===$subject,'Subject differs');
   check(count($q['options'])===4&&count(array_filter($q['options'],fn($o)=>!empty($o['is_correct'])))===1,'Invalid original choices');
   $key=(int)$q['answer_vi'];check($key>=1&&$key<=4&&!empty($q['options'][$key-1]['is_correct']),'Original key differs');
   check(trim($q['ai_general_explanation'])!==''&&in_array($q['difficulty_level'],['easy','medium','upper_medium','hard'],true),'Incomplete enrichment');
   foreach($q['options'] as $o)check(trim($o['ai_explanation'])!=='','Missing option explanation');
   foreach($q['images']??[] as $image)check(is_array($image)&&(bool)preg_match('/^[a-f0-9]{64}$/D',(string)($image['url_hash']??'')),'Invalid media reference');
   $code=$q['ai_lesson_code'];
   if($code){check(isset($byCode[$code])&&($outline[$byCode[$code]]['review_vi']??'n')!=='y','Lesson outside course');$byLesson[$code][]=$q;}
   else check($q['ai_lesson_match']==='none','Invalid lesson match');
  }
 }
 check($total===(int)$p['processing']['question_count'],'Payload count differs');
 $practice=[];$snapAttr=[];$snapMeta=[];$newExercises=0;$mapped=0;
 foreach($byLesson as $code=>$questions){
  $idx=$byCode[$code];$lesson=$outline[$idx];$links=linksOf($lesson);check(count($links)>0,'Missing first exercise');
  $slots=[];$known=[];$template=null;
  foreach($links as $link){
   $id=(int)$link['id'];$a=attr($id);$old=dec($a['value']);
   $meta=sql("SELECT * FROM quiz_exam_metadata WHERE quiz_id=? AND source_system='curriculum-v2-lesson'",[$id])->fetch();
   check((bool)$meta&&count($old)<=40,'Invalid existing lesson exercise');
   if($template===null)$template=$meta;
   foreach($old as $q){$sid=(int)$q['source_question_id'];check(!isset($known[$sid]),'Existing duplicate lesson question');$known[$sid]=$q;}
   $slots[]=['id'=>$id,'attr'=>$a,'meta'=>$meta,'questions'=>$old,'free'=>$link['free']??'n','changed'=>false];
   $snapAttr[]=$a;$snapMeta[]=$meta;
  }
  foreach($questions as $q){
   $sid=(int)$q['source_question_id'];$mapped++;
   if(isset($known[$sid])){check(sameQuestion($known[$sid],$q),'Existing lesson content differs');continue;}
   $target=null;foreach($slots as $k=>$slot)if(count($slot['questions'])<40){$target=$k;break;}
   if($target===null){$target=count($slots);$slots[]=['id'=>null,'attr'=>null,'meta'=>$template,'questions'=>[],'free'=>'n','changed'=>true];$newExercises++;}
   $q['code']='source_'.$sid;$slots[$target]['questions'][]=$q;$slots[$target]['changed']=true;$known[$sid]=$q;
  }
  $practice[$code]=['index'=>$idx,'slots'=>$slots,'template'=>$template];
 }
 $summary=['mode'=>$mode,'product_id'=>(int)$course['product_id'],'source_exams'=>$examIds,'questions'=>$total,'options'=>$total*4,'mapped'=>$mapped,'review_only'=>$total-$mapped,'lessons'=>count($practice),'new_review_exams'=>$newReviews,'new_lesson_exercises'=>$newExercises,'practice_counts'=>array_map(fn($r)=>array_map(fn($s)=>count($s['questions']),$r['slots']),$practice)];
 if($mode==='plan'){echo enc($summary).PHP_EOL;exit;}
 if($mode==='apply'){
  check($backupPath!==''&&!file_exists($backupPath),'A new backup file is required');
  $parent=realpath(dirname($backupPath));$root=realpath(dirname(__DIR__));check($parent&&strpos($parent,$root)!==0,'Backup must be outside web root');
  $backup=['course'=>$course,'quizs_attribute'=>$snapAttr,'quiz_exam_metadata'=>$snapMeta,'payload_sha256'=>hash_file('sha256',$argv[2])];
  check(file_put_contents($backupPath,gzencode(enc($backup),6))!==false,'Cannot write backup');chmod($backupPath,0600);
  check(sql('SELECT value FROM products_attribute WHERE id=?',[$course['id']])->fetchColumn()===$course['value'],'Course changed during plan');
  foreach($snapAttr as $a)check(sql('SELECT value FROM quizs_attribute WHERE id=?',[$a['id']])->fetchColumn()===$a['value'],'Exercise changed during plan');
  $writing=true;
  foreach($p['exams'] as $exam){
   $m=$exam['metadata'];$eid=(int)$m['id'];if($existing[$eid])continue;
   preg_match('/(?<!\d)(19\d\d|20\d\d)(?!\d)/',$m['name'],$year);
   $meta=['source_system'=>'meduc-source-v2','source_exam_id'=>$eid,'source_remote_id'=>$m['remote_id'],'source_category_id'=>$m['category_id'],'source_category_name'=>$m['source_category_name'],'import_topic'=>'Sinh học - Di truyền','school_name'=>$m['school_name'],'year_in_title'=>isset($year[1])?(int)$year[1]:null,'source_quiz_type'=>$m['quiz_type'],'curriculum_type'=>'subject','source_is_pro'=>$m['is_pro'],'source_hash'=>$exam['source_hash']];
   $id=createQuiz($m['name'],$exam['questions'],$meta,'de-tong-on-mv2-'.$eid);
   $reviewLinks[]=['id'=>$id,'free'=>'n'];$existing[$eid]=['quiz_id'=>$id];
  }
  foreach($practice as $code=>&$plan){
   $links=[];preg_match('/-L(\d+)$/',$code,$number);$lessonNumber=(int)$number[1];
   foreach($plan['slots'] as $k=>&$slot){
    $hash=hash('sha256',enc(array_column($slot['questions'],'source_question_id')));
    if($slot['id']===null){
     $meta=$slot['meta'];$meta['source_exam_id']=1000000000000+(int)$course['product_id']*100000+$lessonNumber*100+$k+1;$meta['source_hash']=$hash;
     $name='Bài tập '.($k+1).' · '.$outline[$plan['index']]['name_vi'];
     $slot['id']=createQuiz($name,$slot['questions'],$meta,'bai-tap-'.strtolower($code).'-'.($k+1));
    }elseif($slot['changed']){
     update('quizs_attribute',(int)$slot['attr']['id'],['value'=>enc($slot['questions'])]);
     sql('UPDATE quiz_exam_metadata SET question_count=?,source_question_count=?,source_hash=?,staff_only=0 WHERE quiz_id=?',[count($slot['questions']),count($slot['questions']),$hash,$slot['id']]);
    }
    $links[]=['id'=>(int)$slot['id'],'free'=>$slot['free']];
   }unset($slot);
   $outline[$plan['index']]['quizzes_vi']=enc($links);
  }unset($plan);
  $outline[$ri]['quizzes_vi']=enc($reviewLinks);update('products_attribute',(int)$course['id'],['value'=>enc($outline)]);
 }
 foreach($p['exams'] as $exam){$id=(int)$existing[(int)$exam['metadata']['id']]['quiz_id'];check(dec(attr($id)['value'])===$exam['questions'],'Review readback differs');}
 foreach($practice as $plan)foreach($plan['slots'] as $slot){check($slot['id']!==null,'Missing lesson exercise');$saved=dec(attr((int)$slot['id'])['value']);check($saved===$slot['questions']&&count($saved)<=40,'Exercise readback differs');}
 $saved=dec(sql('SELECT value FROM products_attribute WHERE id=?',[$course['id']])->fetchColumn());$savedReview=linksOf($saved[$ri]);
 check(array_slice($savedReview,0,count($originalReviewLinks))===$originalReviewLinks,'Original review/free links changed');
 check(count($savedReview)===count($originalReviewLinks)+$newReviews,'Review link count differs');
 foreach($practice as $code=>$plan){$expected=array_map(fn($s)=>(int)$s['id'],$plan['slots']);$actual=array_map(fn($l)=>(int)$l['id'],linksOf($saved[$plan['index']]));check($expected===$actual,'Lesson exercise link differs');}
 $summary['review_quizzes']=array_map(fn($l)=>(int)$l['id'],$savedReview);$summary['new_quiz_ids']=$newIds;$summary['backup']=$backupPath;
 echo enc($summary).PHP_EOL;
}catch(Throwable $e){
 if($writing&&$backup!==null){
  foreach($backup['quizs_attribute'] as $r){$id=(int)$r['id'];unset($r['id']);update('quizs_attribute',$id,$r);}
  foreach($backup['quiz_exam_metadata'] as $r){$id=(int)$r['quiz_id'];unset($r['quiz_id']);$keys=array_keys($r);sql('UPDATE quiz_exam_metadata SET '.implode(',',array_map(fn($k)=>'`'.$k.'`=?',$keys)).' WHERE quiz_id=?',array_merge(array_values($r),[$id]));}
  update('products_attribute',(int)$course['id'],['value'=>$course['value']]);
  foreach($newIds as $id){sql("DELETE FROM links WHERE foreign_id=? AND type='quiz_detail'",[$id]);foreach(['quizs_attribute','quizs_content','quiz_exam_metadata'] as $t)sql('DELETE FROM '.$t.' WHERE quiz_id=?',[$id]);sql('DELETE FROM quizs WHERE id=?',[$id]);}
 }
 fwrite(STDERR,'ERROR: '.$e->getMessage().PHP_EOL);exit(1);
}finally{sql('SELECT RELEASE_LOCK(?)',[$lock]);}
