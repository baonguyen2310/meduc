<?php
/** Synthetic order fixtures only; the transport records messages and never sends real email. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||($argv[1]??'')!=='--fixtures')exit(1);
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';
(new App\Application($root.'/coredaca/config'))->bootstrap();
use App\Service\CommercePurchases as Purchases;
use App\Service\CommerceNotifications as Notices;
use App\Service\CoursePricing;
function mailExpect($condition,string $message):void {if(!$condition)throw new RuntimeException($message);}
$db=Purchases::db();$cid=0;$orderIds=[];$contactIds=[];$checks=[];$messages=[];
$email='mail-policy-'.bin2hex(random_bytes(8)).'@example.invalid';
$send=function(array $data)use(&$messages):array {$messages[]=$data;return [CODE=>SUCCESS,DATA=>['provider_id'=>'mail-policy-fixture']];};
try{
    $db->insert('customers',['code'=>'MAIL-'.bin2hex(random_bytes(6)),'full_name'=>'Kiểm thử quy tắc email','email'=>$email,'phone'=>'0912345678','status'=>1,'deleted'=>0,'created'=>time()]);
    $cid=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    $customer=App\Service\CheckoutContact::customer($cid);
    $controller=new App\Controller\CoursePriceController((new Cake\Http\ServerRequest())->withMethod('POST'));
    $save=function($data)use($controller){return $controller->loadComponent('Admin.Order')->saveOrder($data);};
    $boards=[];foreach(CoursePricing::lists(true) as $board)$boards[$board['course_type']]=$board;
    foreach(['knowledge','exam_solution','quiz','document'] as $kind){
        $board=$boards[$kind];$package=CoursePricing::packages((int)$board['id'])[0];
        $ids=$kind==='document'?[]:array_map('intval',array_column(array_slice(CoursePricing::courses((int)$board['id']),0,(int)$package['course_count']),'id'));
        $p=Purchases::create($customer,CoursePricing::quote((int)$package['id'],$ids),$save);$id=(int)$p['order_id'];$orderIds[]=$id;Purchases::report($id);
        $before=count($messages);
        foreach(['leetran2404@gmail.com',' LEETRAN2404@GMAIL.COM '] as $blocked){
            $db->update('orders_contact',['email'=>$blocked],['order_id'=>$id]);Notices::purchase($id,'reported',$send);
            mailExpect(count($messages)===$before,$kind.' test purchase emailed admin.');
            mailExpect((int)$db->execute('SELECT COUNT(*) FROM commerce_notifications WHERE dedupe_key=?',[hash('sha256','purchase:'.$id.':reported:admin')])->fetchColumn(0)===0,'Suppressed notification was queued for retry.');
        }
        $db->update('orders_contact',['email'=>$email],['order_id'=>$id]);Notices::purchase($id,'reported',$send);
        mailExpect(count($messages)===$before+1&&$messages[$before]['to_email']===Notices::adminEmail(),$kind.' normal purchase lost its admin notification.');
        Notices::purchase($id,'reported',$send);mailExpect(count($messages)===$before+1,'Normal purchase notification was duplicated.');
        $checks[]=$kind.'_test_admin_suppressed_normal_admin_sent_once';
    }
    foreach(['leetran2404@gmail.com','LEETRAN2404@GMAIL.COM',$email] as $buyer){
        $value=['cartId'=>'MAIL-'.bin2hex(random_bytes(8)),'customer_id'=>$cid,'full_name'=>'Kiểm thử sách','email'=>$buyer,'phone'=>'0912345678','address'=>'Địa chỉ kiểm thử','totalPrice'=>10000,'payment'=>'bank','cartProducts'=>'[]'];
        $db->insert('contacts',['value'=>json_encode($value,JSON_UNESCAPED_UNICODE),'status'=>2]);$id=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);$contactIds[]=$id;$before=count($messages);
        Notices::book($id,$send);
        $sent=array_slice($messages,$before);$blocked=strcasecmp($buyer,'leetran2404@gmail.com')===0;
        mailExpect(count($sent)===($blocked?1:2),'Book notification recipient count is incorrect.');
        mailExpect($sent[count($sent)-1]['to_email']===$buyer,'Book buyer confirmation was changed.');
        if(!$blocked)mailExpect($sent[0]['to_email']===Notices::adminEmail(),'Normal book admin notification was lost.');
        Notices::book($id,$send);mailExpect(count($messages)===$before+count($sent),'Book notifications were duplicated.');
    }
    $checks[]='books_test_admin_suppressed_buyer_unchanged_normal_both_sent_once';
    $result=['passed'=>$checks,'external_email_sent'=>false,'fixtures'=>'cleaned'];
}finally{
    if($db->inTransaction())$db->rollback(true);
    foreach($orderIds as $id){
        foreach(['reported:admin','approved:buyer'] as $event)$db->delete('commerce_notifications',['dedupe_key'=>hash('sha256','purchase:'.$id.':'.$event)]);
        foreach(['commerce_purchases','orders_item','orders_contact'] as $table)$db->delete($table,['order_id'=>$id]);
        $db->delete('orders',['id'=>$id]);
    }
    foreach($contactIds as $id){foreach(['admin','buyer'] as $role)$db->delete('commerce_notifications',['dedupe_key'=>hash('sha256','book:'.$id.':'.$role)]);$db->delete('contacts',['id'=>$id]);}
    if($cid){$db->delete('customers_account',['customer_id'=>$cid]);$db->delete('customers_address',['customer_id'=>$cid]);$db->delete('customers',['id'=>$cid]);}
}
echo json_encode($result,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE)."\n";
