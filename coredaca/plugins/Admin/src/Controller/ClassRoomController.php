<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Utility\Hash;
use Cake\Http\Response;
use Cake\ORM\Query;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;


class ClassRoomController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

    public function list()
    {
        $this->css_page = [
            '/assets/plugins/global/lightbox/lightbox.css',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css'
        ];
        $this->js_page = [
            '/assets/js/pages/list_class_room.js',
            '/assets/plugins/global/lightbox/lightbox.min.js',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js'
        ];

        $this->set('path_menu', 'class-room');
        $this->set('title_for_layout', "Danh sách lớp học");
    }

    public function listJson()
    {
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');
        $utilities = $this->loadComponent('Utilities');

        $data = $params = $classRooms = [];

        $limit = PAGINATION_LIMIT_ADMIN;
        $page = 1;
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        // params query
        $params[QUERY] = !empty($data[QUERY]) ? $data[QUERY] : [];

        // params filter
        $params[FILTER] = !empty($data[DATA_FILTER]) ? $data[DATA_FILTER] : [];
        if(!empty($params[QUERY])){
            $params[FILTER] = array_merge($params[FILTER], $params[QUERY]);
        }

        // params         
        $params[SORT] = !empty($data[SORT]) ? $data[SORT] : [];

        
        // page and limit
        $page = !empty($data[PAGINATION][PAGE]) ? intval($data[PAGINATION][PAGE]) : 1;
        $limit = !empty($data[PAGINATION][PERPAGE]) ? intval($data[PAGINATION][PERPAGE]) : PAGINATION_LIMIT_ADMIN;


        // sort 
        $sort_field = !empty($params[SORT][FIELD]) ? $params[SORT][FIELD] : null;
        $sort_type = !empty($params[SORT][SORT]) ? $params[SORT][SORT] : null;

        try {
            $classRooms = $this->paginate($table->queryListClassRooms($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toArray();
        } catch (Exception $e) {
            $page = 1;
            $classRooms = $this->paginate($table->queryListClassRooms($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toArray();
        }

        // parse data before output
        $result = [];
        if(!empty($classRooms)){
            $languages = TableRegistry::get('Languages')->getList();
            foreach($classRooms as $k => $classRoom){
                $result[$k] = $table->formatDataClassRoomDetail($classRoom, $this->lang);
                
                // check multiple language
                $mutiple_language = [];
                if(!empty($languages)){
                    foreach($languages as $lang => $language){
                        if($lang == $this->lang && !empty($classRoom['name'])){
                            $mutiple_language[$lang] = true;

                        }else{
                            $content = TableRegistry::get('ClassRoomsContent')->find()->where([
                                'class_room_id' => !empty($classRoom['id']) ? intval($classRoom['id']) : null,
                                'lang' => $lang
                            ])->select(['name'])->first();
                            
                            $mutiple_language[$lang] = !empty($content['name']) ? true : false;
                        }                        
                    }
                }


                $result[$k]['mutiple_language'] = $mutiple_language;
            }
        }

        $pagination_info = !empty($this->request->getAttribute('paging')['ClassRooms']) ? $this->request->getAttribute('paging')['ClassRooms'] : [];
        $meta_info = $utilities->formatPaginationInfo($pagination_info);

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $result, 
            META => $meta_info
        ]);
    }

    public function add()
    {
        $max_record = TableRegistry::get('ClassRooms')->find()->select('id')->max('id');

        $this->set('position', !empty($max_record->id) ? $max_record->id + 1 : 1);

        $this->css_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css'
        ];

        $this->js_page = [
            '/assets/plugins/custom/tinymce6/tinymce.min.js',
            '/assets/js/pages/class_room.js',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js'
        ];

        $this->set('path_menu', 'class_room_add');
        $this->set('title_for_layout', __d('admin', 'Thêm lớp học'));
        $this->render('update');
    }

    public function update($id = null)
    {
        $table = TableRegistry::get('ClassRooms');
        $classRoom = $table->getDetailClassRoom($id, $this->lang, []);

        $classRoom = $table->formatDataClassRoomDetail($classRoom, $this->lang);

        if(empty($classRoom)){
            $this->showErrorPage();
        }
        
        $this->set('path_menu', 'class-room');
        $this->set('id', $id);
        $this->set('position', !empty($classRoom['position']) ? $classRoom['position'] : 1);
        $this->set('classRoom', $classRoom);

        $this->css_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css'
        ];

        $this->js_page = [
            '/assets/plugins/custom/tinymce6/tinymce.min.js',
            '/assets/js/pages/class_room.js',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js'
        ];
        $this->set('title_for_layout', "Cập nhật lớp học");
    }

    public function detail($id = null)
    {
        if(empty($id)){
            $this->showErrorPage();
        }

        $table = TableRegistry::get('ClassRooms');

        $class_room_detail = $table->getDetailClassRoom($id, $this->lang, [
            'get_user' => true, 
            'get_categories' => true,
            'get_tags' => true,
            'get_attributes' => true
        ]);

        if(empty($class_room_detail)){
            $this->showErrorPage();
        }

        $classRoom = $table->formatDataClassRoomDetail($class_room_detail, $this->lang);

        $this->css_page = [
            '/assets/css/pages/wizard/wizard-4.css',
            '/assets/plugins/global/lightbox/lightbox.css'
        ];
        $this->js_page = [
            '/assets/plugins/global/lightbox/lightbox.min.js'
        ];

        $this->set('class_room', $classRoom);
        $this->set('title_for_layout', __d('admin', 'chi_tiet_bai_viet'));
    }

    public function save($id = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();

        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }
        
        $utilities = $this->loadComponent('Utilities');
        $table = TableRegistry::get('ClassRooms');        

        if(!empty($id)){
            $classRoom = $table->getDetailClassRoom($id, $this->lang, []);

            if(empty($classRoom)){
                $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
            }
        }

        // validate data
        if(empty($data['name'])){
            $this->responseJson([MESSAGE => __d('admin', 'vui_long_nhap_tieu_de')]);
        }

        $status = isset($classRoom['status']) ? intval($classRoom['status']) : 1;

        $data_save = [         
            'name' => !empty($data['name']) ? trim(strip_tags($data['name'])) : null,
            'search_unicode' => strtolower($utilities->formatSearchUnicode([$data['name']])),
            'description' => !empty($data['description']) ? trim($data['description']) : null,
            'image_avatar' => null,
            'users' => !empty($data['users']) ? trim($data['users']) : null,
            'position' => !empty($data['position']) ? intval($data['position']) : 1,
            'status' => $status,
            'product_id' => !empty($data['product_id']) ? intval($data['product_id']) : null
        ];

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            $classRoomsTable = TableRegistry::getTableLocator()->get('ClassRooms');

            if(empty($id)){
                $classRoom = $classRoomsTable->newEntity($data_save);
            }else{            
                $classRoom = $classRoomsTable->patchEntity($classRoom, $data_save);
            }

            $save = $classRoomsTable->save($classRoom);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    private function translateClassRoom($class_room_id = null, $lang_from = null)
    {
        if(empty($class_room_id) || empty($lang_from)) return false;

        $languages = TableRegistry::get('Languages')->getList();
        if(empty($languages)) return false;

        $utilities = $this->loadComponent('Utilities');
        $translate_component = $this->loadComponent('Admin.Translate');

        $table = TableRegistry::get('ClassRooms');
        $links_table = TableRegistry::get('Links');
        $class_room_info = $table->getDetailClassRoom($class_room_id, $lang_from);
        if(empty($class_room_info)) return false;

        foreach($languages as $lang => $language){
            if($lang == $lang_from) continue;

            $name = !empty($class_room_info['ClassRoomsContent']['name']) ? $class_room_info['ClassRoomsContent']['name'] : null;
            $translates = $translate_component->translate([$name], $lang_from, $lang);
            
            $name_translate = !empty($translates[0]) ? $translates[0] : $name;

            $link = $utilities->formatToUrl($name_translate);
            if(empty($link)) continue;

            $link = $links_table->getUrlUnique($link);
            $data_save = [
                'id' => $class_room_id,
                'ClassRoomsContent' => [
                    'name' => $name_translate,
                    'seo_title' => $name_translate,
                    'lang' => $lang,
                    'search_unicode' => strtolower($utilities->formatSearchUnicode([$name_translate]))
                ],
                'Links' => [
                    'type' => CLASS_ROOM_DETAIL,
                    'url' => $link,
                    'lang' => $lang,
                ]
            ];

            $entity = $table->newEntity($data_save);
            if($entity->hasErrors()) continue;

            $save = $table->save($entity);
        }

        return true;
    }

    public function delete()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) ? $data['ids'] : [];

        if (!$this->getRequest()->is('post') || empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            foreach($ids as $id){

                // delete class_room
                $classRoom = $table->get($id);
                if (empty($classRoom)) {
                    throw new Exception(__d('admin', 'khong_tim_thay_thong_tin_bai_viet'));
                }

                $classRoom = $table->patchEntity($classRoom, ['id' => $id, 'deleted' => 1], ['validate' => false]);
                $delete = $table->save($classRoom);
                if (empty($delete)){
                    throw new Exception();
                }
            }

            $conn->commit();
            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'xoa_du_lieu_thanh_cong')]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function changeStatus()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) ? $data['ids'] : [];
        $status = !empty($data['status']) ? 1 : 0;

        if (!$this->getRequest()->is('post') || empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');

        $classRooms = $table->find()->where([
            'ClassRooms.id IN' => $ids,
            'ClassRooms.deleted' => 0
        ])->select(['ClassRooms.id', 'ClassRooms.status'])->toList();
        
        if(empty($classRooms)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_thong_tin_bai_viet')]);
        }

        $patch_data = [];
        foreach ($ids as $k => $class_room_id) {
            $patch_data[] = [
                'id' => $class_room_id,
                'status' => $status,
                'draft' => 0
            ];
        }

        $data_class_rooms = $table->patchEntities($classRooms, $patch_data, ['validate' => false]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $change_status = $table->saveMany($data_class_rooms);
            if (empty($change_status)){
                throw new Exception();
            }
            
            $conn->commit();
            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'cap_nhat_thanh_cong')]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function duplicate()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) ? $data['ids'] : [];

        if (!$this->getRequest()->is('post') || empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $class_rooms_table = TableRegistry::get('ClassRooms');
        $system = $this->loadComponent('System');
        $utilities = $this->loadComponent('Utilities');

        $data_dulicate = [];
        foreach($ids as $id){
            $classRoom = $class_rooms_table->find()
            ->contain([
                'ContentMutiple',
                'CategoriesClassRoom',
                'LinksMutiple'
            ])
            ->where([
                'ClassRooms.id' => $id,
                'ClassRooms.deleted' => 0,
            ])->first()->toArray();
            
            if(empty($classRoom)) continue;
            
            // format data before mere entity
            unset($classRoom['id']);
            unset($classRoom['created_by']);
            unset($classRoom['created']);
            unset($classRoom['updated']);

            unset($classRoom['view']);
            unset($classRoom['like']);
            unset($classRoom['has_album']);
            unset($classRoom['has_file']);
            unset($classRoom['has_video']);
            unset($classRoom['comment']);

            if(!empty($classRoom['ContentMutiple'])){
                foreach($classRoom['ContentMutiple'] as $k_content => $content){
                    $name = $system->getNameUnique('ClassRooms', $content['name'], 1);
                    $classRoom['ContentMutiple'][$k_content]['name'] = $name;

                    unset($classRoom['ContentMutiple'][$k_content]['id']);
                    unset($classRoom['ContentMutiple'][$k_content]['category_id']);
                }
            }

            if(!empty($classRoom['LinksMutiple'])){
                foreach($classRoom['LinksMutiple'] as $k_link => $link){
                    $classRoom['LinksMutiple'][$k_link]['url'] = $system->getUrlUnique($link['url'], 1);

                    unset($classRoom['LinksMutiple'][$k_link]['id']);
                    unset($classRoom['LinksMutiple'][$k_link]['foreign_id']);
                }
            }

            if(!empty($classRoom['CategoriesClassRoom'])){
                foreach($classRoom['CategoriesClassRoom'] as $k_category => $category_class_room){
                    unset($classRoom['CategoriesClassRoom'][$k_category]['id']);
                    $classRoom['CategoriesClassRoom'][$k_category]['class_room_id'] = null;
                }
            }
            $data_dulicate[] = $classRoom;            
        }

        $class_room_entities = $class_rooms_table->newEntities($data_dulicate, [
            'associated' => ['ContentMutiple', 'LinksMutiple', 'CategoriesClassRoom']
        ]);

        try{
            // save data
            $save = $class_rooms_table->saveMany($class_room_entities);  
            
            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'nhan_ban_du_lieu_thanh_cong')]);
        }catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }        
    }

    public function changePosition()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $id = !empty($data['id']) ? intval($data['id']) : null;
        $value = !empty($data['value']) ? $data['value'] : 0;

        if(!$this->getRequest()->is('post') || empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');
        $classRoom = $table->get($id);
        if(empty($classRoom)) {
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
        }

        $classRoom = $table->patchEntity($classRoom, ['position' => $value], ['validate' => false]);

        try{
            $save = $table->save($classRoom);

            if (empty($save->id)){
                throw new Exception();
            }
            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function autoSuggest()
    {
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $filter = !empty($data[FILTER]) ? $data[FILTER] : [];
        
        $classRooms = $table->queryListClassRooms([
            FILTER => $filter,
            FIELD => FULL_INFO
        ])->limit(10)->toList();

        $result = [];
        if(!empty($classRooms)){
            foreach($classRooms as $classRoom){
                $result[] = $table->formatDataClassRoomDetail($classRoom, $this->lang);
            }
        }
  
        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $result, 
        ]);
    }

    public function quickUpload()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();

        $id = !empty($data['id']) ? $data['id'] : null;
        $images = !empty($data['images']) ? $data['images'] : [];
        $image_avatar = !empty($data['image_avatar']) ? $data['image_avatar'] : [];

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        // validate data
        if (empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');

        $has_album = 0;
        if(!empty($images)){
            $has_album = 1;
        }

        $class_room_info = $table->find()->where([
            'id' => $id,            
            'deleted' => 0,
        ])->select(['id', 'images', 'image_avatar'])->first();

        if (empty($class_room_info)) {
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
        }

        $classRoom = $table->patchEntity($class_room_info, [
            'images' => $images,
            'image_avatar' => $image_avatar,
            'has_album' => $has_album
        ]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            // save data
            $save = $table->save($classRoom);
            if (empty($save->id)){
                throw new Exception();
            } 

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => $classRoom]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function uploadModal($id = null)
    {
        $this->viewBuilder()->enableAutoLayout(false);

        if(empty($id)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $table = TableRegistry::get('ClassRooms');   
        $classRoom = $table->find()->where([
            'id' => $id,
            'deleted' => 0,
        ])->select(['id', 'images', 'image_avatar'])->first();

        $classRoom['images'] = !empty($classRoom['images']) ? json_decode($classRoom['images'], true) : [];
        $classRoom['image_avatar'] = !empty($classRoom['image_avatar']) ? $classRoom['image_avatar'] : [];


        if(empty($classRoom)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
        }
        
        $this->set('class_room', $classRoom);
    }
}