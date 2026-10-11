<?php

namespace Admin\Controller;

use Admin\Controller\AppController;

class MediaController extends AppController {

    public function initialize(): void
    {
        parent::initialize();
    }

    public function media()
    {
        $this->set('title_for_layout', __d('admin', 'media'));
        $this->set('path_menu', 'media');
        $this->render('media');
    }
}