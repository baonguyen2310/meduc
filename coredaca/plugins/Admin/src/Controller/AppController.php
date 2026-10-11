<?php

namespace Admin\Controller;

use Cake\Controller\Controller;
use Cake\ORM\TableRegistry;
use Cake\Event\EventInterface;
use Cake\Event\Event;
use Cake\Core\Configure;
use Cake\I18n\I18n;

static $js_page = [];

class AppController extends Controller {

    public $lang = null;
    public $error = null;

	public function initialize(): void
    {        
	    parent::initialize();

        $this->loadComponent('Auth', [
            'loginAction' => [
                'controller' => 'User',
                'action' => 'login',
                'plugin' => 'Admin'
            ],
            'authenticate' => [
                'Form' => [
                    'finder' => 'auth'
                ]
            ],
            'storage' => 'Session',
            'unauthorizedRedirect' => $this->referer()
        ]);

        if(!defined('LANGUAGE_ADMIN')){
            define('LANGUAGE_ADMIN', 'vi');
        }

        if(LANGUAGE_ADMIN != LANGUAGE_DEFAULT_ADMIN){
            Configure::write('App.paths.locales', [RESOURCES . 'locales' . DS]);
            Configure::write('App.defaultLocale', LANGUAGE_ADMIN);
            I18n::setLocale(LANGUAGE_ADMIN);
        }    
	}

    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
        $this->lang = $this->loadComponent('System')->getLanguageAdmin();

        // kiểm tra 1 số hằng biến hệ thống nếu không tồn tại thì sẽ khai báo lại, tránh bị lỗi khi call đến các component trong admin bị lỗi
        if(!defined('CODE_TEMPLATE')){
            $template = TableRegistry::get('Templates')->getTemplateDefault();
            $template_code = !empty($template['code']) ? $template['code'] : null;

            $path_template = SOURCE_DOMAIN  . DS . 'templates' . DS;
            $url_template = '/templates/';

            if(!empty($template_code)){
                $path_template = SOURCE_DOMAIN  . DS . 'templates' . DS . $template_code . DS;
                $url_template = '/templates/' . $template_code . '/';
            }

            define('CODE_TEMPLATE', $template_code);
            define('PATH_TEMPLATE', $path_template);
            define('URL_TEMPLATE', $url_template);
        } 

        if(!defined('CDN_URL')){
            $settings = TableRegistry::get('Settings')->getSettingWebsite();
            if(!empty($settings['profile']['cdn_url'])){
                define('CDN_URL', $settings['profile']['cdn_url']);
            }else{
                define('CDN_URL', $this->request->scheme() . '://cdn.' . $this->request->host());
            }
        }

        $mobile_template_code = null;
        $plugins = TableRegistry::get('Plugins')->getList();
        if(!empty($plugins[MOBILE_APP]) && !defined('CODE_MOBILE_TEMPLATE')){
            $mobile_template = TableRegistry::get('MobileTemplate')->getTemplateDefault();
            $mobile_template_code = !empty($mobile_template['code']) ? $mobile_template['code'] : null;                
        }

        define('CODE_MOBILE_TEMPLATE', $mobile_template_code);

        // kiểm tra tài khoản xem có quyền supper admin hay ko
        if(!defined('SUPPER_ADMIN') && !empty($this->Auth->user('supper_admin'))){
            define('SUPPER_ADMIN', true);
        }

        // kiểm tra quyền hệ thống nếu tài khoản đã đã đăng nhập
        $controller_request = $this->request->getParam('controller');
        $action_request = $this->request->getParam('action');

        if($this->Auth->user('id')){
            $role_id = !empty($this->Auth->user()['role_id']) ? intval($this->Auth->user()['role_id']) : null;
            $check_permission = TableRegistry::get('Roles')->checkPermissionRequest($role_id, $controller_request, $action_request);
            if(!$check_permission && !$this->request->is('ajax')){
                $this->showErrorPage('denied');
            }

            if(!$check_permission && $this->request->is('ajax')) {
                $this->responseJson([MESSAGE => __d('admin', 'ban_khong_co_quyen_thuc_hien_hanh_dong_nay')]);
            }
        }
    }

	public function beforeRender(EventInterface $event)
    {
        $view_builder = $this->viewBuilder();
        $view_builder->setClassName('Smarty');

    	if (!$this->request->is('ajax')) {
            $plugins = TableRegistry::get('Plugins')->getList();
            $aside_minimize = !empty($_COOKIE['aside_minimize']) ? $_COOKIE['aside_minimize'] : null;

            $this->set('plugins', $plugins);
            $this->set('aside_minimize', $aside_minimize);
            $this->set('js_page', !empty($this->js_page) ? $this->js_page : []);
            $this->set('css_page', !empty($this->css_page) ? $this->css_page : []);

            $this->set('auth_user', $this->Auth->user());
        }

        if(empty($view_builder->getVars()['lang'])){
            $this->set('lang', $this->lang);
        }

        // nếu page lỗi thì render lại view lỗi (vì nếu ở function gọi lại render view thì sẽ không hiển thị view lỗi)
        if(!empty($this->error)){
            $view_builder->setTemplatePath('Error')->setTemplate($this->error);
        }        
	}

    protected function responseJson($params = []) 
    {
        $code = ERROR;
        if(!empty($params[CODE]) && in_array($params[CODE], [SUCCESS, ERROR, SESSION_END])){
            $code = $params[CODE];
        }

        $message = !empty($params[MESSAGE]) ? $params[MESSAGE] : null;
        if(empty($params[MESSAGE]) && $code == ERROR){
            $message = __d('admin', 'cap_nhat_khong_thanh_cong');
        }

        if(empty($params[MESSAGE]) && $code == SUCCESS){
            $message = __d('admin', 'cap_nhat_thanh_cong');
        }
        
        $result = [
            CODE => $code,
            STATUS => !empty($params[STATUS]) ? intval($params[STATUS]) : 200,
            MESSAGE => $message
        ];

        if(isset($params[DATA])){
            $result[DATA] = !empty($params[DATA]) ? $params[DATA] : [];
        }

        if(isset($params[META])){
            $result[META] = !empty($params[META]) ? $params[META] : [];
        }

        exit(json_encode($result));
    }

    protected function showErrorPage($type = null, $params = [])
    {
        if(empty($type) && !in_array($type, ['404', 'denied', 'error'])){
            $type = '404';
        }

        $this->error = $type;

        $message = !empty($params[MESSAGE]) ? $params[MESSAGE] : __d('admin', 'xu_ly_du_lieu_khong_thanh_cong');
        $title = !empty($params['title']) ? $params['title'] : null;

        if(empty($params['title'])){
            switch($type){
                case '404':
                    $title = '404';
                break;

                case 'denied':
                    $title = __d('admin', 'khong_co_quyen_truy_cap');
                break;

                case 'error':
                    $title = 'Error';
                break;
            }
        }

        $this->set('message', $message);
        $this->set('title_for_layout', $title);
        // $this->render('Error/' . $type);
    }
}