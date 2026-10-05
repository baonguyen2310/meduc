<?php

namespace Admin\Controller\Component;

use Cake\Controller\Component;
use Cake\Controller\ComponentRegistry;
use Cake\Core\Configure;
use Cake\ORM\TableRegistry;
use Cake\Datasource\ConnectionManager;
use Cake\Core\Exception\Exception;
use Cake\Http\Client;
use Cake\Cache\Cache;


class TranslateComponent extends AppComponent
{
    public $controller = null;
    public $components = ['System', 'Utilities'];

    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->controller = $this->_registry->getController();
    }    

    public function translate($list_text = [], $from = null, $to = null)
    {        
        if(empty($list_text) || !is_array($list_text)) return [];
        if(empty($from) || empty($to)) return $list_text;

        $translator_key = $this->getKey();
        if(empty($translator_key)) return $list_text;
        $http = new Client();
        
        $params = [
            'api-version' => '3.0',
            'from' => $from,
            'to' => $to
        ];

        $url = 'https://api.cognitive.microsofttranslator.com/translate?' . http_build_query($params);

        $data_translate = [];
        foreach($list_text as $text){
            $data_translate[] = ['text' => $text];
        }

        $translates = $http->post($url, json_encode($data_translate), 
            [
                'type' => 'json',
                'headers' => [
                    'Ocp-Apim-Subscription-Region' => 'eastasia',
                    'Ocp-Apim-Subscription-Key' => $translator_key
                ]
            ]
        );

        $translates = $translates->getJson();
        if(empty($translates)) return $list_text;

        $result = [];
        foreach($translates as $key => $translate){
            $text_default = !empty($list_text[$key]) ? $list_text[$key] : null;
            $result[$key] = !empty($translate['translations'][0]['text']) ? $translate['translations'][0]['text'] : $text_default;
        }

        return $result;
    }

    private function getKey()
    {
        $keys = Configure::read('AZURE_TRANSLATOR_KEY');

        $cache_key = 'translate_count';
        $translate_count = Cache::read($cache_key);

        if(is_null($translate_count)){
            foreach($keys as $key){
                $translate_count[] = 0;
            }
            
            $translate_count[0] = 1;

            Cache::write($cache_key, $translate_count);

            return !empty($keys[0]) ? $keys[0] : null;
        }

        asort($translate_count);
        $index = array_key_first($translate_count);

        $translate_count[$index] = !empty($translate_count[$index]) ? intval($translate_count[$index]) + 1 : 1;
        Cache::write($cache_key, $translate_count);

        return !empty($keys[$index]) ? $keys[$index] : null;
    }
}
