<?php

namespace App\Controller;

use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;
use Cake\Http\Exception\NotFoundException;
use Cake\Http\Response;

class ContactController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

	public function sendInfo() 
	{
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('template', 'phuong_thuc_khong_hop_le')]);
        }

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];    
        if(empty($data)){
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        // check recaptcha
        $token = !empty($data[TOKEN_RECAPTCHA]) ? $data[TOKEN_RECAPTCHA] : null;
        $check_recaptcha = $this->loadComponent('ReCaptcha')->check($token);
        if($check_recaptcha[CODE] != SUCCESS){
            $this->responseJson([MESSAGE => $check_recaptcha[MESSAGE]]);
        }

        $form_code = !empty($data['form_code']) ? $data['form_code'] : null;
        if(empty($form_code)){
            $this->responseJson([MESSAGE => __d('template', 'vui_long_cau_hinh_ma_form')]);
        }

        $table = TableRegistry::get('Contacts');
        
        $form_info = TableRegistry::get('ContactsForm')->find()->where(['code' => $form_code, 'deleted' => 0])->first();
        if(empty($form_info)){
            $this->responseJson([MESSAGE => __d('template', 'ma_form_duoc_cau_hinh_khong_ton_tai_tren_he_thong')]);
        }

        $fields = !empty($form_info['fields']) ? json_decode($form_info['fields'], true) : [];
        if(empty($fields) || !is_array($fields)){
            $this->responseJson([MESSAGE => __d('template', 'vui_long_cau_hinh_cac_truong_cua_form')]);
        }

        $data_value = [];
        foreach ($fields as $key => $field) {
            $code = !empty($field['code']) ? $field['code'] : null;
            if(empty($code)) continue;
            $data_value[$code] = !empty($data[$code]) ? $data[$code] : null;
        }

        if($form_code == "61CQ0U3H9I") {
            $items = json_decode((string) ($data_value['cartProducts'] ?? ''), true);
            try {
                $data_products = \App\Lib\BookCheckout::quote(is_array($items) ? $items : []);
            } catch (\InvalidArgumentException $e) {
                $this->responseJson([MESSAGE => $e->getMessage()]);
                return;
            }
            $totalPrice = array_sum(array_column($data_products, 'total'));
            $totalQuantity = array_sum(array_column($data_products, 'quantity'));
            if (isset($data['cartTotal']) && abs((float) $data['cartTotal'] - $totalPrice) > 0.5) {
                $this->responseJson([MESSAGE => 'Giá sản phẩm vừa thay đổi. Vui lòng tải lại trang để kiểm tra số tiền trước khi đặt hàng.']);
                return;
            }
            if (!in_array($data_value['payment'] ?? '', ['bank', 'cod'], true)
                || !preg_match('/^MEDUC[0-9]{6,}$/', (string) ($data_value['cartId'] ?? ''))
                || empty(trim((string) ($data_value['full_name'] ?? '')))
                || !filter_var($data_value['email'] ?? '', FILTER_VALIDATE_EMAIL)
                || !preg_match('/^(?:0|\\+84)[0-9]{9,10}$/', preg_replace('/[ .-]/', '', (string) ($data_value['phone'] ?? '')))
                || empty(trim((string) ($data_value['address'] ?? '')))) {
                $this->responseJson([MESSAGE => 'Vui lòng kiểm tra thông tin nhận hàng và phương thức thanh toán.']);
                return;
            }

            $data_value["cartProducts"] = json_encode($data_products);
            $data_value["totalPrice"] = $totalPrice;
            $data_value["totalQuantity"] = $totalQuantity;
            
            if (isset($data_value["affiliateCode"]) && $data_value["affiliateCode"] !== '') {
                $affiliate_percent = null;

                // Tìm khách hàng có mã affiliateCode
                $customer = TableRegistry::get('Customers')
                    ->find()
                    ->where(['code' => $data_value["affiliateCode"]])
                    ->first();
        
                if ($customer && !empty($customer->affiliate_percent)) {
                    $affiliate_percent = (float)$customer->affiliate_percent;
                } else {
                    // Nếu không có thì lấy từ settings
                    $settings = TableRegistry::get('Settings')->getSettingWebsite();
                    $affiliate_percent = isset($settings['website_info']['vi_affiliate_percent']) ? (float)$settings['website_info']['vi_affiliate_percent'] : null;
                }
                
                if ($affiliate_percent !== null) {
                    $data_value["affiliatePercent"] = $affiliate_percent;
        
                    // Tính tiền hoa hồng
                    $total_price = (float)($data_value["totalPrice"] ?? 0);
                    $affiliate_amount = round($total_price * $affiliate_percent / 100);
        
                    $data_value["affiliateAmount"] = $affiliate_amount;
                    $data_value["affiliatePaidStatus"] = 'unpaid';
                }
            }
            
            // Trạng thái đơn hàng mặc định
            $data_value["orderStatus"] = 'initial';
        }

        $data_save = [
            'form_id' => !empty($form_info['id']) ? $form_info['id'] : null,
            'value' => !empty($data_value) ? json_encode($data_value) : null,
            'status' => 2,
            'search_unicode' => strtolower($this->loadComponent('Utilities')->formatSearchUnicode($data_value))
        ];

        $contact = $table->newEntity($data_save);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
                        
            $save = $table->save($contact);

            if (empty($save->id)){
                throw new Exception();
            }

            if(!empty($save) && !empty($form_info['send_email']) && !empty($form_info['template_email_code'])) {
                $settings = TableRegistry::get('Settings')->getSettingWebsite();
                $email_management = !empty($settings['email']['email_administrator']) ? $settings['email']['email_administrator'] : null;
                $params_email = [
                    'to_email' => $email_management,
                    'code' => $form_info['template_email_code'],
                    'id_record' => $save['id']
                ];
  
                $send = $this->loadComponent('Email')->send($params_email);
                
                if($form_code == "61CQ0U3H9I") {
                    // Gửi email cho khách hàng
                    $customer_email = !empty($data_value['email']) ? $data_value['email'] : null;
                    if (!empty($customer_email)) {
                        $params_email_customer = [
                            'to_email' => $customer_email,
                            'code' => $form_info['template_email_code'],
                            'id_record' => $save['id']
                        ];
                        $this->loadComponent('Email')->send($params_email_customer);
                    }
                }
            }
            
            $conn->commit();

            if ($form_code === '61CQ0U3H9I') {
                // The confirmation page reads only this browser session's successfully saved order.
                $this->request->getSession()->write('MeducBookOrder', $data_value);
            }
            $this->loadComponent('SendMessage')->send(CONTACT, $save['id']);
            
            $this->responseJson([
                CODE => SUCCESS, 
                MESSAGE => __d('template', 'gui_thong_tin_lien_he_thanh_cong')
            ]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }
    
    public function getInfo()
    {
        $cartId = $this->request->getQuery('cartId');

        if (!$cartId) {
            throw new NotFoundException(__('Cart ID không hợp lệ'));
        }

        // Lấy instance của bảng contacts qua TableRegistry
        $contactsTable = TableRegistry::getTableLocator()->get('Contacts');

        // Tìm bản ghi có cartId trong trường value
        $contact = $contactsTable->find()
            ->where(["value LIKE" => '%\"cartId\":\"' . $cartId . '\"%'])
            ->first();

        if (!$contact) {
            throw new NotFoundException(__('Không tìm thấy đơn hàng'));
        }

        // Parse JSON trong cột value
        $data = json_decode($contact->value, true);

        return $this->response->withType('application/json')
                              ->withStringBody(json_encode($data));
    }
}