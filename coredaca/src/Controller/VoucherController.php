<?php
declare(strict_types=1);

namespace App\Controller;

use App\Lib\BookCheckout;
use App\Service\CheckoutContact;
use App\Service\CoursePricing;
use App\Service\Vouchers;
use App\Service\WeeklyOnlineTime;
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
            $enabled = Vouchers::available($kind, $now, (int)($customer['id'] ?? 0));
            $offers = $enabled ? Vouchers::personalOffers($customer, $kind, $now) : [];
            $quote = Vouchers::quote($customer, $kind, $base, $input);
            return $this->json(200, '', $quote + ['enabled' => $enabled, 'offers' => $offers]);
        } catch (InvalidArgumentException $e) {
            return $this->json(422, $e->getMessage());
        }
    }

    // Older course tabs can still send a progress request and hide the retired panel.
    public function study()
    {
        $this->request->allowMethod(['get', 'post']);
        return $this->json(200, '', ['enabled' => false]);
    }

    public function claimStudy()
    {
        $this->request->allowMethod(['post']);
        return $this->json(410, 'Chương trình ưu đãi này đã kết thúc.');
    }

    public function online()
    {
        $this->request->allowMethod(['post']);
        $session = $this->request->getSession();
        $customer = $this->currentCustomer();
        if (!$customer) {
            $session->delete('Vouchers.onlineStreams');
            return $this->json(401, 'Đăng nhập để xem thời gian online.');
        }
        if (!WeeklyOnlineTime::installed()) {
            return $this->json(200, '', ['enabled' => false]);
        }

        $stream = $this->request->getData('stream');
        if (!is_string($stream) || !preg_match('/^[a-f0-9]{32}$/D', $stream)) {
            return $this->json(422, 'Không xác định được phiên online.');
        }
        $id = (int)$customer['id'];
        $now = time();
        $key = 'Vouchers.onlineStreams';
        $streams = array_filter($session->read($key) ?: [], static function (array $entry) use ($id, $now): bool {
            return $entry['customer'] === $id && $entry['seen'] >= $now - WeeklyOnlineTime::MAX_PULSE_GAP;
        });
        if (isset($streams[$stream])) {
            WeeklyOnlineTime::record($id, $streams[$stream]['seen'], $now);
            unset($streams[$stream]);
        }
        if ($this->request->getData('leaving') !== '1') {
            $streams[$stream] = ['customer' => $id, 'seen' => $now];
        }
        $session->write($key, array_slice($streams, -24, null, true));
        return $this->json(200, '', ['enabled' => true] + Vouchers::onlineProgress($id, $now));
    }

    public function claimOnline()
    {
        $this->request->allowMethod(['post']);
        $customer = $this->currentCustomer();
        if (!$customer) {
            return $this->json(401, 'Đăng nhập để nhận mã thưởng.');
        }
        if (!WeeklyOnlineTime::installed()) {
            return $this->json(503, 'Chương trình thưởng thời gian online đang được cập nhật.');
        }
        $campaign = filter_var($this->request->getData('campaign_id'), FILTER_VALIDATE_INT);
        $week = filter_var($this->request->getData('week_start'), FILTER_VALIDATE_INT);
        if ($campaign < 1 || $week < 1) {
            return $this->json(422, 'Không xác định được mốc thưởng.');
        }
        try {
            $id = (int)$customer['id'];
            $now = time();
            $code = Vouchers::claimOnlineReward($id, $campaign, $week, $now);
            return $this->json(200, 'Đã nhận mã thưởng.', ['code' => $code, 'progress' => Vouchers::onlineProgress($id, $now)]);
        } catch (InvalidArgumentException $error) {
            return $this->json(422, $error->getMessage());
        }
    }

    private function currentCustomer(): array
    {
        $member = $this->request->getSession()->read(MEMBER) ?: [];
        $customer = CheckoutContact::customer((int)($member['id'] ?? $member['customer_id'] ?? 0));
        return $customer && (int)$customer['status'] === 1 ? $customer : [];
    }

    private function json(int $status, string $message, array $data = [])
    {
        return $this->response->withStatus($status)->withType('application/json')
            ->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode(['code' => $status === 200 ? 'success' : 'error', 'message' => $message, 'data' => $data], JSON_UNESCAPED_UNICODE));
    }
}
