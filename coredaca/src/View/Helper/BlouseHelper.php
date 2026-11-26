<?php
declare(strict_types=1);
namespace App\View\Helper;

use App\Lib\BlouseProducts;
use Cake\ORM\TableRegistry;
use Cake\View\Helper;

class BlouseHelper extends Helper
{
    public $helpers = ['Utilities'];

    public function prepare(array $product): array
    {
        $definitions = [];
        foreach (TableRegistry::get('Attributes')->getAll(LANGUAGE) as $attribute) {
            if (($attribute['attribute_type'] ?? '') === PRODUCT_ITEM) $definitions[(int)$attribute['id']] = $attribute;
        }
        $options = TableRegistry::get('AttributesOptions')->getAll(LANGUAGE);
        $fee = BlouseProducts::embroideryFees([(int)($product['id'] ?? 0)])[(int)($product['id'] ?? 0)] ?? 0.0;

        $items = $used = $gallery = [];
        foreach (($product['items'] ?? []) as $item) {
            if ($item instanceof \Cake\Datasource\EntityInterface) $item = $item->toArray();
            if (isset($item['status']) && (int)$item['status'] !== 1) continue;
            $described = BlouseProducts::describe(array_values($item['attributes'] ?? []), $options, $definitions);
            if (!$described) continue;
            $variant = BlouseProducts::variant($item, (string)$product['name'], (string)$product['url'], (string)($product['all_images'][0] ?? ''), $described['label'], $fee);
            $variant['values'] = [];
            foreach ($described['values'] as $attributeId => $value) {
                $variant['values'][(string)$attributeId] = $value['option_id'];
                $used[$attributeId][$value['option_id']] = true;
            }
            $variant['images'] = array_map([$this, 'image'], array_values(array_unique(array_filter((array)($item['images'] ?? []), 'is_string'))));
            foreach ($variant['images'] as $image) $gallery[$image['full']] = $image;
            $items[] = $variant;
        }

        $attributes = [];
        foreach ($definitions as $attributeId => $definition) {
            if (empty($used[$attributeId])) continue;
            $choices = [];
            foreach (array_keys($used[$attributeId]) as $optionId) {
                $option = $options[$optionId] ?? [];
                $choices[] = ['id'=>$optionId, 'name'=>(string)$option['name'], 'swatch'=>$definition['code'] === BlouseProducts::COLOR_CODE ? BlouseProducts::swatch($option) : ''];
            }
            $kind = $definition['code'] === BlouseProducts::SIZE_CODE ? 'size' : ($definition['code'] === BlouseProducts::COLOR_CODE ? 'color' : 'choice');
            $attributes[] = ['id'=>$attributeId, 'code'=>$definition['code'], 'kind'=>$kind, 'label'=>BlouseProducts::attributeLabel($definition), 'options'=>$choices];
        }

        $book = new BookHelper($this->getView());
        $sections = [];
        foreach (['motangan'=>'Giới thiệu', 'thongtinchitiet'=>'Thông tin sản phẩm', 'huongdansudung'=>'Hướng dẫn sử dụng và bảo quản', 'thongsokythuat'=>'Thông số và bảng size'] as $code=>$label) {
            $html = $book->cleanContent((string)($product['attributes'][$code]['value'] ?? ''));
            if (trim(strip_tags($html)) !== '' || preg_match('/<(?:img|video|iframe)\b/i', $html)) $sections[] = ['label'=>$label,'html'=>$html,'code'=>$code];
        }
        if (!$sections && !empty($product['content'])) $sections[] = ['label'=>'Thông tin sản phẩm','html'=>$book->cleanContent((string)$product['content']),'code'=>'content'];
        if (!$gallery) foreach ((array)($product['all_images'] ?? []) as $path) if (is_string($path) && $path !== '') $gallery[CDN_URL . $path] = $this->image($path);

        $gallery = array_values($gallery);
        return [
            'payload'=>['items'=>$items, 'attributes'=>$attributes, 'gallery'=>$gallery, 'embroidery_fee'=>$fee, 'embroidery_max'=>BlouseProducts::EMBROIDERY_MAX_LENGTH],
            'items'=>$items, 'attributes'=>$attributes, 'gallery'=>$gallery, 'sections'=>$sections,
            'embroidery_fee'=>$fee, 'embroidery_max'=>BlouseProducts::EMBROIDERY_MAX_LENGTH,
            'size_guide'=>(bool)array_filter($sections, static function (array $section): bool { return $section['code'] === 'thongsokythuat'; }),
            'has_price'=>(bool)array_filter($items, static function (array $item): bool { return $item['current'] > 0; }),
        ];
    }

    private function image(string $path): array
    {
        $thumb = $this->Utilities->getThumbs($path, 720);
        $small = $this->Utilities->getThumbs($path, 150);
        return [
            'full'=>CDN_URL . $path,
            'large'=>CDN_URL . (is_string($thumb) && $thumb !== '' ? $thumb : $path),
            'small'=>CDN_URL . (is_string($small) && $small !== '' ? $small : $path),
        ];
    }
}
