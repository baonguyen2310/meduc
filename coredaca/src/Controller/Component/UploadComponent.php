<?php

namespace App\Controller\Component;

use Cake\Controller\Component;
use Cake\Controller\ComponentRegistry;
use Cake\Core\Exception\Exception;
use Cake\Utility\Security;
use Cake\Http\Client;

class UploadComponent extends Component
{
	public $controller = null;
    public $components = ['System', 'Utilities'];

    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->controller = $this->_registry->getController();
    }

    public function uploadToCdn($file = [], $path_folder = null, $options = [])
    {
        if(empty($file) || !is_array($file)){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
        }

        $size = !empty($file['size']) ? intval($file['size']) : 0;
        $error = !empty($file['error']) ? intval($file['error']) : 0;
        $name = !empty($file['name']) ? $file['name'] : null;
        $tmp_file = !empty($file['tmp_name']) ? $file['tmp_name'] : null;

        if(!empty($error) || empty($size) || empty($tmp_file)){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
        }

        if($size > MAX_SIZE_FILE_UPLOAD){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_co_dung_luong_qua_lon')]);
        }

        // rename file tmp before upload cdn
        $tmp_name = pathinfo($tmp_file, PATHINFO_BASENAME);
        if(empty($options['origin_name'])){
            $name = strtolower($this->Utilities->generateRandomString(20));
        }
        
        $file_upload = str_replace($tmp_name, $name, $tmp_file);
        rename($tmp_file, $file_upload);

        $akey = $this->generateAccessKeyUpload(['name' => $name, 'size' => $size]);
        if(empty($akey)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_ma_dang_tai_cdn')]);
        }

        return $this->upToCdn($file_upload, $path_folder, $akey);
    }

    public function uploadToCdnByUrl($url = null, $path_folder, $options = [])
    {
        if(empty($url)){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
        }
        
        $headers = @get_headers($url);
        if(empty($headers) || !is_array($headers)){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
        }

        foreach ($headers as $header) {
            if(strpos($header, 'Content-Type:') > -1){
                $list = explode('Content-Type:', $header);

                $type = !empty($list[1]) ? trim($list[1]) : null;
                if(strpos($type, 'text/html') > -1){
                    return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
                }
            }
        }

        $content = file_get_contents($url);
        $size = strlen($content);

        if($size > MAX_SIZE_FILE_UPLOAD){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_co_dung_luong_qua_lon')]);
        }

        $tmp_file = @tempnam(sys_get_temp_dir(), 'tmp_file');
        $handle = @fopen($tmp_file, 'w');
        @fwrite($handle, $content);
        @fclose($handle);

        if(empty($tmp_file)){
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
        }

        // rename file tmp before upload cdn
        $name = strtolower($this->Utilities->generateRandomString(20));
        $file_upload = str_replace(basename($tmp_file), $name, $tmp_file);
        @rename($tmp_file, $file_upload);

        $akey = $this->generateAccessKeyUpload(['name' => $name, 'size' => $size]);
        if(empty($akey)){
            return $this->System->getResponse([MESSAGE => __d('template', 'khong_lay_duoc_ma_dang_tai_cdn')]);
        }

        return $this->upToCdn($file_upload, $path_folder, $akey);
    }

    private function upToCdn($file_upload = null, $path = null, $akey = null)
    {
        if(empty($file_upload) || empty($path) || empty($akey)){            
            return $this->System->getResponse([MESSAGE => __d('template', 'tep_dang_tai_khong_hop_le')]);
        }

        $request = $this->controller->getRequest();
        $http = new Client();

        $response = $http->post(
            CDN_URL . '/filemanager/upload.php?akey=' . $akey,
            [
                'fldr' => $path . '/',
                'files[]' => fopen($file_upload, 'r')
            ],
            [
                'headers' => ['Referer' => $request->scheme() . '://' . $request->host()],
                'ssl_verify_peer' => FALSE,
                'ssl_verify_host ' => FALSE
            ]
        );

        if($response->getStatusCode() != 200 || empty($response->getStringBody())){
           return $this->System->getResponse([MESSAGE => __d('template', 'dang_tai_tep_khong_thanh_cong')]);
        }

        $files = json_decode($response->getStringBody(), true);    
        if(empty($files['files'][0])){
            return $this->System->getResponse([MESSAGE => __d('template', 'dang_tai_tep_khong_thanh_cong')]);
        }
        

        $file = $files['files'][0];
        if(!empty($file['error'])){
            return $this->System->getResponse([MESSAGE => $file['error']]);   
        }
        $file['url'] = !empty($file['url']) ? str_replace(CDN_URL, '', $file['url']) : null;
        unset($file['deleteUrl']);
        unset($file['deleteType']);

        // delete file tmp
        unlink($file_upload);

        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => __d('template', 'dang_tai_tep_thanh_cong'),
            DATA => $file
        ]);
    }

    private function generateAccessKeyUpload($file_info = [])
    {
        $domain = $this->controller->getRequest()->host();

        $path_key = [ACCESS_KEY_UPLOAD];
        if(!empty($file_info['name'])){
            $path_key[] = $file_info['name'];
        }

        if(!empty($file_info['size'])){
            $path_key[] = $file_info['size'];
        }

        $access_key_upload = Security::hash(implode(SEPARATOR_KEY_UPLOAD, $path_key), 'md5', false);
        return base64_encode($domain . '|' . $access_key_upload);
    }
  
}
