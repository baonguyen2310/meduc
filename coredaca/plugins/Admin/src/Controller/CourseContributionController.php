<?php
namespace Admin\Controller;

use Admin\Service\TeacherCourseAccess;
use Cake\Datasource\ConnectionManager;
use Cake\Event\EventInterface;
use Cake\Http\Exception\ForbiddenException;
use Cake\Http\Exception\NotFoundException;

class CourseContributionController extends AppController
{
    private const PAGE_SIZE = 30;

    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
        $user = $this->Auth->user();
        // The existing Auth component handles the normal login redirect.
        if (empty($user['id'])) return;
        $account = TeacherCourseAccess::accountState((int)$user['id']);
        if (empty($user['supper_admin']) && (!$account || (int)$account['role_id'] !== 1)) {
            throw new ForbiddenException('Chỉ quản trị viên được xem đóng góp của học viên.');
        }
    }

    public function index()
    {
        $db = ConnectionManager::get('default');
        $status = (string)$this->request->getQuery('status', 'new');
        if (!in_array($status, ['new', 'reviewing', 'accepted', 'rejected', 'all'], true)) $status = 'new';
        $type = (string)$this->request->getQuery('type', 'all');
        if (!in_array($type, ['answer', 'exam', 'curriculum', 'general', 'all'], true)) $type = 'all';
        $id = max(0, (int)$this->request->getQuery('id'));
        $where = ['1=1'];
        $params = [];
        if ($status !== 'all') { $where[] = 'cc.status=:status'; $params['status'] = $status; }
        if ($type !== 'all') { $where[] = 'cc.type=:type'; $params['type'] = $type; }
        if ($id) { $where[] = 'cc.id=:id'; $params['id'] = $id; }
        $filterSql = implode(' AND ', $where);
        $total = (int)$db->execute("SELECT COUNT(*) FROM course_contributions cc WHERE {$filterSql}", $params)->fetchColumn(0);
        $page = max(1, (int)$this->request->getQuery('page', 1));
        $pages = max(1, (int)ceil($total / self::PAGE_SIZE));
        $page = min($page, $pages);
        $offset = ($page - 1) * self::PAGE_SIZE;
        $rows = $db->execute("SELECT cc.*, c.full_name, c.email, c.code AS customer_code
            FROM course_contributions cc LEFT JOIN customers c ON c.id=cc.customer_id
            WHERE {$filterSql} ORDER BY cc.id DESC LIMIT " . self::PAGE_SIZE . " OFFSET {$offset}", $params)->fetchAll('assoc');
        foreach ($rows as &$row) {
            $files = json_decode((string)$row['photo_files'], true);
            $row['files'] = is_array($files) ? $files : [];
        }
        unset($row);
        $this->set(compact('rows', 'total', 'page', 'pages', 'status', 'type'));
        $this->set('path_menu', 'course-contributions');
        $this->set('title_for_layout', 'Đóng góp của học viên');
    }

    public function review($id = null)
    {
        if (!$this->request->is('post')) throw new ForbiddenException('Phải gửi bằng POST.');
        $status = (string)$this->request->getData('status');
        $note = trim((string)$this->request->getData('admin_note'));
        if (!in_array($status, ['new', 'reviewing', 'accepted', 'rejected'], true) || mb_strlen($note) > 5000) {
            throw new ForbiddenException('Trạng thái hoặc ghi chú không hợp lệ.');
        }
        $db = ConnectionManager::get('default');
        $db->execute('UPDATE course_contributions SET status=:status, admin_note=:note, reviewed_by=:reviewer,
            reviewed_at=:reviewed, updated=:updated WHERE id=:id', [
            'status' => $status, 'note' => $note ?: null, 'reviewer' => (int)$this->Auth->user('id'),
            'reviewed' => time(), 'updated' => time(), 'id' => (int)$id,
        ]);
        return $this->redirect(ADMIN_PATH . '/course-contributions?id=' . (int)$id . '&status=all');
    }

    public function photo($id = null, $number = null)
    {
        $this->autoRender = false;
        $row = ConnectionManager::get('default')->execute('SELECT photo_files FROM course_contributions WHERE id=:id', ['id' => (int)$id])->fetch('assoc');
        $files = $row ? json_decode((string)$row['photo_files'], true) : null;
        $name = is_array($files) ? ($files[(int)$number] ?? '') : '';
        if (!preg_match('/^[a-f0-9]{40}\.(?:jpg|png|webp)$/', $name)) throw new NotFoundException('Không tìm thấy ảnh.');
        $path = ROOT . DS . 'tmp' . DS . 'course-contributions' . DS . $name;
        if (!is_file($path)) throw new NotFoundException('Không tìm thấy ảnh.');
        $mime = ['jpg' => 'image/jpeg', 'png' => 'image/png', 'webp' => 'image/webp'][pathinfo($name, PATHINFO_EXTENSION)];
        return $this->response->withType($mime)->withHeader('Cache-Control', 'private, no-store')
            ->withHeader('X-Content-Type-Options', 'nosniff')->withStringBody(file_get_contents($path));
    }
}
