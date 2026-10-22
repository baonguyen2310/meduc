<?php
namespace App\Controller;

use App\Service\CoursePricing;
use Cake\ORM\TableRegistry;
use Cake\Http\Exception\NotFoundException;

class CoursePriceController extends AppController
{
    public function initialize(): void { parent::initialize(); $this->get_structure_layout=false; }

    public function index($slug=null)
    {
        $lists=CoursePricing::lists(true);
        $from=(int)$this->request->getQuery('mon');
        if (!$slug && $from) {
            $l=CoursePricing::get(CoursePricing::courseListId($from));
            if ($l && (int)$l['status']===1) return $this->redirect('/bang-bao-gia/'.$l['slug'].'?mon='.$from);
        }
        $list=null;
        foreach($lists as $l) if ($slug ? $l['slug']===$slug : !$list) $list=$l;
        if ($slug && !$list) throw new NotFoundException('Bảng giá không còn mở.');
        $packages=$list?CoursePricing::packages((int)$list['id']):[];
        $courses=$list?CoursePricing::courses((int)$list['id'],true):[];
        $ids=array_column($courses,'id'); if (!in_array($from,$ids)) $from=0;
        $member=$this->request->getSession()->read(MEMBER)?:[];
        $customer=!empty($member['id']) ? TableRegistry::get('Customers')->find()->where(['id'=>(int)$member['id'],'deleted'=>0])->enableHydration(false)->first() : [];
        $recommended_year=(string)($customer['student_year']??'');
        if (!in_array($recommended_year,['1','2','3','4','5','6','graduate'],true)) {
            $source=null; foreach ($courses as $c) if ((int)$c['id']===$from) $source=$c;
            $recommended_year=(string)($source['years'][0]??'');
        }
        $catalog_json=json_encode(array_values($courses),JSON_UNESCAPED_UNICODE|JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT);
        $token=bin2hex(random_bytes(24));
        $tokens=$this->request->getSession()->read('CoursePrice.tokens')?:[];
        $tokens[$token]=time(); $tokens=array_slice($tokens,-10,null,true);
        $this->request->getSession()->write('CoursePrice.tokens',$tokens);
        $blocks=[];
        foreach (['6bcghom','fcm8r16','mv6ky0z','awlj4fk'] as $code) {
            $b=TableRegistry::get('TemplatesBlock')->getInfoBlock($code);
            if (!empty($b['status'])) { $b['data_block']=$this->loadComponent('Block')->getDataBlock($b); $blocks[$code]=$b; }
        }
        $this->set(compact('lists','list','packages','courses','from','member','customer','token','blocks','recommended_year','catalog_json'));
        $this->set('title_for_layout',($list?$list['name']:'Bảng báo giá').' | MedUC');
        $this->set('data_init',['device'=>DEVICE,'member'=>$member,'template'=>['code'=>CODE_TEMPLATE,'url'=>URL_TEMPLATE]]);
        $this->viewBuilder()->setLayout('course_pricing');
    }

    public function links()
    {
        $this->autoRender=false;
        $map=[]; $boards=[];
        foreach(CoursePricing::lists(true) as $l) {
            $courses=CoursePricing::courses((int)$l['id']);
            $packages=CoursePricing::packages((int)$l['id']);
            $boards[]=['id'=>(int)$l['id'],'name'=>$l['name'],'slug'=>$l['slug'],'kind'=>$l['course_type'],
                'courses'=>array_map('intval',array_column($courses,'id')),
                'packages'=>array_map(function($p){return ['id'=>(int)$p['id'],'name'=>$p['name'],'count'=>(int)$p['course_count'],'amount'=>(int)$p['amount']];},$packages)];
            foreach($courses as $c) $map[$c['id']]='/bang-bao-gia/'.$l['slug'].'?mon='.$c['id'];
        }
        $json=json_encode(['links'=>$map,'boards'=>$boards],JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_QUOT|JSON_HEX_APOS);
        $js='window.MeducCourseCart && window.MeducCourseCart.configure('.$json.');';
        return $this->response->withType('application/javascript')->withHeader('Cache-Control','no-store')->withStringBody($js);
    }

