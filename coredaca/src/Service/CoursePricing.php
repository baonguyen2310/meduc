<?php
namespace App\Service;

use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Cake\Utility\Text;

/** A course belongs to one price list; quantity tiers belong to that list. */
class CoursePricing
{
    public static function db() { return ConnectionManager::get('default'); }

    public static function lists(bool $active = false): array
    {
        return self::db()->execute('SELECT l.*, (SELECT COUNT(*) FROM products p WHERE p.course_price_list_id=l.id AND p.deleted=0) AS course_total,
            (SELECT COUNT(*) FROM course_price_packages k WHERE k.price_list_id=l.id AND k.status=1) AS package_total
            FROM course_price_lists l ' . ($active ? 'WHERE l.status=1 ' : '') . 'ORDER BY l.position,l.id')->fetchAll('assoc');
    }

    public static function get($id): ?array
    {
        $r = self::db()->execute('SELECT * FROM course_price_lists WHERE id=:id', ['id'=>(int)$id])->fetch('assoc');
        return $r ?: null;
    }

    public static function packages(int $id, bool $active = true): array
    {
        $rows = self::db()->execute('SELECT * FROM course_price_packages WHERE price_list_id=:id ' . ($active ? 'AND status=1 ' : '') . 'ORDER BY position,id', ['id'=>$id])->fetchAll('assoc');
        foreach ($rows as &$r) {
            $r['amount'] = $r['sale_price'] !== null ? (int)$r['sale_price'] : (int)$r['price'];
            $r['saving'] = (int)$r['price'] > $r['amount'] ? (int)round(100 * (1 - $r['amount'] / (int)$r['price'])) : 0;
            $r['lines'] = array_values(array_filter(array_map('trim', preg_split('/\r?\n/', (string)$r['benefits']))));
        }
        return $rows;
    }

    public static function courses(int $id): array
    {
        $rows = self::db()->execute("SELECT p.id,pc.name,l.url,
            (SELECT GROUP_CONCAT(cp.category_id) FROM categories_product cp WHERE cp.product_id=p.id) AS category_ids,
            (SELECT MIN(i.id) FROM products_item i WHERE i.product_id=p.id AND i.deleted=0 AND i.status=1) AS item_id
            FROM products p JOIN products_content pc ON pc.product_id=p.id AND pc.lang='vi'
            LEFT JOIN links l ON l.foreign_id=p.id AND l.type='product_detail' AND l.lang='vi'
            WHERE p.course_price_list_id=:id AND p.deleted=0 AND p.status=1 AND COALESCE(p.draft,0)=0
            ORDER BY p.position,p.id", ['id'=>$id])->fetchAll('assoc');
        foreach ($rows as &$row) {
            $years=[];
            foreach (explode(',', (string)$row['category_ids']) as $category) {
                $category=(int)$category;
                if ($category>=991 && $category<=996) $years[]=(string)($category-990);
                if ($category===102) $years=array_merge($years,['1','2']);
                if ($category===72) $years=array_merge($years,['3','4']);
                if ($category===103) $years[]='graduate';
            }
            $row['years']=array_values(array_unique($years));
            unset($row['category_ids']);
        }
        return $rows;
    }

    public static function courseListId(int $id): int
    {
        return (int)self::db()->execute('SELECT course_price_list_id FROM products WHERE id=:id AND deleted=0', ['id'=>$id])->fetchColumn(0);
    }

    /** Validate the selected distinct courses and compute prices exclusively on the server. */
    public static function quote(int $packageId, array $selection): array
    {
        $p = self::db()->execute('SELECT p.*,l.name AS list_name,l.slug AS list_slug FROM course_price_packages p
            JOIN course_price_lists l ON l.id=p.price_list_id WHERE p.id=:id AND p.status=1 AND l.status=1', ['id'=>$packageId])->fetch('assoc');
        if (!$p) throw new \InvalidArgumentException('Gói học không còn mở đăng ký.');
        $ids = array_map('intval', array_values($selection));
        if (count($ids) !== (int)$p['course_count'] || count(array_unique($ids)) !== count($ids) || in_array(0,$ids,true)) {
            throw new \InvalidArgumentException('Vui lòng chọn đúng ' . (int)$p['course_count'] . ' môn khác nhau.');
        }
        $courses = array_column(self::courses((int)$p['price_list_id']), null, 'id');
        $chosen = [];
        foreach ($ids as $id) {
            if (empty($courses[$id]['item_id'])) throw new \InvalidArgumentException('Môn được chọn không thuộc bảng giá hoặc không còn mở đăng ký.');
            $chosen[] = $courses[$id];
        }
        $amount = $p['sale_price'] !== null ? (int)$p['sale_price'] : (int)$p['price'];
        if ($amount < 1) throw new \InvalidArgumentException('Gói học chưa có giá hợp lệ.');
        $p['amount'] = $amount;
        return ['package'=>$p, 'courses'=>$chosen, 'amount'=>$amount];
    }

    public static function options(?string $kind=null): array
    {
        $out=[]; foreach (self::lists() as $r) if (!$kind || $r['course_type']===$kind) $out[$r['id']]=$r['name'] . ((int)$r['status'] ? '' : ' (đang ẩn)');
        return $out;
    }

    /** Price lists for regular courses and exam preparation must stay separate. */
    public static function courseKinds(): array
    {
        $rows=self::db()->execute("SELECT p.id, CASE WHEN p.main_category_id=125 OR EXISTS (
            SELECT 1 FROM categories c WHERE c.id=p.main_category_id AND c.path_id LIKE '%|125|%'
            ) OR EXISTS (SELECT 1 FROM categories_product cp JOIN categories c ON c.id=cp.category_id
            WHERE cp.product_id=p.id AND (c.id=125 OR c.path_id LIKE '%|125|%'))
            THEN 'exam_prep' ELSE 'course' END AS kind FROM products p WHERE p.deleted=0")->fetchAll('assoc');
        return array_column($rows,'kind','id');
    }

    public static function courseKind(int $id): string
    {
        return self::courseKinds()[$id] ?? 'course';
    }

    public static function categoryKind(array $ids): string
    {
        $ids=array_values(array_filter(array_map('intval',$ids)));
        if (!$ids) return 'course';
        $exam=self::db()->execute("SELECT 1 FROM categories WHERE id IN (".implode(',',$ids).")
            AND (id=125 OR path_id LIKE '%|125|%') LIMIT 1")->fetchColumn(0);
        return $exam ? 'exam_prep' : 'course';
    }

    public static function acceptsCategories(int $listId,array $ids): bool
    {
        $list=self::get($listId);
        return $list && $list['course_type']===self::categoryKind($ids);
    }

    public static function save(int $id, array $data): int
    {
        $name=trim((string)($data['name']??''));
        $slug=strtolower(Text::slug(trim((string)($data['slug']??'')) ?: $name));
        if (!$name || mb_strlen($name)>180 || !$slug || strlen($slug)>180) throw new \InvalidArgumentException('Tên và đường dẫn bảng giá không hợp lệ.');
        $description=trim((string)($data['description']??''));
        if (mb_strlen($description)>3000) throw new \InvalidArgumentException('Mô tả tối đa 3.000 ký tự.');
        $kind=(string)($data['course_type']??(self::get($id)['course_type']??'course'));
        if (!in_array($kind,['course','exam_prep'],true)) throw new \InvalidArgumentException('Loại bảng giá không hợp lệ.');
        $packages=$data['packages']??[];
        if (!is_array($packages) || count($packages)>30) throw new \InvalidArgumentException('Mỗi bảng giá có tối đa 30 gói.');
        $rows=[];
        foreach ($packages as $p) {
            $pn=trim((string)($p['name']??'')); if (!$pn) continue;
            $count=filter_var($p['course_count']??null,FILTER_VALIDATE_INT);
            $price=filter_var($p['price']??null,FILTER_VALIDATE_INT);
            $sale=isset($p['sale_price']) && $p['sale_price']!=='' ? filter_var($p['sale_price'],FILTER_VALIDATE_INT) : null;
            if (mb_strlen($pn)>120 || $count<1 || $count>1000 || $price===false || $price<1 || $price>999999999999 || ($sale!==null && ($sale===false || $sale<1 || $sale>$price))) throw new \InvalidArgumentException('Kiểm tra số môn và giá của gói ' . $pn . '. Giá ưu đãi phải lớn hơn 0 và không vượt giá gốc.');
            $benefits=trim((string)($p['benefits']??''));
            if (mb_strlen($benefits)>5000) throw new \InvalidArgumentException('Quyền lợi gói tối đa 5.000 ký tự.');
            $rows[]=['id'=>(int)($p['id']??0),'name'=>$pn,'course_count'=>$count,'price'=>$price,'sale_price'=>$sale,'benefits'=>$benefits,'recommended'=>empty($p['recommended'])?0:1,'position'=>(int)($p['position']??count($rows)),'status'=>empty($p['status'])?0:1];
        }
        $courseIds=array_values(array_unique(array_filter(array_map('intval',is_array($data['course_ids']??null)?$data['course_ids']:[]))));
        $valid=TableRegistry::get('CourseEnrollments')->courseIds();
        if (array_diff($courseIds,$valid)) throw new \InvalidArgumentException('Chỉ được gán các sản phẩm là khóa học.');
        $kinds=self::courseKinds();
        foreach ($courseIds as $cid) if (($kinds[$cid]??null)!==$kind) throw new \InvalidArgumentException('Khóa học và khóa luyện thi phải nằm trong các bảng giá riêng.');
        $db=self::db();
        return $db->transactional(function() use($db,$id,$name,$slug,$description,$data,$rows,$courseIds,$kind) {
            if ($id && !self::get($id)) throw new \InvalidArgumentException('Không tìm thấy bảng giá.');
            if ($db->execute('SELECT id FROM course_price_lists WHERE slug=:slug AND id<>:id',['slug'=>$slug,'id'=>$id])->fetch('assoc')) throw new \InvalidArgumentException('Đường dẫn bảng giá đã được sử dụng.');
            $base=['name'=>$name,'slug'=>$slug,'course_type'=>$kind,'description'=>$description,'position'=>(int)($data['position']??0),'status'=>empty($data['status'])?0:1,'updated'=>time()];
            if ($id) $db->update('course_price_lists',$base,['id'=>$id]);
            else { $db->insert('course_price_lists',$base+['created'=>time()]); $id=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0); }
            $old=array_column(self::packages($id,false),null,'id');
            $kept=[];
            foreach ($rows as $r) {
                $pid=$r['id']; unset($r['id']); $r['updated']=time();
                if ($pid) {
                    if (!isset($old[$pid])) throw new \InvalidArgumentException('Gói học không thuộc bảng giá này.');
                    $db->update('course_price_packages',$r,['id'=>$pid,'price_list_id'=>$id]); $kept[]=$pid;
                } else { $db->insert('course_price_packages',$r+['price_list_id'=>$id,'created'=>time()]); $kept[]=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0); }
            }
            foreach ($old as $pid=>$p) if (!in_array((int)$pid,$kept,true)) $db->update('course_price_packages',['status'=>0,'updated'=>time()],['id'=>(int)$pid]);
            $db->update('products',['course_price_list_id'=>null],['course_price_list_id'=>$id]);
            foreach ($courseIds as $cid) $db->update('products',['course_price_list_id'=>$id],['id'=>$cid]);
            \Cake\Cache\Cache::clearAll();
            return $id;
        });
    }
}
