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

}