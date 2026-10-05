<?php
declare(strict_types=1);

namespace Admin\View\Helper;

use Cake\View\Helper;
use Cake\Core\Configure;
use Cake\Utility\Security;
use Cake\ORM\TableRegistry;
use Cake\Utility\Hash;
use Cake\Collection\Collection;
use Cake\Routing\Router;

class SystemAdminHelper extends Helper
{     
    public function getAccessKeyUpload()
    {
        $domain = $this->getView()->getRequest()->host();
        $access_key_upload = Security::hash(implode(SEPARATOR_KEY_UPLOAD, [ACCESS_KEY_UPLOAD]), 'md5', false);
        $string_encode = $domain . '|' . $access_key_upload;
        return base64_encode($string_encode);
    }

    public function getAccessKeyUploadToTemplate()
    {
        $template = TableRegistry::get('Templates')->getTemplateDefault();
        $template_code = !empty($template['code']) ? $template['code'] : null;
        $domain = $this->getView()->getRequest()->host();

        $access_key_upload = Security::hash(implode(SEPARATOR_KEY_UPLOAD, [ACCESS_KEY_UPLOAD, $template_code]), 'md5', false);
        $string_encode = $domain . '|' . $access_key_upload . '|' . $template_code;;
        return base64_encode($string_encode);
    }

    public function getAccessKeyUploadToMobileTemplate()
    {
        $template = TableRegistry::get('MobileTemplate')->getTemplateDefault();
        $template_code = !empty($template['code']) ? $template['code'] : null;
        $domain = $this->getView()->getRequest()->host();

        $template_code = 'mobile_' . $template_code;
        $access_key_upload = Security::hash(implode(SEPARATOR_KEY_UPLOAD, [ACCESS_KEY_UPLOAD, $template_code]), 'md5', false);
        $string_encode = $domain . '|' . $access_key_upload . '|' . $template_code;;
        return base64_encode($string_encode);
    }

    public function getUrlVars($var_name, $value)
    {
        $query_str = parse_url($_SERVER['REQUEST_URI'], PHP_URL_QUERY);
        $url = $_SERVER['REDIRECT_URL'];
        $query_params = [];
        if($query_str) {
            parse_str($query_str, $query_params);
        }
        $query_params[$var_name] = $value;
        $url .= '?'.http_build_query($query_params);
        return $url;
    }
}
