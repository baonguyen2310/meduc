<?php
declare(strict_types=1);
namespace App\Service;

use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;

/** One manually paid order grants one file-download session; online reading is independent. */
class DocumentDownloads
{
    public const PRICE=9999;
    public const RETRY_SECONDS=1800;
    private $lang;
    public function __construct(string $lang='vi'){$this->lang=$lang;}
    public static function db(){return ConnectionManager::get('default');}
    public static function installed(): bool
    {
        static $exists;
        if($exists===null)$exists=(bool)self::db()->execute("SHOW TABLES LIKE 'document_download_purchases'")->fetch();
        return $exists;
    }
    public static function byOrderCode(string $code): ?array
    {
        if(!self::installed())return null;
        return self::db()->execute('SELECT p.code,p.customer_id FROM document_download_purchases p JOIN orders o ON o.id=p.order_id WHERE o.code=:code',['code'=>$code])->fetch('assoc')?:null;
    }
    public static function validateSource(string $url): void
    {
        $p=parse_url($url);
        if(($p['scheme']??'')!=='https'||!in_array(strtolower($p['host']??''),['meduc.vn','cdn.meduc.vn'],true)||isset($p['user'])||isset($p['pass'])||(isset($p['port'])&&$p['port']!==443))throw new \InvalidArgumentException('Tệp này chưa hỗ trợ mua lượt tải.');
    }
    public function quote(int $article,int $index): array
    {
        $a=(new ReadingHistoryService($this->lang))->articles('document',[$article])[$article]??null;
        $file=$a['files'][$index]??null;
        if(!$a||$index<0||!$file)throw new \InvalidArgumentException('Tệp tài liệu không còn khả dụng.');
        self::validateSource($file['url']);
        return ['article_id'=>$article,'file_index'=>$index,'file_key'=>hash('sha256',$file['url']),
            'document_title'=>mb_substr($a['title'],0,255),'document_url'=>$a['url'],
            'file_name'=>mb_substr(str_replace(["\r","\n"],'',rawurldecode(basename((string)parse_url($file['url'],PHP_URL_PATH)))),0,512),
            'file_url'=>$file['url'],'amount'=>self::PRICE];
    }
    private function selectSql(): string
    {
        return "SELECT p.*,o.code order_code,o.total order_total,o.status order_status,o.deleted order_deleted,c.customer_id order_customer,
          COALESCE((SELECT SUM(CASE WHEN t.type=1 THEN t.amount ELSE -t.amount END) FROM payments t WHERE t.foreign_id=p.order_id AND t.foreign_type='order' AND t.status=1),0) confirmed
          FROM document_download_purchases p JOIN orders o ON o.id=p.order_id JOIN orders_contact c ON c.order_id=o.id ";
    }
    public function owned(string $code,int $customer,bool $lock=false): ?array
    {
        if(!preg_match('/^[a-f0-9]{32}$/',$code))return null;
        return self::db()->execute($this->selectSql().' WHERE p.code=:code AND p.customer_id=:customer'.($lock?' FOR UPDATE':''),['code'=>$code,'customer'=>$customer])->fetch('assoc')?:null;
    }
    public function state(array $p): string
    {
        if(!empty($p['order_deleted'])||$p['order_status']===CANCEL||(int)$p['order_customer']!==(int)$p['customer_id']||abs((float)$p['order_total']-self::PRICE)>0.001||(int)$p['amount']!==self::PRICE)return 'cancelled';
        if((float)$p['confirmed']<(int)$p['amount'])return empty($p['used_at'])?'pending':'revoked';
        if(empty($p['used_at']))return 'available';
        return (int)$p['token_expires_at']>=time()?'active':'used';
    }
    public function publicData(array $p): array
    {
        return ['code'=>$p['code'],'order_code'=>$p['order_code'],'document_title'=>$p['document_title'],'document_url'=>$p['document_url'],
            'file_name'=>$p['file_name'],'amount'=>(int)$p['amount'],'state'=>$this->state($p),'reported'=>!empty($p['transfer_reported_at']),
            'expires_at'=>(int)($p['token_expires_at']??0),'payment_url'=>'/document-download/payment/'.$p['code']];
    }
    public function latest(int $customer,array $file): ?array
    {
        if(!$customer)return null;
        $sql=$this->selectSql()." WHERE p.customer_id=:customer AND p.article_id=:article AND p.file_key=:file AND o.deleted=0 AND o.status<>'cancel'
          AND (p.used_at IS NULL OR p.token_expires_at>=:now)
          ORDER BY CASE WHEN confirmed>=p.amount AND p.used_at IS NOT NULL AND p.token_expires_at>=:active THEN 0 WHEN confirmed>=p.amount THEN 1 ELSE 2 END,p.id DESC LIMIT 1";
        $p=self::db()->execute($sql,['customer'=>$customer,'article'=>$file['article_id'],'file'=>$file['file_key'],'now'=>time(),'active'=>time()])->fetch('assoc');
        if(!$p||($this->state($p)==='pending'&&(int)$p['created_at']<time()-86400))return null;
        return $p;
    }
    public function create(array $customer,array $file,callable $saveOrder): array
    {
        return self::db()->transactional(function()use($customer,$file,$saveOrder){
            $db=self::db();$db->execute('SELECT id FROM customers WHERE id=:id AND deleted=0 FOR UPDATE',['id'=>(int)$customer['id']])->fetch();
            $existing=$this->latest((int)$customer['id'],$file);
            if($existing&&in_array($this->state($existing),['pending','available','active'],true))return $existing;
            $sku=$db->execute("SELECT i.id,i.product_id FROM products_item i JOIN products p ON p.id=i.product_id WHERE i.code='MEDUC_DOCUMENT_DOWNLOAD' AND i.deleted=0 AND p.deleted=0 AND p.status=0 AND p.draft=1")->fetch('assoc');
            if(!$sku)throw new \RuntimeException('Dịch vụ tải tài liệu chưa sẵn sàng.');
            $result=$saveOrder(['type'=>ORDER,'source'=>WEBSITE,'status'=>DRAFT,'note'=>mb_substr('Lượt tải tài liệu: '.$file['document_title'].' | '.$file['file_name'],0,250),
                'contact'=>['customer_id'=>(int)$customer['id'],'full_name'=>$customer['full_name'],'email'=>$customer['email'],'phone'=>$customer['phone']??null],
                'items'=>[['product_id'=>(int)$sku['product_id'],'product_item_id'=>(int)$sku['id'],'quantity'=>1,'price'=>self::PRICE,'vat_value'=>0]]]);
            if(($result[CODE]??null)!==SUCCESS)throw new \RuntimeException($result[MESSAGE]??'Chưa tạo được đơn mua lượt tải.');
            $order=$result[DATA];$code=bin2hex(random_bytes(16));$now=time();
            $db->insert('document_download_purchases',array_merge($file,['code'=>$code,'customer_id'=>(int)$customer['id'],'order_id'=>(int)$order['id'],'created_at'=>$now,'updated_at'=>$now]));
            return $this->owned($code,(int)$customer['id']);
        });
    }
    /** A customer's transfer report is only a pending receipt, never proof of payment. */
    public function report(string $code,int $customer,callable $savePayment): array
    {
        return self::db()->transactional(function()use($code,$customer,$savePayment){
            $p=$this->owned($code,$customer,true);if(!$p)throw new \InvalidArgumentException('Không tìm thấy lượt tải.');
            if($this->state($p)!=='pending'||!empty($p['transfer_reported_at']))return $p;
            $result=$savePayment(['foreign_id'=>(int)$p['order_id'],'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$customer,'type'=>1,
                'amount'=>self::PRICE,'payment_method'=>BANK,'reference'=>$p['order_code'],'description'=>'Khách báo đã chuyển khoản mua lượt tải tài liệu','status'=>2]);
            if(($result[CODE]??null)!==SUCCESS)throw new \RuntimeException('Chưa gửi được thông tin chuyển khoản.');
            self::db()->update('orders',['status'=>NEW_ORDER,'updated'=>time()],['id'=>(int)$p['order_id'],'status'=>DRAFT]);
            self::db()->update('document_download_purchases',['transfer_reported_at'=>time(),'updated_at'=>time()],['id'=>(int)$p['id']]);
            return $this->owned($code,$customer);
        });
    }
    public function issue(string $code,int $customer): array
    {
        return self::db()->transactional(function()use($code,$customer){
            $p=$this->owned($code,$customer,true);if(!$p)throw new \InvalidArgumentException('Không tìm thấy lượt tải.');
            if(!in_array($this->state($p),['available','active'],true))throw new \InvalidArgumentException('Lượt tải chưa được thanh toán hoặc đã sử dụng.');
            if(empty($p['download_token'])||(int)$p['token_expires_at']<time()){
                $p['download_token']=bin2hex(random_bytes(32));$p['token_expires_at']=time()+self::RETRY_SECONDS;
                self::db()->update('document_download_purchases',['download_token'=>$p['download_token'],'token_expires_at'=>$p['token_expires_at'],'updated_at'=>time()],['id'=>(int)$p['id']]);
            }
            return ['url'=>'/document-download/file/'.$p['download_token'],'file_name'=>$p['file_name'],'expires_at'=>(int)$p['token_expires_at']];
        });
    }
    public function ticket(string $token,int $customer): ?array
    {
        if(!preg_match('/^[a-f0-9]{64}$/',$token))return null;
        $p=self::db()->execute($this->selectSql().' WHERE p.download_token=:token AND p.customer_id=:customer',['token'=>$token,'customer'=>$customer])->fetch('assoc');
        return $p&&(int)$p['token_expires_at']>=time()&&in_array($this->state($p),['available','active'],true)?$p:null;
    }
    /** Called after a valid upstream response, before sending bytes. Range/retry requests reuse this session. */
    public function consume(string $code,string $token,int $customer): void
    {
        self::db()->transactional(function()use($code,$token,$customer){
            $p=$this->owned($code,$customer,true);
            if(!$p||!hash_equals((string)$p['download_token'],$token)||(int)$p['token_expires_at']<time()||!in_array($this->state($p),['available','active'],true))throw new \InvalidArgumentException('Lượt tải không còn hiệu lực.');
            if(empty($p['used_at']))self::db()->update('document_download_purchases',['used_at'=>time(),'token_expires_at'=>time()+self::RETRY_SECONDS,'updated_at'=>time()],['id'=>(int)$p['id']]);
        });
    }
}
