<?php
declare(strict_types=1);
namespace App\Service;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Cake\Utility\Security;

/** Immutable purchase terms; access starts only after a confirmed receipt. */
final class CommercePurchases
{
    public static function db(){return ConnectionManager::get('default');}
    public static function installed():bool {
        static $yes;if($yes===null)$yes=(bool)self::db()->execute("SHOW TABLES LIKE 'commerce_purchases'")->fetch();return $yes;
    }
    public static function get(int $id,bool $lock=false):?array {
        if(!self::installed())return null;
        return self::db()->execute('SELECT p.*,o.code order_code,o.status order_status,o.deleted order_deleted,c.full_name,c.phone,c.email,
         c.customer_id order_customer,COALESCE((SELECT SUM(CASE WHEN r.type=1 THEN r.amount ELSE -r.amount END) FROM payments r WHERE r.foreign_id=p.order_id AND r.foreign_type=\'order\' AND r.status=1),0) confirmed
         FROM commerce_purchases p JOIN orders o ON o.id=p.order_id JOIN orders_contact c ON c.order_id=o.id WHERE p.order_id=?'.($lock?' FOR UPDATE':''),[$id])->fetch('assoc')?:null;
    }
    public static function owned(string $code,int $customer):?array {
        if(!self::installed()||!preg_match('/^[a-f0-9]{32}$/',$code))return null;
        $id=self::db()->execute('SELECT order_id FROM commerce_purchases WHERE public_code=? AND customer_id=?',[$code,$customer])->fetchColumn(0);
        return $id?self::get((int)$id):null;
    }
    public static function paid(array $p):bool {
        return empty($p['order_deleted'])&&$p['order_status']!==CANCEL&&(int)$p['order_customer']===(int)$p['customer_id']&&(float)$p['confirmed']>=(int)$p['amount'];
    }
    public static function create(array $customer,array $quote,callable $saveOrder,array $context=[]):array {
        return self::db()->transactional(function()use($customer,$quote,$saveOrder,$context){
            $p=$quote['package'];$kind=$p['course_type'];$items=[];$count=count($quote['courses']);$remaining=$quote['amount'];
            foreach($quote['courses'] as $i=>$course){$price=$i===$count-1?$remaining:intdiv($quote['amount'],$count);$remaining-=$price;
                $items[]=['product_id'=>(int)$course['id'],'product_item_id'=>(int)$course['item_id'],'quantity'=>1,'price'=>$price,'vat_value'=>0];}
            if($kind==='document'){
                $sku=self::db()->execute("SELECT i.id,i.product_id FROM products_item i JOIN products p ON p.id=i.product_id WHERE i.code='MEDUC_DOCUMENT_DOWNLOAD' AND i.deleted=0 AND p.deleted=0 AND p.status=0 AND p.draft=1")->fetch('assoc');
                if(!$sku)throw new \RuntimeException('Dịch vụ lượt tải chưa sẵn sàng.');
                $items[]=['product_id'=>(int)$sku['product_id'],'product_item_id'=>(int)$sku['id'],'quantity'=>1,'price'=>$quote['amount'],'vat_value'=>0];
            }
            $result=$saveOrder(['type'=>ORDER,'source'=>WEBSITE,'status'=>DRAFT,'note'=>mb_substr($p['list_name'].' · '.$p['name'],0,250),
                'contact'=>['customer_id'=>(int)$customer['id'],'full_name'=>$customer['full_name'],'email'=>$customer['email'],'phone'=>$customer['phone']??null],'items'=>$items]);
            if(($result[CODE]??null)!==SUCCESS)throw new \RuntimeException($result[MESSAGE]??'Chưa tạo được đơn hàng.');
            $order=$result[DATA];$now=time();
            self::db()->update('orders',['course_price_package_id'=>(int)$p['id'],'course_price_snapshot'=>json_encode($quote,JSON_UNESCAPED_UNICODE)],['id'=>$order['id']]);
            self::db()->insert('commerce_purchases',['order_id'=>$order['id'],'public_code'=>bin2hex(random_bytes(16)),'customer_id'=>$customer['id'],'kind'=>$kind,
                'package_id'=>$p['id'],'package_name'=>$p['name'],'product_id'=>$kind==='quiz'?(int)$quote['courses'][0]['id']:null,
                'duration_months'=>$p['duration_months']?:null,'credit_count'=>(int)$p['credit_count'],'amount'=>$quote['amount'],'original_amount'=>$p['price'],
                'context_json'=>json_encode($context,JSON_UNESCAPED_UNICODE),'created_at'=>$now,'updated_at'=>$now]);
            return self::get((int)$order['id']);
        });
    }
    public static function report(int $id):void {
        self::db()->execute('UPDATE commerce_purchases SET reported_at=COALESCE(reported_at,?),updated_at=? WHERE order_id=?',[time(),time(),$id]);
    }
    public static function addMonths(int $start,int $months):int {
        $date=(new \DateTimeImmutable('@'.$start))->setTimezone(new \DateTimeZone('Asia/Ho_Chi_Minh'));
        $target=$date->modify('first day of this month')->modify('+'.$months.' months');
        return $target->setDate((int)$target->format('Y'),(int)$target->format('m'),min((int)$date->format('d'),(int)$target->format('t')))->getTimestamp();
    }
    /** Returns false only for an invoice from the older checkout. */
    public static function syncOrder(int $id):bool {
        if(!self::get($id))return false;
        self::db()->transactional(function()use($id){
            $p=self::get($id,true);$db=self::db();$now=time();
            $db->execute('SELECT id FROM customers WHERE id=? FOR UPDATE',[$p['customer_id']])->fetch();
            if(self::paid($p))$db->execute('UPDATE commerce_purchases SET approved_at=COALESCE(approved_at,?),fulfilled_at=COALESCE(fulfilled_at,?),updated_at=? WHERE order_id=?',[$now,$now,$now,$id]);
            if($p['kind']==='document')return;
            $products=$db->execute('SELECT DISTINCT product_id FROM orders_item WHERE order_id=?',[$id])->fetchAll('assoc');
            foreach($products as $product)self::rebuildAccess((int)$p['customer_id'],(int)$product['product_id']);
        });return true;
    }
    private static function rebuildAccess(int $customer,int $product):void {
        if(!in_array(CourseTypes::kind($product),['knowledge','exam_solution','quiz'],true))return;
        $db=self::db();$table=TableRegistry::get('CourseEnrollments');
        $current=$table->find()->where(['customer_id'=>$customer,'product_id'=>$product])->enableHydration(false)->first();
        // Keep existing manual and pre-migration lifetime rights intact.
        if($current&&$current['status']==1&&!$current['deleted']&&empty($current['expires_at'])&&($current['source']==='admin'||!self::get((int)$current['order_id'])))return;
        $rows=$db->execute('SELECT p.order_id FROM commerce_purchases p WHERE p.customer_id=? AND p.kind<>\'document\' AND p.approved_at IS NOT NULL AND EXISTS (SELECT 1 FROM orders_item i WHERE i.order_id=p.order_id AND i.product_id=?) ORDER BY p.approved_at,p.order_id',[$customer,$product])->fetchAll('assoc');
        $expiry=0;$owner=0;
        foreach($rows as $row){
            $grant=self::get((int)$row['order_id']);if(!self::paid($grant))continue;
            $owner=(int)$grant['order_id'];
            $expiry=$grant['duration_months']?self::addMonths(max($expiry,(int)$grant['approved_at']),(int)$grant['duration_months']):null;
            $db->update('commerce_purchases',['expires_at'=>$expiry],['order_id'=>$owner]);
            if($expiry===null)break;
        }
        if(!$owner){if($current&&$current['source']==='order'&&self::get((int)$current['order_id']))$table->updateAll(['status'=>0,'updated'=>time()],['id'=>$current['id']]);return;}
        if($current&&$current['source']==='admin'&&$current['status']==1&&!$current['deleted']&&$expiry!==null&&(int)$current['expires_at']>$expiry)return;
        if(!$table->enroll($customer,$product,['source'=>'order','order_id'=>$owner,'expires_at'=>$expiry,'created_by'=>null]))throw new \RuntimeException('Chưa mở được quyền học.');
    }
    public static function approvalSignature(array $p):string {
        return hash_hmac('sha256','meduc-purchase:'.$p['public_code'].':'.$p['order_id'].':'.$p['reported_at'],Security::getSalt());
    }
    public static function approval(string $code,string $signature):?array {
        if(!self::installed()||!preg_match('/^[a-f0-9]{32}$/',$code)||!preg_match('/^[a-f0-9]{64}$/',$signature))return null;
        $id=self::db()->execute('SELECT order_id FROM commerce_purchases WHERE public_code=?',[$code])->fetchColumn(0);$p=$id?self::get((int)$id):null;
        return $p&&!empty($p['reported_at'])&&(int)$p['reported_at']>=time()-7*86400&&hash_equals(self::approvalSignature($p),$signature)?$p:null;
    }
    public static function approve(string $code,string $signature,callable $savePayment):array {
        $p=self::approval($code,$signature);if(!$p)throw new \InvalidArgumentException('Liên kết duyệt không còn hiệu lực. Vui lòng mở đơn trong admin.');
        return self::db()->transactional(function()use($p,$savePayment){
            $p=self::get((int)$p['order_id'],true);
            if($p['order_status']===CANCEL||$p['order_deleted'])throw new \InvalidArgumentException('Đơn hàng đã huỷ.');
            if(!self::paid($p)){
                if((float)$p['confirmed']!==0.0)throw new \InvalidArgumentException('Đơn có giao dịch đã xác nhận hoặc hoàn tiền. Vui lòng đối soát trong admin.');
                $receipt=self::db()->execute("SELECT id FROM payments WHERE foreign_type='order' AND foreign_id=? AND status=2 AND type=1 AND amount=? ORDER BY id LIMIT 1 FOR UPDATE",[$p['order_id'],$p['amount']])->fetch('assoc');
                if(!$receipt)throw new \InvalidArgumentException('Không có giao dịch chờ duyệt khớp số tiền. Vui lòng kiểm tra trong admin.');
                $result=$savePayment(['type'=>1,'object_type'=>CUSTOMER,'object_id'=>$p['customer_id'],'foreign_type'=>ORDER,'foreign_id'=>$p['order_id'],'amount'=>$p['amount'],'payment_method'=>BANK,'reference'=>$p['order_code'],'status'=>1],(int)$receipt['id']);
                if(($result[CODE]??null)!==SUCCESS)throw new \RuntimeException('Chưa xác nhận được giao dịch.');
                if(!TableRegistry::get('Orders')->updateAfterPayment($p['order_id']))throw new \RuntimeException('Chưa cập nhật được đơn hàng.');
            }
            self::syncOrder((int)$p['order_id']);return self::get((int)$p['order_id']);
        });
    }
}
