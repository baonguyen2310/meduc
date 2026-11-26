<?php

namespace App\Controller;

use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;
use Cake\Http\Exception\NotFoundException;
use Cake\Http\Response;
use App\Service\CheckoutContact;
use App\Service\CommerceNotifications;
use App\Service\ShopOrders;
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
            $customer = CheckoutContact::customer((int)($member['id'] ?? 0));
            if (!$customer) {
                return $this->response->withStatus(401)->withType('application/json')->withHeader('Cache-Control','private, no-store')
                    ->withStringBody(json_encode([CODE=>ERROR,MESSAGE=>'Vui lòng đăng nhập để tiếp tục thanh toán.'],JSON_UNESCAPED_UNICODE));
            }
        }

        // check recaptcha
        $token = !empty($data[TOKEN_RECAPTCHA]) ? $data[TOKEN_RECAPTCHA] : null;
        $check_recaptcha = $this->loadComponent('ReCaptcha')->check($token);
        if($check_recaptcha[CODE] != SUCCESS){
            $this->responseJson([MESSAGE => $check_recaptcha[MESSAGE]]);
        }

        if ($shop) {
            $this->placeShopOrder($customer, $data);
            return;
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

        $conn = ConnectionManager::get('default');
        try {
            $conn->begin();

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
            if (!empty($form_info['send_email']) && !empty($form_info['template_email_code'])) {
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
            $this->responseJson([MESSAGE => $e->getMessage()]);
            return;
        }
        try {
            $this->loadComponent('SendMessage')->send(CONTACT, $save['id']);
        } catch (\Throwable $error) {
            $this->log('Contact notification: ' . $error->getMessage(), 'error');
        }
        $this->responseJson([CODE => SUCCESS, MESSAGE => __d('template', 'gui_thong_tin_lien_he_thanh_cong')]);
    }
    
    private function placeShopOrder(array $customer, array $data): void
    {
        try {
            $receipt = ShopOrders::place(
                $customer,
                $data,
                function ($payload) { return $this->loadComponent('Admin.Order')->saveOrder($payload); },
                function ($payment) { return $this->loadComponent('Admin.Payment')->savePayment($payment); }
            );
        } catch (\InvalidArgumentException $error) {
            $this->responseJson([MESSAGE => $error->getMessage()]);
            return;
        } catch (\Throwable $error) {
            $this->log('Shop checkout: ' . $error->getMessage(), 'error');
            $this->responseJson([MESSAGE => 'Chưa tạo được đơn hàng. Vui lòng thử lại.']);
            return;
        }

        $this->request->getSession()->write('MeducBookOrder', $receipt);
        CommerceNotifications::shop($receipt, function ($message) {
            return $this->loadComponent('Email')->sendEmail($message);
        }, $this->request->host());
        $this->responseJson([CODE => SUCCESS, MESSAGE => 'MedUC đã nhận đơn hàng.']);
    }

    public function getInfo()
    {
        $session = $this->request->getSession();
        $buyer = (int)($session->read(MEMBER)['id'] ?? 0);
        $reference = $this->request->getQuery('cartId');
        $data = is_string($reference) ? ShopOrders::byReference($reference, $buyer) : [];
        if (!$data && $buyer && is_string($reference)) {
            $old = $session->read('MeducBookOrder');
            if (is_array($old) && (int)($old['customer_id'] ?? 0) === $buyer && ($old['cartId'] ?? '') === $reference) {
                $data = $old;
            }
        }
        if (!$data) throw new NotFoundException(__('Không tìm thấy đơn hàng'));

        return $this->response->withType('application/json')->withHeader('Cache-Control', 'private, no-store')
                              ->withStringBody(json_encode($data));
    }
}
