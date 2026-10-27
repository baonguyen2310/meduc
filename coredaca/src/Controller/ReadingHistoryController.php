<?php
declare(strict_types=1);
namespace App\Controller;

use App\Service\ReadingHistoryService;
use Cake\ORM\TableRegistry;
use Cake\Http\CallbackStream;

class ReadingHistoryController extends AppController
{
    public function initialize(): void { parent::initialize();$this->get_structure_layout=false; }
    private function customer(): int
    {
        $member=$this->request->getSession()->read(MEMBER)?:[];
        if (empty($member['id'])) return 0;
        $row=TableRegistry::get('Customers')->find()->where(['id'=>(int)$member['id'],'deleted'=>0])->select(['id'])->first();
        return $row?(int)$row['id']:0;
    }
    private function json(int $status,array $data=[],string $message='')
    {
        $this->autoRender=false;
        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control','private, no-store')->withStringBody(json_encode(['code'=>$status===200?'success':'error','data'=>$data,'message'=>$message],JSON_UNESCAPED_UNICODE));
    }
    public function index()
    {
        if (!$this->request->is('get')) return $this->json(405);
        $kind=$this->request->getQuery('kind');
        if (!in_array($kind,['blog','document'],true)) return $this->json(400,[],'Loại nội dung không hợp lệ.');
        $customer=$this->customer();$service=new ReadingHistoryService(LANGUAGE);
        if ($customer) $items=$service->recent($customer,$kind);
        else {
            $raw=$this->request->getQuery('ids','');
            $ids=is_string($raw)&&preg_match('/^\d*(?:,\d+){0,2}$/',$raw)?array_filter(array_map('intval',explode(',',$raw))):[];
            $articles=$service->articles($kind,$ids);$items=[];
            foreach ($ids as $id) if (isset($articles[$id])) { $item=$articles[$id];unset($item['files']);$items[]=$item; }
        }
        return $this->json(200,['customer_id'=>$customer,'items'=>$items]);
    }
    public function save()
    {
        if (!$this->request->is('post')) return $this->json(405);
        $customer=$this->customer();
        if (!$customer) return $this->json(401,[],'Bạn chưa đăng nhập.');
        if ((int)$this->request->getData('expected_customer_id')!==$customer) return $this->json(409,[],'Tài khoản đã thay đổi.');
        $kind=$this->request->getData('kind');$action=$this->request->getData('action');$id=(int)$this->request->getData('article_id');
        if (!in_array($kind,['blog','document'],true) || !in_array($action,['visit','progress'],true) || $id<1) return $this->json(400);
        $service=new ReadingHistoryService(LANGUAGE);$articles=$service->articles($kind,[$id]);
        if (!isset($articles[$id])) return $this->json(404,[],'Nội dung hiện chưa khả dụng.');
        if ($action==='visit') $service->visit($customer,$kind,$id);
        else {
            $raw=$this->request->getData('progress');
            $p=is_string($raw)&&strlen($raw)<=4096?json_decode($raw,true):null;
            if (!is_array($p)) return $this->json(400);
            try { $progress=$service->progress($kind,$p,$articles[$id]); }
            catch (\InvalidArgumentException $e) { return $this->json(400,[],$e->getMessage()); }
            $service->save($customer,$kind,$id,$progress);
        }
        return $this->json(200,['saved'=>true]);
    }

    /** Stream only the selected published CMS attachment. No arbitrary URL, redirects or upstream cookies. */
    public function pdf($articleId=null,$fileIndex=null)
    {
        $this->autoRender=false;
        if (!$this->request->is('get')) return $this->response->withStatus(405);
        $id=(int)$articleId;$index=(int)$fileIndex;
        $articles=(new ReadingHistoryService(LANGUAGE))->articles('document',[$id]);
        $file=$articles[$id]['files'][$index]??null;
        if (!$file || !$file['pdf']) return $this->response->withStatus(404);
        $parts=parse_url($file['url']);
        if (($parts['scheme']??'')!=='https' || !in_array(strtolower($parts['host']??''),['meduc.vn','cdn.meduc.vn'],true) || isset($parts['user']) || isset($parts['pass']) || (isset($parts['port']) && $parts['port']!==443)) return $this->response->withStatus(422);
        $range=$this->request->getHeaderLine('Range');
        if ($range!=='' && (strlen($range)>80 || !preg_match('/^bytes=(?:\d+-\d*|-\d+)$/',$range))) return $this->response->withStatus(416);
        $headers="Accept: application/pdf\r\nConnection: close\r\n".($range!==''?'Range: '.$range."\r\n":'');
        $context=stream_context_create(['http'=>['method'=>'GET','header'=>$headers,'timeout'=>30,'ignore_errors'=>true,'follow_location'=>0,'protocol_version'=>1.1],'ssl'=>['verify_peer'=>true,'verify_peer_name'=>true]]);
        $path=implode('/',array_map(function($segment){return rawurlencode(rawurldecode($segment));},explode('/',$parts['path']??'/')));
        $url='https://'.$parts['host'].$path.(isset($parts['query'])?'?'.$parts['query']:'');
        $stream=@fopen($url,'rb',false,$context);
        if (!$stream) return $this->response->withStatus(502);
        $status=0;$upstream=[];
        foreach ($http_response_header??[] as $header) {
            if (preg_match('~^HTTP/\S+\s+(\d+)~',$header,$m)) $status=(int)$m[1];
            elseif (strpos($header,':')!==false) {[$key,$value]=explode(':',$header,2);$upstream[strtolower(trim($key))]=trim($value);}
        }
        if (!in_array($status,[200,206],true) || stripos($upstream['content-type']??'','application/pdf')!==0) { fclose($stream);return $this->response->withStatus($status===416?416:502); }
        $response=$this->response->withStatus($status)->withType('application/pdf')->withHeader('Accept-Ranges','bytes')->withHeader('Content-Disposition','inline; filename="meduc-'.$id.'-'.$index.'.pdf"')->withHeader('Cache-Control','private, max-age=0')->withHeader('X-Content-Type-Options','nosniff')->withHeader('X-Accel-Buffering','no');
        foreach (['content-length'=>'Content-Length','content-range'=>'Content-Range','etag'=>'ETag','last-modified'=>'Last-Modified'] as $key=>$name) if (isset($upstream[$key])) $response=$response->withHeader($name,$upstream[$key]);
        // Cake's range emitter otherwise slices a non-seekable body a second time.
        // The callback writes only the upstream range, in bounded chunks, without buffering a PDF.
        $session=$this->request->getSession();
        return $response->withBody(new CallbackStream(function()use($stream,$session){
            $session->close();
            while (!feof($stream) && !connection_aborted()) {
                $chunk=fread($stream,65536);if ($chunk===false) break;echo $chunk;
            }
            fclose($stream);
        }));
    }
}
