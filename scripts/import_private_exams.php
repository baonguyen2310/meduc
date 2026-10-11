<?php
/** CLI-only import. Data and backups must stay outside public_html. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
require '/home/kbbcutgf/public_html/config_database.php';
$db=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USERNAME,DB_PASSWORD,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$db->exec("SET SESSION sql_mode='STRICT_ALL_TABLES'");
$mode=$argv[1]??'';
function sql(string $query,array $values=[]){global $db;$s=$db->prepare($query);$s->execute($values);return $s;}
function insert(string $table,array $row): int {global $db;$cols=array_keys($row);sql('INSERT INTO '.$table.' (`'.implode('`,`',$cols).'`) VALUES ('.implode(',',array_fill(0,count($cols),'?')).')',array_values($row));return (int)$db->lastInsertId();}
function once(string $table,string $key,int $id,array $row): void {if(!sql('SELECT 1 FROM '.$table.' WHERE '.$key.'=? LIMIT 1',[$id])->fetchColumn())insert($table,$row);}
function encoded($value): string {return json_encode($value,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);}

if ($mode==='schema') {
    $dir='/home/kbbcutgf/meduc-import-backups';if(!is_dir($dir))mkdir($dir,0700,true);
    $path=$dir.'/before-2033-'.date('Ymd-His').'.jsonl.gz';$out=gzopen($path,'wb6');chmod($path,0600);
    foreach(['products','products_content','products_item','products_attribute','categories_product','quizs','quizs_content','quizs_attribute','categories_quiz','links','quiz_exam_metadata'] as $table){
        $ddl=$db->query('SHOW CREATE TABLE '.$table)->fetch(PDO::FETCH_NUM);gzwrite($out,encoded(['table'=>$table,'ddl'=>$ddl[1]])."\n");
        $rows=$db->query('SELECT * FROM '.$table);while($row=$rows->fetch(PDO::FETCH_ASSOC))gzwrite($out,encoded(['table'=>$table,'row'=>$row])."\n");
    }
    gzclose($out);echo 'Backup: '.$path.PHP_EOL;
    $db->exec("CREATE TABLE IF NOT EXISTS exam_prep_courses (product_id INT NOT NULL PRIMARY KEY, import_topic VARCHAR(180) NOT NULL, staff_only TINYINT(1) NOT NULL DEFAULT 1, imported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY topic (import_topic)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    foreach(['staff_only'=>'TINYINT(1) NOT NULL DEFAULT 1','source_remote_id'=>'VARCHAR(64) DEFAULT NULL'] as $col=>$type){
        if(!sql('SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? AND column_name=?',['quiz_exam_metadata',$col])->fetchColumn())$db->exec('ALTER TABLE quiz_exam_metadata ADD COLUMN '.$col.' '.$type);
    }
    foreach(['quizs_attribute','products_attribute'] as $table){
        $type=sql('SELECT DATA_TYPE FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? AND column_name=?',[$table,'value'])->fetchColumn();
        if($type!=='longtext')$db->exec('ALTER TABLE '.$table.' MODIFY value LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL');
    }
    echo "Schema ready\n";exit;
}

if (!in_array($mode,['import','verify'],true) || empty($argv[2])) {fwrite(STDERR,"Usage: php import_private_exams.php schema | import file.jsonl.gz | verify file.jsonl.gz\n");exit(1);}
if (!sql("SELECT GET_LOCK('meduc_2033_import',0)")->fetchColumn())throw new RuntimeException('Another import is running.');
$input=gzopen($argv[2],'rb');if(!$input)throw new RuntimeException('Missing import data');
$manifest=json_decode(gzgets($input),true,512,JSON_THROW_ON_ERROR);
if(($manifest['exams']??0)!==2033 || count($manifest['topics']??[])!==88)throw new RuntimeException('Unexpected manifest');
$courses=[];$curriculum=[];$total=0;$questions=0;$newExams=0;
$now=time();
foreach($manifest['topics'] as $index=>$topic){
    $row=sql('SELECT product_id FROM exam_prep_courses WHERE import_topic=?',[$topic])->fetch(PDO::FETCH_ASSOC);
    if(!$row){
        if($mode==='verify')throw new RuntimeException('Course missing: '.$topic);
        $id=insert('products',['main_category_id'=>125,'status'=>0,'draft'=>1,'deleted'=>0,'created'=>$now,'updated'=>$now,'created_by'=>1,'position'=>$index+1]);
        insert('exam_prep_courses',['product_id'=>$id,'import_topic'=>$topic,'staff_only'=>1]);
    }else{$id=(int)$row['product_id'];}
    $courses[$topic]=$id;$curriculum[$topic]=[];
    if($mode==='import'){
        once('products_content','product_id',$id,['product_id'=>$id,'name'=>$topic,'search_unicode'=>$topic,'lang'=>'vi']);
        once('products_item','product_id',$id,['product_id'=>$id,'code'=>'MEDUC-LT-'.$id,'price'=>0,'status'=>0,'deleted'=>0,'position'=>1]);
        if(!sql('SELECT 1 FROM categories_product WHERE product_id=? AND category_id=125',[$id])->fetchColumn())insert('categories_product',['product_id'=>$id,'category_id'=>125]);
        if(!sql("SELECT 1 FROM links WHERE foreign_id=? AND type='product_detail' AND lang='vi'",[$id])->fetchColumn())insert('links',['foreign_id'=>$id,'type'=>'product_detail','url'=>'khoa-luyen-thi-noi-bo-'.$id,'lang'=>'vi','created'=>$now,'updated'=>$now,'deleted'=>0]);
    }
}
while(!gzeof($input)){
    $line=gzgets($input);if(!$line)continue;
    $e=json_decode($line,true,512,JSON_THROW_ON_ERROR);$m=$e['metadata'];
    if(($e['type']??'')!=='exam' || !isset($courses[$m['import_topic']]))throw new RuntimeException('Invalid import row');
    $existing=sql('SELECT * FROM quiz_exam_metadata WHERE source_system=? AND source_exam_id=?',[$m['source_system'],$m['source_exam_id']])->fetch(PDO::FETCH_ASSOC);
    if(!$existing){
        if($mode==='verify')throw new RuntimeException('Missing exam '.$m['source_exam_id']);
        $id=insert('quizs',['status'=>0,'draft'=>1,'deleted'=>0,'created'=>$now,'updated'=>$now,'created_by'=>1,'position'=>$total+1]);
        insert('quiz_exam_metadata',array_merge(['quiz_id'=>$id,'imported_at'=>date('Y-m-d H:i:s')],$m));$newExams++;
    }else{
        $id=(int)$existing['quiz_id'];
        if($existing['source_hash']!==$m['source_hash'])throw new RuntimeException('Source changed for exam '.$m['source_exam_id']);
        if((int)$existing['staff_only']!==1)throw new RuntimeException('Exam is no longer private');
    }
    $json=encoded($e['questions']);
    if($mode==='import'){
        once('quizs_content','quiz_id',$id,['quiz_id'=>$id,'name'=>$e['name'],'search_unicode'=>$e['search_unicode'],'lang'=>'vi']);
        foreach([18=>$json,19=>(string)$e['duration']] as $attr=>$value){
            if(!sql('SELECT 1 FROM quizs_attribute WHERE quiz_id=? AND attribute_id=?',[$id,$attr])->fetchColumn())insert('quizs_attribute',['quiz_id'=>$id,'attribute_id'=>$attr,'value'=>$value]);
        }
        if(!sql("SELECT 1 FROM links WHERE foreign_id=? AND type='quiz_detail' AND lang='vi'",[$id])->fetchColumn())insert('links',['foreign_id'=>$id,'type'=>'quiz_detail','url'=>'de-tong-on-noi-bo-'.$id,'lang'=>'vi','created'=>$now,'updated'=>$now,'deleted'=>0]);
    }
    $stored=sql('SELECT value FROM quizs_attribute WHERE quiz_id=? AND attribute_id=18 LIMIT 1',[$id])->fetchColumn();
    if(!is_string($stored) || json_decode($stored,true)!==$e['questions'])throw new RuntimeException('Question integrity mismatch '.$id);
    $curriculum[$m['import_topic']][]=['code'=>'review_'.$m['source_exam_id'],'name_vi'=>$e['name'],'chapter_vi'=>'n','review_vi'=>'y','trial_vi'=>'n','quiz_id_vi'=>(string)$id,'description_vi'=>'','files'=>''];
    $total++;$questions+=count($e['questions']);
    if($total%250===0)echo 'Checked '.$total.PHP_EOL;
}
gzclose($input);
if($total!==2033 || $questions!==(int)$manifest['questions'])throw new RuntimeException('Import totals mismatch');
foreach($curriculum as $topic=>$lessons){
    $id=$courses[$topic];$json=encoded($lessons);
    $current=sql('SELECT id,value FROM products_attribute WHERE product_id=? AND attribute_id=11 LIMIT 1',[$id])->fetch(PDO::FETCH_ASSOC);
    if(!$current && $mode==='import')insert('products_attribute',['product_id'=>$id,'attribute_id'=>11,'value'=>$json]);
    elseif(!$current || $current['value']!==$json)throw new RuntimeException('Course curriculum mismatch '.$id);
}
echo encoded(['mode'=>$mode,'courses'=>count($courses),'exams'=>$total,'questions'=>$questions,'new_exams'=>$newExams,'first_course'=>reset($courses),'last_course'=>end($courses)]).PHP_EOL;
sql("SELECT RELEASE_LOCK('meduc_2033_import')");
