<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Utility\Hash;
use Cake\Http\Response;
use Cake\ORM\Query;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;


class QuizController extends AppController {

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
            '/assets/js/pages/list_quiz.js',
            '/assets/plugins/global/lightbox/lightbox.min.js',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js'
        ];

        $this->set('path_menu', 'quiz');
        $this->set('title_for_layout', __d('admin', 'danh_sach_bai_viet'));
    }

    public function listJson()
    {
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $table = TableRegistry::get('Quizs');
        $utilities = $this->loadComponent('Utilities');

        $data = $params = $quizs = [];

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

        $params[FILTER][LANG] = !empty($params[FILTER][LANG]) ? $params[FILTER][LANG] : TableRegistry::get('Languages')->getDefaultLanguage();

        // params         
        $params[SORT] = !empty($data[SORT]) ? $data[SORT] : [];
        $params['get_user'] = true;
        $params['get_empty_name'] = true;

        
        // page and limit
        $page = !empty($data[PAGINATION][PAGE]) ? intval($data[PAGINATION][PAGE]) : 1;
        $limit = !empty($data[PAGINATION][PERPAGE]) ? intval($data[PAGINATION][PERPAGE]) : PAGINATION_LIMIT_ADMIN;


        // sort 
        $sort_field = !empty($params[SORT][FIELD]) ? $params[SORT][FIELD] : null;
        $sort_type = !empty($params[SORT][SORT]) ? $params[SORT][SORT] : null;

        try {
            $quizs = $this->paginate($table->queryListQuizs($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toArray();
        } catch (Exception $e) {
            $page = 1;
            $quizs = $this->paginate($table->queryListQuizs($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toArray();
        }

        // parse data before output
        $result = [];
        if(!empty($quizs)){
            $languages = TableRegistry::get('Languages')->getList();
            foreach($quizs as $k => $quiz){
                $result[$k] = $table->formatDataQuizDetail($quiz, $this->lang);
                
                // check multiple language
                $mutiple_language = [];
                if(!empty($languages)){
                    foreach($languages as $lang => $language){
                        if($lang == $this->lang && !empty($quiz['name'])){
                            $mutiple_language[$lang] = true;

                        }else{
                            $content = TableRegistry::get('QuizsContent')->find()->where([
                                'quiz_id' => !empty($quiz['id']) ? intval($quiz['id']) : null,
                                'lang' => $lang
                            ])->select(['name'])->first();
                            
                            $mutiple_language[$lang] = !empty($content['name']) ? true : false;
                        }                        
                    }
                }


                $result[$k]['mutiple_language'] = $mutiple_language;
            }
        }

        $pagination_info = !empty($this->request->getAttribute('paging')['Quizs']) ? $this->request->getAttribute('paging')['Quizs'] : [];
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
        $all_attributes = Hash::combine(TableRegistry::get('Attributes')->getAll($this->lang), '{n}.id', '{n}', '{n}.attribute_type');
        $all_attributes = !empty($all_attributes[QUIZ]) ? $all_attributes[QUIZ] : [];

        $all_options = [];
        if(!empty($all_attributes)){
            $all_options = Hash::combine(TableRegistry::get('AttributesOptions')->getAll($this->lang), '{n}.id', '{n}.name','{n}.attribute_id');
        }

        $max_record = TableRegistry::get('Quizs')->find()->select('id')->max('id');

        $this->set('all_attributes', $all_attributes);
        $this->set('all_options', $all_options);
        $this->set('position', !empty($max_record->id) ? $max_record->id + 1 : 1);
        $this->set('list_category_main', []);

        $this->css_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css'
        ];

        $this->js_page = [
            '/assets/plugins/custom/tinymce6/tinymce.min.js',
            '/assets/js/seo_analysis.js',
            '/assets/js/pages/quiz.js',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js'
        ];

        $this->set('path_menu', 'quiz_add');
        $this->set('title_for_layout', __d('admin', 'them_bai_viet'));
        $this->render('update');
    }

    public function update($id = null)
    {
        $all_attributes = Hash::combine(TableRegistry::get('Attributes')->getAll($this->lang), '{n}.id', '{n}', '{n}.attribute_type');
        $all_attributes = !empty($all_attributes[QUIZ]) ? $all_attributes[QUIZ] : [];
        $all_options = Hash::combine(TableRegistry::get('AttributesOptions')->getAll($this->lang), '{n}.id', '{n}.name', '{n}.attribute_id');

        $table = TableRegistry::get('Quizs');
        $quiz = $table->getDetailQuiz($id, $this->lang, [
            'get_user' => true, 
            'get_categories' => true,
            'get_tags' => true,
            'get_attributes' => true
        ]);

        $quiz = $table->formatDataQuizDetail($quiz, $this->lang);
        $list_category_main = [];
        if(!empty($quiz['categories'])) {
            foreach($quiz['categories'] as $category_id => $category_main){
                if(empty($category_main['id']) || empty($category_main['name'])) continue;
                $list_category_main[$category_id] = $category_main['name'];
            }
        }

        if(empty($quiz)){
            $this->showErrorPage();
        }
        
        $this->set('path_menu', 'quiz');
        $this->set('id', $id);
        $this->set('position', !empty($quiz['position']) ? $quiz['position'] : 1);
        $this->set('all_attributes', $all_attributes);
        $this->set('all_options', $all_options);
        $this->set('quiz', $quiz);
        $this->set('list_category_main', $list_category_main);

        $this->css_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css'
        ];

        $this->js_page = [
            '/assets/plugins/custom/tinymce6/tinymce.min.js',
            '/assets/js/seo_analysis.js',
            '/assets/js/pages/quiz.js',
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js'
        ];
        $this->set('title_for_layout', __d('admin', 'cap_nhat_bai_viet'));
    }

    public function detail($id = null)
    {
        if(empty($id)){
            $this->showErrorPage();
        }

        $table = TableRegistry::get('Quizs');

        $quiz_detail = $table->getDetailQuiz($id, $this->lang, [
            'get_user' => true, 
            'get_categories' => true,
            'get_tags' => true,
            'get_attributes' => true
        ]);

        if(empty($quiz_detail)){
            $this->showErrorPage();
        }

        $quiz = $table->formatDataQuizDetail($quiz_detail, $this->lang);

        $this->css_page = [
            '/assets/css/pages/wizard/wizard-4.css',
            '/assets/plugins/global/lightbox/lightbox.css'
        ];
        $this->js_page = [
            '/assets/plugins/global/lightbox/lightbox.min.js'
        ];

        $this->set('quiz', $quiz);
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
        $attribute_component = $this->loadComponent('Admin.Attribute');
        $table = TableRegistry::get('Quizs');        
        $tags_table = TableRegistry::get('Tags');

        if(!empty($id)){
            $quiz = $table->getDetailQuiz($id, $this->lang, [
                'get_user' => false, 
                'get_categories' => true,
                'get_attributes' => true
            ]);

            if(empty($quiz)){
                $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
            }
        }

        // validate data
        if(empty($data['name'])){
            $this->responseJson([MESSAGE => __d('admin', 'vui_long_nhap_tieu_de')]);
        }

        $link = !empty($data['link']) ? $utilities->formatToUrl(trim($data['link'])) : null;
        if(empty($link)){
            $this->responseJson([MESSAGE => __d('admin', 'vui_long_nhap_duong_dan')]);
        }

        $link_id = !empty($quiz['Links']) ? $quiz['Links']['id'] : null;
        if(TableRegistry::get('Links')->checkExist($link, $link_id)){
            $this->responseJson([MESSAGE => __d('admin', 'duong_dan_da_ton_tai_tren_he_thong')]);
        }

        // format data before save
        $list_keyword = !empty($data['seo_keyword']) ? array_column(json_decode($data['seo_keyword'], true), 'value') : null;
        $seo_keyword = !empty($list_keyword) ? implode(', ', $list_keyword) : null;

        $data_categories = [];
        if(!empty($data['categories'])){
            foreach($data['categories'] as $category_id){
                $data_categories[] = [
                    'quiz_id' => $id,
                    'category_id' => $category_id
                ];
            }
        }

        $url_video = !empty($data['url_video']) ? $data['url_video'] : null;
        $type_video = null;
        if(!empty($url_video)){
            $type_video = !empty($data['type_video']) ? $data['type_video'] : null;
        }

        $has_album = $has_video = $has_file = 0;
        if(!empty($data['images'])){
            $has_album = 1;
        }

        if(!empty($data['url_video'])){
            $has_video = 1;
        }

        if(!empty($data['files'])){
            $has_file = 1;
        }

        $files = [];
        if(!empty($data['files'])){
            foreach (json_decode($data['files'], true) as $key => $file) {
                $files[] = str_replace(CDN_URL , '', $file);
            }
        }

        $status = isset($quiz['status']) ? intval($quiz['status']) : 1;
        $draft = !empty($data['draft']) ? 1 : 0;
        if(!empty($draft)){
            $status = 0;
        }
        
        // kiểm tra duyệt bài
        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $approved_quiz = !empty($settings['approved_quiz']) ? $settings['approved_quiz'] : [];
        $approved_role_id = !empty($approved_quiz['role_id']) ? array_map('intval', explode('|', $approved_quiz['role_id'])) : [];
        if(empty($draft) && !empty($approved_quiz['approved']) && !in_array($this->Auth->user('id'), $approved_role_id)){            
            // đổi trạng thái bài viết = -1 (chờ duyệt)
            $status = -1;
        }

        $data_save = [
            'image_avatar' => !empty($data['image_avatar']) ? $data['image_avatar'] : null,
            'images' => !empty($data['images']) ? $data['images'] : null,
            'url_video' => $url_video,
            'type_video' => $type_video,
            'files' => !empty($files) ? json_encode($files) : null,
            'has_album' => $has_album,
            'has_file' => $has_file,
            'has_video' => $has_video,            
            'position' => !empty($data['position']) ? intval($data['position']) : 1,
            'main_category_id' => !empty($data['main_category_id']) ? intval($data['main_category_id']) : null,
            'featured' => !empty($data['featured']) ? 1 : 0,
            'catalogue' => !empty($data['catalogue']) ? 1 : 0,
            'seo_score' => !empty($data['seo_score']) ? $data['seo_score'] : null,
            'keyword_score' => !empty($data['keyword_score']) ? $data['keyword_score'] : null,
            'draft' => $draft,
            'status' => $status
        ];

        $name = !empty($data['name']) ? trim(strip_tags($data['name'])) : null;
        $seo_title = !empty($data['seo_title']) ? trim(strip_tags($data['seo_title'])) : null;
        $seo_description = !empty($data['seo_description']) ? trim(strip_tags($data['seo_description'])) : null;
        
        $data_save['QuizsContent'] = [
            'name' => $name,
            'description' => !empty($data['description']) ? trim($data['description']) : null,
            'content' => !empty($data['content']) ? trim($data['content']) : null,
            'seo_title' => $seo_title,
            'seo_description' => $seo_description,
            'seo_keyword' => $seo_keyword,
            'lang' => $this->lang,
            'search_unicode' => strtolower($utilities->formatSearchUnicode([$name]))
        ];

        $data_save['Links'] = [
            'type' => QUIZ_DETAIL,
            'url' => $link,
            'lang' => $this->lang,
        ];

        $data_save['CategoriesQuiz'] = $data_categories;    
        $data_save['QuizsAttribute'] = $attribute_component->formatDataAttributesBeforeSave($data, $this->lang, QUIZ, $id);

        // merge data with entity 
        if(empty($id)){
            $data_save['created_by'] = $this->Auth->user('id');
            $quiz = $table->newEntity($data_save, [
                'associated' => ['QuizsContent', 'Links', 'CategoriesQuiz', 'QuizsAttribute']
            ]);
        }else{            
            $quiz = $table->patchEntity($quiz, $data_save);
        }

        // show error validation in model
        if($quiz->hasErrors()){
            $list_errors = $utilities->errorModel($quiz->getErrors());            
            $this->responseJson([
                MESSAGE => !empty($list_errors[0]) ? $list_errors[0] : null,
                DATA => $list_errors
            ]);
        }

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            if(!empty($id)){
                $clear_categories = TableRegistry::get('CategoriesQuiz')->deleteAll(['quiz_id' => $id]);
                $clear_attributes = TableRegistry::get('QuizsAttribute')->deleteAll(['quiz_id' => $id]);

                $clear_tags = TableRegistry::get('TagsRelation')->deleteAll([
                    'foreign_id' => $id,
                    'type' => QUIZ_DETAIL
                ]);
            }
            
            $save = $table->save($quiz);
            if (empty($save->id)){
                throw new Exception();
            }

            $tags = !empty($data['tags']) ? array_filter(array_column(json_decode($data['tags'], true), 'value')) : null;
            if(!empty($tags)){
                $tag_data = [];
                foreach ($tags as $tag) {
                    $tag_info = $tags_table->find()->where(['Tags.name' => $tag])->select(['Tags.id', 'Tags.name'])->first();
                    $tag_id = !empty($tag_info['id']) ? intval($tag_info['id']) : null;
                    if(empty($tag_info)){
                        $new_tag = $this->loadComponent('Admin.Tag')->saveTag([
                            'name' => $tag,
                            'link' => $tags_table->getUrlUnique($utilities->formatToUrl($tag)),
                            'seo_title' => $tag,
                            'lang' => $this->lang,
                            'search_unicode' => strtolower($this->Utilities->formatSearchUnicode([$tag]))
                        ]);
                        $tag_id = !empty($new_tag[DATA]['id']) ? intval($new_tag[DATA]['id']) : null;
                    }

                    if(empty($tag_id)) continue;
                    $tag_data[] = [
                        'foreign_id' => $save->id,
                        'type' => QUIZ_DETAIL,
                        'tag_id' => $tag_id
                    ];
                }

                $entities_tags = TableRegistry::get('TagsRelation')->newEntities($tag_data);
                $save_tags = TableRegistry::get('TagsRelation')->saveMany($entities_tags);
                if (empty($save_tags)){
                    throw new Exception();
                }
            }

            $conn->commit();

            // dich tự động các ngôn ngữ khác khi thêm mới bản ghi
            $auto_translate = TableRegistry::get('Settings')->getSettingAutoTranslate();
            if(empty($id) && $auto_translate){
                $this->translateQuiz($save->id, $this->lang);
            }

            $this->responseJson([CODE => SUCCESS, DATA => ['id' => $save->id]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    private function translateQuiz($quiz_id = null, $lang_from = null)
    {
        if(empty($quiz_id) || empty($lang_from)) return false;

        $languages = TableRegistry::get('Languages')->getList();
        if(empty($languages)) return false;

        $utilities = $this->loadComponent('Utilities');
        $translate_component = $this->loadComponent('Admin.Translate');

        $table = TableRegistry::get('Quizs');
        $links_table = TableRegistry::get('Links');
        $quiz_info = $table->getDetailQuiz($quiz_id, $lang_from);
        if(empty($quiz_info)) return false;

        foreach($languages as $lang => $language){
            if($lang == $lang_from) continue;

            $name = !empty($quiz_info['QuizsContent']['name']) ? $quiz_info['QuizsContent']['name'] : null;
            $translates = $translate_component->translate([$name], $lang_from, $lang);
            
            $name_translate = !empty($translates[0]) ? $translates[0] : $name;

            $link = $utilities->formatToUrl($name_translate);
            if(empty($link)) continue;

            $link = $links_table->getUrlUnique($link);
            $data_save = [
                'id' => $quiz_id,
                'QuizsContent' => [
                    'name' => $name_translate,
                    'seo_title' => $name_translate,
                    'lang' => $lang,
                    'search_unicode' => strtolower($utilities->formatSearchUnicode([$name_translate]))
                ],
                'Links' => [
                    'type' => QUIZ_DETAIL,
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

        $table = TableRegistry::get('Quizs');

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            foreach($ids as $id){

                // delete quiz
                $quiz = $table->get($id);
                if (empty($quiz)) {
                    throw new Exception(__d('admin', 'khong_tim_thay_thong_tin_bai_viet'));
                }

                $quiz = $table->patchEntity($quiz, ['id' => $id, 'deleted' => 1], ['validate' => false]);
                $delete = $table->save($quiz);
                if (empty($delete)){
                    throw new Exception();
                }

                // delete link
                $delete_link = TableRegistry::get('Links')->updateAll(
                    [  
                        'deleted' => 1
                    ],
                    [  
                        'foreign_id' => $id,
                        'type' => QUIZ_DETAIL
                    ]
                );
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

        $table = TableRegistry::get('Quizs');

        $quizs = $table->find()->where([
            'Quizs.id IN' => $ids,
            'Quizs.deleted' => 0
        ])->select(['Quizs.id', 'Quizs.status'])->toList();
        
        if(empty($quizs)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_thong_tin_bai_viet')]);
        }

        $patch_data = [];
        foreach ($ids as $k => $quiz_id) {
            $patch_data[] = [
                'id' => $quiz_id,
                'status' => $status,
                'draft' => 0
            ];
        }

        $data_quizs = $table->patchEntities($quizs, $patch_data, ['validate' => false]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $change_status = $table->saveMany($data_quizs);
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

        $quizs_table = TableRegistry::get('Quizs');
        $system = $this->loadComponent('System');
        $utilities = $this->loadComponent('Utilities');

        $data_dulicate = [];
        foreach($ids as $id){
            $quiz = $quizs_table->find()
            ->contain([
                'ContentMutiple',
                'CategoriesQuiz',
                'LinksMutiple'
            ])
            ->where([
                'Quizs.id' => $id,
                'Quizs.deleted' => 0,
            ])->first()->toArray();
            
            if(empty($quiz)) continue;
            
            // format data before mere entity
            unset($quiz['id']);
            unset($quiz['created_by']);
            unset($quiz['created']);
            unset($quiz['updated']);

            unset($quiz['view']);
            unset($quiz['like']);
            unset($quiz['has_album']);
            unset($quiz['has_file']);
            unset($quiz['has_video']);
            unset($quiz['comment']);

            if(!empty($quiz['ContentMutiple'])){
                foreach($quiz['ContentMutiple'] as $k_content => $content){
                    $name = $system->getNameUnique('Quizs', $content['name'], 1);
                    $quiz['ContentMutiple'][$k_content]['name'] = $name;

                    unset($quiz['ContentMutiple'][$k_content]['id']);
                    unset($quiz['ContentMutiple'][$k_content]['category_id']);
                }
            }

            if(!empty($quiz['LinksMutiple'])){
                foreach($quiz['LinksMutiple'] as $k_link => $link){
                    $quiz['LinksMutiple'][$k_link]['url'] = $system->getUrlUnique($link['url'], 1);

                    unset($quiz['LinksMutiple'][$k_link]['id']);
                    unset($quiz['LinksMutiple'][$k_link]['foreign_id']);
                }
            }

            if(!empty($quiz['CategoriesQuiz'])){
                foreach($quiz['CategoriesQuiz'] as $k_category => $category_quiz){
                    unset($quiz['CategoriesQuiz'][$k_category]['id']);
                    $quiz['CategoriesQuiz'][$k_category]['quiz_id'] = null;
                }
            }
            $data_dulicate[] = $quiz;            
        }

        $quiz_entities = $quizs_table->newEntities($data_dulicate, [
            'associated' => ['ContentMutiple', 'LinksMutiple', 'CategoriesQuiz']
        ]);

        try{
            // save data
            $save = $quizs_table->saveMany($quiz_entities);  
            
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

        $table = TableRegistry::get('Quizs');
        $quiz = $table->get($id);
        if(empty($quiz)) {
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
        }

        $quiz = $table->patchEntity($quiz, ['position' => $value], ['validate' => false]);

        try{
            $save = $table->save($quiz);

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

        $table = TableRegistry::get('Quizs');
        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $filter = !empty($data[FILTER]) ? $data[FILTER] : [];
        
        $quizs = $table->queryListQuizs([
            FILTER => $filter,
            FIELD => FULL_INFO
        ])->limit(10)->toList();

        $result = [];
        if(!empty($quizs)){
            foreach($quizs as $quiz){
                $result[] = $table->formatDataQuizDetail($quiz, $this->lang);
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

        $table = TableRegistry::get('Quizs');

        $has_album = 0;
        if(!empty($images)){
            $has_album = 1;
        }

        $quiz_info = $table->find()->where([
            'id' => $id,            
            'deleted' => 0,
        ])->select(['id', 'images', 'image_avatar'])->first();

        if (empty($quiz_info)) {
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
        }

        $quiz = $table->patchEntity($quiz_info, [
            'images' => $images,
            'image_avatar' => $image_avatar,
            'has_album' => $has_album
        ]);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            // save data
            $save = $table->save($quiz);
            if (empty($save->id)){
                throw new Exception();
            } 

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => $quiz]);

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

        $table = TableRegistry::get('Quizs');   
        $quiz = $table->find()->where([
            'id' => $id,
            'deleted' => 0,
        ])->select(['id', 'images', 'image_avatar'])->first();

        $quiz['images'] = !empty($quiz['images']) ? json_decode($quiz['images'], true) : [];
        $quiz['image_avatar'] = !empty($quiz['image_avatar']) ? $quiz['image_avatar'] : [];


        if(empty($quiz)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')]);
        }
        
        $this->set('quiz', $quiz);
    }
}