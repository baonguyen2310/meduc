<?php
declare(strict_types=1);
namespace App\Lib;

/** Blouse sizes are existing CMS SKU attributes, with a separate price and stock per SKU. */
final class BlouseProducts
{
    public const CATEGORY_ID = 997;
    public const SIZE_CODE = 'blouse_size';

    public static function physicalCategoryIds(): array
    {
        $categories = \Cake\ORM\TableRegistry::get('Categories');
        return array_values(array_unique(array_merge(
            $categories->getAllChildCategoryId(79),
            $categories->getAllChildCategoryId(80),
            $categories->getAllChildCategoryId(self::CATEGORY_ID)
        )));
    }

    public static function size(array $rows, array $options, array $definitions = []): string
    {
        foreach ($rows as $row) {
            $attributeId = (int)($row['attribute_id'] ?? 0);
            $code = $row['code'] ?? ($definitions[$attributeId]['code'] ?? '');
            if ($code !== self::SIZE_CODE) continue;
            $option = $options[(int)($row['value'] ?? 0)] ?? [];
            if ((int)($option['attribute_id'] ?? 0) !== $attributeId) return '';
            return trim((string)($option['name'] ?? ''));
        }
        return '';
    }

    public static function variant(array $item, string $name, string $url, string $image, string $size): array
    {
        $price = (float)($item['price'] ?? 0);
        $current = !empty($item['apply_special']) && !empty($item['price_special']) ? (float)$item['price_special'] : $price;
        $maximum = max(0, (int)($item['quantity_available'] ?? 0));
        $id = (int)($item['id'] ?? 0);
        return [
            'id'=>$id, 'label'=>$size, 'price'=>$price, 'current'=>$current,
            'discount'=>$price > $current && $current > 0 ? (int)round(100 * ($price - $current) / $price) : 0,
            'maximum'=>$maximum, 'available'=>$id > 0 && $size !== '' && $current > 0 && $maximum > 0,
            'cart'=>[
                'id'=>$id, 'name'=>$name.' (Size '.$size.')', 'image'=>$item['images'][0] ?? $image,
                'quantity'=>1, 'price'=>$price, 'price_special'=>$current, 'url'=>'/'.ltrim($url, '/')
            ]
        ];
    }

    public static function assertQuantity(array $product, int $quantity): void
    {
        if (isset($product['maximum']) && $quantity > $product['maximum']) {
            throw new \InvalidArgumentException('Size áo đã chọn không đủ số lượng. Vui lòng cập nhật giỏ hàng.');
        }
    }
}
