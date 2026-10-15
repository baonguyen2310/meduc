<?php
declare(strict_types=1);
namespace App\Lib;

/** Questions of a quiz as the course quiz player shows them (assets/meduc-v2/classroom-quiz.js).
 *
 * A quiz keeps its questions in attribute 18 (danhsachcauhoi): a JSON list with name_vi, description_vi,
 * option_one_vi … option_five_vi, answer_vi (1-5), answer_detail_vi and a code. Codes are missing or repeated in many
 * old quizzes, so the player and the server both number the questions by their place in this list, keeping only those
 * with a question and at least one answer. The text loses the Word formatting pasted into it (style, class, span…).
 */
final class QuizQuestions
{
    const QUESTIONS_ATTRIBUTE = 18; // attributes.code = danhsachcauhoi
    const MINUTES_ATTRIBUTE = 19; // attributes.code = thoigianlambai
    const OPTION_KEYS = ['option_one', 'option_two', 'option_three', 'option_four', 'option_five'];

    /** [['code', 'question', 'note', 'options' => [[value, text]], 'answer', 'explain'], ...] */
    public static function fromValue($value, string $lang = 'vi'): array
    {
        $items = is_string($value) ? json_decode($value, true) : $value;
        if (!is_array($items)) return [];

        $questions = [];
        foreach ($items as $item) {
            if (!is_array($item) || trim((string)($item['name_' . $lang] ?? '')) === '') continue;
            $options = [];
            foreach (self::OPTION_KEYS as $index => $key) {
                $text = self::clean($item[$key . '_' . $lang] ?? '');
                if ($text !== '') $options[] = [$index + 1, $text];
            }
            if (!$options) continue;
            $questions[] = [
                'code' => (string)($item['code'] ?? ''),
                'question' => self::clean($item['name_' . $lang]),
                'note' => self::clean($item['description_' . $lang] ?? ''),
                'options' => $options,
                'answer' => (int)($item['answer_' . $lang] ?? 0),
                'explain' => self::clean($item['answer_detail_' . $lang] ?? ''),
            ];
        }
        return $questions;
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
