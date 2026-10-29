<?php
declare(strict_types=1);
/** Rename only the public quiz catalogue, preserving category/course IDs and private source URLs.
 * php scripts/rename_quiz_catalog.php /var/www/html /secure/backup-directory
 */
if (PHP_SAPI !== 'cli' || empty($argv[1]) || empty($argv[2])) throw new RuntimeException('Pass application root and an existing backup directory.');
$root=rtrim($argv[1],'/');$backupDir=rtrim($argv[2],'/');
if (!is_dir($backupDir) || !is_writable($backupDir)) throw new RuntimeException('Backup directory is not writable.');
require $root.'/config_database.php';
$db=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USERNAME,DB_PASSWORD,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
function renameCatalogUrls($value) {
    if (is_array($value)) return array_map('renameCatalogUrls',$value);
    if (is_string($value)) return preg_replace('~^((?:https?://[^/]+)?/?)khoa-luyen-thi(/?)([?#].*)?$~','${1}trac-nghiem${2}${3}',$value);
    return $value;
}
$db->beginTransaction();
try {
    $link=$db->query("SELECT * FROM links WHERE foreign_id=125 AND type='category_product' AND lang='vi' AND deleted=0 FOR UPDATE")->fetch();
    if (!$link || !in_array($link['url'],['khoa-luyen-thi','trac-nghiem'],true)) throw new RuntimeException('The quiz catalogue URL does not match the expected category.');
    $other=$db->prepare("SELECT id FROM links WHERE url='trac-nghiem' AND id<>? AND deleted=0 FOR UPDATE");$other->execute([$link['id']]);
    if ($other->fetch()) throw new RuntimeException('trac-nghiem is already used by another page.');
    $blocks=$db->query("SELECT id,config,data_extend,normal_data_extend,updated FROM templates_block WHERE config LIKE '%khoa-luyen-thi%' OR data_extend LIKE '%khoa-luyen-thi%' OR normal_data_extend LIKE '%khoa-luyen-thi%' FOR UPDATE")->fetchAll();
    $backupPath=$backupDir.'/quiz-catalog-url-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)).'.json';
    if (file_put_contents($backupPath,json_encode(['link'=>$link,'blocks'=>$blocks],JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR))===false) throw new RuntimeException('Backup failed.');
    chmod($backupPath,0600);
    if ($link['url']!=='trac-nghiem') $db->prepare('UPDATE links SET url=?,updated=? WHERE id=?')->execute(['trac-nghiem',time(),$link['id']]);
    $changed=0;
    foreach($blocks as $block) foreach(['config','data_extend','normal_data_extend'] as $column) {
        $old=$block[$column]??'';
        if (strpos($old,'khoa-luyen-thi')===false) continue;
        $data=json_decode($old,true);
        if (json_last_error()!==JSON_ERROR_NONE) continue;
        $new=renameCatalogUrls($data);
        if ($new===$data) continue;
        $json=json_encode($new,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);
        $db->prepare('UPDATE templates_block SET '.$column.'=?,updated=? WHERE id=?')->execute([$json,time(),$block['id']]);
        $changed++;
    }
    $db->commit();
    echo "Quiz catalogue: /trac-nghiem; updated $changed configured link fields. Backup: $backupPath\n";
} catch (Throwable $error) { $db->rollBack(); throw $error; }
