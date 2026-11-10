<?php
declare(strict_types=1);
namespace App\Service;
use Cake\ORM\TableRegistry;

/** Purchase-only mail outbox. Sending failure never discards an order or grants access. */
final class CommerceNotifications
{
    public static function adminEmail():string {
        $email=(string)(TableRegistry::get('Settings')->getSettingWebsite()['email']['email_administrator']??'');
        if(!filter_var($email,FILTER_VALIDATE_EMAIL))throw new \RuntimeException('Chưa cấu hình email quản trị.');return $email;
    }
    private static function esc($v):string {return htmlspecialchars((string)$v,ENT_QUOTES,'UTF-8');}
    public static function origin(string $host='meduc.vn'):string {return 'https://'.(in_array($host,['meduc.vn','meducv3.duckdns.org'],true)?$host:'meduc.vn');}
    private static function html(string $heading,string $lead,array $facts,string $action,string $url):string {
        $rows='';foreach($facts as $label=>$value)$rows.='<tr><td style="padding:12px 0;color:#6b7280;border-bottom:1px solid #e5e7eb">'.self::esc($label).'</td><td style="padding:12px 0 12px 16px;font-weight:600;text-align:right;border-bottom:1px solid #e5e7eb">'.self::esc($value).'</td></tr>';
        return '<!doctype html><html lang="vi"><body style="margin:0;background:#f5f5f7;font-family:Arial,sans-serif;color:#181a20"><div style="max-width:580px;margin:32px auto;padding:34px;background:#fff;border:1px solid #e5e7eb;border-radius:14px"><div style="font-size:25px;font-weight:700;margin-bottom:30px"><span style="color:#df1939">M</span> MedUC</div><h1 style="font-size:26px;line-height:1.35">'.self::esc($heading).'</h1><p style="font-size:15px;line-height:1.8;color:#626775">'.self::esc($lead).'</p><table style="width:100%;font-size:14px;border-collapse:collapse">'.$rows.'</table><p style="margin:30px 0"><a href="'.self::esc($url).'" style="display:inline-block;padding:16px 24px;background:#dd1938;color:white;text-decoration:none;border-radius:7px;font-size:15px;font-weight:700">'.self::esc($action).'</a></p><p style="font-size:12px;line-height:1.7;color:#7a7f89">MedUC · Học Y cùng người hướng dẫn.</p></div></body></html>';
    }
    public static function purchase(int $id,string $event,callable $send,string $host='meduc.vn'):void {
        try { self::queuePurchase($id,$event,$send,$host); }
        catch(\Throwable $e){\Cake\Log\Log::error('Commerce email queue failed for order '.$id);}
    }
    private static function queuePurchase(int $id,string $event,callable $send,string $host):void {
        $p=CommercePurchases::get($id);if(!$p||!$p['reported_at'])return;
        $approved=$event==='approved';$origin=self::origin($host);
        $names=CommercePurchases::db()->execute("SELECT pc.name FROM orders_item i JOIN products_content pc ON pc.product_id=i.product_id AND pc.lang='vi' WHERE i.order_id=?",[$id])->fetchAll('assoc');
        $facts=['Mã đơn'=>$p['order_code'],'Gói mua'=>$p['package_name'],'Sản phẩm'=>$p['kind']==='document'?'Lượt tải tài liệu':implode(', ',array_column($names,'name')),
            'Người mua'=>$p['full_name'],'Email'=>$p['email'],'Số điện thoại'=>$p['phone'],'Tổng thanh toán'=>number_format((int)$p['amount'],0,',','.').'đ'];
        if($p['credit_count'])$facts['Lượt tải được cộng']=$p['credit_count'].' lượt';
        if($p['duration_months'])$facts['Thời hạn']=$p['duration_months'].' tháng từ khi duyệt';
        if($p['expires_at'])$facts['Có hiệu lực đến']=date('d/m/Y H:i',(int)$p['expires_at']);
        $approval=$origin.'/duyet-thanh-toan/'.$p['public_code'].'/'.CommercePurchases::approvalSignature($p);
        $customerUrl=$origin.($p['kind']==='document'?'/document-download/payment/'.$p['public_code']:'/khoa-hoc-da-dang-ky');
        foreach(['admin'=>self::adminEmail(),'buyer'=>$p['email']] as $role=>$email){
            if(!filter_var($email,FILTER_VALIDATE_EMAIL))continue;
            $heading=$approved?'Thanh toán đã được duyệt':($role==='admin'?'Đơn hàng đang chờ duyệt':'MedUC đã nhận thông tin thanh toán');
            $lead=$approved?'Quyền sử dụng của đơn hàng đã được cập nhật.':($role==='admin'?'Kiểm tra giao dịch rồi xác nhận để mở quyền cho người mua.':'MedUC sẽ kiểm tra chuyển khoản và mở quyền sau khi xác nhận.');
            $body=self::html($heading,$lead,$facts,$role==='admin'&&!$approved?'Duyệt và mở quyền':'Xem đơn hàng',$role==='admin'?$approval:$customerUrl);
            self::queue('purchase:'.$id.':'.$event.':'.$role,$email,'[MedUC] '.$heading.' · '.$p['order_code'],$body,$send);
        }
    }
    public static function book(int $id,callable $send,string $host='meduc.vn'):void {
        try { self::queueBook($id,$send,$host); }
        catch(\Throwable $e){\Cake\Log\Log::error('Commerce email queue failed for book contact '.$id);}
    }
    private static function queueBook(int $id,callable $send,string $host):void {
        $record=TableRegistry::get('Contacts')->find()->where(['id'=>$id])->enableHydration(false)->first();$data=json_decode((string)($record['value']??''),true)?:[];
        if(empty($data['cartId']))return;
        $facts=['Mã đơn'=>$data['cartId'],'Người nhận'=>$data['full_name'],'Email'=>$data['email'],'Số điện thoại'=>$data['phone'],'Địa chỉ'=>$data['address'],
            'Tổng tiền sản phẩm'=>number_format((float)$data['totalPrice'],0,',','.').'đ','Thanh toán'=>$data['payment']==='cod'?'COD · Thanh toán khi nhận sách':'Chuyển khoản ngân hàng'];
        foreach(json_decode((string)$data['cartProducts'],true)?:[] as $i=>$product)$facts['Sách '.($i+1)]=($product['name']??'').' × '.($product['quantity']??1);
        foreach(['admin'=>self::adminEmail(),'buyer'=>$data['email']] as $role=>$email){
            $url=self::origin($host).($role==='admin'?'/admin/contact/detail/'.$id:'/dat-hang-thanh-cong?cartId='.rawurlencode($data['cartId']));
            self::queue('book:'.$id.':'.$role,$email,'[MedUC] Đơn sách '.$data['cartId'],self::html('Đã ghi nhận đơn sách','MedUC sẽ liên hệ xác nhận và chuẩn bị giao sách.',$facts,$role==='admin'?'Xem đơn sách':'Xem đơn hàng',$url),$send);
        }
    }
    private static function queue(string $key,string $email,string $subject,string $html,callable $send):void {
        $db=CommercePurchases::db();$key=hash('sha256',$key);$now=time();
        $db->execute("INSERT IGNORE INTO commerce_notifications (dedupe_key,recipient,subject,html,created_at,updated_at) VALUES (?,?,?,?,?,?)",[$key,$email,$subject,$html,$now,$now]);
        $row=$db->execute('SELECT id FROM commerce_notifications WHERE dedupe_key=?',[$key])->fetch('assoc');self::deliver((int)$row['id'],$send);
    }
    public static function deliver(int $id,callable $send):bool {
        $db=CommercePurchases::db();$lock=$db->execute('SELECT GET_LOCK(?,0)',['meduc-mail-'.$id])->fetchColumn(0);if(!$lock)return false;
        try{
            $r=$db->execute('SELECT * FROM commerce_notifications WHERE id=?',[$id])->fetch('assoc');if(!$r||$r['status']==='sent')return true;
            $db->execute("UPDATE commerce_notifications SET status='sending',attempts=attempts+1,updated_at=? WHERE id=?",[time(),$id]);
            $result=$send(['to_email'=>$r['recipient'],'subject'=>$r['subject'],'content'=>$r['html'],'send_try_content'=>true,'from_website_template'=>true,'delivery_timeout'=>10,'idempotency_key'=>'meduc-commerce-'.$r['dedupe_key']]);
            if(($result[CODE]??null)!==SUCCESS)throw new \RuntimeException('Email chưa được gửi.');
            $db->update('commerce_notifications',['status'=>'sent','provider_id'=>$result[DATA]['provider_id']??null,'last_error'=>null,'updated_at'=>time()],['id'=>$id]);return true;
        }catch(\Throwable $e){$db->update('commerce_notifications',['status'=>'failed','last_error'=>'Chưa kết nối được dịch vụ email.','updated_at'=>time()],['id'=>$id]);return false;}
        finally{$db->execute('SELECT RELEASE_LOCK(?)',['meduc-mail-'.$id]);}
    }
    public static function retry(callable $send):int {
        if(!CommercePurchases::installed())return 0;$rows=CommercePurchases::db()->execute("SELECT id FROM commerce_notifications WHERE status<>'sent' AND updated_at<? ORDER BY id LIMIT 20",[time()-120])->fetchAll('assoc');
        $count=0;foreach($rows as $r)if(self::deliver((int)$r['id'],$send))$count++;return $count;
    }
}
