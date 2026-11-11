<?php
/** Transactional approval fixtures; no external payment, download or email is performed. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||($argv[1]??'')!=='--fixtures')exit(1);
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';
(new App\Application($root.'/coredaca/config'))->bootstrap();
if(!defined('CDN_URL'))define('CDN_URL','https://cdn.meduc.vn');
if(!defined('LANGUAGE'))define('LANGUAGE','vi');
use App\Service\CommercePurchases as Purchases;
use App\Service\DocumentCredits as Credits;
use App\Service\DocumentDownloads as Downloads;
use App\Service\OrderPayments as Approvals;
use App\Service\CoursePricing;
use Cake\ORM\TableRegistry;
function approvalExpect($condition,$message){if(!$condition)throw new RuntimeException($message);}
$db=Purchases::db();$db->begin();$checks=[];
try{
    $email='approval-fixture-'.bin2hex(random_bytes(6)).'@example.invalid';
    $db->insert('customers',['code'=>'APP-'.bin2hex(random_bytes(6)),'full_name'=>'Kiểm thử duyệt đơn','email'=>$email,'phone'=>'0912345678','status'=>1,'deleted'=>0,'created'=>time()]);
    $cid=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    $customer=App\Service\CheckoutContact::customer($cid);
    $controller=new App\Controller\CoursePriceController((new Cake\Http\ServerRequest())->withMethod('POST'));
    $save=function($data)use($controller){return $controller->loadComponent('Admin.Order')->saveOrder($data);};
    $pay=function($data,$id=null)use($controller){return $controller->loadComponent('Admin.Payment')->savePayment($data,$id);};
    $boards=[];foreach(CoursePricing::lists(true) as $board)$boards[$board['course_type']]=$board;
    $make=function($kind)use($boards,$customer,$save){
        $board=$boards[$kind];$package=CoursePricing::packages((int)$board['id'])[0];
        $ids=$kind==='document'?[]:array_map('intval',array_column(array_slice(CoursePricing::courses((int)$board['id']),0,(int)$package['course_count']),'id'));
        return Purchases::create($customer,CoursePricing::quote((int)$package['id'],$ids),$save);
    };
    $report=function($p)use($pay,$cid){
        $result=$pay(['foreign_id'=>$p['order_id'],'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$cid,'type'=>1,'amount'=>$p['amount'],'payment_method'=>BANK,'status'=>2]);
        approvalExpect($result[CODE]===SUCCESS,'Could not create pending receipt.');Purchases::report((int)$p['order_id']);
    };
    foreach(['knowledge','exam_solution','quiz','document'] as $kind){
        $p=$make($kind);$id=(int)$p['order_id'];$report($p);
        $summary=Approvals::summaries([$id])[$id];approvalExpect($summary['kind']===$kind&&$summary['can_approve']&&!$summary['paid'],'Wrong kind or pending approval.');
        $filtered=TableRegistry::get('Orders')->queryListOrders([FILTER=>['type'=>ORDER,'order_kind'=>$kind,'customer_id'=>$cid],'get_contact'=>true])->toArray();
        approvalExpect(in_array($id,array_map(function($r){return (int)$r['id'];},$filtered),true),'Order-kind filter missed its fixture.');
        $paid=Approvals::approve($id,$pay,0);approvalExpect($paid['paid']&&!$paid['can_approve'],'Approval did not mark payment complete.');
        $purchase=Purchases::get($id);approvalExpect(!empty($purchase['approved_at'])&&Purchases::paid($purchase),'Access was not fulfilled.');
        $count=(int)$db->execute("SELECT COUNT(*) FROM payments WHERE foreign_id=? AND foreign_type='order'",[$id])->fetchColumn(0);
        Approvals::approve($id,$pay,0);
        approvalExpect($count===1&&(int)$db->execute("SELECT COUNT(*) FROM payments WHERE foreign_id=? AND foreign_type='order'",[$id])->fetchColumn(0)===1,'Approval created a duplicate receipt.');
        if($kind!=='document'){
            $course=(int)$db->execute('SELECT product_id FROM orders_item WHERE order_id=? LIMIT 1',[$id])->fetchColumn(0);
            approvalExpect(isset(TableRegistry::get('CourseEnrollments')->activeCourses($cid)[$course]),'Paid course access missing.');
        }
    }
    $checks[]='four_order_kinds_filters_pending_receipt_approval_access_and_idempotency';

    $manual=$make('document');$manualId=(int)$manual['order_id'];Approvals::approve($manualId,$pay,0);
    $sent=[];$send=function($data)use(&$sent){$sent[]=$data;return [CODE=>SUCCESS,DATA=>['provider_id'=>'fixture']];};
    App\Service\CommerceNotifications::purchase($manualId,'approved',$send);
    App\Service\CommerceNotifications::purchase($manualId,'approved',$send);
    approvalExpect(count($sent)===1&&$sent[0]['to_email']===$email,'Manual approval did not email only the buyer once.');
    $checks[]='manual_approval_without_transfer_report_and_one_buyer_email';

    $partial=$make('document');$partialId=(int)$partial['order_id'];$report($partial);
    $pay(['foreign_id'=>$partialId,'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$cid,'type'=>1,'amount'=>1000,'payment_method'=>BANK,'status'=>1]);
    approvalExpect(Approvals::summaries([$partialId])[$partialId]['remaining']===$partial['amount']-1000.0,'Incorrect remaining payment amount.');
    Approvals::approve($partialId,$pay,0);Approvals::approve($partialId,$pay,0);
    $confirmed=(float)$db->execute("SELECT SUM(amount) FROM payments WHERE foreign_type='order' AND foreign_id=? AND type=1 AND status=1",[$partialId])->fetchColumn(0);
    approvalExpect($confirmed===(float)$partial['amount'],'Partial payment approval overcharged or duplicated the payment.');
    $checks[]='partial_payment_approves_only_the_remaining_amount';

    $failed=$make('document');$failedId=(int)$failed['order_id'];$report($failed);
    try{Approvals::approve($failedId,function(){return [CODE=>ERROR];},0);throw new LogicException('Failed payment accepted.');}catch(RuntimeException $e){if($e instanceof LogicException)throw $e;}
    approvalExpect(!Purchases::get($failedId)['approved_at']&&!Approvals::summaries([$failedId])[$failedId]['paid'],'Failed approval granted access.');
    $db->update('orders',['status'=>CANCEL],['id'=>$failedId]);
    try{Approvals::approve($failedId,$pay,0);throw new LogicException('Cancelled order accepted.');}catch(InvalidArgumentException $e){}
    $db->update('orders',['status'=>NEW_ORDER,'deleted'=>1],['id'=>$failedId]);
    try{Approvals::approve($failedId,$pay,0);throw new LogicException('Deleted order accepted.');}catch(InvalidArgumentException $e){}
    $checks[]='failed_cancelled_deleted_orders_do_not_grant_access';

    $file=['article_id'=>1,'file_index'=>0,'file_key'=>hash('sha256','legacy-'.random_bytes(5)),'document_title'=>'Tài liệu đã chọn ban đầu','document_url'=>'/tai-lieu-cu','file_name'=>'tai-lieu-cu.pdf','file_url'=>'https://cdn.meduc.vn/tai-lieu-cu.pdf','amount'=>Downloads::PRICE];
    $service=new Downloads();$old=$service->create($customer,$file,$save);$oldId=(int)$old['order_id'];
    $before=$db->execute('SELECT * FROM document_download_purchases WHERE order_id=?',[$oldId])->fetch('assoc');
    $items=$db->execute('SELECT * FROM orders_item WHERE order_id=?',[$oldId])->fetchAll('assoc');
    $links=Approvals::documents($oldId);
    approvalExpect($links['title']===$file['document_title']&&$links['files'][0]['url']===$file['file_url']&&$links['files'][0]['name']===$file['file_name'],'Admin cannot download the original selected file.');
    $balance=Credits::balance($cid);Approvals::approve($oldId,$pay,0);
    approvalExpect(Credits::balance($cid)===$balance+1,'Old order did not grant exactly one shared credit.');
    approvalExpect(!Credits::importLegacy($oldId),'Legacy import duplicated a grant.');
    approvalExpect($before===$db->execute('SELECT * FROM document_download_purchases WHERE order_id=?',[$oldId])->fetch('assoc')&&$items===$db->execute('SELECT * FROM orders_item WHERE order_id=?',[$oldId])->fetchAll('assoc'),'Original file or invoice items changed.');
    try{$service->issue($old['code'],$cid);throw new LogicException('Legacy endpoint granted a second entitlement.');}catch(InvalidArgumentException $e){}
    $other=$file;$other['article_id']=2;$other['file_key']=hash('sha256','other-'.random_bytes(5));$other['file_name']='tai-lieu-khac.pdf';
    $ticket=Credits::issue($cid,$other);$token=basename($ticket['url']);Credits::consume($token,$cid);Credits::consume($token,$cid);
    approvalExpect(Credits::balance($cid)===$balance,'Shared credit was not usable for a different file or retry charged twice.');
    $checks[]='legacy_order_preserves_original_selection_one_shared_credit_no_double_download';

    $usedFile=$file;$usedFile['file_key']=hash('sha256','used-'.random_bytes(5));
    $used=$service->create($customer,$usedFile,$save);$usedId=(int)$used['order_id'];
    $pay(['foreign_id'=>$usedId,'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$cid,'type'=>1,'amount'=>Downloads::PRICE,'payment_method'=>BANK,'status'=>1]);
    $oldTicket=$service->issue($used['code'],$cid);$oldToken=basename($oldTicket['url']);$service->consume($used['code'],$oldToken,$cid);
    $balance=Credits::balance($cid);Credits::importLegacy($usedId);
    approvalExpect(Credits::balance($cid)===$balance&&Credits::ticket($oldToken,$cid),'Used legacy credit was regranted or its retry window lost.');
    $checks[]='previously_used_legacy_purchase_is_not_granted_again';

    $newDocument=$make('document');$newId=(int)$newDocument['order_id'];
    $context=['selected_document'=>['title'=>'Tài liệu đặt mua','file_url'=>'https://meduc.vn/cdn/media/tai lieu.pdf','file_name'=>'tai lieu.pdf']];
    $db->update('commerce_purchases',['context_json'=>json_encode($context)],['order_id'=>$newId]);
    $wallet=Credits::balance($cid);$links=Approvals::documents($newId);
    approvalExpect($links['files'][0]['url']==='https://meduc.vn/cdn/media/tai%20lieu.pdf'&&Credits::balance($cid)===$wallet&&!Purchases::get($newId)['approved_at'],'Admin download links consumed credit or approved an order.');
    $context['selected_document']['file_url']='javascript:alert(1)';
    $db->update('commerce_purchases',['context_json'=>json_encode($context)],['order_id'=>$newId]);
    approvalExpect(Approvals::documents($newId)['files']===[],'Unsafe file URL rendered in admin.');
    $source=$db->execute("SELECT l.url,l.foreign_id article_id FROM links l JOIN articles a ON a.id=l.foreign_id JOIN categories_article ca ON ca.article_id=a.id WHERE l.type=? AND l.lang='vi' AND l.deleted=0 AND a.deleted=0 AND a.status=1 AND a.draft=0 AND ca.category_id=48 AND a.files IS NOT NULL AND a.files<>'[]' LIMIT 1",[ARTICLE_DETAIL])->fetch('assoc');
    if(!$source)throw new RuntimeException('No source document available for fallback fixture.');
    $db->update('commerce_purchases',['context_json'=>json_encode(['document_url'=>'/'.$source['url']])],['order_id'=>$newId]);
    approvalExpect(count(Approvals::documents($newId)['files'])>0,'Earlier credit order could not resolve its document files.');
    $quoted=(new Downloads('vi'))->quote((int)$source['article_id'],0);$nonce=bin2hex(random_bytes(24));
    $request=(new Cake\Http\ServerRequest())->withMethod('POST');$session=$request->getSession();$session->write(MEMBER,['id'=>$cid]);
    $session->write('DocumentDownload.tokens',[$nonce=>['article'=>$quoted['article_id'],'index'=>0,'file'=>$quoted['file_key'],'customer'=>$cid,'expires'=>time()+600]]);
    $package=CoursePricing::packages((int)$boards['document']['id'])[0];
    $request=$request->withParsedBody(['nonce'=>$nonce,'expected_customer_id'=>$cid,'package_id'=>$package['id']]);
    $created=json_decode((string)(new App\Controller\DocumentDownloadController($request))->purchase()->getBody(),true);
    approvalExpect(($created['code']??'')==='success','Document checkout did not create the fixture order.');
    $code=basename($created['data']['redirect']);$saved=Purchases::owned($code,$cid);$context=json_decode($saved['context_json'],true);
    approvalExpect($context['selected_document']['file_url']===$quoted['file_url']&&Approvals::documents((int)$saved['order_id'])['files'][0]['name']===$quoted['file_name'],'New checkout did not retain the exact selected file.');
    $checks[]='admin_document_links_support_old_and_new_orders_without_spending_credits';
    echo json_encode(['passed'=>$checks,'fixtures'=>'rolled back','external_email_or_payment'=>false],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE)."\n";
}finally{$db->rollback();}
