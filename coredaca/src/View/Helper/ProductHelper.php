<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;
use Cake\ORM\TableRegistry;

class ProductHelper extends Helper
{
    /** Group the already-filtered public products by their actual year-category memberships. */
    public function prepareCourseCatalog($courses = [], $year_ids = [], $selected_id = null, $lang = null)
    {
        $lang = $lang ?: LANGUAGE;
        $categories = TableRegistry::get('Categories')->getAll(PRODUCT, $lang);
        $groups = [];
        foreach ((array) $year_ids as $id) {
            $id = (int) $id;
            if (empty($categories[$id]['status'])) continue;
            $groups[$id] = [
                'id' => $id,
                'name' => $categories[$id]['name'],
                'url' => $categories[$id]['url'],
                'courses' => [],
            ];
        }
        $nav_groups = $groups;
        $selected_id = (int) $selected_id;
        $selected_year = isset($groups[$selected_id]) ? $selected_id : null;
        $unique = [];
        $other = [];
        foreach ((array) $courses as $course) {
            if (empty($course['id']) || isset($unique[$course['id']])) continue;
            $unique[$course['id']] = true;
            $attrs = $course['attributes'] ?? [];
            $lessons = json_decode($attrs['danhsachtiethoc']['value'] ?? '', true);
            $chapters = $lesson_count = 0;
            foreach (is_array($lessons) ? $lessons : [] as $lesson) {
                if (!is_array($lesson) || empty($lesson['name_' . $lang])) continue;
                if (($lesson['chapter_' . $lang] ?? '') === 'y') $chapters++;
                else $lesson_count++;
            }
            $summary = $attrs['motangan']['value'] ?? ($course['description'] ?? '');
            $summary = html_entity_decode(strip_tags((string) $summary), ENT_QUOTES | ENT_HTML5, 'UTF-8');
            $summary = trim(preg_replace('/\s+/u', ' ', str_replace("\xc2\xa0", ' ', $summary)) ?? '');
            $course['catalog_meta'] = [
                'chapters' => $chapters,
                'lessons' => $lesson_count,
                'summary' => mb_strlen($summary) > 190 ? mb_substr($summary, 0, 187) . '…' : $summary,
            ];
            $matched = false;
            foreach ($groups as $id => &$group) {
                if (!isset($course['categories'][$id])) continue;
                $matched = true;
                if ($selected_year === null || $selected_year === $id) $group['courses'][] = $course;
            }
            unset($group);
            if (!$matched) $other[] = $course;
        }
        if ($other) $groups['other'] = ['id' => 'other', 'name' => 'Khóa học khác', 'url' => null, 'courses' => $other];
        return [
            'groups' => array_values(array_filter($groups, function ($group) { return !empty($group['courses']); })),
            'nav_groups' => array_values($nav_groups),
            'total' => count($unique),
            'selected_id' => $selected_id,
            'category_name' => $categories[$selected_id]['name'] ?? 'Khóa học MedUC',
        ];
    }

