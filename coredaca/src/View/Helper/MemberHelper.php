<?php
declare(strict_types=1);

namespace App\View\Helper;

use Cake\View\Helper;
use Cake\ORM\TableRegistry;
use Cake\Core\Configure;

class MemberHelper extends Helper
{
    public $helpers = ['Utilities'];

    // khóa học được học của học viên đang đăng nhập, tính một lần mỗi trang (getCourseAccessList)
    private $course_access = null;

    /** Lấy thông tin tài khoản khách hàng khi đã đăng nhập
     * 
     * 
     * {assign var = data value = $this->Member->getMemberInfo()}
     * 
    */
    public function getMemberInfo()
    {
        $session = $this->getView()->getRequest()->getSession();
        return $session->read(MEMBER);     
    }

    /** Lấy thông tin khách hàng qua ID khách hàng
     * 
     * $params['get_user']: lấy thông tin của nhân viên - ví dụ: 'true'| 'false'
     * $params['get_account']: lấy thông tin của tài khoản - ví dụ: 'true'| 'false'
     * $params['get_default_address']: lấy thông tin địa chỉ mặc định - ví dụ: 'true'| 'false'
     * $params['get_list_address']: lấy danh sách địa chỉ - ví dụ: 'true'| 'false'
     * $params['get_point']: lấy thông tin điểm - ví dụ: 'true'| 'false'
     * $params['get_bank']: lấy thông tin tài khoản ngân hàng - ví dụ: 'true'| 'false'
     * 
     * {assign var = data value = $this->Member->getDetailCustomer(1995, [
     *      'get_default_address' => true
     * ])}
     * 
    */
    public function getDetailCustomer($customer_id = null, $param = [])
    {
        if(empty($customer_id)) return [];

        $table = TableRegistry::get('Customers');

        $customer = $table->getDetailCustomer($customer_id, $param);
        
        return $table->formatDataCustomerDetail($customer);
    }

    /** Lấy danh sách ngân hàng
     * 
     * 
     * {assign var = data value = $this->Member->getListBank()}
     * 
    */
    public function getListBank()
    {
        return Configure::read('LIST_BANK');
    }

    /** Lấy danh sách khảo sát
     * 
     * 
     * {assign var = data value = $this->Member->getListSurvey()}
     * 
    */
    public function getListSurvey()
    {
        return Configure::read('LIST_SURVEY');
    }

    /** Lấy danh sách ngân hàng kiểu dropdown
     * 
     * $customer_id*: ID của khách hàng(int)
     * 
     * {assign var = data value = $this->Member->getListBankDropdown($customer_id)}
     * 
    */
    public function getListBankDropdown($customer_id = null, $params = [])
    {
        $result = [];
        if(empty($customer_id)) return $result;

        $params[FILTER]['customer_id'] = $customer_id;
        $params[FIELD] = LIST_INFO;

        $banks = TableRegistry::get('CustomersBank')->queryListCustomersBank($params)->toList();

        foreach ($banks as $k => $bank) {
            $bank_name = !empty($bank['bank_name']) ? $bank['bank_name'] : null;
            $account_number = !empty($bank['account_number']) ? ' - ' . $bank['account_number'] : null;
            $result[$bank['id']] = $bank_name . $account_number;
        }
        return $result;
    }

    /** Lấy danh sách các bài quiz đã làm theo $customer_id
     * 
     * 
     * {assign var = member_quizs_answer value = $this->Member->getMemberQuizsAnswer($customer_id)}
     * 
    */
    public function getMemberQuizsAnswer($customer_id = null)
    {
        $data = TableRegistry::get('QuizsAnswer')->queryListQuizsAnswer($customer_id)->toList();
        return $data;
    }

    /** Lấy danh sách các đơn hàng theo $customer_id
     * 
     * 
     * {assign var = list_order value = $this->Member->getListOrdersByCustomer($customer_id)}
     * 
    */
    public function getListOrdersByCustomer($customer_id = null)
    {
        $data = TableRegistry::get('Orders')->queryListOrdersByCustomer($customer_id)->toList();
        return $data;
    }

