<?php
declare(strict_types=1);
namespace App\Lib;

use Cake\ORM\TableRegistry;

/** Public physical-product prices, using the same special-price dates as the catalogue. */
final class BookCheckout
{
    public static function categoryIds(): array
    {
        return BlouseProducts::physicalCategoryIds();
    }

    public static function catalog(): array
    {
        $categories = TableRegistry::get('Categories');
        $categoryIds = self::categoryIds();
        $blouseIds = TableRegistry::get('CategoriesProduct')->find()->where(['category_id IN' => $categories->getAllChildCategoryId(BlouseProducts::CATEGORY_ID)])->all()->extract('product_id')->toList();
        $blouseIds = array_fill_keys(array_map('intval', $blouseIds), true);
        $sizeDefinitions = $sizeOptions = $embroideryFees = [];
        if ($blouseIds) {
            foreach (TableRegistry::get('Attributes')->getAll(LANGUAGE) as $attribute) $sizeDefinitions[(int)$attribute['id']] = $attribute;
            $sizeOptions = TableRegistry::get('AttributesOptions')->getAll(LANGUAGE);
            $embroideryFees = BlouseProducts::embroideryFees(array_keys($blouseIds));
        }
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
            if (isset($blouseIds[(int)$item['product_id']])) {
                $described = BlouseProducts::describe((array)($row['ProductsItemAttribute'] ?? []), $sizeOptions, $sizeDefinitions);
                if (!$described) continue;
                $variant = BlouseProducts::variant($item, (string)$item['name'], (string)$item['url'], '', $described['label'], $embroideryFees[(int)$item['product_id']] ?? 0.0);
                $result[$item['id']] = array_merge($variant['cart'], ['product_id'=>(int)$item['product_id'], 'maximum'=>$variant['maximum'], 'discount_percent'=>$variant['discount']]);
                continue;
            }
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
        $result = $ordered = [];
        foreach ($items as $item) {
            if (!is_array($item)) throw new \InvalidArgumentException('Dữ liệu sản phẩm không hợp lệ.');
            $id = filter_var($item['id'] ?? null, FILTER_VALIDATE_INT);
            $quantity = filter_var($item['quantity'] ?? null, FILTER_VALIDATE_INT);
            // One SKU may appear on several lines, one per name to embroider.
            $embroidery = BlouseProducts::embroideryText($item['embroidery'] ?? '');
            $line = $id . "\n" . $embroidery;
            if (!$id || !$quantity || $quantity < 1 || $quantity > 999 || empty($catalog[$id]) || isset($result[$line])) {
                throw new \InvalidArgumentException('Sản phẩm hoặc số lượng không hợp lệ. Vui lòng tải lại giỏ hàng.');
            }
            $product = $catalog[$id];
            $fee = (float)($product['embroidery_fee'] ?? 0);
            if ($embroidery !== '' && $fee <= 0) {
                throw new \InvalidArgumentException('Mẫu áo đã chọn chưa nhận thêu tên. Vui lòng xoá tên thêu trong giỏ hàng.');
            }
            $ordered[$id] = ($ordered[$id] ?? 0) + $quantity;
            BlouseProducts::assertQuantity($product, $ordered[$id]);
            $product['quantity'] = $quantity;
            if ($embroidery !== '') {
                $product['name'] .= ' · Thêu tên “' . $embroidery . '”';
                $product['embroidery'] = $embroidery;
            } else {
                $fee = 0.0;
            }
            $product['embroidery_fee'] = $fee;
            $product['unit_price'] = $product['price_special'] + $fee;
            $product['total'] = $product['unit_price'] * $quantity;
            $result[$line] = $product;
        }
        return array_values($result);
    }
}
