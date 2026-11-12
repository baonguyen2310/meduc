<?php
declare(strict_types=1);
namespace App\Service;

use App\Lib\LessonMetadata;
use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;
use Cake\Datasource\ConnectionManager;

/** Context shared by the admin notification and its contribution detail link. Never sends mail. */
final class CourseContributionMessage
{
    public static function lesson($outline, int $number, int $quizId, string $lang = 'vi'): array
    {
        $unit = $chapter = '';
        $index = 0;
        $selected = $matched = [];
        foreach (LessonQuizzes::lessons($outline) as $item) {
            $name = self::text($item['name_' . $lang] ?? '');
            if ($name === '') continue;
            $type = LessonMetadata::outlineType($item, $lang);
            if ($type === 'unit') { $unit = $name; $chapter = ''; continue; }
            if ($type === 'chapter') { $chapter = $name; continue; }
            $current = ['lesson_number' => ++$index, 'lesson_name' => $name, 'unit_name' => $unit, 'chapter_name' => $chapter];
            if ($index === $number) $selected = $current;
            foreach (LessonQuizzes::of($item, $lang) as $quiz) {
                // Resolve against the actual course outline, rather than trusting a posted lesson number.
                if ($quizId && $quiz['id'] === $quizId && (!$matched || $index === $number)) $matched = $current;
            }
        }
        return $quizId ? $matched : $selected;
    }

    public static function context(array $contribution, string $host = 'meduc.vn', string $lang = 'vi'): array
    {
        $productId = (int)($contribution['product_id'] ?? 0);
        $quizId = (int)($contribution['quiz_id'] ?? 0);
        $questionNumber = (int)($contribution['question_number'] ?? 0);
        $course = ConnectionManager::get('default')->execute(
            "SELECT p.deleted, pc.name, l.url, a.value AS lessons FROM products p
             LEFT JOIN products_content pc ON pc.product_id=p.id AND pc.lang=:content_lang
             LEFT JOIN links l ON l.foreign_id=p.id AND l.type='product_detail' AND l.lang=:link_lang AND l.deleted=0
             LEFT JOIN products_attribute a ON a.product_id=p.id AND a.attribute_id=11
             WHERE p.id=:id LIMIT 1", ['id' => $productId, 'content_lang' => $lang, 'link_lang' => $lang]
        )->fetch('assoc') ?: [];
        $context = self::lesson($course['lessons'] ?? null, (int)($contribution['lesson_number'] ?? 0), $quizId, $lang);
        $context['course_name'] = self::text($course['name'] ?? '') ?: 'Khóa #' . $productId;
        $context['quiz_name'] = '';
        $context['question_text'] = '';
        $context['options'] = [];
        $context['correct_answer'] = '';
        if ($quizId) {
            $quiz = QuizQuestions::load($quizId, $lang);
            $context['quiz_name'] = self::text($quiz['name'] ?? '') ?: 'Đề #' . $quizId;
            $question = $quiz['questions'][$questionNumber - 1] ?? [];
            $context['question_text'] = self::text($question['question'] ?? '');
            foreach ($question['options'] ?? [] as $option) {
                $label = (int)$option[0] <= 26 ? chr(64 + (int)$option[0]) : (string)$option[0];
                $context['options'][] = ['label' => $label, 'text' => self::text($option[1])];
                if ((int)$option[0] === (int)($question['answer'] ?? 0)) $context['correct_answer'] = $label;
            }
        }
        $origin = CommerceNotifications::origin($host);
        $context['admin_url'] = $origin . '/admin/course-contributions?id=' . (int)($contribution['id'] ?? 0)
            . '&status=all#contribution-' . (int)($contribution['id'] ?? 0);
        $context['course_admin_url'] = $origin . '/admin/product/update/' . $productId;
        $context['lesson_url'] = '';
        $slug = trim((string)($course['url'] ?? ''), '/');
        if ($slug !== '' && !preg_match('/[:?#\s]/u', $slug) && empty($course['deleted'])) {
            $context['lesson_url'] = $origin . '/' . $slug;
            if (!empty($context['lesson_number'])) {
                $params = ['bai' => $context['lesson_number']];
                if ($quizId) $params['tab'] = 'quiz';
                $context['lesson_url'] .= '?' . http_build_query($params, '', '&', PHP_QUERY_RFC3986);
            }
        }
        return $context;
    }

