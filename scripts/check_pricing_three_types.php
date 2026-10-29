<?php
if (PHP_SAPI !== 'cli') exit;
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);define('CDN_URL','https://meduc.vn/cdn/');
require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';require $root.'/coredaca/config/bootstrap.php';
use App\Service\CoursePricing as P;
use Cake\ORM\TableRegistry;
$db=P::db();function ok($v,$m){if(!$v)throw new RuntimeException($m);echo 'PASS '.$m."\n";}
function rejects($fn,$m){try{$fn();}catch(InvalidArgumentException $e){ok(true,$m);return;}throw new RuntimeException($m);}
$lists=[];foreach(P::lists(true)as$l)if(!isset($lists[$l['course_type']]) && count(P::courses((int)$l['id']))>=3 && count(P::packages((int)$l['id']))>=2)$lists[$l['course_type']]=$l;ok(count($lists)===3,'All three price-list types have checkout fixtures');
$catalogues=[];foreach($lists as$kind=>$list)$catalogues[$kind]=P::courses((int)$list['id']);
foreach(['knowledge','exam_solution','quiz']as$kind){$list=$lists[$kind];$courses=P::courses((int)$list['id']);ok(count($courses)>=3,$kind.' has selectable courses');$catalogues[$kind]=$courses;
 foreach($courses as$c)ok(App\Service\CourseTypes::kind((int)$c['id'])===$kind,$kind.' course '.$c['id']);
 foreach(P::packages((int)$list['id'])as$pack){$ids=array_map('intval',array_column(array_slice($courses,0,(int)$pack['course_count']),'id'));$q=P::quote((int)$pack['id'],$ids);ok($q['amount']===$pack['amount'],$kind.' server amount for '.$pack['course_count'].' courses');}
 $pack=P::packages((int)$list['id'])[0];
 foreach(['knowledge','exam_solution','quiz']as$other)if($other!==$kind)rejects(fn()=>P::quote((int)$pack['id'],[(int)$catalogues[$other][0]['id']]),'Cross-type rejection '.$kind.' / '.$other);
}
$quizPack=P::packages((int)$lists['quiz']['id'])[0];$fa=(int)$db->execute("SELECT id FROM products WHERE course_kind='fa' AND deleted=0 LIMIT 1")->fetchColumn(0);ok($fa>0,'Private Fa fixture exists');rejects(fn()=>P::quote((int)$quizPack['id'],[$fa]),'Private Fa cannot be purchased');
$two=P::packages((int)$lists['quiz']['id'])[1];$one=(int)$catalogues['quiz'][0]['id'];rejects(fn()=>P::quote((int)$two['id'],[$one,$one]),'Duplicate selection rejected');
$wrongData=['name'=>'Test pricing type','slug'=>'test-pricing-three-types','course_type'=>'exam_solution','status'=>1,'course_ids'=>[$one],'packages'=>[['name'=>'Gói 1 môn','course_count'=>1,'price'=>1500000,'sale_price'=>499000,'status'=>1]]];
rejects(fn()=>P::save(0,$wrongData),'Admin cannot assign quiz to a solution price list');
rejects(fn()=>P::save(0,array_replace($wrongData,['course_type'=>'fa','course_ids'=>[]])),'Admin cannot create a public Fa price list');
$member=$db->execute("SELECT c.* FROM customers c JOIN customers_account a ON a.customer_id=c.id WHERE a.username='user_test_01'")->fetch('assoc');ok((bool)$member,'Existing test learner available');
$baseline=(int)$db->execute('SELECT COUNT(*) FROM orders')->fetchColumn(0);
$stockBefore=$db->execute('SELECT id,quantity_available FROM products_item ORDER BY id')->fetchAll('assoc');
$orderService=(new Cake\Controller\Controller(new Cake\Http\ServerRequest()))->loadComponent('Admin.Order');
foreach($lists as$kind=>$list){
 $db->begin();try{
  $package=P::packages((int)$list['id'])[1];$ids=array_map('intval',array_column(array_slice($catalogues[$kind],0,2),'id'));$quote=P::quote((int)$package['id'],$ids);$items=[];$remaining=$quote['amount'];$n=count($quote['courses']);
  foreach($quote['courses']as$i=>$c){$price=$i===$n-1?$remaining:intdiv($quote['amount'],$n);$remaining-=$price;$items[]=['product_id'=>(int)$c['id'],'product_item_id'=>(int)$c['item_id'],'quantity'=>1,'price'=>$price,'vat_value'=>0];}
  $payload=['type'=>ORDER,'source'=>WEBSITE,'status'=>DRAFT,'note'=>'QA rollback only','contact'=>['customer_id'=>(int)$member['id'],'full_name'=>$member['full_name'],'email'=>$member['email'],'phone'=>$member['phone']?:'0900000000'],'items'=>$items];
  $result=$orderService->saveOrder($payload);ok(($result[CODE]??'')===SUCCESS,'Draft order created for '.$kind.' '.($result[MESSAGE]??''));$order=$result[DATA];$id=(int)$order['id'];
  $db->update('orders',['course_price_package_id'=>(int)$package['id'],'course_price_snapshot'=>json_encode($quote,JSON_UNESCAPED_UNICODE)],['id'=>$id]);
  $saved=$db->execute('SELECT total,course_price_package_id FROM orders WHERE id=:i',['i'=>$id])->fetch('assoc');ok((int)$saved['total']===$quote['amount'],'Order amount matches server quote '.$kind);
  $enrollments=TableRegistry::get('CourseEnrollments');$enrollments->syncOrder($id);foreach($ids as$pid){$r=$enrollments->activeCourses($member['id'])[$pid]??null;ok(!$r || (int)$r['order_id']!==$id,'Unpaid order does not grant course '.$pid);}
  // Simulated settlement only inside this rolled-back transaction. No payment gateway, messages or real funds.
  $db->update('orders',['status'=>NEW_ORDER,'point_paid'=>$quote['amount']],['id'=>$id]);ok($enrollments->syncOrder($id),'Enrollment sync '.$kind);
  foreach($ids as$pid)ok(isset($enrollments->activeCourses($member['id'])[$pid]),'Settled package grants selected course '.$pid);
  $db->update('orders',['status'=>CANCEL],['id'=>$id]);$enrollments->syncOrder($id);
  foreach($ids as$pid){$r=$enrollments->activeCourses($member['id'])[$pid]??null;ok(!$r || (int)$r['order_id']!==$id,'Cancelled order revokes its course '.$pid);}
 }finally{$db->rollback();}
}
ok((int)$db->execute('SELECT COUNT(*) FROM orders')->fetchColumn(0)===$baseline,'No QA orders persisted');
ok($stockBefore===$db->execute('SELECT id,quantity_available FROM products_item ORDER BY id')->fetchAll('assoc'),'Product stock unchanged after rollback');
echo "All three pricing checkout and enrollment paths passed.\n";
