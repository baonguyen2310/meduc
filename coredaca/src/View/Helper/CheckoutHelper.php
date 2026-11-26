<?php
declare(strict_types=1);
namespace App\View\Helper;
use Cake\View\Helper;
use Cake\ORM\TableRegistry;
use App\Lib\BookCheckout;
use App\Service\CoursePricing;
use App\Service\ShopOrders;

class CheckoutHelper extends Helper
{
    public function catalog(): array { return BookCheckout::catalog(); }
    public function prices(array $order): array
    {
        $amount = (float)($order['total'] ?? 0);
        $row = empty($order['id']) ? [] : TableRegistry::get('Orders')->find()->select(['course_price_snapshot'])
            ->where(['id'=>(int)$order['id']])->enableHydration(false)->first();
        $snapshot = json_decode((string)($row['course_price_snapshot'] ?? ''), true) ?: [];
        $original = (float)($snapshot['package']['price'] ?? $order['total_origin'] ?? $amount);
        return ['amount'=>$amount, 'original'=>max($original, $amount), 'package'=>$snapshot['package']??[],
            'discounts'=>$snapshot['vouchers']['discounts']??[], 'gifts'=>$snapshot['purchase_gifts']??[]];
    }
    public function paymentCatalog(array $order): string
    {
        if (empty($order['id'])) return '/khoa-hoc';
        $kind = CoursePricing::db()->execute('SELECT '.\App\Service\OrderPayments::kindSql().' AS kind FROM orders Orders WHERE Orders.id=?', [(int)$order['id']])->fetchColumn(0);
        return CoursePricing::CATALOGS[CoursePricing::normalizeKind((string)$kind)] ?? '/khoa-hoc';
    }
    public function confirmation(): array
    {
        $request = $this->getView()->getRequest();
        $session = $request->getSession();
        $member = $session->read(MEMBER) ?: [];
        $buyer = (int)($member['id'] ?? 0);
        $code = $request->getQuery('cartId');
        if (!$buyer || !is_string($code)) return [];
        $receipt = ShopOrders::byReference($code, $buyer);
        if ($receipt) return $receipt;

        $order = $session->read('MeducBookOrder');
        return is_array($order) && (int)($order['customer_id'] ?? 0) === $buyer
            && ($order['cartId'] ?? '') === $code ? $order : [];
    }
    public function bank(string $purpose = 'course', array $order = []): array
    {
        if (in_array($purpose, ['book', 'document', 'quiz'], true) ||
            ($purpose === 'order' && $this->isBookstoreOrder($order))) {
            return [
                'bank_name' => 'VietinBank',
                'bank_branch' => 'CN NAM HUE - PGD AN VAN DUONG',
                'account_holder' => 'HO KINH DOANH NHA SACH MEDUCBO',
                'account_number' => '109886529080',
                'qr_file' => 'bank-qr-meducbo-vietqr.png',
                'qr_width' => 540, 'qr_height' => 660, 'qr_compact' => true,
                'qr_download' => 'MedUCBO-VietQR.png', 'show_momo' => false
            ];
        }
        $gateways = TableRegistry::get('PaymentsGateway')->getList(LANGUAGE);
        return array_merge($gateways['bank']['config'][0] ?? [], [
            'qr_file' => 'bank-qr.jpg', 'qr_width' => 893, 'qr_height' => 1306,
            'qr_download' => 'MedUC-QR-ngan-hang.jpg', 'show_momo' => true
        ]);
    }

    /** Resolve invoice items on the server; a course invoice keeps the existing account. */
    private function isBookstoreOrder(array $order): bool
    {
        $ids = array_values(array_unique(array_filter(array_map(function ($item) {
            return is_array($item) ? (int)($item['product_id'] ?? 0) : 0;
        }, $order['items'] ?? []))));
        if (!$ids) return false;
        $products = TableRegistry::get('Products')->find()->select(['id', 'course_kind'])
            ->where(['id IN' => $ids])->enableHydration(false)->toArray();
        if (count($products) !== count($ids)) return false;
        $physical = [];
        foreach ($products as $product) {
            $kind = CoursePricing::normalizeKind((string)$product['course_kind']);
            if ($kind === 'quiz') continue;
            if ($kind !== '') return false;
            $physical[] = (int)$product['id'];
        }
        if (!$physical) return true;
        $categories = TableRegistry::get('Categories');
        $categoryIds = \App\Lib\BlouseProducts::physicalCategoryIds();
        $bookIds = TableRegistry::get('CategoriesProduct')->find()
            ->where(['product_id IN' => $physical, 'category_id IN' => $categoryIds])
            ->all()->extract('product_id')->toList();
        return !array_diff($physical, array_map('intval', $bookIds));
    }
}
