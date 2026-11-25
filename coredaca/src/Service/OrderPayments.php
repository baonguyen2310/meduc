<?php
declare(strict_types=1);
namespace App\Service;

use Cake\ORM\TableRegistry;

/** Admin payment approval is separate from affiliate commission approval. */
final class OrderPayments
{
    public const LABELS = [
        'knowledge'=>'Khoá ôn kiến thức', 'exam_solution'=>'Khoá chữa đề',
        'quiz'=>'Đề thi', 'document'=>'Tài liệu', 'shop'=>'MedUC Shop', 'fa'=>'Fa', 'other'=>'Khác'
    ];
    private const APPROVABLE = ['knowledge', 'exam_solution', 'quiz', 'document', 'shop'];

    public static function kindSql(): string
    {
        return "COALESCE((SELECT cp.kind FROM commerce_purchases cp WHERE cp.order_id=Orders.id),
            (SELECT 'document' FROM document_download_purchases dp WHERE dp.order_id=Orders.id),
            (SELECT p.course_kind FROM orders_item oi JOIN products p ON p.id=oi.product_id
             WHERE oi.order_id=Orders.id AND p.course_kind IN ('knowledge','exam_solution','quiz','fa') ORDER BY oi.id LIMIT 1),'other')";
    }

    public static function summaries(array $ids): array
    {
        $ids=array_values(array_unique(array_filter(array_map('intval',$ids))));
        if(!$ids)return [];
        $sql="SELECT Orders.id,Orders.total,Orders.status,Orders.deleted,".self::kindSql()." kind,
            cp.credit_count,cp.package_name,
            CASE WHEN cp.kind='shop' THEN JSON_UNQUOTE(JSON_EXTRACT(cp.context_json,'$.payment_method')) END payment_method,
            CASE WHEN cp.kind='shop' THEN (SELECT s.status FROM shippings s WHERE s.order_id=Orders.id ORDER BY s.id DESC LIMIT 1) END shipping_status,
            dp.document_title legacy_document_title,
            COALESCE((SELECT SUM(CASE WHEN r.type=1 THEN r.amount ELSE -r.amount END) FROM payments r
                WHERE r.foreign_type='order' AND r.foreign_id=Orders.id AND r.status=1),0) confirmed,
            CASE WHEN cp.order_id IS NULL THEN COALESCE(Orders.point_paid,0)+COALESCE(Orders.point_promotion_paid,0) ELSE 0 END points,
            (SELECT COUNT(*) FROM payments r WHERE r.foreign_type='order' AND r.foreign_id=Orders.id AND r.status=2 AND r.type=1) pending
            FROM orders Orders LEFT JOIN commerce_purchases cp ON cp.order_id=Orders.id
            LEFT JOIN document_download_purchases dp ON dp.order_id=Orders.id
            WHERE Orders.id IN (".implode(',',array_fill(0,count($ids),'?')).")";
        $result=[];
        foreach(CommercePurchases::db()->execute($sql,$ids)->fetchAll('assoc') as $row){
            $remaining=max(0,(float)$row['total']-(float)$row['confirmed']-(float)$row['points']);
            $cancelled=!empty($row['deleted'])||$row['status']===CANCEL;
            $paid=!$cancelled&&(float)$row['total']>0&&$remaining<0.001;
            $result[(int)$row['id']]=[
                'kind'=>$row['kind'],'label'=>self::LABELS[$row['kind']]??self::LABELS['other'],
                'amount'=>(float)$row['total'],'remaining'=>$remaining,'paid'=>$paid,
                'received'=>$paid&&(float)$row['confirmed']>=(float)$row['total'],
                'status_label'=>$cancelled?'Đã huỷ':($paid?'Đã thanh toán':($row['payment_method']===COD?'Chờ thu COD':($row['pending']?'Chờ duyệt thanh toán':'Chưa thanh toán'))),
                'can_approve'=>!$cancelled&&!$paid&&(float)$row['total']>0&&in_array($row['kind'],self::APPROVABLE,true),
                'payment_method'=>$row['payment_method'],
                'shipping_status'=>$row['shipping_status'],
                'package_name'=>$row['package_name']??'',
                'credit_count'=>(int)($row['credit_count']??($row['kind']==='document'?1:0)),
                'legacy_document_title'=>$row['legacy_document_title']??''
            ];
        }
        return $result;
    }

    /** Read-only admin links: viewing/downloading a source file never consumes the buyer's credit. */
    public static function documents(int $order): array
    {
        $db=CommercePurchases::db();
        $selected=$db->execute('SELECT document_title title,file_name,file_url FROM document_download_purchases WHERE order_id=?',[$order])->fetch('assoc');
        $title='';$files=[];
        $purchase=CommercePurchases::get($order);
        if(!$selected&&$purchase&&$purchase['kind']==='document'){
            $context=json_decode((string)$purchase['context_json'],true)?:[];
            $selected=$context['selected_document']??null;
            // Earlier credit packages saved only the source document page, so list its available files.
            if(!$selected&&!empty($context['document_url'])){
                $path=ltrim((string)parse_url($context['document_url'],PHP_URL_PATH),'/');
                $articleId=$db->execute('SELECT foreign_id FROM links WHERE url=? AND type=? AND lang=? AND deleted=0 LIMIT 1',[$path,ARTICLE_DETAIL,'vi'])->fetchColumn(0);
                $article=$articleId?(new ReadingHistoryService('vi'))->articles('document',[(int)$articleId])[(int)$articleId]??null:null;
                if($article){$title=$article['title'];foreach($article['files'] as $file)$files[]=['file_url'=>$file['url']];}
            }
        }
        if($selected){$title=(string)($selected['title']??'');$files=[$selected];}
        $links=[];
        foreach($files as $file){
            $url=str_replace(' ','%20',(string)($file['file_url']??''));
            try{DocumentDownloads::validateSource($url);}catch(\InvalidArgumentException $e){continue;}
            $name=(string)($file['file_name']??rawurldecode(basename((string)parse_url($url,PHP_URL_PATH))));
            $links[$url]=['name'=>$name?:'Tài liệu','url'=>$url];
        }
        return ['title'=>$title,'files'=>array_values($links)];
    }

    public static function approve(int $id,callable $savePayment,int $adminId,?float $expectedAmount=null): array
    {
        $summary = CommercePurchases::db()->transactional(function()use($id,$savePayment,$adminId,$expectedAmount){
            $db=CommercePurchases::db();
            $order=$db->execute('SELECT * FROM orders WHERE id=? FOR UPDATE',[$id])->fetch('assoc');
            if(!$order||$order['type']!==ORDER||$order['deleted']||$order['status']===CANCEL)
                throw new \InvalidArgumentException('Đơn hàng không tồn tại hoặc đã huỷ.');
            $summary=self::summaries([$id])[$id];
            if(!in_array($summary['kind'],self::APPROVABLE,true))
                throw new \InvalidArgumentException('Loại đơn này không hỗ trợ duyệt tại đây.');
            DocumentCredits::importLegacy($id);
            if(!$summary['paid']){
                if ($expectedAmount !== null && abs($summary['remaining'] - $expectedAmount) > 0.001) {
                    throw new \InvalidArgumentException('Số tiền còn phải thu đã thay đổi. Vui lòng tải lại đơn để đối soát.');
                }
                $contact=$db->execute('SELECT customer_id,full_name FROM orders_contact WHERE order_id=?',[$id])->fetch('assoc');
                $purchase=CommercePurchases::get($id);
                $archiveReference = $purchase && $purchase['kind'] === 'shop' ? ShopOrders::archiveReference($purchase) : '';
                if (!$contact || (empty($contact['customer_id']) && !$archiveReference))
                    throw new \InvalidArgumentException('Đơn chưa có tài khoản người mua.');
                $expectedTotal = $purchase && $purchase['kind'] === 'shop'
                    ? (float)$purchase['amount'] + (float)$order['shipping_fee_customer'] : (float)($purchase['amount'] ?? 0);
                if($purchase&&((int)$purchase['customer_id']!==(int)$contact['customer_id']||abs($expectedTotal-(float)$order['total'])>0.001))
                    throw new \InvalidArgumentException('Thông tin hoặc số tiền đơn đã thay đổi. Vui lòng đối soát trước khi duyệt.');
                $method = $summary['payment_method'] === COD ? COD : BANK;
                // Reuse the matching transfer report; repeated clicks must never create a second receipt.
                $receiptSql = "SELECT id FROM payments WHERE foreign_type='order' AND foreign_id=? AND status=2 AND type=1 AND payment_method=?";
                $receipt = $summary['kind'] === 'shop'
                    ? $db->execute($receiptSql . " ORDER BY (amount=?) DESC,id LIMIT 1 FOR UPDATE", [$id,$method,$summary['remaining']])->fetch('assoc')
                    : $db->execute($receiptSql . " AND amount=? ORDER BY id LIMIT 1 FOR UPDATE", [$id,$method,$summary['remaining']])->fetch('assoc');
                $data=['foreign_id'=>$id,'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>(int)$contact['customer_id'],
                    'full_name'=>$contact['full_name'],'type'=>1,'amount'=>$summary['remaining'],'payment_method'=>$method,
                    'reference'=>$archiveReference ?: $order['code'],'description'=>'Admin duyệt thanh toán đơn hàng','created_by'=>$adminId,'status'=>1];
                $saved=$savePayment($data,$receipt?(int)$receipt['id']:null);
                if(($saved[CODE]??null)!==SUCCESS)throw new \RuntimeException('Chưa xác nhận được thanh toán.');
            }
            if($order['status']===DRAFT)$db->update('orders',['status'=>NEW_ORDER,'updated'=>time()],['id'=>$id]);
            if(!TableRegistry::get('Orders')->updateAfterPayment($id))throw new \RuntimeException('Chưa cập nhật được đơn hàng.');
            // Do not silently approve a receipt if fulfillment failed.
            if(CommercePurchases::get($id))CommercePurchases::syncOrder($id);
            $purchase=CommercePurchases::get($id);
            if($purchase&&(!$purchase['approved_at']||!CommercePurchases::paid($purchase)))throw new \RuntimeException('Chưa cập nhật được quyền sử dụng.');
            $summary=self::summaries([$id])[$id];
            if(!$summary['paid'])throw new \RuntimeException('Đơn hàng chưa được thanh toán đủ.');
            return $summary;
        });
        Vouchers::awardAfterPayment($id);
        return $summary;
    }
}
