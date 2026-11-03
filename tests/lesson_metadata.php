<?php
declare(strict_types=1);
require dirname(__DIR__).'/coredaca/src/Lib/LessonMetadata.php';
use App\Lib\LessonMetadata;

function expect($condition, string $message): void {
    if (!$condition) throw new RuntimeException($message);
}
foreach (['regular'=>false, 'midterm'=>true, 'final'=>true, 'practical'=>true] as $type=>$exam) {
    expect(LessonMetadata::isExam(['lesson_type'=>$type]) === $exam, 'Incorrect quiz mode: '.$type);
}
expect(!LessonMetadata::isExam(['review_vi'=>'y']), 'Legacy flag must not control quiz mode.');
$original = ['name_vi'=>'Bài 1', 'code'=>'L1', 'quiz_id_vi'=>'15', 'files'=>'["video.mp4"]', 'trial_vi'=>'y'];
$lesson = LessonMetadata::normalize($original + ['lesson_type'=>'midterm', 'tags'=>"Quan trọng, Cần ôn lại; quan trọng\n", 'review_vi'=>'y']);
foreach ($original as $key=>$value) expect($lesson[$key] === $value, 'Existing content changed: '.$key);
expect(!isset($lesson['review_vi']), 'Legacy flag was retained.');
expect(count($lesson['tags']) === 2, 'Tags must split, trim and deduplicate.');
expect(LessonMetadata::normalize(['tags'=>''])['tags'] === [], 'Clearing tags must save an empty list.');
expect(LessonMetadata::normalize(['lesson_type'=>''])['lesson_type'] === 'regular', 'New cloned lesson must default to regular.');
$chapter = LessonMetadata::normalize(['chapter_vi'=>'y', 'lesson_type'=>'final', 'tags'=>['X'], 'review_vi'=>'n']);
expect($chapter === ['chapter_vi'=>'y'], 'Chapters must not become exam lessons.');
try {
    LessonMetadata::normalize(['lesson_type'=>'invalid']);
    throw new RuntimeException('Invalid type was accepted.');
} catch (InvalidArgumentException $expected) {}
echo "Lesson type, quiz mode, tags and preservation checks passed.\n";
