<?php
declare(strict_types=1);
namespace App\Service;

/** Download credits are allocated once, after the upstream file was opened successfully. */
final class DocumentCredits
{
    /** Preserve old file selections; their paid entitlement becomes one shared download credit. */
    public static function importLegacy(int $order): bool {
        if(!DocumentDownloads::installed()||!CommercePurchases::installed())return false;
        // Cake treats a literal false callback result as rollback, including the parent approval.
        // Use integer results inside the transaction and convert to the public boolean afterwards.
        return (bool)CommercePurchases::db()->transactional(function()use($order){
            $db=CommercePurchases::db();
            $old=$db->execute('SELECT * FROM document_download_purchases WHERE order_id=?',[$order])->fetch('assoc');
            if(!$old)return 0;
            $invoice=$db->execute('SELECT id,total,deleted FROM orders WHERE id=? FOR UPDATE',[$order])->fetch('assoc');
            if(!$invoice||$invoice['deleted'])return 0;
            if(CommercePurchases::get($order))return 0;
            $owner=$db->execute('SELECT customer_id FROM orders_contact WHERE order_id=?',[$order])->fetchColumn(0);
            if((int)$owner!==(int)$old['customer_id']||abs((float)$invoice['total']-(int)$old['amount'])>0.001)
                throw new \InvalidArgumentException('Thông tin đơn tài liệu cũ không khớp.');
            $now=time();
            $db->insert('commerce_purchases',[
                'order_id'=>$order,'public_code'=>$old['code'],'customer_id'=>$old['customer_id'],'kind'=>'document',
                'package_id'=>0,'package_name'=>'1 lượt tải · Đơn tài liệu cũ','credit_count'=>1,
                'amount'=>$old['amount'],'original_amount'=>$old['amount'],
                'context_json'=>json_encode(['document_url'=>$old['document_url'],'legacy_document'=>[
                    'title'=>$old['document_title'],'article_id'=>(int)$old['article_id'],'file_name'=>$old['file_name']]],JSON_UNESCAPED_UNICODE),
                'reported_at'=>$old['transfer_reported_at'],'created_at'=>$old['created_at'],'updated_at'=>$now
            ]);
            if($old['used_at']){
                $db->insert('document_credit_uses',[
                    'code'=>$old['code'],'customer_id'=>$old['customer_id'],'grant_order_id'=>$order,
                    'article_id'=>$old['article_id'],'file_index'=>$old['file_index'],'file_key'=>$old['file_key'],
                    'file_name'=>$old['file_name'],'file_url'=>$old['file_url'],
                    'download_token'=>$old['download_token']?:bin2hex(random_bytes(32)),
                    'token_expires_at'=>$old['token_expires_at']?:0,'used_at'=>$old['used_at'],'created_at'=>$old['created_at']
                ]);
            }
            CommercePurchases::syncOrder($order);
            return 1;
        });
    }

