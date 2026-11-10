<?php
/** Metadata round trips must not erase imported questions, original answers or explanations. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
$app = new App\Application($root . '/coredaca/config');
$app->bootstrap();
if (!defined('LANGUAGE')) define('LANGUAGE', 'vi');
if (!defined('LANGUAGE_ADMIN')) define('LANGUAGE_ADMIN', 'vi');
if (!defined('ADMIN_PATH')) define('ADMIN_PATH', '/admin');
if (!defined('CDN_URL')) define('CDN_URL', '/cdn');

use App\Lib\QuestionMetadata;
use App\Lib\QuizQuestions;

function expectQuestion($ok, string $message): void
{
    if (!$ok) throw new RuntimeException($message);
}
foreach (QuestionMetadata::LEGACY_LEVELS as $before => $after) {
    expectQuestion(QuestionMetadata::normalize(['difficulty_level' => $before])['difficulty_level'] === $after, 'Legacy level mapping failed.');
}
foreach (array_keys(QuestionMetadata::CATEGORIES) as $category) {
    expectQuestion(QuestionMetadata::normalize(['question_category' => $category])['question_category'] === $category, 'Category rejected.');
}
foreach (['question_category', 'difficulty_level'] as $field) {
    expectQuestion(QuestionMetadata::normalize([$field => ''])[$field] === null, 'Cannot clear metadata.');
    foreach (['invalid', ['theory']] as $invalid) {
        try {
            QuestionMetadata::normalize([$field => $invalid]);
            throw new RuntimeException('Invalid metadata accepted.');
        } catch (InvalidArgumentException $expected) {}
    }
}
$original = [
    'code' => 'source_1', 'question_type' => 'MULTIPLE_CHOICE', 'name_vi' => 'Câu hỏi mẫu',
    'option_one_vi' => 'A', 'option_two_vi' => 'B', 'answer_vi' => '2',
    'answer_detail_vi' => 'Lời giải gốc', 'source_question_id' => 101, 'source_exam_id' => 23,
    'source_question_order' => 4, 'source_explanation' => 'Giải thích gốc',
    'images' => [['url_hash' => str_repeat('a', 64)]], 'ai_general_explanation' => 'Khái niệm',
    'difficulty_level' => 'medium',
    'options' => [
        ['content' => 'A', 'is_correct' => false, 'ai_explanation' => 'Sai vì A'],
        ['content' => 'B', 'is_correct' => true, 'ai_explanation' => 'Đúng vì B'],
    ],
];
$posted = ['code' => 'source_1', '_question_index' => '0', 'question_category' => 'clinical', 'difficulty_level' => 'application'];
$saved = QuestionMetadata::forSave([$posted], [$original])[0];
foreach ($original as $key => $value) {
    if ($key !== 'difficulty_level') expectQuestion($saved[$key] === $value, 'Imported data changed: ' . $key);
}
expectQuestion($saved['question_category'] === 'clinical' && $saved['difficulty_level'] === 'application', 'New fields not saved.');
expectQuestion(!isset($saved['_question_index']), 'Editor position leaked into stored question.');
$reordered = QuestionMetadata::forSave([
    ['code' => '', '_question_index' => '1', 'question_category' => 'image'],
    ['code' => '', '_question_index' => '0', 'question_category' => 'theory'],
], [['code' => '', 'source_question_id' => 1], ['code' => '', 'source_question_id' => 2]]);
expectQuestion(array_column($reordered, 'source_question_id') === [2, 1], 'Reorder lost identity of questions with missing codes.');
$edited = QuestionMetadata::forSave([$posted + ['option_one_vi' => 'A sửa', 'answer_vi' => '1']], [$original])[0];
expectQuestion($edited['options'][0]['content'] === 'A sửa' && $edited['options'][0]['is_correct'] && !$edited['options'][1]['is_correct'], 'Edited MCQ choices are out of sync.');
expectQuestion($edited['options'][0]['ai_explanation'] === 'Sai vì A', 'Choice metadata erased.');
$staff = QuestionMetadata::forSave([$posted + ['answer_vi' => '1', 'options' => []]], [$original], true)[0];
expectQuestion($staff['answer_vi'] === '2' && $staff['options'] === $original['options'], 'Original exam answer changed.');
expectQuestion(QuestionMetadata::forSave([], [$original], true) === [$original], 'Omitted protected questions were removed.');
$player = QuizQuestions::fromValue([$saved])[0];
expectQuestion($player['question_category'] === 'clinical' && $player['difficulty_level'] === 'application', 'Player lost metadata.');
expectQuestion($player['key'] === QuizQuestions::fromValue([$original])[0]['key'], 'Metadata changed history/confidence identity.');

class QuestionMetadataView extends App\View\SmartyView
{
    public $helpers = ['Admin.AttributeAdmin'];
    public function question(array $question, bool $metadataOnly): string
    {
        return $this->_render(SOURCE_DOMAIN . '/coredaca/plugins/Admin/templates/element/attribute/album_quiz_item.tpl', [
            'album' => $question, 'languages' => ['vi' => 'Tiếng Việt'], 'index' => 0,
            'metadata_only' => $metadataOnly, 'code' => 'danhsachcauhoi',
            'required' => false, 'filemanager_access_key' => '',
        ]);
    }
}
$view = new QuestionMetadataView();
foreach ([false, true] as $metadataOnly) {
    $html = $view->question($saved, $metadataOnly);
    foreach (array_merge(QuestionMetadata::CATEGORIES, QuestionMetadata::LEVELS) as $label) expectQuestion(strpos($html, $label) !== false, 'Missing option: ' . $label);
    expectQuestion((bool)preg_match('/value="clinical"\s+selected/', $html), 'Saved category not selected.');
    expectQuestion((bool)preg_match('/value="application"\s+selected/', $html), 'Saved level not selected.');
    expectQuestion((strpos($html, 'data-name="answer_vi"') === false) === $metadataOnly, 'Protected answer editor exposed.');
    expectQuestion(strpos($html, 'input-attribute="album_quiz"') !== false, 'Question field names will not be initialized by the Admin form manager.');
}
echo "Question categories, levels, source preservation, MCQ editing, player identity and Admin form checks passed.\n";
