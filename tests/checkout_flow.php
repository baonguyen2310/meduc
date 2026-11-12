<?php
/** Transactional integration checks: fixtures are rolled back; no email or payment is sent. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
$root=dirname(__DIR__);
define('SOURCE_DOMAIN',$root);
require $root.'/config_database.php';
require $root.'/coredaca/vendor/autoload.php';
$app=new App\Application($root.'/coredaca/config');$app->bootstrap();
Cake\Core\Configure::write('App.paths.templates',[$root.'/templates/app01/']);
foreach (['LANGUAGE'=>'vi','CODE_TEMPLATE'=>'app01','CDN_URL'=>'https://cdn.meduc.vn','CURRENCY_UNIT'=>'đ'] as $key=>$value) if(!defined($key))define($key,$value);

use App\Service\CheckoutContact;
use App\Service\CoursePricing;
use App\Service\DocumentDownloads;
use Cake\Datasource\ConnectionManager;
use Cake\Http\ServerRequest;
use Cake\ORM\TableRegistry;

function checkoutExpect($condition,string $message):void {if(!$condition)throw new RuntimeException($message);}
function checkoutRequest($session,string $method,array $data=[]):ServerRequest {
    return (new ServerRequest(['environment'=>['REQUEST_METHOD'=>$method,'HTTP_HOST'=>'meducv3.duckdns.org','HTTPS'=>'on'],'session'=>$session]))->withMethod($method)->withParsedBody($data);
}
class CheckoutFlowView extends App\View\SmartyView {
    public function page(string $path,array $data):string {return $this->_render(SOURCE_DOMAIN.'/templates/app01/'.$path,$data);}
}
class CheckoutFixtureResponse extends RuntimeException {public $result;public function __construct(array $result){$this->result=$result;parent::__construct('Fixture response');}}
class CheckoutFixtureContact extends App\Controller\ContactController {
    protected function responseJson($params=[]){throw new CheckoutFixtureResponse($params);}
}
class CheckoutFixtureMessages extends Cake\Controller\Component {
    public function check($token){return [CODE=>SUCCESS];}
    public function send(...$args){return [CODE=>SUCCESS];}
    public function sendEmail(...$args){return [CODE=>SUCCESS];}
}
$db=ConnectionManager::get('default');$checks=[];$db->begin();
try {
    $email='checkout-fixture-'.bin2hex(random_bytes(6)).'@example.invalid';
    $db->insert('customers',['code'=>'CHECKOUT-'.bin2hex(random_bytes(5)),'full_name'=>'Kiểm thử thanh toán','email'=>$email,'phone'=>'0912345678','status'=>1,'deleted'=>0,'created'=>time()]);
    $id=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);$customer=CheckoutContact::customer($id);
    $db->insert('customers_address',['customer_id'=>$id,'name'=>'Nhà','address'=>'12 Đường kiểm thử','full_address'=>'12 Đường kiểm thử, Huế','is_default'=>1]);
    $profile=CheckoutContact::profile($customer);
    checkoutExpect($profile['email']===$email&&$profile['address']==='12 Đường kiểm thử, Huế','Profile/default shipping address did not prefill.');
    $contact=CheckoutContact::validate(['full_name'=>'Người nhận mới','phone'=>'+84912345678','email'=>'changed@example.invalid','address'=>'34 Địa chỉ nhận mới'],$customer,true);
    checkoutExpect($contact['email']===$email&&$contact['full_name']==='Người nhận mới','Email was editable or recipient details were ignored.');
    try{CheckoutContact::validate(['address'=>''],$customer,true);throw new RuntimeException('Empty address accepted.');}catch(InvalidArgumentException $e){}
    $checks[]='account_prefill_editable_recipient_locked_email_shipping_validation';

    $session=(new ServerRequest())->getSession();
    $controller=new App\Controller\CoursePriceController(checkoutRequest($session,'POST'));
    checkoutExpect($controller->create()->getStatusCode()===401,'Guest course checkout was allowed.');
    $contextController=new App\Controller\CheckoutController(checkoutRequest($session,'GET'));
    $guest=json_decode((string)$contextController->customer()->getBody(),true)['data'];
    checkoutExpect(!$guest['member']&&!$guest['contact'],'Guest contact context leaked a profile.');
    $session->write(MEMBER,['id'=>$id]);
    $contextController=new App\Controller\CheckoutController(checkoutRequest($session,'GET'));
    $response=$contextController->customer();$signed=json_decode((string)$response->getBody(),true)['data'];
    checkoutExpect($signed['contact']===$profile&&strpos($response->getHeaderLine('Cache-Control'),'no-store')!==false,'Signed-in private contact context differs.');
    $checks[]='authentication_before_order_and_private_contact_context';

    foreach(['knowledge','exam_solution','quiz'] as $kind){
        $board=null;foreach(CoursePricing::lists(true) as $list)if($list['course_type']===$kind){$board=$list;break;}
        checkoutExpect($board,'Missing price board '.$kind);
        $package=null;foreach(CoursePricing::packages((int)$board['id']) as $p)if((int)$p['course_count']===1){$package=$p;break;}
        $course=CoursePricing::courses((int)$board['id'],true)[0];
        $controller=new App\Controller\CoursePriceController(checkoutRequest($session,'GET'));
        $controller->checkoutContext();$tokens=$session->read('CoursePrice.tokens')?:[];
        // The endpoint issues a token only for a checkout request.
        $token=bin2hex(random_bytes(24));$tokens[$token]=time();$session->write('CoursePrice.tokens',$tokens);
        $data=['package_id'=>$package['id'],'course_ids'=>[$course['id']],'token'=>$token];
        $controller=new App\Controller\CoursePriceController(checkoutRequest($session,'POST',$data));
        $result=json_decode((string)$controller->create()->getBody(),true);
        checkoutExpect($result['code']==='success','Direct checkout without phone confirmation failed: '.json_encode($result));
        parse_str(parse_url($result['data']['redirect'],PHP_URL_QUERY),$query);
        $order=TableRegistry::get('Orders')->find()->where(['code'=>$query['code']])->enableHydration(false)->first();
        checkoutExpect($order&&(int)$order['total']===(int)$package['amount'],'Server package price differs.');
        CheckoutContact::save((int)$order['id'],$customer,['full_name'=>'Tên trên đơn','phone'=>'0987654321','email'=>'tampered@example.invalid']);
        $saved=TableRegistry::get('OrdersContact')->find()->where(['order_id'=>$order['id']])->enableHydration(false)->first();
        checkoutExpect($saved['full_name']==='Tên trên đơn'&&$saved['phone']==='0987654321'&&$saved['email']===$email,'Edited checkout details were not saved.');
        checkoutExpect(CheckoutContact::customer($id)['full_name']===$customer['full_name'],'Recipient edit modified the student profile.');
        try{CheckoutContact::save((int)$order['id'],['id'=>$id+1000000],[]);throw new RuntimeException('Another customer could change the contact.');}catch(InvalidArgumentException $e){}
        $view=new CheckoutFlowView();$view->loadHelper('Checkout');
        $orderInfo=TableRegistry::get('Orders')->formatDataOrderDetail(TableRegistry::get('Orders')->getDetailOrder($order['id'],['get_items'=>true,'get_contact'=>true]),LANGUAGE);
        $html=$view->page('Order/checkout.tpl',['order_info'=>$orderInfo,'checkout_contact'=>CheckoutContact::profile($customer,$orderInfo['contact'])]);
        checkoutExpect(strpos($html,'data-payment-return="'.CoursePricing::CATALOGS[$kind].'"')!==false,'Payment confirmation returns to the wrong catalog for '.$kind);
        checkoutExpect(strpos($html,'data-order-payment-form')!==false&&strpos($html,' readonly ')!==false&&strpos($html,'Kiểm tra lựa chọn')===false,'Course checkout render is incorrect.');
        checkoutExpect((strpos($html,'qr-momo-tab')!==false)===($kind!=='quiz')&&strpos($html,'qr-cod-tab')===false,'Payment methods leaked to another course type.');
        $checks[]=$kind.'_direct_order_edit_contact_and_payment_render';
    }
    $downloads=new DocumentDownloads('vi');
    $file=['article_id'=>1,'file_index'=>0,'file_key'=>hash('sha256',$email),'document_title'=>'Tài liệu kiểm thử','document_url'=>'/tai-lieu-kiem-thu','file_name'=>'fixture.pdf','file_url'=>'https://meduc.vn/media/fixture.pdf','amount'=>9999];
    $purchase=$downloads->create($customer,$file,function($data)use($controller){return $controller->loadComponent('Admin.Order')->saveOrder($data);});
    $countBefore=(int)$db->execute('SELECT COUNT(*) FROM payments WHERE foreign_id=? AND foreign_type=?',[$purchase['order_id'],ORDER])->fetchColumn(0);
    CheckoutContact::save((int)$purchase['order_id'],$customer,['full_name'=>'Người mua tài liệu','phone'=>'0987654321','email'=>'ignored@example.invalid']);
    $reported=$downloads->report($purchase['code'],$id,function($data)use($controller){return $controller->loadComponent('Admin.Payment')->savePayment($data);});
    checkoutExpect($downloads->state($reported)==='pending'&&!empty($reported['transfer_reported_at']),'Transfer report incorrectly opened access.');
    $downloads->report($purchase['code'],$id,function($data){throw new RuntimeException('Duplicate report tried to save a second receipt.');});
    $countAfter=(int)$db->execute('SELECT COUNT(*) FROM payments WHERE foreign_id=? AND foreign_type=?',[$purchase['order_id'],ORDER])->fetchColumn(0);
    checkoutExpect($countAfter===$countBefore+1,'Transfer reporting is not idempotent.');
    $checks[]='document_contact_saved_report_idempotent_access_requires_confirmation';
    $view=new CheckoutFlowView();$view->loadHelper('Checkout');
    $html=$view->page('block/slider/view_book_checkout.tpl',[]);
    checkoutExpect(strpos($html,'qr-cod-tab')!==false&&strpos($html,'qr-momo-tab')===false&&strpos($html,'name="address"')!==false&&strpos($html,'data-checkout-login')!==false,'Book checkout methods or fields incorrect.');
    $html=$view->page('DocumentDownload/payment.tpl',['purchase_code'=>str_repeat('a',32)]);
    checkoutExpect(strpos($html,'qr-cod-tab')===false&&strpos($html,'qr-momo-tab')===false&&strpos($html,'name="email"')!==false&&strpos($html,'name="address"')===false,'Document checkout methods or fields incorrect.');
    $checks[]='book_and_document_use_common_contact_and_payment_layout';
    $books=App\Lib\BookCheckout::catalog();$book=reset($books);
    checkoutExpect($book,'No book available for checkout fixture.');
    $bookData=['form_code'=>'61CQ0U3H9I','full_name'=>'Người nhận sách','phone'=>'0912345678','email'=>'forged@example.invalid','address'=>'34 Đường kiểm thử',
        'payment'=>'cod','cartId'=>'MEDUC'.random_int(100000000,999999999),'cartTotal'=>$book['price_special']*2,
        'cartProducts'=>json_encode([['id'=>$book['id'],'quantity'=>2]])];
    $session->delete(MEMBER);
    $contactController=new CheckoutFixtureContact(checkoutRequest($session,'POST',$bookData));
    checkoutExpect($contactController->sendInfo()->getStatusCode()===401,'Guest book order accepted.');
    $session->write(MEMBER,['id'=>$id]);
    $contactController=new CheckoutFixtureContact(checkoutRequest($session,'POST',$bookData));
    foreach(['ReCaptcha','Email','SendMessage'] as $alias)$contactController->components()->set($alias,new CheckoutFixtureMessages($contactController->components()));
    try{$contactController->sendInfo();throw new RuntimeException('Book checkout did not respond.');}
    catch(CheckoutFixtureResponse $e){checkoutExpect(($e->result[CODE]??null)===SUCCESS,'Book checkout failed: '.json_encode($e->result));}
    $receipt=$session->read('MeducBookOrder');
    checkoutExpect($receipt['email']===$email&&(int)$receipt['customer_id']===$id&&$receipt['full_name']==='Người nhận sách'&&$receipt['payment']==='cod'&&
        (int)$receipt['totalQuantity']===2&&(float)$receipt['totalPrice']===(float)$bookData['cartTotal'],'Book receipt lost account email, recipient, quantities or COD.');
    $checks[]='book_guest_blocked_authenticated_cod_order_uses_server_price_and_account_email';
    echo json_encode(['passed'=>$checks,'fixtures'=>'rolled back','external_email_or_payment'=>false],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE)."\n";
}finally{$db->rollback();}
