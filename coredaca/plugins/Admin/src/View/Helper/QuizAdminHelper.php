<?php
declare(strict_types=1);

namespace Admin\View\Helper;

use Cake\View\Helper;
use Cake\Core\Configure;
use Cake\ORM\TableRegistry;

class QuizAdminHelper extends Helper
{   

    public function getDetailQuiz($quiz_id = null, $lang = null, $params = [])
    {
        $table = TableRegistry::get('Quizs');
        $quiz = $table->getDetailQuiz($quiz_id, $lang, $params);

        $result = [];
        if(!empty($quiz)){
        	$result = $table->formatDataQuizDetail($quiz, $lang);
        }
        return $result;
    }

    public function getAllNameContent($quiz_id = null)
    {
        if(empty($quiz_id)) return [];
        $result = TableRegistry::get('Quizs')->getAllNameContent($quiz_id);
        return $result;
    }
}
