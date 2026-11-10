<?php
/** Isolated purchase/access fixtures, all rolled back; email transport is replaced by an in-memory recorder. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||($argv[1]??'')!=='--fixtures')exit(1);
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';$app=new App\Application($root.'/coredaca/config');$app->bootstrap();
foreach(['LANGUAGE'=>'vi','CODE_TEMPLATE'=>'app01','CDN_URL'=>'https://cdn.meduc.vn','CURRENCY_UNIT'=>'đ'] as $k=>$v)if(!defined($k))define($k,$v);
Cake\Core\Configure::write('App.paths.templates',[$root.'/templates/app01/']);
use App\Service\CommercePurchases as Purchases;use App\Service\CommerceNotifications as Notices;use App\Service\DocumentCredits as Credits;use App\Service\CoursePricing;use Cake\ORM\TableRegistry;
function commerceExpect($yes,$why){if(!$yes)throw new RuntimeException($why);}
$db=Purchases::db();$db->begin();$checks=[];
try{
 $email='commerce-fixture-'.bin2hex(random_bytes(6)).'@example.invalid';$db->insert('customers',['full_name'=>'Kiểm thử gói mua','email'=>$email,'phone'=>'0912345678','code'=>'COM-'.bin2hex(random_bytes(5)),'status'=>1,'deleted'=>0,'created'=>time()]);$cid=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);$customer=App\Service\CheckoutContact::customer($cid);
 $controller=new App\Controller\CoursePriceController((new Cake\Http\ServerRequest())->withMethod('POST'));
 $save=function($data)use($controller){return $controller->loadComponent('Admin.Order')->saveOrder($data);};
 $savePayment=function($data,$id=null)use($controller){return $controller->loadComponent('Admin.Payment')->savePayment($data,$id);};
 $make=function($package,$ids=[])use($customer,$save){return Purchases::create($customer,CoursePricing::quote((int)$package['id'],$ids),$save);};
 $report=function($p)use($db,$savePayment,$cid){$r=$savePayment(['foreign_type'=>ORDER,'foreign_id'=>$p['order_id'],'object_type'=>CUSTOMER,'object_id'=>$cid,'type'=>1,'amount'=>$p['amount'],'payment_method'=>BANK,'status'=>2]);commerceExpect($r[CODE]===SUCCESS,'Pending receipt failed');$db->update('orders',['status'=>NEW_ORDER],['id'=>$p['order_id']]);Purchases::report((int)$p['order_id']);return Purchases::get((int)$p['order_id']);};
 $approve=function($p)use($savePayment){return Purchases::approve($p['public_code'],Purchases::approvalSignature($p),$savePayment);};
 $boards=[];foreach(CoursePricing::lists(true) as $l)$boards[$l['course_type']]=$l;
 $courses=CoursePricing::courses((int)$boards['knowledge']['id']);$package=CoursePricing::packages((int)$boards['knowledge']['id'])[2];
 commerceExpect($package['course_count']==4&&$package['bonus_count']==1&&$package['recommended']&&$package['amount']==9500000&&$package['price']==16000000,'3+1 package data incorrect.');
 try{CoursePricing::quote((int)$package['id'],array_column(array_slice($courses,0,3),'id'));throw new RuntimeException('3+1 accepted only 3 subjects');}catch(InvalidArgumentException $e){}
 $bundle=$make($package,array_column(array_slice($courses,0,4),'id'));commerceExpect(count($db->execute('SELECT id FROM orders_item WHERE order_id=?',[$bundle['order_id']])->fetchAll('assoc'))===4,'Gift subject missing from invoice.');
 $checks[]='knowledge_3_plus_1_four_distinct_subjects_9500000_with_visible_discount';
 $quizCourses=CoursePricing::courses((int)$boards['quiz']['id']);$qa=(int)$quizCourses[0]['id'];$qb=(int)$quizCourses[1]['id'];$plans=CoursePricing::packages((int)$boards['quiz']['id']);
 commerceExpect(array_map('intval',array_column($plans,'duration_months'))===[1,6,12]&&array_map('intval',array_column($plans,'amount'))===[9999,29999,49999],'Quiz subscription prices incorrect.');
 $p=$report($make($plans[0],[$qa]));commerceExpect(!isset(TableRegistry::get('CourseEnrollments')->activeCourses($cid)[$qa]),'Report opened quiz access.');
 commerceExpect(!Purchases::approval($p['public_code'],str_repeat('0',64)),'Forged approval accepted.');
 $sig=Purchases::approvalSignature($p);$readonly=Purchases::approval($p['public_code'],$sig);commerceExpect(!$readonly['approved_at'],'Reading approval link changed access.');
 $p=$approve($p);$expiry=(int)$p['expires_at'];commerceExpect($expiry===Purchases::addMonths((int)$p['approved_at'],1),'Term did not start at approval.');
 $active=TableRegistry::get('CourseEnrollments')->activeCourses($cid);commerceExpect(isset($active[$qa])&&!isset($active[$qb]),'Subscription leaked to another subject.');
 commerceExpect((int)$approve($p)['expires_at']===$expiry,'Repeated approval extended expiry.');
 $six=$approve($report($make($plans[1],[$qa])));commerceExpect((int)$six['expires_at']===Purchases::addMonths($expiry,6),'Renewal did not extend the active term.');
 $db->execute("UPDATE payments SET status=0 WHERE foreign_type='order' AND foreign_id=?",[$six['order_id']]);TableRegistry::get('Orders')->updateAfterPayment($six['order_id']);
 commerceExpect((int)TableRegistry::get('CourseEnrollments')->activeCourses($cid)[$qa]['expires_at']===$expiry,'Revoked renewal lost earlier valid access.');
 $past=(new DateTimeImmutable('2020-01-01'))->getTimestamp();$db->update('commerce_purchases',['approved_at'=>$past],['order_id'=>$p['order_id']]);Purchases::syncOrder((int)$p['order_id']);
 commerceExpect(!isset(TableRegistry::get('CourseEnrollments')->activeCourses($cid)[$qa]),'Expired subscription still active.');
 $slot=$db->execute('SELECT quiz_id FROM course_quiz_slots WHERE product_id=? AND slot=2 LIMIT 1',[$qa])->fetchColumn(0);
 if($slot){$access=$controller->loadComponent('QuizAnswer')->courseQuizAccess(['id'=>$cid,'code'=>$customer['code']],$qa,(int)$slot);commerceExpect(empty($access['allowed']),'Expired paid quiz API remained accessible.');}
 $checks[]='quiz_per_subject_1_6_12_months_manual_approval_renewal_idempotency_revocation_expiry';
 commerceExpect(date('Y-m-d',Purchases::addMonths(strtotime('2027-01-31 12:00:00'),1))==='2027-02-28','Calendar-month end overflow.');
 $checks[]='calendar_month_expiry_clamps_end_of_month';
 $partial=$report($make($plans[0],[$qb]));
 $savePayment(['foreign_type'=>ORDER,'foreign_id'=>$partial['order_id'],'object_type'=>CUSTOMER,'object_id'=>$cid,'type'=>1,'amount'=>1000,'payment_method'=>BANK,'status'=>1]);
 try{$approve($partial);throw new RuntimeException('Email approval over-counted a partially confirmed invoice');}catch(InvalidArgumentException $e){}
 commerceExpect(!isset(TableRegistry::get('CourseEnrollments')->activeCourses($cid)[$qb]),'Partial payment granted access.');
 commerceExpect((int)CoursePricing::startingOffer($qa)['amount']===9999,'Quiz detail advertises a legacy SKU price.');
 $checks[]='partial_payment_requires_admin_reconciliation_entry_price_matches_package';
 $docs=Credits::packages();commerceExpect(array_map('intval',array_column($docs,'credit_count'))===[1,3,5]&&array_map('intval',array_column($docs,'amount'))===[9999,19999,29999],'Credit packages incorrect.');
 $credit=$report($make($docs[2]));commerceExpect(Credits::balance($cid)===0,'Unconfirmed credits appeared in wallet.');$credit=$approve($credit);commerceExpect(Credits::balance($cid)===5,'Approved credit bundle not added.');$approve($credit);commerceExpect(Credits::balance($cid)===5,'Approval added credits twice.');
 $file=['article_id'=>1,'file_index'=>0,'file_key'=>hash('sha256','commerce-test-0'),'file_name'=>'fixture.pdf','file_url'=>'https://meduc.vn/media/fixture.pdf'];
 $issued=Credits::issue($cid,$file);$token=basename($issued['url']);commerceExpect(Credits::balance($cid)===5,'Ticket creation charged before file was opened.');
 Credits::consume($token,$cid);commerceExpect(Credits::balance($cid)===4,'First download not charged exactly once.');Credits::consume($token,$cid);commerceExpect(Credits::balance($cid)===4,'Range/retry charged twice.');
 commerceExpect(!Credits::ticket($token,$cid+1000000),'Credit ticket accepted another owner.');
 $tokens=[];for($i=1;$i<=5;$i++){$file['file_key']=hash('sha256','commerce-test-'.$i);$t=Credits::issue($cid,$file);$tokens[]=basename($t['url']);}
 for($i=0;$i<4;$i++)Credits::consume($tokens[$i],$cid);
 try{Credits::consume($tokens[4],$cid);throw new RuntimeException('Credit balance overdrew');}catch(InvalidArgumentException $e){}
 commerceExpect(Credits::balance($cid)===0,'Empty wallet incorrect.');
 $checks[]='credit_wallet_manual_grant_shared_balance_one_charge_retries_no_overdraft_owner_bound';
 $delivered=[];$send=function($data)use(&$delivered){$delivered[]=$data;return [CODE=>SUCCESS,DATA=>['provider_id'=>'fixture-provider']];};
 Notices::purchase((int)$p['order_id'],'reported',$send,'meducv3.duckdns.org');commerceExpect(count($delivered)===2,'Missing buyer or admin purchase email.');
 Notices::purchase((int)$p['order_id'],'reported',$send,'meducv3.duckdns.org');commerceExpect(count($delivered)===2,'Report email was duplicated.');
 Notices::purchase((int)$p['order_id'],'approved',$send,'meducv3.duckdns.org');commerceExpect(count($delivered)===4,'Approval email missing.');
 commerceExpect($delivered[0]['to_email']==='baonguyencoder97@gmail.com'&&strpos($delivered[0]['content'],'/duyet-thanh-toan/')!==false&&strpos($delivered[1]['content'],'/duyet-thanh-toan/')===false,'Admin approval link or recipient incorrect.');
 $checks[]='buyer_admin_mail_outbox_idempotent_scoped_approval_link';
 Notices::purchase((int)$credit['order_id'],'reported',function(){throw new RuntimeException('Simulated transport timeout');},'meducv3.duckdns.org');
 $failed=$db->execute("SELECT id FROM commerce_notifications WHERE status='failed' AND subject LIKE ?",['%'.$credit['order_code']])->fetchAll('assoc');
 commerceExpect(count($failed)===2&&Credits::balance($cid)===0,'Mail failure changed credit fulfilment or lost retry records.');
 $db->execute("UPDATE commerce_notifications SET updated_at=0 WHERE status='failed' AND subject LIKE ?",['%'.$credit['order_code']]);
 foreach($failed as $mail)commerceExpect(Notices::deliver((int)$mail['id'],$send),'Outbox retry did not send.');
 commerceExpect(count($delivered)===6,'Retry did not deliver both roles exactly once.');
 $checks[]='mail_failure_does_not_change_purchase_outbox_can_retry';
 echo json_encode(['passed'=>$checks,'fixtures'=>'rolled back','external_email_or_payment'=>false],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE)."\n";
}finally{$db->rollback();}
