<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Core\Configure;
use Cake\Utility\Hash;
use Cake\Http\Response;
use Cake\ORM\Query;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;
use Cake\Filesystem\File;
use Cake\Filesystem\Folder;
use Cake\Cache\Cache;

class TemplateBlockController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

    public function list()
    {
        $this->js_page = '/assets/js/pages/list_block.js';

        $this->set('path_menu', 'template');
        $this->set('title_for_layout', __d('admin', 'danh_sach_block'));
    }

    public function listJson()
    {
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $table = TableRegistry::get('TemplatesBlock');
        $utilities = $this->loadComponent('Utilities');

        $data = $params = $block = [];

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
        $params['get_user'] = true;

        // page and limit
        $page = !empty($data[PAGINATION][PAGE]) ? intval($data[PAGINATION][PAGE]) : 1;
        $limit = !empty($data[PAGINATION][PERPAGE]) ? intval($data[PAGINATION][PERPAGE]) : PAGINATION_LIMIT_ADMIN;


        // sort 
        $sort_field = !empty($params[SORT][FIELD]) ? $params[SORT][FIELD] : null;
        $sort_type = !empty($params[SORT][SORT]) ? $params[SORT][SORT] : null;

        try {
            $block = $this->paginate($table->queryListBlocks($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toArray();
        } catch (Exception $e) {
            $page = 1;
            $block = $this->paginate($table->queryListBlocks($params), [
                'limit' => $limit,
                'page' => $page,
                'order' => [
                    $sort_field => $sort_type
                ]
            ])->toArray();
        }

        if (!empty($block)) {
            $list_type = [
                PRODUCT => __d('admin', 'danh_sach_san_pham'),
                PRODUCT_DETAIL => __d('admin', 'chi_tiet_san_pham'),
                CATEGORY_PRODUCT => __d('admin', 'danh_muc_san_pham'),
                ARTICLE => __d('admin', 'danh_sach_bai_viet'),      
                ARTICLE_DETAIL => __d('admin', 'chi_tiet_bai_viet'),
                CATEGORY_ARTICLE => __d('admin', 'danh_muc_bai_viet'),
                QUIZ => "Danh sách trắc nghiệm",      
                QUIZ_DETAIL => "Chi tiết trắc nghiệm",
                CATEGORY_QUIZ => "Danh mục trắc nghiệm",
                MENU => 'MENU',
                HTML => 'HTML',
                SLIDER => 'SLIDER',
                RATING => __d('admin', 'danh_gia'),
                COMMENT => __d('admin', 'binh_luan'),
            ];

            foreach ($block as $k => $item) {
                $block[$k]['type_label'] = null;

                if(!empty($list_type[$item['type']])){
                    $block[$k]['type_label'] = $list_type[$item['type']];
                }
            }
        }

        $pagination_info = !empty($this->request->getAttribute('paging')['TemplatesBlock']) ? $this->request->getAttribute('paging')['TemplatesBlock'] : [];
        $meta_info = $utilities->formatPaginationInfo($pagination_info);

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
            DATA => $block, 
            META => $meta_info
        ]);
    }

    public function add()
    {
        $this->js_page = [
            '/assets/js/pages/template_block_add.js',
        ];

        $this->set('path_menu', 'template');
        $this->set('title_for_layout', __d('admin', 'them_block'));
        $this->render('add');
    }

    public function update($code = null)
    {
        $block_info = TableRegistry::get('TemplatesBlock')->find()->where([
            'template_code' => CODE_TEMPLATE,
            'code' => $code,
            'deleted' => 0
        ])->first();

        if(empty($block_info)){
            $this->showErrorPage();
        }

        $config = !empty($block_info['config']) ? json_decode($block_info['config'], true) : [];
        $type = !empty($block_info['type']) ? $block_info['type'] : null;
        
        $files = $files_view = $files_item = [];
        $file_first_content = null;

        if(!empty($type) && $type != HTML){
            $path_view = $this->loadComponent('Block')->getPathViewBlock($code);    
            if(!empty($path_view)){
                $folder = new Folder($path_view, false);
                $list_files = $folder->find('.*\.tpl', true);

                if(!empty($list_files)){
                    foreach ($list_files as $k => $file) {
                        $files[$file] = $file;
                        if(strpos($file, 'view') > -1){
                            $files_view[$file] = $file;
                        }

                        if(strpos($file, 'sub') > -1){
                            $files_item[$file] = $file;
                        }
                    }
                }
            }

            $file_first = !empty($block_info['view']) ? $block_info['view'] : reset($files);
            if(!empty($file_first)){
                $file_first_obj = new File($path_view . DS . $file_first, false);
                $file_first_content = $file_first_obj->read();
            }
        }

        $this->set('block_info', $block_info);
        $this->set('config', $config);
        $this->set('code', $code);
        $this->set('files', $files);
        $this->set('files_view', $files_view);
        $this->set('files_item', $files_item);
        $this->set('type', !empty($block_info['type']) ? $block_info['type'] : null);
        $this->set('file_first_content', !empty($file_first_content) ? $file_first_content : '');

        $this->css_page = [
            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.css',
            '/assets/plugins/global/ace-diff/ace-diff.min.css'
        ];

        $this->js_page = [
            '/assets/js/block_config.js',
            '/assets/js/pages/template_block_update.js',
            '/assets/plugins/global/ace/ace.js',
            '/assets/plugins/global/ace/theme-monokai.js',
            '/assets/plugins/global/ace/mode-json.js',
            '/assets/plugins/global/ace/mode-html.js',
            '/assets/plugins/global/ace/mode-smarty.js',
            '/assets/plugins/global/ace/ext-language_tools.js',

            '/assets/plugins/custom/jquery-ui/jquery-ui.bundle.js',

            '/assets/plugins/global/ace-diff/ace_1.3.3.js',
            '/assets/plugins/global/ace-diff/ace-diff.min.js'
        ];

        $this->set('path_menu', 'template');
        $this->set('title_for_layout', $code);
        $this->render('update');    
    }

    public function create()
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();
        $type = !empty($data['type']) ? $data['type'] : null;
        $name = !empty($data['name']) ? $data['name'] : null;

        if(empty($type) || empty($name)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $block_table = TableRegistry::get('TemplatesBlock');
        $utilities = $this->loadComponent('Utilities');

        $template_default = TableRegistry::get('Templates')->getTemplateDefault();
        $template_code = !empty($template_default['code']) ? $template_default['code'] : null;
        if(empty($template_code)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_giao_dien')]);
        }

        $code = strtolower($utilities->generateRandomString(7));
        $data_save = [
            'template_code' => $template_code,
            'code' => $code,
            'name' => $name,
            'type' => $type,
            'search_unicode' => strtolower($utilities->formatSearchUnicode([$name, $code]))
        ];

        if($type == HTML){
            $data_save['view'] = $code . '.tpl';
        }

        $block = $block_table->newEntity($data_save);
        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();
            
            $save = $block_table->save($block);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => ['code' => $save->code]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function saveMainConfig($code = null)
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();

        $table = TableRegistry::get('TemplatesBlock');
        $utilities = $this->loadComponent('Utilities');  

        $block = $table->find()->where([
            'template_code' => CODE_TEMPLATE,
            'code' => $code,
            'deleted' => 0
        ])->first();
        if(empty($block)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_block')]);
        }

        $name = !empty($data['name']) ? $data['name'] : null;

        $data_save = [
            'name' => $name,
            'status' => !empty($data['status']) ? 1 : 0,
            'search_unicode' => strtolower($utilities->formatSearchUnicode([$name, $code]))
        ];

        $block = $table->patchEntity($block, $data_save);

        $conn = ConnectionManager::get('default');
        try{

            $conn->begin();
            
            $save = $table->save($block);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => ['code' => $save->code]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function saveGeneralConfig($code = null)
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();
        
        $table = TableRegistry::get('TemplatesBlock');
        $utilities = $this->loadComponent('Utilities');                
        $config = !empty($data['config']) ? json_encode($data['config']) : [];        
        if(empty($config) || !$utilities->isJson($config)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $block = $table->find()->where([
            'template_code' => CODE_TEMPLATE,
            'code' => $code,
            'deleted' => 0
       ])->first();
        if(empty($block)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_block')]);
        }

        $block = $table->patchEntity($block, [
            'view' => !empty($data['view']) ? $data['view'] : null,
            'config' => $config
        ]);

        $conn = ConnectionManager::get('default');
        try{

            $conn->begin();
            $save = $table->save($block);

            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => ['code' => $code]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }    

    public function saveDataExtend($code = null)
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();

        $table = TableRegistry::get('TemplatesBlock');
        $utilities = $this->loadComponent('Utilities');

        $data_extend = !empty($data['data_extend']) ? $data['data_extend'] : null;
        $normal_data_extend = !empty($data['normal_data_extend']) ? $data['normal_data_extend'] : null;
        if(!empty($data_extend) && !$utilities->isJson($data_extend)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        if(!empty($normal_data_extend) && !$utilities->isJson($normal_data_extend)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $block = $table->find()->where([
            'template_code' => CODE_TEMPLATE,
            'code' => $code,
            'deleted' => 0
        ])->first();
        if(empty($block)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_block')]);
        }

        $block = $table->patchEntity($block, [
            'data_extend' => $data_extend,
            'normal_data_extend' => $normal_data_extend
        ]);

        $conn = ConnectionManager::get('default');
        try{

            $conn->begin();
            
            $save = $table->save($block);
            if (empty($save->id)){
                throw new Exception();
            }

            $conn->commit();

            $this->responseJson([CODE => SUCCESS, DATA => ['code' => $save->code]]);

        }catch (Exception $e) {
            $conn->rollback();
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function saveFileView($code = null)
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();

        $view_file = !empty($data['view_file']) ? $data['view_file'] : null;
        $view_file_content = !empty($data['view_file_content']) ? $data['view_file_content'] : '';

        if(empty($view_file)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $block = TableRegistry::get('TemplatesBlock')->find()->where([
            'template_code' => CODE_TEMPLATE,
            'code' => $code,
            'deleted' => 0
        ])->first();
        if(empty($block)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_lay_duoc_thong_tin_block')]);
        }

        $path_view = $this->loadComponent('Block')->getPathViewBlock($code);    
        if(empty($path_view)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_duong_dan_file_cua_block')]);
        }

        $file = new File($path_view . DS . $view_file, false);
        if(!$file->writable()){
            $this->responseJson([MESSAGE => __d('admin', 'khong_co_quyen_ghi_file')]);
        }
        $file->write($view_file_content);

        // delete cache        
        TableRegistry::get('App')->deleteCacheBlock($code);

        $this->responseJson([CODE => SUCCESS, DATA => ['code' => $code]]);
    }

    public function loadViewData()
    {
        $this->viewBuilder()->enableAutoLayout(false);
        $data = $this->getRequest()->getData();

        $code = !empty($data['code']) ? $data['code'] : null;
        $data_type = !empty($data['data_type']) ? $data['data_type'] : null;

        $block_info = TableRegistry::get('TemplatesBlock')->getInfoBlock($code);        
        $block_type = !empty($block_info['type']) ? $block_info['type'] : null;        

        $this->set('data_type', $data_type);
        $this->set('block_type', $block_type);
    }

    public function addFileView($code = null)
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();

        if(empty($data['name_file'])){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $name_file = $this->loadComponent('Utilities')->formatUnicode(strtolower(str_replace(' ', '', $data['name_file']))) . '.tpl';
        
        $path_view = $this->loadComponent('Block')->getPathViewBlock($code);    
        if(empty($path_view)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_duong_dan_file_cua_block')]);
        }

        $file = new File($path_view . DS . $name_file, true);
        if(empty($file->path)){
            $this->responseJson([MESSAGE => __d('admin', 'tao_file_khong_thanh_cong')]);
        }

        $this->responseJson([CODE => SUCCESS, DATA => ['file' => $name_file]]);
    }

    public function deleteFileView($code = null)
    {
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }
        $data = $this->getRequest()->getData();

        $view_file = !empty($data['view_file']) ? $data['view_file'] : null;
        if(empty($view_file)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $path_view = $this->loadComponent('Block')->getPathViewBlock($code);    
        if(empty($path_view)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_duong_dan_file_cua_block')]);
        }

        $file = new File($path_view . DS . $view_file, false);
        if(!$file->delete()){
            $this->responseJson([MESSAGE => __d('admin', 'xoa_giao_dien_khong_thanh_cong')]);
        }

        // delete cache        
        TableRegistry::get('App')->deleteCacheBlock($code);

        $this->responseJson([CODE => SUCCESS, DATA => ['code' => $code]]);
    }

    public function loadDropdownCategories()
    {
        $this->viewBuilder()->enableAutoLayout(false);

        $data = $this->getRequest()->getData();
        $type = !empty($data['type']) ? $data['type'] : null;
        $type = !empty($type) ? str_replace('category_', '', $type) : null;
        
        $this->set('type', $type);
        $this->set('lang', $this->lang);
    }

    public function loadCheckboxCategories()
    {
        $this->viewBuilder()->enableAutoLayout(false);

        $data = $this->getRequest()->getData();

        $type = !empty($data['type']) ? $data['type'] : null;
        $type = !empty($type) ? str_replace('category_', '', $type) : null;

        $this->set('type', $type);
        $this->set('lang', $this->lang);
    }

    public function loadViewDataForTab()
    {
        $this->viewBuilder()->enableAutoLayout(false);

        $data = $this->getRequest()->getData();
        $type = !empty($data['type']) ? $data['type'] : null;

        $this->set('type', $type);
        $this->set('lang', $this->lang);
    }

    public function loadEditorDataExtendSubMenu()
    {
        $this->viewBuilder()->enableAutoLayout(false);

        $this->render('load_editor_data_extend_sub_menu');
    }

    public function loadConfigTypeLoadOfBlock($type = null)
    {
        $this->viewBuilder()->enableAutoLayout(false);

        $this->set('type_load', $type);
        $this->render('config_type_load');
    }

    public function loadContentFileView($code = null)
    {
        $this->viewBuilder()->enableAutoLayout(false);

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = $this->getRequest()->getData();
        $view_file = !empty($data['view_file']) ? $data['view_file'] : null;

        $path_view = $this->loadComponent('Block')->getPathViewBlock($code);    
        if(empty($path_view)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_duong_dan_file_cua_block')]);
        }

        $file = new File($path_view . DS . $view_file, false);
        $file_content = $file->read();

        $this->responseJson([CODE => SUCCESS, DATA => ['code' => $code, 'file_content' => $file_content]]);
    }

    public function changeStatus()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = $this->getRequest()->getData();
        $ids = !empty($data['ids']) ? $data['ids'] : [];
        $status = !empty($data['status']) ? 1 : 0;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $blocks = TableRegistry::get('TemplatesBlock')->queryListBlocks([FILTER => ['ids' => $ids]])->toList();
        if(empty($blocks)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_tim_thay_thong_tin_bai_viet')]);
        }

        $patch_data = [];
        foreach ($ids as $k => $block_id) {
            $patch_data[] = [
                'id' => intval($block_id),
                'status' => $status
            ];
        }

        $table = TableRegistry::get('TemplatesBlock');
        $data_blocks = $table->patchEntities($blocks, $patch_data);

        $conn = ConnectionManager::get('default');
        try{
            $conn->begin();

            $change_status = $table->saveMany($data_blocks);
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

    public function delete()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        $ids = !empty($data['ids']) ? $data['ids'] : [];
        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        if (empty($ids) || !is_array($ids)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        try{
            TableRegistry::get('TemplatesBlock')->updateAll(
                [  
                    'deleted' => 1
                ],
                [  
                    'id IN' => $ids,
                    'template_code' => CODE_TEMPLATE
                ]
            );

            $this->responseJson([CODE => SUCCESS, MESSAGE => __d('admin', 'xoa_du_lieu_thanh_cong')]);

        }catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);  
        }
    }

    public function translateLabel()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        $label = !empty($data['label']) ? $data['label'] : null;

        if (empty($label) || !$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $translate_component = $this->loadComponent('Admin.Translate');

        $languages = TableRegistry::get('Languages')->getList();
        $lang_default = TableRegistry::get('Languages')->getDefaultLanguage();        
        if(empty($languages) || count($languages) == 1) $this->responseJson([CODE => SUCCESS, DATA => []]);

        $result = [];
        foreach($languages as $lang => $language){
            if($lang == $lang_default) continue;

            $translates = $translate_component->translate([$label], $lang_default, $lang);
            $label_translate = !empty($translates[0]) ? $translates[0] : $label;

            $result[$lang] = $label_translate;
        }

        $this->responseJson([CODE => SUCCESS, DATA => $result]);

    }
}