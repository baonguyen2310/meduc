<?php
/** CLI: migrate the former two price-list types and assign the new public catalogues.
 * Old list/package IDs, prices and order snapshots are retained. Safe to run again.
 */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit;
$root=dirname(__DIR__);define('SOURCE_DOMAIN',$root);
require $root.'/config_database.php';require $root.'/coredaca/vendor/autoload.php';require $root.'/coredaca/config/bootstrap.php';
use App\Service\CoursePricing;
$db=CoursePricing::db();
if (!in_array('--apply',$argv,true)) {echo "Preview: separate knowledge, exam_solution and quiz price lists; remove Fa sales assignments. Use --apply.\n";exit;}
if (!$db->execute("SELECT GET_LOCK('meduc-pricing-three-types',0)")->fetchColumn(0)) throw new RuntimeException('Pricing migration is already running.');
$report=[];$db->begin();
try {
    $db->execute("UPDATE course_price_lists SET course_type=CASE course_type WHEN 'course' THEN 'knowledge' WHEN 'exam_prep' THEN 'quiz' ELSE course_type END,updated=:t WHERE course_type IN ('course','exam_prep')",['t'=>time()]);
    $renames=['Khóa học Y khoa'=>'Khoá ôn kiến thức','Luyện thi Y khoa'=>'Khoá trắc nghiệm'];
    foreach($renames as$old=>$new)$db->execute('UPDATE course_price_lists SET name=:new WHERE name=:old',['new'=>$new,'old'=>$old]);
    $quiz=$db->execute("SELECT * FROM course_price_lists WHERE course_type='quiz' AND status=1 ORDER BY position,id LIMIT 1 FOR UPDATE")->fetch('assoc');
    if (!$quiz) throw new RuntimeException('Missing existing quiz price list.');
    $solution=$db->execute("SELECT * FROM course_price_lists WHERE course_type='exam_solution' AND status=1 ORDER BY position,id LIMIT 1 FOR UPDATE")->fetch('assoc');
    if (!$solution) {
        if ($db->execute("SELECT 1 FROM course_price_lists WHERE slug='khoa-chua-de'")->fetchColumn(0)) throw new RuntimeException('Solution price-list slug is already in use.');
        $db->insert('course_price_lists',['name'=>'Khoá chữa đề','slug'=>'khoa-chua-de','description'=>'Chọn môn và gói video chữa đề phù hợp với mục tiêu ôn thi.','course_type'=>'exam_solution','position'=>0,'status'=>1,'created'=>time(),'updated'=>time()]);
        $id=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
        foreach(CoursePricing::packages((int)$quiz['id']) as$p) {
            unset($p['id'],$p['amount'],$p['saving'],$p['lines']);
            $p['price_list_id']=$id;
            $p['benefits']='Tự chọn '.$p['course_count']." môn trong bảng giá\nHọc qua video chữa đề theo môn\nXem lại nội dung đã đăng ký\nQuản lý các khoá đang tham gia";
            $p['created']=$p['updated']=time();$db->insert('course_price_packages',$p);
        }
        $solution=CoursePricing::get($id);
        $report['created_solution_list']=$id;
    }
    $db->execute("UPDATE products SET course_price_list_id=NULL WHERE course_kind='fa' AND course_price_list_id IS NOT NULL");
    foreach(['quiz'=>(int)$quiz['id'],'exam_solution'=>(int)$solution['id']]as$kind=>$listId) {
        $db->execute('UPDATE products SET course_price_list_id=:list WHERE course_kind=:kind AND deleted=0 AND course_price_list_id IS NULL',['list'=>$listId,'kind'=>$kind]);
    }
    $wrong=$db->execute("SELECT COUNT(*) FROM products p JOIN course_price_lists l ON l.id=p.course_price_list_id WHERE p.deleted=0 AND (p.course_kind='fa' OR COALESCE(p.course_kind,'')<>l.course_type)")->fetchColumn(0);
    if ((int)$wrong!==0) throw new RuntimeException('Price lists still contain mismatched course types.');
    $report['lists']=array_map(static function($l){return ['id'=>(int)$l['id'],'kind'=>$l['course_type'],'name'=>$l['name'],'courses'=>(int)$l['course_total'],'url'=>'/bang-bao-gia/'.$l['slug']];},CoursePricing::lists());
    $db->commit();
} catch(Throwable $e) {$db->rollback();throw$e;}
finally {$db->execute("SELECT RELEASE_LOCK('meduc-pricing-three-types')");}
foreach(Cake\Cache\Cache::configured()as$c)Cake\Cache\Cache::clear($c);
echo json_encode($report,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT|JSON_THROW_ON_ERROR)."\n";
