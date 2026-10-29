<?php
if (PHP_SAPI !== 'cli') exit;
$root=rtrim($argv[1]??'/var/www/html','/');
define('SOURCE_DOMAIN',$root); require $root.'/config_database.php'; require $root.'/coredaca/vendor/autoload.php'; require $root.'/coredaca/config/bootstrap.php';
use App\Service\CourseTypes;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
function ok($v,$m){if(!$v)throw new RuntimeException($m);echo "PASS $m\n";}
$db=ConnectionManager::get('default');
ok((int)$db->execute("SELECT COUNT(*) FROM products WHERE course_kind='fa'")->fetchColumn(0)===108,'108 Fa courses');
ok(TableRegistry::get('Products')->find()->where(['Products.course_kind'=>'fa'])->count()===0,'Public ORM hides Fa');
ok(App\Lib\QuizQuestions::load(2715)===null,'Fa question loader rejects source exam');
$controller=new App\Controller\QuizsAnswerController(new Cake\Http\ServerRequest());
$component=new App\Controller\Component\QuizAnswerComponent(new Cake\Controller\ComponentRegistry($controller));
ok(!$component->courseQuizAccess([],316,2715)['found'],'Fa course endpoint denied');
$db->begin();
try {
 $db->execute("INSERT INTO products(course_kind,status,deleted,draft,main_category_id)VALUES('quiz',1,0,0,125)");$pid=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
 $lessons=[['name_vi'=>'Chương kiểm thử','chapter_vi'=>'y'],['name_vi'=>'Bài A','code'=>'test-a'],['name_vi'=>'Bài B','code'=>'test-b']];
 $db->execute('INSERT INTO products_attribute(product_id,attribute_id,value)VALUES(:p,11,:v)',['p'=>$pid,'v'=>json_encode($lessons)]);
 CourseTypes::syncLessons($pid);
 $slots=$db->execute('SELECT * FROM course_quiz_slots WHERE product_id=:p ORDER BY lesson_code,slot',['p'=>$pid])->fetchAll('assoc');
 ok(count($slots)===4,'Two quiz slots per lesson');CourseTypes::syncLessons($pid);
 ok($slots===$db->execute('SELECT * FROM course_quiz_slots WHERE product_id=:p ORDER BY lesson_code,slot',['p'=>$pid])->fetchAll('assoc'),'Saving again keeps quiz IDs');
 $first=(int)$slots[0]['quiz_id'];$second=(int)$slots[1]['quiz_id'];
 ok(!$component->courseQuizAccess([],$pid,$first)['found'],'Empty trial cannot start');
 $questions=[];for($i=0;$i<30;$i++)$questions[]=['name_vi'=>'Test '.($i+1),'option_one_vi'=>'Một','option_two_vi'=>'Hai','answer_vi'=>'1'];
 $db->execute('UPDATE quizs_attribute SET value=:v WHERE quiz_id IN (:first,:second) AND attribute_id=18',['v'=>json_encode($questions),'first'=>$first,'second'=>$second]);
 ok($component->courseQuizAccess([],$pid,$first)['allowed'],'30-question first quiz is free');
 ok(!$component->courseQuizAccess([],$pid,$second)['allowed'],'Second quiz denied before purchase');
 $grade=new ReflectionMethod($component,'gradeAnswers'); $grade->setAccessible(true);
 $score=$grade->invoke($component,$first,[['index'=>0,'answer'=>1],['index'=>1,'answer'=>2]]);
 ok($score['answer_total']===30 && $score['answer_correct']===1,'Server grades course questions independently of submitted score');
 $memberId=(int)$db->execute("SELECT customer_id FROM customers_account WHERE username='user_test_01'")->fetchColumn(0);
 ok((bool)TableRegistry::get('CourseEnrollments')->enroll($memberId,$pid,['source'=>'admin']),'Enrollment uses existing course payment entitlement');
 ok($component->courseQuizAccess(['id'=>$memberId],$pid,$second)['allowed'],'Purchased course unlocks second quiz');
 $otherSecond=(int)$slots[3]['quiz_id'];
 $db->execute('UPDATE quizs_attribute SET value=:v WHERE quiz_id=:id AND attribute_id=18',['v'=>json_encode($questions),'id'=>$otherSecond]);
 ok($component->courseQuizAccess(['id'=>$memberId],$pid,$otherSecond)['allowed'],'One purchase unlocks the second quiz in another lesson');
 ok(!TableRegistry::get('CourseEnrollments')->enroll($memberId,316),'Fa cannot be enrolled');
 ok(TableRegistry::get('Quizs')->find()->where(['Quizs.id'=>$second])->count()===0,'Paid quiz hidden from standalone public queries');
 array_pop($questions);$db->execute('UPDATE quizs_attribute SET value=:v WHERE quiz_id=:id AND attribute_id=18',['v'=>json_encode($questions),'id'=>$first]);
 ok(!$component->courseQuizAccess([],$pid,$first)['found'],'Incomplete 29-question trial is unavailable');
 $db->execute("UPDATE products SET course_kind='knowledge' WHERE id=:id",['id'=>$pid]);
 ok(!$component->courseQuizAccess(['id'=>$memberId],$pid,$second)['found'],'Video-only course rejects exercises even for enrolled users');
 CourseTypes::syncLessons($pid);
 ok(TableRegistry::get('Quizs')->find()->where(['Quizs.id'=>$second])->count()===0,'Detached course quizzes remain private');
}finally{$db->rollback();}
$data=['exam'=>['id'=>1,'name'=>'Test'], 'questions'=>[['content'=>'FIRST_QUESTION','options'=>[['key'=>'A','content'=>'YES','is_correct'=>true]],'explanation'=>'FIRST_ANSWER'],['content'=>'SECOND_QUESTION','options'=>[['key'=>'A','content'=>'YES','is_correct'=>true]],'explanation'=>'SECOND_ANSWER']]];
foreach(['inline','end'] as $mode){$path=(new App\Service\ExamWordExporter)->create($data,static function(){return null;},$mode);$z=new ZipArchive;$z->open($path);$xml=$z->getFromName('word/document.xml');$z->close();unlink($path);ok(($mode==='inline')===(strpos($xml,'FIRST_ANSWER')<strpos($xml,'SECOND_QUESTION')),'Word answer placement '.$mode);}
echo "All fixtures rolled back.\n";
