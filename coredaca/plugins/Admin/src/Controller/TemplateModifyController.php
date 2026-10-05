<?php

namespace Admin\Controller;

use Admin\Controller\AppController;
use Cake\ORM\TableRegistry;
use Cake\Core\Configure;
use Cake\Utility\Hash;
use Cake\Http\Response;
use Cake\ORM\Query;
use Cake\Core\Exception\Exception;
use Cake\Filesystem\File;
use Cake\Filesystem\Folder;

class TemplateModifyController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
        $this->loadComponent('Admin.UploadFile');
    }

    public function save($type = null)
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        $content = !empty($data['content']) ? $data['content'] : '';
        $file_dir = PATH_TEMPLATE . 'assets' . DS . $type . DS . 'custom.' . $type;
        $file = new File($file_dir, false);

        if(!$file->exists()){
            $this->responseJson([MESSAGE => __d('admin', 'khong_doc_duoc_noi_dung_tep')]);
        }

        try {
            $file->write($content);
            $file->close();
            
            TableRegistry::get('App')->deleteCacheTemplate(PAGE);

            $this->responseJson([
                CODE => SUCCESS,
                MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong')
            ]);

        } catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }
    }

    public function cssCustom()
    {
        $this->js_page = [
            '/assets/plugins/global/ace/ace.js',
            '/assets/plugins/global/ace/theme-monokai.js',
            '/assets/plugins/global/ace/mode-css.js',
            '/assets/plugins/global/ace/ext-language_tools.js',
            '/assets/js/block_config.js',
            '/assets/js/pages/template_custom_css.js'
        ];

        $file_dir = PATH_TEMPLATE . 'assets' . DS . 'css' . DS . 'custom.css';
        $file_css = new File($file_dir, false);
        $exist_file = $file_css->exists();

        $content = null;
        if ($exist_file) {
            $content = $file_css->read();
            $file_css->close();            
        }

        $this->set('exist_file', $exist_file);
        $this->set('content', $content);
        $this->set('type', 'css');
        $this->set('path_menu', 'template');
        $this->set('title_for_layout', __d('admin', 'tuy_chinh_css'));        
    }

    public function jsCustom()
    {
        $this->js_page = [
            '/assets/plugins/global/ace/ace.js',
            '/assets/plugins/global/ace/theme-monokai.js',
            '/assets/plugins/global/ace/mode-javascript.js',
            '/assets/plugins/global/ace/ext-language_tools.js',            
            '/assets/js/pages/template_custom_javascript.js'
        ];

        $file_dir = PATH_TEMPLATE . 'assets' . DS . 'js' . DS . 'custom.js';
        $file_js = new File($file_dir, false);
        $exist_file = $file_js->exists();

        $content = null;
        if ($exist_file) {
            $content = $file_js->read();
            $file_js->close();            
        }

        $this->set('exist_file', $exist_file);
        $this->set('content', $content);
        $this->set('type', 'js');
        $this->set('path_menu', 'template');
        $this->set('title_for_layout', __d('admin', 'tuy_chinh_javascript'));        
    }

    public function modifyView()
    {
        $this->js_page = [
            '/assets/js/pages/template_modify.js',
            '/assets/plugins/global/jstree/jstree.bundle.js',
            '/assets/plugins/global/ace/ace.js',
            '/assets/plugins/global/ace/theme-monokai.js',
            '/assets/plugins/global/ace/mode-javascript.js',
            '/assets/plugins/global/ace/mode-css.js',
            '/assets/plugins/global/ace/mode-php.js',
            '/assets/plugins/global/ace/mode-html.js',
            '/assets/plugins/global/ace/mode-smarty.js',
            '/assets/plugins/global/ace/ext-language_tools.js'
        ];
        $this->css_page = [
            '/assets/plugins/global/jstree/jstree.bundle.css',
        ];

        $this->set('path_menu', 'template');
        $this->set('title_for_layout', __d('admin', 'chinh_sua_giao_dien'));
    }

    public function readFolder()
    {
        $this->layout = false;
        $this->autoRender = false;

        if (!$this->getRequest()->is('post')) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }

        $structure = $this->getStructFolder(PATH_TEMPLATE);
        try{
            $this->responseJson([
                CODE => SUCCESS,
                MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'),
                DATA => $structure
            ]);
        }catch (Exception $e) {
            $this->responseJson([MESSAGE => $e->getMessage()]);
        }   
    }

    private function getStructFolder($path = null)
    {
        $result = [];
        $direct_folder = new Folder($path, false);
        $data = $direct_folder->read();

        // read folder
        if (!empty($data[0])) {
            foreach ($data[0] as $key => $folder) {
                $result[] = [
                    'text' => $folder,
                    'icon' => 'fa fa-folder kt-font-success',
                    'children' => $this->getStructFolder($path . $folder . DS),
                    'a_attr' => [
                        'data_folder_path' => $path . $folder . DS,
                        'type' => 'folder'
                    ]
                ];
            }
        }

        // read file
        if (!empty($data[1])) {
            $white_list = ['css', 'js', 'tpl', 'json', 'po', 'eot', 'ttf', 'woff', 'woff2', 'png', 'gif', 'svg', 'jpg', 'jpeg', 'webp', 'mp4', 'mp3', 'avi', 'flv', 'wmv', 'mov'];
            foreach ($data[1] as $key => $file) {
                $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));            
                if(!in_array($ext, $white_list)) continue;

                $icon = 'fa fa-file';
                switch ($ext) {
                    case 'php':
                        $icon = 'fa fa-file  kt-font-warning';
                        break;

                    case 'tpl':
                        $icon = 'fa fa-file  kt-font-info';
                        break;

                    case 'css':
                        $icon = 'fa fa-file  kt-font-danger';
                        break;

                    case 'js':
                        $icon = 'fa fa-file  kt-font-dark';
                        break;
                }

                $result[] = [
                    'text' => $file,
                    'icon' => $icon,
                    'a_attr' => [
                        'data_file_path' => $path . $file,
                        'data_file_ext' => $ext,
                        'type' => 'file'
                    ]
                ];
            }
        }
        return $result;
    }

    public function loadFile()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'phuong_thuc_khong_hop_le')]);
        }            
        $path = !empty($data['path']) ? $data['path'] : null;
        $file = new File($path, false);
        if (!$file->exists()) {
            $this->responseJson([MESSAGE => __d('admin', 'tep_nay_khong_ton_tai')]);
        }

        $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
        $white_list = ['css', 'js', 'tpl', 'json', 'po'];
        if(!in_array($ext, $white_list)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_doc_duoc_tep_nay')]);
        }

        $content = $file->read();
        $file->close();

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'xu_ly_du_lieu_thanh_cong'), 
            DATA => $content
        ]);
    }

    public function saveFile() 
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];

        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }        

        $path = !empty($data['path']) ? $data['path'] : null;
        $content = !empty($data['content_file']) ? $data['content_file'] : '';
        
        $file = new File($path, false);
        if (!$file->exists()) {
            $this->responseJson([MESSAGE => __d('admin', 'tep_nay_khong_ton_tai')]);
        }

        $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
        $white_list = ['css', 'js', 'tpl', 'json', 'po'];
        if(!in_array($ext, $white_list)){
            $this->responseJson([MESSAGE => __d('admin', 'khong_doc_duoc_tep_nay')]);
        }

        // save content file
        $file->write($content);
        $file->close();

        TableRegistry::get('App')->deleteCacheTemplate();

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'cap_nhat_thanh_cong')
        ]);
    }

    public function renameFile()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }
        
        $new_name = !empty($data['new_name']) ? $data['new_name'] : null;
        $old_name = !empty($data['old_name']) ? $data['old_name'] : null;
        $path = !empty($data['path']) ? $data['path'] : null;
        
        if(empty($new_name) || empty($old_name) || empty($path)){
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }        
        if(!is_dir($path)) {
            $file = new File($path, false);
            if (!$file->exists()) {
                $this->responseJson([MESSAGE => __d('admin', 'tep_nay_khong_ton_tai')]);
            }
        }
    
        $different = strcmp($new_name, $old_name);
        if(!$different) {
            $this->responseJson([MESSAGE => __d('admin', 'ten_chua_duoc_thay_doi')]);
        }

        $path = pathinfo($path, PATHINFO_DIRNAME);
        
        $path_new = $path . DS . $new_name;
        $path_old = $path . DS . $old_name;
        rename($path_old, $path_new);

        TableRegistry::get('App')->deleteCacheTemplate();

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'doi_ten_thanh_cong')
        ]);
    }

    public function deleteFile()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        if (!$this->getRequest()->is('post') || empty($data)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }    
        
        $type = !empty($data['type']) ? $data['type'] : null;
        $path = !empty($data['path']) ? $data['path'] : null;
        if(empty($type) || empty($path)) {
            $this->responseJson([MESSAGE => __d('admin', 'file_khong_ton_tai')]);
        }

        if($type == 'file') {
            $file = new File($path, false);
            if($file->exists()){
                $delete = $file->delete();
            }
            $message = __d('admin', 'file_da_duoc_xoa');
        } else {
            $folder = new Folder($path, false);
            $delete = $folder->delete();

            $message = __d('admin', 'folder_da_duoc_xoa');
        }

        TableRegistry::get('App')->deleteCacheTemplate();

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => $message
        ]);
    }

    public function downloadFile()
    {
        $this->layout = false;
        $this->autoRender = false;
        $params = $this->request->getQuery();
        $path = !empty($params['path']) ? $params['path'] : null;
        if (empty($path)) die;

        $file = new File($path, false);
        if (!$file->exists())  die;

        $file_name = pathinfo($path, PATHINFO_BASENAME);
        $response = $this->response->withFile($path, [
            'download' => true, 
            'name' => $file_name
        ]);
        return $response;
    }

    public function uploadFile()
    {
        $this->layout = false;
        $this->autoRender = false;

        $data = !empty($this->request->getData()) ? $this->request->getData() : [];
        $path = !empty($data['path']) ? $data['path'] : null;

        if (!$this->getRequest()->is('post') || empty($path)) {
            $this->responseJson([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        if(!is_dir($path)) {
            $file = new File($path, false);
            if (!$file->exists()) {
                $this->responseJson([MESSAGE => __d('admin', 'tep_nay_khong_ton_tai')]);
            }
        }
        
        $path = pathinfo($path, PATHINFO_DIRNAME);

        $upload = $this->UploadFile->upload($data['file'], $path);
        if (empty($upload) || ( !empty($upload) && $upload['code'] === ERROR)) {
            $this->responseJson([
                MESSAGE => !empty($upload['message']) ? $upload['message'] : __d('admin', 'tai_tep_len_khong_thanh_cong')
            ]);
        }

        $this->responseJson([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'tai_tep_len_thanh_cong')
        ]);
    }
}