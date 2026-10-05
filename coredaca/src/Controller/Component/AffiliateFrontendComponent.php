<?php

namespace App\Controller\Component;

use Cake\Controller\Component;
use Cake\Controller\ComponentRegistry;
use Cake\Core\Configure;
use Cake\ORM\TableRegistry;
use Cake\Datasource\ConnectionManager;
use Cake\Core\Exception\Exception;
use Cake\Utility\Hash;

class AffiliateFrontendComponent extends Component
{
    public $controller = null;
    public $components = ['System', 'Utilities', 'ReCaptcha', 'PaginatorExtend'];

    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->controller = $this->_registry->getController();
    }

    public function apply($data = null)
    {
        $session = $this->controller->getRequest()->getSession();
        $affiliate_code = !empty($data['affiliate_code']) ? $data['affiliate_code'] : null;
        $cart_info = $session->read(CART);
        if(empty($affiliate_code)){
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_ma_gioi_thieu')]);
        }
        
        if(empty($cart_info)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_gio_hang')]);

        $customers_info = TableRegistry::get('Customers')->find()->where([
            'is_partner_affiliate' => 1,
            'status' => 1,
            'deleted' => 0,
            'code' => $affiliate_code
        ])->select(['id'])->first();

        if(empty($customers_info)){
            return $this->System->getResponse([MESSAGE => __d('template', 'ma_gioi_thieu_khong_ton_tai')]);
        }

        $exist_coupon = !empty($session->read(COUPON)) ? true : false;
        $total_cart = !empty($cart_info['total']) ? floatval($cart_info['total']) : 0;

        // lấy % hoa hồng
        $profit_value = TableRegistry::get('Settings')->getValueCommissionDiscountForCustomer($exist_coupon);
        $profit_money = $total_cart * $profit_value / 100;

        $affiliate = [
            'affiliate_code' => $affiliate_code,
            'affiliate_discount_type' => PERCENT,
            'affiliate_discount_value' => !empty($profit_value) ? $profit_value : 0,
            'total_affiliate' => !empty($profit_money) ? $profit_money : 0,
        ];

        $session->write(AFFILIATE, $affiliate);

        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => __d('template', 'xac_minh_ma_gioi_thieu_thanh_cong'),
            DATA => $affiliate
        ]);
    }

    public function saveAffiliate()
    {
        $session = $this->controller->getRequest()->getSession();
        $affiliate_session = $session->read(AFFILIATE);
        if(empty($affiliate_session['affiliate_code'])) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_doi_tac')]);

        $partner_info = TableRegistry::get('Customers')->find()->where([
            'is_partner_affiliate' => 1,
            'status' => 1,
            'deleted' => 0,
            'code' => $affiliate_session['affiliate_code']

        ])->select(['id', 'level_partner_affiliate'])->first();

        $partner_id = !empty($partner_info['id']) ? intval($partner_info['id']) : null;
        if(empty($partner_id)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_doi_tac')]);

        // lấy thông tin đối tác trong bảng customer affiliate
        $customers_affiliate_table = TableRegistry::get('CustomersAffiliate');

        $customers_affiliate = $customers_affiliate_table->find()->where([
            'CustomersAffiliate.customer_id' => $partner_id
        ])->first();

        $number_referral = !empty($customers_affiliate['number_referral']) ? intval($customers_affiliate['number_referral']) : 0;
        $number_order_success = !empty($customers_affiliate['number_order_success']) ? intval($customers_affiliate['number_order_success']) : 0;
        $total_order_success = !empty($customers_affiliate['total_order_success']) ? floatval($customers_affiliate['total_order_success']) : 0;
        $number_order_failed = !empty($customers_affiliate['number_order_failed']) ? intval($customers_affiliate['number_order_failed']) : 0;
        $total_order_failed = !empty($customers_affiliate['total_order_failed']) ? floatval($customers_affiliate['total_order_failed']) : 0;
        $total_point = !empty($customers_affiliate['total_point']) ? intval($customers_affiliate['total_point']) : 0;

        $data_save = [
            'customer_id' => intval($partner_id),
            'number_referral' => intval($number_referral) + 1,
            'number_order_success' => intval($number_order_success),
            'total_order_success' => floatval($total_order_success),
            'number_order_failed' => intval($number_order_failed),
            'total_order_failed' => floatval($total_order_failed),
            'total_point' => intval($total_point)
        ];

        if(empty($customers_affiliate)){
            $entity_affiliate = $customers_affiliate_table->newEntity($data_save);
        }else{            
            $entity_affiliate = $customers_affiliate_table->patchEntity($customers_affiliate, $data_save);
        }

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            
            $save_affiliate = $customers_affiliate_table->save($entity_affiliate);
            if(empty($save_affiliate['id'])){
                return $this->System->getResponse([MESSAGE => __d('template', 'cap_nhat_khong_thanh_cong')]);
            }

            $conn->commit();

            return $this->System->getResponse([CODE => SUCCESS]);
        } catch (Exception $e) {
            $conn->rollback();
            return $this->System->getResponse([MESSAGE => __d('template', 'cap_nhat_khong_thanh_cong')]);
        }
    }

    public function saveAffiliateOrder($order_id = null, $total = null)
    {
        $session = $this->controller->getRequest()->getSession();
        $affiliate_session = $session->read(AFFILIATE);
        if(empty($affiliate_session['affiliate_code'])) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_doi_tac')]);

        $partner_info = TableRegistry::get('Customers')->find()->where([
            'is_partner_affiliate' => 1,
            'status' => 1,
            'deleted' => 0,
            'code' => $affiliate_session['affiliate_code']

        ])->select(['id', 'level_partner_affiliate'])->first();

        $partner_id = !empty($partner_info['id']) ? intval($partner_info['id']) : null;
        if(empty($partner_id)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_doi_tac')]);

        // lấy % hoa hồng
        $exist_coupon = !empty($session->read(COUPON)) ? true : false;
        $profit_value = TableRegistry::get('Settings')->getValueCommissionDiscountForPartner($partner_id, $exist_coupon);

        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $point_setting = !empty($settings['point']) ? $settings['point'] : [];
        $point_to_money = !empty($point_setting['point_to_money']) ? floatval($point_setting['point_to_money']) : 1;

        // làm tròn và tính số điểm hoa hồng
        $profit_point = round($total * $profit_value / 100 / $point_to_money);
        $profit_money = $profit_point * $point_to_money;

        $data_save = [
            'customer_id' => $partner_id,
            'order_id' => $order_id,
            'profit_value' => $profit_value,
            'profit_point' => $profit_point,
            'profit_money' => $profit_money
        ];

        $affiliate_order = TableRegistry::get('CustomersAffiliateOrder')->newEntity($data_save);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            
            $save_affiliate = TableRegistry::get('CustomersAffiliateOrder')->save($affiliate_order);
            if(empty($save_affiliate['id'])){
                return $this->System->getResponse([MESSAGE => __d('template', 'cap_nhat_khong_thanh_cong')]);
            }

            $conn->commit();

            return $this->System->getResponse([CODE => SUCCESS]);
        } catch (Exception $e) {
            $conn->rollback();
            return $this->System->getResponse([MESSAGE => __d('template', 'cap_nhat_khong_thanh_cong')]);
        }
    }

    public function registerAffiliate($data = [], $options = [])
    {
        // check recaptcha
        $api = !empty($options['api']) ? true : false;        
        if(!$api){
            $token = !empty($data[TOKEN_RECAPTCHA]) ? $data[TOKEN_RECAPTCHA] : null;
            $check_recaptcha = $this->ReCaptcha->check($token);
            if($check_recaptcha[CODE] != SUCCESS){
                return $this->System->getResponse([MESSAGE => $check_recaptcha[MESSAGE]]);
            }
        }

        if (!$this->controller->getRequest()->is('post') || empty($data)) {
            return $this->System->getResponse([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }
        
        $bank_key = !empty($data['bank_key']) ? $data['bank_key'] : null;
        $bank_branch = !empty($data['bank_branch']) ? trim($data['bank_branch']) : null;
        $account_holder = !empty($data['account_holder']) ? trim($data['account_holder']) : null;
        $account_number = !empty($data['account_number']) ? trim($data['account_number']) : null;
        $identity_card_id = !empty($data['identity_card_id']) ? trim($data['identity_card_id']) : "";
        $identity_card_date = !empty($data['identity_card_date']) ? trim($data['identity_card_date']) : "";
        $identity_card_name = !empty($data['identity_card_name']) ? trim($data['identity_card_name']) : "";
        $identity_card_where = !empty($data['identity_card_where']) ? trim($data['identity_card_where']) : "";
        $survey = !empty($data['survey']) ? $data['survey'] : [];
        $redirect = !empty($data['redirect']) ? trim($data['redirect']) : null;

        if(empty($bank_key)){
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_ten_ngan_hang')]);
        }

        if(empty($bank_branch)){
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_chi_nhanh')]);
        }

        if(empty($account_holder)){
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_ten_chu_tai_khoan')]);
        }

        if(empty($account_number)){
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_so_tai_khoan')]);
        }

        // if(empty($identity_card_id)){
        //     return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_so_cmnd_cccd')]);
        // }

        // if(empty($identity_card_date)){
        //     return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_ngay_cap_cmnd_cccd')]);
        // }

        // if(empty($identity_card_name)){
        //     return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_nhap_ho_va_ten_trong_cmnd_cccd')]);
        // }

        $session = $this->controller->getRequest()->getSession();
        $member = $session->read(MEMBER);

        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        // echo '<pre>';
        // print_r($customer_id);
        // die();
        if(empty($customer_id)) {
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $table = TableRegistry::get('CustomersAffiliateRequest');
        $customers_table = TableRegistry::get('Customers');
        $customer = $customers_table->getDetailCustomer($customer_id, [
            'get_list_address' => true
        ]);
        $customer_info = $customers_table->formatDataCustomerDetail($customer);

        if(empty($customer_info)) {
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        if(empty($customer_info['full_name'])) {
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_cap_nhat_ho_va_ten')]);
        }

        if(empty($customer_info['phone'])) {
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_cap_nhat_so_dien_thoai')]);
        }

        if(empty($customer_info['email'])) {
            return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_cap_nhat_email')]);
        }

        // if(empty($customer_info['city_name'])) {
        //     return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_cap_nhat_tinh_thanh')]);
        // }

        // if(empty($customer_info['district_name'])) {
        //     return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_cap_nhat_quan_huyen')]);
        // }

        // if(empty($customer_info['ward_name'])) {
        //     return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_cap_nhat_phuong_xa')]);
        // }

        if(!empty($customer_info) && $customer_info['is_partner_affiliate'] == 1){
            return $this->System->getResponse([
                CODE => SUCCESS,
                MESSAGE => __d('template', 'ban_da_tro_thanh_doi_tac')
            ]);
        }

        if(!empty($customer_info['is_partner_affiliate']) && $customer_info['is_partner_affiliate'] == 2){
            return $this->System->getResponse([
                CODE => SUCCESS,
                DATA => [
                    'wait_active' => true
                ],
                MESSAGE => __d('template', 'dang_cho_quan_tri_xet_duyet')
            ]); 
        }

        $list_bank = Configure::read('LIST_BANK');
        $bank = [
            'bank_key' => $bank_key,
            'bank_name' => !empty($list_bank[$bank_key]) ? $list_bank[$bank_key] : null,
            'bank_branch' => $bank_branch,
            'account_holder' => $account_holder,
            'account_number' => $account_number,
        ];

        $identity_card = [
            'identity_card_id' => $identity_card_id,
            'identity_card_date' => $identity_card_date,
            'identity_card_name' => $identity_card_name,
            'identity_card_where' => $identity_card_where
        ];

        $data_save = [
            'customer_id' => $customer_id,
            'bank' => json_encode($bank),
            'identity_card' => json_encode($identity_card),
            'survey' => json_encode($survey),
            'status' => 2
        ];

        $request_entity = $table->newEntity($data_save);
        $customer_entity = $customers_table->patchEntity($customer, ['is_partner_affiliate' => 2], ['validate' => false]);

        // show error validation in model
        if($request_entity->hasErrors()){
            $list_errors = $this->Utilities->errorModel($request_entity->getErrors());
            
            return $this->System->getResponse([
                MESSAGE => !empty($list_errors[0]) ? $list_errors[0] : null,
                DATA => $list_errors
            ]);             
        }
        
        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            // save data
            $save_request = $table->save($request_entity);
            if (empty($save_request->id)){
                throw new Exception();
            }

            $save_customer = $customers_table->save($customer_entity);
            if (empty($save_customer)){
                throw new Exception();
            }
      
            $conn->commit();




            // Auto Active
            $customers_bank_table = TableRegistry::get('CustomersBank');
            $customers_affiliate_table = TableRegistry::get('CustomersAffiliate');

            // lay thong tin request
            $affiliate_request_info = $table->find()->where(['customer_id' => $customer_id])->first();
            if (empty($affiliate_request_info)) {
                $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
            }

            $bank = !empty($affiliate_request_info['bank']) ? json_decode($affiliate_request_info['bank'], true) : [];
            $identity_card = !empty($affiliate_request_info['identity_card']) ? json_decode($affiliate_request_info['identity_card'], true) : [];

            // thay doi trang thai request
            $affiliate_request = $table->patchEntity($affiliate_request_info, ['status' => 1], ['validate' => false]);

            // thong tin khach hang
            $customer_info = $customers_table->find()->where([
                'id' => $customer_id,
                'status' => 1,
                'deleted' => 0
            ])->first();

            if (empty($customer_info)) {
                $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_khach_hang')]);
            }

            // thông tin trạng thái partner trong bảng customer
            $is_partner_affiliate = isset($customer_info['is_partner_affiliate']) ? intval($customer_info['is_partner_affiliate']) : 0;

            if (!empty($is_partner_affiliate) && $is_partner_affiliate == 1) {
                $this->responseJson([MESSAGE => __d('admin', 'khach_hang_hien_tai_da_la_doi_tac')]);
            }

            // kiểm tra xem thông tin customer_id này đã lưu vào bảng customer_affiliate hay chưa
            $customers_affiliate_info = $customers_affiliate_table->find()->where([
                'customer_id' => $customer_id
            ])->first();

            $number_referral = !empty($customers_affiliate_info['number_referral']) ? intval($customers_affiliate_info['number_referral']) : 0;
            $number_order_success = !empty($customers_affiliate_info['number_order_success']) ? intval($customers_affiliate_info['number_order_success']) : 0;
            $total_order_success = !empty($customers_affiliate_info['total_order_success']) ? floatval($customers_affiliate_info['total_order_success']) : 0;
            $number_order_failed = !empty($customers_affiliate_info['number_order_failed']) ? intval($customers_affiliate_info['number_order_failed']) : 0;
            $total_order_failed = !empty($customers_affiliate_info['total_order_failed']) ? floatval($customers_affiliate_info['total_order_failed']) : 0;
            $total_point = !empty($customers_affiliate_info['total_point']) ? intval($customers_affiliate_info['total_point']) : 0;

            $data_save_customers_affiliate = [
                'customer_id' => $customer_id,
                'number_referral' => $number_referral,
                'number_order_success' => $number_order_success,
                'total_order_success' => $total_order_success,
                'number_order_failed' => $number_order_failed,
                'total_order_failed' => $total_order_failed,
                'total_point' => $total_point
            ];

            $customer = $customers_affiliate = $customers_bank = [];

            $data_save_customer_info = [
                'is_partner_affiliate' => 1
            ];

            if (true) {
                // khoi tao data save thong tin cmnd/cccd cua khach hang
                if (!empty($identity_card)) {
                    $data_save_customer_info['identity_card_id'] = !empty($identity_card['identity_card_id']) ? $identity_card['identity_card_id'] : null;
                    $data_save_customer_info['identity_card_date'] = !empty($identity_card['identity_card_date']) ? strtotime(date('Y-m-d 00:00:00', strtotime(str_replace('/', '-', $identity_card['identity_card_date'])))) : null;
                    $data_save_customer_info['identity_card_name'] = !empty($identity_card['identity_card_name']) ? $identity_card['identity_card_name'] : null;
                    $data_save_customer_info['identity_card_where'] = !empty($identity_card['identity_card_where']) ? $identity_card['identity_card_where'] : null;
                }

                // khoi tao data save thong tin bank cua khach hang
                if (!empty($bank)) {
                    $bank_save = [
                        'customer_id' => $customer_id,
                        'bank_key' => !empty($bank['bank_key']) ? $bank['bank_key'] : null,
                        'bank_name' => !empty($bank['bank_name']) ? $bank['bank_name'] : null,
                        'bank_branch' => !empty($bank['bank_branch']) ? $bank['bank_branch'] : null,
                        'account_number' => !empty($bank['account_number']) ? $bank['account_number'] : null,
                        'account_holder' => !empty($bank['account_holder']) ? $bank['account_holder'] : null,
                        'is_default' => 1,
                    ];

                    $customers_bank = $customers_bank_table->newEntity($bank_save);
                }

                // khi kich hoat partner se luu thong tin customer vao bang customer_affiliate 
                if (!empty($customers_affiliate_info)) {

                    $customers_affiliate = $customers_affiliate_table->patchEntity($customers_affiliate_info, $data_save_customers_affiliate);
                } else {

                    $customers_affiliate = $customers_affiliate_table->newEntity($data_save_customers_affiliate);
                }
            }

            // thay doi thong tin partner cua customer
            $customer = $customers_table->patchEntity($customer_info, $data_save_customer_info, ['validate' => false]);

            $conn2 = ConnectionManager::get('default');
            try{
                $conn2->begin();

                // thay doi trang thai request
                $save_affiliate_request = $table->save($affiliate_request);
                if (empty($save_affiliate_request)){
                    throw new Exception();
                }

                // thay doi trang thai partner cua customer
                if (!empty($customer)) {

                    $save_customer = $customers_table->save($customer);
                    if (empty($save_customer)){
                        throw new Exception();
                    }

                }

                // luu thong tin tai khoan ngan hang cua khach hang
                if (!empty($customers_bank)) {

                    $save_bank = $customers_bank_table->save($customers_bank);
                    if (empty($save_bank->id)){
                        throw new Exception();
                    }

                }

                // luu thong tin tai khoan vao bang customer_affiliate
                if (!empty($customers_affiliate)) {

                    $save_affiliate = $customers_affiliate_table->save($customers_affiliate);
                    if (empty($save_affiliate->id)){
                        throw new Exception();
                    }

                }

            }catch (Exception $e) {
                $this->responseJson([MESSAGE => $e->getMessage()]);  
            }
            // End Auto Active


            return $this->System->getResponse([
                CODE => SUCCESS, 
                DATA => [
                    'redirect' => $redirect
                ],
                MESSAGE => __d('template', 'khoi_tao_tai_khoan_doi_tac_thanh_cong')
            ]);
        }catch (Exception $e) {
            $conn->rollback();
            return $this->System->getResponse([MESSAGE => $e->getMessage()]);
        }
    }

    public function allStatistical($data = [])
    {
        $session = $this->controller->getRequest()->getSession();
        $member_info = $session->read(MEMBER);

        $customer_id = !empty($member_info['id']) ? intval($member_info['id']) : null;
        if(empty($customer_id)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);

        $customer_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, ['get_point' => true]);
        $is_partner_affiliate = !empty($customer_info['is_partner_affiliate']) ? true : false;
        if(empty($customer_info) || empty($is_partner_affiliate)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);    

        $settings = TableRegistry::get('Settings')->getSettingWebsite();

        // thông tin cấp độ
        $level_partner_affiliate = !empty($customer_info['level_partner_affiliate']) ? intval($customer_info['level_partner_affiliate']) : 0;

        $affiliate_setting = !empty($settings['affiliate']) ? $settings['affiliate'] : [];
        $ranks = !empty($affiliate_setting['commissions']) ? json_decode($affiliate_setting['commissions'], true) : [];
        
        $customer_rank = !empty($ranks[$level_partner_affiliate]) ? $ranks[$level_partner_affiliate] : [];
        
        $rank_info = [];
        if(!empty($customer_rank)){
            $rank_info = [
                'rank' => !empty($customer_rank['key']) ? intval('key') : 0,
                'name' => !empty($customer_rank['name']) ? $customer_rank['name'] : null,
                'profit' => !empty($customer_rank['profit']) ? floatval($customer_rank['profit']) : 0,
                'image' => !empty($customer_rank['image']) ? $customer_rank['image'] : null
            ]; 
        }

        // thông tin điểm        
        $point_setting = !empty($settings['point']) ? $settings['point'] : [];
        $point_to_money = !empty($point_setting['point_to_money']) ? floatval($point_setting['point_to_money']) : 1;

        $point_info = TableRegistry::get('CustomersPoint')->getInfoCustomerPoint($customer_id);
        $affiliate_info = TableRegistry::get('CustomersAffiliate')->find()->where(['customer_id' => $customer_id])->first();

        // Thông tin đơn hàng
        $order_list = TableRegistry::get('Orders')->find()->where(['affiliate_code' => $customer_info['code']])->toList();
        $order_list_success = TableRegistry::get('Orders')->find()->where(['affiliate_code' => $customer_info['code'], 'status' => 'done'])->toList();
        $order_list_cancel = TableRegistry::get('Orders')->find()->where(['affiliate_code' => $customer_info['code'], 'status' => 'cancel'])->toList();

        $nam_total_order = strval(count($order_list)); // Tổng đơn hàng
        $nam_total_order_success = strval(count($order_list_success)); // Đơn hàng thành công
        $nam_total_order_cancel = strval(count($order_list_cancel)); // Đơn hàng thất bại
        $nam_total_order_new = strval(count($order_list) - count($order_list_success) - count($order_list_cancel)); // Đơn hàng mới

        $list_customers_affiliate_order_success = TableRegistry::get('customers_affiliate_order')->find()->where(['customer_id' => $customer_id])
        ->innerJoin(
            ['o' => 'orders'],
            [
                'o.id = customers_affiliate_order.order_id',
                'o.status = "done"'
            ],
        )
        ->toList();

        $nam_money_order_success = 0; // Tổng hoa hồng đạt
        if(!empty($list_customers_affiliate_order_success)) {
            foreach ($list_customers_affiliate_order_success as $k => $item) {
                $nam_money_order_success += $item['profit_money'];
            }
        }

        // echo '<pre>';
        // print_r($nam_money_order_success);
        // die();
        
        // thông tin affiliate
        $all_number_order = !empty($affiliate_info['number_referral']) ? intval($affiliate_info['number_referral']) : 0;
        $all_number_order_success = !empty($affiliate_info['number_order_success']) ? intval($affiliate_info['number_order_success']) : 0;
        $all_number_order_failed = !empty($affiliate_info['number_order_failed']) ? intval($affiliate_info['number_order_failed']) : 0;

        $all_total_order_success = !empty($affiliate_info['total_order_success']) ? floatval($affiliate_info['total_order_success']) : 0;
        $all_total_order_failed = !empty($affiliate_info['total_order_failed']) ? floatval($affiliate_info['total_order_failed']) : 0;

        $all_profit_point = !empty($affiliate_info['total_point']) ? floatval($affiliate_info['total_point']) : 0;
        $all_profit_money = $all_profit_point * $point_to_money;

        $all_withdraw_point = TableRegistry::get('CustomersPointHistory')->sumWithDrawPointOfCustomer($customer_id);
        $all_withdraw_money = $all_withdraw_point * $point_to_money;

        $result_processing = TableRegistry::get('CustomersPointTomoney')->sumTotalRequestProcessing($customer_id);
        $all_withdraw_processing_point = !empty($result_processing['point']) ? intval($result_processing['point']) : 0;
        $all_withdraw_processing_money = !empty($result_processing['money']) ? intval($result_processing['money']) : 0;

        // thông tin affiliate theo tháng
        $start_month = strtotime(date('Y-m-01 00:00:00'));
        $end_month = strtotime(date('Y-m-t 23:59:59'));

        $month_list_customers_affiliate_order_success = TableRegistry::get('customers_affiliate_order')->find()->where(['customer_id' => $customer_id])
        ->innerJoin(
            ['o' => 'orders'],
            [
                'o.id = customers_affiliate_order.order_id',
                'o.status = "done"',
                'o.created >=' => $start_month
            ],
        )
        ->toList();

        $month_total_order_success = 0; // Tổng hoa hồng đạt
        if(!empty($month_list_customers_affiliate_order_success)) {
            foreach ($month_list_customers_affiliate_order_success as $k => $item) {
                $month_total_order_success += $item['profit_money'];
            }
        }

        // echo '<pre>';
        // print_r($month_total_order_success);
        // die();

        $affiliate_oder_table = TableRegistry::get('CustomersAffiliateOrder');

        $month_total_order = $affiliate_oder_table->sumTotalOrderOfCustomer($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        // $month_total_order_success = $affiliate_oder_table->sumTotalOrderOfCustomer($customer_id, [
        //     'order_status' => DONE,
        //     'create_from' => $start_month,
        //     'create_to' => $end_month
        // ]);

        $month_total_order_failed = $affiliate_oder_table->sumTotalOrderOfCustomer($customer_id, [
            'order_status' => CANCEL,
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        $month_number_order = $affiliate_oder_table->countNumberOrderOfCustomer($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        $month_number_order_success = $affiliate_oder_table->countNumberOrderOfCustomer($customer_id, [
            'order_status' => DONE,
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        $month_number_order_failed = $affiliate_oder_table->countNumberOrderOfCustomer($customer_id, [
            'order_status' => CANCEL,
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        $month_profit_point_success = TableRegistry::get('CustomersPointHistory')->sumAffiliatePointOfCustomer($customer_id, [
            FILTER => [
                'create_from' => $start_month,
                'create_to' => $end_month
            ]
        ]);

        $month_profit_point_fail = TableRegistry::get('CustomersPointHistory')->sumAffiliatePointOfCustomer($customer_id, [
            FILTER => [
                'action' => 0,
                'create_from' => $start_month,
                'create_to' => $end_month
            ]
        ]);

        $month_profit_point = $month_profit_point_success - $month_profit_point_fail;
        $month_profit_money = $month_profit_point * $point_to_money;


        $month_withdraw_point = TableRegistry::get('CustomersPointHistory')->sumWithDrawPointOfCustomer($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);
        $month_withdraw_money = $month_withdraw_point * $point_to_money;


        $result_month_processing = TableRegistry::get('CustomersPointTomoney')->sumTotalRequestProcessing($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);
        $month_withdraw_processing_point = !empty($result_month_processing['point']) ? intval($result_month_processing['point']) : 0;
        $month_withdraw_processing_money = !empty($result_month_processing['money']) ? intval($result_month_processing['money']) : 0;

        $result = [
            'all_total_order_success' => $all_total_order_success,
            'all_total_order_failed' => $all_total_order_failed,
            'all_number_order' => $all_number_order,
            'all_number_order_success' => $all_number_order_success,
            'all_number_order_failed' => $all_number_order_failed,
            'all_profit_point' => $all_profit_point,
            'all_profit_money' => $all_profit_money,
            'all_withdraw_point' => $all_withdraw_point,
            'all_withdraw_money' => $all_withdraw_money,
            'all_withdraw_processing_point' => $all_withdraw_processing_point,
            'all_withdraw_processing_money' => $all_withdraw_processing_money,

            'nam_total_order' => $nam_total_order,
            'nam_total_order_new' => $nam_total_order_new,
            'nam_total_order_success' => $nam_total_order_success,
            'nam_total_order_cancel' => $nam_total_order_cancel,
            'nam_money_order_success' => $nam_money_order_success,

            'month_total_order' => $month_total_order,
            'month_total_order_success' => $month_total_order_success,
            'month_total_order_failed' => $month_total_order_failed,
            'month_number_order' => $month_number_order,
            'month_number_order_success' => $month_number_order_success,
            'month_number_order_failed' => $month_number_order_failed,
            'month_number_order_new' => ($month_number_order - $month_number_order_success - $month_number_order_failed),
            'month_profit_point' => $month_profit_point,
            'month_profit_money' => $month_profit_money,
            'month_withdraw_point' => $month_withdraw_point,
            'month_withdraw_money' => $month_withdraw_money,
            'month_withdraw_processing_point' => $month_withdraw_processing_point,
            'month_withdraw_processing_money' => $month_withdraw_processing_money,

            'rank' => $rank_info,
            'point' => !empty($customer_info['point']) ? intval($customer_info['point']) : 0,
            'point_promotion' => !empty($customer_info['point_promotion']) ? intval($customer_info['point_promotion']) : 0,
            'point_promotion_expiration' => !empty($customer_info['expiration_time']) ? intval($customer_info['expiration_time']) : 0
        ];

        return $this->System->getResponse([
            CODE => SUCCESS,
            DATA => $result
        ]);
    }

    public function monthStatistical($data = [], $options = [])
    {
        $session = $this->controller->getRequest()->getSession();
        $member_info = $session->read(MEMBER);

        $customer_id = !empty($member_info['id']) ? intval($member_info['id']) : null;
        if(empty($customer_id)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);

        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $point_setting = !empty($settings['point']) ? $settings['point'] : [];
        $point_to_money = !empty($point_setting['point_to_money']) ? floatval($point_setting['point_to_money']) : 1;
        
        // thông tin affiliate theo tháng
        $month = !empty($data['month']) ? $data['month'] : 0;
        if(intval($month) <=0 || intval($month) > 12) $month = date('m');

        $start_month = strtotime(date("Y-$month-01 00:00:00"));
        $end_month = strtotime(date("Y-$month-t 23:59:59"));

        $affiliate_oder_table = TableRegistry::get('CustomersAffiliateOrder');
        $month_total_order = $affiliate_oder_table->sumTotalOrderOfCustomer($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        // $month_total_order_success = $affiliate_oder_table->sumTotalOrderOfCustomer($customer_id, [
        //     'order_status' => DONE,
        //     'create_from' => $start_month,
        //     'create_to' => $end_month
        // ]);

        // Thông tin đơn hàng
        $month_order_list = TableRegistry::get('Orders')->find()->where(['affiliate_code' => $member_info['code'], 'Orders.created >=' => $start_month, 'Orders.created <=' => $end_month])->toList();
        $month_order_list_success = TableRegistry::get('Orders')->find()->where(['affiliate_code' => $member_info['code'], 'status' => 'done', 'Orders.created >=' => $start_month, 'Orders.created <=' => $end_month])->toList();
        $month_order_list_cancel = TableRegistry::get('Orders')->find()->where(['affiliate_code' => $member_info['code'], 'status' => 'cancel', 'Orders.created >=' => $start_month, 'Orders.created <=' => $end_month])->toList();

        $month_number_order = strval(count($month_order_list)); // Tổng đơn hàng
        $month_number_order_success = strval(count($month_order_list_success)); // Đơn hàng thành công
        $month_number_order_failed = strval(count($month_order_list_cancel)); // Đơn hàng thất bại
        $month_number_order_new = strval(count($month_order_list) - count($month_order_list_success) - count($month_order_list_cancel)); // Đơn hàng mới

        // echo '<pre>';
        // print_r($month_number_order_failed);
        // die();

        $month_list_customers_affiliate_order_success = TableRegistry::get('customers_affiliate_order')->find()->where(['customer_id' => $customer_id])
        ->innerJoin(
            ['o' => 'orders'],
            [
                'o.id = customers_affiliate_order.order_id',
                'o.status = "done"',
                'o.created >=' => $start_month,
                'o.created <=' => $end_month
            ],
        )
        ->toList();

        $month_total_order_success = 0; // Tổng hoa hồng đạt
        if(!empty($month_list_customers_affiliate_order_success)) {
            foreach ($month_list_customers_affiliate_order_success as $k => $item) {
                $month_total_order_success += $item['profit_money'];
            }
        }

        $month_total_order_failed = $affiliate_oder_table->sumTotalOrderOfCustomer($customer_id, [
            'order_status' => CANCEL,
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);

        // $month_number_order = $affiliate_oder_table->countNumberOrderOfCustomer($customer_id, [
        //     'create_from' => $start_month,
        //     'create_to' => $end_month
        // ]);

        // $month_number_order_success = $affiliate_oder_table->countNumberOrderOfCustomer($customer_id, [
        //     'order_status' => DONE,
        //     'create_from' => $start_month,
        //     'create_to' => $end_month
        // ]);

        // $month_number_order_failed = $affiliate_oder_table->countNumberOrderOfCustomer($customer_id, [
        //     'order_status' => CANCEL,
        //     'create_from' => $start_month,
        //     'create_to' => $end_month
        // ]);


        $month_profit_point_success = TableRegistry::get('CustomersPointHistory')->sumAffiliatePointOfCustomer($customer_id, [
            FILTER => [
                'create_from' => $start_month,
                'create_to' => $end_month
            ]
        ]);

        $month_profit_point_fail = TableRegistry::get('CustomersPointHistory')->sumAffiliatePointOfCustomer($customer_id, [
            FILTER => [
                'action' => 0,
                'create_from' => $start_month,
                'create_to' => $end_month
            ]
        ]);

        $month_profit_point = $month_profit_point_success - $month_profit_point_fail;
        $month_profit_money = $month_profit_point * $point_to_money;


        $month_withdraw_point = TableRegistry::get('CustomersPointHistory')->sumWithDrawPointOfCustomer($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);
        $month_withdraw_money = $month_withdraw_point * $point_to_money;

        $result_processing = TableRegistry::get('CustomersPointTomoney')->sumTotalRequestProcessing($customer_id, [
            'create_from' => $start_month,
            'create_to' => $end_month
        ]);
        $month_withdraw_processing_point = !empty($result_processing['point']) ? intval($result_processing['point']) : 0;
        $month_withdraw_processing_money = !empty($result_processing['money']) ? intval($result_processing['money']) : 0;

        $result = [
            'month_total_order' => $month_total_order,
            'month_total_order_success' => $month_total_order_success,
            'month_total_order_failed' => $month_total_order_failed,
            'month_number_order' => $month_number_order,
            'month_number_order_success' => $month_number_order_success,
            'month_number_order_failed' => $month_number_order_failed,
            'month_number_order_new' => $month_number_order_new,
            'month_profit_point' => $month_profit_point,
            'month_profit_money' => $month_profit_money,
            'month_withdraw_point' => $month_withdraw_point,
            'month_withdraw_money' => $month_withdraw_money,
            'month_withdraw_processing_point' => $month_withdraw_processing_point,
            'month_withdraw_processing_money' => $month_withdraw_processing_money,
        ];

        return $this->System->getResponse([
            CODE => SUCCESS,
            DATA => $result
        ]);
    }

    public function chartProfit($data = [], $options = [])
    {
        $api = !empty($options['api']) ? true : false;

        $member = $this->controller->getRequest()->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        if(empty($customer_id)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $table = TableRegistry::get('CustomersAffiliateOrder');     

        $month = !empty($data['month']) ? $data['month'] : 0;

        if(intval($month) <=0 || intval($month) > 12) $month = date('m');
        $last_day = date('t', strtotime(date("Y-$month-01")));

        // lấy dữ liệu chart profit
        $labels = $point_data = $money_data = [];
        for ($i = 1; $i <= $last_day; $i++) {
            $day = str_pad(strval($i), 2, '0', STR_PAD_LEFT);
            $labels[] = $day;

            $start_day = strtotime(date("Y-$month-$day 00:00:00"));
            $end_day = strtotime(date("Y-$month-$day 23:59:59"));

            $sum_result = $table->find()->contain(['Customers', 'Orders'])->where([
                'customer_id' => $customer_id,
                'Customers.deleted' => 0,
                'Customers.is_partner_affiliate' => 1,
                'Orders.status' => DONE,
                'Orders.created >=' => $start_day,
                'Orders.created <=' => $end_day
            ])->select([
                'point' => $table->find()->func()->sum('CustomersAffiliateOrder.profit_point'),
                'money' => $table->find()->func()->sum('CustomersAffiliateOrder.profit_money')
            ])->first();

            $point_data[] = !empty($sum_result['point']) ? intval($sum_result['point']) : 0;
            $money_data[] = !empty($sum_result['money']) ? floatval($sum_result['money']) : 0;
        }


        // lấy dữ liệu tổng cho tháng 
        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $point_setting = !empty($settings['point']) ? $settings['point'] : [];
        $point_to_money = !empty($point_setting['point_to_money']) ? floatval($point_setting['point_to_money']) : 1;


        $start_month = strtotime(date("Y-$month-01 00:00:00"));
        $end_month = strtotime(date("Y-$month-$last_day 23:59:59"));

        $month_profit_point = TableRegistry::get('CustomersPointHistory')->sumAffiliatePointOfCustomer($customer_id, [
            FILTER => [
                'create_from' => $start_month,
                'create_to' => $end_month
            ]
        ]);
        $month_profit_money = $month_profit_point * $point_to_money;

        $chart_data = [
            'labels' => $labels,
            'point_data' => $point_data,
            'money_data' => $money_data,
            'month_profit_point' => $month_profit_point,
            'month_profit_money' => $month_profit_money,
        ];

        return $this->System->getResponse([
            CODE => SUCCESS,
            DATA => $chart_data
        ]);
    }

    public function affiliateOrder($data = [], $options = [])
    {
        // check recaptcha
        $api = !empty($options['api']) ? true : false;        
        if(!$api){
            $token = !empty($data[TOKEN_RECAPTCHA]) ? $data[TOKEN_RECAPTCHA] : null;
            $check_recaptcha = $this->ReCaptcha->check($token);
            if($check_recaptcha[CODE] != SUCCESS){
                return $this->System->getResponse([MESSAGE => $check_recaptcha[MESSAGE]]);
            }
        }

        $number_record = !empty($data[NUMBER_RECORD]) ? intval($data[NUMBER_RECORD]) : 12;
        $page = !empty($data[PAGE]) ? intval($data[PAGE]) : 1;

        $sort_field = 'id';
        $sort_type = 'DESC';

        $create_from = !empty($data['create_from']) ? $data['create_from'] : null;
        $create_to = !empty($data['create_to']) ? $data['create_to'] : null;
        $group_status = !empty($data['group_status']) ? $data['group_status'] : null;

        $member = $this->controller->getRequest()->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        if(empty($customer_id)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $params = [
            FILTER => [
                'customer_id' => $customer_id,
                'create_from' => $create_from,
                'create_to' => $create_to,
                'group_status' => $group_status
            ]
        ];

        $table = TableRegistry::get('CustomersAffiliateOrder');

        try {
            $affiliates = $this->PaginatorExtend->paginate($table->queryListAffiliateOrder($params), [
                'limit' => $number_record,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        } catch (Exception $e) {
            $affiliates = $this->PaginatorExtend->paginate($table->queryListAffiliateOrder($params), [
                'limit' => $number_record,
                'page' => 1,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        }

        $pagination = [];
        $pagination_info = !empty($this->controller->getRequest()->getAttribute('paging')['CustomersAffiliateOrder']) ? $this->controller->getRequest()->getAttribute('paging')['CustomersAffiliateOrder'] : [];
        $pagination = $this->Utilities->formatPaginationInfo($pagination_info);
        
        $result = [];
        if(!empty($affiliates)){
            foreach ($affiliates as $k => $affiliate) {
                $result[$k] = $table->formatDataAffiliateOrderDetail($affiliate, LANGUAGE);
            }
        }

        return $this->System->getResponse([
            CODE => SUCCESS,
            DATA => [
                'affiliate' => $result,
                PAGINATION => $pagination
            ]
        ]);
    }

    public function affiliateOrderInfomation($data = [], $options = [])
    {
        $api = !empty($options['api']) ? true : false;

        $order_code = !empty($data['code']) ? $data['code'] : null;
        if(empty($order_code)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_don_hang')]);

        $member = $this->controller->getRequest()->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        if(empty($customer_id)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $table = TableRegistry::get('Orders');

        $order_info = $table->queryListOrders([
            'get_items' => true,
            FILTER => [
                'affiliate_customer_id' => $customer_id,
                'order_code' => $order_code
            ]
        ])->first();

        if(empty($order_info)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_don_hang')]);
        }

        $order_detail = $table->formatDataOrderDetail($order_info, LANGUAGE);
        
        return $this->System->getResponse([
            CODE => SUCCESS,
            DATA => $order_detail
        ]);
    }

    public function listPointToMoney($data = [], $options = [])
    {
        $api = !empty($options['api']) ? true : false;

        $number_record = !empty($data[NUMBER_RECORD]) ? intval($data[NUMBER_RECORD]) : 12;
        $page = !empty($data[PAGE]) ? intval($data[PAGE]) : 1;
        $member = $this->controller->getRequest()->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;

        $sort_field = 'id';
        $sort_type = 'DESC';

        if(empty($customer_id)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);
        }

        $params = [
            'get_customer' => true,
            'get_bank' => true,
            FILTER => [
                'customer_id' => $customer_id
            ]
        ];

        $table = TableRegistry::get('CustomersPointTomoney');

        try {
            $points_tomoney = $this->PaginatorExtend->paginate($table->queryListPointTomoney($params), [
                'limit' => $number_record,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        } catch (Exception $e) {
            $points_tomoney = $this->PaginatorExtend->paginate($table->queryListPointTomoney($params), [
                'limit' => $number_record,
                'page' => 1,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        }

        $pagination = [];
        $pagination_info = !empty($this->controller->getRequest()->getAttribute('paging')['CustomersPointTomoney']) ? $this->controller->getRequest()->getAttribute('paging')['CustomersPointTomoney'] : [];
        $pagination = $this->Utilities->formatPaginationInfo($pagination_info);
        
        $result = [];
        if(!empty($points_tomoney)){
            foreach ($points_tomoney as $k => $point_tomoney) {
                $result[$k] = $table->formatDataPointTomoneyDetail($point_tomoney);
            }
        }

        return $this->System->getResponse([
            CODE => SUCCESS,
            DATA => [
                'point_tomoney' => $result,
                PAGINATION => $pagination
            ]
        ]);
    }

    public function createRequestPointToMoney($data = [], $options = [])
    {
        $api = !empty($options['api']) ? true : false;
        // check recaptcha
        if(!$api){
            $token = !empty($data[TOKEN_RECAPTCHA]) ? $data[TOKEN_RECAPTCHA] : null;
            $check_recaptcha = $this->ReCaptcha->check($token);
            if($check_recaptcha[CODE] != SUCCESS){
                return $this->System->getResponse([MESSAGE => $check_recaptcha[MESSAGE]]);
            }
        }

        if (!$this->controller->getRequest()->is('post') || empty($data)) {
            return $this->System->getResponse([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $bank_id = !empty($data['bank_id']) ? intval($data['bank_id']) : null;
        $point = !empty($data['point']) ? intval(str_replace(',', '', $data['point'])) : null;
        $note = !empty($data['note']) ? trim($data['note']) : null;


        if(empty($bank_id)) return $this->System->getResponse([MESSAGE => __d('template', 'vui_long_chon_ngan_hang')]);
        if(empty($point)) return $this->System->getResponse([MESSAGE => __d('template', 'so_diem_khong_du_dieu_kien_de_rut')]);

        $member = $this->controller->getRequest()->getSession()->read(MEMBER);
        $customer_id = !empty($member['customer_id']) ? intval($member['customer_id']) : null;
        if(empty($customer_id)) return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_thong_tin_tai_khoan')]);

        $customer_info = TableRegistry::get('Customers')->getDetailCustomer($customer_id, [
            'get_point' => true
        ]);
        $customer_info = TableRegistry::get('Customers')->formatDataCustomerDetail($customer_info);
        $poin_max = !empty($customer_info['point']) ? intval($customer_info['point']) : 0;
 
        if($point > $poin_max) return $this->System->getResponse([MESSAGE => __d('template', 'so_diem_khong_du_de_rut')]);

        $bank_info = TableRegistry::get('CustomersBank')->find()->where([
            'id' => $bank_id,
            'customer_id' => $customer_id
        ])->select('id')->first();
        if(empty($bank_info)) return $this->System->getResponse([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);

        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $rule_point_to_money = !empty($settings['point']['point_to_money']) ? intval($settings['point']['point_to_money']) : null;
        if(empty($rule_point_to_money)){
            return $this->System->getResponse([MESSAGE => __d('template', 'chua_thiet_lap_ti_le_quy_doi')]);
        }

        $data_save = [
            'customer_id' => $customer_id,
            'bank_id' => $bank_id,
            'point' => $point,
            'money' => $rule_point_to_money * $point,
            'note' => $note,
            'status' => 2,
            'type' => 1
        ];

        $table = TableRegistry::get('CustomersPointTomoney');
        $point_tomoney_info = $table->find()->where([
            'customer_id' => $customer_id,
            'created >=' => strtotime(date('Y-m-d 00:00:00')),
            'created <=' => strtotime(date('Y-m-d 23:59:59'))
        ])->select(['id'])->count();
 
        if($point_tomoney_info >= 3){
            return $this->System->getResponse([MESSAGE => __d('template', 'vuot_qua_so_luong_yeu_cau_trong_ngay')]);
        }

        $point_tomoney = $table->newEntity($data_save);

        // show error validation in model
        if($point_tomoney->hasErrors()){
            $list_errors = $this->Utilities->errorModel($point_tomoney->getErrors());            
            $this->responseJson([
                MESSAGE => !empty($list_errors[0]) ? $list_errors[0] : null,
                DATA => $list_errors
            ]);
        }

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            // save data
            $save_point_tomoney = $table->save($point_tomoney);
            if (empty($save_point_tomoney->id)){
                throw new Exception();
            }

            $conn->commit();
            
            return $this->System->getResponse([
                CODE => SUCCESS, 
                MESSAGE => __d('template', 'gui_yeu_cau_thanh_cong')
            ]);

        }catch (Exception $e) {
            $conn->rollback();
            return $this->System->getResponse([MESSAGE => $e->getMessage()]);
        }
    }

}