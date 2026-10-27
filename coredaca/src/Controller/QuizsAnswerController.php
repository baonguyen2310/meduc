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
        // Even a free quiz starts only after account authentication; never send guest question/answer data.
        $quiz = !empty($access['allowed']) && !empty($member['id']) ? \App\Lib\QuizQuestions::load(intval($quiz_id), LANGUAGE) : null;
        $status = empty($access['found']) ? 404 : (empty($access['allowed']) ? 403 : (empty($member['id']) ? 401 : (empty($quiz) ? 404 : 200)));
        $body = $status === 200 ? [CODE => SUCCESS, DATA => $quiz] : [CODE => ERROR, MESSAGE => $status === 401
            ? 'Đăng nhập hoặc đăng ký tài khoản để làm bài tập miễn phí. Bạn không cần mua khóa học để làm thử.'
            : ($status === 403 ? 'Bài tập này dành cho học viên đã đăng ký khóa học.' : 'Không tìm thấy bài tập.')];
        if ($status === 401) $body[DATA] = ['login_required' => true];

        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode($body, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE));
    }

    /** Lịch sử của đúng học viên đang đăng nhập, cho một đề thuộc khóa học mà họ được phép mở. */
    public function history($product_id = null, $quiz_id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $productId = intval($product_id);
        $quizId = intval($quiz_id);
        $member = $this->getRequest()->getSession()->read(MEMBER);
        $member = is_array($member) ? $member : [];
        $access = $this->loadComponent('QuizAnswer')->courseQuizAccess($member, $productId, $quizId);
        $quiz = !empty($access['allowed']) ? \App\Lib\QuizQuestions::load($quizId, LANGUAGE) : null;
        $status = empty($access['found']) || (!empty($access['allowed']) && empty($quiz)) ? 404 : (empty($access['allowed']) ? 403 : 200);
        if ($status !== 200) {
            $body = [CODE => ERROR, MESSAGE => $status === 403 ? 'Bài tập này dành cho học viên đã đăng ký khóa học.' : 'Không tìm thấy bài tập.'];
        } else {
            $history = [];
            if (!empty($member['id'])) {
                $rows = ConnectionManager::get('default')->execute(
                    'SELECT id, created, answer_total, answer_correct, answer_correct_percent, total_time, answers
                     FROM quizs_answer WHERE deleted=0 AND customer_id=:customer AND product_id=:product AND quiz_id=:quiz
                     ORDER BY created DESC, id DESC',
                    ['customer' => intval($member['id']), 'product' => $productId, 'quiz' => $quizId]
                )->fetchAll('assoc');
                foreach ($rows as $row) {
                    $answers = json_decode((string)$row['answers'], true);
                    $history[] = [
                        'id' => intval($row['id']),
                        'created' => intval($row['created']),
                        'total' => intval($row['answer_total']),
                        'correct' => intval($row['answer_correct']),
                        'percent' => floatval($row['answer_correct_percent']),
                        'seconds' => intval($row['total_time']),
                        'answers' => is_array($answers) ? $answers : [],
                    ];
                }
            }
            $body = [CODE => SUCCESS, DATA => $history];
        }

        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode($body, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE));
    }

}
