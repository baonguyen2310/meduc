<?php
/** Real commits on synthetic fixtures, independently observed; email is recorded in memory; fixtures are deleted. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||($argv[1]??'')!=='--fixtures')exit(1);
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';
(new App\Application($root.'/coredaca/config'))->bootstrap();
use App\Service\CommercePurchases as Purchases;
use App\Service\CommerceNotifications as Notices;
use App\Service\CoursePricing;
use App\Service\DocumentCredits as Credits;
use App\Service\DocumentDownloads as Downloads;
use Cake\ORM\TableRegistry;
function commitExpect($ok,$message){if(!$ok)throw new RuntimeException($message);}
class PaymentCommitResponse extends RuntimeException {
    public $result;
    public function __construct(array $result){$this->result=$result;parent::__construct('Fixture response');}
}
class PaymentCommitController extends Admin\Controller\OrderController {
    protected function responseJson($params=[]){throw new PaymentCommitResponse($params);}
}
class PaymentCommitAuth extends Cake\Controller\Component {
    public function user($key=null){return $key==='id'?1:['id'=>1];}
}
class PaymentCommitEmail extends Cake\Controller\Component {
    public $sent=[];
    public function sendEmail($data){$this->sent[]=$data;return [CODE=>SUCCESS,DATA=>['provider_id'=>'commit-fixture']];}
}
$db=Purchases::db();$cid=0;$orderIds=[];$checks=[];
$email='payment-commit-'.bin2hex(random_bytes(8)).'@example.invalid';
try{
    commitExpect(!$db->inTransaction(),'Commit test must not run inside another transaction.');
    $observer=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USERNAME,DB_PASSWORD,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
    $db->insert('customers',['code'=>'PAY-'.bin2hex(random_bytes(6)),'full_name'=>'Kiểm thử giao dịch duyệt','phone'=>'0912345678','email'=>$email,'status'=>1,'deleted'=>0,'created'=>time()]);
    $cid=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);$customer=App\Service\CheckoutContact::customer($cid);
    $backend=new App\Controller\CoursePriceController((new Cake\Http\ServerRequest())->withMethod('POST'));
    $save=function($data)use($backend){return $backend->loadComponent('Admin.Order')->saveOrder($data);};
    $pay=function($data,$id=null)use($backend){return $backend->loadComponent('Admin.Payment')->savePayment($data,$id);};
    $boards=[];foreach(CoursePricing::lists(true) as $board)$boards[$board['course_type']]=$board;
    $approve=function($id)use($email,$observer,&$checks){
        $request=(new Cake\Http\ServerRequest(['environment'=>['REQUEST_METHOD'=>'POST','HTTP_HOST'=>'meduc.vn']]))->withMethod('POST')->withParsedBody(['approve_order'=>'1']);
        $controller=new PaymentCommitController($request);
        $controller->components()->set('Auth',new PaymentCommitAuth($controller->components()));
        $mail=new PaymentCommitEmail($controller->components());$controller->components()->set('Email',$mail);
        try{$controller->paymentConfirm($id);throw new LogicException('Controller did not return a response.');}
        catch(PaymentCommitResponse $r){commitExpect(($r->result[CODE]??'')===SUCCESS,'Admin approval failed: '.($r->result[MESSAGE]??''));}
        commitExpect(!Purchases::db()->inTransaction(),'Approval left an unfinished transaction.');
        $query=$observer->prepare('SELECT approved_at FROM commerce_purchases WHERE order_id=?');$query->execute([$id]);
        commitExpect((int)$query->fetchColumn()>0,'Approval did not persist outside its own connection.');
        commitExpect(count($mail->sent)===1&&$mail->sent[0]['to_email']===$email,'Admin approval did not send exactly one buyer email.');
        $before=Purchases::get($id);
        try{$controller->paymentConfirm($id);}catch(PaymentCommitResponse $r){commitExpect(($r->result[CODE]??'')===SUCCESS,'Repeated approval failed.');}
        commitExpect(count($mail->sent)===1,'Repeated admin approval duplicated the email.');
        $same=Purchases::approve($before['public_code'],Purchases::approvalSignature($before),function(){throw new RuntimeException('Email approval duplicated payment.');});
        Notices::purchase($id,'approved',function($data)use($mail){return $mail->sendEmail($data);});
        commitExpect(count($mail->sent)===1&&$same['approved_at']===$before['approved_at'],'Email/admin approval paths duplicated notification or access.');
    };
    foreach(['document','quiz','knowledge','exam_solution'] as $kind){
        $board=$boards[$kind];$package=CoursePricing::packages((int)$board['id'])[0];
        $ids=$kind==='document'?[]:array_map('intval',array_column(array_slice(CoursePricing::courses((int)$board['id']),0,(int)$package['course_count']),'id'));
        $p=Purchases::create($customer,CoursePricing::quote((int)$package['id'],$ids),$save);$id=(int)$p['order_id'];$orderIds[]=$id;
        $r=$pay(['foreign_id'=>$id,'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$cid,'type'=>1,'amount'=>$p['amount'],'payment_method'=>BANK,'status'=>2]);
        commitExpect($r[CODE]===SUCCESS,'Pending receipt failed.');Purchases::report($id);
        $approve($id);
        $query=$observer->prepare("SELECT COUNT(*) FROM payments WHERE foreign_type='order' AND foreign_id=? AND status=1 AND type=1");$query->execute([$id]);
        commitExpect((int)$query->fetchColumn()===1,'Approval did not confirm exactly one receipt.');
        if($ids){$query=$observer->prepare('SELECT COUNT(*) FROM course_enrollments WHERE customer_id=? AND order_id=? AND status=1 AND deleted=0');$query->execute([$cid,$id]);commitExpect((int)$query->fetchColumn()===count($ids),'Committed course access missing.');}
        $checks[]=$kind.'_admin_approval_commits_access_and_sends_buyer_email_once';
    }
    $file=['article_id'=>1,'file_index'=>0,'file_key'=>hash('sha256',$email),'document_title'=>'Tài liệu cũ kiểm thử','document_url'=>'/tai-lieu-cu','file_name'=>'fixture.pdf','file_url'=>'https://meduc.vn/cdn/media/fixture.pdf','amount'=>Downloads::PRICE];
    $service=new Downloads();$old=$service->create($customer,$file,$save);$id=(int)$old['order_id'];$orderIds[]=$id;
    $service->report($old['code'],$cid,$pay);commitExpect(Credits::importLegacy($id),'Legacy import failed.');
    $balance=Credits::balance($cid);$approve($id);
    commitExpect(Credits::balance($cid)===$balance+1,'Legacy approval did not commit one shared download credit.');
    $checks[]='already_imported_legacy_order_commits_credit_and_sends_buyer_email_once';
    $result=['passed'=>$checks,'fixtures'=>'committed and cleaned','independent_connection_verified'=>true,'external_email_or_payment'=>false];
}finally{
    if($db->inTransaction())$db->rollback(true);
    $db->delete('commerce_notifications',['recipient'=>$email]);
    if($cid){$db->delete('course_enrollments',['customer_id'=>$cid]);$db->delete('document_credit_uses',['customer_id'=>$cid]);}
    foreach($orderIds as $id){
        foreach(['document_download_purchases','commerce_purchases','orders_item','orders_contact'] as $table)$db->delete($table,['order_id'=>$id]);
        $db->delete('payments',['foreign_type'=>ORDER,'foreign_id'=>$id]);$db->delete('orders',['id'=>$id]);
    }
    if($cid){$db->delete('customers_account',['customer_id'=>$cid]);$db->delete('customers_address',['customer_id'=>$cid]);$db->delete('customers',['id'=>$cid]);}
}
echo json_encode($result,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE)."\n";
