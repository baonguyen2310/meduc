<?php
declare(strict_types=1);
namespace App\Lib;

use InvalidArgumentException;

/** Metadata belongs to a lesson, independently of its quizzes and free/paid access. */
final class LessonMetadata
{
    public const OUTLINE_TYPES = ['unit'=>'Học phần', 'chapter'=>'Chương', 'lesson'=>'Bài học'];

    /** Older courses still use chapter_xx; học phần is optional. */
    public static function outlineType(array $item, string $lang = 'vi'): string
    {
        $kind = $item['outline_type'] ?? '';
        if (is_string($kind) && isset(self::OUTLINE_TYPES[$kind])) return $kind;
        return ($item['chapter_'.$lang] ?? '') === 'y' ? 'chapter' : 'lesson';
    }

    public static function isGroup(array $item, string $lang = 'vi'): bool
    {
        return self::outlineType($item, $lang) !== 'lesson';
    }

    public const TYPES = [
        'regular' => 'Bài thường',
        'midterm' => 'Giữa kỳ',
        'final' => 'Cuối kỳ',
        'practical' => 'Thực hành',
    ];

    public static function type(array $lesson): string
    {
        $type = $lesson['lesson_type'] ?? 'regular';
        return is_string($type) && isset(self::TYPES[$type]) ? $type : 'regular';
    }

    public static function isExam(array $lesson): bool
    {
        return !self::isGroup($lesson) && self::type($lesson) !== 'regular';
    }

    public static function label(array $lesson): string
    {
        return self::TYPES[self::type($lesson)];
    }

    public static function tags(array $lesson): array
    {
        $raw = $lesson['tags'] ?? [];
        if (is_string($raw)) $raw = preg_split('/[,;\r\n]+/u', $raw) ?: [];
        if (!is_array($raw)) return [];
        $tags = [];
        foreach ($raw as $tag) {
            if (!is_string($tag)) continue;
            $tag = trim(strip_tags($tag));
            if ($tag !== '') $tags[mb_strtolower($tag, 'UTF-8')] = $tag;
        }
        return array_values($tags);
    }

    public static function tagsText(array $lesson): string
    {
        return implode(', ', self::tags($lesson));
    }

    /** Used by the existing admin attribute save, including when all tags are cleared. */
    public static function normalize(array $lesson): array
    {
        foreach (array_keys($lesson) as $key) {
            if (strpos((string)$key, 'review_') === 0) unset($lesson[$key]);
        }
        $kind = $lesson['outline_type'] ?? '';
        if ($kind !== '' && (!is_string($kind) || !isset(self::OUTLINE_TYPES[$kind]))) {
            throw new InvalidArgumentException('Loại mục trong lộ trình không hợp lệ.');
        }
        $lesson['outline_type'] = self::outlineType($lesson);
        $lesson['chapter_vi'] = $lesson['outline_type'] === 'chapter' ? 'y' : 'n';
        if (self::isGroup($lesson)) {
            unset($lesson['lesson_type'], $lesson['tags']);
            return $lesson;
        }
        $type = $lesson['lesson_type'] ?? 'regular';
        if ($type === '' || $type === null) $type = 'regular';
        if (!is_string($type) || !isset(self::TYPES[$type])) {
            throw new InvalidArgumentException('Loại bài không hợp lệ.');
        }
        $lesson['lesson_type'] = $type;
        $lesson['tags'] = self::tags($lesson);
        return $lesson;
    }
}
