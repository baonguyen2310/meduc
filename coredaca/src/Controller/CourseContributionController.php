<?php
namespace App\Controller;

use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Psr\Http\Message\UploadedFileInterface;

/** Suggestions remain separate from the source exams until an admin reviews them. */
class CourseContributionController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
    }

    public function submit()
    {
        $this->autoRender = false;
        if (!$this->request->is('post')) return $this->json(405, 'Phương thức không hợp lệ.');

        $member = $this->request->getSession()->read(MEMBER);
        if (empty($member['id'])) return $this->json(401, 'Vui lòng đăng nhập để gửi đóng góp.');

        $data = $this->request->getData();
        $type = (string)($data['type'] ?? '');
        $productId = (int)($data['product_id'] ?? 0);
        $lesson = (int)($data['lesson_number'] ?? 0);
        $quizId = (int)($data['quiz_id'] ?? 0);
        $question = (int)($data['question_number'] ?? 0);
        $answer = trim((string)($data['suggested_answer'] ?? ''));
        $content = trim((string)($data['content'] ?? ''));

        if (!in_array($type, ['answer', 'exam', 'curriculum', 'general'], true)
            || $productId < 1 || $lesson < 0 || $lesson > 10000
            || $quizId < 0 || $question < 0 || $question > 10000
            || mb_strlen($answer) > 255 || mb_strlen($content) < 10 || mb_strlen($content) > 5000) {
            return $this->json(422, 'Vui lòng chọn nội dung góp ý và mô tả từ 10 đến 5.000 ký tự.');
        }
        if ($type === 'answer' && (!$quizId || !$question || !$answer)) {
            return $this->json(422, 'Vui lòng chọn đề, nhập số câu và đáp án đề xuất.');
        }

        $product = TableRegistry::get('Products')->find()->where(['id' => $productId, 'deleted' => 0])->select(['id'])->first();
        if (!$product) return $this->json(404, 'Không tìm thấy khóa học.');
        if ($quizId) {
            $access = $this->loadComponent('QuizAnswer')->courseQuizAccess($member, $productId, $quizId);
            if (empty($access['allowed'])) return $this->json(403, 'Bạn không có quyền xem đề này.');
            if ($question) {
                $quiz = \App\Lib\QuizQuestions::load($quizId, LANGUAGE);
                if (!$quiz || $question > count($quiz['questions'] ?? [])) return $this->json(422, 'Số câu không có trong đề.');
            }
        }

        $db = ConnectionManager::get('default');
        $recent = $db->execute('SELECT COUNT(*) FROM course_contributions WHERE customer_id=:id AND created>=:since',
            ['id' => (int)$member['id'], 'since' => time() - 3600])->fetchColumn(0);
        if ((int)$recent >= 10) return $this->json(429, 'Bạn đã gửi nhiều góp ý trong giờ qua. Vui lòng thử lại sau.');

        $uploads = $data['photos'] ?? [];
        if ($uploads instanceof UploadedFileInterface) $uploads = [$uploads];
        if (!is_array($uploads)) $uploads = [];
        $uploads = array_values(array_filter($uploads, function ($file) {
            return $file instanceof UploadedFileInterface && $file->getError() !== UPLOAD_ERR_NO_FILE;
        }));
        if (count($uploads) > 5 || ($type !== 'exam' && $uploads)) return $this->json(422, 'Chỉ đề đóng góp mới nhận tối đa 5 ảnh.');
        if ($type === 'exam' && !$uploads) return $this->json(422, 'Vui lòng đính kèm ít nhất một ảnh đề.');

        $mimeTypes = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
        foreach ($uploads as $file) {
            if ($file->getError() !== UPLOAD_ERR_OK || $file->getSize() > 8 * 1024 * 1024 || $file->getSize() < 1) {
                return $this->json(422, 'Mỗi ảnh phải nhỏ hơn 8 MB.');
            }
            $uri = $file->getStream()->getMetadata('uri');
            $mime = $uri && is_file($uri) ? (new \finfo(FILEINFO_MIME_TYPE))->file($uri) : null;
            if (!isset($mimeTypes[$mime])) return $this->json(422, 'Chỉ nhận ảnh JPG, PNG hoặc WebP.');
        }

        $folder = ROOT . DS . 'tmp' . DS . 'course-contributions';
        $saved = [];
        try {
            if ($uploads && !is_dir($folder) && !mkdir($folder, 0700, true) && !is_dir($folder)) {
                throw new \RuntimeException('Không tạo được thư mục lưu ảnh.');
            }
            foreach ($uploads as $file) {
                $uri = $file->getStream()->getMetadata('uri');
                $mime = (new \finfo(FILEINFO_MIME_TYPE))->file($uri);
                $name = bin2hex(random_bytes(20)) . '.' . $mimeTypes[$mime];
                $file->moveTo($folder . DS . $name);
                $saved[] = $name;
            }
            $now = time();
            $db->execute('INSERT INTO course_contributions
                (customer_id, product_id, lesson_number, quiz_id, question_number, type, suggested_answer, content, photo_files, status, created, updated)
                VALUES (:customer, :product, :lesson, :quiz, :question, :type, :answer, :content, :photos, :status, :created, :updated)', [
                'customer' => (int)$member['id'], 'product' => $productId,
                'lesson' => $lesson ?: null, 'quiz' => $quizId ?: null, 'question' => $question ?: null,
                'type' => $type, 'answer' => $answer ?: null, 'content' => $content,
                'photos' => json_encode($saved), 'status' => 'new', 'created' => $now, 'updated' => $now,
            ]);
            $id = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
        } catch (\Throwable $e) {
            foreach ($saved as $name) @unlink($folder . DS . $name);
            $this->log('Course contribution save failed: ' . $e->getMessage(), 'error');
            return $this->json(500, 'Chưa lưu được đóng góp. Vui lòng thử lại.');
        }

        // Notification failure must not erase a student's contribution.
        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $adminEmails = array_values(array_unique(array_filter(
            preg_split('/[,;\s]+/', trim((string)($settings['email']['email_administrator'] ?? ''))),
            static function ($email) { return (bool)filter_var($email, FILTER_VALIDATE_EMAIL); }
        )));
        $localPreview = in_array($this->request->getUri()->getHost(), ['localhost', '127.0.0.1'], true);
        if (!$localPreview && $adminEmails) {
            $safe = htmlspecialchars($content, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
            try {
                $mail = $this->loadComponent('Email')->sendEmail([
                    'to_email' => $adminEmails, 'send_try_content' => true,
                    'subject' => "MedUC: đóng góp mới #{$id}",
                    'content' => "Có đóng góp mới #{$id} cho khóa {$productId} (" . htmlspecialchars($type, ENT_QUOTES, 'UTF-8') . ").<br>" . nl2br($safe) . "<br>Vào trang quản trị mục Đóng góp học viên để xem và xử lý.",
                ]);
                if (($mail[CODE] ?? null) !== SUCCESS) $this->log("Could not email course contribution #{$id}", 'error');
            } catch (\Throwable $e) {
                $this->log("Could not email course contribution #{$id}: " . $e->getMessage(), 'error');
            }
        } elseif (!$localPreview) {
            $this->log("Admin email is not configured for course contribution #{$id}", 'warning');
        }

        return $this->json(200, 'MedUC cảm ơn bạn đã đóng góp. Bộ đề được đội ngũ ThS, BSNT của MedUC tổng hợp, rà soát và giải đáp, có hỗ trợ một phần của AI. Nội dung có thể còn sai sót; những đóng góp của bạn giúp cộng đồng học Y ngày càng tốt hơn.', ['id' => $id]);
    }

    private function json(int $status, string $message, array $data = [])
    {
        return $this->response->withStatus($status)->withType('application/json')
            ->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode(['code' => $status === 200 ? 'success' : 'error', 'message' => $message, 'data' => $data], JSON_UNESCAPED_UNICODE));
    }
}
