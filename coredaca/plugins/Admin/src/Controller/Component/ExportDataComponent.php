<?php

namespace Admin\Controller\Component;

use Cake\Controller\Component;
use Cake\Controller\ComponentRegistry;
use Cake\ORM\TableRegistry;
use Cake\Core\Exception\Exception;
use Cake\Datasource\ConnectionManager;
use Cake\Filesystem\Folder;
use Cake\Filesystem\File;
use ZipArchive;

class ExportDataComponent extends Component
{
	public $controller = null;
    public $components = ['System', 'Utilities', 'Admin.Plugin'];
    public $list_tables_export = [];

    public function initialize(array $config): void
    {
        parent::initialize($config);
        $this->controller = $this->_registry->getController();

        $this->list_tables_export = [
            'articles', 
            'articles_content',
            'attributes',
            'attributes_content',
            'attributes_options',
            'attributes_options_content',
            'brands', 
            'categories', 
            'categories_article', 
            'categories_content', 
            'categories_product',
            'links',
            'products',
            'products_content',
            'products_item',
            'products_item_attribute',
            'tags',
            'tags_relation'
        ];
    }

    public function readMigrateDataExportInfo()
    {
        $migrate_info = [];
        $migrate_file = new File(TMP . 'migrate.json', false);
        if($migrate_file->exists()){
            $content = $migrate_file->read();
            $migrate_info = $this->Utilities->isJson($content) ? json_decode($content, true) : [];
        }

        return $migrate_info;
    }

