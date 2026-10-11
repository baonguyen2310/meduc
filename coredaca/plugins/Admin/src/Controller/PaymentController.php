<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Http\Response;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;


class PaymentController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

    public function list()
    {
        $this->js_page = '/assets/js/pages/list_payment.js';
        $this->set('path_menu', 'payment');
        $this->set('title_for_layout', __d('admin', 'danh_sach_giao_dich'));
    }

    public function listJson()
    {
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $table = TableRegistry::get('Payments');
        $utilities = $this->loadComponent('Utilities');

        $data = $params = [];

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

        // page and limit
        $page = !empty($data[PAGINATION][PAGE]) ? intval($data[PAGINATION][PAGE]) : 1;
        $limit = !empty($data[PAGINATION][PERPAGE]) ? intval($data[PAGINATION][PERPAGE]) : PAGINATION_LIMIT_ADMIN;
        
        // sort 
        $params[SORT] = !empty($data[SORT]) ? $data[SORT] : [];
        $sort_field = !empty($params[SORT][FIELD]) ? $params[SORT][FIELD] : null;
        $sort_type = !empty($params[SORT][SORT]) ? $params[SORT][SORT] : null;
        
        try {
            $payments = $this->paginate($table->queryListPayments($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        } catch (Exception $e) {
            $payments = $this->paginate($table->queryListPayments($params), [
                'limit' => $limit,
                'page' => 1,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toList();
        }

        $pagination_info = !empty($this->request->getAttribute('paging')['Payments']) ? $this->request->getAttribute('paging')['Payments'] : [];
        $meta_info = $utilities->formatPaginationInfo($pagination_info);

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $payments, 
            META => $meta_info
        ]);
    }

    public function detail($code = null)
    {
        $payment_detail = TableRegistry::get('Payments')->getDetailPayment($code);
        if (empty($payment_detail)) {
            $this->showErrorPage();
        }

        $status = !empty($payment_detail['status']) ? $payment_detail['status'] : null;
        if(!empty($payment_detail['order_id'])){
            $payment_detail['orders'] = TableRegistry::get('Orders')->getDetailOrder($payment_detail['order_id']);
        }

        $change_status = false;
        $payment_method = !empty($payment_detail['payment_method']) ? $payment_detail['payment_method'] : null;
        $payment_gateway_code = !empty($payment_detail['payment_gateway_code']) ? $payment_detail['payment_gateway_code'] : null;

        if($payment_method == BANK && $status == 2 && empty($payment_gateway_code)){
            $change_status = true;
        }

        $this->js_page = [
            '/assets/js/pages/payment_detail.js',
        ];

        $this->set('payment', $payment_detail);
        $this->set('change_status', $change_status);
        $this->set('path_menu', 'payment');
        $this->set('title_for_layout', __d('admin', 'chi_tiet_giao_dich'));
    }

    public function changeNote()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $id = !empty($data['id']) ? intval($data['id']) : null;
        $value = !empty($data['value']) ? $data['value'] : 0;
        $type = !empty($data['type']) ? $data['type'] : '';

        // validate data
        if (empty($id) || empty($type)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $payments_table = TableRegistry::get('Payments');
        if ( !empty($type) && $type == 'note' ) {
            $data_save['note'] = $value;
        }
        $payment = $payments_table->find()->where(['id' => $id])->first();
        $payment = $payments_table->patchEntity($payment, $data_save);

        try{
            // save data
            $save = $payments_table->save($payment);

            if (empty($save->id)){
                throw new Exception();
            }
            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function changeStatus($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $payments_table = TableRegistry::get('Payments');

        // validate data
        if(empty($data)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }
      
        if(empty($id)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_thong_tin_don_hang')]);
        }

        if(!isset($data['status'])){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_trang_thai_don_hang')]);
        }

        $status = !empty($data['status']) ? intval($data['status']) : 0;

        $payment_info = $payments_table->find()->where(['Payments.id' => $id])->first();        
        if(empty($payment_info)) {
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_cua_giao_dich')]);
        }

        $foreign_id = !empty($payment_info['foreign_id']) ? $payment_info['foreign_id'] : null;
        $foreign_type = !empty($payment_info['foreign_type']) ? $payment_info['foreign_type'] : null;
        $payment_method = !empty($payment_info['payment_method']) ? $payment_info['payment_method'] : null;
        $payment_gateway_code = !empty($payment_info['payment_gateway_code']) ? $payment_info['payment_gateway_code'] : null;

        if($payment_method != BANK || !empty($payment_gateway_code)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_the_cap_nhat_trang_thai_cua_giao_dich_nay')]);   
        }

        $data_save = [
            'reference' => !empty($data['reference']) ? $data['reference'] : null,
            'status' => $status
        ];

        $payment_info = $payments_table->patchEntity($payment_info, $data_save);

        if($payment_info->hasErrors()){
            $list_errors = $this->Utilities->errorModel($payment_info->getErrors());
            
            return $this->System->getResponse([
                MESSAGE => !empty($list_errors[0]) ? $list_errors[0] : null,
                DATA => $list_errors
            ]);
        }

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            // save data
            $save = $payments_table->save($payment_info);
            if (empty($save->id)){
                throw new Exception();
            }

            if(!empty($foreign_id) && $foreign_type == ORDER && $status == 1){
                $update_order = TableRegistry::get('Orders')->updateAfterPayment($foreign_id);
                if (empty($update_order)){
                    throw new Exception();
                }

                // cộng điểm thưởng sau khi đơn hàng thành công
                $this->loadComponent('Admin.CustomersPoint')->refundPointOrder($foreign_id);
            }
            
            $conn->commit();
            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'cap_nhat_thanh_cong')]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

}