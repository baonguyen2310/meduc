<?php
declare(strict_types=1);

namespace App\Controller;

use Cake\Event\EventInterface;
use Cake\ORM\TableRegistry;
use Cake\Utility\Security;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;
use Cake\Core\Configure;
use Google;
use Cake\Http\Client;

class MemberController extends AppController 
{
    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
        $action_check = [
            'dashboard', 
            'address',
            'saveAddress',
            'profile', 
            'saveProfile', 
            'isDefault', 
            'deleteAddress', 
            'changePassword',
            'ajaxChangePassword',
            'order',
            'orderDetail',
            'cancelOrder',
            'uploadAvatar',
            'deleteAvatar',
            'attendance',
            'attendanceTick',
            'promotion',
            'changePhone',
            'changeEmail',
            'ajaxChangePhone',
            'ajaxChangeEmail',
            'listBank',
            'deleteBank',
            'saveBank'
        ];

        $session = $this->request->getSession();  
        $member = $session->read(MEMBER);

        if(in_array($this->request->getParam('action'), $action_check) && !empty($member['customer_id'])) {
            if($this->loadComponent('Member')->memberDoesntExistLogout($member['customer_id'])){
                if($this->request->is('ajax')){
                    $this->responseJson([
                        STATUS => 403,
                        MESSAGE => __d('template', 'het_phien_lam_viec_vui_long_dang_nhap_lai_tai_khoan')
                    ]);
                }else{
                    return $this->redirect('/member/login?redirect=' . urlencode($this->request->getPath()), 303);
                }
            }
        }

