<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Core\Configure;
use Cake\Http\Response;
use Cake\ORM\Query;
use Cake\Core\Exception\Exception;
use Cake\Utility\Hash;
use Cake\Datasource\ConnectionManager;
use Cake\Utility\Security;
use Cake\Mailer\Mailer;
use Cake\Mailer\TransportFactory;

class CustomerController extends AppController {

    public function initialize(): void
    {
        parent::initialize();        
    }

    public function list() 
    {
        $this->css_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css'
        ];

        $this->js_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js',
            '/assets/js/pages/list_customer.js'
        ];

        $this->set('path_menu', 'customer');
        $this->set('title_for_layout', __d('admin', 'khach_hang'));
    }

    public function listJson()
    {

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $table = TableRegistry::get('Customers');
        $utilities = $this->loadComponent('Utilities');

        $data = $params = $brands = [];

        $limit = PAGINATION_LIMIT_ADMIN;
        $page = 1;
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        // params query
        $params[QUERY] = !empty($data[QUERY]) ? $data[QUERY] : [];

        // params filter
        $params[FILTER] = !empty($data[DATA_FILTER]) ? $data[DATA_FILTER] : [];
        if(!empty($params[QUERY])){
            $params[FILTER] = array_merge($params[FILTER], $params[QUERY]);
        }
        $params['get_account'] = true;

        // params sort         
        $params[SORT] = !empty($data[SORT]) ? $data[SORT] : [];

        // page and limit
        $page = !empty($data[PAGINATION][PAGE]) ? intval($data[PAGINATION][PAGE]) : 1;
        $limit = !empty($data[PAGINATION][PERPAGE]) ? intval($data[PAGINATION][PERPAGE]) : PAGINATION_LIMIT_ADMIN;

        // sort 
        $sort_field = !empty($params[SORT][FIELD]) ? $params[SORT][FIELD] : null;
        $sort_type = !empty($params[SORT][SORT]) ? $params[SORT][SORT] : null;

        try {
            $customers = $this->paginate($table->queryListCustomers($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();

        } catch (Exception $e) {
            $page = 1;
            $customers = $this->paginate($table->queryListCustomers($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        }

        $pagination_info = !empty($this->request->getAttribute('paging')['Customers']) ? $this->request->getAttribute('paging')['Customers'] : [];
        $meta_info = $utilities->formatPaginationInfo($pagination_info);

        $result = [];
        if(!empty($customers)){
            foreach ($customers as $key => $customer) {
                $result[] = $table->formatDataCustomerDetail($customer);
            }
        }

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $result, 
            META => $meta_info
        ]);
    }

    public function autoSuggest()
    {
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $table = TableRegistry::get('Customers');
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        
        $filter = !empty($data[FILTER]) ? $data[FILTER] : [];
        $get_params = !empty($data['get_params']) ? $data['get_params'] : [];
        $filter[STATUS] = 1;

        $params = [
            FILTER => $filter,
            FIELD => SIMPLE_INFO
        ];

        if(!empty($get_params)){
            $params['get_user'] = !empty($get_params['get_user']) ? true : false;
            $params['get_account'] = !empty($get_params['get_account']) ? true : false;
            $params['get_default_address'] = !empty($get_params['get_default_address']) ? true : false;
            $params['get_list_address'] = !empty($get_params['get_list_address']) ? true : false;
            $params['get_point'] = !empty($get_params['get_point']) ? true : false;
            $params['get_bank'] = !empty($get_params['get_bank']) ? true : false;
            $params['address_id'] = !empty($get_params['address_id']) ? true : false;
        }
        
        $customers = $table->queryListCustomers($params)->limit(10)->toList();

        $result = [];
        if(!empty($customers)){
            foreach($customers as $customer){
                $item = $table->formatDataCustomerDetail($customer);
                $full_name = !empty($item['phone']) ? $item['full_name'] : null;
                $phone = !empty($item['phone']) ? $item['phone'] : null;
                $email = !empty($item['email']) ? $item['email'] : null;

                $item['full_name_phone'] = $item['full_name_email'] = $full_name;
                if(!empty($phone)) {
                    $item['full_name_phone'] = $full_name . ' - ' . $phone;
                }

                if(!empty($email)) {
                    $item['full_name_email'] = $full_name . ' - ' . $email;
                }

                $result[] = $item;
            }
        }
  
        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $result, 
        ]);
    }

    public function add() 
    {
        $cities_table = TableRegistry::get('Cities');
        $users_table = TableRegistry::get('Users');

        $this->js_page = [
            '/assets/js/pages/customer_add.js'
        ];
        $this->set('path_menu', 'customer');
        $this->set('title_for_layout', __d('admin', 'them_khach_hang'));
    }

    public function update($id = null) 
    {
        $customers_table = TableRegistry::get('Customers');

        $customer = $customers_table->getDetailCustomer($id, [
            'get_user' => false,
            'get_list_address' => true
        ]);

        if(empty($customer)){
            $this->showErrorPage();
        }
        $customer = $customers_table->formatDataCustomerDetail($customer);

        $this->js_page = [
            '/assets/js/pages/customer_update.js',
        ];

        $this->set('id', $id);
        $this->set('customer', $customer);
        $this->set('path_menu', 'customer');
        $this->set('title_for_layout', __d('admin', 'cap_nhat_khach_hang'));
    }

    public function saveAddress($customer_id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData(); 

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        if(empty($customer_id)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_khach_hang')]);
        }
    
        $customer_component = $this->loadComponent('Admin.Customer');
        $result = $customer_component->saveAddress($data, $customer_id);


        if($result[CODE] == SUCCESS){
            $data_result = !empty($result[DATA]) ? $result[DATA] : [];
            if(!empty($data_result)){
                $customer_id = !empty($data_result['customer_id']) ? intval($data_result['customer_id']) : null;
                $customer_info = TableRegistry::get('Customers')->get($customer_id);

                $data_result['full_name'] = !empty($customer_info['full_name']) ? $customer_info['full_name'] : null;
                $data_result['email'] = !empty($customer_info['email']) ? $customer_info['email'] : null;
                $data_result['address_name'] = !empty($data_result['name']) ? $data_result['name'] : null;
            }
            $result[DATA] = $data_result;
        }

        exit(json_encode($result));
    }

    public function getAddress($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData(); 

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($data['id'])) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $address_info = TableRegistry::get('CustomersAddress')->get($data['id']);
    
        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $address_info
        ]);
    }

    public function saveNote($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData(); 

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $comment = !empty($data['comment']) ? $data['comment'] : null;
        if(empty($comment)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $customers_table = TableRegistry::get('Customers');
        $customer_info = $customers_table->get($id);
        if(empty($customer_info)){
            $this->showErrorPage();
        }

        $utilities = $this->loadComponent('Utilities');
        $date = $utilities->stringDateTimeToInt(date('Y-m-d H:i:s'));

        $note = !empty($customer_info['note']) ? json_decode($customer_info['note'], true) : [];
        $note[] = [
            'comment' => $comment,
            'created_by' => null,
            'created' => $date
        ];

        $data_save = [
            'id' => $id,
            'note' => json_encode($note)
        ];

        $customer = $customers_table->patchEntity($customer_info, $data_save, ['validate' => false]);
        
        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $customers_table->save($customer);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }     
    }

    public function sendInfoAccount($info_full_name = null, $info_email = null, $info_username = null, $info_password = null) {
        $date_now = date("d/m/Y");
        $info_subject = "Tài khoản của bạn đã được kích hoạt";
        $info_content = '
            <div style="width: 720px; margin: 0 auto; overflow: hidden">
                <div
                style="
                    width: 700px;
                    margin: 0 auto;
                    overflow: hidden;
                    background: #ececec;
                "
                >
                <div
                    style="
                    overflow: hidden;
                    width: 100%;
                    margin-bottom: 20px;
                    background-color: #ec1c24;
                    color: #ffffff;
                    line-height: 40px;
                    "
                >
                    <ul style="list-style: none; margin: 0; padding: 0 20px">
                    <li style="float: left; margin: 0">
                        <span> Ngày: ' . $date_now . ' </span>
                    </li>
                    </ul>
                </div>
        
                <div style="overflow: hidden; width: 100%">
                    <ul style="list-style: none; margin: 0; padding: 0">
                    <li
                        style="
                        float: left;
                        width: 180px;
                        margin: 0;
                        padding: 0px 0 0px 20px;
                        "
                    >
                        <img src="https://ykhoa.daca.vn/templates/app01/assets/img/logo-meduc.jpg" style="height: 50px;width: auto;mix-blend-mode: multiply;">
                    </li>
                    </ul>
                </div>
        
                <div style="overflow: hidden; padding: 20px">
                    <div
                    style="
                        overflow: hidden;
                        background: #fff;
                        padding: 20px;
                        border-radius: 5px;
                    "
                    >
                    <div style="margin-bottom: 20px">
                        <strong> Xin chào ' . $info_full_name . '! </strong>
                    </div>
        
                    <div style="margin-bottom: 20px">
                        Chúc mừng bạn đã đăng ký thành công khoá học. Tài khoản của bạn đã được kích hoạt.
                    </div>
        
                    <div style="margin-bottom: 10px">Tên tài khoản: <strong>' . $info_username . '</strong></div>
        
                    <div style="margin-bottom: 10px">Mật khẩu: <strong>' . $info_password . '</strong></div>
        
                    <div style="margin-bottom: 10px">
                        Nếu muốn thay đổi mật khẩu, bạn có thể click chọn “Quên mật khẩu”,
                        hoặc thiết lập mật khẩu mới sau khi đăng nhập vào tài khoản.
                    </div>
        
                    <div style="margin-bottom: 10px">
                        Chúc bạn học tốt & sớm đạt kết quả nhé! 🤩
                    </div>
                    </div>
                </div>
        
                <div
                    style="
                    overflow: hidden;
                    width: 100%;
                    background-color: #ec1c24;
                    color: #ffffff;
                    line-height: 40px;
                    text-align: center;
                    "
                >
                    <span>
                    © Copyright 2023 | Y Khoa | All Rights Reserved
                    </span>
                    <div class="yj6qo"></div>
                    <div class="adL"></div>
                </div>
                <div class="adL"></div>
                </div>
                <div class="adL"></div>
            </div>
        ';


        $from_email = 'no.reply.daca.vn@gmail.com';
        $password = 'zzuzxkyupfwgtowl';
        TransportFactory::setConfig('gmail', [
            'host' => 'ssl://smtp.gmail.com',
            'port' => 465,
            'username' => $from_email,
            'password' => $password,
            'className' => 'Smtp'
        ]);

        try{
            $mailer = new Mailer();
            $mailer->setTransport('gmail');
            $mailer->setTo($info_email);
            $mailer->setFrom($from_email, 'Website Y Khoa');
            $mailer->setSubject($info_subject);
            $mailer->setEmailFormat('html');
            $mailer->deliver($info_content);
        } catch (Exception $e) {
            $this->responseJson([MESSAGE => __d('admin', 'gui_yeu_cau_khong_thanh_cong')]);
        }
    }

    public function save($id = null) 
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();    

        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $data_save = [
            'full_name' => !empty($data['full_name']) ? strip_tags(trim($data['full_name'])) : null,
            'username' => !empty($data['username']) ? $data['username'] : null,
            'password' => !empty($data['password']) ? $data['password'] : null,
            'address_name' => !empty($data['name']) ? $data['name'] : __d('admin', 'mac_dinh'),
            'phone' => !empty($data['phone']) ? $data['phone'] : null,
            'email' => !empty($data['email']) ? $data['email'] : null,
            'staff_id' => !empty($data['staff_id']) ? $data['staff_id'] : null,
            'code' => !empty($data['code']) ? $data['code'] : null,
            'birthday' => !empty($data['birthday']) ? $data['birthday'] : null,
            'sex' => !empty($data['sex']) ? $data['sex'] : null,
            'is_default' => empty($data['is_default']) ? 1 : 0,
            'city_id' => !empty($data['city_id']) ? $data['city_id'] : null,
            'district_id' => !empty($data['district_id']) ? $data['district_id'] : null,
            'ward_id' => !empty($data['ward_id']) ? $data['ward_id'] : null,
            'address' => !empty($data['address']) ? $data['address'] : null,
            'zip_code' => !empty($data['zip_code']) ? $data['zip_code'] : null,
            'status_account' => !empty($data['status_account']) ? intval($data['status_account']) : null
        ];

        $result = $this->loadComponent('Admin.Customer')->saveCustomer($data_save, $id);

        if($result[CODE] == SUCCESS){
            $result[DATA] = TableRegistry::get('Customers')->formatDataCustomerDetail($result[DATA]);
        }


        $info_full_name = !empty($data['full_name']) ? strip_tags(trim($data['full_name'])) : null;
        $info_email = !empty($data['email']) ? trim($data['email']) : null;
        $info_username = !empty($data['username']) ? $data['username'] : null;
        $info_password = !empty($data['password']) ? $data['password'] : null;
        
        $this->sendInfoAccount($info_full_name, $info_email, $info_username, $info_password);

        exit(json_encode($result));
    }

    public function detail($id = null)
    {
        $table = TableRegistry::get('Customers');

        $customer = $table->getDetailCustomer($id, [
            'get_account' => true,
            'get_default_address' => true,
            'get_list_address' => true
        ]);
        
        $customer = $table->formatDataCustomerDetail($customer);
        if(empty($customer)){
            $this->showErrorPage();
        }

        $orders = TableRegistry::get('Orders')->find()->contain(['OrdersContact'])
        ->where([
            'OrdersContact.customer_id' => $id,
            'Orders.type' => ORDER,
            'Orders.deleted' => 0
        ])->select([
            'Orders.id', 'Orders.created', 'Orders.code', 'Orders.note', 'Orders.total', 'Orders.total_paid', 'Orders.status'
        ])->toList();

        $this->js_page = [
            '/assets/js/pages/customer_detail.js'
        ];

        $this->set('id', $id);
        $this->set('customer', $customer);
        $this->set('orders', $orders);
        $this->set('title_for_layout', __d('admin', 'chi_tiet_khach_hang'));
    }

    public function checkExist($type = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();       
        $phone = !empty($data['phone']) ? trim($data['phone']) : null;
        $email = !empty($data['email']) ? trim($data['email']) : null;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($phone) && empty($email)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $check = false;

        $table = TableRegistry::get('Customers');        
        switch($type){
            case 'phone':
                $check = $table->checkPhoneExist($phone);
            break;

            case 'email':
                $check = $table->checkEmailExist($email);
            break;
        }
        
        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => ['exist' => $check]
        ]);
    }

    public function changeStatus()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) ? $data['ids'] : [];
        $status = !empty($data['status']) ? 1 : 0;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $customers_table = TableRegistry::get('Customers');
        try{
            $customers_table->updateAll(
                [  
                    'status' => $status
                ],
                [  
                    'id IN' => $ids
                ]
            );

            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'cap_nhat_thanh_cong')]);

        }catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function delete()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) ? $data['ids'] : [];
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $customers_table = TableRegistry::get('Customers');

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            foreach($ids as $id){
                // delete customer
                $customer_info = $customers_table->find()->where(['Customers.id' => $id])->contain(['Account'])->first();
                if (empty($customer_info)) {
                    $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_khach_hang')]);
                }
                if(!empty($customer_info['Account'])){
                    $customer = $customers_table->patchEntity($customer_info, [
                        'id' => $id, 
                        'deleted' => 1,
                        'Account' => [
                            'deleted' => 1
                        ]
                    ], ['validate' => false]);
                } else {
                    $customer = $customers_table->patchEntity($customer_info, [
                        'id' => $id, 
                        'deleted' => 1
                    ], ['validate' => false]);
                }
                $delete_customer = $customers_table->save($customer);
                if (empty($delete_customer)){
                    throw new Exception();
                }
            }

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'xoa_du_lieu_thanh_cong')]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function setDefault()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();

        if (empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $customer_component = $this->loadComponent('Admin.Customer');
        $update_default = $customer_component->setDefault($data);
        exit(json_encode($update_default));
    }

    public function deleteAddress()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();

        if (empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $customer_component = $this->loadComponent('Admin.Customer');
        $result = $customer_component->deleteAddress($data);
        exit(json_encode($result));
    }

    public function deleteNote()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();
        $id = !empty($data['id']) ? $data['id'] : null;
        $index = isset($data['index']) ? $data['index'] : null;
        if (empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('Customers');

        // delete customer address
        $customer_info = $table->get($id);
        $note = !empty($customer_info['note']) ? json_decode($customer_info['note'], true) : [];

        if (empty($note[$index])) {
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_thong_tin_ghi_chu')]);
        }

        unset($note[$index]);

        $data_save = [
            'id' => $id,
            'note' => json_encode($note)
        ];

        $customer = $table->patchEntity($customer_info, $data_save, ['validate' => false]);
        
        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $table->save($customer);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        } 
    }

    public function changePassword($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();    

        if (!$this->getRequest()->is('post') || empty($data) || empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $password = !empty($data['password']) ? $data['password'] : null;

        $account_table = TableRegistry::get('CustomersAccount');        
        $account_info = $account_table->find()->where(['customer_id' => $id])->first();
        if (empty($account_info)) {
            $this->responseJson([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $password = Security::hash($password, 'md5', false);
        
        $data_account = $account_table->patchEntity($account_info, [
            'password' => $password
        ]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $account_table->save($data_account);

            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function sendEmailInfoRemind($info_full_name = null, $info_email = null) {
        $this->layout = false;
        $this->autoRender = false;

        $date_now = date("d/m/Y");
        $info_subject = "Virtual Assistant 101 - Hoàn tất thanh toán";
        $info_content = '
            <div style="width: 720px; margin: 0 auto; overflow: hidden">
                <div
                style="
                    width: 700px;
                    margin: 0 auto;
                    overflow: hidden;
                    background: #ececec;
                "
                >
                <div
                    style="
                    overflow: hidden;
                    width: 100%;
                    margin-bottom: 20px;
                    background-color: #ec1c24;
                    color: #ffffff;
                    line-height: 40px;
                    "
                >
                    <ul style="list-style: none; margin: 0; padding: 0 20px">
                    <li style="float: left; margin: 0">
                        <span> Ngày: ' . $date_now . ' </span>
                    </li>
        
                    <li style="float: right; margin: 0">
                        <span> Hotline: 0347758897 </span>
                    </li>
                    </ul>
                </div>
        
                <div style="overflow: hidden; width: 100%">
                    <ul style="list-style: none; margin: 0; padding: 0">
                    <li
                        style="
                        float: left;
                        width: 180px;
                        margin: 0;
                        padding: 0px 0 0px 20px;
                        "
                    >
                        <img src="https://ykhoa.daca.vn/templates/app01/assets/img/logo-meduc.jpg" style="height: 50px;width: auto;mix-blend-mode: multiply;">
                    </li>
        
                    <li
                        style="
                        float: right;
                        width: 480px;
                        margin: 0;
                        padding: 0px 20px 0px 0px;
                        text-align: right;
                        font-size: 14px;
                        line-height: 20px;
                        "
                    >
                        <p style="margin: 0">
                        <strong style="text-transform: uppercase"> Hazel Mai </strong>
                        </p>
        
                        <p style="margin: 0"></p>
                    </li>
                    </ul>
                </div>
        
                <div style="overflow: hidden; padding: 20px">
                    <div
                    style="
                        overflow: hidden;
                        background: #fff;
                        padding: 20px;
                        border-radius: 5px;
                    "
                    >
                    <div style="margin-bottom: 20px">
                        <strong> Xin chào ' . $info_full_name . '! </strong>
                    </div>
        
                    <div style="margin-bottom: 20px">
                        Virtual Assistant 101 đã nhận được đăng ký của bạn, tuy nhiên, tụi mình vẫn chưa nhận được thanh toán học phí. Bạn hãy hoàn tất thanh toán theo các cách dưới đây để tụi mình kích hoạt tài khoản học cho bạn nhé:
                    </div>
        
                    <div style="margin-bottom: 10px">
                        <i><strong>Cách 1:</strong> Chuyển khoản ngân hàng</i>
                    </div>
                    <div style="margin-bottom: 10px">
                        <i>Ngân hàng: VP Bank</i>
                    </div>
                    <div style="margin-bottom: 10px">
                        <i>STK: 154462783</i>
                    </div>
                    <div style="margin-bottom: 20px">
                        <i>Chủ TK: Nguyễn Thị Thanh Mai</i>
                    </div>
                    <div style="margin-bottom: 20px">
                        <i><strong>Cách 2:</strong> Momo 0347758897</i>
                    </div>
                    <div style="margin-bottom: 20px">
                        <strong><i>Nội dung: VA101 + Họ Tên + Số điện thoại của bạn</i></strong>
                    </div>
        
                    <div style="margin-bottom: 20px">
                        Nếu bạn có bất kỳ thắc mắc nào về khoá học, đừng ngần ngại nhắn tin cho Hazel Mai qua <a href="https://www.facebook.com/hazelmainguyen" target="_blank">Facebook này</a> nhé.
                    </div>
        
                    <div style="margin-bottom: 10px">
                        Tụi mình rất vui được chào đón bạn đến với khoá học!
                    </div>
                    </div>
                </div>
        
                <div
                    style="
                    overflow: hidden;
                    width: 100%;
                    background-color: #ec1c24;
                    color: #ffffff;
                    line-height: 40px;
                    text-align: center;
                    "
                >
                    <span>
                    © Copyright 2022 | Virtual Assistant 101 | Hazel Mai | All Rights
                    Reserved
                    </span>
                    <div class="yj6qo"></div>
                    <div class="adL"></div>
                </div>
                <div class="adL"></div>
                </div>
                <div class="adL"></div>
            </div>
        ';


        $from_email = 'khoahocvirtualassistant101@gmail.com';
        $password = 'suttsvaklynqccdk';
        TransportFactory::setConfig('gmail', [
            'host' => 'ssl://smtp.gmail.com',
            'port' => 465,
            'username' => $from_email,
            'password' => $password,
            'className' => 'Smtp'
        ]);

        try{
            $mailer = new Mailer();
            $mailer->setTransport('gmail');
            $mailer->setTo($info_email);
            $mailer->setFrom($from_email, 'Virtualassistant101.vn');
            $mailer->setSubject($info_subject);
            $mailer->setEmailFormat('html');
            $mailer->deliver($info_content);
        } catch (Exception $e) {
            $this->responseJson([MESSAGE => __d('admin', 'gui_yeu_cau_khong_thanh_cong')]);
        }
    }

    public function sendEmailRemind() {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();

        // Send Email
        $this->sendEmailInfoRemind($data['full_name'], $data['email']);
        // End Send Email

        // Update Remind
        $id = !empty($data['id']) ? $data['id'] : [];
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        // Update Order
        if(!empty($data['order_id'])) {
            $order_table = TableRegistry::get('Orders');

            $conn2 = ConnectionManager::get('default');
            try{
                $conn2->begin();
                $order_info = $order_table->find()->where(['Orders.id' => $data['order_id']])->first();
                if (empty($order_info)) {
                    $this->responseJson([MESSAGE => "Không lấy được thông tin đơn hàng."]);
                }
                $order = $order_table->patchEntity($order_info, [
                    'id' => $data['order_id'], 
                    'reminded' => 1
                ], ['validate' => false]);
                $reminded_order = $order_table->save($order);
                if (empty($reminded_order)){
                    throw new Exception();
                }
    
                $conn2->commit();
    
            }catch (Exception $e) {
                $conn2->rollback();
                $this->responseJson([MESSAGE => $e->getMessage()]);  
            }
        }

        // Update Customer
        $customers_table = TableRegistry::get('Customers');

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            $customer_info = $customers_table->find()->where(['Customers.id' => $id])->first();
            if (empty($customer_info)) {
                $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_khach_hang')]);
            }
            $customer = $customers_table->patchEntity($customer_info, [
                'id' => $id, 
                'reminded' => 1
            ], ['validate' => false]);
            $reminded_customer = $customers_table->save($customer);
            if (empty($reminded_customer)){
                throw new Exception();
            }

            $conn->commit();

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
        // End Update Remind

        $this->responseJson([CODE => SUCCESS, MESSAGE => 'Gửi thành công!']);
    }

    public function addAccount($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();    

        if (!$this->getRequest()->is('post') || empty($data) || empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        if(empty($data['username'])) {
            $this->responseJson([MESSAGE => __d('template', 'vui_long_nhap_tai_khoan_dang_ky')]);
        }

        if(empty($data['password'])) {
            $this->responseJson([MESSAGE => __d('template', 'vui_long_nhap_mat_khau')]);
        }
        $table = TableRegistry::get('CustomersAccount');

        $username_exist = $table->checkExistUsername($data['username']);
        if($username_exist){
            $this->responseJson([MESSAGE => __d('template', 'tai_khoan_da_duoc_dang_ky')]);
        }

        $data_save = [
            'customer_id' => $id,
            'username' => !empty($data['username']) ? trim(strip_tags($data['username'])) : null,
            'password' => !empty($data['password']) ? Security::hash($data['password'], 'md5', false) : null
        ];

        $customer = $table->newEntity($data_save);

        $this->sendInfoAccount($data['full_name'], $data['email'], $data['username'], $data['password']);

        $utilities = $this->loadComponent('Utilities');

        // show error validation in model
        if($customer->hasErrors()){
            $list_errors = $utilities->errorModel($customer->getErrors());
            
            $this->responseJson([
                MESSAGE => !empty($list_errors[0]) ? $list_errors[0] : null,
                DATA => $list_errors
            ]);             
        }

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $table->save($customer);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        } 
    }

    public function accountStatus($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();    

        if (!$this->getRequest()->is('post') || empty($data) || empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $account_status = isset($data['account_status']) ? intval($data['account_status']) : 0;

        $account_table = TableRegistry::get('CustomersAccount');        
        $account_info = $account_table->find()->where(['customer_id' => $id])->first();
        if (empty($account_info)) {
            $this->responseJson([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }
        
        $data_account = $account_table->patchEntity($account_info, [
            'status' => $account_status
        ]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $account_table->save($data_account);

            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function statusLearn($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();

        if (!$this->getRequest()->is('post') || empty($data) || empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $status_learn = !empty($data['status_learn']) ? $data['status_learn'] : null;

        $account_table = TableRegistry::get('CustomersAccount');        
        $account_info = $account_table->find()->where(['customer_id' => $id])->first();
        if (empty($account_info)) {
            $this->responseJson([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }
        
        $data_account = $account_table->patchEntity($account_info, [
            'status_learn' => $status_learn
        ]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $account_table->save($data_account);

            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }
}