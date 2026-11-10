<?php
declare(strict_types=1);
namespace App\Controller;
use App\Service\CommercePurchases;
use App\Service\CommerceNotifications;

class PurchaseApprovalController extends AppController
{
    public function initialize():void {parent::initialize();$this->get_structure_layout=false;}
    public function review($code=null,$signature=null){
        $this->response=$this->response->withHeader('Cache-Control','private, no-store')->withHeader('Referrer-Policy','no-referrer')->withHeader('X-Robots-Tag','noindex, nofollow');
        $purchase=CommercePurchases::approval((string)$code,(string)$signature);$error=null;
        if($purchase&&$this->request->is('post')){
            try{
                $purchase=CommercePurchases::approve((string)$code,(string)$signature,function($data,$id){return $this->loadComponent('Admin.Payment')->savePayment($data,$id);});
                CommerceNotifications::purchase((int)$purchase['order_id'],'approved',function($data){return $this->loadComponent('Email')->sendEmail($data);},$this->request->host());
            }catch(\Throwable $e){$error=$e instanceof \InvalidArgumentException?$e->getMessage():'Chưa duyệt được đơn. Vui lòng kiểm tra trong admin.';}
        }
        $approved=$purchase&&$purchase['approved_at']&&CommercePurchases::paid($purchase);
        $products='';
        if($purchase&&$purchase['kind']!=='document'){
            $rows=CommercePurchases::db()->execute("SELECT pc.name FROM orders_item i JOIN products_content pc ON pc.product_id=i.product_id AND pc.lang='vi' WHERE i.order_id=?",[$purchase['order_id']])->fetchAll('assoc');
            $products=implode(', ',array_column($rows,'name'));
        }
        if(!$purchase)$this->response=$this->response->withStatus(404);
        $this->set(compact('purchase','approved','error','products'));$this->set('title_for_layout','Duyệt thanh toán | MedUC');
        $this->viewBuilder()->setLayout('purchase_approval');
    }
}
