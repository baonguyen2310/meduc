<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;
use Cake\Core\Configure;
use Cake\ORM\TableRegistry;
use Cake\Filesystem\File;
use Cake\Filesystem\Folder;

class BlockHelper extends Helper
{
    /** Dịch đa ngôn ngữ
     * 
     * $attribute_code (*): mã thuộc tính(string)
     * $lang (*): Mã ngôn ngữ(string)  - ví dụ: 'en'| 'vi'
     *
     * 
     * {$this->Block->getLocale('tieu_de', $data_extend)}
     * 
    */
    public function getLocale($key = null, $data_extend = [])
    {
        if(empty($data_extend['locale'][LANGUAGE][$key])) return $key;
        return $data_extend['locale'][LANGUAGE][$key];
    }

    /** Kiểm tra view của block có tồn tại
     * 
     * $block_type (*): loại block(string)
     * $view (*): view của block(string) ví dụ: view.tpl
     *
     * 
     * $this->Block->checkViewExist('product', 'view.tpl')
     * 
    */
    public function checkViewExist($block_type = null, $view = null)
    {
        $path_view = PATH_TEMPLATE . BLOCK . DS . $block_type . DS . $view;
        $file = new File($path_view, false);
        if(!$file->exists()){
            return false;
        }
        return true;
    }

    /** Lấy danh sách item của một block slider khác, cùng dạng với $data_block của view slider
     *
     * $block_code (*): mã block (string)
     *
     * Dùng khi một trang cần dữ liệu của block không đặt trên trang đó, ví dụ trang khóa học
     * lấy video phản hồi từ block của trang Phản hồi học viên:
     * {$this->Block->getSliderItems('fbvideos')}
    */
    public function getSliderItems($block_code = null)
    {
        if(empty($block_code)) return [];

        $block_info = TableRegistry::get('TemplatesBlock')->getInfoBlock($block_code);
        if(empty($block_info['status']) || empty($block_info['type']) || $block_info['type'] != SLIDER) return [];

        $items = !empty($block_info['config']['item']) ? $block_info['config']['item'] : [];
        $result = [];
        foreach ($items as $item) {
            if(!is_array($item)) continue;
            $result[] = [
                'name' => !empty($item['name_' . LANGUAGE]) ? $item['name_' . LANGUAGE] : null,
                'url' => !empty($item['url_' . LANGUAGE]) ? $item['url_' . LANGUAGE] : null,
                'image' => !empty($item['image']) ? $item['image'] : null,
                'image_source' => !empty($item['image_source']) ? $item['image_source'] : null,
                'class_item' => !empty($item['class_item']) ? $item['class_item'] : null,
                'blank_link' => !empty($item['blank_link']) ? $item['blank_link'] : null,
                'description' => !empty($item['description_' . LANGUAGE]) ? $item['description_' . LANGUAGE] : null,
                'description_short' => !empty($item['description_short_' . LANGUAGE]) ? $item['description_short_' . LANGUAGE] : null,
            ];
        }
        return $result;
    }

}
