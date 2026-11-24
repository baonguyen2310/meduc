<?php

namespace App\Controller;

use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;
use Cake\Http\Exception\NotFoundException;
use Cake\Http\Response;
use App\Service\Vouchers;

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

        $shop = ($data['form_code'] ?? '') === Vouchers::SHOP_FORM;
        if ($shop) {
            $member = $this->request->getSession()->read(MEMBER) ?: [];
            $customer = \App\Service\CheckoutContact::customer((int)($member['id'] ?? 0));
            if (!$customer) {
                return $this->response->withStatus(401)->withType('application/json')->withHeader('Cache-Control','private, no-store')
                    ->withStringBody(json_encode([CODE=>ERROR,MESSAGE=>'Vui lòng đăng nhập để tiếp tục thanh toán.'],JSON_UNESCAPED_UNICODE));
            }
            try {
                $data = array_merge($data, \App\Service\CheckoutContact::validate($data, $customer, true));
            } catch (\InvalidArgumentException $e) {
                $this->responseJson([MESSAGE=>$e->getMessage()]);
                return;
            }
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

        if ($shop) {
            $items = json_decode((string) ($data_value['cartProducts'] ?? ''), true);
            try {
                $data_products = \App\Lib\BookCheckout::quote(is_array($items) ? $items : []);
            } catch (\InvalidArgumentException $e) {
                $this->responseJson([MESSAGE => $e->getMessage()]);
                return;
            }
            $totalPrice = array_sum(array_column($data_products, 'total'));
            $totalQuantity = array_sum(array_column($data_products, 'quantity'));
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
            
            $data_value['orderStatus'] = 'initial';
            $data_value['customer_id'] = (int)$customer['id'];
            $data_value['voucher_buyer_id'] = (int)$customer['id'];
        }

        $conn = ConnectionManager::get('default');
        try {
            $conn->begin();
            $voucher = null;
            if ($shop) {
                $voucherInput = Vouchers::checkoutInput($data);
                if ($voucherInput) {
                    $voucher = Vouchers::confirm($customer, 'shop', (int)round($totalPrice), $voucherInput);
                    if ($voucher['discounts']) {
                        $data_value['totalPrice'] = $voucher['total'];
                        $data_value['voucher_base'] = $voucher['base'];
                        $data_value['voucher_discounts'] = $voucher['discounts'];
                    }
                }
                if (isset($data['cartTotal']) && abs((float)$data['cartTotal'] - $data_value['totalPrice']) > 0.5) {
                    throw new \InvalidArgumentException('Giá sản phẩm vừa thay đổi. Vui lòng kiểm tra số tiền trước khi đặt hàng.');
                }

                $partnerCode = $voucher['partner']['code'] ?? ($data_value['affiliateCode'] ?? '');
                unset($data_value['affiliateCode'], $data_value['affiliatePercent'], $data_value['affiliateAmount'], $data_value['affiliatePaidStatus']);
                if (is_string($partnerCode)) {
                    $data_value += Vouchers::affiliateTerms($partnerCode, (int)$customer['id'], (int)$data_value['totalPrice']);
                }
            }

            $contact = $table->newEntity([
                'form_id' => !empty($form_info['id']) ? $form_info['id'] : null,
                'value' => !empty($data_value) ? json_encode($data_value) : null,
                'status' => 2,
                'search_unicode' => strtolower($this->loadComponent('Utilities')->formatSearchUnicode(array_filter($data_value, 'is_scalar'))),
            ]);
            $save = $table->save($contact);
            if (empty($save->id)) {
                throw new Exception();
            }
            if ($shop && !empty($voucher['discounts'])) {
                Vouchers::recordUses('shop', (int)$save->id, (int)$customer['id'], $voucher['discounts']);
            }

            if (!$shop && !empty($form_info['send_email']) && !empty($form_info['template_email_code'])) {
                $settings = TableRegistry::get('Settings')->getSettingWebsite();
                $email_management = !empty($settings['email']['email_administrator']) ? $settings['email']['email_administrator'] : null;
                $params_email = [
                    'to_email' => $email_management,
                    'code' => $form_info['template_email_code'],
                    'id_record' => $save['id']
                ];
  
                $this->loadComponent('Email')->send($params_email);
            }
            $conn->commit();
        } catch (\InvalidArgumentException $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
            return;
        } catch (\Throwable $e) {
            if ($conn->inTransaction()) {
                $conn->rollback();
            }
            if ($shop) {
                $this->log('Shop checkout: ' . $e->getMessage(), 'error');
            }
            $this->responseJson([MESSAGE => $shop ? 'Chưa tạo được đơn hàng. Vui lòng thử lại.' : $e->getMessage()]);
            return;
        }
        if ($shop) {
            $this->request->getSession()->write('MeducBookOrder', $data_value);
        }
        try {
            if ($shop) {
                \App\Service\CommerceNotifications::book((int)$save['id'], function ($message) {
                    return $this->loadComponent('Email')->sendEmail($message);
                }, $this->request->host());
            }
            $this->loadComponent('SendMessage')->send(CONTACT, $save['id']);
        } catch (\Throwable $error) {
            $this->log('Contact notification: ' . $error->getMessage(), 'error');
        }
        $this->responseJson([CODE => SUCCESS, MESSAGE => __d('template', 'gui_thong_tin_lien_he_thanh_cong')]);
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
