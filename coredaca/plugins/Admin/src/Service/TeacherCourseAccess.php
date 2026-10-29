<?php

namespace Admin\Service;

use Cake\Datasource\ConnectionManager;
use InvalidArgumentException;

/** Course assignments are independent of the legacy classroom feature. */
class TeacherCourseAccess
{
    private static function db()
    {
        return ConnectionManager::get('default');
    }

    public static function accountState(int $userId): ?array
    {
        $row = self::db()->execute(
            'SELECT u.role_id, u.status, u.deleted, r.name AS role_name
             FROM users u LEFT JOIN roles r ON r.id = u.role_id
             WHERE u.id = :id LIMIT 1',
            ['id' => $userId]
        )->fetch('assoc');
        return $row ?: null;
    }

    public static function teacherOptions(): array
    {
        $rows = self::db()->execute(
            "SELECT u.id, u.full_name, u.username FROM users u
             INNER JOIN roles r ON r.id = u.role_id
             WHERE r.name = 'Giáo viên' AND r.deleted = 0
               AND u.status = 1 AND u.deleted = 0
             ORDER BY u.full_name, u.username"
        )->fetchAll('assoc');
        $options = [];
        foreach ($rows as $row) {
            $options[(int)$row['id']] = $row['full_name'] . ' (' . $row['username'] . ')';
        }
        return $options;
    }

    public static function teacherIdsForCourse(int $productId): array
    {
        $rows = self::db()->execute(
            'SELECT user_id FROM teacher_course_access WHERE product_id = :product_id ORDER BY user_id',
            ['product_id' => $productId]
        )->fetchAll('assoc');
        return array_map('intval', array_column($rows, 'user_id'));
    }

    public static function isCourse(int $productId): bool
    {
        $row = self::db()->execute(
            "SELECT p.id FROM products p
             WHERE p.id = :product_id AND p.deleted = 0 AND (
               p.main_category_id = 50 OR EXISTS (
                 SELECT 1 FROM categories c
                 WHERE c.id = p.main_category_id AND c.path_id LIKE '%|50|%'
               ) OR EXISTS (
                 SELECT 1 FROM categories_product cp INNER JOIN categories c ON c.id = cp.category_id
                 WHERE cp.product_id = p.id AND (c.id = 50 OR c.path_id LIKE '%|50|%')
               )
             ) LIMIT 1",
            ['product_id' => $productId]
        )->fetch('assoc');
        return (bool)$row;
    }

    public static function hasCourseCategory(array $categoryIds): bool
    {
        $categoryIds = array_values(array_filter(array_map('intval', $categoryIds)));
        if (!$categoryIds) return false;
        return (bool)self::db()->execute(
            "SELECT 1 FROM categories WHERE deleted=0 AND type='product'
             AND id IN (".implode(',', $categoryIds).") AND (id=50 OR path_id LIKE '%|50|%') LIMIT 1"
        )->fetch('assoc');
    }

    public static function isAssigned(int $userId, int $productId): bool
    {
        $row = self::db()->execute(
            'SELECT 1 FROM teacher_course_access WHERE user_id = :user_id AND product_id = :product_id LIMIT 1',
            ['user_id' => $userId, 'product_id' => $productId]
        )->fetch('assoc');
        return (bool)$row && self::isCourse($productId) && \App\Service\CourseTypes::kind($productId) !== 'fa';
    }

    public static function assignedCourses(int $userId): array
    {
        return self::db()->execute(
            "SELECT p.id, p.status, pc.name, COALESCE(e.staff_only,0) exam_staff_only
             FROM teacher_course_access t
             INNER JOIN products p ON p.id = t.product_id AND p.deleted = 0
             INNER JOIN products_content pc ON pc.product_id = p.id AND pc.lang = 'vi'
             LEFT JOIN exam_prep_courses e ON e.product_id = p.id
             WHERE t.user_id = :user_id AND COALESCE(p.course_kind,'') <> 'fa' AND (
               p.main_category_id = 50 OR EXISTS (
                 SELECT 1 FROM categories c
                 WHERE c.id = p.main_category_id AND c.path_id LIKE '%|50|%'
               ) OR EXISTS (
                 SELECT 1 FROM categories_product cp INNER JOIN categories c ON c.id = cp.category_id
                 WHERE cp.product_id = p.id AND (c.id = 50 OR c.path_id LIKE '%|50|%')
               )
             ) ORDER BY pc.name",
            ['user_id' => $userId]
        )->fetchAll('assoc');
    }

    public static function validateTeacherIds($ids): array
    {
        // Cake's multiple select submits its empty hidden value when all teachers are removed.
        if ($ids === null || $ids === '') {
            return [];
        }
        if (!is_array($ids)) {
            throw new InvalidArgumentException('Danh sách giáo viên không hợp lệ.');
        }
        $normalized = [];
        foreach ($ids as $id) {
            if ($id === '') {
                continue;
            }
            if (!ctype_digit((string)$id) || (int)$id < 1) {
                throw new InvalidArgumentException('Danh sách giáo viên không hợp lệ.');
            }
            $normalized[(int)$id] = (int)$id;
        }
        $normalized = array_values($normalized);
        if (!$normalized) {
            return [];
        }
        $valid = self::teacherOptions();
        foreach ($normalized as $id) {
            if (!isset($valid[$id])) {
                throw new InvalidArgumentException('Chỉ có thể phân công tài khoản giáo viên đang hoạt động.');
            }
        }
        return $normalized;
    }

    public static function replaceAssignments(int $productId, array $teacherIds): void
    {
        if (!self::isCourse($productId) && $teacherIds) {
            throw new InvalidArgumentException('Chỉ có thể phân công giáo viên cho khóa học.');
        }
        self::db()->transactional(function ($db) use ($productId, $teacherIds) {
            $db->execute('DELETE FROM teacher_course_access WHERE product_id = :product_id', ['product_id' => $productId]);
            foreach ($teacherIds as $teacherId) {
                $db->execute(
                    'INSERT INTO teacher_course_access (user_id, product_id) VALUES (:user_id, :product_id)',
                    ['user_id' => $teacherId, 'product_id' => $productId]
                );
            }
        });
    }
}
