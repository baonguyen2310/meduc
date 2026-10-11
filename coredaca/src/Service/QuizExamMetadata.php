<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Datasource\ConnectionManager;
use InvalidArgumentException;

/** Source and catalog information for an imported quiz exam. */
class QuizExamMetadata
{
    private const TEXT_LIMITS = [
        'source_category_name' => 500,
        'import_topic' => 180,
        'school_name' => 180,
        'source_quiz_type' => 50,
    ];

    public static function forQuiz(int $quizId): array
    {
        if ($quizId < 1) {
            return [];
        }
        $row = ConnectionManager::get('default')->execute(
            'SELECT * FROM quiz_exam_metadata WHERE quiz_id = :quiz_id',
            ['quiz_id' => $quizId]
        )->fetch('assoc');
        return $row ?: [];
    }

    /** Empty metadata on an ordinary quiz returns null. */
    public static function normalize(array $input, bool $alreadyExists = false): ?array
    {
        foreach ($input as $value) {
            if ($value !== null && !is_scalar($value)) {
                throw new InvalidArgumentException('Thông tin nguồn đề không hợp lệ.');
            }
        }
        $sourceId = trim((string)($input['source_exam_id'] ?? ''));
        $otherInput = $input;
        unset($otherInput['source_system'], $otherInput['source_exam_id']);
        $hasOtherValue = (bool)array_filter($otherInput, static function ($value): bool {
            return $value !== null && trim((string)$value) !== '';
        });
        if ($sourceId === '') {
            if ($alreadyExists || $hasOtherValue) {
                throw new InvalidArgumentException('Cần nhập ID đề gốc khi điền thông tin nguồn đề.');
            }
            return null;
        }
        $parsedSourceId = filter_var($sourceId, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        if ($parsedSourceId === false) {
            throw new InvalidArgumentException('ID đề gốc phải là số nguyên dương.');
        }

        $system = strtolower(trim((string)($input['source_system'] ?? 'facourse')));
        if (!preg_match('/^[a-z0-9_-]{1,32}$/', $system)) {
            throw new InvalidArgumentException('Tên nguồn đề không hợp lệ.');
        }

        $result = [
            'source_system' => $system,
            'source_exam_id' => $parsedSourceId,
            'source_category_id' => self::optionalPositiveInt($input['source_category_id'] ?? null, 'ID danh mục gốc'),
            'year_in_title' => self::optionalPositiveInt($input['year_in_title'] ?? null, 'Năm trong tên đề'),
            'source_question_count' => self::optionalNonNegativeInt($input['source_question_count'] ?? null, 'Số câu nguồn'),
        ];
        if ($result['year_in_title'] !== null && ($result['year_in_title'] < 1900 || $result['year_in_title'] > 2100)) {
            throw new InvalidArgumentException('Năm trong tên đề phải nằm trong khoảng 1900–2100.');
        }

        foreach (self::TEXT_LIMITS as $field => $limit) {
            $value = trim((string)($input[$field] ?? ''));
            if (mb_strlen($value, 'UTF-8') > $limit) {
                throw new InvalidArgumentException('Thông tin nguồn đề vượt quá độ dài cho phép.');
            }
            $result[$field] = $value === '' ? null : $value;
        }

        $curriculumType = trim((string)($input['curriculum_type'] ?? ''));
        if ($curriculumType !== '' && !in_array($curriculumType, ['subject', 'module'], true)) {
            throw new InvalidArgumentException('Loại môn/module không hợp lệ.');
        }
        $result['curriculum_type'] = $curriculumType === '' ? null : $curriculumType;

        $pro = $input['source_is_pro'] ?? '';
        if ($pro !== '' && $pro !== null && (string)$pro !== '0' && (string)$pro !== '1') {
            throw new InvalidArgumentException('Trạng thái Pro của đề gốc không hợp lệ.');
        }
        $result['source_is_pro'] = $pro === '' || $pro === null ? null : (int)$pro;
        return $result;
    }

    public static function save(int $quizId, array $metadata): void
    {
        $db = ConnectionManager::get('default');
        self::assertAvailable($quizId, $metadata);

        $values = array_merge(['quiz_id' => $quizId], $metadata);
        if (self::forQuiz($quizId)) {
            $assignments = [];
            foreach (array_keys($metadata) as $field) {
                $assignments[] = $field . ' = :' . $field;
            }
            $db->execute(
                'UPDATE quiz_exam_metadata SET ' . implode(', ', $assignments) . ' WHERE quiz_id = :quiz_id',
                $values
            );
            return;
        }

        $fields = array_keys($values);
        $placeholders = array_map(static function ($field): string { return ':' . $field; }, $fields);
        $db->execute(
            'INSERT INTO quiz_exam_metadata (' . implode(', ', $fields) . ') VALUES (' . implode(', ', $placeholders) . ')',
            $values
        );
    }

    public static function assertAvailable(int $quizId, array $metadata): void
    {
        $db = ConnectionManager::get('default');
        $duplicate = $db->execute(
            'SELECT quiz_id FROM quiz_exam_metadata WHERE source_system = :system AND source_exam_id = :source_id',
            ['system' => $metadata['source_system'], 'source_id' => $metadata['source_exam_id']]
        )->fetch('assoc');
        if ($duplicate && (int)$duplicate['quiz_id'] !== $quizId) {
            throw new InvalidArgumentException('ID đề gốc này đã được gắn với một bài tập khác.');
        }
    }

    public static function refreshQuestionCount(int $quizId): void
    {
        $db = ConnectionManager::get('default');
        $row = $db->execute(
            'SELECT value FROM quizs_attribute WHERE quiz_id = :quiz_id AND attribute_id = 18 LIMIT 1',
            ['quiz_id' => $quizId]
        )->fetch('assoc');
        $questions = $row ? json_decode((string)$row['value'], true) : [];
        $count = is_array($questions) ? count($questions) : null;
        $db->execute(
            'UPDATE quiz_exam_metadata SET question_count = :count WHERE quiz_id = :quiz_id',
            ['count' => $count, 'quiz_id' => $quizId]
        );
    }

    private static function optionalPositiveInt($value, string $label): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }
        $parsed = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        if ($parsed === false) {
            throw new InvalidArgumentException($label . ' phải là số nguyên dương.');
        }
        return $parsed;
    }

    private static function optionalNonNegativeInt($value, string $label): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }
        $parsed = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 0]]);
        if ($parsed === false) {
            throw new InvalidArgumentException($label . ' phải là số nguyên không âm.');
        }
        return $parsed;
    }
}