    /** Lấy danh sách thứ hạng của các customer
     * 
     * 
     * {assign var = rank value = $this->Member->getRank()}
     * 
    */
    public function getRank()
    {
        $result = [];

        $data = TableRegistry::get('QuizsAnswer')->queryRank()->toList();

        if(!empty($data)){
            foreach($data as $k => $item){
                $result[$k] = TableRegistry::get('QuizsAnswer')->formatDataQuizsAnswerDetail($item);
            }
        }

        return $result;
    }

    /** Lấy danh sách các lớp học mà học viên đã được add vào theo $customer_id
     * 
     * 
     * {assign var = listClassRoom value = $this->Member->getListClassRoomByCustomerId($customer_id)}
     * 
    */
    public function getListClassRoomByCustomerId($customer_id = null)
    {
        $data = [];
        if(empty($customer_id)) return $data;

        $table = TableRegistry::get('ClassRooms');
        $where = ['ClassRooms.deleted' => 0];

        if(!empty($customer_id)){
            $where['ClassRooms.users LIKE'] = '%' . $customer_id . '%';
        }

        // $fields = ['ClassRooms.id', 'ClassRooms.product_id', 'ClassRooms.name', 'ClassRooms.search_unicode', 'ClassRooms.description', 'ClassRooms.image_avatar', 'ClassRooms.users', 'ClassRooms.created', 'ClassRooms.updated', 'ClassRooms.position', 'ClassRooms.status'];
        
        $fields = ['ClassRooms.id', 'ClassRooms.product_id'];

        $sort_string = 'ClassRooms.id DESC';

        $data = $table->find()->where($where)->select($fields)->order($sort_string)->toList();
        return $data;
    }

    /** Khóa học mà học viên đang đăng nhập được học (các bài và bài tập dành cho học viên đã đăng ký)
     *
     * $product_id (*): id khóa học
     *
     * Trả về [] nếu chưa được học, ngược lại ['class_room_id' => id lớp hoặc 0, 'enrollment_id' => id ghi danh hoặc 0,
     * 'expires_at' => hạn học (unix time) hoặc 0]:
     * - học viên cũ: lớp học có mã học viên trong danh sách (class_rooms.users);
     * - học viên mới: ghi danh còn hiệu lực, tự động khi đơn hàng thanh toán đủ hoặc do admin thêm (course_enrollments).
     *
     * {assign var = course_access value = $this->Member->getCourseAccess($product.id)}
    */
    public function getCourseAccess($product_id = null)
    {
        $list = $this->getCourseAccessList();
        return !empty($product_id) && !empty($list[intval($product_id)]) ? $list[intval($product_id)] : [];
    }

    /** Mọi khóa học mà học viên đang đăng nhập được học, theo id khóa học (xem getCourseAccess); tính một lần mỗi trang
     *
     * {assign var = courses value = $this->Member->getCourseAccessList()}
    */
    public function getCourseAccessList()
    {
        if ($this->course_access !== null) return $this->course_access;

        $this->course_access = [];
        $member = $this->getMemberInfo();
        if (empty($member['id'])) return $this->course_access;

        if (!empty($member['code'])) {
            foreach ($this->getListClassRoomByCustomerId($member['code']) as $class_room) {
                $product_id = intval($class_room['product_id']);
                if (empty($product_id) || !empty($this->course_access[$product_id])) continue;
                $this->course_access[$product_id] = ['class_room_id' => intval($class_room['id']), 'enrollment_id' => 0, 'expires_at' => 0];
            }
        }

        foreach (TableRegistry::get('CourseEnrollments')->activeCourses($member['id']) as $product_id => $enrollment) {
            $access = !empty($this->course_access[$product_id]) ? $this->course_access[$product_id] : ['class_room_id' => 0];
            $access['enrollment_id'] = intval($enrollment['id']);
            $access['expires_at'] = intval($enrollment['expires_at']);
            $this->course_access[$product_id] = $access;
        }

        return $this->course_access;
    }
}
