<?php

namespace App\Controller\Component;

use Cake\Controller\Component;
use Cake\Controller\ComponentRegistry;
use Cake\ORM\TableRegistry;
use Cake\Datasource\ConnectionManager;
use Cake\Core\Exception\Exception;

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
                      
        $data_save = [
            'class_room_id' => $data['class_room_id'],
            'member_code' => $data['member_code'],
            'quiz_id' => $data['quiz_id'],
            'product_id' => $data['product_id'],
            'customer_id' => $data['customer_id'],
            'lesson_name' => $data['lesson_name'],
            'lesson_code' => $data['lesson_code'],
            'answers' => $data['answers'],
            'answer_total' => intval($data['answer_total']),
            'answer_correct' => intval($data['answer_correct']),
            'answer_wrong' => intval($data['answer_wrong']),
            'answer_correct_percent' => floatval($data['answer_correct_percent']),
            'total_time' => intval($data['total_time']),
            'ip' => $this->controller->getRequest()->clientIp()
        ];
        
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
}
