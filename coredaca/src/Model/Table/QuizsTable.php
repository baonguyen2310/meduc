<?php
namespace App\Model\Table;

use Cake\ORM\Query;
use Cake\ORM\Table;
use Cake\ORM\TableRegistry;
use Cake\Validation\Validator;
use App\Model\Behavior\UnixTimestampBehavior;
use Cake\Utility\Text;
use Cake\Utility\Hash;

class QuizsTable extends AppTable
{
    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->setTable('quizs');

        $this->setPrimaryKey('id');

        $this->addBehavior('UnixTimestamp', [
            'events' => [
                'Model.beforeSave' => [
                    'created' => 'new',
                    'updated' => 'existing'
                ]
            ]
        ]);

        $this->hasOne('QuizsContent', [
            'className' => 'QuizsContent',
            'foreignKey' => 'quiz_id',
            'propertyName' => 'QuizsContent'
        ]);

        $this->hasOne('Links', [
            'className' => 'Links',
            'foreignKey' => 'foreign_id',
            'propertyName' => 'Links'
        ]);

        $this->belongsTo('User', [
            'className' => 'Users',
            'foreignKey' => 'created_by',
            'propertyName' => 'User'
        ]);

        $this->hasOne('CategoryQuiz', [
            'className' => 'CategoriesQuiz',
            'foreignKey' => 'quiz_id',
            'joinType' => 'LEFT',
            'propertyName' => 'CategoryQuiz'
        ]);

        $this->hasMany('CategoriesQuiz', [
            'className' => 'CategoriesQuiz',
            'foreignKey' => 'quiz_id',
            'joinType' => 'LEFT',
            'propertyName' => 'CategoriesQuiz'
        ]);

        $this->hasMany('ContentMutiple', [
            'className' => 'QuizsContent',
            'foreignKey' => 'quiz_id',
            'joinType' => 'LEFT',
            'propertyName' => 'ContentMutiple'
        ]);

        $this->hasMany('LinksMutiple', [
            'className' => 'Links',
            'foreignKey' => 'foreign_id',
            'joinType' => 'LEFT',
            'conditions' => [
                'LinksMutiple.type' => QUIZ_DETAIL,
                'LinksMutiple.deleted' => 0
            ],
            'propertyName' => 'LinksMutiple'
        ]);

        $this->hasOne('SingleAttribute', [
            'className' => 'Publishing.QuizsAttribute',
            'foreignKey' => 'quiz_id',
            'joinType' => 'INNER',
            'propertyName' => 'SingleAttribute'
        ]);

        $this->hasMany('QuizsAttribute', [
            'className' => 'QuizsAttribute',
            'foreignKey' => 'quiz_id',
            'joinType' => 'LEFT',
            'propertyName' => 'QuizsAttribute'
        ]);

        $this->hasMany('TagsRelation', [
            'className' => 'TagsRelation',
            'foreignKey' => 'foreign_id',
            'conditions' => [
                'TagsRelation.type' => QUIZ_DETAIL
            ],
            'joinType' => 'LEFT',
            'propertyName' => 'TagsRelation'
        ]);