    /** Lấy danh sách sản phẩm
     * 
     * $params['get_user']: lấy thông tin của nhân viên - ví dụ: 'true'| 'false'
     * $params['get_item']: lấy thông tin phiên bản sản phẩm - ví dụ: 'true'| 'false'
     * $params['get_categories']: lấy thông tin của danh mục - ví dụ: 'true'| 'false'
     * $params['get_attributes']: lấy thông tin của thuộc tính sản phẩm - ví dụ: 'true'| 'false'
     * $params['get_item_attributes']: lấy thông tin của thuộc tính phiên bản sản phẩm - ví dụ: 'true'| 'false'
     * $params['get_tags']: lấy thông tin của tags - ví dụ: 'true'| 'false'
     * 
     * 
     * $params[{FIELD}]: Lấy các trường thông tin ví dụ: FULL_INFO | LIST_INFO | SIMPLE_INFO mặc định là SIMPLE_INFO
     * 
     * 
     * $params[{FILTER}]: lọc theo điều kiện truyền vào
     * 
     * 
     * $params[{FILTER}][{KEYWORD}]: lọc theo từ khóa
     * $params[{FILTER}]['draft']: lọc theo các sản phẩm nháp
     * $params[{FILTER}]['ids']: lọc theo danh sách ID sản phẩm - ví dụ: [5, 6, 9, 10] - chú ý truyền dạng mảng "[]"
     * $params[{FILTER}]['not_ids']: lọc theo danh sách loại bỏ ID sản phẩm - ví dụ: [5, 6, 9, 10] - chú ý truyền dạng mảng "[]"
     * $params[{FILTER}]['id_categories']: lọc theo danh sách ID danh mục sản phẩm - ví dụ: [5, 6, 9, 10] - chú ý truyền dạng mảng "[]"
     * $params[{FILTER}]['id_brands']: lọc theo danh sách ID thương hiệu - ví dụ: [5, 6, 9, 10] - chú ý truyền dạng mảng "[]"
     * $params[{FILTER}]['featured']: lọc theo sản phẩm nổi bật - ví dụ: 0 | 1
     * $params[{FILTER}]['discount']: lọc theo sản phẩm giảm giá - ví dụ: 0 | 1
     * $params[{FILTER}]['stocking']: lọc theo sản phẩm còn hàng - ví dụ: 0 | 1
     * $params[{FILTER}]['tag_id']: lọc theo ID của tag product (int)
     * $params[{FILTER}]['price_from']: lọc theo giá tiền "từ"" (int)
     * $params[{FILTER}]['price_to']: lọc theo giá tiền "đến" (int)
     * $params[{FILTER}]['created_by']: lọc theo nhân viên tạo (int)
     * $params[{FILTER}]['create_from']: lọc theo thời gian tạo "từ" (int)
     * $params[{FILTER}]['create_to']: lọc theo thời gian tạo "đến" (int)
     * 
     * 
     * $params[{SORT}]: sắp xếp dữ liệu
     * 
     * 
     * $params[{SORT}][{FIELD}]: sắp xếp dữ liệu theo field - ví dụ: id | product_id | name | status | price | position | created | updated | featured | created_by | view -  mặc định id
     * $params[{SORT}][{SORT}]: sắp xếp tăng dần hoặc giảm dần - ví dụ DESC | ASC - mặc định DESC
     * 
     * $lang (*): Mã ngôn ngữ(string)  - ví dụ: 'en'| 'vi'
     * 
     * {assign var = data value = $this->Product->getProducts([
     *      'get_categories' => true,
     *      {FIELD} => FULL_INFO,
     *      {FILTER} => [
                'id_categories' => PAGE_CATEGORIES_ID
     *      ],
     *      {SORT} => [
     *          {FIELD} => 'name',
     *          {SORT} => ASC
     *      ]
     * ], {LANGUAGE})}
     * 
     * 
    */
    public function getProducts($params = [], $lang = null) 
    {
        $result = [];

        $languages = TableRegistry::get('Languages')->getList();
        if(empty($lang) || empty($languages[$lang])) $lang = LANGUAGE;
        $params[FILTER][LANG] = $lang;

        if(!isset($params[FILTER][STATUS])) $params[FILTER][STATUS] = 1;
        if(!isset($params[FILTER][STATUS_ITEM])) $params[FILTER][STATUS_ITEM] = 1;
        
        $limit = !empty($params['limit']) ? intval($params['limit']) : 10;
        $products = TableRegistry::get('Products')->queryListProducts($params)->limit($limit)->toList();

        if(!empty($products)){
            foreach($products as $k => $product){
                $result[$k] = TableRegistry::get('Products')->formatDataProductDetail($product, $lang);
            }
        }
        
        return $result;
    }


