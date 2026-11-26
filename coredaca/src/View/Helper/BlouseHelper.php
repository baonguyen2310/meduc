<?php
declare(strict_types=1);
namespace App\View\Helper;

use App\Lib\BlouseProducts;
use Cake\View\Helper;

class BlouseHelper extends Helper
{
    public function prepare(array $product): array
    {
        $definitions = $product['attributes_item_apply'] ?? [];
        $options = [];
        foreach ($definitions as $id=>$definition) foreach (($definition['options'] ?? []) as $optionId=>$option) {
            $option['attribute_id'] = (int)$id;
            $options[(int)$optionId] = $option;
        }
        $items = [];
        foreach (($product['items'] ?? []) as $item) {
            if ($item instanceof \Cake\Datasource\EntityInterface) $item = $item->toArray();
            if (isset($item['status']) && (int)$item['status'] !== 1) continue;
            $size = BlouseProducts::size($item['attributes'] ?? [], $options, $definitions);
            if ($size === '') continue;
            $items[] = BlouseProducts::variant($item, (string)$product['name'], (string)$product['url'], (string)($product['all_images'][0] ?? ''), $size);
        }
        $book = new BookHelper($this->getView());
        $sections = [];
        foreach (['motangan'=>'Giới thiệu', 'thongtinchitiet'=>'Thông tin sản phẩm', 'huongdansudung'=>'Hướng dẫn sử dụng và bảo quản', 'thongsokythuat'=>'Thông số và bảng size'] as $code=>$label) {
            $html = $book->cleanContent((string)($product['attributes'][$code]['value'] ?? ''));
            if (trim(strip_tags($html)) !== '' || preg_match('/<(?:img|video|iframe)\b/i', $html)) $sections[] = ['label'=>$label,'html'=>$html];
        }
        if (!$sections && !empty($product['content'])) $sections[] = ['label'=>'Thông tin sản phẩm','html'=>$book->cleanContent((string)$product['content'])];
        return ['items'=>$items, 'sections'=>$sections, 'has_price'=>(bool)array_filter($items,function($item){return $item['current']>0;})];
    }
}
