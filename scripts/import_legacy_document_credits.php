<?php
/** Convert old file-specific purchases without changing their original invoice or file selection. */
declare(strict_types=1);
if(PHP_SAPI!=='cli'||($argv[1]??'')!=='--apply')exit(1);
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';
(new App\Application($root.'/coredaca/config'))->bootstrap();
$db=App\Service\CommercePurchases::db();
$count=$db->transactional(function()use($db){
    $rows=$db->execute('SELECT dp.order_id FROM document_download_purchases dp JOIN orders o ON o.id=dp.order_id LEFT JOIN commerce_purchases cp ON cp.order_id=dp.order_id WHERE o.deleted=0 AND cp.order_id IS NULL ORDER BY dp.order_id')->fetchAll('assoc');
    $count=0;
    foreach($rows as $row)if(App\Service\DocumentCredits::importLegacy((int)$row['order_id']))$count++;
    return $count;
});
echo json_encode(['converted'=>$count,'original_orders_and_file_selections'=>'preserved','email_sent'=>false],JSON_UNESCAPED_UNICODE)."\n";
