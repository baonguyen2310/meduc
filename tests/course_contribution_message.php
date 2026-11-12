<?php
/** Read-only, synthetic fixtures. This script does not configure or call any email transport. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
require dirname(__DIR__) . '/coredaca/vendor/autoload.php';

use App\Service\CourseContributionMessage as Message;

function contributionExpect($condition, string $message): void
{
    if (!$condition) throw new RuntimeException($message);
}

$outline = [
    ['name_vi' => 'Học phần 1', 'outline_type' => 'unit'],
    ['name_vi' => 'Chương chi trên', 'chapter_vi' => 'y'],
    ['name_vi' => 'Bài nhập môn', 'quiz_id_vi' => 70],
    ['name_vi' => '', 'quiz_id_vi' => 99],
    ['name_vi' => 'Xương bàn tay', 'quizzes_vi' => '[{"id":71,"free":"y"},{"id":72,"free":"n"}]'],
    ['name_vi' => 'Học phần 2', 'outline_type' => 'unit'],
    ['name_vi' => 'Bài tổng hợp', 'quiz_id_vi' => 71],
];
$lesson = Message::lesson(json_encode($outline), 99, 72);
contributionExpect($lesson === ['lesson_number' => 2, 'lesson_name' => 'Xương bàn tay', 'unit_name' => 'Học phần 1', 'chapter_name' => 'Chương chi trên'], 'Quiz must resolve to its actual lesson; headings and empty rows are not lessons.');
contributionExpect(Message::lesson($outline, 3, 71)['lesson_number'] === 3, 'A repeated legacy quiz should use the matching submitted lesson.');
contributionExpect(Message::lesson($outline, 3, 0)['chapter_name'] === '', 'New units must not inherit the previous chapter.');
contributionExpect(Message::lesson($outline, 2, 999) === [], 'Detached quizzes must not link to an unrelated lesson.');
contributionExpect(Message::lesson(null, 1, 0) === [], 'Missing legacy outlines must be supported.');

$row = ['id' => 4, 'product_id' => 436, 'lesson_number' => 2, 'quiz_id' => 72,
    'question_number' => 1, 'type' => 'answer', 'suggested_answer' => 'B',
    'content' => 'Mong lời giải rõ hơn. <script>alert(1)</script>'];
$context = $lesson + ['course_name' => "Giải phẫu học\r\n", 'quiz_name' => 'Bài tập 1 · Xương bàn tay',
    'question_text' => 'Bàn tay có bao nhiêu xương? <img src=x onerror=alert(1)>',
    'admin_url' => 'https://meduc.vn/admin/course-contributions?id=4&status=all#contribution-4',
    'lesson_url' => 'https://meduc.vn/trac-nghiem-giai-phau-hoc-v1?bai=2&tab=quiz'];
$mail = Message::email($row, $context);
contributionExpect(strpos($mail['subject'], 'Giải phẫu học') !== false && strpos($mail['subject'], 'Câu 1') !== false, 'Subject must identify course and question.');
contributionExpect(strpbrk($mail['subject'], "\r\n") === false, 'Subject must be a single line.');
foreach (['Học phần 1', 'Chương chi trên', 'Xương bàn tay', 'Bài tập 1', 'Bàn tay có bao nhiêu xương?', 'Đáp án / nội dung đề xuất:'] as $text) {
    contributionExpect(strpos($mail['content'], $text) !== false, 'Missing email context: ' . $text);
}
$dom = new DOMDocument();
libxml_use_internal_errors(true);
$dom->loadHTML($mail['content']);
libxml_clear_errors();
contributionExpect($dom->getElementsByTagName('script')->length === 0 && $dom->getElementsByTagName('img')->length === 0, 'Submitted HTML must remain text in the email.');
$hrefs = [];
foreach ($dom->getElementsByTagName('a') as $anchor) $hrefs[] = $anchor->getAttribute('href');
contributionExpect($hrefs === [$context['admin_url'], $context['lesson_url']], 'Both links must preserve their query strings and direct contribution anchor.');
contributionExpect(strpos($mail['content'], 'status=all') !== false, 'Reviewed contributions must remain accessible from older emails.');

foreach (['curriculum', 'exam', 'general'] as $type) {
    $row['type'] = $type; $row['question_number'] = 0; $row['suggested_answer'] = null;
    $courseOnly = ['course_name' => 'Sinh lý học', 'admin_url' => $context['admin_url'], 'lesson_url' => ''];
    $message = Message::email($row, $courseOnly);
    contributionExpect(strpos($message['content'], 'Xem và xử lý đóng góp') !== false, 'Course-level contributions need a working admin action.');
    contributionExpect(strpos($message['content'], 'Nội dung câu') === false && strpos($message['content'], 'href=""') === false, 'Do not invent a question or empty URL for course-level contributions.');
}

if (!defined('ADMIN_PATH')) define('ADMIN_PATH', '/admin');
$compileDir = sys_get_temp_dir() . '/meduc-contribution-' . bin2hex(random_bytes(8));
mkdir($compileDir, 0700);
try {
    $smarty = new Smarty();
    $smarty->setCompileDir($compileDir);
    $smarty->assign('this', new class {
        public function getRequest() { return new Cake\Http\ServerRequest(); }
    });
    $row = ['id' => 4, 'product_id' => 436, 'lesson_number' => 2, 'quiz_id' => 72, 'question_number' => 1,
        'type' => 'answer', 'status' => 'new', 'created' => 1700000000, 'full_name' => 'Học viên kiểm thử',
        'customer_code' => 'FIXTURE', 'email' => 'fixture@example.invalid', 'files' => [], 'admin_note' => '',
        'suggested_answer' => 'B', 'content' => 'Đề nghị giải thích thêm.',
        'context' => $context + ['options' => [['label' => 'B', 'text' => 'Tám xương']], 'correct_answer' => 'B']];
    foreach (['rows' => [$row], 'status' => 'all', 'type' => 'all', 'page' => 1, 'pages' => 1, 'total' => 1] as $key => $value) $smarty->assign($key, $value);
    $admin = $smarty->fetch(dirname(__DIR__) . '/coredaca/plugins/Admin/templates/CourseContribution/index.tpl');
    foreach (['contribution-4', 'Xương bàn tay', 'Tám xương', 'Đáp án hiện tại:', 'bai=2&amp;tab=quiz'] as $text) {
        contributionExpect(strpos($admin, $text) !== false, 'Admin link destination is missing its question context: ' . $text);
    }
} finally {
    foreach (glob($compileDir . '/*') ?: [] as $file) unlink($file);
    rmdir($compileDir);
}
echo json_encode(['passed' => ['canonical_lesson_and_headings', 'repeated_quiz', 'missing_outline', 'email_context', 'escaped_content', 'direct_links', 'all_contribution_types', 'admin_template_rendered'], 'external_email_sent' => false, 'database_writes' => false], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n";