    public function initializeExportData()
    {
        // khởi tạo thư mục chứa dữ liệu
        $dir_data_tmp = TMP . 'export_data' . DS;
        $folder_data_tmp = new Folder($dir_data_tmp, true, 0755);
        if(empty($folder_data_tmp->path)){
            return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_thu_muc_chua_giao_dien')]);
        }

        $dir_media_tmp = TMP . 'export_media' . DS;
        $folder_media_tmp = new Folder($dir_media_tmp, true, 0755);
        if(empty($folder_media_tmp->path)){
            return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_thu_muc_chua_giao_dien')]);
        }

        $dir_thumbs_tmp = TMP . 'export_thumbs' . DS;
        $dir_thumbs_tmp = new Folder($dir_thumbs_tmp, true, 0755);
        if(empty($dir_thumbs_tmp->path)){
            return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_thu_muc_chua_giao_dien')]);
        }

        // khởi tạo file chứa dữ liệu
        foreach($this->list_tables_export as $table){
            $file = new File(TMP . 'export_data' . DS . $table .'.json', true);
            if(!$file->exists()){
                return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_tep_du_lieu_{0}', [$table])]);
            }
            $file->write('', 'w');
            $file->close();

            $file = new File(TMP . 'export_data' . DS . $table .'.sql', true);
            if(!$file->exists()){
                return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_tep_du_lieu_{0}', [$table])]);
            }

            $file->write('', 'w');
            $file->close();
        }

        $file = new File(TMP . 'export_data' . DS . 'all.sql', true);
        if(!$file->exists()){
            $this->responseJson([MESSAGE => "Không thể khởi tạo tệp dữ liệu all.sql'"]);
            return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_tep_du_lieu_all_sql')]);
        }

        $file->write('', 'w');
        $file->close();

        $file = new File(TMP . 'export_data.zip', false);
        if($file->exists()){
            $file->delete();
            $file->close();
        }

        $file = new File(TMP . 'export_media.zip', false);
        if($file->exists()){
            $file->delete();
            $file->close();
        }

        $file = new File(TMP . 'export_thumbs.zip', false);
        if($file->exists()){
            $file->delete();
            $file->close();
        }

        // xóa dữ liệu trong folder media
        $media_dir = TMP . 'export_media';
        $folder_media = new Folder($media_dir, true);
        if(empty($folder_media->path)){
            return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_thu_muc_media')]);
        }

        // khởi tạo thư mục chứa ảnh
        $folder_media = new Folder($media_dir . DS . 'categories', true);
        $folder_media = new Folder($media_dir . DS . 'articles', true);
        $folder_media = new Folder($media_dir . DS . 'products', true);
        $folder_media = new Folder($media_dir . DS . 'brands', true);
        $folder_media = new Folder($media_dir . DS . 'videos', true);
        $folder_media = new Folder($media_dir . DS . 'files', true);

        $folder_thumbs = new Folder(TMP . 'export_thumbs', true);
        if(empty($folder_thumbs->path)){
            return $this->System->getResponse([MESSAGE => __d('admin', 'khong_the_khoi_tao_thu_muc_thumbs')]);
        }

        // khởi tạo file migrate.json ở webroot
        $data_update = [
            'initialization' => ['status' => SUCCESS, MESSAGE => __d('admin', 'khoi_tao_thanh_cong')]
        ];
        $update_file_migrate = $this->updateFileMiragte('initialization', $data_update, true);

        if(!$update_file_migrate) {
            return $this->System->getResponse([MESSAGE => __d('admin', 'cap_nhat_file_migrate_json_khong_thanh_cong')]);
        }

        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'khoi_tao_quy_trinh_thanh_cong')
        ]);
    }

    public function updateFileMiragte($step = null, $data = [], $init = false)
    {
        if(empty($step) || empty($data) || !is_array($data)) return false;

        $migrate_info = [];
        $migrate_file = new File(TMP . 'migrate.json', true);
        if($migrate_file->exists()){
            $content = $migrate_file->read();
            $migrate_info = $this->Utilities->isJson($content) ? json_decode($content, true) : [];
        }

        if($init){
            $migrate_info = [ 
                'initialization' => [
                    'initialization' => null,
                    'read_database' => null,
                    'config_data' => null,
                    'config_attributes' => null,
                    'config_id' => null,
                    'done' => false
                ],
                'categories' => [
                    'total_record' => 0,
                    'migrated' => 0,
                    'done' => false
                ],
                'articles' => [
                    'total_record' => 0,
                    'migrated' => 0,
                    'done' => false
                ],
                'products' => [
                    'total_record' => 0,
                    'migrated' => 0,
                    'done' => false
                ],
                'brands' => [
                    'total_record' => 0,
                    'migrated' => 0,
                    'done' => false
                ],
                'attributes' => [
                    'total_record' => 0,
                    'migrated' => 0,
                    'done' => false
                ],
                'tags' => [
                    'total_record' => 0,
                    'migrated' => 0,
                    'done' => false
                ],
                'success' => [
                    'export' => false,
                    'done' => false
                ]
            ];
        }

        if(empty($migrate_info) || empty($migrate_info[$step])) return false;

        foreach($data as $k => $item){
            $migrate_info[$step][$k] = $item;
        }

        // kiểm tra các bước khởi tạo đã xong chưa
        if($step == 'initialization'){
            $done = true;
            foreach($migrate_info[$step] as $key => $item){
                if($key == 'done') continue;
                if(!isset($item['status']) || $item['status'] != SUCCESS){
                    $done = false;
                }
            }
            $migrate_info[$step]['done'] = $done;
        }

        $migrate_file->write(json_encode($migrate_info, JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT), 'w');
        $migrate_file->close();

        return true;
    }

    public function readDatabase()
    {
        // tổng số danh mục bài viết
        $number_category_article = TableRegistry::get('Categories')->find()->where([
            'deleted' => 0, 
            'type' => ARTICLE
        ])->count();

        // tổng số bài viết
        $number_article = TableRegistry::get('Articles')->find()->where([
            'deleted' => 0
        ])->count();

        // tổng số thẻ tag bài viết
        $number_tag_article = TableRegistry::get('TagsRelation')->find()->contain(['Tags'])->where([
            'TagsRelation.type' => ARTICLE_DETAIL,
        ])->count();

        // tổng số thuộc tính mở rộng bài viết
        $number_attribute_article = TableRegistry::get('Attributes')->find()->where([
            'deleted' => 0,
            'attribute_type' => ARTICLE
        ])->count();

        // tổng số danh mục sản phẩm
        $number_category_product = TableRegistry::get('Categories')->find()->where([
            'deleted' => 0, 
            'type' => PRODUCT
        ])->count();

        // tổng số sản phẩm
        $number_product = TableRegistry::get('Products')->find()->where([
            'deleted' => 0
        ])->count();

        // tổng số thương hiệu
        $number_brand = TableRegistry::get('Brands')->find()->where([
            'deleted' => 0
        ])->count();

        // tổng số thẻ tag sản phẩm
        $number_tag_product = TableRegistry::get('TagsRelation')->find()->contain(['Tags'])->where([
            'TagsRelation.type' => PRODUCT_DETAIL,
        ])->count();

        // tổng số thuộc tính mở rộng sản phẩm
        $number_attribute_product = TableRegistry::get('Attributes')->find()->where([
            'deleted' => 0,
            'attribute_type' => PRODUCT
        ])->count();

        // tổng số thuộc tính mở rộng sản phẩm
        $number_attribute_product_item = TableRegistry::get('Attributes')->find()->where([
            'deleted' => 0,
            'attribute_type' => PRODUCT_ITEM
        ])->count();

        $number_category = $number_category_article + $number_category_product;
        $number_tag = $number_tag_article + $number_tag_product;
        $number_attribute = $number_attribute_article + $number_attribute_product + $number_attribute_product_item;

        $this->updateFileMiragte('initialization', [
            'read_database' => [
                STATUS => SUCCESS,
                MESSAGE => __d('admin', 'doc_thong_tin_du_lieu_thanh_cong'),
                DATA => [
                    'number_category_article' => $number_category_article,
                    'number_article' => $number_article,
                    'number_tag_article' => $number_tag_article,
                    'number_attribute_article' => $number_attribute_article,
                    'number_category_product' => $number_category_product,
                    'number_product' => $number_product,
                    'number_brand' => $number_brand,
                    'number_tag_product' => $number_tag_product,
                    'number_attribute_product' => $number_attribute_product,
                    'number_attribute_product_item' => $number_attribute_product_item
                ]
            ]
        ]);

        $this->updateFileMiragte('categories', [
            'total_record' => intval($number_category)
        ]);

        $this->updateFileMiragte('articles', [
            'total_record' => intval($number_article)
        ]);

        $this->updateFileMiragte('brands', [
            'total_record' => intval($number_brand)
        ]);

        $this->updateFileMiragte('products', [
            'total_record' => intval($number_product)
        ]);

        $this->updateFileMiragte('tags', [
            'total_record' => intval($number_tag)
        ]);

        $this->updateFileMiragte('attributes', [
            'total_record' => intval($number_attribute)
        ]);

        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'doc_thong_tin_du_lieu_thanh_cong')
        ]);
    }

    public function configAttributes($data = [])
    {
        $ids = !empty($data['ids']) ? json_encode($data['ids']) : null;
        $attribute_type = !empty($data['attribute_type']) ? $data['attribute_type'] : null;

        if (empty($data) || empty($ids) || empty($attribute_type)) {
            return $this->System->getResponse([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }

        $this->updateFileMiragte('attributes', [
            'ids_' . $attribute_type => $ids
        ]);

        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'luu_cau_hinh_thuoc_tinh_mo_rong_thanh_cong')
        ]);
    }

    public function configDataExport($data = [])
    {
        if (empty($data)) {
            return $this->System->getResponse([MESSAGE => __d('admin', 'du_lieu_khong_hop_le')]);
        }
        
        $category_article = 0;
        if (!empty($data['categories']) && !empty($data['categories']['article_check']) && !empty($data['categories']['article_record'])) {
            $category_article = $data['categories']['article_record'];
        }

        $category_product = 0;
        if (!empty($data['categories']) && !empty($data['categories']['product_check']) && !empty($data['categories']['product_record'])) {
            $category_product = $data['categories']['article_record'];
        }

        $articles = 0;
        if (!empty($data['articles']) && !empty($data['articles']['check']) && !empty($data['articles']['record'])) {
            $articles = $data['articles']['record'];
        }

        $products = 0;
        if (!empty($data['products']) && !empty($data['products']['check']) && !empty($data['products']['record'])) {
            $products = $data['products']['record'];
        }

        $attributes_article = false;
        if (!empty($data['attributes']) && !empty($data['article_check']['check'])) {
            $attributes_article = true;
        }

        $attributes_product = false;
        if (!empty($data['attributes']) && !empty($data['product_check']['check'])) {
            $attributes_product = true;
        }

        $tag_article = 0;
        if (!empty($data['tags']) && !empty($data['tags']['article_check']) && !empty($data['tags']['article_record'])) {
            $tag_article = $data['tags']['article_record'];
        }

        $tag_product = 0;
        if (!empty($data['tags']) && !empty($data['tags']['product_check']) && !empty($data['tags']['product_record'])) {
            $tag_product = $data['tags']['article_record'];
        }

        $brands = 0;
        if (!empty($data['brands']) && !empty($data['brands']['check']) && !empty($data['brands']['record'])) {
            $brands = $data['brands']['record'];
        }

        $this->updateFileMiragte('initialization', [
            'config_data' => [
                STATUS => SUCCESS,
                MESSAGE => __d('admin', 'doc_thong_tin_du_lieu_thanh_cong'),
                DATA => [
                    'category_article' => $category_article,
                    'category_product' => $category_product,
                    'articles' => $articles,
                    'products' => $products,
                    'attributes_article' => $attributes_article,
                    'attributes_product' => $attributes_product,
                    'tag_article' => $tag_article,
                    'tag_product' => $tag_product,
                    'brands' => $brands,
                    'languages' => !empty($data['languages']) ? $data['languages'] : null
                ]
            ]
        ]);

        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => __d('admin', 'cau_hinh_du_lieu_thanh_cong')
        ]);
    }
}
