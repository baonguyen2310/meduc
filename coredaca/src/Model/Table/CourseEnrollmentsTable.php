<?php
namespace App\Model\Table;

use Cake\Log\Log;
use Cake\ORM\TableRegistry;
use Cake\Utility\Text;
use Cake\Validation\Validator;

/** Course enrollments (scripts/meduc_v2_course_enrollment.sql): one row per student and course.
 *  - source "order": made when an order holding the course is fully paid (syncOrder, from OrdersTable::updateAfterPayment
 *    and the admin's order cancel); paused again when that order is cancelled or no longer fully paid.
 *  - source "admin": made by hand in the admin (CourseEnrollmentController).
 *  A student studies the course while the row is active: status 1, not deleted, expires_at empty or still ahead.
 *  Old students keep studying through class rooms (class_rooms.users), which MemberHelper::getCourseAccess also reads.
 */
class CourseEnrollmentsTable extends AppTable
{
    // Courses are the products in category 50 ("Khoá học") and its sub-categories, as in Admin\Service\TeacherCourseAccess.
    const COURSE_CATEGORY_ID = 50;

    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->setTable('course_enrollments');
        $this->setPrimaryKey('id');

        $this->addBehavior('UnixTimestamp', [
            'events' => [
                'Model.beforeSave' => [
                    'created' => 'new',
                    'updated' => 'existing'
                ]
            ]
        ]);
    }

    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->integer('id')
            ->allowEmptyString('id', null, 'create');

        return $validator;
    }

    /** Courses a student studies now: [product_id => ['id', 'product_id', 'source', 'order_id', 'expires_at']]. */
    public function activeCourses($customer_id = null): array
    {
        if (empty($customer_id)) return [];

        $rows = $this->find()->where([
            'customer_id' => intval($customer_id),
            'status' => 1,
            'deleted' => 0,
            'OR' => ['expires_at IS' => null, 'expires_at' => 0, 'expires_at >' => time()]
        ])->select(['id', 'product_id', 'source', 'order_id', 'expires_at'])->enableHydration(false)->toList();

        $result = [];
        foreach ($rows as $row) {
            $result[intval($row['product_id'])] = $row;
        }
        return $result;
    }

    /** Ids of every course, for the admin's course list and to tell courses from books in an order. */
    public function courseIds(): array
    {
        $rows = $this->getConnection()->execute(
            "SELECT p.id FROM products p
             WHERE p.deleted = 0 AND (
               p.main_category_id = :category OR EXISTS (
                 SELECT 1 FROM categories c WHERE c.id = p.main_category_id AND c.path_id LIKE :path
               ) OR EXISTS (
                 SELECT 1 FROM categories_product cp INNER JOIN categories c ON c.id = cp.category_id
                 WHERE cp.product_id = p.id AND (c.id = :category OR c.path_id LIKE :path)
               )
             )",
            ['category' => self::COURSE_CATEGORY_ID, 'path' => '%|' . self::COURSE_CATEGORY_ID . '|%']
        )->fetchAll('assoc');

        return array_map('intval', array_column($rows, 'id'));
    }

    /** Courses for the admin form: [id => name], newest first. */
    public function courseOptions($lang = 'vi'): array
    {
        $ids = $this->courseIds();
        if (empty($ids)) return [];

        $rows = TableRegistry::get('ProductsContent')->find()->where([
            'product_id IN' => $ids,
            'lang' => $lang
        ])->select(['product_id', 'name'])->order(['product_id' => 'DESC'])->enableHydration(false)->toList();

        $result = [];
        foreach ($rows as $row) {
            $result[intval($row['product_id'])] = trim((string)$row['name']);
        }
        return $result;
    }

    /** Enroll a student, or bring back the row they already have (it may be paused or deleted).
     *  $fields: source, order_id, expires_at, note, status, created_by. Returns the saved entity or false. */
    public function enroll($customer_id = null, $product_id = null, $fields = [])
    {
        $customer_id = intval($customer_id);
        $product_id = intval($product_id);
        if (empty($customer_id) || empty($product_id)) return false;

        $entity = $this->find()->where(['customer_id' => $customer_id, 'product_id' => $product_id])->first();
        $data = array_merge(['status' => 1, 'deleted' => 0], $fields, ['customer_id' => $customer_id, 'product_id' => $product_id]);

        // a deleted row comes back as a new enrollment
        if (!empty($entity) && !empty($entity['deleted'])) $data['created'] = time();
        $entity = empty($entity) ? $this->newEntity($data) : $this->patchEntity($entity, $data);
        $save = $this->save($entity);
        return !empty($save->id) ? $save : false;
    }

    /** Keep an order's enrollments in step with the order: each course in a fully paid order is enrolled for the order's
     *  customer; when the order is cancelled or no longer fully paid, the enrollments it made are paused.
     *  An order of 0đ (a course "Liên hệ" for its price) enrolls nobody: the admin enrolls such students by hand.
     *  Never throws, so a payment is recorded even when this fails. */
    public function syncOrder($order_id = null): bool
    {
        $order_id = intval($order_id);
        if (empty($order_id)) return false;

        try {
            $order = TableRegistry::get('Orders')->find()->where(['id' => $order_id])
                ->select(['id', 'total', 'point_paid', 'point_promotion_paid', 'status', 'deleted'])->first();
            if (empty($order)) return false;

            // Paid as the order shows it (OrdersTable::updateAfterPayment): receipts plus points.
            $total = floatval($order['total']);
            $paid = TableRegistry::get('Payments')->getTotalPaidOrder($order_id)
                + floatval($order['point_paid']) + floatval($order['point_promotion_paid']);
            $paid_in_full = $total > 0 && $paid >= $total && $order['status'] != CANCEL && empty($order['deleted']);

            if (!$paid_in_full) {
                $this->updateAll(['status' => 0, 'updated' => time()], [
                    'order_id' => $order_id, 'source' => 'order', 'status' => 1, 'deleted' => 0
                ]);
                return true;
            }

            $contact = TableRegistry::get('OrdersContact')->find()->where(['order_id' => $order_id])->select(['customer_id'])->first();
            $customer_id = !empty($contact['customer_id']) ? intval($contact['customer_id']) : 0;
            if (empty($customer_id)) return false;

            $product_ids = TableRegistry::get('OrdersItem')->find()->where(['order_id' => $order_id])
                ->select(['product_id'])->enableHydration(false)->all()->extract('product_id')->toList();
            $course_ids = array_intersect(array_unique(array_map('intval', $product_ids)), $this->courseIds());

            foreach ($course_ids as $product_id) {
                $current = $this->find()->where(['customer_id' => $customer_id, 'product_id' => $product_id])->first();
                // A row the admin made and keeps active stays as it is; anything else now comes from this order.
                if (!empty($current) && $current['source'] == 'admin' && $current['status'] == 1 && empty($current['deleted'])) continue;

                $this->enroll($customer_id, $product_id, [
                    'source' => 'order',
                    'order_id' => $order_id,
                    'created_by' => null,
                    'note' => !empty($current['note']) ? $current['note'] : null,
                    'expires_at' => !empty($current['expires_at']) && $current['expires_at'] > time() ? $current['expires_at'] : null
                ]);
            }
            return true;
        } catch (\Throwable $e) {
            Log::error('CourseEnrollments::syncOrder ' . $order_id . ': ' . $e->getMessage());
            return false;
        }
    }

    /** Admin list: filter keyword (student name, code, phone, email), product_id, status, source. */
    public function queryList($params = [])
    {
        $filter = !empty($params[FILTER]) ? $params[FILTER] : [];
        $keyword = !empty($filter['keyword']) ? trim($filter['keyword']) : null;
        $product_id = !empty($filter['product_id']) ? intval($filter['product_id']) : null;
        $status = isset($filter['status']) && $filter['status'] !== '' ? intval($filter['status']) : null;
        $source = !empty($filter['source']) ? $filter['source'] : null;

        $query = $this->find()
            ->join([
                'Customers' => ['table' => 'customers', 'type' => 'LEFT', 'conditions' => 'Customers.id = CourseEnrollments.customer_id'],
                'ProductsContent' => ['table' => 'products_content', 'type' => 'LEFT', 'conditions' => [
                    'ProductsContent.product_id = CourseEnrollments.product_id', 'ProductsContent.lang' => LANGUAGE_ADMIN
                ]],
                'Orders' => ['table' => 'orders', 'type' => 'LEFT', 'conditions' => 'Orders.id = CourseEnrollments.order_id'],
                'Users' => ['table' => 'users', 'type' => 'LEFT', 'conditions' => 'Users.id = CourseEnrollments.created_by']
            ])
            ->select([
                'CourseEnrollments.id', 'CourseEnrollments.product_id', 'CourseEnrollments.customer_id', 'CourseEnrollments.source',
                'CourseEnrollments.order_id', 'CourseEnrollments.expires_at', 'CourseEnrollments.note', 'CourseEnrollments.status',
                'CourseEnrollments.created', 'CourseEnrollments.updated',
                'customer_code' => 'Customers.code', 'customer_name' => 'Customers.full_name',
                'customer_phone' => 'Customers.phone', 'customer_email' => 'Customers.email',
                'course_name' => 'ProductsContent.name', 'order_code' => 'Orders.code', 'created_by_name' => 'Users.full_name'
            ])
            ->where(['CourseEnrollments.deleted' => 0]);

        if (!empty($keyword)) {
            $like = '%' . $keyword . '%';
            $query->where(['OR' => [
                'Customers.code LIKE' => $like,
                'Customers.full_name LIKE' => $like,
                'Customers.phone LIKE' => $like,
                'Customers.email LIKE' => $like,
                'Customers.search_unicode LIKE' => '%' . Text::slug(strtolower($keyword), ' ') . '%'
            ]]);
        }
        if (!empty($product_id)) $query->where(['CourseEnrollments.product_id' => $product_id]);
        if (!is_null($status)) $query->where(['CourseEnrollments.status' => $status]);
        if (in_array($source, ['admin', 'order'])) $query->where(['CourseEnrollments.source' => $source]);

        return $query;
    }
}
