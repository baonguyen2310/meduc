<?php

namespace App\Controller\Component;

use Cake\Controller\Component;
use Cake\Controller\ComponentRegistry;
use Cake\ORM\TableRegistry;
use Cake\Datasource\ConnectionManager;
use Cake\Core\Exception\Exception;
use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;

class QuizAnswerComponent extends Component
{
    public $controller = null;
    public $components = ['System', 'Utilities', 'PaginatorExtend', 'ReCaptcha', 'Upload'];

    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->controller = $this->_registry->getController();
    }

    public function addQuizAnswer($data = [], $options = [])
    {
        if(empty($data)){
            return $this->System->getResponse([MESSAGE => __d('template', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('QuizsAnswer');
        $private = ConnectionManager::get('default')->execute(
            'SELECT 1 FROM quiz_exam_metadata WHERE quiz_id=:id AND staff_only=1',
            ['id'=>(int)($data['quiz_id']??0)]
        )->fetch('assoc');
        if ($private) return $this->System->getResponse([MESSAGE=>'Đề này chưa được mở cho học viên.']);

        // học viên lấy từ phiên đăng nhập, không theo dữ liệu gửi lên
        $member = $this->controller->getRequest()->getSession()->read(MEMBER);
        if (empty($member['id'])) {
            return $this->System->getResponse([MESSAGE => 'Vui lòng đăng nhập để lưu kết quả bài làm.']);
        }

        $quiz_id = !empty($data['quiz_id']) ? intval($data['quiz_id']) : 0;
        $product_id = !empty($data['product_id']) ? intval($data['product_id']) : 0;
        $access = $this->courseQuizAccess($member, $product_id, $quiz_id);
        if (empty($access['found'])) {
            return $this->System->getResponse([MESSAGE => 'Bài tập này không thuộc khóa học.']);
        }
        if (empty($access['allowed'])) {
            return $this->System->getResponse([MESSAGE => 'Bài tập này dành cho học viên đã đăng ký khóa học.']);
        }

        // điểm do máy chủ chấm khi bài làm ghi vị trí câu hỏi (trình làm bài trên trang khóa học), nếu không giữ như gửi lên
        $answers = !empty($data['answers']) && is_string($data['answers']) ? $data['answers'] : '[]';
        $score = $this->gradeAnswers($quiz_id, json_decode($answers, true));
        if (empty($score)) {
            return $this->System->getResponse([MESSAGE => 'Dữ liệu bài làm không hợp lệ. Vui lòng thử lại.']);
        }

        $data_save = array_merge([
            'class_room_id' => $access['class_room_id'],
            'member_code' => !empty($member['code']) ? (string)$member['code'] : '',
            'quiz_id' => $quiz_id,
            'product_id' => $product_id,
            'customer_id' => intval($member['id']),
            'lesson_name' => !empty($data['lesson_name']) ? mb_substr(trim(strip_tags((string)$data['lesson_name'])), 0, 255) : null,
            'lesson_code' => !empty($data['lesson_code']) ? mb_substr(trim(strip_tags((string)$data['lesson_code'])), 0, 255) : null,
            'answers' => $answers,
            'total_time' => max(0, intval($data['total_time'] ?? 0)),
            'ip' => $this->controller->getRequest()->clientIp()
        ], $score);
        
        $quiz_answer = $table->newEntity($data_save);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
                        
            $save = $table->save($quiz_answer);
            if (empty($save->id)){
                throw new Exception();
            }
            
            $conn->commit();

            return $this->System->getResponse([
                CODE => SUCCESS, 
                DATA => $table->parseDetailQuizsAnswer($save),
                MESSAGE => "Thành công!"
            ]);
        }catch (Exception $e) {
            $conn->rollback();

            $message = !empty($e->getMessage()) ? $e->getMessage() : "";
            return $this->System->getResponse([MESSAGE => $message]);
        }
    }

    /** Bài tập có trong một buổi của khóa học không, và học viên có được làm không:
     *  đề làm thử miễn phí thì ai cũng làm được, đề còn lại dành cho học viên của khóa
     *  (lớp học cũ có mã học viên, hoặc ghi danh còn hiệu lực trong course_enrollments).
     *  Trả về ['found' => bool, 'allowed' => bool, 'class_room_id' => id lớp học cũ hoặc 0]; $member rỗng là khách chưa đăng nhập.
    */
    public function courseQuizAccess($member = [], $product_id = 0, $quiz_id = 0)
    {
        $result = ['found' => false, 'allowed' => false, 'class_room_id' => 0];
        if (empty($product_id) || empty($quiz_id)) return $result;
        if (\App\Service\CourseTypes::kind((int)$product_id) !== 'quiz'
            || !\App\Service\CourseTypes::publicCourse((int)$product_id)
            || \App\Service\CourseTypes::privateQuiz((int)$quiz_id)) return $result;
        $slot = \App\Service\CourseTypes::slot((int)$product_id, (int)$quiz_id);
        if (!$slot) return $result;
        $quiz = \App\Lib\QuizQuestions::load((int)$quiz_id);
        if (!$quiz || ((int)$slot['slot'] === 1 && count($quiz['questions']) !== 30)) return $result;

        $lessons = TableRegistry::get('ProductsAttribute')->find()->where([
            'product_id' => $product_id,
            'attribute_id' => 11 // attributes.code = danhsachtiethoc
        ])->select(['value'])->first();

        $free = null;
        foreach (LessonQuizzes::lessons(!empty($lessons['value']) ? $lessons['value'] : null) as $lesson) {
            foreach (LessonQuizzes::of($lesson) as $quiz) {
                if ($quiz['id'] === $quiz_id) $free = (int)$slot['slot'] === 1;
            }
        }
        if (is_null($free)) return $result;
        $result['found'] = true;

        if (!empty($member['code'])) {
            $class_room = TableRegistry::get('ClassRooms')->find()->where([
                'deleted' => 0,
                'product_id' => $product_id,
                'users LIKE' => '%' . $member['code'] . '%'
            ])->select(['id'])->first();
            if (!empty($class_room['id'])) $result['class_room_id'] = intval($class_room['id']);
        }

        $enrolled = !empty($member['id']) && !empty(TableRegistry::get('CourseEnrollments')->activeCourses($member['id'])[$product_id]);
        $result['allowed'] = $free || !empty($result['class_room_id']) || $enrolled;
        return $result;
    }

    /** Chấm bài theo vị trí câu hỏi (App\Lib\QuizQuestions, như trình làm bài đánh số):
     *  $answers = [['index' => vị trí câu từ 0, 'answer' => 1-5, 'code' => mã câu], ...] chỉ gồm câu đã chọn.
     *  Trả về null khi bài làm không ghi vị trí câu (cách gửi cũ).
    */
    private function gradeAnswers($quiz_id = 0, $answers = null)
    {
        if (empty($quiz_id) || !is_array($answers)) return null;
        foreach ($answers as $answer) {
            if (!is_array($answer) || !isset($answer['index']) || !is_numeric($answer['index'])) return null;
        }

        // Access was checked above. Course quizzes are deliberately hidden from standalone ORM queries.
        $quiz = QuizQuestions::load((int)$quiz_id);
        $questions = $quiz['questions'] ?? [];
        if (empty($questions)) return null;

        $correct = 0;
        $seen = [];
        foreach ($answers as $answer) {
            $index = intval($answer['index']);
            if (isset($seen[$index]) || empty($questions[$index])) continue;
            $seen[$index] = true;
            if ($questions[$index]['answer'] > 0 && intval($answer['answer'] ?? 0) === $questions[$index]['answer']) $correct++;
        }

        $total = count($questions);
        return [
            'answer_total' => $total,
            'answer_correct' => $correct,
            'answer_wrong' => $total - $correct,
            'answer_correct_percent' => round($correct / $total * 100, 2)
        ];
    }
}
