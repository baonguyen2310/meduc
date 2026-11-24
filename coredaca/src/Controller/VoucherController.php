<?php
declare(strict_types=1);

namespace App\Controller;

use App\Lib\BookCheckout;
use App\Service\CheckoutContact;
use App\Service\CoursePricing;
use App\Service\Vouchers;
use InvalidArgumentException;

class VoucherController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
        $this->autoRender = false;
    }

    public function preview()
    {
        if (!$this->request->is('post')) {
            return $this->json(405, 'Phương thức không hợp lệ.');
        }
        if (!Vouchers::installed()) {
            return $this->json(200, '', ['enabled' => false]);
        }

        $input = (array)$this->request->getData();
        $member = $this->request->getSession()->read(MEMBER) ?: [];
        $customer = CheckoutContact::customer((int)($member['id'] ?? 0));

        try {
            if (($input['source'] ?? '') === 'shop') {
                $items = $input['items'] ?? [];
                if (is_string($items)) {
                    $items = json_decode($items, true);
                }
                $products = BookCheckout::quote(is_array($items) ? $items : []);
                $base = (int)round(array_sum(array_column($products, 'total')));
                $kind = 'shop';
            } elseif (($input['source'] ?? '') === 'package') {
                $plan = CoursePricing::quote((int)($input['package_id'] ?? 0), is_array($input['course_ids'] ?? null) ? $input['course_ids'] : []);
                $base = (int)$plan['amount'];
                $kind = $plan['package']['course_type'];
            } else {
                throw new InvalidArgumentException('Chọn sản phẩm hoặc gói để kiểm tra ưu đãi.');
            }
            $now = time();
            $enabled = Vouchers::available($kind, $now);
            $offers = $enabled ? Vouchers::personalOffers($customer, $kind, $now) : [];
            $quote = Vouchers::quote($customer, $kind, $base, $input);
            return $this->json(200, '', $quote + ['enabled' => $enabled, 'offers' => $offers]);
        } catch (InvalidArgumentException $e) {
            return $this->json(422, $e->getMessage());
        }
    }

    public function study()
    {
        if (!$this->request->is('post')) {
            return $this->response->withStatus(405)->withHeader('Allow', 'POST');
        }
        $session = $this->request->getSession();
        $member = $session->read(MEMBER) ?: [];
        $id = (int)($member['id'] ?? 0);
        if (!$id || !Vouchers::hasStudyCampaign()) {
            $session->delete('Vouchers.study');
            return $this->response->withStatus(204)->withHeader('Cache-Control', 'no-store')
                ->withHeader('X-Meduc-Study', 'inactive');
        }

        // Credits use server time. A stale tab or a new login starts a fresh interval.
        $now = time();
        $state = $session->read('Vouchers.study') ?: [];
        $active = (int)($state['customer'] ?? 0) === $id && $now - (int)($state['seen'] ?? 0) <= 90;
        $from = $active ? (int)$state['from'] : $now;
        if ($now - $from >= 60) {
            Vouchers::recordStudyMinute($id, intdiv($now - 1, 60));
            $from = max($from + 60, $now - 59);
        }
        $session->write('Vouchers.study', ['customer' => $id, 'from' => $from, 'seen' => $now]);
        return $this->response->withStatus(204)->withHeader('Cache-Control', 'no-store');
    }

    private function json(int $status, string $message, array $data = [])
    {
        return $this->response->withStatus($status)->withType('application/json')
            ->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode(['code' => $status === 200 ? 'success' : 'error', 'message' => $message, 'data' => $data], JSON_UNESCAPED_UNICODE));
    }
}
