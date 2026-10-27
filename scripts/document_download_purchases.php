<?php
/** Run with PHP CLI: php scripts/document_download_purchases.php --apply */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
if (!in_array('--apply', $argv, true)) { fwrite(STDERR,"Use --apply to install document-download purchases.\n"); exit(1); }
$root=dirname(__DIR__);
$_SERVER['HTTP_HOST']='meducv3.duckdns.org';$_SERVER['SERVER_NAME']=$_SERVER['HTTP_HOST'];$_SERVER['HTTPS']='on';
$_SERVER['DOCUMENT_ROOT']=$root;$_SERVER['SCRIPT_FILENAME']=$root.'/index.php';chdir($root);
require 'config.php';require 'config_database.php';require 'coredaca/config/requirements.php';
if(!defined('SOURCE_DOMAIN'))define('SOURCE_DOMAIN',$root);
require 'coredaca/vendor/autoload.php';$app=new \App\Application($root.'/coredaca/config');$app->bootstrap();
$db=\Cake\Datasource\ConnectionManager::get('default');
$db->execute("CREATE TABLE IF NOT EXISTS document_download_purchases (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
 code CHAR(32) NOT NULL, order_id INT NOT NULL, customer_id INT NOT NULL,
 article_id INT NOT NULL, file_index INT UNSIGNED NOT NULL, file_key CHAR(64) NOT NULL,
 document_title VARCHAR(255) NOT NULL, document_url VARCHAR(500) NOT NULL,
 file_name VARCHAR(512) NOT NULL, file_url TEXT NOT NULL, amount INT UNSIGNED NOT NULL,
 transfer_reported_at BIGINT UNSIGNED NULL, used_at BIGINT UNSIGNED NULL,
 download_token CHAR(64) NULL, token_expires_at BIGINT UNSIGNED NULL,
 created_at BIGINT UNSIGNED NOT NULL, updated_at BIGINT UNSIGNED NOT NULL,
 UNIQUE KEY uq_document_purchase_code(code), UNIQUE KEY uq_document_purchase_order(order_id),
 UNIQUE KEY uq_document_download_token(download_token),
 KEY idx_document_customer_file(customer_id,article_id,file_key), KEY idx_document_order_customer(order_id,customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
$lock=$db->execute("SELECT GET_LOCK('meduc_document_download_sku',10)")->fetch('num');
if(empty($lock[0]))throw new \RuntimeException('Cannot lock download SKU installation.');
try {
 $sku=$db->execute("SELECT i.id,i.product_id,p.status,p.draft FROM products_item i JOIN products p ON p.id=i.product_id WHERE i.code='MEDUC_DOCUMENT_DOWNLOAD' AND i.deleted=0 AND p.deleted=0")->fetch('assoc');
 if(!$sku){
  $sku=$db->transactional(function()use($db){
   $now=time();$db->insert('products',['status'=>0,'draft'=>1,'deleted'=>0,'catalogue'=>0,'created'=>$now,'updated'=>$now]);$product=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetch('num')[0];
   $db->insert('products_content',['product_id'=>$product,'name'=>'Lượt tải tài liệu MedUC','lang'=>'vi','search_unicode'=>'luot tai tai lieu meduc']);
   $db->insert('products_item',['product_id'=>$product,'code'=>'MEDUC_DOCUMENT_DOWNLOAD','price'=>9999,'status'=>1,'deleted'=>0,'quantity_available'=>1000000000]);
   return ['id'=>(int)$db->execute('SELECT LAST_INSERT_ID()')->fetch('num')[0],'product_id'=>$product,'status'=>0,'draft'=>1];
  });
 }
 if((int)$sku['status']!==0||(int)$sku['draft']!==1)throw new \RuntimeException('Download SKU must remain inactive and unlisted.');
 echo json_encode(['installed'=>true,'sku_item'=>(int)$sku['id'],'sku_product'=>(int)$sku['product_id']],JSON_UNESCAPED_UNICODE)."\n";
}finally{$db->execute("SELECT RELEASE_LOCK('meduc_document_download_sku')");}
