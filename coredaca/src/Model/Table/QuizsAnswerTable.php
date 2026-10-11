<?php
namespace App\Model\Table;

use Cake\ORM\Query;
use Cake\ORM\Table;
use Cake\Event\Event;
use Cake\ORM\TableRegistry;
use Cake\Validation\Validator;
use App\Model\Behavior\UnixTimestampBehavior;
use Cake\Utility\Hash;
use Cake\Utility\Text;
use Cake\I18n\Time;

class QuizsAnswerTable extends AppTable
{
    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->setTable('quizs_answer');

        $this->setPrimaryKey('id');

        $this->addBehavior('UnixTimestamp', [
            'events' => [
                'Model.beforeSave' => [
                    'created' => 'new'
                ]
            ]
        ]);

        $this->hasOne('Customers', [
            'className' => 'Customers',
            'foreignKey' => 'foreign_id',
            'propertyName' => 'Customers'
        ]);
    }

    public function parseDetailQuizsAnswer($data = [])
    {
        if(empty($data)) return [];

        $created = !empty($data['created']) ? $data['created'] : null;
        $time = $this->parseTimeQuizsAnswer($created);

        $result = [
            'id' => !empty($data['id']) ? intval($data['id']) : null,
            'customer_id' => !empty($data['customer_id']) ? $data['customer_id'] : null,
            'product_id' => !empty($data['product_id']) ? $data['product_id'] : null,
            'quiz_id' => !empty($data['quiz_id']) ? $data['quiz_id'] : null,
            'answers' => !empty($data['answers']) ? $data['answers'] : null,
            'answer_total' => !empty($data['answer_total']) ? intval($data['answer_total']) : null,
            'answer_correct' => !empty($data['answer_correct']) ? intval($data['answer_correct']) : null,
            'answer_wrong' => !empty($data['answer_wrong']) ? intval($data['answer_wrong']) : null,
            'answer_correct_percent' => !empty($data['answer_correct_percent']) ? floatval($data['answer_correct_percent']) : null,
            'ip' => !empty($data['ip']) ? $data['ip'] : null,
            'created' => !empty($data['created']) ? $data['created'] : null,
            'time' => !empty($time['time']) ? $time['time'] : null,
            'full_time' => !empty($time['full_time']) ? $time['full_time'] : null,
        ];

        return $result;
    }

    public function parseTimeQuizsAnswer($time = null)
    {
        $result = [
            'time' => '',
            'full_time' => ''
        ];

        if(empty($time)){
            return $result;
        }

        $time = date('Y-m-d H:i:s', $time);
        $time_input = new Time($time);
        $now = new Time();


        $interval = $now->diff($time_input);
        if (!empty($interval->format('%i'))) {
            $result['time'] = $interval->format('%i') . ' ' . __d('template', 'phut_truoc');
        }

        if (!empty($interval->format('%h'))) {
            $result['time'] = $interval->format('%h') . ' ' . __d('template', 'gio_truoc');
        }        

        if (!empty($interval->format('%d'))) {
            $result['time'] = $interval->format('%d') . ' ' . __d('template', 'ngay_truoc');
            $result['full_time'] = date(("d \M\O\N\T\H m, Y \A\T H:i"), strtotime($time));
        }

        if (!empty($interval->format('%m'))) {
            $result['time'] = $interval->format('%m') . ' ' . __d('template', 'thang_truoc');
            $result['full_time'] = date(("d \M\O\N\T\H m, Y \A\T H:i"), strtotime($time));
        }


        if (!empty($interval->format('%y'))) {
            $result['time'] = $interval->format('%y') . ' ' . __d('template', 'nam_truoc');
            $result['full_time'] = date(("d \M\O\N\T\H m, Y \A\T H:i"), strtotime($time));
        }

        if (empty($result['time'])) {
            $result['time'] = __d('template', 'vua_xong');
        }

        $result['full_time'] = str_replace('MONTH', __d('template', 'thang'), trim($result['full_time']));
        $result['full_time'] = str_replace('AT', __d('template', 'luc'), trim($result['full_time']));

        return $result;
    }

    public function queryListQuizsAnswer($customer_id = null)
    {
        if(empty($customer_id)) return false;

        $data = TableRegistry::get('QuizsAnswer')->find()->where([
            'QuizsAnswer.customer_id' => $customer_id,
            'QuizsAnswer.deleted' => 0,
        ])->contain([])->select(['QuizsAnswer.id', 'QuizsAnswer.customer_id', 'QuizsAnswer.product_id', 'QuizsAnswer.quiz_id', 'QuizsAnswer.answers', 'QuizsAnswer.answer_total', 'QuizsAnswer.answer_correct', 'QuizsAnswer.answer_wrong', 'QuizsAnswer.answer_correct_percent', 'QuizsAnswer.total_time', 'QuizsAnswer.ip', 'QuizsAnswer.created', 'QuizsAnswer.updated', 'QuizsAnswer.deleted']);

        $result = $data;

        return !empty($result) ? $result : null;
    }

    public function queryRank()
    {
        $data = TableRegistry::get('QuizsAnswer')->find();
        
        $data->where([
            'QuizsAnswer.deleted' => 0,
        ])
        ->select([
            'QuizsAnswer.customer_id',
            'quiz_counter' => $data->func()->count('QuizsAnswer.customer_id'),
            'answer_total' => $data->func()->sum('QuizsAnswer.answer_total'),
            'answer_correct' => $data->func()->sum('QuizsAnswer.answer_correct'),
            'answer_wrong' => $data->func()->sum('QuizsAnswer.answer_wrong'),
            'total_time' => $data->func()->sum('QuizsAnswer.total_time'),
        ])
        ->group('QuizsAnswer.customer_id')
        ->order('QuizsAnswer.answer_correct ASC');

        $result = $data;

        return !empty($result) ? $result : null;
    }

    public function formatDataQuizsAnswerDetail($data = [])
    {
        if(empty($data)) return [];

        $result = [
            'customer_id' => !empty($data['customer_id']) ? intval($data['customer_id']) : null,
            'quiz_counter' => !empty($data['quiz_counter']) ? intval($data['quiz_counter']) : null,
            'answer_total' => !empty($data['answer_total']) ? intval($data['answer_total']) : null,
            'answer_correct' => !empty($data['answer_correct']) ? intval($data['answer_correct']) : null,
            'answer_wrong' => !empty($data['answer_wrong']) ? intval($data['answer_wrong']) : null,
            'total_time' => !empty($data['total_time']) ? intval($data['total_time']) : null,
        ];

        if(!empty($data['customer_id'])){
            $customer_table = TableRegistry::get('Customers');
            $customer_info = $customer_table->find()
                ->where(['id' => $data['customer_id']])
                ->select([
                    'id',
                    'code',
                    'full_name',
                    'email',
                    'phone',
                    'avatar',
                ])->first();
            $result['customer_info'] = $customer_info;
        }

        return $result;
    }
}