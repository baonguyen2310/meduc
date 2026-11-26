<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Database\Query;
use Cake\Utility\Text;

/** Page orders and unlinked Shop records together without changing their payment state. */
final class AdminOrderList
{
    public static function includesArchive(array $filter): bool
    {
        if (!in_array($filter['type'] ?? '', ['', ORDER], true) ||
            !in_array($filter['order_kind'] ?? '', ['', 'shop'], true) ||
            !in_array($filter['source'] ?? '', ['', WEBSITE], true)) {
            return false;
        }

        // Archived records have no reliable invoice ID, payment, staff or delivery status.
        foreach (['order_id', 'customer_id', 'affiliate_customer_id', 'staff_id', 'created_by', 'branch_id',
            'city_id', 'district_id', 'ward_id', 'status', 'not_status', 'group_status', 'pay_status', 'note'] as $key) {
            if (isset($filter[$key]) && $filter[$key] !== '') return false;
        }
        return true;
    }

    public static function page(Query $orders, array $filter, array $sort, int $page, int $limit): array
    {
        $db = $orders->getConnection();
        $current = clone $orders;
        $current->select([
            'record_origin' => $current->newExpr("'order'"),
            'record_id' => 'Orders.id',
            'created' => 'Orders.created',
            'code' => 'Orders.code',
            'total' => 'Orders.total',
            'count_items' => 'Orders.count_items',
            'status' => 'Orders.status',
            'updated' => 'Orders.updated',
            'created_by' => 'Orders.created_by',
        ], true)->enableAutoFields(false)->order([], true);

        $archive = self::archiveIndex($db->newQuery(), $filter);
        $merged = $db->newQuery()->from(['Merged' => $current->unionAll($archive)]);
        $counter = clone $merged;
        $total = (int)$counter->select(['total' => $counter->func()->count('*')])->execute()->fetchColumn(0);
        $pages = max(1, (int)ceil($total / $limit));
        $page = $page > $pages ? 1 : $page;

        $field = $sort['field'] ?? 'created';
        $direction = ($sort['sort'] ?? '') === ASC ? ASC : DESC;
        $field = in_array($field, ['code', 'count_items', 'total', 'status', 'created', 'updated', 'created_by'], true)
            ? $field : 'created';
        $references = $merged->select(['Merged.record_origin', 'Merged.record_id'])
            ->order(['Merged.' . $field => $direction])
            ->order(['Merged.created' => $field === 'created' ? $direction : DESC, 'Merged.record_origin' => DESC, 'Merged.record_id' => DESC])
            ->limit($limit)->offset(($page - 1) * $limit)->execute()->fetchAll('assoc');

        return [
            'references' => $references,
            'paging' => ['sort'=>$field, 'direction'=>$direction, 'page'=>$page, 'pageCount'=>$pages,
                'perPage'=>$limit, 'current'=>count($references), 'count'=>$total],
        ];
    }

    private static function archiveIndex(Query $query, array $filter): Query
    {
        $payload = "IF(JSON_VALID(Archive.value), Archive.value, '{}')";
        $json = static function (string $key) use ($payload): string {
            return "NULLIF(JSON_UNQUOTE(JSON_EXTRACT($payload, '$." . $key . "')), 'null')";
        };
        $code = $json('cartId');
        $total = "CAST(" . $json('totalPrice') . " AS DECIMAL(15,2))";
        $query->select([
            'record_origin' => $query->newExpr("'archive'"),
            'record_id' => 'Archive.id',
            'created' => 'Archive.created',
            'code' => $query->newExpr($code),
            'total' => $query->newExpr($total),
            'count_items' => $query->newExpr("CAST(" . $json('totalQuantity') . " AS UNSIGNED)"),
            'status' => $query->newExpr($json('orderStatus')),
            'updated' => 'Archive.created',
            'created_by' => $query->newExpr('NULL'),
        ])->from(['Archive'=>'contacts'])
            ->innerJoin(['ShopForm'=>'contacts_form'], 'ShopForm.id=Archive.form_id')
            ->leftJoin(['Linked'=>'commerce_purchases'], "Linked.kind='shop' AND Linked.public_code=LEFT(SHA2(CONCAT('" .
                ShopOrders::ARCHIVE_CODE_PREFIX . "',Archive.id),256),32)")
            ->where(['Archive.deleted'=>0, 'ShopForm.code'=>Vouchers::SHOP_FORM, 'Linked.order_id IS'=>null]);

        $keyword = trim((string)($filter['keyword'] ?? ''));
        if ($keyword !== '') {
            $matches = $query->newExpr()->setConjunction('OR')
                ->like('Archive.search_unicode', '%' . Text::slug(strtolower($keyword), ' ') . '%', 'string');
            foreach (['cartId','full_name','phone','email'] as $key) {
                $matches->like($query->newExpr($json($key)), '%' . $keyword . '%', 'string');
            }
            $query->where($matches);
        }
        if (!empty($filter['order_code'])) {
            $query->where($query->newExpr()->eq($query->newExpr($code), $filter['order_code'], 'string'));
        }
        foreach (['create_from'=>['>=','00:00:00'], 'create_to'=>['<=','23:59:59']] as $key => [$operator,$time]) {
            if (!empty($filter[$key])) {
                $day = strtotime(str_replace('/', '-', $filter[$key]));
                $query->where(['Archive.created ' . $operator => strtotime(date('Y-m-d', (int)$day) . ' ' . $time)]);
            }
        }
        foreach (['price_from'=>'gte', 'price_to'=>'lte'] as $key => $method) {
            if (!empty($filter[$key])) {
                $query->where($query->newExpr()->$method($query->newExpr($total), str_replace(',', '', $filter[$key]), 'decimal'));
            }
        }
        return $query;
    }

    public static function archives(array $ids): array
    {
        if (!$ids) return [];
        $db = CommercePurchases::db();
        $rows = $db->newQuery()->select(['id','created','value'])->from('contacts')
            ->where(['id IN'=>$ids,'deleted'=>0], ['id'=>'integer[]'])->execute()->fetchAll('assoc');
        $result = [];
        foreach ($rows as $row) {
            $id = (int)$row['id'];
            $data = json_decode((string)$row['value'], true);
            $data = is_array($data) ? $data : [];
            $text = static function (string $key) use ($data): string {
                return is_string($data[$key] ?? null) ? $data[$key] : '';
            };
            $number = static function (string $key) use ($data): float {
                return is_numeric($data[$key] ?? null) ? (float)$data[$key] : 0;
            };
            $result[$id] = [
                'id' => -$id, 'archive_id' => $id, 'code' => $text('cartId'), 'created' => (int)$row['created'],
                'count_items' => (int)$number('totalQuantity'), 'total' => $number('totalPrice'),
                'contact' => ['full_name'=>$text('full_name'), 'phone'=>$text('phone'), 'email'=>$text('email')],
                'affiliateCode'=>$text('affiliateCode'), 'affiliateAmount'=>$number('affiliateAmount'),
                'affiliatePercent'=>$number('affiliatePercent'), 'orderStatus'=>$text('orderStatus'),
                'payment_summary'=>[
                    'kind'=>'shop', 'paid'=>false,
                    'status_label'=>$text('orderStatus') === 'cancel' ? 'Đã huỷ' : 'Cần đối soát',
                ],
            ];
        }
        return $result;
    }
}
