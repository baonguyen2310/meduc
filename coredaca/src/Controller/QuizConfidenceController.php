<?php
namespace App\Controller;

use App\Lib\QuizQuestions;
use Cake\Datasource\ConnectionManager;

/** A confidence rating belongs to one question in the signed-in student's own saved attempt. */
class QuizConfidenceController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
    }

    public function index($product = null, $quiz = null, $attempt = null)
    {
        $this->autoRender = false;
        if (!$this->request->is('get') && !$this->request->is('post')) return $this->json(405, 'Phương thức không hợp lệ.');
        $member = $this->request->getSession()->read(MEMBER);
        if (empty($member['id'])) return $this->json(401, 'Vui lòng đăng nhập để lưu mức độ tự tin.');
        $db = ConnectionManager::get('default');
        $record = $db->execute('SELECT id FROM quizs_answer WHERE id=:attempt AND customer_id=:customer
            AND product_id=:product AND quiz_id=:quiz AND deleted=0 LIMIT 1', [
            'attempt'=>(int)$attempt, 'customer'=>(int)$member['id'], 'product'=>(int)$product, 'quiz'=>(int)$quiz,
        ])->fetch('assoc');
        if (!$record) return $this->json(404, 'Không tìm thấy bài làm của bạn.');
        $access = $this->loadComponent('QuizAnswer')->courseQuizAccess($member, (int)$product, (int)$quiz);
        if (empty($access['found']) || empty($access['allowed'])) return $this->json(403, 'Bạn không có quyền mở bài tập này.');
        $data = QuizQuestions::load((int)$quiz, LANGUAGE);
        if (!$data) return $this->json(404, 'Không tìm thấy bài tập.');
        $questions = $data['questions'];
        if ($this->request->is('get')) {
            $rows = $db->execute('SELECT question_index,question_key,confidence FROM quiz_question_confidence WHERE quiz_answer_id=:id', ['id'=>(int)$attempt])->fetchAll('assoc');
            $ratings = [];
            foreach ($rows as $row) {
                $index = (int)$row['question_index'];
                if (isset($questions[$index]) && hash_equals($questions[$index]['key'], $row['question_key'])) $ratings[$index] = $row['confidence'];
            }
            return $this->json(200, '', ['ratings'=>(object)$ratings]);
        }
        $index = $this->request->getData('question_index');
        $level = $this->request->getData('confidence');
        $key = $this->request->getData('question_key');
        if (filter_var($index, FILTER_VALIDATE_INT) === false || (int)$index < 0 || !isset($questions[(int)$index])
            || !is_string($level) || !in_array($level, ['confident','unsure','guess'], true)
            || !is_string($key) || !preg_match('/^[a-f0-9]{64}$/D', $key)) {
            return $this->json(422, 'Mức độ tự tin hoặc câu hỏi không hợp lệ.');
        }
        if (!hash_equals($questions[(int)$index]['key'], $key)) return $this->json(409, 'Nội dung câu hỏi đã thay đổi. Vui lòng mở lại bài tập.');
        try {
            $db->execute('INSERT INTO quiz_question_confidence (quiz_answer_id,question_index,question_key,confidence,created,updated)
                VALUES (:attempt,:index,:key,:confidence,:created,:updated)
                ON DUPLICATE KEY UPDATE question_key=VALUES(question_key),confidence=VALUES(confidence),updated=VALUES(updated)', [
                'attempt'=>(int)$attempt, 'index'=>(int)$index, 'key'=>$key, 'confidence'=>$level, 'created'=>time(), 'updated'=>time(),
            ]);
        } catch (\Throwable $error) {
            $this->log('Could not save question confidence for attempt #'.(int)$attempt, 'error');
            return $this->json(500, 'Chưa lưu được mức độ tự tin. Vui lòng thử lại.');
        }
        return $this->json(200, 'Đã lưu', ['question_index'=>(int)$index,'confidence'=>$level]);
    }

    private function json(int $status, string $message, array $data = [])
    {
        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control','private, no-store')
            ->withStringBody(json_encode(['code'=>$status === 200 ? 'success' : 'error','message'=>$message,'data'=>$data], JSON_UNESCAPED_UNICODE));
    }
}