    public function create()
    {
        $this->autoRender=false;
        if (!$this->request->is('post')) return $this->json(405,'Phương thức không hợp lệ.');
        $session=$this->request->getSession(); $member=$session->read(MEMBER);
        if (empty($member['id'])) return $this->json(401,'Vui lòng đăng nhập để đăng ký gói học.');
        $data=$this->request->getData(); $token=(string)($data['token']??'');
        $done=$session->read('CoursePrice.completed')?:[];
        if (isset($done[$token]) && (int)($done[$token]['customer_id']??0)===(int)$member['id']) return $this->json(200,'Đơn đăng ký đã được tạo.',['redirect'=>$done[$token]['redirect']]);
        $tokens=$session->read('CoursePrice.tokens')?:[];
        if (empty($tokens[$token]) || $tokens[$token]<time()-7200) return $this->json(422,'Phiên đăng ký đã hết hạn. Vui lòng tải lại trang.');
        try {
            $quote=CoursePricing::quote((int)($data['package_id']??0),is_array($data['course_ids']??null)?$data['course_ids']:[]);
            $customer=TableRegistry::get('Customers')->find()->where(['id'=>(int)$member['id'],'deleted'=>0])->enableHydration(false)->first();
            if (!$customer) return $this->json(401,'Tài khoản không còn hoạt động.');
            $phone=trim((string)($data['phone']??$customer['phone']??''));
            if (!preg_match('/^[+0-9][0-9 .()-]{7,20}$/',$phone)) return $this->json(422,'Vui lòng nhập số điện thoại hợp lệ.');
            $items=[]; $n=count($quote['courses']); $remaining=$quote['amount'];
            foreach($quote['courses'] as $i=>$c) {
                $price=$i===$n-1 ? $remaining : intdiv($quote['amount'],$n); $remaining-=$price;
                $items[]=['product_id'=>(int)$c['id'],'product_item_id'=>(int)$c['item_id'],'quantity'=>1,'price'=>$price,'vat_value'=>0];
            }
            $p=$quote['package'];
            $payload=['type'=>ORDER,'source'=>WEBSITE,'status'=>DRAFT,'note'=>mb_substr('Bảng giá: '.$p['list_name'].' · '.$p['name'],0,250),
                'contact'=>['customer_id'=>(int)$member['id'],'full_name'=>$customer['full_name'],'email'=>$customer['email'],'phone'=>$phone], 'items'=>$items];
            $order=CoursePricing::db()->transactional(function() use($payload,$p,$quote) {
                $result=$this->loadComponent('Admin.Order')->saveOrder($payload);
                if (($result[CODE]??null)!==SUCCESS) throw new \RuntimeException($result[MESSAGE]??'Chưa tạo được đơn đăng ký.');
                $o=$result[DATA];
                CoursePricing::db()->update('orders',['course_price_package_id'=>(int)$p['id'],'course_price_snapshot'=>json_encode($quote,JSON_UNESCAPED_UNICODE)],['id'=>(int)$o['id']]);
                return $o;
            });
            $url='/order/checkout?code='.rawurlencode($order['code']);
            $done[$token]=['customer_id'=>(int)$member['id'],'redirect'=>$url]; $session->write('CoursePrice.completed',array_slice($done,-10,null,true));
            unset($tokens[$token]);$session->write('CoursePrice.tokens',$tokens);
            return $this->json(200,'Đã tạo đơn đăng ký.',['redirect'=>$url]);
        } catch(\InvalidArgumentException $e) { return $this->json(422,$e->getMessage()); }
        catch(\Throwable $e) { $this->log('Course price checkout: '.$e->getMessage(),'error');return $this->json(500,'Chưa tạo được đơn đăng ký. Vui lòng thử lại.'); }
    }

    private function json(int $status,string $message,array $data=[])
    { return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control','private, no-store')->withStringBody(json_encode(['code'=>$status===200?'success':'error','message'=>$message,'data'=>$data],JSON_UNESCAPED_UNICODE)); }
}
