<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Datasource\ConnectionManager;
use Cake\Http\Client;
use RuntimeException;

/** The 2,033 exam catalog and the explicit PHP course access rules. */
class TeacherExamLibrary
{
    private $connection;
    private $catalog;

    public function __construct()
    {
        $this->connection = ConnectionManager::get('default');
    }

    public static function teacherRoleId(): int
    {
        $row = ConnectionManager::get('default')->execute(
            'SELECT id FROM roles WHERE name = :name AND deleted = 0 LIMIT 1',
            ['name' => 'Giáo viên']
        )->fetch('assoc');
        return $row ? (int)$row['id'] : 0;
    }

    public function catalog(): array
    {
        if ($this->catalog !== null) {
            return $this->catalog;
        }
        $path = SOURCE_DOMAIN . DS . 'hero-light' . DS . 'assets' . DS . 'exam-hierarchy-data.json';
        $data = json_decode((string)file_get_contents($path), true);
        if (!is_array($data) || count($data['exams'] ?? []) !== 2033) {
            throw new RuntimeException('Danh mục 2.033 đề không hợp lệ.');
        }
        $this->catalog = $data;
        return $data;
    }

    public function exam(int $examId): ?array
    {
        if ($examId < 1) {
            return null;
        }
        foreach ($this->catalog()['exams'] as $exam) {
            if ((int)$exam['id'] === $examId) {
                return $exam;
            }
        }
        return null;
    }

