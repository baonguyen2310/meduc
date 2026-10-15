<?php
declare(strict_types=1);
namespace App\View\Helper;
use Cake\View\Helper;
use Cake\ORM\TableRegistry;
use App\Lib\BookCheckout;

class CheckoutHelper extends Helper
{
    public function catalog(): array { return BookCheckout::catalog(); }
    public function confirmation(): array
    {
        $order = $this->getView()->getRequest()->getSession()->read('MeducBookOrder');
        $code = $this->getView()->getRequest()->getQuery('cartId');
        return is_array($order) && is_string($code) && ($order['cartId'] ?? '') === $code ? $order : [];
    }
    public function bank(): array
    {
        $gateways = TableRegistry::get('PaymentsGateway')->getList(LANGUAGE);
        return $gateways['bank']['config'][0] ?? [];
    }
}
