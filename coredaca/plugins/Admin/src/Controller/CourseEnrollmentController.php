<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;

/** Ghi danh khóa học (bảng course_enrollments, scripts/meduc_v2_course_enrollment.sql)
 *
 * Học viên được ghi danh thì học được các bài và bài tập dành cho học viên của khóa trên website.
 * Đơn hàng thanh toán đủ tự ghi danh (nguồn "Đơn hàng"); ở đây admin xem, thêm tay, đặt hạn học, tạm khóa và xóa.
 * Học viên cũ vẫn học qua Lớp học (class_rooms), không cần ghi danh lại.
 */
class CourseEnrollmentController extends AppController {

    const PER_PAGE = 30;

    public function initialize(): void
    {
        parent::initialize();
    }

    public function list()
    {
        $table = TableRegistry::get('CourseEnrollments');
        $query = $this->request->getQueryParams();

        $filter = [
            'keyword' => !empty($query['keyword']) ? trim($query['keyword']) : '',
            'product_id' => !empty($query['product_id']) ? intval($query['product_id']) : '',
            'status' => isset($query['status']) && $query['status'] !== '' ? intval($query['status']) : '',
            'source' => !empty($query['source']) && in_array($query['source'], ['admin', 'order']) ? $query['source'] : ''
        ];
        $page = !empty($query['page']) ? max(1, intval($query['page'])) : 1;

        $list = $table->queryList([FILTER => $filter]);
        $total = $list->count();
        $pages = max(1, (int)ceil($total / self::PER_PAGE));
        $page = min($page, $pages);

        $enrollments = $list->order(['CourseEnrollments.id' => 'DESC'])
            ->limit(self::PER_PAGE)->offset(($page - 1) * self::PER_PAGE)
            ->enableHydration(false)->toList();

        $this->js_page = ['/assets/js/pages/course_enrollment.js'];

        $this->set('enrollments', $enrollments);
        $this->set('filter', $filter);
        $this->set('page', $page);
        $this->set('pages', $pages);
        $this->set('total', $total);
        $this->set('courses', $table->courseOptions(LANGUAGE_ADMIN));
        $this->set('now', time());
        $this->set('path_menu', 'course-enrollment');
        $this->set('title_for_layout', 'Ghi danh khóa học');
    }

    public function add()
    {
        $query = $this->request->getQueryParams();

        $this->js_page = ['/assets/js/pages/course_enrollment.js'];

        $this->set('enrollment', [
            'product_id' => !empty($query['product_id']) ? intval($query['product_id']) : null,
            'status' => 1
        ]);
        $this->set('courses', TableRegistry::get('CourseEnrollments')->courseOptions(LANGUAGE_ADMIN));
        $this->set('path_menu', 'course_enrollment_add');
        $this->set('title_for_layout', 'Ghi danh học viên');
        $this->render('update');
    }

    public function update($id = null)
    {
        $table = TableRegistry::get('CourseEnrollments');
        $enrollment = $table->queryList()->where(['CourseEnrollments.id' => intval($id)])->enableHydration(false)->first();
        if (empty($enrollment)) {
            $this->showErrorPage();
            return;
        }

        $this->js_page = ['/assets/js/pages/course_enrollment.js'];

        $this->set('id', intval($id));
        $this->set('enrollment', $enrollment);
        $this->set('courses', $table->courseOptions(LANGUAGE_ADMIN));
        $this->set('path_menu', 'course-enrollment');
        $this->set('title_for_layout', 'Cập nhật ghi danh');
    }

