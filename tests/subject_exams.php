<?php
/** Regression checks for multi-exam lessons and ungraded, image-based short-answer study. */
declare(strict_types=1);
$root = getenv('MEDUC_APP_ROOT') ?: dirname(__DIR__);
require $root.'/coredaca/vendor/autoload.php';
function expectExam($ok, string $message): void { if (!$ok) throw new RuntimeException($message); }
use App\Lib\QuizQuestions;
use App\Service\CourseTypes;
$rows=[]; for ($i=1;$i<=90;$i++) $rows[]=['id'=>$i,'free'=>$i===1?'y':'n'];
$lesson=['code'=>'final','lesson_type'=>'final','quizzes_vi'=>json_encode($rows)];
$exams=CourseTypes::quizzes($lesson,'quiz');
expectExam(count($exams)===90 && $exams[0]['free'] && !$exams[1]['free'] && $exams[89]['id']===90,'Final exams truncated or paid access changed.');
foreach (['midterm','practical'] as $type) expectExam(count(CourseTypes::quizzes(array_merge($lesson,['lesson_type'=>$type]),'quiz'))===90,'Exam lesson truncated: '.$type);
$regular=CourseTypes::quizzes(array_merge($lesson,['lesson_type'=>'regular']),'quiz');
expectExam(count($regular)===2 && $regular[0]['free'] && !$regular[1]['free'],'Regular free/paid pair changed.');
$sample=['code'=>'TH-01','name_vi'=>'Gọi tên cấu trúc số 3.','description_vi'=>'<p><img src="/cdn/media/lesson-exercises/test.png" alt="Hình"></p>',
 'question_type'=>'TULUAN','options'=>[],'answer_vi'=>'Thần kinh trụ','answer_detail_vi'=>'**Đáp án:** Thần kinh trụ.','question_category'=>'image','difficulty_level'=>'recognition'];
$parsed=QuizQuestions::fromValue([$sample]);
expectExam(count($parsed)===1 && $parsed[0]['read_only']===true && $parsed[0]['options']===[] && $parsed[0]['answer']===0,'Short-answer practical dropped or became graded.');
expectExam(strpos($parsed[0]['answer_text'],'Thần kinh trụ')!==false && strpos($parsed[0]['note'],'test.png')!==false && strpos($parsed[0]['explain'],'<strong>')!==false,'Practical image, answer or Markdown lost.');
expectExam($parsed[0]['metadata_labels']['question_category']==='Hình ảnh','Practical labels lost.');
expectExam(QuizQuestions::fromValue([array_merge($sample,['answer_vi'=>'3 đốt'])])[0]['answer']===0,'Numeric short answer became an MCQ answer key.');
expectExam(QuizQuestions::fromValue([['name_vi'=>'An empty MCQ draft','question_type'=>'MULTIPLE_CHOICE']])===[],'Incomplete MCQ became playable.');
$mcq=['code'=>'Q1','name_vi'=>'Choose B','question_type'=>'MULTIPLE_CHOICE','answer_vi'=>'2','option_one_vi'=>'A','option_two_vi'=>'B'];
$q=QuizQuestions::fromValue([$mcq])[0];
expectExam(!$q['read_only'] && $q['answer']===2 && count($q['options'])===2,'MCQ marking contract changed.');
expectExam($q['key']===hash('sha256',json_encode([$q['code'],$q['question'],$q['options']],JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_INVALID_UTF8_SUBSTITUTE)),'Existing attempt identity changed.');
echo "Multi-exam access, regular pairs, practical image/answer rendering and MCQ identity passed.\n";
