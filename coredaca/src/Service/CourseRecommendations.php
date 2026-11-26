<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Datasource\ConnectionManager;
use Cake\Utility\Text;

final class CourseRecommendations
{
    public const SECONDARY_NAVIGATION = [
        '/gioi-thieu' => 'Giới thiệu',
        '/doi-ngu-giang-vien' => 'Giảng viên',
        '/phuong-phap-hoc' => 'Phương pháp học',
        '/phan-hoi-hoc-vien' => 'Phản hồi',
        '/lo-trinh-hoc' => 'Lộ trình học',
    ];

    private const ACADEMY = [
        'knowledge' => ['title' => 'Khoá ôn kiến thức', 'url' => '/khoa-hoc'],
        'exam_solution' => ['title' => 'Khoá luyện thi', 'url' => '/khoa-chua-de'],
    ];

    // Integrated subjects are covered in modules of these Academy courses.
    private const KNOWLEDGE_MODULES = [
        'he-tim-mach' => ['ecg', 'sinh-ly', 'noi-co-so'],
        'huyet-hoc' => ['xet-nghiem', 'sinh-ly'],
        'he-than-tiet-nieu' => ['sinh-ly', 'giai-phau', 'noi-co-so'],
        'rang-ham-mat' => ['tieng-anh-y-khoa', 'giai-phau'],
        'he-tieu-hoa' => ['giai-phau', 'sinh-ly', 'noi-co-so'],
        'he-ho-hap' => ['giai-phau', 'sinh-ly', 'noi-co-so'],
        'he-da-co-xuong-khop' => ['giai-phau', 'sinh-ly', 'ngoai-co-so'],
        'he-than-kinh' => ['giai-phau', 'sinh-ly', 'noi-co-so'],
        'he-noi-tiet-chuyen-hoa' => ['sinh-ly', 'hoa-sinh'],
        'he-sinh-san' => ['sinh-ly', 'san-phu-khoa'],
        'da-va-giac-quan' => ['giai-phau', 'sinh-ly'],
        'benh-hoc-noi-ngoai-khoa' => ['noi-khoa', 'ngoai-khoa'],
        'he-noi-tiet-sinh-san' => ['sinh-ly', 'san-phu-khoa', 'giai-phau'],
        'dieu-duong-co-ban' => ['tien-lam-sang'],
    ];

    private const SOLUTION_SUBJECTS = [
        'ecg' => ['he-tim-mach'],
        'xet-nghiem' => ['huyet-hoc', 'hoa-sinh'],
        'tien-lam-sang' => ['dieu-duong-co-ban'],
        'noi-co-so' => ['noi-khoa'],
        'ngoai-co-so' => ['ngoai-khoa'],
        'duoc-lam-sang' => ['duoc-ly-hoc'],
    ];

    private $lang;
    private $catalog;

    public function __construct(string $lang)
    {
        $this->lang = $lang;
    }

    public function forCourse(int $id): array
    {
        $catalog = $this->catalog();
        $source = $catalog[$id] ?? null;
        if (!$source) return [];

        $subject = $source['subject'];
        $kind = $source['kind'];
        if ($kind === 'knowledge') {
            $courses = $this->matching('exam_solution', $subject, self::SOLUTION_SUBJECTS);
            return $this->academyCards(['exam_solution' => $courses]);
        }

        $groups = [];
        $knowledge = $this->matching('knowledge', $subject, self::KNOWLEDGE_MODULES);
        if ($kind === 'quiz') {
            $paired = $this->pairedCourse('exam_solution', $source['pair']);
            $groups['exam_solution'] = $paired ? [$paired] : $this->coursesForSubject('exam_solution', $subject);
        } else {
            $paired = $this->pairedCourse('quiz', $source['pair']);
        }
        if (!$knowledge && $paired) {
            $knowledge = $this->matching('knowledge', $paired['subject'], self::KNOWLEDGE_MODULES);
        }
        $groups['knowledge'] = $knowledge;
        return $this->academyCards($groups);
    }

    public function forContent(string $title, array $subjects = [], array $configuredIds = []): array
    {
        $catalog = $this->catalog();
        $courses = [];
        foreach ($configuredIds as $id) {
            if (($catalog[$id]['kind'] ?? null) === 'knowledge') $courses[$id] = $catalog[$id];
        }
        if ($courses) return $this->cards('Khoá ôn kiến thức liên quan', $courses);

        foreach ($subjects as $subject) {
            $key = PurchaseGiftSubjects::key($subject);
            $courses = $this->matching('knowledge', $key, self::KNOWLEDGE_MODULES);
            if ($courses) return $this->cards('Khoá ôn kiến thức liên quan', $courses);
        }

        foreach ($this->subjectsIn($title) as $subject) {
            $matches = $this->matching('knowledge', $subject, self::KNOWLEDGE_MODULES);
            foreach ($matches as $course) $courses[$course['id']] = $course;
        }
        return $courses ? $this->cards('Khoá ôn kiến thức liên quan', $courses) : $this->featured();
    }

    public function forShop(array $product, array $configuredIds, array $subjects = []): array
    {
        $quiz = PurchaseGifts::installed() ? PurchaseGiftSubjects::forShopProduct((int)$product['id']) : 0;
        $linked = $quiz ? ($this->catalog()[$quiz]['subject'] ?? null) : null;
        if ($linked) array_unshift($subjects, $linked);
        foreach ($product['categories'] ?? [] as $category) {
            if (empty($category['status'])) continue;
            if ((int)$category['id'] === 87) $subjects[] = 'Nội cơ sở'; // Máy đo huyết áp.
            $subjects[] = preg_replace('/^Sách\s+/iu', '', $category['name']);
        }
        return $this->forContent((string)$product['name'], $subjects, $configuredIds);
    }

