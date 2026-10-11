<?php
namespace App\Model\Table;

use Cake\ORM\Query;
use Cake\ORM\Table;
use Cake\ORM\TableRegistry;
use Cake\Validation\Validator;
use Cake\Utility\Hash;
use Cake\Cache\Cache;

class BrandsTable extends AppTable
{
    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->setTable('brands');
        $this->setPrimaryKey('id');

        $this->addBehavior('UnixTimestamp', [
            'events' => [
                'Model.beforeSave' => [
                    'created' => 'new',
                    'updated' => 'always'
                ]
            ]
        ]);

        $this->hasOne('BrandsContent', [
            'className' => 'BrandsContent',
            'foreignKey' => 'brand_id',
            'propertyName' => 'BrandsContent'
        ]);

        $this->hasOne('Links', [
            'className' => 'Links',
            'foreignKey' => 'foreign_id',
            'propertyName' => 'Links'
        ]);

        $this->belongsTo('User', [
            'className' => 'Publishing.Users',
            'foreignKey' => 'created_by',
            'joinType' => 'LEFT',
            'propertyName' => 'User'
        ]);
    }

    public function validationDefault(Validator $validator): Validator
    {
        $validator
            ->integer('id')
            ->allowEmptyString('id', null, 'create');

        return $validator;
    }

    public function queryListBrands($params = []) 
    {
        // get info params
        $field = !empty($params[FIELD]) ? $params[FIELD] : SIMPLE_INFO;
        $get_user = !empty($params['get_user']) ? $params['get_user'] : false;

        // sort
        $sort = !empty($params[SORT]) ? $params[SORT] : [];
        $sort_field = !empty($sort[FIELD]) ? $sort[FIELD] : null;
        $sort_type = !empty($sort[SORT]) ? $sort[SORT] : DESC;

        // filter
        $filter = !empty($params[FILTER]) ? $params[FILTER] : [];
        $lang = !empty($filter[LANG]) ? $filter[LANG] : TableRegistry::get('Languages')->getDefaultLanguage();
        $keyword = !empty($filter['keyword']) ? trim($filter['keyword']) : null;
        $status = isset($filter['status']) && $filter['status'] != '' ? intval($filter['status']) : null;
       
        $ids = !empty($filter['ids']) && is_array($filter['ids']) ? $filter['ids'] : [];
        $not_ids = !empty($filter['not_ids']) && is_array($filter['not_ids']) ? $filter['not_ids'] : [];
        
        // fields select
        switch($field){
            case FULL_INFO:
                $fields = ['Brands.id', 'Brands.image_avatar', 'Brands.images', 'Brands.url_video', 'Brands.type_video', 'Brands.files', 'Brands.created_by', 'Brands.created', 'Brands.position', 'Brands.status', 'BrandsContent.name', 'BrandsContent.content', 'BrandsContent.seo_title', 'BrandsContent.seo_description', 'BrandsContent.seo_keyword', 'BrandsContent.lang', 'Links.id', 'Links.url'];
            break;

            case LIST_INFO:
                $fields = ['Brands.id', 'BrandsContent.name'];
            break;

            case SIMPLE_INFO:
            default:
                $fields = ['Brands.id', 'Brands.image_avatar', 'Brands.images', 'Brands.url_video', 'Brands.type_video', 'Brands.files', 'Brands.created_by', 'Brands.created', 'Brands.position', 'Brands.status', 'BrandsContent.name', 'Links.id', 'Links.url'];
            break;
        }

        $where = ['Brands.deleted' => 0];
        
        //contain        
        $contain = [
            'BrandsContent' => function ($q) use ($lang) {
                return $q->where([
                    'BrandsContent.lang' => $lang
                ]);
            }, 
            'Links' => function ($q) use ($lang) {
                return $q->where([
                    'Links.type' => BRAND_DETAIL,
                    'Links.lang' => $lang,
                    'Links.deleted' => 0
                ]);
            } 
        ];


        // filter by conditions  
        if(!empty($keyword)){
            $where['BrandsContent.search_unicode LIKE'] = '%' . Text::slug(strtolower($keyword), ' ') . '%';
        }

        if(!empty($ids)){
            $where['Brands.id IN'] = $ids;
        }

        if(!empty($not_ids)){
            $where['Brands.id NOT IN'] = $not_ids;
        }

        if(!is_null($status)){
            $where['Brands.status'] = $status;
        }

        if(!empty($get_user)){
            $fields[] = 'User.id';
            $fields[] = 'User.full_name';

            $contain[] = 'User';
        }

        // sort by
        $sort_string = 'Brands.id DESC';
        if(!empty($params[SORT])){
            switch($sort_field){
                case 'id':
                case 'brand_id':
                    $sort_string = 'Brands.id '. $sort_type;
                break;

                case 'name':
                    $sort_string = 'BrandsContent.name '. $sort_type .', Brands.position DESC, Brands.id DESC';
                break;

                case 'status':
                    $sort_string = 'Brands.status '. $sort_type .', Brands.position DESC, Brands.id DESC';
                break;

                case 'position':
                    $sort_string = 'Brands.position '. $sort_type .', Brands.id DESC';
                break;

                case 'created':
                    $sort_string = 'Brands.created '. $sort_type .', Brands.position DESC, Brands.id DESC';
                break;

                case 'updated':
                    $sort_string = 'Brands.updated '. $sort_type .', Brands.position DESC, Brands.id DESC';
                break;

                case 'created_by':
                    $sort_string = 'Brands.created_by '. $sort_type .', Brands.position DESC, Brands.id DESC';
                break;             
            }
        }

        return $this->find()->contain($contain)->where($where)->select($fields)->group('Brands.id')->order($sort_string);
    }

    public function getDetailBrand($id = null, $lang = null, $params = [])
    {
        $result = [];
        if(empty($id) || empty($lang)) return [];        

        $get_user = !empty($params['get_user']) ? true : false;
        $status = !empty($params['status']) ? intval($params['status']) : null;

        $contain = [
            'BrandsContent' => function ($q) use ($lang) {
                return $q->where([
                    'BrandsContent.lang' => $lang
                ]);
            }, 
            'Links' => function ($q) use ($lang) {
                return $q->where([
                    'Links.type' => BRAND_DETAIL,
                    'Links.lang' => $lang,
                    'Links.deleted' => 0
                ]);
            }
        ];


        $where = [
            'Brands.id' => $id,
            'Brands.deleted' => 0,
        ];
        if(!is_null($status)) {
            $where['Brands.status'] = $status;
        }

        if($get_user){
            $contain[] = 'User';
        }

        $result = $this->find()->contain($contain)->where($where)->first();

        return $result;
    }

    public function formatDataBrandDetail($data = [], $lang = null)
    {
        if(empty($data) || empty($lang)) return [];

        $result = [
            'id' => !empty($data['id']) ? intval($data['id']) : null,
            'image_avatar' => !empty($data['image_avatar']) ? $data['image_avatar'] : null,
            'images' => !empty($data['images']) ? json_decode($data['images'], true) : null,
            'url_video' => !empty($data['url_video']) ? $data['url_video'] : null,
            'type_video' => !empty($data['type_video']) ? $data['type_video'] : null,
            'files' => !empty($data['files']) ? json_decode($data['files'], true) : null,
            'created_by' => !empty($data['created_by']) ? intval($data['created_by']) : null,
            'created_by_user' => !empty($data['User']['full_name']) ? $data['User']['full_name'] : null,
            'created' => !empty($data['created']) ? $data['created'] : null,
            'updated' => !empty($data['updated']) ? $data['created'] : null,
            'position' => !empty($data['position']) ? intval($data['position']) : null,
            'status' => isset($data['status']) ? intval($data['status']) : null,
            
            'name' => !empty($data['BrandsContent']['name']) ? $data['BrandsContent']['name'] : null,            
            'content' => !empty($data['BrandsContent']['content']) ? $data['BrandsContent']['content'] : null,

            'seo_title' => !empty($data['BrandsContent']['seo_title']) ? $data['BrandsContent']['seo_title'] : null,
            'seo_description' => !empty($data['BrandsContent']['seo_description']) ? $data['BrandsContent']['seo_description'] : null,
            'seo_keyword' => !empty($data['BrandsContent']['seo_keyword']) ? $data['BrandsContent']['seo_keyword'] : null,
            'lang' => !empty($data['BrandsContent']['lang']) ? $data['BrandsContent']['lang'] : null,

            'url_id' => !empty($data['Links']['id']) ? intval($data['Links']['id']) : null,
            'url' => !empty($data['Links']['url']) ? $data['Links']['url'] : null,
        ];

        if(!empty($data['User'])){
            $result['user_full_name'] = !empty($data['User']['full_name']) ? $data['User']['full_name'] : null;
        }

        return $result;
    }

    public function checkExistName($name = null, $id = null)
    {
        if(empty($name)) return false;

        $where = [
            'deleted' => 0,
            'name' => $name,            
        ];

        if(!empty($id)){
            $where['id !='] = $id;
        }
        $brand = $this->find()->where($where)->first();

        return !empty($brand->id) ? true : false;
    }

    public function getListBrands($lang = null)
    {
        if(empty($lang)) $lang = TableRegistry::get('Languages')->getDefaultLanguage();

        $cache_key = BRAND . '_list' . '_' . $lang ;
        $result = Cache::read($cache_key);
        if(is_null($result)){
            $brands = $this->queryListBrands([
                FILTER => [
                    'status' => 1,
                    LANG => $lang
                ],
                FIELD => LIST_INFO
            ])->limit(1000)->toList();        
            $result = Hash::combine($brands, '{n}.id', '{n}.BrandsContent.name');

            Cache::write($cache_key, !empty($result) ? $result : []);
        }

        return $result;
    }


    public function getAllNameContent($brand_id = null)
    {
        if(empty($brand_id)) return false;

        $brands = $this->find()->where([
            'Brands.id' => $brand_id,
            'Brands.deleted' => 0
        ])->contain(['BrandsContent'])->select(['BrandsContent.lang', 'BrandsContent.name'])->toList();

        $result = Hash::combine($brands, '{*}.BrandsContent.lang', '{*}.BrandsContent.name');        
        return !empty($result) ? $result : null;
    }






}