        if (in_array($this->request->getParam('action'), $action_check) && empty($member['customer_id'])){
            if($this->request->is('ajax')){
                $this->responseJson([
                    STATUS => 403,
                    MESSAGE => __d('template', 'het_phien_lam_viec_vui_long_dang_nhap_lai_tai_khoan')
                ]);
            }else{
                return $this->redirect('/member/login?redirect=' . urlencode($this->request->getPath()), 303);
            }
        }

    }

	public function login() 
	{
        $request = $this->request;
        $member_info = $request->getSession()->read(MEMBER);
        $redirect = $request->getQuery('redirect');
        if(!empty($member_info)){
            $this->redirect(!empty($redirect) ? $redirect : 'member/dashboard');
        }

        $this->set('redirect', $redirect);
        $this->set('title_for_layout', __d('template', 'dang_nhap'));
        $this->render('login');
    }

    public function ajaxLogin() 
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        
        $result = $this->loadComponent('Member')->login($data);
        $this->responseJson($result);
    }

    public function socialLogin()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $result = $this->loadComponent('Member')->socialLogin($data);
        $this->responseJson($result);
    }

    public function register() 
    {
        $this->set('title_for_layout', __d('template', 'dang_ky_tai_khoan'));
        $this->render('register');
    }

    public function ajaxRegister()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $result = $this->loadComponent('Member')->register($data);
        $this->responseJson($result);
    }

    public function dashboard() 
    {
        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $customers_table = TableRegistry::get('Customers');

        $member_info = $customers_table->getDetailCustomer($customer_id, [
            'get_default_address' => true
        ]);
        $member_info = $customers_table->formatDataCustomerDetail($member_info);

        $orders = TableRegistry::get('Orders')->queryListOrders([
            FILTER => [
                TYPE => ORDER,
                'customer_id' => $customer_id
            ]
        ])->limit(5)->toList();

        $this->set('order', $orders);
        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'quan_ly_tai_khoan'));
    }

    public function address() 
    {
        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        $table = TableRegistry::get('Customers');

        $member_info = $table->getDetailCustomer($customer_id, [
            'get_list_address' => true
        ]);
        $member_info = $table->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'so_dia_chi'));
    }

    public function saveAddress()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $result = $this->loadComponent('Member')->saveAddress($data);
        $this->responseJson($result);
    }

    public function profile() 
    {
        $member = $this->request->getSession()->read(MEMBER);

        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $customers_table = TableRegistry::get('Customers');

        $member_info = $customers_table->getDetailCustomer($customer_id, [
            'get_list_address' => true
        ]);
        $member_info = $customers_table->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'thong_tin_ca_nhan'));
    }

    public function saveProfile()
    {
        $this->layout = false;
        $this->autoRender = false;

        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        $data = $this->getRequest()->getData();
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $result = $this->loadComponent('Member')->updateProfile($data);
        $this->responseJson($result);
    }

    public function isDefault()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();        
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $result = $this->loadComponent('Member')->setDefaultAddress($data);
        $this->responseJson($result);
    }

    public function deleteAddress()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();        
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $result = $this->loadComponent('Member')->deleteAddress($data);
        $this->responseJson($result);
    }

    public function changePassword() 
    {
        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $member_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, [
            'get_default_address' => true
        ]);
        $member_info = TableRegistry::get('Customers')->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'thay_doi_mat_khau'));
    }

    public function ajaxChangePassword() 
    {
        $this->layout = false;
        $this->autoRender = false;
        
        $data = $this->getRequest()->getData();

        $result = $this->loadComponent('Member')->changePassword($data);
        $this->responseJson($result);
    }

    public function order() 
    {
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $result = $this->loadComponent('Member')->listOrders($data);
        $data_result = !empty($result[DATA]) ? $result[DATA] : [];

        $order = !empty($data_result['orders']) ? $data_result['orders'] : [];
        $pagination = !empty($data_result[PAGINATION]) ? $data_result[PAGINATION] : [];

        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $member_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, [
            'get_default_address' => true
        ]);
        $member_info = TableRegistry::get('Customers')->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('order', $order);
        $this->set('pagination', $pagination);
        $this->set('title_for_layout', __d('template', 'don_hang_cua_ban'));

        if($this->request->is('ajax')){
            $this->viewBuilder()->enableAutoLayout(false);
            $this->render('list_order_element');
        }else{
            $this->render('list_order');
        }
    }

    public function orderDetail($code = null)
    {
        $member = $this->request->getSession()->read(MEMBER);        
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        $customers_table = TableRegistry::get('Customers');
        $orders_table = TableRegistry::get('Orders');

        $member = $customers_table->getDetailCustomer($customer_id);
        $member_info = $customers_table->formatDataCustomerDetail($member);

        $check_order = $orders_table->find()->contain(['OrdersContact'])->where([
            'OrdersContact.customer_id' => $customer_id,
            'Orders.code' => $code,
            'Orders.deleted' => 0
        ])->select(['Orders.id'])->first();

        $order_id = !empty($check_order['id']) ? intval($check_order['id']) : null;
        if(empty($order_id)){
            return $this->showErrorPage([
                MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_don_hang'),
                'title' => __d('template', 'thong_tin_don_hang')
            ]);
        }

        $order = $orders_table->getDetailOrder($order_id, [
            'get_items' => true,
            'get_contact' => true
        ]);
        $order_info = $orders_table->formatDataOrderDetail($order, LANGUAGE);

        if(empty($order_info)){
            return $this->showErrorPage([
                MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_don_hang'),
                'title' => __d('template', 'thong_tin_don_hang')
            ]);
        }

        $this->set('member', $member_info);
        $this->set('order', $order_info);
        $this->set('title_for_layout', __d('template', 'thong_tin_don_hang'));
    }

    public function cancelOrder() 
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $result = $this->loadComponent('Member')->cancelOrder($data);
        $this->responseJson($result);
    }

    public function forgotPassword()
    {
        $this->set('title_for_layout', __d('template', 'quen_mat_khau'));
        $this->render('forgot_password');
    }

    public function ajaxForgotPassword()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $result = $this->loadComponent('Member')->forgotPassword($data);
        $this->responseJson($result);
    }

    public function verifyForgotPassword()
    {
        $this->set('title_for_layout', __d('template', 'quen_mat_khau'));
        $this->render('verify_forgot_password');
    }

    public function ajaxVerifyForgotPassword()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }

        $result = $this->loadComponent('Member')->verifyForgotPassword($data);
        $this->responseJson($result);    
    }

    public function logout() 
    {
        $this->layout = false;
        $this->autoRender = false;

        $this->loadComponent('Member')->logout();
        return $this->redirect('/');
    }

    public function reloadMiniMember()
    {
        $this->viewBuilder()->enableAutoLayout(false);
        $this->render('mini');
    }

    public function uploadAvatar()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }
        
        $file = !empty($_FILES['file']) ? $_FILES['file'] : [];
        if (empty($file)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
 
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        $data_upload = [
            'path' => !empty($data['path']) ? $data['path'] : CUSTOMER,
            'file' => $file
        ];
        $result = $this->loadComponent('Member')->updateAvatar($data_upload);
        $this->responseJson($result);        
    }

    public function deleteAvatar()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }

        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        if(empty($customer_id)){
            $this->responseJson([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $customers_table = TableRegistry::get('Customers');

        $customers_info = $customers_table->find()->where(['id' => $customer_id])->first();
        if(empty($customers_info)){
            $this->responseJson([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $customer = $customers_table->patchEntity($customers_info, [
            'id' => $customer_id,
            'avatar' => null
        ], ['validate' => false]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $save = $customers_table->save($customer);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }

        $this->responseJson([
            CODE => SUCCESS, 
            MESSAGE => __d('template', 'xoa_anh_dai_dien_thanh_cong')
        ]);
    }

    public function verifyEmail() 
    {
        $this->set('title_for_layout', __d('template', 'kich_hoat_tai_khoan'));
        $this->render('verify_email');
    }

    public function ajaxVerifyEmail()
    {
        $this->layout = false;
        $this->autoRender = false;
        $result = $this->loadComponent('Member')->verifyAccount($this->getRequest()->getData());
        $this->responseJson($result);
    }

    public function success()
    {
        $this->set('title_for_layout', __d('template', 'dang_ky_thanh_cong'));
        $this->render('success');
    }
    
    public function resendVerifyCode()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $result = $this->loadComponent('Member')->resendVerifyCode($data);
        $this->responseJson($result);
    }

    public function attendance()
    {
        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $member_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, [
            'get_default_address' => true
        ]);
        $member_info = TableRegistry::get('Customers')->formatDataCustomerDetail($member_info);

        $attendance = $this->loadComponent('CustomersPointFrontend')->processAttendance($customer_id);
        $customer_point = TableRegistry::get('CustomersPoint')->getInfoCustomerPoint($customer_id);
        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $config_point = !empty($settings['point']) ? $settings['point'] : [];
   
        $this->set('member', $member_info);
        $this->set('customer_point', $customer_point);
        $this->set('config_point', $config_point);
        $this->set('attendance', $attendance);
        
        $this->set('title_for_layout', __d('template', 'diem_danh_tich_diem'));
    }

    public function attendanceTick()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->request->getData();
        if (!$this->getRequest()->is('post') && empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }

        $result = $this->loadComponent('CustomersPointFrontend')->attendanceTick($data);
        $this->responseJson($result);
    }

    public function promotion()
    {
        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $member_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, [
            'get_default_address' => true
        ]);
        $member_info = TableRegistry::get('Customers')->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'phieu_giam_gia'));
        $this->render('promotion');
    }

    public function changePhone() 
    {
        $member = $this->request->getSession()->read(MEMBER);

        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $customers_table = TableRegistry::get('Customers');

        $member_info = $customers_table->getDetailCustomer($customer_id, [
            'get_list_address' => true
        ]);
        $member_info = $customers_table->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'thay_doi_so_dien_thoai'));
    }

    public function ajaxChangePhone()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $result = $this->loadComponent('Member')->changeImportantInfo($data);
        $this->responseJson($result);
    }

    public function changeEmail() 
    {
        $member = $this->request->getSession()->read(MEMBER);

        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $customers_table = TableRegistry::get('Customers');

        $member_info = $customers_table->getDetailCustomer($customer_id, [
            'get_list_address' => true
        ]);
        $member_info = $customers_table->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('title_for_layout', __d('template', 'thay_doi_email'));
    }

    public function ajaxChangeEmail()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $result = $this->loadComponent('Member')->changeImportantInfo($data);
        $this->responseJson($result);
    }

    public function getVerifyCode() 
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $result = $this->loadComponent('Member')->getVerifyCode($data);
        $this->responseJson($result);
    }

    public function listBank() 
    {
        $affiliate = $this->loadComponent('Member')->listBankOfPartner();
        $affiliate = !empty($affiliate[DATA]) ? $affiliate[DATA] : [];

        $member = $this->request->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        $member_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, [
            'get_default_address' => true
        ]);
        $member_info = TableRegistry::get('Customers')->formatDataCustomerDetail($member_info);

        $this->set('member', $member_info);
        $this->set('affiliate', $affiliate);
        $this->set('title_for_layout', __d('template', 'tai_khoan_ngan_hang'));
    }

    public function deleteBank()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $result = $this->loadComponent('Member')->deleteBank($data);
        $this->responseJson($result);
    }

    public function saveBank()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $result = $this->loadComponent('Member')->saveBank($data);
        $this->responseJson($result);
    }

    public function oauthGoogle()
    {
        return $this->redirect('/member/login');
    }

    public function oauthFacebook()
    {
        return $this->redirect('/member/login');
    }

}