<?php

namespace App\Controller;

use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;

class QuizsAnswerController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

	public function add() 
	{
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if(!$this->getRequest()->is('post') || empty($data)){
            $this->responseJson([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $add_quiz_answer = $this->loadComponent('QuizAnswer')->addQuizAnswer($data);

        $this->responseJson($add_quiz_answer);
    }

    /** Câu hỏi của một đề cho trình làm bài trên trang khóa học (assets/meduc-v2/classroom-quiz.js)
     *  GET /khoa-hoc/bai-tap/{id khóa}/{id đề}: chỉ trả về khi đề thuộc một buổi của khóa và người xem được làm
     *  (đề làm thử miễn phí, hoặc học viên của khóa: lớp học cũ hay ghi danh), xem QuizAnswerComponent::courseQuizAccess.
    */
    public function player($product_id = null, $quiz_id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $member = $this->getRequest()->getSession()->read(MEMBER);
        $access = $this->loadComponent('QuizAnswer')->courseQuizAccess(is_array($member) ? $member : [], intval($product_id), intval($quiz_id));
        $quiz = !empty($access['allowed']) ? \App\Lib\QuizQuestions::load(intval($quiz_id), LANGUAGE) : null;

        $status = empty($access['found']) || (!empty($access['allowed']) && empty($quiz)) ? 404 : (empty($access['allowed']) ? 403 : 200);
        $body = $status === 200 ? [CODE => SUCCESS, DATA => $quiz] : [CODE => ERROR, MESSAGE => $status === 403 ? 'Bài tập này dành cho học viên đã đăng ký khóa học.' : 'Không tìm thấy bài tập.'];

        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode($body, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE));
    }

}