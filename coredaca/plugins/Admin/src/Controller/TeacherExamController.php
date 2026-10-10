<?php
declare(strict_types=1);

namespace Admin\Controller;

use App\Service\ExamWordExporter;
use App\Service\TeacherExamLibrary;
use Cake\Datasource\ConnectionManager;
use Cake\Event\EventInterface;
use Cake\Http\Exception\ForbiddenException;
use Cake\Http\Exception\NotFoundException;
use Cake\Http\Exception\UnauthorizedException;
use RuntimeException;

/** Course-scoped teacher access to the curated Facourse exam bank. */
class TeacherExamController extends AppController
{
    private $staff;
    private $manager = false;

    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
        $sessionUser = $this->Auth->user();
        if (!$sessionUser || empty($sessionUser['id'])) {
            if ($this->request->getParam('action') === 'index') {
                return $this->redirect('/admin?redirect=' . rawurlencode('/admin/teacher-exams'));
            }
            throw new UnauthorizedException('Vui lòng đăng nhập tài khoản quản trị MedUC.');
        }
        if (!empty($sessionUser['supper_admin'])) {
            $this->staff = $sessionUser;
            $this->manager = true;
            return;
        }
        $staff = ConnectionManager::get('default')->execute('SELECT id, username, full_name, role_id
            FROM users WHERE id = :id AND status = 1 AND deleted = 0 LIMIT 1',
            ['id' => (int)$sessionUser['id']])->fetch('assoc');
        if (!$staff) {
            throw new UnauthorizedException('Tài khoản không còn hoạt động.');
        }
        $this->staff = $staff;
        $roleId = (int)$staff['role_id'];
        $this->manager = $roleId === 1;
        if (!$this->manager && $roleId !== TeacherExamLibrary::teacherRoleId()) {
            throw new ForbiddenException('Chỉ quản trị viên và giáo viên được xem kho đề này.');
        }
    }

    public function index()
    {
        $this->viewBuilder()->disableAutoLayout();
        $this->set('csrfToken', (string)$this->request->getAttribute('csrfToken'));
        $this->set('staffName', (string)($this->staff['full_name'] ?? 'MedUC'));
        $this->set('isManager', $this->manager);
    }

    public function data()
    {
        $library = new TeacherExamLibrary();
        $catalog = $library->catalog();
        $topicMappings = $library->topicMappings();
        $examMappings = $library->examMappings();
        $teacherCourses = $this->manager ? [] : $library->teacherCourses((int)$this->staff['id']);
        $exams = [];
        foreach ($catalog['exams'] as $exam) {
            $courseIds = $library->courseIdsForExam($exam, $topicMappings, $examMappings);
            if (!$this->manager && !array_intersect($teacherCourses, $courseIds)) {
                continue;
            }
            $exam['courseIds'] = $courseIds;
            $exam['directCourseIds'] = $examMappings[(int)$exam['id']] ?? [];
            $exams[] = $exam;
        }
        $result = [
            'count' => count($exams),
            'totalCatalog' => (int)$catalog['count'],
            'exams' => $exams,
            'courses' => $this->manager ? $library->courses() : array_values(array_filter(
                $library->courses(), static function ($course) use ($teacherCourses) {
                    return in_array((int)$course['id'], $teacherCourses, true);
                }
            )),
            'manager' => $this->manager,
        ];
        if ($this->manager) {
            $result['teachers'] = $library->teachers();
            $result['teacherAssignments'] = $library->teacherAssignments();
            $result['topicMappings'] = $topicMappings;
        }
        return $this->json($result);
    }

    public function detail($id = null)
    {
        $library = new TeacherExamLibrary();
        $exam = $this->requireExamAccess($library, (int)$id);
        try {
            $live = $library->liveExam((int)$exam['id']);
            return $this->json($live);
        } catch (RuntimeException $error) {
            return $this->json(['error' => $error->getMessage()], 503);
        }
    }

    public function word($id = null)
    {
        $library = new TeacherExamLibrary();
        $exam = $this->requireExamAccess($library, (int)$id);
        try {
            $live = $library->liveExam((int)$exam['id']);
            $path = (new ExamWordExporter())->create($live, static function ($hash) use ($library) {
                return $library->image($hash);
            });
            $bytes = file_get_contents($path);
            @unlink($path);
            if ($bytes === false) {
                throw new RuntimeException('Không đọc được tệp Word.');
            }
            $courses = $this->manager ? [] : $library->allowedCoursesForExam((int)$this->staff['id'], $exam);
            $library->recordDownload((int)$this->staff['id'], (int)$exam['id'], $courses[0] ?? null);
            return $this->response
                ->withType('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
                ->withHeader('Content-Disposition', 'attachment; filename="meduc-de-' . (int)$exam['id'] . '.docx"')
                ->withHeader('Cache-Control', 'private, no-store')
                ->withStringBody($bytes);
        } catch (RuntimeException $error) {
            return $this->json(['error' => $error->getMessage()], 503);
        }
    }

    public function saveTeacher()
    {
        $this->requireManagerPost();
        $library = new TeacherExamLibrary();
        try {
            $library->saveTeacherCourses((int)$this->request->getData('user_id'),
                (array)$this->request->getData('course_ids', []));
            return $this->json(['success' => true]);
        } catch (RuntimeException $error) {
            return $this->json(['error' => $error->getMessage()], 422);
        }
    }

    public function saveTopic()
    {
        $this->requireManagerPost();
        $library = new TeacherExamLibrary();
        try {
            $library->saveTopicCourses((string)$this->request->getData('topic'),
                (array)$this->request->getData('course_ids', []));
            return $this->json(['success' => true]);
        } catch (RuntimeException $error) {
            return $this->json(['error' => $error->getMessage()], 422);
        }
    }

    public function saveExam()
    {
        $this->requireManagerPost();
        $library = new TeacherExamLibrary();
        try {
            $library->saveExamCourses((int)$this->request->getData('exam_id'),
                (array)$this->request->getData('course_ids', []));
            return $this->json(['success' => true]);
        } catch (RuntimeException $error) {
            return $this->json(['error' => $error->getMessage()], 422);
        }
    }

    private function requireExamAccess(TeacherExamLibrary $library, int $id): array
    {
        $exam = $library->exam($id);
        if (!$exam) {
            throw new NotFoundException('Không tìm thấy đề trong kho 2.033 đề.');
        }
        if (!$this->manager && !$library->allowedCoursesForExam((int)$this->staff['id'], $exam)) {
            throw new ForbiddenException('Đề không thuộc khóa học được giao cho giáo viên này.');
        }
        return $exam;
    }

    private function requireManagerPost(): void
    {
        if (!$this->manager) {
            throw new ForbiddenException('Chỉ quản trị viên được thay đổi phân quyền.');
        }
        $this->request->allowMethod(['post']);
    }

    private function json(array $data, int $status = 200)
    {
        return $this->response->withType('application/json')
            ->withStatus($status)
            ->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode($data, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE));
    }
}