    /** Lấy danh sách đại diện của phiên bản
     * 
     * $items (*): danh sách ảnh phiên bản sản phẩm
     * 
     * 
     * {assign var = data value = $this->Product->getImageItem($items)}
     * 
    */
    public function getImageItem($items = []) {
        
        $images = [];
        if (empty($items)) {
            return $images;
        }

        foreach ($items as $key => $item) {
            array_push($images, $item['images'][0]);
        }

        return array_unique($images);
    }


    /** Lấy chi tiết sản phẩm thông qua product_id
     * 
     * $product_id (*): ID sản phẩm(int)
     * $lang (*): Mã ngôn ngữ(string)  - ví dụ: 'en'| 'vi'
     * $params['get_user']: lấy thông tin của nhân viên - ví dụ: 'true'| 'false'
     * $params['get_categories']: lấy thông tin của danh mục - ví dụ: 'true'| 'false'
     * $params['get_tags']: lấy thông tin của tag - ví dụ: 'true'| 'false'
     * $params['get_attributes']: lấy thông tin của thuộc tính sản phẩm - ví dụ: 'true'| 'false'
     * $params['get_item_attributes']: lấy thông tin của thuộc tính phiên bản sản phẩm - ví dụ: 'true'| 'false'
     * 
     * {assign var = data value = $this->Product->getDetailProduct(1995, {LANGUAGE}, [
     *  'get_user' => true,
     *  'get_categories' => true
     * ])}
     * 
    */
    public function getDetailProduct($product_id = null, $lang = null, $params = [])
    {
        if(empty($product_id)) return [];

        $lang = !empty($lang) ? $lang : LANGUAGE;
        $params['status'] = 1;

        $product = TableRegistry::get('Products')->getDetailProduct($product_id, $lang, $params);
        $result = TableRegistry::get('Products')->formatDataProductDetail($product, $lang);
        
        return $result;
    }


    /** Lấy chi tiết phiên bản sản phẩm thông qua product_item_id
     * 
     * $product_item_id (*): ID phiên bản sản phẩm (int)
     * $lang (*): Mã ngôn ngữ(string)  - ví dụ: 'en'| 'vi'
     * $params['get_attribute']: lấy thông tin của thuộc tính phiên bản sản phẩm - ví dụ: 'true'| 'false'
     * 
     * {assign var = data value = $this->Product->getDetailProductItem(1995, {LANGUAGE}, [
     *  'get_attribute' => true
     * ])}
     * 
    */
    public function getDetailProductItem($product_item_id = null, $lang = null, $params = [])
    {
        if(empty($product_item_id)) return [];
        $lang = !empty($lang) ? $lang : LANGUAGE;

        $result = TableRegistry::get('ProductsItem')->getDetailProductItem($product_item_id, $lang, $params);
        return $result;
    }

    public function getQuizs($params = [], $lang = null) 
    {
        $quizIds = [];
        if (array_key_exists('lesson_list', $params)) {
            $trialOnly = !empty($params['trial_only']);
            foreach ((array)$params['lesson_list'] as $lesson) {
                if (!is_array($lesson) || ($lesson['chapter_vi'] ?? null) === 'y') {
                    continue;
                }
                if ($trialOnly && ($lesson['trial_vi'] ?? null) !== 'y') {
                    continue;
                }
                $quizId = $lesson['quiz_id_vi'] ?? null;
                if (is_scalar($quizId) && ctype_digit((string)$quizId) && (int)$quizId > 0) {
                    $quizIds[] = (int)$quizId;
                }
            }
            $quizIds = array_values(array_unique($quizIds));
            if (!$quizIds) {
                return [];
            }
        }

        $query = TableRegistry::get('Quizs')
        ->find()
        ->contain([
            'QuizsAttribute',
            'QuizsContent'
        ])
        ->where([
            'Quizs.deleted' => 0
        ]);

        if (array_key_exists('lesson_list', $params)) {
            $query->where(['Quizs.id IN' => $quizIds]);
        }

        return $query->toList();
    }
}
