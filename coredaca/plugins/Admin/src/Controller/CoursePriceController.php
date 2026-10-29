<?php
namespace Admin\Controller;

use App\Service\CoursePricing;
use Admin\Service\TeacherCourseAccess;
use Cake\ORM\TableRegistry;
use Cake\Event\EventInterface;
use Cake\Http\Exception\ForbiddenException;
use Cake\Http\Exception\NotFoundException;

class CoursePriceController extends AppController
{
    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);$u=$this->Auth->user();
        if (empty($u['id'])) return;
        $a=TeacherCourseAccess::accountState((int)$u['id']);
        if (empty($u['supper_admin']) && (!$a || (int)$a['role_id']!==1)) throw new ForbiddenException('Chỉ quản trị viên được quản lý bảng báo giá.');
    }
    public function index()
    {
        $this->set('lists',CoursePricing::lists());$this->set('path_menu','course-prices');$this->set('title_for_layout','Bảng báo giá khóa học');
    }
    public function edit($id=null)
    {
        $id=(int)$id;$error=null;
        if ($id && !CoursePricing::get($id)) throw new NotFoundException('Không tìm thấy bảng giá.');
        if ($this->request->is('post')) {
            try { $id=CoursePricing::save($id,$this->request->getData()); return $this->redirect(ADMIN_PATH.'/course-prices/edit/'.$id.'?saved=1'); }
            catch(\InvalidArgumentException $e) { $error=$e->getMessage(); }
        }
        $list=$error?$this->request->getData():(CoursePricing::get($id)?:['name'=>'','slug'=>'','description'=>'','course_type'=>'knowledge','status'=>1,'position'=>0]);
        $packages=$error?($list['packages']??[]):($id?CoursePricing::packages($id,false):[]);
        $all=TableRegistry::get('CourseEnrollments')->courseOptions('vi');
        $assigned=CoursePricing::db()->execute('SELECT id,course_price_list_id FROM products WHERE course_price_list_id IS NOT NULL')->fetchAll('assoc');
        $map=array_column($assigned,'course_price_list_id','id');
        $selected=$error?($list['course_ids']??[]):array_keys(array_filter($map,function($v)use($id){return $id && (int)$v===$id;}));
        $this->set(compact('id','list','packages','all','selected','map','error'));
        $this->set('course_kinds',CoursePricing::courseKinds());
        $this->set('price_list_kinds',CoursePricing::LABELS);
        $this->set('price_list_names',CoursePricing::options());$this->set('saved',(bool)$this->request->getQuery('saved'));
        $this->set('path_menu','course-prices');$this->set('title_for_layout',$id?'Sửa bảng báo giá':'Thêm bảng báo giá');
    }
}
