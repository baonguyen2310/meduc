<?php
declare(strict_types=1);
namespace App\Lib;

/**
 * Áo blouse uses the CMS SKU attributes: each SKU is one combination of the
 * item attributes (Kiểu dáng · Màu · Size) with its own price, stock and images.
 * A product may also offer name embroidery for a fixed fee per shirt.
 */
final class BlouseProducts
{
    public const CATEGORY_ID = 997;
    public const SIZE_CODE = 'blouse_size';
    public const COLOR_CODE = 'blouse_color';
    public const EMBROIDERY_FEE_CODE = 'phi_theu_ten';
    public const EMBROIDERY_MAX_LENGTH = 30;

    private const LABELS = ['blouse_fit'=>'Kiểu dáng', self::COLOR_CODE=>'Màu', self::SIZE_CODE=>'Size'];
    private const COLORS = [
        'trang'=>'#ffffff', 'xanh reu'=>'#5f6b58', 'xam'=>'#6c7178', 'xam dam'=>'#4a4f57', 'den'=>'#25262a',
        'xanh navy'=>'#1f2b4a', 'tim than'=>'#2f2b48', 'xanh duong'=>'#2f6db5', 'xanh ngoc'=>'#2a9d8f',
        'xanh la'=>'#3f8f5a', 'hong'=>'#e7a3b3', 'do do'=>'#7a2433', 'be'=>'#e6dac4',
    ];

    public static function physicalCategoryIds(): array
    {
        $categories = \Cake\ORM\TableRegistry::get('Categories');
        return array_values(array_unique(array_merge(
            $categories->getAllChildCategoryId(79),
            $categories->getAllChildCategoryId(80),
            $categories->getAllChildCategoryId(self::CATEGORY_ID)
        )));
    }

    /**
     * Describe one SKU from its attribute rows ([attribute_id, value]).
     * Returns the chosen option of every item attribute, in attribute order, or [] when the
     * SKU has no size or points at an option of another attribute.
     */
    public static function describe(array $rows, array $options, array $definitions): array
    {
        $values = [];
        foreach ($rows as $row) {
            $attributeId = (int)($row['attribute_id'] ?? 0);
            $definition = $definitions[$attributeId] ?? [];
            if (($definition['attribute_type'] ?? PRODUCT_ITEM) !== PRODUCT_ITEM || empty($definition['code'])) continue;
            $option = $options[(int)($row['value'] ?? 0)] ?? [];
            $name = trim((string)($option['name'] ?? ''));
            if ((int)($option['attribute_id'] ?? 0) !== $attributeId || $name === '') return [];
            $values[$attributeId] = ['attribute_id'=>$attributeId, 'option_id'=>(int)$option['id'], 'code'=>$definition['code'], 'name'=>$name];
        }
        $order = array_flip(array_keys($definitions));
        uksort($values, static function ($a, $b) use ($order): int { return ($order[$a] ?? PHP_INT_MAX) <=> ($order[$b] ?? PHP_INT_MAX); });
        $size = '';
        foreach ($values as $value) if ($value['code'] === self::SIZE_CODE) $size = $value['name'];
        if ($size === '') return [];
        $parts = array_map(static function (array $value): string {
            return $value['code'] === self::SIZE_CODE ? 'Size ' . $value['name'] : $value['name'];
        }, array_values($values));
        return ['size'=>$size, 'label'=>implode(' · ', $parts), 'values'=>$values];
    }

    /** Size of one SKU; kept for callers that only need the size. */
    public static function size(array $rows, array $options, array $definitions = []): string
    {
        return self::describe($rows, $options, $definitions)['size'] ?? '';
    }

    public static function attributeLabel(array $definition): string
    {
        return self::LABELS[$definition['code'] ?? ''] ?? trim((string)($definition['name'] ?? ''));
    }

    /** Swatch colour: a 6-digit hex at the end of the option code (mau_5f6b58), else a known colour name. */
    public static function swatch(array $option): string
    {
        if (preg_match('/([0-9a-f]{6})$/i', (string)($option['code'] ?? ''), $match)) return '#' . strtolower($match[1]);
        $name = mb_strtolower(trim((string)($option['name'] ?? '')));
        $plain = preg_replace('/\p{Mn}+/u', '', self::normalize(strtr($name, ['đ'=>'d']), false));
        $plain = preg_replace('/\s+/u', ' ', (string)$plain);
        return self::COLORS[$plain] ?? '';
    }

