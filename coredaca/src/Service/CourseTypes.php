<?php
declare(strict_types=1);
namespace App\Service;

use App\Lib\LessonQuizzes;
use Cake\Datasource\ConnectionManager;
use InvalidArgumentException;

/** Course type is independent of year/subject categories and pricing packages. */
final class CourseTypes
{
    public const LABELS = ['knowledge'=>'Khoá ôn kiến thức', 'exam_solution'=>'Khoá chữa đề', 'quiz'=>'Khoá trắc nghiệm', 'fa'=>'Fa'];
    public static function kind(int $id): ?string
    {
        $value=ConnectionManager::get('default')->execute('SELECT course_kind FROM products WHERE id=:id AND deleted=0',['id'=>$id])->fetchColumn(0);
        return isset(self::LABELS[$value ?? '']) ? $value : null;
    }
    public static function admin(): bool { return defined('MEDUC_FA_ADMIN') && MEDUC_FA_ADMIN; }
    public static function privateQuiz(int $id): bool
    {
        return (bool)ConnectionManager::get('default')->execute('SELECT 1 FROM quizs WHERE id=:id AND fa_only=1',['id'=>$id])->fetchColumn(0);
    }
    public static function courseQuiz(int $quiz): bool
    {
        return (bool)ConnectionManager::get('default')->execute('SELECT 1 FROM quizs WHERE id=:id AND course_only=1',['id'=>$quiz])->fetchColumn(0);
    }
    public static function publicCourse(int $id): bool
    {
        return (bool)ConnectionManager::get('default')->execute("SELECT 1 FROM products WHERE id=:id AND deleted=0 AND status=1 AND COALESCE(draft,0)=0 AND COALESCE(course_kind,'')<>'fa'",['id'=>$id])->fetchColumn(0);
    }
    /** First quiz is always free, second always paid; legacy checkbox values cannot override this. */
    public static function quizzes(array $lesson, ?string $kind): array
    {
        if ($kind !== 'quiz') return [];
        $rows=array_slice(LessonQuizzes::of($lesson),0,2);
        foreach ($rows as $i=>&$row) $row['free']=$i===0;
        return $rows;
    }
    /** Called inside the product save transaction. Empty slots are created once, never on public reads. */
    public static function syncLessons(int $productId): void
    {
        $db=ConnectionManager::get('default');
        $kind=self::kind($productId);
        $row=$db->execute('SELECT id,value FROM products_attribute WHERE product_id=:id AND attribute_id=11',['id'=>$productId])->fetch('assoc');
        if ($kind !== 'quiz') $db->execute('DELETE FROM course_quiz_slots WHERE product_id=:id',['id'=>$productId]);
        if (!$row) return;
        $lessons=LessonQuizzes::lessons($row['value']);
        if ($kind==='fa') {
            $ids=LessonQuizzes::ids($lessons);
            if ($ids) $db->execute('UPDATE quizs SET fa_only=1 WHERE id IN ('.implode(',',$ids).')');
            return;
        }
        if ($kind!=='quiz') return; // Preserve legacy video exercises in storage, but do not expose them.
        $used=[];
        foreach ($lessons as &$lesson) {
            if (($lesson['chapter_vi']??'')==='y') continue;
            $quizzes=LessonQuizzes::of($lesson);
            if(count($quizzes)>2) throw new InvalidArgumentException('Mỗi bài của khoá trắc nghiệm chỉ có 2 bài tập.');
            for($i=0;$i<2;$i++) {
                $id=(int)($quizzes[$i]['id']??0);
                if ($id) {
                    $q=$db->execute('SELECT id,fa_only FROM quizs WHERE id=:id AND deleted=0',['id'=>$id])->fetch('assoc');
                    if (!$q || $q['fa_only'] || isset($used[$id])) throw new InvalidArgumentException('Mỗi bài tập phải dùng một đề riêng, không dùng đề Fa.');
                    $owner=$db->execute('SELECT product_id FROM course_quiz_slots WHERE quiz_id=:id AND product_id<>:product',['id'=>$id,'product'=>$productId])->fetchColumn(0);
                    if ($owner) throw new InvalidArgumentException('Đề này đã thuộc một môn trắc nghiệm khác.');
                } else {
                    $now=time();$name='Bài tập '.($i+1).' · '.trim((string)($lesson['name_vi']??'Bài học'));
                    $db->execute('INSERT INTO quizs (created,updated,status,draft,deleted,fa_only) VALUES (:now,:now,1,0,0,0)',['now'=>$now]);
                    $id=(int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
                    $db->execute("INSERT INTO quizs_content (quiz_id,name,lang,search_unicode) VALUES (:id,:name,'vi',:name)",['id'=>$id,'name'=>$name]);
                    $db->execute("INSERT INTO quizs_attribute (quiz_id,attribute_id,value) VALUES (:id,18,'[]'),(:id,19,'30')",['id'=>$id]);
                    $db->execute("INSERT INTO links (foreign_id,type,url,lang,created,updated,deleted) VALUES (:id,'quiz_detail',:url,'vi',:now,:now,0)",['id'=>$id,'url'=>'bai-tap-'.$productId.'-'.$id,'now'=>$now]);
                }
                $db->execute('UPDATE quizs SET course_only=1 WHERE id=:id',['id'=>$id]);
                $used[$id]=true;
                $quizzes[$i]=['id'=>$id,'free'=>$i===0?'y':'n'];
            }
            if (empty($lesson['code'])) $lesson['code']='lesson-'.bin2hex(random_bytes(8));
            $lesson['quizzes_vi']=json_encode($quizzes,JSON_UNESCAPED_UNICODE);
            $lesson['quiz_id_vi']=(string)$quizzes[0]['id'];
        }
        unset($lesson);
        $db->execute('DELETE FROM course_quiz_slots WHERE product_id=:id',['id'=>$productId]);
        foreach($lessons as $lesson) foreach(self::quizzes($lesson,'quiz') as $i=>$q) {
            $db->execute('INSERT INTO course_quiz_slots (product_id,lesson_code,slot,quiz_id) VALUES (:p,:l,:s,:q)', ['p'=>$productId,'l'=>$lesson['code'],'s'=>$i+1,'q'=>$q['id']]);
        }
        $db->execute('UPDATE products_attribute SET value=:value WHERE id=:id',['id'=>$row['id'],'value'=>json_encode($lessons,JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES)]);
    }
    public static function slot(int $product,int $quiz): ?array
    {
        $r=ConnectionManager::get('default')->execute('SELECT * FROM course_quiz_slots WHERE product_id=:p AND quiz_id=:q',['p'=>$product,'q'=>$quiz])->fetch('assoc');
        return $r ?: null;
    }
}
