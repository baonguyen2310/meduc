<?php
/** Committed wallet fixtures; no email or upstream download; isolated workers exercise concurrent debits. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||!in_array($argv[1]??'',['--fixtures','--consume'],true))exit(1);
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';
(new App\Application($root.'/coredaca/config'))->bootstrap();
use App\Service\CommercePurchases as Purchases;
use App\Service\DocumentCredits as Credits;
use App\Service\CoursePricing;
use App\Service\OrderPayments;

if($argv[1]==='--consume'){
    $delay=(float)($argv[4]??0)-microtime(true);if($delay>0)usleep((int)(min($delay,5)*1000000));
    try{Credits::consume((string)$argv[3],(int)$argv[2]);echo json_encode(['result'=>'consumed']);}
    catch(InvalidArgumentException $e){echo json_encode(['result'=>'blocked']);}
    catch(Throwable $e){fwrite(STDERR,get_class($e).': '.$e->getMessage());exit(1);}
    exit;
}
function downloadExpect($ok,$why){if(!$ok)throw new RuntimeException($why);}
$db=Purchases::db();$cid=0;$orders=[];$workers=[];$checks=[];
$email='download-limit-'.bin2hex(random_bytes(8)).'@example.invalid';
try{
    downloadExpect(!$db->inTransaction(),'Wallet tests need real commits, not an outer rollback transaction.');
    $db->insert('customers',['code'=>'DL-'.bin2hex(random_bytes(6)),'full_name'=>'Kiểm thử lượt tải','phone'=>'0912345678','email'=>$email,'status'=>1,'deleted'=>0,'created'=>time()]);
    $cid=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);$customer=App\Service\CheckoutContact::customer($cid);
    $backend=new App\Controller\CoursePriceController((new Cake\Http\ServerRequest())->withMethod('POST'));
    $save=function($data)use($backend){return $backend->loadComponent('Admin.Order')->saveOrder($data);};
    $pay=function($data,$id=null)use($backend){return $backend->loadComponent('Admin.Payment')->savePayment($data,$id);};
    $plans=[];foreach(Credits::packages() as $plan)$plans[(int)$plan['credit_count']]=$plan;
    $buy=function($count)use($plans,$customer,$save,$pay,&$orders){
        $p=Purchases::create($customer,CoursePricing::quote((int)$plans[$count]['id'],[]),$save);
        $orders[]=(int)$p['order_id'];OrderPayments::approve((int)$p['order_id'],$pay,0);
    };
    $file=['article_id'=>1,'file_index'=>0,'file_key'=>hash('sha256',$email),'file_name'=>'download-limit-fixture.pdf','file_url'=>'https://meduc.vn/cdn/media/download-limit-fixture.pdf'];
    $buy(1);$first=Credits::issue($cid,$file);$firstToken=basename($first['url']);
    downloadExpect(Credits::balance($cid)===1,'Issuing a ticket charged before a successful file response.');
    Credits::consume($firstToken,$cid);Credits::consume($firstToken,$cid);
    downloadExpect(Credits::balance($cid)===0,'One-credit download or transfer retry charged incorrectly.');
    try{Credits::issue($cid,$file);throw new LogicException('A new click reused an exhausted one-credit ticket.');}catch(InvalidArgumentException $e){}
    $checks[]='one_credit_new_click_is_blocked_after_use_but_same_transfer_can_retry';

    $buy(3);$previous=[$first['url']];
    foreach([2,1,0] as $remaining){
        $ticket=Credits::issue($cid,$file);downloadExpect(!in_array($ticket['url'],$previous,true),'A new click reused an earlier same-file ticket.');$previous[]=$ticket['url'];
        $token=basename($ticket['url']);Credits::consume($token,$cid);
        downloadExpect(Credits::balance($cid)===$remaining,'Three-credit same-file downloads did not count down 3→2→1→0.');
        Credits::consume($token,$cid);downloadExpect(Credits::balance($cid)===$remaining,'Range/resume request was charged twice.');
        downloadExpect(!Credits::ticket($token,$cid+1000000),'A transfer token accepted another owner.');
    }
    try{Credits::issue($cid,$file);throw new LogicException('A fourth click was allowed with no remaining credit.');}catch(InvalidArgumentException $e){}
    $checks[]='three_credit_package_counts_each_same_file_click_then_blocks_fourth';

    $buy(3);$unused=Credits::issue($cid,$file);downloadExpect(Credits::balance($cid)===3,'Unopened ticket was charged.');
    for($i=0;$i<3;$i++){
        $different=$file;$different['article_id']=$i+2;$different['file_key']=hash('sha256',$email.'-'.$i);
        $ticket=Credits::issue($cid,$different);Credits::consume(basename($ticket['url']),$cid);
    }
    downloadExpect(Credits::balance($cid)===0&&!Credits::ticket(basename($unused['url']),$cid),'Unopened ticket bypassed an empty wallet.');
    try{Credits::consume(basename($unused['url']),$cid);throw new LogicException('An extra unused ticket overdrew the wallet.');}catch(InvalidArgumentException $e){}
    $checks[]='different_files_charge_once_unopened_ticket_is_free_no_overdraft';

    if(in_array('--parallel',$argv,true)){
        downloadExpect(function_exists('proc_open'),'Parallel fixture workers are unavailable.');
        $buy(3);$tokens=[];for($i=0;$i<8;$i++)$tokens[]=basename(Credits::issue($cid,$file)['url']);
        $start=microtime(true)+2;
        foreach($tokens as $token){
            $process=proc_open([PHP_BINARY,__FILE__,'--consume',(string)$cid,$token,(string)$start],[0=>['file','/dev/null','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
            downloadExpect(is_resource($process),'Could not start parallel fixture worker.');$workers[]=['process'=>$process,'pipes'=>$pipes];
        }
        $consumed=0;$blocked=0;
        foreach($workers as &$worker){
            $out=stream_get_contents($worker['pipes'][1]);$err=stream_get_contents($worker['pipes'][2]);
            fclose($worker['pipes'][1]);fclose($worker['pipes'][2]);$status=proc_close($worker['process']);$worker['process']=null;
            downloadExpect($status===0,'Fixture worker failed: '.$err);$data=json_decode($out,true);
            $consumed+=($data['result']??'')==='consumed'?1:0;$blocked+=($data['result']??'')==='blocked'?1:0;
        }unset($worker);
        downloadExpect($consumed===3&&$blocked===5&&Credits::balance($cid)===0,'Parallel downloads overspent or lost purchased credits.');
        $checks[]='eight_parallel_downloads_spend_exactly_three_credits_and_block_five';
    }
    $result=['passed'=>$checks,'fixtures'=>'committed and cleaned','external_email_or_download'=>false];
}finally{
    foreach($workers as $worker)if(is_resource($worker['process'])){proc_terminate($worker['process']);foreach($worker['pipes'] as $pipe)if(is_resource($pipe))fclose($pipe);proc_close($worker['process']);}
    if($db->inTransaction())$db->rollback(true);
    if($cid){$db->delete('document_credit_uses',['customer_id'=>$cid]);$db->delete('course_enrollments',['customer_id'=>$cid]);}
    foreach($orders as $id){
        foreach(['document_download_purchases','commerce_purchases','orders_item','orders_contact'] as $table)$db->delete($table,['order_id'=>$id]);
        $db->delete('payments',['foreign_type'=>ORDER,'foreign_id'=>$id]);$db->delete('orders',['id'=>$id]);
    }
    if($cid){$db->delete('customers_account',['customer_id'=>$cid]);$db->delete('customers_address',['customer_id'=>$cid]);$db->delete('customers',['id'=>$cid]);}
}
echo json_encode($result,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE)."\n";
