<?php

namespace App\Controller;

use Cake\Event\EventInterface;
use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;

class WebsiteController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

    public function loadSettingBlock()
    {
        $this->viewBuilder()->enableAutoLayout(false);

        $data = $this->getRequest()->getData();
        $code = empty($data['code']) ? $data['code'] : '';

        $block_info = TableRegistry::get('TemplatesBlock')->find()->where([
            'template_code' => CODE_TEMPLATE,
            'code' => $code,
            'deleted' => 0
        ])->first();

        $config = !empty($block_info['config']) ? json_decode($block_info['config'], true) : [];
        $type = !empty($block_info['type']) ? $block_info['type'] : null;

        $this->set('config', $config);
        $this->set('code', $code);
        $this->set('type', $type);
        $this->set('block_info', $block_info);
        $this->render('setting_block');
    }
}