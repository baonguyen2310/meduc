<?php
namespace Admin\Controller;

use Admin\Service\TeacherCourseAccess;
use App\Service\FacultyApplications;
use Cake\Datasource\ConnectionManager;
use Cake\Event\EventInterface;
use Cake\Http\Exception\ForbiddenException;
use Cake\Http\Exception\NotFoundException;

class FacultyApplicationController extends AppController
{
    public function beforeFilter(EventInterface $event)
    {
        $user = $this->Auth->user();
        if (!empty($user['id']) && empty($user['supper_admin'])) {
            $account = TeacherCourseAccess::accountState((int)$user['id']);
            if (!$account || (int)$account['role_id'] !== 1 || (int)$account['status'] !== 1 || (int)$account['deleted'] !== 0) {
                return $this->response->withStatus(403)->withType('text/plain')
                    ->withHeader('Cache-Control', 'private, no-store')
                    ->withStringBody('Chỉ quản trị viên được quản lý hồ sơ ứng tuyển.');
            }
        }
        return parent::beforeFilter($event);
    }

    public function index()
    {
        $db = ConnectionManager::get('default');
        $status = (string)$this->request->getQuery('status', 'all');
        $labels = FacultyApplications::STATUSES;
        if (!isset($labels[$status])) $status = 'all';
        $search = mb_substr(trim((string)$this->request->getQuery('q', '')), 0, 160);
        $where = ['1=1']; $params = [];
        if ($status !== 'all') { $where[]='status=:status'; $params['status']=$status; }
        if ($search !== '') {
            $where[]='(full_name LIKE :q1 OR email LIKE :q2 OR phone LIKE :q3 OR specialty LIKE :q4)';
            foreach (['q1','q2','q3','q4'] as $key) $params[$key]='%'.$search.'%';
        }
        $sql = implode(' AND ', $where);
        $total=(int)$db->execute('SELECT COUNT(*) FROM faculty_applications WHERE '.$sql, $params)->fetchColumn(0);
        $pages=max(1,(int)ceil($total/25));
        $page=min($pages,max(1,(int)$this->request->getQuery('page',1)));
        $offset=($page-1)*25;
        $rows=$db->execute('SELECT * FROM faculty_applications WHERE '.$sql.' ORDER BY id DESC LIMIT 25 OFFSET '.$offset, $params)->fetchAll('assoc');
        foreach ($rows as &$row) $row['file_count']=count(json_decode($row['attachment_files'],true) ?: []);
        unset($row);
        $this->set(compact('rows','total','pages','page','status','search','labels'));
        $this->set('query_string', http_build_query(['status'=>$status,'q'=>$search]));
        $this->set('path_menu','faculty-applications');
        $this->set('title_for_layout','Ứng tuyển giảng viên');
    }

    public function detail($id = null)
    {
        $row=FacultyApplications::find((int)$id);
        if (!$row) throw new NotFoundException('Không tìm thấy hồ sơ.');
        $this->set('row',$row);
        $this->set('labels',FacultyApplications::STATUSES);
        $this->set('path_menu','faculty-applications');
        $this->set('title_for_layout','Hồ sơ ứng tuyển #'.(int)$id);
        $this->set('saved',$this->request->getQuery('saved') === '1');
    }

    public function review($id = null)
    {
        $this->request->allowMethod(['post']);
        if (!FacultyApplications::find((int)$id)) throw new NotFoundException('Không tìm thấy hồ sơ.');
        $status=(string)$this->request->getData('status');
        $note=trim((string)$this->request->getData('admin_note'));
        if (!isset(FacultyApplications::STATUSES[$status]) || mb_strlen($note)>5000) throw new ForbiddenException('Trạng thái hoặc ghi chú không hợp lệ.');
        ConnectionManager::get('default')->execute('UPDATE faculty_applications SET status=:status,admin_note=:note,reviewed_by=:user,
            reviewed_at=:now,updated=:updated WHERE id=:id', ['status'=>$status,'note'=>$note ?: null,'user'=>(int)$this->Auth->user('id'),
            'now'=>time(),'updated'=>time(),'id'=>(int)$id]);
        return $this->redirect(ADMIN_PATH.'/faculty-applications/detail/'.(int)$id.'?saved=1');
    }

    public function notify($id = null)
    {
        $this->request->allowMethod(['post']);
        if (!FacultyApplications::find((int)$id)) throw new NotFoundException('Không tìm thấy hồ sơ.');
        FacultyApplications::notify((int)$id,function ($params) { return $this->loadComponent('Email')->sendEmail($params); });
        return $this->redirect(ADMIN_PATH.'/faculty-applications/detail/'.(int)$id);
    }

    public function download($id = null, $number = null)
    {
        $this->autoRender=false;
        $row=FacultyApplications::find((int)$id);
        $file=$row['files'][(int)$number] ?? null;
        if (!$file || !preg_match('/^[a-f0-9]{40}\.(?:pdf|docx?|jpg|png|webp)$/',$file['stored_name'])) throw new NotFoundException('Không tìm thấy file.');
        $path=FacultyApplications::directory().DS.$file['stored_name'];
        if (!is_file($path)) throw new NotFoundException('Không tìm thấy file.');
        return $this->response->withFile($path,['download'=>true,'name'=>$file['original_name']])->withType($file['mime'])
            ->withHeader('X-Content-Type-Options','nosniff')->withHeader('Cache-Control','private, no-store');
    }
}