        $this->hasOne('TagQuiz', [
            'className' => 'TagsRelation',
            'foreignKey' => 'foreign_id',
            'conditions' => [
                'TagQuiz.type' => QUIZ_DETAIL
            ],
            'joinType' => 'LEFT',
            'propertyName' => 'TagQuiz'
        ]);
    }

    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->integer('id')
            ->allowEmptyString('id', null, 'create');

        return $validator;
    }

    public function queryListQuizs($params = []) 
    {
        $table = TableRegistry::get('Quizs');

        // get info params
        $field = !empty($params[FIELD]) ? $params[FIELD] : SIMPLE_INFO;
        $get_user = !empty($params['get_user']) ? $params['get_user'] : false;
        $get_categories = !empty($params['get_categories']) ? true : false;
        $get_attributes = !empty($params['get_attributes']) ? true : false;
        $get_empty_name = !empty($params['get_empty_name']) ? true : false;

        // sort
        $sort = !empty($params[SORT]) ? $params[SORT] : [];
        $sort_field = !empty($sort[FIELD]) ? $sort[FIELD] : null;
        $sort_type = !empty($sort[SORT]) ? $sort[SORT] : DESC;

        // filter
        $filter = !empty($params[FILTER]) ? $params[FILTER] : [];
        $lang = !empty($filter[LANG]) ? $filter[LANG] : TableRegistry::get('Languages')->getDefaultLanguage();
        $keyword = !empty($filter['keyword']) ? trim($filter['keyword']) : null;
        $status = isset($filter['status']) && $filter['status'] != '' ? intval($filter['status']) : null;
        $has_album = isset($filter['has_album']) && $filter['has_album'] != '' ? intval($filter['has_album']) : null;
        $has_video = isset($filter['has_video']) && $filter['has_video'] != '' ? intval($filter['has_video']) : null;
        $has_file = isset($filter['has_file']) && $filter['has_file'] != '' ? intval($filter['has_file']) : null;
        $featured = isset($filter['featured']) && $filter['featured'] != '' ? intval($filter['featured']) : null;
        $catalogue = isset($filter['catalogue']) && $filter['catalogue'] != '' ? intval($filter['catalogue']) : null;
        $seo_score = !empty($filter['seo_score']) ? trim($filter['seo_score']) : null;
        $keyword_score = !empty($filter['keyword_score']) ? trim($filter['keyword_score']) : null;
        $ids = !empty($filter['ids']) && is_array($filter['ids']) ? $filter['ids'] : [];
        $not_ids = !empty($filter['not_ids']) && is_array($filter['not_ids']) ? $filter['not_ids'] : [];
        $id_categories = !empty($filter['id_categories']) && is_array($filter['id_categories']) ? $filter['id_categories'] : [];
        $tag_id = !empty($filter['tag_id']) ? intval($filter['tag_id']) : null;
        $create_from = !empty($filter['create_from']) ? strtotime(date('Y-m-d 00:00:00', strtotime(str_replace('/', '-', $filter['create_from'])))) : null;
        $create_to = !empty($filter['create_to']) ? strtotime(date('Y-m-d 23:59:59', strtotime(str_replace('/', '-', $filter['create_to'])))) : null;

        // fields select
        switch($field){
            case FULL_INFO:
                $fields = ['Quizs.id', 'Quizs.image_avatar', 'Quizs.images', 'Quizs.url_video', 'Quizs.type_video', 'Quizs.files', 'Quizs.view', 'Quizs.like', 'Quizs.comment', 'Quizs.created_by', 'Quizs.created', 'Quizs.position', 'Quizs.featured', 'Quizs.catalogue', 'Quizs.seo_score', 'Quizs.keyword_score', 'Quizs.status', 'Quizs.draft', 'QuizsContent.name', 'QuizsContent.description', 'QuizsContent.content', 'QuizsContent.seo_title', 'QuizsContent.seo_description', 'QuizsContent.seo_keyword', 'QuizsContent.lang', 'Links.id', 'Links.url'];
            break;

            case LIST_INFO:
                $fields = ['Quizs.id', 'QuizsContent.name'];
            break;

            case SIMPLE_INFO:
            default:
                $fields = ['Quizs.id', 'Quizs.image_avatar', 'Quizs.images', 'Quizs.url_video', 'Quizs.type_video', 'Quizs.view', 'Quizs.files', 'Quizs.has_album', 'Quizs.has_file', 'Quizs.has_video', 'Quizs.created_by', 'Quizs.created', 'Quizs.position', 'Quizs.featured', 'Quizs.catalogue', 'Quizs.seo_score', 'Quizs.keyword_score', 'Quizs.status', 'Quizs.draft', 'QuizsContent.name', 'QuizsContent.description', 'Links.id', 'Links.url'];
            break;
        }

        $where = ['Quizs.deleted' => 0];
        
        //contain        
        if(!$get_empty_name){
            $contain = ['QuizsContent', 'Links'];

            $where['QuizsContent.lang'] = $lang;
            $where['Links.lang'] = $lang;
            $where['Links.type'] = QUIZ_DETAIL;
            $where['Links.deleted'] = 0;
        }else{
            $contain = [
                'QuizsContent' => function ($q) use ($lang) {
                    return $q->where([
                        'QuizsContent.lang' => $lang
                    ]);
                }, 
                'Links' => function ($q) use ($lang) {
                    return $q->where([
                        'Links.type' => QUIZ_DETAIL,
                        'Links.lang' => $lang,
                        'Links.deleted' => 0
                    ]);
                } 
            ];            
        }


        // filter by conditions  
        if(!empty($keyword)){
            $where['QuizsContent.search_unicode LIKE'] = '%' . Text::slug(strtolower($keyword), ' ') . '%';
        }

        if(!empty($ids)){
            $where['Quizs.id IN'] = $ids;
        }

        if(!empty($not_ids)){
            $where['Quizs.id NOT IN'] = $not_ids;
        }

        if(!empty($id_categories)){
            // lay id danh muc con
            $all_category_ids = [];
            foreach($id_categories as $category_id){
                $child_category_ids = TableRegistry::get('Categories')->getAllChildCategoryId($category_id);
                $all_category_ids = array_unique(array_merge($all_category_ids, $child_category_ids));
            }

            $contain[] = 'CategoryQuiz';
            $where['CategoryQuiz.category_id IN'] = $all_category_ids;
        }

        if(!empty($tag_id)){
            $contain[] = 'TagQuiz';
            $where['TagQuiz.tag_id'] = $tag_id;
        }

        $can_view_draft = defined('CAN_VIEW_DRAFT') && CAN_VIEW_DRAFT;
        if($can_view_draft && !defined('LANGUAGE_ADMIN')){
            if(!is_null($status) && $status == 1){
                $where['OR'] = [
                    'Quizs.status' => 1,
                    'Quizs.draft' => 1
                ];
            } elseif(!is_null($status)) {
                $where['Quizs.status'] = $status;
            }
        } else {
            if(!is_null($status)){
                $where['Quizs.status'] = $status;
            }
            if(!defined('LANGUAGE_ADMIN')){
                $where[] = '(Quizs.draft = 0 OR Quizs.draft IS NULL)';
            }
        }

        if(!is_null($featured)){
            $where['Quizs.featured'] = $featured;
        }

        if(!is_null($has_album)){
            $where['Quizs.has_album'] = $has_album;
        }

        if(!is_null($has_video)){
            $where['Quizs.has_video'] = $has_video;
        }

        if(!is_null($has_file)){
            $where['Quizs.has_file'] = $has_file;
        }

        if(!is_null($catalogue)){
            $where['Quizs.catalogue'] = $catalogue;
        }

        if(!empty($seo_score)){
            $where['Quizs.seo_score'] = $seo_score;
        }

        if(!empty($keyword_score)){
            $where['Quizs.keyword_score'] = $keyword_score;
        }

        if(!empty($create_from)){
            $where['Quizs.created >='] = $create_from;
        }

        if(!empty($create_to)){
            $where['Quizs.created <='] = $create_to;
        }

        if(!empty($get_user)){
            $fields[] = 'User.id';
            $fields[] = 'User.full_name';

            $contain[] = 'User';
        }

        if(!empty($get_categories)){
            $contain[] = 'CategoriesQuiz';
        }

        if($get_attributes){
            $contain[] = 'QuizsAttribute';
        }

        if(!empty($get_tags)){
            $contain[] = 'TagQuiz';
        }

        // sort by
        $sort_string = 'Quizs.id DESC';
        if(!empty($params[SORT])){
            switch($sort_field){
                case 'id':
                case 'quiz_id':
                    $sort_string = 'Quizs.id '. $sort_type;
                break;

                case 'name':
                    $sort_string = 'QuizsContent.name '. $sort_type .', Quizs.position DESC, Quizs.id DESC';
                break;

                case 'status':
                    $sort_string = 'Quizs.status '. $sort_type .', Quizs.position DESC, Quizs.id DESC';
                break;

                case 'view':
                    $sort_string = 'Quizs.view '. $sort_type .', Quizs.id DESC';
                break;

                case 'position':
                    $sort_string = 'Quizs.position '. $sort_type .', Quizs.id DESC';
                break;

                case 'created':
                    $sort_string = 'Quizs.created '. $sort_type .', Quizs.position DESC, Quizs.id DESC';
                break;

                case 'updated':
                    $sort_string = 'Quizs.updated '. $sort_type .', Quizs.position DESC, Quizs.id DESC';
                break;

                case 'featured':
                    $sort_string = 'Quizs.featured '. $sort_type .', Quizs.position DESC, Quizs.id DESC';
                break;

                case 'created_by':
                    $sort_string = 'Quizs.created_by '. $sort_type .', Quizs.position DESC, Quizs.id DESC';
                break;             
            }
        }

        return $table->find()->contain($contain)->where($where)->select($fields)->group('Quizs.id')->order($sort_string);
    }

    public function getDetailQuiz($id = null, $lang = null, $params = [])
    {
        $result = [];
        if(empty($id) || empty($lang)) return [];        

        $get_user = !empty($params['get_user']) ? true : false;
        $get_categories = !empty($params['get_categories']) ? true : false;
        $get_tags = !empty($params['get_tags']) ? true : false;
        $get_attributes = !empty($params['get_attributes']) ? true : false;
        $status = !empty($params['status']) ? intval($params['status']) : null;

        $contain = [
            'QuizsContent' => function ($q) use ($lang) {
                return $q->where([
                    'QuizsContent.lang' => $lang
                ]);
            }, 
            'Links' => function ($q) use ($lang) {
                return $q->where([
                    'Links.type' => QUIZ_DETAIL,
                    'Links.lang' => $lang,
                    'Links.deleted' => 0
                ]);
            }
        ];


        $where = [
            'Quizs.id' => $id,
            'Quizs.deleted' => 0,
        ];
        if(!is_null($status)) {
            $where['Quizs.status'] = $status;
        }

        if($get_user){
            $contain[] = 'User';
        }

        if($get_categories){
            $contain[] = 'CategoriesQuiz';
        }

        if($get_attributes){
            $contain[] = 'QuizsAttribute';
        }

        if($get_tags){
            $contain[] = 'TagsRelation';
        }

        $result = TableRegistry::get('Quizs')->find()->contain($contain)->where($where)->first();

        return $result;
    }

    public function formatDataQuizDetail($data = [], $lang = null)
    {
        if(empty($data) || empty($lang)) return [];
        $result = [
            'id' => !empty($data['id']) ? intval($data['id']) : null,
            'image_avatar' => !empty($data['image_avatar']) ? $data['image_avatar'] : null,
            'images' => !empty($data['images']) ? json_decode($data['images'], true) : null,
            'url_video' => !empty($data['url_video']) ? $data['url_video'] : null,
            'type_video' => !empty($data['type_video']) ? $data['type_video'] : null,
            'files' => !empty($data['files']) ? json_decode($data['files'], true) : null,
            'view' => !empty($data['view']) ? intval($data['view']) : null,
            'like' => !empty($data['like']) ? intval($data['like']) : null,
            'main_category_id' => !empty($data['main_category_id']) ? intval($data['main_category_id']) : null,
            'has_album' => !empty($data['has_album']) ? 1 : 0,
            'has_file' => !empty($data['has_file']) ? 1 : 0,
            'has_video' => !empty($data['has_video']) ? 1 : 0,
            'comment' => !empty($data['comment']) ? intval($data['comment']) : null,
            'created_by' => !empty($data['created_by']) ? intval($data['created_by']) : null,
            'created_by_user' => !empty($data['User']['full_name']) ? $data['User']['full_name'] : null,
            'created' => !empty($data['created']) ? date('H:i - d/m/Y', $data['created']) : null,
            'updated' => !empty($data['updated']) ? date('H:i - d/m/Y', $data['updated']) : null,
            'position' => !empty($data['position']) ? intval($data['position']) : null,
            'featured' => !empty($data['featured']) ? 1 : 0,
            'catalogue' => !empty($data['catalogue']) ? 1 : 0,
            'seo_score' => !empty($data['seo_score']) ? $data['seo_score'] : null,
            'keyword_score' => !empty($data['keyword_score']) ? $data['keyword_score'] : null,
            'draft' => !empty($data['draft']) ? 1 : 0,
            'status' => isset($data['status']) ? intval($data['status']) : null,
            
            'name' => !empty($data['QuizsContent']['name']) ? $data['QuizsContent']['name'] : null,
            'description' => !empty($data['QuizsContent']['description']) ? $data['QuizsContent']['description'] : null,
            'content' => !empty($data['QuizsContent']['content']) ? $data['QuizsContent']['content'] : null,
            'tags' => [],

            'seo_title' => !empty($data['QuizsContent']['seo_title']) ? $data['QuizsContent']['seo_title'] : null,
            'seo_description' => !empty($data['QuizsContent']['seo_description']) ? $data['QuizsContent']['seo_description'] : null,
            'seo_keyword' => !empty($data['QuizsContent']['seo_keyword']) ? $data['QuizsContent']['seo_keyword'] : null,
            'lang' => !empty($data['QuizsContent']['lang']) ? $data['QuizsContent']['lang'] : null,

            'url_id' => !empty($data['Links']['id']) ? intval($data['Links']['id']) : null,
            'url' => !empty($data['Links']['url']) ? $data['Links']['url'] : null,
        ];

        if(!empty($data['User'])){
            $result['user_full_name'] = !empty($data['User']['full_name']) ? $data['User']['full_name'] : null;
        }

        if(!empty($data['CategoriesQuiz'])){
            $categories = [];
            $all_categories = TableRegistry::get('Categories')->getAll(QUIZ, $lang);
            foreach ($data['CategoriesQuiz'] as $k => $category) {
                $category_id = !empty($category['category_id']) ? intval($category['category_id']) : null;
                $category_info = !empty($all_categories[$category_id]) ? $all_categories[$category_id] : [];
                if(empty($category_info)) continue;

                $categories[$category_id] = [
                    'id' => $category_id,
                    'name' => !empty($category_info['name']) ? $category_info['name'] : null,
                    'url' => !empty($category_info['url']) ? $category_info['url'] : null,
                ];
            }
            $result['categories'] = $categories;
        }

        if(!empty($data['TagsRelation'])){
            $tags = [];
            $tags_table = TableRegistry::get('Tags');
            foreach ($data['TagsRelation'] as $key => $tag) {
                $tag_id = !empty($tag['tag_id']) ? intval($tag['tag_id']) : null;
                if(empty($tag_id)) continue;
                $tag_info = $tags_table->find()->where(['id' => $tag_id])->select(['id', 'name', 'url'])->first();
                if(empty($tag_info)) continue;

                $tags[] = $tag_info;
            }

            $result['tags'] = $tags;
        }

        
        $attributes_table = TableRegistry::get('Attributes');
        $all_attributes = Hash::combine($attributes_table->getAll($lang), '{n}.id', '{n}', '{n}.attribute_type');
        $all_attributes_quiz = !empty($all_attributes[QUIZ]) ? $all_attributes[QUIZ] : [];

        if(!empty($all_attributes_quiz) && !empty($data['QuizsAttribute'])){
            $attributes = [];
            $attribute_value = Hash::combine($data['QuizsAttribute'], '{n}.attribute_id', '{n}');
            foreach ($all_attributes_quiz as $attribute_id => $attribute_info) {
                $attribute_code = !empty($attribute_info['code']) ? $attribute_info['code'] : null;
                $attribute_name = !empty($attribute_info['name']) ? $attribute_info['name'] : null;
                $attribute_input_type = !empty($attribute_info['input_type']) ? $attribute_info['input_type'] : null;
                if(empty($attribute_code) || empty($attribute_name)) continue;

                $value = !empty($attribute_value[$attribute_id]['value']) ? $attribute_value[$attribute_id]['value'] : null;
                $value = $attributes_table->formatValueAttibute($attribute_input_type, $value, $lang);
                $attributes[$attribute_code] = [
                    'id' => $attribute_id,
                    'name' => $attribute_name,
                    'value' => $value
                ];
            }
            
            $result['attributes'] = $attributes;
        }

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