    public function courses(): array
    {
        return $this->connection->execute("SELECT p.id, pc.name, p.status
            FROM products p
            JOIN categories c ON c.id = p.main_category_id
            JOIN products_content pc ON pc.product_id = p.id AND pc.lang = 'vi'
            WHERE p.deleted = 0 AND (c.id = 50 OR c.path_id LIKE '%|50|%')
            ORDER BY p.status DESC, pc.name ASC")->fetchAll('assoc');
    }

    public function teachers(): array
    {
        $roleId = self::teacherRoleId();
        if (!$roleId) {
            return [];
        }
        return $this->connection->execute('SELECT id, full_name, username FROM users
            WHERE role_id = :role AND status = 1 AND deleted = 0 ORDER BY full_name',
            ['role' => $roleId])->fetchAll('assoc');
    }

    public function teacherCourses(int $userId): array
    {
        $rows = $this->connection->execute('SELECT product_id FROM teacher_course_access WHERE user_id = :id',
            ['id' => $userId])->fetchAll('assoc');
        return array_map('intval', array_column($rows, 'product_id'));
    }

    public function teacherAssignments(): array
    {
        $result = [];
        foreach ($this->connection->execute('SELECT user_id, product_id FROM teacher_course_access')->fetchAll('assoc') as $row) {
            $result[(int)$row['user_id']][] = (int)$row['product_id'];
        }
        return $result;
    }

    public function topicMappings(): array
    {
        $result = [];
        foreach ($this->connection->execute('SELECT topic, product_id FROM facourse_topic_courses')->fetchAll('assoc') as $row) {
            $result[$row['topic']][] = (int)$row['product_id'];
        }
        return $result;
    }

    public function examMappings(): array
    {
        $result = [];
        foreach ($this->connection->execute('SELECT exam_id, product_id FROM facourse_exam_courses')->fetchAll('assoc') as $row) {
            $result[(int)$row['exam_id']][] = (int)$row['product_id'];
        }
        return $result;
    }

    public function courseIdsForExam(array $exam, array $topicMappings, array $examMappings): array
    {
        return array_values(array_unique(array_merge(
            $topicMappings[$exam['topic']] ?? [],
            $examMappings[(int)$exam['id']] ?? []
        )));
    }

    public function allowedCoursesForExam(int $userId, array $exam): array
    {
        $mapped = $this->courseIdsForExam($exam, $this->topicMappings(), $this->examMappings());
        return array_values(array_intersect($this->teacherCourses($userId), $mapped));
    }

    public function saveTeacherCourses(int $userId, array $courseIds): void
    {
        $roleId = self::teacherRoleId();
        $teacher = $this->connection->execute('SELECT id FROM users WHERE id = :id AND role_id = :role
            AND status = 1 AND deleted = 0', ['id' => $userId, 'role' => $roleId])->fetch('assoc');
        if (!$teacher) {
            throw new RuntimeException('Tài khoản giáo viên không hợp lệ.');
        }
        $this->replaceMappings('teacher_course_access', 'user_id', $userId, $courseIds);
    }

    public function saveTopicCourses(string $topic, array $courseIds): void
    {
        $topics = array_column($this->catalog()['exams'], 'topic');
        if (!in_array($topic, $topics, true)) {
            throw new RuntimeException('Môn/module không có trong kho đề.');
        }
        $this->replaceMappings('facourse_topic_courses', 'topic', $topic, $courseIds);
    }

    public function saveExamCourses(int $examId, array $courseIds): void
    {
        if (!$this->exam($examId)) {
            throw new RuntimeException('Không tìm thấy đề.');
        }
        $this->replaceMappings('facourse_exam_courses', 'exam_id', $examId, $courseIds);
    }

    private function replaceMappings(string $table, string $key, $value, array $courseIds): void
    {
        $valid = array_map('intval', array_column($this->courses(), 'id'));
        $courseIds = array_values(array_unique(array_map('intval', $courseIds)));
        if (array_diff($courseIds, $valid)) {
            throw new RuntimeException('Khóa học được chọn không hợp lệ.');
        }
        $this->connection->begin();
        try {
            $this->connection->execute("DELETE FROM {$table} WHERE {$key} = :value", ['value' => $value]);
            foreach ($courseIds as $productId) {
                $this->connection->execute("INSERT INTO {$table} ({$key}, product_id) VALUES (:value, :course)",
                    ['value' => $value, 'course' => $productId]);
            }
            $this->connection->commit();
        } catch (\Throwable $error) {
            $this->connection->rollback();
            throw $error;
        }
    }

    public function liveExam(int $examId): array
    {
        $key = getenv('MEDUC_2033_API_KEY');
        if (!$key) {
            throw new RuntimeException('Chưa cấu hình kết nối bảo mật tới kho 2.033 đề.');
        }
        $base = rtrim(getenv('MEDUC_2033_API_BASE') ?: 'https://meduc.duckdns.org/api/2033', '/');
        $client = new Client(['timeout' => 35]);
        $response = $client->get($base . '/exam/' . $examId, [], [
            'headers' => ['X-API-Key' => $key, 'Accept' => 'application/json']
        ]);
        $payload = $response->getJson();
        if (!$response->isOk() || empty($payload['success']) || !is_array($payload['data'] ?? null)) {
            throw new RuntimeException('Không tải được nội dung đề từ kho dữ liệu.');
        }
        if ((int)($payload['data']['exam']['id'] ?? 0) !== $examId) {
            throw new RuntimeException('Mã đề trả về không khớp yêu cầu.');
        }
        return $payload['data'];
    }

    public function image(string $hash): ?array
    {
        if (!preg_match('/^[a-zA-Z0-9_-]{16,128}$/', $hash)) {
            return null;
        }
        $base = rtrim(getenv('MEDUC_2033_API_BASE') ?: 'https://meduc.duckdns.org/api/2033', '/');
        $origin = preg_replace('~/api(?:/2033)?$~', '', $base);
        $client = new Client(['timeout' => 15]);
        $response = $client->get($origin . '/api/media/' . rawurlencode($hash));
        if (!$response->isOk()) {
            return null;
        }
        $bytes = (string)$response->getBody();
        if (strlen($bytes) > 8000000 || !$bytes) {
            return null;
        }
        $info = @getimagesizefromstring($bytes);
        if (!$info) {
            return null;
        }
        return ['bytes' => $bytes, 'width' => $info[0], 'height' => $info[1], 'mime' => $info['mime']];
    }

    public function recordDownload(int $userId, int $examId, ?int $courseId): void
    {
        $this->connection->execute('INSERT INTO facourse_word_downloads
            (user_id, exam_id, product_id, downloaded_at) VALUES (:user, :exam, :course, NOW())',
            ['user' => $userId, 'exam' => $examId, 'course' => $courseId]);
    }
}
