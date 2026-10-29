<?php
/** CLI only: create the two public 32-subject catalogues from the approved v1 input.
 * Existing records are identified by SKU, never by a subject name or Fa ID.
 * Reruns preserve admin changes and existing attempts; --demo fills only empty slots.
 */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit;
$root=dirname(__DIR__);
define('SOURCE_DOMAIN',$root);
require $root.'/config_database.php';
require $root.'/coredaca/vendor/autoload.php';
require $root.'/coredaca/config/bootstrap.php';
use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;
use App\Service\CourseTypes;
use Cake\Datasource\ConnectionManager;
$db=ConnectionManager::get('default');
function require32(bool $ok,string $message): void { if (!$ok) throw new RuntimeException($message); }
function json32($value): string { return json_encode($value,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR); }
function insert32(string $table,array $row): int {
    global $db;
    $columns='`'.implode('`,`',array_keys($row)).'`';
    $db->execute('INSERT INTO `'.$table.'` ('.$columns.') VALUES ('.implode(',',array_fill(0,count($row),'?')).')',array_values($row));
    return (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
}
function faHash32(): string {
    global $db;
    $rows=$db->execute("SELECT p.id,a.id attribute_id,a.value FROM products p LEFT JOIN products_attribute a ON a.product_id=p.id WHERE p.course_kind='fa' ORDER BY p.id,a.id")->fetchAll('assoc');
    $quiz=$db->execute('SELECT q.id,q.fa_only,a.attribute_id,a.value FROM quizs q LEFT JOIN quizs_attribute a ON a.quiz_id=q.id WHERE q.fa_only=1 ORDER BY q.id,a.id')->fetchAll('assoc');
    return hash('sha256',json32([$rows,$quiz]));
}
$input=json_decode(file_get_contents(__DIR__.'/data/curriculum-32-v1.json'),true,512,JSON_THROW_ON_ERROR);
require32(count($input['subjects'])===32,'Expected exactly 32 subjects');
require32(array_sum(array_map(static function($s){return count($s['lessons']);},$input['subjects']))===823,'Expected 823 v1 lessons');
foreach($input['subjects'] as $s) require32($s['student_year']>=1 && $s['student_year']<=5,'Invalid student year');
$apply=in_array('--apply',$argv,true);
if (!$apply) { echo "Preview: 32 solution courses; 32 quiz courses; 823 curriculum lessons + 32 mock-exam lessons. Add --apply [--demo] to seed.\n";exit; }
require32((bool)$db->execute("SELECT GET_LOCK('meduc-seed-32-v1',0)")->fetchColumn(0),'Another seed is running');
$before=faHash32();$created=[];$manifest=['version'=>$input['version'],'source_sha256'=>$input['source_sha256'],'courses'=>[],'demo'=>[]];$now=time();
$db->begin();
try {
    foreach($input['subjects'] as $index=>$s) {
        $year=990+(int)$s['student_year'];
        require32((bool)$db->execute('SELECT 1 FROM categories WHERE id=:y AND parent_id=125 AND status=1 AND deleted=0',['y'=>$year])->fetchColumn(0),'Missing year category '.$year);
        foreach(['exam_solution'=>'S','quiz'=>'Q'] as $kind=>$prefix) {
            $skuCode='MEDUC-32V1-'.$prefix.'-'.$s['subject_code'];
            $existing=$db->execute('SELECT p.id,p.course_kind FROM products_item i JOIN products p ON p.id=i.product_id WHERE i.code=:c AND i.deleted=0 AND p.deleted=0',['c'=>$skuCode])->fetchAll('assoc');
            require32(count($existing)<=1,'Duplicate seed SKU '.$skuCode);
            $slug=($kind==='quiz'?'trac-nghiem-':'khoa-chua-de-').$s['slug'].'-v1';
            if ($existing) {
                $id=(int)$existing[0]['id'];require32($existing[0]['course_kind']===$kind,'Seed course changed type: '.$skuCode);
            } else {
                require32(!$db->execute('SELECT 1 FROM links WHERE url=:u AND deleted=0',['u'=>$slug])->fetchColumn(0),'URL already used: '.$slug);
                $id=insert32('products',['course_kind'=>$kind,'main_category_id'=>$year,'status'=>1,'draft'=>0,'deleted'=>0,'featured'=>0,'view'=>0,'position'=>1000-$index,'created_by'=>1,'created'=>$now,'updated'=>$now,'catalogue'=>0]);
                $description=$kind==='quiz'?'Luyện trắc nghiệm theo '.count($s['lessons']).' bài trong lộ trình MedUC version 1.':'Video chữa đề môn '.$s['subject_name'].'. Nội dung video đang được cập nhật.';
                if ($kind==='quiz' && $s['subject_code']==='MV2-S001') $description.=' Có dữ liệu mẫu theo bài và thi thử; các bài còn lại đang biên soạn.';
                insert32('products_content',['product_id'=>$id,'name'=>$s['subject_name'],'search_unicode'=>str_replace('-',' ',$s['slug']),'description'=>$description,'content'=>'','seo_title'=>($kind==='quiz'?'Trắc nghiệm ':'Khoá chữa đề ').$s['subject_name'],'seo_description'=>$description,'lang'=>'vi']);
                // Reuse the current exam-subject price, without assigning a price-list bundle.
                insert32('products_item',['product_id'=>$id,'code'=>$skuCode,'price'=>1500000,'price_special'=>499000,'discount_percent'=>66.73,'position'=>1,'status'=>1,'deleted'=>0]);
                insert32('links',['foreign_id'=>$id,'type'=>'product_detail','url'=>$slug,'lang'=>'vi','created'=>$now,'updated'=>$now,'deleted'=>0]);
                foreach([50,125,$year] as $category) insert32('categories_product',['product_id'=>$id,'category_id'=>$category]);
                $outline=[];
                if ($kind==='quiz') {
                    $group=null;
                    foreach($s['lessons'] as $l) {
                        if ($group!==$l['group_order']) {
                            $group=$l['group_order'];$outline[]=['name_vi'=>$l['group'],'chapter_vi'=>'y','code'=>$s['subject_code'].'-V1-C'.$group];
                        }
                        $outline[]=['name_vi'=>$l['title'],'code'=>$l['id'],'review_vi'=>'n','curriculum_version'=>$input['version']];
                    }
                    $outline[]=['name_vi'=>'Thi thử','chapter_vi'=>'y','code'=>$s['subject_code'].'-V1-C-REVIEW'];
                    $outline[]=['name_vi'=>'Thi thử','code'=>$s['subject_code'].'-REF-REVIEW','review_vi'=>'y','trial_vi'=>'y'];
                }
                insert32('products_attribute',['product_id'=>$id,'attribute_id'=>11,'value'=>json32($outline)]);
                CourseTypes::syncLessons($id);
                $created[]=$id;
            }
            $manifest['courses'][$s['subject_code']][$kind]=['id'=>$id,'url'=>'/'.$slug,'year'=>$s['student_year']];
        }
    }
    if (in_array('--demo',$argv,true)) {
        $bio=(int)$manifest['courses']['MV2-S001']['quiz']['id'];
        require32(CourseTypes::kind(316)==='fa','Expected Fa biology source');
        // Old and new lesson boundaries differ. Copy only these directly related topics for UI samples.
        $mapping=[1=>[2716],8=>[2722,2723],11=>[2725],16=>[2729,5698],19=>[2731,5695],22=>[2724],24=>[2734,5697]];
        $load=function(int $source) use ($db): array {
            require32(CourseTypes::privateQuiz($source),'Demo source must be private Fa');
            $raw=json_decode((string)$db->execute('SELECT value FROM quizs_attribute WHERE quiz_id=:q AND attribute_id=18',['q'=>$source])->fetchColumn(0),true,512,JSON_THROW_ON_ERROR);
            require32(is_array($raw) && count($raw)===count(QuizQuestions::fromValue(json32($raw))),'Source has unsupported question data');
            foreach($raw as $i=>&$q) {
                $q['sample_data']=true;
                $q['demo_source_quiz_id']=$source;
                $q['demo_source_question_position']=$i+1;
            }
            unset($q);return $raw;
        };
        $write=function(string $code,int $slot,array $questions,?string $title=null) use ($db,$bio,&$manifest): void {
            if (!$questions) return;
            $id=(int)$db->execute('SELECT quiz_id FROM course_quiz_slots WHERE product_id=:p AND lesson_code=:c AND slot=:s',['p'=>$bio,'c'=>$code,'s'=>$slot])->fetchColumn(0);
            require32($id>0,'Missing demo slot');
            $old=(string)$db->execute('SELECT value FROM quizs_attribute WHERE quiz_id=:q AND attribute_id=18',['q'=>$id])->fetchColumn(0);
            if (count(QuizQuestions::fromValue($old))>0) return; // Never replace edited questions or attempt history on a rerun.
            require32($slot!==1 || count($questions)===30,'Free samples must contain 30 questions');
            $db->execute('UPDATE quizs_attribute SET value=:v WHERE quiz_id=:q AND attribute_id=18',['v'=>json32($questions),'q'=>$id]);
            $db->execute('UPDATE quizs_attribute SET value=:v WHERE quiz_id=:q AND attribute_id=19',['v'=>(string)count($questions),'q'=>$id]);
            if ($title!==null) $db->execute('UPDATE quizs_content SET name=:n,search_unicode=:n WHERE quiz_id=:q AND lang=\'vi\'',['n'=>$title,'q'=>$id]);
            $manifest['demo'][]=['lesson'=>$code,'slot'=>$slot,'quiz_id'=>$id,'questions'=>count($questions)];
        };
        foreach($mapping as $lesson=>$sources) {
            $questions=[];foreach($sources as $source) $questions=array_merge($questions,$load($source));
            require32(count($questions)>=30,'Insufficient demo questions');
            $code='MV2-S001-REF-L'.str_pad((string)$lesson,2,'0',STR_PAD_LEFT);
            $write($code,1,array_slice($questions,0,30));
            $write($code,2,array_slice($questions,30,30));
        }
        $write('MV2-S001-REF-REVIEW',1,array_slice($load(2715),0,30),'Đề thi thử 1 · 30 câu mẫu');
        $write('MV2-S001-REF-REVIEW',2,$load(5686),'Đề thi thử 2 · 60 câu mẫu');
    }
    require32($before===faHash32(),'Fa source data changed: rolling back');
    $manifest['created_ids']=$created;
    $manifest['fa_sha256_unchanged']=$before;
    $db->commit();
} catch (Throwable $e) { $db->rollback();throw $e; }
finally { $db->execute("SELECT RELEASE_LOCK('meduc-seed-32-v1')"); }
foreach(Cake\Cache\Cache::configured() as $cache) Cake\Cache\Cache::clear($cache);
echo json_encode($manifest,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT|JSON_THROW_ON_ERROR)."\n";
