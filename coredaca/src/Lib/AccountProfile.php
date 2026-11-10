<?php
declare(strict_types=1);

namespace App\Lib;

final class AccountProfile
{
    public const YEARS = ['1', '2', '3', '4', '5', '6', 'graduate'];

    private static function text($value): string
    {
        return is_string($value) ? (preg_replace('/^[\s\p{Z}]+|[\s\p{Z}]+$/u', '', strip_tags($value)) ?? '') : '';
    }

    public static function missing(array $profile): array
    {
        $missing = [];
        foreach (['full_name', 'phone', 'school_name'] as $field) {
            if (self::text($profile[$field] ?? null) === '') $missing[] = $field;
        }
        if (!in_array((string)($profile['student_year'] ?? ''), self::YEARS, true)) $missing[] = 'student_year';
        return $missing;
    }

    public static function validate(array $data): array
    {
        $profile = [];
        foreach (['full_name', 'phone', 'school_name', 'student_year'] as $field) {
            $value = $field === 'student_year' && is_scalar($data[$field] ?? null) ? (string)$data[$field] : ($data[$field] ?? null);
            $profile[$field] = self::text($value);
        }
        if (mb_strlen($profile['full_name']) < 2 || mb_strlen($profile['full_name']) > 255) {
            throw new \InvalidArgumentException('Vui lòng nhập họ và tên hợp lệ.');
        }
        $profile['phone'] = preg_replace('/[\s().-]+/', '', $profile['phone']);
        if (!preg_match('/^(?:0[0-9]{9,10}|\+84[0-9]{9,10})$/D', $profile['phone'])) {
            throw new \InvalidArgumentException('Vui lòng nhập số điện thoại hợp lệ.');
        }
        if ($profile['school_name'] === '' || mb_strlen($profile['school_name']) > 255) {
            throw new \InvalidArgumentException('Vui lòng nhập tên trường học, tối đa 255 ký tự.');
        }
        if (!in_array($profile['student_year'], self::YEARS, true)) {
            throw new \InvalidArgumentException('Vui lòng chọn năm sinh viên hợp lệ.');
        }
        return $profile;
    }
}
