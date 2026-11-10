<?php
declare(strict_types=1);
namespace App\Controller;

use App\Service\CheckoutContact;

class CheckoutController extends AppController
{
    public function initialize(): void { parent::initialize(); $this->get_structure_layout = false; }

    public function customer()
    {
        $this->autoRender = false;
        if (!$this->request->is('get')) return $this->response->withStatus(405);
        $member = $this->request->getSession()->read(MEMBER) ?: [];
        $customer = CheckoutContact::customer((int)($member['id'] ?? 0));
        return $this->response->withType('application/json')->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode(['code'=>'success', 'data'=>[
                'member'=>(bool)$customer, 'customer_id'=>(int)($customer['id'] ?? 0),
                'contact'=>CheckoutContact::profile($customer)
            ]], JSON_UNESCAPED_UNICODE));
    }
}
