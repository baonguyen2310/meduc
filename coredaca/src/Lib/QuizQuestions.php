<?php
declare(strict_types=1);
namespace App\Lib;

use Cake\Datasource\ConnectionManager;

/** Questions of a quiz as the course quiz player shows them (assets/meduc-v2/classroom-quiz.js).
 *
 * A quiz keeps its questions in attribute 18 (danhsachcauhoi): a JSON list with name_vi, description_vi,
 * option_one_vi … option_five_vi, answer_vi (1-5), answer_detail_vi and a code. Exams imported from MedUC Cao
 * (scripts/import_private_exams.php) also have "options" ([{content, is_correct}], sometimes more than five) and
 * "images" ([{url_hash}], served by the MedUC Cao media API); those are used when present.
 * Codes are missing or repeated in many old quizzes, so the player and the server both number the questions by their
 * place in this list, keeping only those with a question and at least one answer. The text loses the Word formatting
 * pasted into it (style, class, span…).
 */
final class QuizQuestions
{
    const QUESTIONS_ATTRIBUTE = 18; // attributes.code = danhsachcauhoi
    const MINUTES_ATTRIBUTE = 19; // attributes.code = thoigianlambai
    const OPTION_KEYS = ['option_one', 'option_two', 'option_three', 'option_four', 'option_five'];

    /** One quiz for the player: ['id', 'name', 'minutes', 'questions' => fromValue()], or null when it has no questions
     *  or is missing, deleted or kept for staff (quiz_exam_metadata.staff_only). */
    public static function load(int $quizId, string $lang = 'vi'): ?array
    {
        $row = ConnectionManager::get('default')->execute(
            "SELECT q.id, c.name, questions.value AS questions, minutes.value AS minutes
             FROM quizs q
             LEFT JOIN quizs_content c ON c.quiz_id = q.id AND c.lang = :lang
             JOIN quizs_attribute questions ON questions.quiz_id = q.id AND questions.attribute_id = :questions
             LEFT JOIN quizs_attribute minutes ON minutes.quiz_id = q.id AND minutes.attribute_id = :minutes
             WHERE q.id = :id AND q.deleted = 0 AND q.fa_only = 0
               AND NOT EXISTS (SELECT 1 FROM quiz_exam_metadata m WHERE m.quiz_id = q.id AND m.staff_only = 1)
             LIMIT 1",
            ['id' => $quizId, 'lang' => $lang, 'questions' => self::QUESTIONS_ATTRIBUTE, 'minutes' => self::MINUTES_ATTRIBUTE]
        )->fetch('assoc');
        if (!$row) return null;
        $questions = self::fromValue((string)$row['questions'], $lang);
        if (!$questions) return null;
        return ['id' => (int)$row['id'], 'name' => trim((string)$row['name']), 'minutes' => (int)$row['minutes'], 'questions' => $questions];
    }

    /** [['code', 'question', 'note', 'options' => [[value, text]], 'answer', 'explain'], ...] */
    public static function fromValue($value, string $lang = 'vi'): array
    {
        $items = is_string($value) ? json_decode($value, true) : $value;
        if (!is_array($items)) return [];

        $questions = [];
        foreach ($items as $item) {
            if (!is_array($item) || trim((string)($item['name_' . $lang] ?? '')) === '') continue;
            $options = [];
            $answer = (int)($item['answer_' . $lang] ?? 0);
            if (!empty($item['options']) && is_array($item['options'])) {
                foreach (array_values($item['options']) as $index => $option) {
                    $text = self::clean(is_array($option) ? ($option['content'] ?? '') : '');
                    if ($text !== '') $options[] = [$index + 1, $text];
                    if (!$answer && is_array($option) && !empty($option['is_correct'])) $answer = $index + 1;
                }
            } else {
                foreach (self::OPTION_KEYS as $index => $key) {
                    $text = self::clean($item[$key . '_' . $lang] ?? '');
                    if ($text !== '') $options[] = [$index + 1, $text];
                }
            }
            if (!$options) continue;
            $question = [
                'code' => (string)($item['code'] ?? ''),
                'question' => self::clean($item['name_' . $lang]) . self::images($item['images'] ?? []),
                'note' => self::clean($item['description_' . $lang] ?? ''),
                'options' => $options,
                'answer' => $answer,
                'explain' => QuizExplanation::render($item['answer_detail_' . $lang] ?? ''),
                'explanation_parts' => self::explanationParts($item),
            ];
            // Bind self-assessment to the displayed question, including repeated legacy codes.
            $question['key'] = hash('sha256', json_encode([$question['code'], $question['question'], $question['options']], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE));
            $questions[] = $question;
        }
        return $questions;
    }

    /** AI explanations are separate from the original answer and explanation. Keep the source answer authoritative. */
    public static function explanationParts(array $item): ?array
    {
        $options = $item['options'] ?? null;
        if (!is_array($options) || !$options) return null;
        $answer = (int)($item['answer_vi'] ?? 0);
        $parts = [];
        foreach (array_values($options) as $index => $option) {
            if (!is_array($option)) return null;
            $reason = self::plainText($option['ai_explanation'] ?? '');
            if ($reason === '') return null;
            $parts[] = [
                'key' => (string)($option['key'] ?? chr(65 + $index)),
                'correct' => $answer > 0 ? $answer === $index + 1 : !empty($option['is_correct']),
                'reason' => $reason,
                'reason_html' => QuizExplanation::render($option['ai_explanation'] ?? ''),
            ];
        }
        return [
            'concept' => self::plainText($item['ai_general_explanation'] ?? ''),
            'concept_html' => QuizExplanation::render($item['ai_general_explanation'] ?? ''),
            'source' => self::plainText($item['source_explanation'] ?? ''),
            'source_html' => QuizExplanation::render($item['source_explanation'] ?? ''),
            'options' => $parts,
        ];
    }

    private static function plainText($value): string
    {
        $text = str_replace(["\r\n", "\r"], "\n", (string)$value);
        $text = preg_replace('/<br\s*\/?\s*>/i', "\n", $text);
        $text = preg_replace('/<\/(?:p|div|li|h[1-6])\s*>/i', "\n\n", $text);
        return trim(html_entity_decode(strip_tags($text), ENT_QUOTES | ENT_HTML5, 'UTF-8'));
    }

    /** Pictures of an imported question, from the MedUC Cao media API (as the admin exam library shows them). */
    private static function images($images): string
    {
        $html = '';
        foreach ((array)$images as $image) {
            $hash = is_array($image) ? (string)($image['url_hash'] ?? '') : '';
            if (preg_match('/^[a-f0-9]{64}$/D', $hash)) $html .= '<p><img src="https://meduc.duckdns.org/api/media/' . $hash . '" alt="" loading="lazy"></p>';
        }
        return $html;
    }

    /** Text pasted from Word, without its comments, inline formatting and font tags. */
    public static function clean($html): string
    {
        $html = (string)$html;
        $html = preg_replace('/<!--[\s\S]*?-->/', '', $html);
        $html = preg_replace('/\s(?:style|class|lang|face|size|align|dir)=(?:"[^"]*"|\'[^\']*\')/i', '', $html);
        $html = preg_replace('/<\/?(?:o:p|font|span)\b[^>]*>/i', '', $html);
        return trim(preg_replace('/\s+/u', ' ', $html));
    }
}
