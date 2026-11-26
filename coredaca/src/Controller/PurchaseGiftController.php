<?php
declare(strict_types=1);

namespace App\Controller;

use App\Service\PurchaseGifts;
use InvalidArgumentException;
use Throwable;

class PurchaseGiftController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
    }

    public function activate()
    {
        $this->request->allowMethod(['post']);
        $this->autoRender = false;
        $session = $this->request->getSession();
        $owner = (int)($session->read(MEMBER)['id'] ?? 0);
        if (!$owner) return $this->redirect('/member/login', 303);

        $gift = filter_var($this->request->getData('gift_id'), FILTER_VALIDATE_INT);
        $quiz = filter_var($this->request->getData('quiz_id'), FILTER_VALIDATE_INT);
        try {
            if (!$gift || !$quiz || $gift < 1 || $quiz < 1) throw new InvalidArgumentException('Vui lòng chọn môn nhận quà.');
            PurchaseGifts::activateQuiz($owner, $gift, $quiz);
            $notice = ['ok'=>true, 'message'=>'Đã mở Đề thi tặng kèm.'];
        } catch (InvalidArgumentException $error) {
            $notice = ['ok'=>false, 'message'=>$error->getMessage()];
        } catch (Throwable $error) {
            $this->log('Purchase gift activation: ' . $error->getMessage(), 'error');
            $notice = ['ok'=>false, 'message'=>'Chưa nhận được quà. Bạn thử lại sau nhé.'];
        }
        $session->write('PurchaseGifts.notice', $notice);
        $this->setResponse($this->getResponse()->withHeader('Cache-Control', 'private, no-store'));
        return $this->redirect('/khoa-hoc-da-dang-ky?loai=quiz#qua-mua-hang', 303);
    }
}
