<?php
declare(strict_types=1);

namespace App\Controller;

use App\Lib\BookCheckout;
use App\Service\CheckoutContact;
use App\Service\CoursePricing;
use App\Service\CourseTypes;
use App\Service\Vouchers;
use App\Service\WeeklyStudyTime;
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
            $offers = $enabled ? Vouchers::personalOffers($customer, $kind, $now, true) : [];
            $quote = Vouchers::quote($customer, $kind, $base, $input);
            return $this->json(200, '', $quote + ['enabled' => $enabled, 'offers' => $offers]);
        } catch (InvalidArgumentException $e) {
            return $this->json(422, $e->getMessage());
        }
    }

    public function study()
    {
        $this->request->allowMethod(['get', 'post']);
        $session = $this->request->getSession();
        $member = $session->read(MEMBER) ?: [];
        $customer = CheckoutContact::customer((int)($member['id'] ?? 0));
        if (!$customer || (int)$customer['status'] !== 1) {
            $session->delete('Vouchers.studyStreams');
            return $this->json(401, 'Đăng nhập để tích lũy giờ học.');
        }
        if (!WeeklyStudyTime::installed()) {
            return $this->json(200, '', ['enabled' => false]);
        }
        $now = time();
        try {
            if ($this->request->is('post')) {
                $this->studyHeartbeat($customer, $now);
            }
            return $this->json(200, '', Vouchers::studyProgress((int)$customer['id'], $now));
        } catch (InvalidArgumentException $error) {
            return $this->json(422, $error->getMessage());
        }
    }

    public function claimStudy()
    {
        $this->request->allowMethod(['post']);
        $member = $this->request->getSession()->read(MEMBER) ?: [];
        $customer = CheckoutContact::customer((int)($member['id'] ?? 0));
        if (!$customer || (int)$customer['status'] !== 1) {
            return $this->json(401, 'Đăng nhập để nhận mã thưởng.');
        }
        if (!WeeklyStudyTime::installed()) {
            return $this->json(503, 'Chương trình thưởng giờ học đang được cập nhật.');
        }
        $campaign = filter_var($this->request->getData('campaign_id'), FILTER_VALIDATE_INT);
        $week = filter_var($this->request->getData('week_start'), FILTER_VALIDATE_INT);
        if ($campaign < 1 || $week < 1) {
            return $this->json(422, 'Không xác định được mốc thưởng.');
        }
        try {
            $id = (int)$customer['id'];
            $now = time();
            $code = Vouchers::claimStudy($id, $campaign, $week, $now);
            return $this->json(200, 'Đã nhận mã thưởng.', ['code' => $code, 'progress' => Vouchers::studyProgress($id, $now)]);
        } catch (InvalidArgumentException $error) {
            return $this->json(422, $error->getMessage());
        }
    }

    private function studyHeartbeat(array $customer, int $now): void
    {
        $session = $this->request->getSession();
        $data = (array)$this->request->getData();
        $stream = $data['stream'] ?? '';
        $course = filter_var($data['course_id'] ?? null, FILTER_VALIDATE_INT);
        $item = filter_var($data['item_id'] ?? null, FILTER_VALIDATE_INT);
        $activity = $data['activity'] ?? '';
        $stop = ($data['stop'] ?? '') === '1';
        if (!is_string($stream) || !preg_match('/^[a-f0-9]{24}$/D', $stream) || $course < 1 || $item < 1
            || !in_array($activity, ['video', 'quiz'], true)) {
            throw new InvalidArgumentException('Không xác định được nội dung đang học.');
        }
        $id = (int)$customer['id'];
        $streams = array_filter($session->read('Vouchers.studyStreams') ?: [], static function ($state) use ($id, $now) {
            return $state['customer'] === $id && $state['seen'] >= $now - 60;
        });
        $previous = $streams[$stream] ?? null;
        if ($stop && !$previous) {
            return;
        }
        if ($previous && ($previous['course'] !== $course || $previous['item'] !== $item || $previous['activity'] !== $activity)) {
            throw new InvalidArgumentException('Nội dung học đã thay đổi. Hãy mở lại bài học.');
        }
        $allowedUntil = $previous['allowed_until'] ?? 0;
        if ($allowedUntil <= $now) {
            if (!$this->canRecordStudy($customer, $course, $item, $activity)) {
                unset($streams[$stream]);
                $session->write('Vouchers.studyStreams', $streams);
                throw new InvalidArgumentException('Nội dung này chưa đủ điều kiện tính giờ học.');
            }
            $allowedUntil = $now + 120;
        }
        if ($previous) {
            WeeklyStudyTime::record($id, $previous['seen'], $now);
        }
        unset($streams[$stream]);
        if (!$stop) {
            $streams[$stream] = [
                'customer' => $id, 'course' => $course, 'item' => $item, 'activity' => $activity,
                'seen' => max($previous['seen'] ?? 0, $now), 'allowed_until' => $allowedUntil,
            ];
        }
        $session->write('Vouchers.studyStreams', array_slice($streams, -6, null, true));
    }

    private function canRecordStudy(array $customer, int $course, int $item, string $activity): bool
    {
        if (CourseTypes::kind($course) !== 'knowledge' || !CourseTypes::publicCourse($course)) {
            return false;
        }
        if ($activity === 'video') {
            return WeeklyStudyTime::canWatch($customer, $course, $item);
        }
        $access = $this->loadComponent('QuizAnswer')->courseQuizAccess($customer, $course, $item);
        return !empty($access['allowed']) && ($access['mode'] ?? '') !== 'reference';
    }

    private function json(int $status, string $message, array $data = [])
    {
        return $this->response->withStatus($status)->withType('application/json')
            ->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode(['code' => $status === 200 ? 'success' : 'error', 'message' => $message, 'data' => $data], JSON_UNESCAPED_UNICODE));
    }
}