    public function featured(): array
    {
        return $this->cards('Khoá học nổi bật', $this->coursesForSubject('knowledge'), 'featured');
    }

    private function cards(string $title, array $courses, string $type = 'related'): array
    {
        return ['title' => $title, 'type' => $type, 'courses' => array_slice($courses, 0, 4)];
    }

    private function academyCards(array $groups): array
    {
        $cards = $browse = [];
        foreach ($groups as $kind => $courses) {
            $category = self::ACADEMY[$kind];
            if (!$courses) {
                $browse[] = ['name' => 'Xem các ' . mb_strtolower($category['title'], 'UTF-8'), 'url' => $category['url']];
                continue;
            }
            foreach (array_slice($courses, 0, 3) as $course) {
                $course['kind_label'] = $category['title'];
                $offer = CoursePricing::startingOffer($course['id']);
                $course['price'] = (int)($offer['amount'] ?? 0);
                $course['original_price'] = (int)($offer['price'] ?? 0);
                $cards[] = $course;
            }
        }
        return ['title' => 'Khoá học liên quan', 'type' => 'academy', 'courses' => $cards, 'browse' => $browse];
    }

    private function matching(string $kind, ?string $subject, array $modules): array
    {
        if ($subject === null) return [];
        $courses = $this->coursesForSubject($kind, $subject);
        if ($courses) return $courses;

        foreach ($modules[$subject] ?? [] as $module) {
            $matches = $this->coursesForSubject($kind, $module);
            if ($matches) $courses[] = $matches[0];
        }
        return $courses;
    }

    private function coursesForSubject(string $kind, ?string $subject = null): array
    {
        return array_values(array_filter($this->catalog(), static function (array $course) use ($kind, $subject): bool {
            return $course['kind'] === $kind && ($subject === null || $course['subject'] === $subject);
        }));
    }

    private function pairedCourse(string $kind, string $pair): ?array
    {
        if ($pair === '') return null;
        foreach ($this->catalog() as $course) {
            if ($course['kind'] === $kind && $course['pair'] === $pair) return $course;
        }
        return null;
    }

    private function subjectsIn(string $title): array
    {
        $terms = [];
        foreach ($this->catalog() as $course) {
            if (!$course['subject']) continue;
            $terms[$course['subject']] = $course['subject'];
            $terms[$course['term']] = $course['subject'];
        }
        uksort($terms, static function (string $a, string $b): int { return strlen($b) <=> strlen($a); });

        $title = '-' . Text::slug(mb_strtolower($title, 'UTF-8'), '-') . '-';
        $subjects = [];
        foreach ($terms as $term => $subject) {
            if ($term === '') continue;
            $phrase = '-' . $term . '-';
            if (strpos($title, $phrase) === false) continue;
            $subjects[$subject] = $subject;
            $title = str_replace($phrase, '--', $title);
        }
        return array_values($subjects);
    }

    private function catalog(): array
    {
        if ($this->catalog !== null) return $this->catalog;

        $rows = ConnectionManager::get('default')->execute(
            "SELECT p.id, p.course_kind, c.name, l.url,
                CASE WHEN p.course_kind IN ('knowledge','exam_solution') THEN (
                    SELECT JSON_UNQUOTE(JSON_EXTRACT(i.images, '$[0]')) FROM products_item i
                    WHERE i.product_id=p.id AND i.deleted=0 AND i.status=1 AND JSON_VALID(i.images)
                    AND JSON_LENGTH(i.images)>0 ORDER BY i.position DESC,i.id LIMIT 1
                ) END image,
                CASE WHEN p.course_kind IN ('quiz','exam_solution') THEN (
                    SELECT i.code FROM products_item i WHERE i.product_id=p.id AND i.deleted=0
                    AND (i.code LIKE 'MEDUC-32V1-Q-%' OR i.code LIKE 'MEDUC-32V1-S-%') ORDER BY i.id LIMIT 1
                ) END pair_code
             FROM products p
             JOIN products_content c ON c.product_id=p.id AND c.lang=?
             JOIN links l ON l.id=(SELECT MAX(route.id) FROM links route WHERE route.foreign_id=p.id
                 AND route.type='product_detail' AND route.lang=? AND route.deleted=0)
             WHERE p.course_kind IN ('quiz','exam_solution','knowledge') AND p.deleted=0 AND p.status=1 AND COALESCE(p.draft,0)=0
             ORDER BY p.featured DESC,p.position DESC,p.id DESC",
            [$this->lang, $this->lang]
        )->fetchAll('assoc');

        $this->catalog = [];
        foreach ($rows as $row) {
            $id = (int)$row['id'];
            $name = trim(html_entity_decode(strip_tags((string)$row['name']), ENT_QUOTES | ENT_HTML5, 'UTF-8'));
            $url = trim((string)$row['url']);
            if ($name === '' || !preg_match('~^/?[a-z0-9_-]+(?:/[a-z0-9_-]+)*$~iD', $url)) continue;

            $label = PurchaseGiftSubjects::courseLabel($name);
            $image = (string)$row['image'];
            preg_match('/^MEDUC-32V1-[QS]-(.+)$/D', (string)$row['pair_code'], $pair);
            $this->catalog[$id] = [
                'id' => $id,
                'kind' => $row['course_kind'],
                'name' => $name,
                'url' => '/' . ltrim($url, '/'),
                'image' => strpos($image, '/media/') === 0 ? $image : '',
                'term' => Text::slug(mb_strtolower($label, 'UTF-8'), '-'),
                'subject' => PurchaseGiftSubjects::key($label),
                'pair' => $pair[1] ?? '',
            ];
        }
        return $this->catalog;
    }
}
