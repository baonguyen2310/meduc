<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;
use Cake\ORM\TableRegistry;
use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;

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
        // lesson_list: chỉ các đề của các buổi học đó; trial_only: chỉ các đề làm thử miễn phí (App\Lib\LessonQuizzes)
        $quizIds = [];
        if (array_key_exists('lesson_list', $params)) {
            $quizIds = LessonQuizzes::ids($params['lesson_list'], !empty($params['trial_only']));
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
            // đề chỉ dành cho nội bộ (quiz_exam_metadata.staff_only) không mở cho học viên
            $query->where(['Quizs.id NOT IN (SELECT quiz_id FROM quiz_exam_metadata WHERE staff_only = 1)']);
        }

        return $query->toList();
    }

    /** Bài tập của một buổi học: [['id' => id đề, 'free' => làm thử miễn phí], ...] theo thứ tự admin xếp
     *
     * $lesson (*): một buổi trong "Danh sách tiết học" của khóa học (xem App\Lib\LessonQuizzes)
     *
     * {$quizzes = $this->Product->getLessonQuizzes($item)}
    */
    public function getLessonQuizzes($lesson = [])
    {
        return LessonQuizzes::of($lesson);
    }

    /** Bài tập của trang khóa học (block/product_detail/view_classroom.tpl, assets/meduc-v2/classroom-quiz.js)
     *
     * $params['lesson_list'] (*): danh sách tiết học của khóa học
     * $params['licensed']: người xem là học viên của khóa học (làm được mọi đề), nếu không chỉ làm được đề miễn phí
     *
     * Câu hỏi theo App\Lib\QuizQuestions (bỏ định dạng Word dán vào, để trang nhẹ hơn nhiều lần). Kết quả:
     * - 'info' => [id => ['id', 'name', 'count', 'minutes']]: mọi đề có câu hỏi, để hiện cả đề còn khóa;
     * - 'play' => [id => ['id', 'name', 'minutes', 'questions' => [['code', 'question', 'note', 'options' => [[value, text]],
     *   'answer', 'explain']]]]: chỉ các đề người xem được làm (đáp án của đề còn khóa không ra trang).
     *
     * {$course_quizzes = $this->Product->getCourseQuizData(['lesson_list' => $raw_lessons, 'licensed' => $licensed])}
    */
    public function getCourseQuizData($params = [], $lang = null)
    {
        $lang = $lang ?: LANGUAGE;
        $lessons = !empty($params['lesson_list']) ? $params['lesson_list'] : [];
        $playable = array_flip(LessonQuizzes::ids($lessons, empty($params['licensed'])));

        $result = ['info' => [], 'play' => []];
        foreach ($this->getQuizs(['lesson_list' => $lessons], $lang) as $quiz) {
            $questions = [];
            $minutes = 0;
            foreach ((array) ($quiz['QuizsAttribute'] ?? []) as $attribute) {
                if ((int) $attribute['attribute_id'] === QuizQuestions::QUESTIONS_ATTRIBUTE) {
                    $questions = QuizQuestions::fromValue((string) $attribute['value'], $lang);
                } elseif ((int) $attribute['attribute_id'] === QuizQuestions::MINUTES_ATTRIBUTE) {
                    $minutes = (int) $attribute['value'];
                }
            }
            if (!$questions) continue;

            $id = (int) $quiz['id'];
            $name = (string) ($quiz['QuizsContent']['name'] ?? '');
            $result['info'][$id] = ['id' => $id, 'name' => $name, 'count' => count($questions), 'minutes' => $minutes];
            if (isset($playable[$id])) {
                $result['play'][$id] = ['id' => $id, 'name' => $name, 'minutes' => $minutes, 'questions' => $questions];
            }
        }
        return $result;
    }
}
