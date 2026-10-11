<?php
namespace App\Model\Table;

use Cake\ORM\Query;
use Cake\ORM\Table;
use Cake\ORM\TableRegistry;
use Cake\Validation\Validator;
use Cake\Utility\Hash;

class CategoriesQuizTable extends Table
{
    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->setTable('categories_quiz');
        $this->setPrimaryKey('id');

    }

    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->integer('id')
            ->allowEmptyString('id', null, 'create');

        return $validator;
    }

    public function getListQuizIds($category_id = null)
    {
        if(empty($category_id)) return [];
        $table = TableRegistry::get('CategoriesQuiz');


        $quiz_ids = $table->find()->where(['category_id' => $category_id])->select(['quiz_id'])->toList();
        $result = !empty($quiz_ids) ? Hash::extract($quiz_ids, '{n}.quiz_id') : [];
        return $result;
    }
}