    public static function variant(array $item, string $name, string $url, string $image, string $label, float $embroideryFee = 0): array
    {
        $price = (float)($item['price'] ?? 0);
        $current = !empty($item['apply_special']) && !empty($item['price_special']) ? (float)$item['price_special'] : $price;
        $maximum = max(0, (int)($item['quantity_available'] ?? 0));
        $id = (int)($item['id'] ?? 0);
        $label = $label !== '' && strpos($label, ' · ') === false && strpos($label, 'Size ') !== 0 ? 'Size ' . $label : $label;
        return [
            'id'=>$id, 'label'=>$label, 'price'=>$price, 'current'=>$current,
            'discount'=>$price > $current && $current > 0 ? (int)round(100 * ($price - $current) / $price) : 0,
            'maximum'=>$maximum, 'available'=>$id > 0 && $label !== '' && $current > 0 && $maximum > 0,
            'cart'=>[
                'id'=>$id, 'name'=>$name.' ('.$label.')', 'image'=>$item['images'][0] ?? $image,
                'quantity'=>1, 'price'=>$price, 'price_special'=>$current, 'url'=>'/'.ltrim($url, '/'),
                'embroidery_fee'=>$embroideryFee > 0 ? $embroideryFee : 0,
            ]
        ];
    }

    /** Embroidery fee per shirt for each blouse product; 0 or missing means the product does not offer it. */
    public static function embroideryFees(array $productIds): array
    {
        $productIds = array_values(array_filter(array_map('intval', $productIds)));
        if (!$productIds) return [];
        $attributeId = 0;
        foreach (\Cake\ORM\TableRegistry::get('Attributes')->getAll(LANGUAGE) as $attribute) {
            if (($attribute['code'] ?? '') === self::EMBROIDERY_FEE_CODE && ($attribute['attribute_type'] ?? '') === PRODUCT) $attributeId = (int)$attribute['id'];
        }
        if (!$attributeId) return [];
        $rows = \Cake\ORM\TableRegistry::get('ProductsAttribute')->find()
            ->where(['product_id IN'=>$productIds, 'attribute_id'=>$attributeId])->select(['product_id', 'value'])->enableHydration(false)->toList();
        $fees = [];
        foreach ($rows as $row) $fees[(int)$row['product_id']] = self::fee($row['value'] ?? '');
        return array_filter($fees);
    }

    public static function fee($value): float
    {
        // Admin saves numeric attributes as plain numbers ("35000"); tolerate "35,000" too.
        $text = str_replace([',', ' '], '', trim((string)$value));
        $fee = is_numeric($text) ? (int)round((float)$text) : 0;
        return $fee > 0 && $fee <= 10000000 ? (float)$fee : 0.0;
    }

    /** Normalise the text to embroider. Letters (with Vietnamese marks), digits, spaces and . , ' - only. */
    public static function embroideryText($value): string
    {
        if ($value === null || $value === '') return '';
        if (!is_string($value)) throw new \InvalidArgumentException('Tên thêu không hợp lệ.');
        if (!mb_check_encoding($value, 'UTF-8')) throw new \InvalidArgumentException('Tên thêu không hợp lệ.');
        $text = self::normalize(trim(preg_replace('/\s+/u', ' ', $value) ?? ''), true);
        if ($text === '') return '';
        if (mb_strlen($text) > self::EMBROIDERY_MAX_LENGTH) {
            throw new \InvalidArgumentException('Tên thêu tối đa ' . self::EMBROIDERY_MAX_LENGTH . ' ký tự.');
        }
        if (!preg_match("/^[\\p{L}\\p{M}\\p{N} .,'\\-]+$/u", $text)) {
            throw new \InvalidArgumentException('Tên thêu chỉ gồm chữ, số, dấu cách và các dấu . , \' -');
        }
        return $text;
    }

    private static function normalize(string $text, bool $composed): string
    {
        if (!class_exists('Normalizer')) return $text;
        $result = \Normalizer::normalize($text, $composed ? \Normalizer::FORM_C : \Normalizer::FORM_D);
        return is_string($result) ? $result : $text;
    }

    public static function assertQuantity(array $product, int $quantity): void
    {
        if (isset($product['maximum']) && $quantity > $product['maximum']) {
            throw new \InvalidArgumentException('Mẫu áo đã chọn không đủ số lượng. Vui lòng cập nhật giỏ hàng.');
        }
    }
}
