<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;
use Cake\ORM\TableRegistry;
use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;
use Cake\Datasource\ConnectionManager;

class ProductHelper extends Helper
{
    public function courseKind($id) { return \App\Service\CourseTypes::kind((int)$id); }

    // Khóa học > Khóa luyện thi (scripts/production_exam_prep_category.php): listed on its own page, /trac-nghiem.
    const EXAM_PREP_CATEGORY_ID = 125;

    /** Khóa học có phải khóa luyện thi (thuộc danh mục 125) không
     *
     * {$this->Product->isExamPrepCourse(PAGE_RECORD_ID)}
    */
    public function isExamPrepCourse($product_id = null)
    {
        if (empty($product_id)) return false;
        return \App\Service\CourseTypes::kind((int)$product_id) === 'quiz';
    }

    /** Group public products by their actual year-category memberships.
     * Exam-prep categories stay separate from regular courses, including on year pages. */
    public function prepareCourseCatalog($courses = [], $year_ids = [], $selected_id = null, $lang = null)
    {
        $lang = $lang ?: LANGUAGE;
        $categories = TableRegistry::get('Categories')->getAll(PRODUCT, $lang);
        $selected_id = (int) $selected_id;
        $exam_catalog = $selected_id === self::EXAM_PREP_CATEGORY_ID;
        $ancestor = $selected_id;
        $visited = [];
        while ($ancestor && isset($categories[$ancestor]) && !isset($visited[$ancestor])) {
            $visited[$ancestor] = true;
            if ($ancestor === self::EXAM_PREP_CATEGORY_ID) { $exam_catalog = true; break; }
            $ancestor = (int) $categories[$ancestor]['parent_id'];
        }
        $request = $this->getView()->getRequest();
        $solution = rtrim($request->getUri()->getPath(), '/') === '/khoa-chua-de' || $request->getQuery('loai') === 'exam_solution';
        if ($exam_catalog || $solution) {
            $years = array_filter($categories, function ($category) {
                return (int) $category['parent_id'] === self::EXAM_PREP_CATEGORY_ID && !empty($category['status']);
            });
            uasort($years, function ($a, $b) { return strnatcasecmp($a['name'], $b['name']); });
            $year_ids = array_keys($years);
        }
        $kind = $solution ? 'exam_solution' : ($exam_catalog ? 'quiz' : 'knowledge');
        if ($solution && !$exam_catalog && $request->getQuery('nam') !== null) {
            $year = (int)$request->getQuery('nam');
            if (in_array($year, array_map('intval', (array)$year_ids), true)) $selected_id = $year;
        }
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
        $selected_year = isset($groups[$selected_id]) ? $selected_id : null;
        $unique = [];
        $other = [];
        foreach ((array) $courses as $course) {
            if (empty($course['id']) || isset($unique[$course['id']])) continue;
            if (($course['course_kind'] ?? \App\Service\CourseTypes::kind((int)$course['id'])) !== $kind) continue;
            $exam_prep = $kind === 'quiz';
            if ($selected_year !== null && !isset($course['categories'][$selected_year])) continue;
            $unique[$course['id']] = true;
            $attrs = $course['attributes'] ?? [];
            $lessons = json_decode($attrs['danhsachtiethoc']['value'] ?? '', true);
            $chapters = $lesson_count = 0;
            $first_trial_video = $first_free_quiz = $first_quiz = 0;
            foreach (is_array($lessons) ? $lessons : [] as $lesson) {
                if (!is_array($lesson) || empty($lesson['name_' . $lang])) continue;
                if (($lesson['chapter_' . $lang] ?? '') === 'y') { $chapters++; continue; }
                $lesson_count++;
                $video = preg_replace('/[^\w-].*$/s', '', trim((string) ($lesson['youtube_id_' . $lang] ?? '')));
                if (!$first_trial_video && ($lesson['trial_' . $lang] ?? '') === 'y' && strlen($video) === 11) $first_trial_video = $lesson_count;
                foreach (LessonQuizzes::of($lesson, $lang) as $quiz) {
                    if (!$first_quiz) $first_quiz = $lesson_count;
                    if (!$first_free_quiz && $quiz['free']) $first_free_quiz = $lesson_count;
                }
            }
            $summary = $attrs['motangan']['value'] ?? ($course['description'] ?? '');
            $summary = html_entity_decode(strip_tags((string) $summary), ENT_QUOTES | ENT_HTML5, 'UTF-8');
            $summary = trim(preg_replace('/\s+/u', ' ', str_replace("\xc2\xa0", ' ', $summary)) ?? '');
            $course['catalog_meta'] = [
                'chapters' => $chapters,
                'lessons' => $lesson_count,
                'exam_prep' => $exam_prep,
                'exams' => $exam_prep ? count(LessonQuizzes::ids(is_array($lessons) ? $lessons : [])) : 0,
                'preview_lesson' => $exam_prep ? ($first_free_quiz ?: $first_quiz ?: 1) : ($first_trial_video ?: $first_free_quiz ?: 1),
                'preview_tab' => $exam_prep ? 'quiz' : 'video',
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
        if ($exam_catalog || $solution) {
            // A year page's input contains only that year; keep links to the other populated years.
            $available = ConnectionManager::get('default')->execute(
                'SELECT DISTINCT cp.category_id FROM categories_product cp JOIN products p ON p.id=cp.product_id WHERE p.course_kind=:kind AND p.deleted=0 AND p.status=1 AND COALESCE(p.draft,0)=0',
                ['kind'=>$kind]
            )->fetchAll('assoc');
            $nav_groups = array_intersect_key($nav_groups, array_flip(array_column($available,'category_id')));
        }
        if ($other) $groups['other'] = ['id' => 'other', 'name' => $exam_catalog ? 'Luyện đề theo môn' : 'Khóa học khác', 'url' => null, 'courses' => $other];
        return [
            'groups' => array_values(array_filter($groups, function ($group) { return !empty($group['courses']); })),
            'nav_groups' => array_values($nav_groups),
            'total' => count($unique),
            'selected_id' => $selected_id,
            'exam_prep' => $exam_catalog,
            'catalog_url' => $kind === 'exam_solution' ? '/khoa-chua-de' : ($exam_catalog ? '/trac-nghiem' : '/khoa-hoc'),
            'course_kind' => $kind,
            'course_label' => \App\Service\CourseTypes::LABELS[$kind],
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
            $query->where('Quizs.fa_only=0 AND Quizs.course_only=0');
        }

        return $query->toList();
    }

    /** Bài tập của một buổi học: [['id' => id đề, 'free' => làm thử miễn phí], ...] theo thứ tự admin xếp
     *
     * $lesson (*): một buổi trong "Danh sách tiết học" của khóa học (xem App\Lib\LessonQuizzes)
     *
     * {$quizzes = $this->Product->getLessonQuizzes($item)}
    */
    public function getLessonQuizzes($lesson = [], $kind = null)
    {
        return $kind === null ? LessonQuizzes::of($lesson) : \App\Service\CourseTypes::quizzes($lesson, $kind);
    }

    /** Bài tập của trang khóa học (block/product_detail/view_classroom.tpl)
     *
     * $params['lesson_list'] (*): danh sách tiết học của khóa học
     *
     * Trả về ['info' => [id => ['id', 'name', 'count' => số câu, 'minutes']]]: mọi đề còn dùng được của các buổi học,
     * không gồm đề đã xóa hay đề nội bộ (quiz_exam_metadata.staff_only). Câu hỏi không có ở đây: trình làm bài
     * (assets/meduc-v2/classroom-quiz.js) tải từng đề khi học viên bắt đầu làm, qua /khoa-hoc/bai-tap/{khóa}/{đề}
     * (QuizsAnswerController::player), nên trang nhẹ dù khóa có hàng trăm đề.
     *
     * {$course_quizzes = $this->Product->getCourseQuizData(['lesson_list' => $raw_lessons])}
    */
    public function getCourseQuizData($params = [], $lang = null)
    {
        $lang = $lang ?: LANGUAGE;
        $ids = \App\Service\CourseTypes::kind((int)($params['product_id'] ?? 0)) === 'quiz' ? LessonQuizzes::ids($params['lesson_list'] ?? []) : [];
        $result = ['info' => []];
        if (!$ids) return $result;

        $rows = ConnectionManager::get('default')->execute(
            "SELECT q.id, c.name, JSON_LENGTH(questions.value) AS count, minutes.value AS minutes
             FROM quizs q
             LEFT JOIN quizs_content c ON c.quiz_id = q.id AND c.lang = :lang
             JOIN quizs_attribute questions ON questions.quiz_id = q.id AND questions.attribute_id = :questions AND JSON_VALID(questions.value)
             LEFT JOIN quizs_attribute minutes ON minutes.quiz_id = q.id AND minutes.attribute_id = :minutes
             WHERE q.deleted = 0 AND q.fa_only = 0 AND q.id IN (" . implode(',', array_map('intval', $ids)) . ")
               AND q.id NOT IN (SELECT quiz_id FROM quiz_exam_metadata WHERE staff_only = 1)",
            ['lang' => $lang, 'questions' => QuizQuestions::QUESTIONS_ATTRIBUTE, 'minutes' => QuizQuestions::MINUTES_ATTRIBUTE]
        )->fetchAll('assoc');

        foreach ($rows as $row) {
            // Empty draft slots remain visible with a disabled start button.
            $id = (int) $row['id'];
            $result['info'][$id] = ['id' => $id, 'name' => trim((string) $row['name']), 'count' => (int) $row['count'], 'minutes' => (int) $row['minutes']];
        }
        return $result;
    }
}
