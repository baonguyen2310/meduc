<?php
declare(strict_types=1);
namespace App\Lib;

use Cake\ORM\TableRegistry;

/** Public book/equipment prices, using the same special-price dates as the catalogue. */
final class BookCheckout
{
    public static function catalog(): array
    {
        $categories = TableRegistry::get('Categories');
        $categoryIds = array_unique(array_merge([79, 80], $categories->getAllChildCategoryId(79), $categories->getAllChildCategoryId(80)));
        $productIds = TableRegistry::get('CategoriesProduct')->find()->where(['category_id IN' => $categoryIds])->all()->extract('product_id')->toList();
        if (!$productIds) return [];
        $table = TableRegistry::get('ProductsItem');
        $rows = $table->queryListProductsItem(['filter' => ['lang' => LANGUAGE, 'status' => 1, 'display_product' => 1]])
            ->where(['Products.id IN' => array_unique($productIds), 'Products.draft' => 0])->all();
        $result = [];
        foreach ($rows as $row) {
            $item = $table->formatProductItemDetail($row, LANGUAGE);
            $price = (float) ($item['price'] ?? 0);
            $current = !empty($item['apply_special']) ? (float) $item['price_special'] : $price;
            if ($current <= 0 || empty($item['url'])) continue;
            $result[$item['id']] = [
                'id' => (int) $item['id'], 'product_id' => (int) $item['product_id'],
                'name' => $item['name_extend'], 'image' => $item['images'][0] ?? '',
                'url' => $item['url'], 'price' => $price, 'price_special' => $current,
                'discount_percent' => $price > $current ? round(100 * ($price - $current) / $price, 2) : 0
            ];
        }
        return $result;
    }

    public static function quote(array $items): array
    {
        if (!$items || count($items) > 100) throw new \InvalidArgumentException('Vui lòng kiểm tra lại giỏ hàng.');
        $catalog = self::catalog();
        $result = [];
        foreach ($items as $item) {
            if (!is_array($item)) throw new \InvalidArgumentException('Dữ liệu sản phẩm không hợp lệ.');
            $id = filter_var($item['id'] ?? null, FILTER_VALIDATE_INT);
            $quantity = filter_var($item['quantity'] ?? null, FILTER_VALIDATE_INT);
            if (!$id || !$quantity || $quantity < 1 || $quantity > 999 || empty($catalog[$id]) || isset($result[$id])) {
                throw new \InvalidArgumentException('Sản phẩm hoặc số lượng không hợp lệ. Vui lòng tải lại giỏ hàng.');
            }
            $product = $catalog[$id];
            $product['quantity'] = $quantity;
            $product['total'] = $product['price_special'] * $quantity;
            $result[$id] = $product;
        }
        return array_values($result);
    }
}
