<?php

namespace App\Controller;

use Cake\Event\EventInterface;
use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;

class SystemController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

    public function loadEmbed()
    {
        $this->layout = false;
        $this->autoRender = false;

        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $embed_code = !empty($settings['embed_code']) ? $settings['embed_code'] : null;

        $result = [
            'head' => null,
            'top_body' => null,
            'bottom_body' => null,
        ];

        if(!empty($embed_code['head'])){
            $result['head'] = $embed_code['head'];
        }

        if(!empty($embed_code['top_body'])){
            $result['top_body'] = $embed_code['top_body'];
        }

        if(!empty($embed_code['bottom_body'])){
            $result['bottom_body'] = $embed_code['bottom_body'];
        }

        $this->responseJson([
            CODE => SUCCESS,
            DATA => $result
        ]);
    }

    public function loadSdkSocial($type = null)
    {
        $this->viewBuilder()->enableAutoLayout(false);

        if(empty($type) || !in_array($type, ['facebook', 'google'])) die;

        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        $social = !empty($settings['social']) ? $settings['social'] : [];


        $this->set('social', $social);

        if($type == 'facebook'){
            $this->render('/element/layout/facebook_sdk');
        }
        
        if($type == 'google'){
            $this->render('/element/layout/google_sdk');
        }
    }
}