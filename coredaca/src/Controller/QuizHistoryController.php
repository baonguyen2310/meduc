<?php

namespace App\Controller;

use Cake\Datasource\ConnectionManager;

class QuizHistoryController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
    }

    public function index()
    {
        $this->set('title_for_layout', 'Lịch sử làm bài — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('index');
    }

    /** Only the signed-in learner may read their own attempt history. */
    public function data()
    {
        $this->autoRender = false;
        $member = $this->request->getSession()->read(MEMBER);
        $customerId = is_array($member) ? intval($member['customer_id'] ?? 0) : 0;

        if ($customerId <= 0) {
            return $this->jsonResponse(['status' => 'login_required', 'attempts' => []], 401);
        }

        $connection = ConnectionManager::get('default');
        $rows = $connection->execute("
            SELECT a.id, a.quiz_id, a.product_id, a.lesson_name,
                   a.answer_total, a.answer_correct, a.total_time, a.created,
                   qc.name AS quiz_name, pc.name AS course_name, l.url AS course_slug
            FROM quizs_answer a
            LEFT JOIN quizs_content qc ON qc.id = (
                SELECT MIN(qc2.id) FROM quizs_content qc2
                WHERE qc2.quiz_id = a.quiz_id AND qc2.lang = 'vi'
            )
            LEFT JOIN products_content pc ON pc.id = (
                SELECT MIN(pc2.id) FROM products_content pc2
                WHERE pc2.product_id = a.product_id AND pc2.lang = 'vi'
            )
            LEFT JOIN links l ON l.id = (
                SELECT MIN(l2.id) FROM links l2
                WHERE l2.foreign_id = a.product_id AND l2.type = 'product_detail'
                  AND l2.lang = 'vi' AND l2.deleted = 0
            )
            WHERE a.customer_id = :customer_id AND a.deleted = 0
            ORDER BY a.created DESC, a.id DESC
        ", ['customer_id' => $customerId])->fetchAll('assoc');

        $clean = static function ($value) {
            return trim(preg_replace('/\s+/u', ' ', strip_tags(html_entity_decode((string)$value, ENT_QUOTES, 'UTF-8'))));
        };
        $attempts = [];
        foreach ($rows as $row) {
            $total = max(0, intval($row['answer_total']));
            $correct = max(0, min($total, intval($row['answer_correct'])));
            $lesson = $clean($row['lesson_name']);
            $quiz = $clean($row['quiz_name']);
            $course = $clean($row['course_name']);
            $slug = trim((string)$row['course_slug'], '/');
            $attempts[] = [
                'id' => intval($row['id']),
                'quiz_id' => intval($row['quiz_id']),
                'course_id' => intval($row['product_id']),
                'title' => $lesson ?: ($quiz ?: 'Bài luyện tập'),
                'quiz' => $quiz,
                'course' => $course ?: 'Luyện tập Y khoa',
                'score' => $total ? round($correct * 100 / $total, 1) : 0,
                'correct' => $correct,
                'total' => $total,
                'duration' => max(0, intval($row['total_time'])),
                'created' => intval($row['created']),
                'course_url' => $slug ? '/khoa-hoc-chi-tiet-v2?course=' . rawurlencode($slug) : '/medduo',
            ];
        }

        return $this->jsonResponse(['status' => 'ok', 'count' => count($attempts), 'attempts' => $attempts]);
    }

    private function jsonResponse(array $payload, int $status = 200)
    {
        return $this->response
            ->withStatus($status)
            ->withType('application/json')
            ->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE));
    }
}
