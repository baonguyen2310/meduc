<?php
declare(strict_types=1);
namespace App\Controller;

use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;

/** Refresh the signed-in student's existing course access without reloading the classroom. */
class ClassroomController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout=false;
    }

    public function access($productId=null)
    {
        $this->autoRender=false;
        if (!$this->request->is('get')) return $this->json(405,[],'Phương thức không hợp lệ.');
        $productId=(int)$productId;
        $product=ConnectionManager::get('default')->execute('SELECT id FROM products WHERE id=:id AND deleted=0 AND status=1 AND COALESCE(draft,0)=0',['id'=>$productId])->fetch('assoc');
        if (!$product || !in_array($productId,TableRegistry::get('CourseEnrollments')->courseIds(),true)) return $this->json(404,[],'Không tìm thấy khóa học.');
        $member=$this->request->getSession()->read(MEMBER)?:[];
        $customer=!empty($member['id']) ? TableRegistry::get('Customers')->find()->where(['id'=>(int)$member['id'],'deleted'=>0])->select(['id','code'])->enableHydration(false)->first() : null;
        $data=['member_id'=>0,'member_code'=>'','licensed'=>false,'class_room_id'=>0];
        if ($customer) {
            $data['member_id']=(int)$customer['id'];$data['member_code']=(string)$customer['code'];
            // Same legacy class and active-enrollment rules used by MemberHelper and QuizAnswerComponent.
            if ($data['member_code']!=='') {
                $class=TableRegistry::get('ClassRooms')->find()->where(['deleted'=>0,'product_id'=>$productId,'users LIKE'=>'%'.$data['member_code'].'%'])->select(['id'])->first();
                if ($class) $data['class_room_id']=(int)$class['id'];
            }
            $data['licensed']=$data['class_room_id']>0 || !empty(TableRegistry::get('CourseEnrollments')->activeCourses($data['member_id'])[$productId]);
        }
        return $this->json(200,$data);
    }

    private function json(int $status,array $data,string $message='')
    {
        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control','private, no-store')
            ->withStringBody(json_encode(['code'=>$status===200?'success':'error','data'=>$data,'message'=>$message],JSON_UNESCAPED_UNICODE));
    }
}
