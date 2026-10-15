<?php
declare(strict_types=1);
namespace App\Lib;

/** Quizzes of one lesson in a course's "Danh sách tiết học" (product attribute danhsachtiethoc).
 *
 * A lesson keeps its quizzes in quizzes_vi, a JSON string like files and filestwo:
 *   [{"id": 75, "free": "y"}, {"id": 76, "free": "n"}]
 * in the order the admin set. "free" = y: anyone may take it (a sample quiz); otherwise only students of the course.
 * Lessons saved before the list existed have one quiz in quiz_id_vi, free when the lesson is "Bài học thử" (trial_vi).
 * The admin lesson editor still writes the first quiz to quiz_id_vi for readers that know only one quiz.
 */
final class LessonQuizzes
{
    /** [['id' => int, 'free' => bool], ...] for one lesson; chapters have none. */
    public static function of($lesson, string $lang = 'vi'): array
    {
        if (!is_array($lesson) || ($lesson['chapter_' . $lang] ?? null) === 'y') return [];

        $list = $lesson['quizzes_' . $lang] ?? null;
        if (is_string($list) && trim($list) !== '') $list = json_decode($list, true);
        if (is_array($list)) {
            $result = [];
            foreach ($list as $entry) {
                $id = self::id(is_array($entry) ? ($entry['id'] ?? null) : $entry);
                if ($id && !isset($result[$id])) {
                    $result[$id] = ['id' => $id, 'free' => is_array($entry) && ($entry['free'] ?? null) === 'y'];
                }
            }
            return array_values($result);
        }

        $id = self::id($lesson['quiz_id_' . $lang] ?? null);
        return $id ? [['id' => $id, 'free' => ($lesson['trial_' . $lang] ?? null) === 'y']] : [];
    }

    /** Every quiz id of a course's lessons, first appearance first; $freeOnly keeps the sample quizzes only. */
    public static function ids($lessons, bool $freeOnly = false, string $lang = 'vi'): array
    {
        $ids = [];
        foreach ((array)$lessons as $lesson) {
            foreach (self::of($lesson, $lang) as $quiz) {
                if (!$freeOnly || $quiz['free']) $ids[$quiz['id']] = $quiz['id'];
            }
        }
        return array_values($ids);
    }

    /** Lessons of a course from the raw attribute value (a JSON list, or already decoded). */
    public static function lessons($value): array
    {
        if (is_string($value)) $value = json_decode($value, true);
        return is_array($value) ? array_values(array_filter($value, 'is_array')) : [];
    }

    /** A quiz id typed by hand ("616 ", "40"), or 0. */
    private static function id($value): int
    {
        $value = is_scalar($value) ? trim((string)$value) : '';
        return $value !== '' && ctype_digit($value) ? (int)$value : 0;
    }
}