    public function save($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        // "save" không có trong cấu hình quyền: thêm mới cần quyền "add", sửa cần quyền "update"
        $this->checkRight(empty($id) ? 'add' : 'update');

        $table = TableRegistry::get('CourseEnrollments');
        $expires_at = null;
        if (!empty($data['expires_at'])) {
            $date = \DateTime::createFromFormat('!Y-m-d', trim($data['expires_at']));
            if (empty($date)) {
                $this->responseJson([MESSAGE => 'Hạn học không hợp lệ.']);
            }
            $expires_at = $date->getTimestamp() + 86399; // học hết ngày hôm đó
        }

        $fields = [
            'expires_at' => $expires_at,
            'note' => !empty($data['note']) ? mb_substr(trim(strip_tags($data['note'])), 0, 500) : null,
            'status' => !empty($data['status']) ? 1 : 0
        ];

        try {
            if (!empty($id)) {
                $enrollment = $table->find()->where(['id' => intval($id), 'deleted' => 0])->first();
                if (empty($enrollment)) {
                    throw new Exception(__d('admin', 'khong_lay_duoc_thong_tin_ban_ghi'));
                }

                $save = $table->save($table->patchEntity($enrollment, $fields));
                if (empty($save->id)) {
                    throw new Exception();
                }
                $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);
            }

            $customer_id = !empty($data['customer_id']) ? intval($data['customer_id']) : 0;
            $product_id = !empty($data['product_id']) ? intval($data['product_id']) : 0;

            $customer = TableRegistry::get('Customers')->find()->where(['id' => $customer_id, 'deleted' => 0])->select(['id'])->first();
            if (empty($customer)) {
                throw new Exception('Vui lòng chọn học viên.');
            }
            if (empty($product_id) || !in_array($product_id, $table->courseIds(), true)) {
                throw new Exception('Vui lòng chọn khóa học.');
            }

            $current = $table->find()->where(['customer_id' => $customer_id, 'product_id' => $product_id, 'deleted' => 0])->first();
            if (!empty($current)) {
                throw new Exception('Học viên này đã được ghi danh vào khóa học. Hãy sửa ghi danh đó (#' . $current['id'] . ').');
            }

            $save = $table->enroll($customer_id, $product_id, array_merge($fields, [
                'source' => 'admin',
                'order_id' => null,
                'created_by' => intval($this->Auth->user('id'))
            ]));
            if (empty($save)) {
                throw new Exception();
            }
            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        } catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function delete()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) && is_array($data['ids']) ? array_map('intval', $data['ids']) : [];
        if (!$this->getRequest()->is('post') || empty($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        TableRegistry::get('CourseEnrollments')->updateAll(['deleted' => 1, 'updated' => time()], ['id IN' => $ids]);
        $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'xoa_du_lieu_thanh_cong')]);
    }

    public function changeStatus()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) && is_array($data['ids']) ? array_map('intval', $data['ids']) : [];
        $status = !empty($data['status']) ? 1 : 0;
        if (!$this->getRequest()->is('post') || empty($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        TableRegistry::get('CourseEnrollments')->updateAll(['status' => $status, 'updated' => time()], ['id IN' => $ids, 'deleted' => 0]);
        $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'cap_nhat_thanh_cong')]);
    }

    /** Tìm học viên theo tên, mã học viên, số điện thoại hoặc email: [['id', 'code', 'full_name', 'phone', 'email'], ...] */
    public function customerSuggest()
    {
        $this->layout = false;
        $this->autoRender = false;

        $keyword = trim((string)$this->getRequest()->getData('keyword'));
        if (!$this->getRequest()->is('post') || mb_strlen($keyword) < 2) {
            $this->responseJson([CODE => SUCCESS, DATA => []]);
        }

        $like = '%' . $keyword . '%';
        $customers = TableRegistry::get('Customers')->find()
            ->where(['deleted' => 0, 'OR' => [
                'code LIKE' => $like,
                'full_name LIKE' => $like,
                'phone LIKE' => $like,
                'email LIKE' => $like
            ]])
            ->select(['id', 'code', 'full_name', 'phone', 'email'])
            ->order(['id' => 'DESC'])->limit(10)->enableHydration(false)->toList();

        $this->responseJson([CODE => SUCCESS, DATA => $customers]);
    }

    private function checkRight($right = null)
    {
        if (!empty($this->Auth->user('supper_admin'))) return;

        $user = TableRegistry::get('Users')->find()->where(['id' => intval($this->Auth->user('id'))])->select(['role_id'])->first();
        $allowed = !empty($user['role_id']) && TableRegistry::get('Roles')->checkPermissionRequest(intval($user['role_id']), 'CourseEnrollment', $right);
        if (!$allowed) {
            $this->responseJson([MESSAGE => __d('admin', 'ban_khong_co_quyen_thuc_hien_hanh_dong_nay')]);
        }
    }
}