    public static function email(array $contribution, array $context): array
    {
        $id = (int)$contribution['id'];
        $question = (int)($contribution['question_number'] ?? 0);
        $labels = ['answer' => 'Góp ý đáp án / lời giải', 'exam' => 'Đóng góp đề', 'curriculum' => 'Góp ý lộ trình', 'general' => 'Góp ý khác'];
        $kind = $labels[$contribution['type'] ?? ''] ?? 'Đóng góp';
        $facts = ['Loại đóng góp' => $kind, 'Môn / Khóa học' => $context['course_name']];
        foreach (['Học phần' => 'unit_name', 'Chương' => 'chapter_name', 'Bài học' => 'lesson_name', 'Đề / Bài tập' => 'quiz_name'] as $label => $key) {
            if (!empty($context[$key])) $facts[$label] = $context[$key];
        }
        if (empty($context['lesson_name']) && !empty($contribution['lesson_number'])) $facts['Bài đã gửi'] = 'Bài số ' . (int)$contribution['lesson_number'];
        if ($question) $facts['Câu hỏi'] = 'Câu ' . $question;
        $rows = '';
        foreach ($facts as $label => $value) {
            $rows .= '<tr><td style="padding:10px 12px 10px 0;width:120px;color:#6b7280;border-bottom:1px solid #e5e7eb;vertical-align:top">'
                . self::escape($label) . '</td><td style="padding:10px 0;font-weight:600;border-bottom:1px solid #e5e7eb;overflow-wrap:anywhere">' . self::escape($value) . '</td></tr>';
        }
        $excerpt = '';
        if (!empty($context['question_text'])) {
            $excerpt = '<h2 style="font-size:16px;margin:24px 0 10px">Nội dung câu ' . $question . '</h2>'
                . '<div style="padding:16px;background:#f5f5f7;border-left:4px solid #6366f1;line-height:1.7">'
                . nl2br(self::escape(mb_strimwidth($context['question_text'], 0, 1200, '…', 'UTF-8'))) . '</div>';
        }
        $answer = trim((string)($contribution['suggested_answer'] ?? ''));
        if ($answer !== '') $excerpt .= '<p><strong>Đáp án / nội dung đề xuất:</strong> ' . self::escape($answer) . '</p>';
        $action = $question ? 'Xem câu hỏi và xử lý đóng góp' : 'Xem và xử lý đóng góp';
        $links = '<p style="margin:28px 0 16px"><a href="' . self::escape($context['admin_url'])
            . '" style="display:inline-block;padding:15px 22px;border-radius:8px;background:#de2334;color:#fff;text-decoration:none;font-weight:700">' . $action . '</a></p>';
        if (!empty($context['lesson_url'])) $links .= '<p><a href="' . self::escape($context['lesson_url']) . '" style="color:#4338ca">Mở bài học trên website →</a></p>';
        $subject = 'MedUC: đóng góp #' . $id . ' · ' . preg_replace('/\s+/u', ' ', $context['course_name']) . ($question ? ' · Câu ' . $question : '');
        return ['subject' => mb_substr($subject, 0, 200), 'content' => '<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head><body style="margin:0;padding:16px;background:#f5f5f7;font-family:Arial,sans-serif;color:#181a20">'
            . '<div style="max-width:620px;margin:16px auto;padding:28px;background:#fff;border:1px solid #e5e7eb;border-radius:14px;overflow-wrap:anywhere">'
            . '<p style="color:#de2334;font-size:12px;font-weight:700;letter-spacing:1px">MEDUC · ĐÓNG GÓP HỌC VIÊN</p>'
            . '<h1 style="font-size:24px;line-height:1.4">Đóng góp mới #' . $id . '</h1><table style="width:100%;border-collapse:collapse;font-size:14px;line-height:1.6">'
            . $rows . '</table>' . $excerpt . '<h2 style="font-size:16px;margin:24px 0 10px">Nội dung đóng góp</h2><div style="line-height:1.8">'
            . nl2br(self::escape($contribution['content'] ?? '')) . '</div>' . $links . '</div></body></html>'];
    }

    private static function text($value): string
    {
        $text = preg_replace('/<(?:br\s*\/?|\/p|\/div|\/li)>/i', "\n", (string)$value);
        return trim(html_entity_decode(strip_tags($text), ENT_QUOTES | ENT_HTML5, 'UTF-8'));
    }

    private static function escape($value): string
    {
        return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}
