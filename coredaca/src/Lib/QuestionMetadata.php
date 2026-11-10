<?php
declare(strict_types=1);
namespace App\Lib;

/** Content classification is independent of the answer format (MCQ, essay, etc.). */
final class QuestionMetadata
{
    const CATEGORIES = [
        'theory' => 'Lý thuyết',
        'calculation' => 'Tính toán',
        'image' => 'Hình ảnh',
        'clinical' => 'Lâm sàng',
    ];
    const LEVELS = [
        'recognition' => 'Nhận biết',
        'understanding' => 'Thông hiểu',
        'application' => 'Vận dụng',
    ];
    const LEGACY_LEVELS = [
        'easy' => 'recognition',
        'medium' => 'understanding',
        'upper_medium' => 'application',
        'hard' => 'application',
    ];

    public static function normalize(array $question): array
    {
        foreach (['question_category' => self::CATEGORIES, 'difficulty_level' => self::LEVELS] as $field => $choices) {
            if (!array_key_exists($field, $question)) continue;
            $value = $question[$field];
            if ($value === null || $value === '') {
                $question[$field] = null;
                continue;
            }
            if (!is_string($value)) throw new \InvalidArgumentException('Phân loại hoặc mức độ câu hỏi không hợp lệ.');
            if ($field === 'difficulty_level') $value = self::LEGACY_LEVELS[$value] ?? $value;
            if (!isset($choices[$value])) throw new \InvalidArgumentException('Phân loại hoặc mức độ câu hỏi không hợp lệ.');
            $question[$field] = $value;
        }
        return $question;
    }

    /** Merge the small legacy editor into the full question, preserving source, images and AI explanations.
     * Original indexes distinguish repeated/missing legacy codes even after sorting. New cloned rows clear the index.
     * Staff-only imported exams expose only metadata; their questions, answers and ordering stay untouched. */
    public static function forSave(array $submitted, array $existing = [], bool $metadataOnly = false): array
    {
        $existing = array_values($existing);
        $byCode = [];
        foreach ($existing as $index => $question) {
            $code = (string)($question['code'] ?? '');
            if ($code !== '') $byCode[$code][] = $index;
        }
        $result = $metadataOnly ? $existing : [];
        $used = [];
        foreach ($submitted as $question) {
            if (!is_array($question)) throw new \InvalidArgumentException('Dữ liệu câu hỏi không hợp lệ.');
            $code = (string)($question['code'] ?? '');
            $ref = $question['_question_index'] ?? null;
            $index = null;
            if ($ref !== null && $ref !== '') {
                if (!is_scalar($ref) || !ctype_digit((string)$ref)) throw new \InvalidArgumentException('Vị trí câu hỏi không hợp lệ.');
                $index = (int)$ref;
                if (!isset($existing[$index]) || (string)($existing[$index]['code'] ?? '') !== $code) {
                    throw new \InvalidArgumentException('Câu hỏi đã thay đổi. Vui lòng tải lại trang trước khi lưu.');
                }
            } elseif (count($byCode[$code] ?? []) === 1) {
                $index = $byCode[$code][0];
            }
            if ($index !== null && isset($used[$index])) throw new \InvalidArgumentException('Câu hỏi bị lặp khi lưu.');
            if ($index !== null) $used[$index] = true;
            unset($question['_question_index']);
            $base = $index !== null ? $existing[$index] : [];
            if ($metadataOnly) {
                if ($index === null) throw new \InvalidArgumentException('Không thể thêm câu hỏi vào đề gốc tại đây.');
                $metadata = array_intersect_key($question, ['question_category' => true, 'difficulty_level' => true]);
                $result[$index] = self::normalize(array_replace($base, $metadata));
            } else {
                $merged = array_replace($base, $question);
                // Imported MCQ choices take precedence in the player, so reflect edits in both representations.
                if (($merged['question_type'] ?? '') === 'MULTIPLE_CHOICE' && isset($merged['options']) && is_array($merged['options'])) {
                    $merged['options'] = array_values($merged['options']);
                    foreach (array_values($merged['options']) as $i => $option) {
                        $key = (QuizQuestions::OPTION_KEYS[$i] ?? '') . '_vi';
                        if (is_array($option) && array_key_exists($key, $question)) {
                            $merged['options'][$i]['content'] = $question[$key];
                        }
                        if (is_array($option) && isset($question['answer_vi'])) $merged['options'][$i]['is_correct'] = (int)$question['answer_vi'] === $i + 1;
                    }
                }
                $result[] = self::normalize($merged);
            }
        }
        return $result;
    }
}
