<?php
namespace App\Model\Table;

use Cake\ORM\Query;
use Cake\ORM\Table;
use Cake\ORM\TableRegistry;
use Cake\Validation\Validator;
use App\Model\Behavior\UnixTimestampBehavior;
use Cake\Utility\Text;
use Cake\Utility\Hash;

class ClassRoomsTable extends AppTable
{
    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->setTable('class_rooms');

        $this->setPrimaryKey('id');

        $this->addBehavior('UnixTimestamp', [
            'events' => [
                'Model.beforeSave' => [
                    'created' => 'new',
                    'updated' => 'existing'
                ]
            ]
        ]);
    }

    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->integer('id')
            ->allowEmptyString('id', null, 'create');

        return $validator;
    }

    public function queryListClassRooms($params = []) 
    {
        $table = TableRegistry::get('ClassRooms');

        // get info params
        $field = !empty($params[FIELD]) ? $params[FIELD] : SIMPLE_INFO;

        // sort
        $sort = !empty($params[SORT]) ? $params[SORT] : [];
        $sort_field = !empty($sort[FIELD]) ? $sort[FIELD] : null;
        $sort_type = !empty($sort[SORT]) ? $sort[SORT] : DESC;

        // filter
        $filter = !empty($params[FILTER]) ? $params[FILTER] : [];
        $keyword = !empty($filter['keyword']) ? trim($filter['keyword']) : null;
        $status = isset($filter['status']) && $filter['status'] != '' ? intval($filter['status']) : null;
        $create_from = !empty($filter['create_from']) ? strtotime(date('Y-m-d 00:00:00', strtotime(str_replace('/', '-', $filter['create_from'])))) : null;
        $create_to = !empty($filter['create_to']) ? strtotime(date('Y-m-d 23:59:59', strtotime(str_replace('/', '-', $filter['create_to'])))) : null;

        // fields select
        switch($field){
            case FULL_INFO:
                $fields = ['ClassRooms.id', 'ClassRooms.product_id', 'ClassRooms.name', 'ClassRooms.search_unicode', 'ClassRooms.description', 'ClassRooms.image_avatar', 'ClassRooms.users', 'ClassRooms.created', 'ClassRooms.updated', 'ClassRooms.position', 'ClassRooms.status'];
            break;

            case LIST_INFO:
                $fields = ['ClassRooms.id', 'ClassRooms.name'];
            break;

            case SIMPLE_INFO:
            default:
                $fields = ['ClassRooms.id', 'ClassRooms.product_id', 'ClassRooms.name', 'ClassRooms.search_unicode', 'ClassRooms.description', 'ClassRooms.image_avatar', 'ClassRooms.users', 'ClassRooms.created', 'ClassRooms.updated', 'ClassRooms.position', 'ClassRooms.status'];
            break;
        }

        $where = ['ClassRooms.deleted' => 0];

        // filter by conditions  
        if(!empty($keyword)){
            $where['ClassRooms.search_unicode LIKE'] = '%' . Text::slug(strtolower($keyword), ' ') . '%';
        }

        if(!is_null($status)){
            $where['ClassRooms.status'] = $status;
        }

        if(!empty($create_from)){
            $where['ClassRooms.created >='] = $create_from;
        }

        if(!empty($create_to)){
            $where['ClassRooms.created <='] = $create_to;
        }

        // sort by
        $sort_string = 'ClassRooms.id DESC';
        if(!empty($params[SORT])){
            switch($sort_field){
                case 'id':
                case 'product_id':
                    $sort_string = 'ClassRooms.id '. $sort_type;
                break;

                case 'name':
                    $sort_string = 'ClassRooms.name '. $sort_type .', ClassRooms.position DESC, ClassRooms.id DESC';
                break;

                case 'status':
                    $sort_string = 'ClassRooms.status '. $sort_type .', ClassRooms.position DESC, ClassRooms.id DESC';
                break;

                case 'position':
                    $sort_string = 'ClassRooms.position '. $sort_type .', ClassRooms.id DESC';
                break;

                case 'created':
                    $sort_string = 'ClassRooms.created '. $sort_type .', ClassRooms.position DESC, ClassRooms.id DESC';
                break;

                case 'updated':
                    $sort_string = 'ClassRooms.updated '. $sort_type .', ClassRooms.position DESC, ClassRooms.id DESC';
                break;

                case 'created_by':
                    $sort_string = 'ClassRooms.created_by '. $sort_type .', ClassRooms.position DESC, ClassRooms.id DESC';
                break;             
            }
        }

        return $table->find()->where($where)->select($fields)->group('ClassRooms.id')->order($sort_string);
    }

    public function getDetailClassRoom($id = null, $lang = null, $params = [])
    {
        $result = [];
        if(empty($id) || empty($lang)) return [];        

        $status = !empty($params['status']) ? intval($params['status']) : null;

        $where = [
            'ClassRooms.id' => $id,
            'ClassRooms.deleted' => 0,
        ];
        if(!is_null($status)) {
            $where['ClassRooms.status'] = $status;
        }

        $result = TableRegistry::get('ClassRooms')->find()->where($where)->first();

        return $result;
    }

    public function formatDataClassRoomDetail($data = [], $lang = null)
    {
        if(empty($data) || empty($lang)) return [];
        $result = [
            'id' => !empty($data['id']) ? intval($data['id']) : null,
            'name' => !empty($data['name']) ? $data['name'] : null,
            'search_unicode' => !empty($data['search_unicode']) ? $data['search_unicode'] : null,
            'description' => !empty($data['description']) ? $data['description'] : null,
            'image_avatar' => !empty($data['image_avatar']) ? $data['image_avatar'] : null,
            'users' => !empty($data['users']) ? $data['users'] : null,
            'created' => !empty($data['created']) ? date('H:i - d/m/Y', $data['created']) : null,
            'updated' => !empty($data['updated']) ? date('H:i - d/m/Y', $data['updated']) : null,
            'position' => !empty($data['position']) ? intval($data['position']) : null,
            'status' => isset($data['status']) ? intval($data['status']) : null,
            'product_id' => !empty($data['product_id']) ? intval($data['product_id']) : null,
        ];

        return $result;
    }

    public function checkNameExist($name = null)
    {
        if(empty($name)) return false;
        $quiz = TableRegistry::get('Quizs')->find()->contain(['QuizsContent'])
        ->where([
            'QuizsContent.name' => $name,
            'Quizs.deleted' => 0,
        ])->first();
        return !empty($quiz) ? true : false;
    }

    public function getAllNameContent($quiz_id = null)
    {
        if(empty($quiz_id)) return false;

        $quiz = TableRegistry::get('Quizs')->find()->where([
            'Quizs.id' => $quiz_id,
            'Quizs.deleted' => 0
        ])->contain(['QuizsContent'])->select(['QuizsContent.lang', 'QuizsContent.name'])->toList();

        $result = Hash::combine($quiz, '{*}.QuizsContent.lang', '{*}.QuizsContent.name');

        return !empty($result) ? $result : null;
    }
}