    public static function grants(int $customer):array {
        if(!$customer||!CommercePurchases::installed())return [];
        return CommercePurchases::db()->execute("SELECT p.order_id,p.credit_count-COALESCE((SELECT COUNT(*) FROM document_credit_uses u WHERE u.grant_order_id=p.order_id AND u.used_at IS NOT NULL),0) remaining
          FROM commerce_purchases p JOIN orders o ON o.id=p.order_id JOIN orders_contact c ON c.order_id=o.id
          WHERE p.customer_id=? AND p.kind='document' AND p.approved_at IS NOT NULL AND o.deleted=0 AND o.status<>'cancel' AND c.customer_id=p.customer_id
          AND COALESCE((SELECT SUM(CASE WHEN r.type=1 THEN r.amount ELSE -r.amount END) FROM payments r WHERE r.foreign_type='order' AND r.foreign_id=p.order_id AND r.status=1),0)>=p.amount
          HAVING remaining>0 ORDER BY p.approved_at,p.order_id",[$customer])->fetchAll('assoc');
    }
    public static function balance(int $customer):int {return array_sum(array_map('intval',array_column(self::grants($customer),'remaining')));}
    public static function packages():array {
        $list=CommercePurchases::db()->execute("SELECT id FROM course_price_lists WHERE course_type='document' AND status=1 ORDER BY position,id LIMIT 1")->fetchColumn(0);
        return $list?CoursePricing::packages((int)$list):[];
    }
    public static function issue(int $customer,array $file):array {
        return CommercePurchases::db()->transactional(function()use($customer,$file){
            $db=CommercePurchases::db();$db->execute('SELECT id FROM customers WHERE id=? AND deleted=0 FOR UPDATE',[$customer])->fetch();
            // Each explicit download action gets a new ticket, even for the same file.
            // Range requests and interrupted-transfer retries reuse that ticket's URL instead.
            if(self::balance($customer)<1)throw new \InvalidArgumentException('Bạn đã hết lượt tải. Vui lòng chọn gói lượt tải.');
            $use=['code'=>bin2hex(random_bytes(16)),'customer_id'=>$customer,'article_id'=>$file['article_id'],'file_index'=>$file['file_index'],'file_key'=>$file['file_key'],
                'file_name'=>$file['file_name'],'file_url'=>$file['file_url'],'download_token'=>bin2hex(random_bytes(32)),'token_expires_at'=>time()+DocumentDownloads::RETRY_SECONDS,'created_at'=>time()];
            $db->insert('document_credit_uses',$use);return self::link($use);
        });
    }
    private static function link(array $u):array {return ['url'=>'/document-download/file/'.$u['download_token'],'file_name'=>$u['file_name'],'expires_at'=>(int)$u['token_expires_at']];}
    public static function ticket(string $token,int $customer):?array {
        if(!preg_match('/^[a-f0-9]{64}$/',$token)||!CommercePurchases::installed())return null;
        $u=CommercePurchases::db()->execute('SELECT * FROM document_credit_uses WHERE download_token=? AND customer_id=? AND token_expires_at>=?',[$token,$customer,time()])->fetch('assoc');
        if(!$u)return null;
        if($u['used_at']){$grant=CommercePurchases::get((int)$u['grant_order_id']);if(!$grant||!$grant['approved_at']||!CommercePurchases::paid($grant))return null;}
        elseif(!self::balance($customer))return null;
        $u['credit_use']=true;return $u;
    }
    public static function consume(string $token,int $customer):void {
        CommercePurchases::db()->transactional(function()use($token,$customer){
            $db=CommercePurchases::db();
            // Customers is MyISAM on the legacy hosting; lock the InnoDB wallet rows instead.
            // This serializes distinct tickets for one buyer before reading their remaining balance.
            $db->execute("SELECT order_id FROM commerce_purchases WHERE customer_id=? AND kind='document' ORDER BY order_id FOR UPDATE",[$customer])->fetchAll('assoc');
            $use=$db->execute('SELECT * FROM document_credit_uses WHERE download_token=? AND customer_id=? AND token_expires_at>=? FOR UPDATE',[$token,$customer,time()])->fetch('assoc');
            if(!$use)throw new \InvalidArgumentException('Lượt tải không còn hiệu lực.');
            if($use['used_at']){if(!self::ticket($token,$customer))throw new \InvalidArgumentException('Lượt tải không còn hiệu lực.');return;}
            $grants=self::grants($customer);if(!$grants)throw new \InvalidArgumentException('Bạn đã hết lượt tải.');
            $db->update('document_credit_uses',['grant_order_id'=>$grants[0]['order_id'],'used_at'=>time(),'token_expires_at'=>time()+DocumentDownloads::RETRY_SECONDS],['id'=>$use['id']]);
        });
    }
    public static function publicPurchase(array $p):array {
        $context=json_decode((string)$p['context_json'],true)?:[];
        $state=!empty($p['order_deleted'])||$p['order_status']===CANCEL?'cancelled':($p['approved_at']&&CommercePurchases::paid($p)?'available':'pending');
        return ['mode'=>'credits','code'=>$p['public_code'],'order_code'=>$p['order_code'],'document_title'=>$p['package_name'],
            'document_url'=>$context['document_url']??'/tai-lieu-hoc-tap','file_name'=>'Dùng chung cho mọi tệp trong thư viện tài liệu.',
            'amount'=>(int)$p['amount'],'original_amount'=>(int)$p['original_amount'],'credit_count'=>(int)$p['credit_count'],'balance'=>self::balance((int)$p['customer_id']),
            'reported'=>!empty($p['reported_at']),'state'=>$state,'expires_at'=>0,'payment_url'=>'/document-download/payment/'.$p['public_code']];
    }
}
