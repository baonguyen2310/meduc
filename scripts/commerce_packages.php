<?php
/** Additive commerce migration. Run only with --apply; existing invoices keep their snapshots. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||!in_array('--apply',$argv,true))exit("Use --apply\n");
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';
$app=new App\Application($root.'/coredaca/config');$app->bootstrap();$db=Cake\Datasource\ConnectionManager::get('default');
foreach(['duration_months'=>'SMALLINT UNSIGNED NULL','credit_count'=>'SMALLINT UNSIGNED NOT NULL DEFAULT 0','bonus_count'=>'SMALLINT UNSIGNED NOT NULL DEFAULT 0'] as $column=>$type){
 if(!$db->execute("SHOW COLUMNS FROM course_price_packages LIKE '$column'")->fetch())$db->execute("ALTER TABLE course_price_packages ADD COLUMN $column $type");
}
$db->execute("CREATE TABLE IF NOT EXISTS commerce_purchases (
 order_id INT NOT NULL PRIMARY KEY, public_code CHAR(32) NOT NULL, customer_id INT NOT NULL,
 kind VARCHAR(16) NOT NULL, package_id INT NOT NULL, package_name VARCHAR(120) NOT NULL,
 product_id INT NULL, duration_months SMALLINT UNSIGNED NULL, credit_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
 amount BIGINT UNSIGNED NOT NULL, original_amount BIGINT UNSIGNED NOT NULL, context_json TEXT NULL,
 reported_at BIGINT UNSIGNED NULL, approved_at BIGINT UNSIGNED NULL, fulfilled_at BIGINT UNSIGNED NULL,
 expires_at BIGINT UNSIGNED NULL, created_at BIGINT UNSIGNED NOT NULL, updated_at BIGINT UNSIGNED NOT NULL,
 UNIQUE KEY uq_commerce_public(public_code), KEY idx_commerce_customer(customer_id,kind), KEY idx_commerce_product(customer_id,product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
$db->execute("CREATE TABLE IF NOT EXISTS document_credit_uses (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, code CHAR(32) NOT NULL,
 customer_id INT NOT NULL, grant_order_id INT NULL, article_id INT NOT NULL, file_index INT UNSIGNED NOT NULL,
 file_key CHAR(64) NOT NULL, file_name VARCHAR(512) NOT NULL, file_url TEXT NOT NULL,
 download_token CHAR(64) NOT NULL, token_expires_at BIGINT UNSIGNED NOT NULL,
 used_at BIGINT UNSIGNED NULL, created_at BIGINT UNSIGNED NOT NULL,
 UNIQUE KEY uq_credit_code(code), UNIQUE KEY uq_credit_token(download_token),
 KEY idx_credit_usage(grant_order_id,used_at), KEY idx_credit_file(customer_id,article_id,file_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
$db->execute("CREATE TABLE IF NOT EXISTS commerce_notifications (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, dedupe_key CHAR(64) NOT NULL,
 recipient VARCHAR(255) NOT NULL, subject VARCHAR(255) NOT NULL, html MEDIUMTEXT NOT NULL,
 status VARCHAR(12) NOT NULL DEFAULT 'pending', attempts INT UNSIGNED NOT NULL DEFAULT 0,
 provider_id VARCHAR(128) NULL, last_error VARCHAR(500) NULL, created_at BIGINT UNSIGNED NOT NULL, updated_at BIGINT UNSIGNED NOT NULL,
 UNIQUE KEY uq_commerce_mail(dedupe_key), KEY idx_commerce_mail_status(status,updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
$db->execute("CREATE TABLE IF NOT EXISTS commerce_migrations (name VARCHAR(100) PRIMARY KEY,created_at BIGINT UNSIGNED NOT NULL) ENGINE=InnoDB");
if(!$db->execute("SELECT 1 FROM commerce_migrations WHERE name='packages-v1'")->fetch()){
 $db->transactional(function()use($db){
  $now=time();
  $knowledge=$db->execute("SELECT id FROM course_price_lists WHERE course_type='knowledge' ORDER BY id LIMIT 1")->fetchColumn(0);
  $quiz=$db->execute("SELECT id FROM course_price_lists WHERE course_type='quiz' ORDER BY id LIMIT 1")->fetchColumn(0);
  $common=['Video + slide khoá học','Full bộ đề luyện thi','Nhóm giải đáp'];
  $sets=[[$knowledge,[['Gói 1 môn',1,4000000,3200000,0,0,36,$common],['Gói 2 môn',2,8000000,6000000,0,0,36,array_merge($common,['Full bộ tài liệu quý'])],['Gói 3 + 1',4,16000000,9500000,1,1,36,['Video + slide khoá học','Full bộ đề luyện thi','Full bộ tài liệu quý','Nhóm giải đáp','Tặng 1 môn tự chọn','Tặng sổ tay ghi bài','Tặng voucher 500.000đ']]]],
   [$quiz,[['1 tháng',1,9999,null,0,0,1,['Luyện đề của môn đã chọn','Xem đáp án và lời giải chi tiết','Lưu lịch sử và sổ tay câu sai']],['6 tháng',1,59994,29999,0,0,6,['Luyện đề của môn đã chọn','Xem đáp án và lời giải chi tiết','Lưu lịch sử và sổ tay câu sai']],['1 năm',1,119988,49999,1,0,12,['Luyện đề của môn đã chọn','Xem đáp án và lời giải chi tiết','Lưu lịch sử và sổ tay câu sai']]]]];
  $doc=$db->execute("SELECT id FROM course_price_lists WHERE course_type='document' ORDER BY id LIMIT 1")->fetchColumn(0);
  if(!$doc){$db->insert('course_price_lists',['name'=>'Lượt tải tài liệu','slug'=>'luot-tai-tai-lieu','course_type'=>'document','description'=>'Mua lượt tải, dùng cho mọi tệp tài liệu trong thư viện.','position'=>40,'status'=>1,'created'=>$now,'updated'=>$now]);$doc=$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);}
  foreach($sets as [$list,$packages]){
   if(!$list)continue;
   $old=$db->execute('SELECT id FROM course_price_packages WHERE price_list_id=? ORDER BY position,id',[$list])->fetchAll('assoc');
   foreach($packages as $i=>$p){[$name,$count,$price,$sale,$recommended,$bonus,$months,$benefits]=$p;
    $row=['name'=>$name,'course_count'=>$count,'price'=>$price,'sale_price'=>$sale,'recommended'=>$recommended,'bonus_count'=>$bonus,'duration_months'=>$months,'benefits'=>implode("\n",$benefits),'credit_count'=>0,'position'=>$i+1,'status'=>1,'updated'=>$now];
    if(isset($old[$i]))$db->update('course_price_packages',$row,['id'=>$old[$i]['id']]);else$db->insert('course_price_packages',$row+['price_list_id'=>$list,'created'=>$now]);
   }
   foreach(array_slice($old,3) as $r)$db->update('course_price_packages',['status'=>0,'updated'=>$now],['id'=>$r['id']]);
  }
  foreach([[1,9999,null],[3,29997,19999],[5,49995,29999]] as $i=>$p){[$credits,$price,$sale]=$p;
   $db->insert('course_price_packages',['price_list_id'=>$doc,'name'=>$credits.' lượt tải','course_count'=>0,'credit_count'=>$credits,'price'=>$price,'sale_price'=>$sale,'recommended'=>$credits===5?1:0,'benefits'=>"Dùng cho mọi tài liệu trong thư viện\nKhông giới hạn thời gian dùng lượt\nTrừ 1 lượt khi bắt đầu tải một tệp",'position'=>$i+1,'status'=>1,'created'=>$now,'updated'=>$now]);
  }
  $db->update('settings',['value'=>'baonguyencoder97@gmail.com'],['group_setting'=>'email','code'=>'email_administrator']);
  $db->insert('commerce_migrations',['name'=>'packages-v1','created_at'=>$now]);
 });
}
Cake\Cache\Cache::clearAll();echo json_encode(['installed'=>true,'migration'=>'packages-v1'])."\n";
