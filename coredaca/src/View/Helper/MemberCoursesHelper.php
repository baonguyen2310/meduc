<?php
declare(strict_types=1);

namespace App\View\Helper;

use App\Service\DocumentCredits;
use Cake\Log\Log;
use Cake\ORM\TableRegistry;
use Cake\View\Helper;
use Throwable;

class MemberCoursesHelper extends Helper
{
    public $helpers = ['Member'];

    private const GROUPS = [
        'knowledge' => ['label' => 'Khoá ôn kiến thức', 'catalogue' => '/khoa-hoc', 'action' => 'Vào học'],
        'exam_solution' => ['label' => 'Khoá luyện thi', 'catalogue' => '/khoa-chua-de', 'action' => 'Vào học'],
        'quiz' => ['label' => 'Khoá đề thi', 'catalogue' => '/trac-nghiem', 'action' => 'Làm đề'],
    ];

    public function dashboard(): array
    {
        $member = $this->Member->getMemberInfo();
        $customerId = (int) ($member['id'] ?? 0);
        $requestedKind = $this->getView()->getRequest()->getQuery('loai');
        $selected = is_string($requestedKind) && isset(self::GROUPS[$requestedKind]) ? $requestedKind : null;
        $result = [
            'signed_in' => $customerId > 0,
            'groups' => array_map(static function (array $group): array {
                return $group + ['courses' => []];
            }, self::GROUPS),
            'active_kind' => $selected ?? 'knowledge',
            'credits' => null,
            'courses_unavailable' => false,
        ];

        if (!$result['signed_in']) return $result;

        try {
            $result['credits'] = DocumentCredits::balance($customerId);
        } catch (Throwable $exception) {
            Log::error('Member courses document balance: ' . $exception->getMessage());
        }

        try {
            foreach ($this->courseCards() as $kind => $courses) {
                $result['groups'][$kind]['courses'] = $courses;
            }
        } catch (Throwable $exception) {
            Log::error('Member courses access list: ' . $exception->getMessage());
            $result['courses_unavailable'] = true;
        }

        if ($selected === null) {
            foreach ($result['groups'] as $kind => $group) {
                if (!$group['courses']) continue;
                $result['active_kind'] = $kind;
                break;
            }
        }

        return $result;
    }

    private function courseCards(): array
    {
        $ids = array_keys($this->Member->getCourseAccessList());
        if (!$ids) return [];

        $products = TableRegistry::get('Products');
        // A withdrawn sales variant does not remove an existing learning entitlement.
        $rows = $products->queryListProducts([
            'get_item' => true,
            FILTER => [LANG => LANGUAGE, STATUS => 1, 'ids' => $ids],
            SORT => [FIELD => 'position', SORT => DESC],
        ])->where(['OR' => ['Products.draft' => 0, 'Products.draft IS' => null]])->all();

        $groups = [];
        $legacyIds = null;
        foreach ($rows as $row) {
            $kind = (string) ($row['course_kind'] ?? '');
            if ($kind === '') {
                $legacyIds = $legacyIds ?? array_fill_keys(TableRegistry::get('CourseEnrollments')->courseIds(), true);
                if (isset($legacyIds[(int) $row['id']])) $kind = 'knowledge';
            }
            if (!isset(self::GROUPS[$kind])) continue;

            $product = $products->formatDataProductDetail($row, LANGUAGE);
            if (empty($product['name']) || empty($product['url'])) continue;
            $groups[$kind][] = [
                'id' => $product['id'],
                'name' => $product['name'],
                'url' => $product['url'],
                'image' => $product['all_images'][0] ?? null,
            ];
        }
        return $groups;
    }
}
