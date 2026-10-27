<?php
declare(strict_types=1);
namespace App\Controller;

use App\Service\DocumentDownloads;
use App\Service\ReadingHistoryService;
use Cake\ORM\TableRegistry;
use Cake\Http\CallbackStream;

class DocumentDownloadController extends AppController
{
    public function initialize(): void {parent::initialize();$this->get_structure_layout=false;}
    private function customer(): array
    {
        $member=$this->request->getSession()->read(MEMBER)?:[];
        return empty($member['id'])?[]:(TableRegistry::get('Customers')->find()->where(['id'=>(int)$member['id'],'deleted'=>0])->enableHydration(false)->first()?:[]);
    }
    private function json(int $status,string $message,array $data=[])
    {
        $this->autoRender=false;
        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control','private, no-store')->withStringBody(json_encode(['code'=>$status===200?'success':'error','message'=>$message,'data'=>$data],JSON_UNESCAPED_UNICODE));
    }
    public function context()
    {
        if(!$this->request->is('get'))return $this->json(405,'Phương thức không hợp lệ.');
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải đang được cập nhật.');
        $article=(int)$this->request->getQuery('article');$service=new DocumentDownloads(LANGUAGE);
        $a=(new ReadingHistoryService(LANGUAGE))->articles('document',[$article])[$article]??null;
        if(!$a)return $this->json(404,'Tài liệu không còn khả dụng.');
        $customer=$this->customer();$owner=(int)($customer['id']??0);$files=[];$session=$this->request->getSession();
        $tokens=$session->read('DocumentDownload.tokens')?:[];
        foreach($a['files'] as $index=>$attachment){
            try{
                $file=$service->quote($article,$index);$nonce='';
                if($owner){$nonce=bin2hex(random_bytes(24));$tokens[$nonce]=['customer'=>$owner,'article'=>$article,'index'=>$index,'file'=>$file['file_key'],'expires'=>time()+7200];}
                $purchase=$owner?$service->latest($owner,$file):null;
                $files[]=['index'=>$index,'name'=>$file['file_name'],'nonce'=>$nonce,'purchase'=>$purchase?$service->publicData($purchase):null];
            }catch(\InvalidArgumentException $e){$files[]=['index'=>$index,'unavailable'=>true];}
        }
        if($owner)$session->write('DocumentDownload.tokens',array_slice(array_filter($tokens,function($t){return $t['expires']>=time();}),-40,null,true));
        return $this->json(200,'',['customer_id'=>$owner,'price'=>DocumentDownloads::PRICE,'files'=>$files]);
    }
    public function purchase()
    {
        if(!$this->request->is('post'))return $this->json(405,'Phương thức không hợp lệ.');
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải chưa sẵn sàng.');
        $customer=$this->customer();if(!$customer)return $this->json(401,'Vui lòng đăng nhập trước khi mua lượt tải.');
        $owner=(int)$customer['id'];if((int)$this->request->getData('expected_customer_id')!==$owner)return $this->json(409,'Tài khoản đã thay đổi. Vui lòng thử lại.');
        $session=$this->request->getSession();$nonce=(string)$this->request->getData('nonce');$done=$session->read('DocumentDownload.completed')?:[];
        if(isset($done[$nonce])&&(int)$done[$nonce]['customer']===$owner)return $this->json(200,'Đơn mua lượt tải đã được tạo.',['redirect'=>'/document-download/payment/'.$done[$nonce]['code']]);
        $tokens=$session->read('DocumentDownload.tokens')?:[];$token=$tokens[$nonce]??null;
        if(!$token||$token['expires']<time()||(int)$token['customer']!==$owner)return $this->json(422,'Phiên mua lượt tải đã hết hạn. Vui lòng thử lại.');
        try{
            $service=new DocumentDownloads(LANGUAGE);$file=$service->quote((int)$token['article'],(int)$token['index']);
            if(!hash_equals($token['file'],$file['file_key']))return $this->json(422,'Danh sách tệp đã thay đổi. Vui lòng tải lại trang.');
            [$stream]=$this->upstream($file['file_url'],'HEAD');fclose($stream);
            $purchase=$service->create($customer,$file,function($data){return $this->loadComponent('Admin.Order')->saveOrder($data);});
            $done[$nonce]=['customer'=>$owner,'code'=>$purchase['code']];$session->write('DocumentDownload.completed',array_slice($done,-20,null,true));
            unset($tokens[$nonce]);$session->write('DocumentDownload.tokens',$tokens);
            return $this->json(200,'Đã tạo đơn mua lượt tải.',['redirect'=>'/document-download/payment/'.$purchase['code']]);
        }catch(\InvalidArgumentException $e){return $this->json(422,$e->getMessage());}
        catch(\Throwable $e){$this->log('Document download purchase: '.$e->getMessage(),'error');return $this->json(503,'Chưa tạo được đơn mua lượt tải. Vui lòng thử lại sau.');}
    }
    public function payment($code=null)
    {
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải đang được cập nhật.');
        if(!is_string($code)||!preg_match('/^[a-f0-9]{32}$/',$code))return $this->response->withStatus(404)->withStringBody('Không tìm thấy lượt tải.');
        $customer=$this->customer();
        if($customer&&!(new DocumentDownloads(LANGUAGE))->owned($code,(int)$customer['id']))return $this->response->withStatus(404)->withStringBody('Không tìm thấy lượt tải.');
        $this->set('purchase_code',$code);$this->set('title_for_layout','Mua lượt tải tài liệu | MedUC');
        $this->set('data_init',['device'=>DEVICE,'member'=>$this->request->getSession()->read(MEMBER)?:[],'template'=>['code'=>CODE_TEMPLATE,'url'=>URL_TEMPLATE]]);
        $this->viewBuilder()->setLayout('course_pricing');
        $this->response=$this->response->withHeader('Cache-Control','private, no-store');
    }
    public function status($code=null)
    {
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải đang được cập nhật.');
        if(!$this->request->is('get'))return $this->json(405,'Phương thức không hợp lệ.');
        $customer=$this->customer();if(!$customer)return $this->json(401,'Vui lòng đăng nhập để xem lượt tải đã mua.');
        $service=new DocumentDownloads(LANGUAGE);$purchase=$service->owned((string)$code,(int)$customer['id']);
        return $purchase?$this->json(200,'',$service->publicData($purchase)):$this->json(404,'Không tìm thấy lượt tải.');
    }
    public function transfer($code=null)
    {
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải đang được cập nhật.');
        if(!$this->request->is('post'))return $this->json(405,'Phương thức không hợp lệ.');
        $customer=$this->customer();if(!$customer)return $this->json(401,'Vui lòng đăng nhập.');
        try{
            $service=new DocumentDownloads(LANGUAGE);$purchase=$service->report((string)$code,(int)$customer['id'],function($data){return $this->loadComponent('Admin.Payment')->savePayment($data);});
            return $this->json(200,'Đã gửi thông tin. MedUC sẽ kiểm tra và xác nhận thanh toán.',$service->publicData($purchase));
        }catch(\InvalidArgumentException $e){return $this->json(404,$e->getMessage());}
        catch(\Throwable $e){$this->log('Document transfer report: '.$e->getMessage(),'error');return $this->json(500,'Chưa gửi được thông tin chuyển khoản. Vui lòng thử lại.');}
    }
    public function start($code=null)
    {
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải đang được cập nhật.');
        if(!$this->request->is('post'))return $this->json(405,'Phương thức không hợp lệ.');
        $customer=$this->customer();if(!$customer)return $this->json(401,'Vui lòng đăng nhập để tải tệp đã mua.');
        try{return $this->json(200,'',(new DocumentDownloads(LANGUAGE))->issue((string)$code,(int)$customer['id']));}
        catch(\InvalidArgumentException $e){return $this->json(402,$e->getMessage());}
    }
    public function file($token=null)
    {
        if(!DocumentDownloads::installed())return $this->json(503,'Dịch vụ mua lượt tải đang được cập nhật.');
        $this->autoRender=false;
        if(!$this->request->is(['get','head']))return $this->json(405,'Phương thức không hợp lệ.');
        $customer=$this->customer();if(!$customer)return $this->json(401,'Vui lòng đăng nhập để tải tệp đã mua.');
        $service=new DocumentDownloads(LANGUAGE);$p=$service->ticket((string)$token,(int)$customer['id']);
        if(!$p)return $this->json(404,'Lượt tải không còn hiệu lực.');
        $range=$this->request->getHeaderLine('Range');
        if($range!==''&&(strlen($range)>80||!preg_match('/^bytes=(?:\d+-\d*|-\d+)$/',$range)))return $this->response->withStatus(416);
        try{
            [$stream,$status,$headers]=$this->upstream($p['file_url'],$this->request->is('head')?'HEAD':'GET',$range);
            if(!$this->request->is('head'))$service->consume($p['code'],(string)$token,(int)$customer['id']);
        }catch(\Throwable $e){if(isset($stream)&&is_resource($stream))fclose($stream);return $this->json(502,'Chưa tải được tệp. Lượt chưa dùng của bạn vẫn được giữ lại; vui lòng thử lại.');}
        $ext=preg_replace('/[^a-z0-9]/i','',pathinfo($p['file_name'],PATHINFO_EXTENSION));
        $response=$this->response->withStatus($status)->withHeader('Content-Type',$headers['content-type']??'application/octet-stream')
            ->withHeader('Content-Disposition','attachment; filename="meduc-document-'.$p['article_id'].($ext?'.'.$ext:'').'"; filename*=UTF-8\'\''.rawurlencode($p['file_name']))
            ->withHeader('Cache-Control','private, no-store')->withHeader('Referrer-Policy','no-referrer')->withHeader('X-Content-Type-Options','nosniff')->withHeader('Accept-Ranges','bytes')->withHeader('X-Accel-Buffering','no');
        foreach(['content-length'=>'Content-Length','content-range'=>'Content-Range','etag'=>'ETag','last-modified'=>'Last-Modified'] as $k=>$name)if(isset($headers[$k]))$response=$response->withHeader($name,$headers[$k]);
        if($this->request->is('head')){fclose($stream);return $response;}
        $session=$this->request->getSession();
        return $response->withBody(new CallbackStream(function()use($stream,$session){$session->close();while(!feof($stream)&&!connection_aborted()){$chunk=fread($stream,65536);if($chunk===false)break;echo $chunk;}fclose($stream);}));
    }
    private function upstream(string $url,string $method='GET',string $range=''): array
    {
        DocumentDownloads::validateSource($url);$parts=parse_url($url);
        $path=implode('/',array_map(function($part){return rawurlencode(rawurldecode($part));},explode('/',$parts['path']??'/')));
        $url='https://'.$parts['host'].$path.(isset($parts['query'])?'?'.$parts['query']:'');
        $context=stream_context_create(['http'=>['method'=>$method,'header'=>"Connection: close\r\n".($range?'Range: '.$range."\r\n":''),'timeout'=>30,'ignore_errors'=>true,'follow_location'=>0,'protocol_version'=>1.1],'ssl'=>['verify_peer'=>true,'verify_peer_name'=>true]]);
        $stream=@fopen($url,'rb',false,$context);if(!$stream)throw new \RuntimeException('File upstream unavailable.');
        $status=0;$headers=[];foreach($http_response_header??[] as $line){if(preg_match('~^HTTP/\S+\s+(\d+)~',$line,$m))$status=(int)$m[1];elseif(strpos($line,':')!==false){[$k,$v]=explode(':',$line,2);$headers[strtolower(trim($k))]=trim($v);}}
        if(!in_array($status,[200,206],true)||stripos($headers['content-type']??'','text/html')===0){fclose($stream);throw new \RuntimeException('File upstream returned '.$status);}
        return [$stream,$status,$headers];
    }
}
