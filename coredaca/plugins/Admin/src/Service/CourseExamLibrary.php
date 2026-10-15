<?php
declare(strict_types=1);

namespace Admin\Service;

use App\Lib\LessonQuizzes;
use Cake\Datasource\ConnectionManager;
use Cake\Http\Exception\NotFoundException;

class CourseExamLibrary
{
    public static function isImportedCourse(int $id): bool
    {
        return (bool)ConnectionManager::get('default')->execute(
            'SELECT 1 FROM exam_prep_courses WHERE product_id=:id LIMIT 1', ['id'=>$id]
        )->fetch('assoc');
    }

    public static function isExamPrep(int $id): bool
    {
        return (bool)ConnectionManager::get('default')->execute(
            "SELECT 1 FROM products p WHERE p.id=:id AND (p.main_category_id=125 OR EXISTS
             (SELECT 1 FROM categories_product cp JOIN categories c ON c.id=cp.category_id
              WHERE cp.product_id=p.id AND (c.id=125 OR c.path_id LIKE '%|125|%'))) LIMIT 1", ['id'=>$id]
        )->fetch('assoc');
    }

    public static function lessons(int $id): array
    {
        $db = ConnectionManager::get('default');
        $row = $db->execute('SELECT value FROM products_attribute WHERE product_id=:id AND attribute_id=11 LIMIT 1', ['id'=>$id])->fetch('assoc');
        $lessons = $row ? json_decode($row['value'], true) : [];
        if (!is_array($lessons)) return [];
        // a lesson may have several quizzes (App\Lib\LessonQuizzes); each gets its own row, under the lesson's position
        $ids = LessonQuizzes::ids($lessons);
        $info = [];
        if ($ids) {
            $rows = $db->execute('SELECT q.id, qc.name, m.year_in_title, m.school_name, m.source_category_name, m.question_count
                FROM quizs q LEFT JOIN quizs_content qc ON qc.quiz_id=q.id AND qc.lang=\'vi\'
                LEFT JOIN quiz_exam_metadata m ON m.quiz_id=q.id WHERE q.deleted=0 AND q.id IN ('.implode(',', array_unique($ids)).')')->fetchAll('assoc');
            foreach ($rows as $q) $info[(int)$q['id']]=$q;
        }
        $result=[];
        foreach ($lessons as $index=>$lesson) {
            if (!is_array($lesson)) continue;
            $quizIds=array_column(LessonQuizzes::of($lesson),'id') ?: [0];
            foreach ($quizIds as $place=>$quizId) {
                $name=(string)($lesson['name_vi']??'');
                if ($place>0) $name.=' · đề '.($place+1).(!empty($info[$quizId]['name']) ? ': '.$info[$quizId]['name'] : '');
                $result[]=[
                    'position'=>$index+1, 'name'=>$name,
                    'chapter'=>($lesson['chapter_vi']??'')==='y', 'review'=>($lesson['review_vi']??'')==='y',
                    'quiz_id'=>isset($info[$quizId])?$quizId:0, 'metadata'=>$info[$quizId]??[],
                ];
            }
        }
        return $result;
    }

    public static function exam(int $courseId, int $quizId): array
    {
        $found=false;
        foreach (self::lessons($courseId) as $lesson) {
            if (!$lesson['chapter'] && $lesson['quiz_id']===$quizId && $quizId>0) { $found=true; break; }
        }
        if (!$found) throw new NotFoundException('Đề không thuộc khóa học này.');
        $db=ConnectionManager::get('default');
        $row=$db->execute("SELECT q.id,qc.name,qa.value questions,qt.value duration,
            m.year_in_title,m.school_name,m.source_category_name
            FROM quizs q JOIN quizs_content qc ON qc.quiz_id=q.id AND qc.lang='vi'
            JOIN quizs_attribute qa ON qa.quiz_id=q.id AND qa.attribute_id=18
            LEFT JOIN quizs_attribute qt ON qt.quiz_id=q.id AND qt.attribute_id=19
            LEFT JOIN quiz_exam_metadata m ON m.quiz_id=q.id WHERE q.id=:id AND q.deleted=0 LIMIT 1",['id'=>$quizId])->fetch('assoc');
        if (!$row) throw new NotFoundException('Không tìm thấy nội dung đề.');
        $raw=json_decode($row['questions'],true);
        if (!is_array($raw)) throw new NotFoundException('Nội dung đề chưa hợp lệ.');
        $questions=[];
        foreach ($raw as $i=>$q) {
            $options=$q['options']??[];
            if (!$options) {
                foreach (['one','two','three','four','five'] as $j=>$word) {
                    $value=(string)($q['option_'.$word.'_vi']??'');
                    if (trim($value)!=='') $options[]=['key'=>chr(65+$j),'content'=>$value,'is_correct'=>(int)($q['answer_vi']??0)===$j+1];
                }
            }
            foreach ($options as &$option) {
                $option['content']=self::safeHtml((string)($option['content']??''));
                $option['is_correct']=!empty($option['is_correct']);
            }
            unset($option);
            $images=[];
            foreach ($q['images']??[] as $image) {
                $hash=(string)($image['url_hash']??'');
                if (preg_match('/^[a-f0-9]{64}$/D',$hash)) $images[]=['url_hash'=>$hash,'url'=>'https://meduc.duckdns.org/api/media/'.$hash];
            }
            $questions[]=['id'=>$i+1,'question_type'=>(string)($q['question_type']??''),
                'content'=>self::safeHtml((string)($q['name_vi']??'')),
                'explanation'=>self::safeHtml((string)($q['answer_detail_vi']??'')),
                'options'=>$options,'images'=>$images,'rubrics'=>$q['rubrics']??[]];
        }
        return ['exam'=>['id'=>$quizId,'name'=>$row['name'],'school'=>$row['school_name'],
            'year'=>$row['year_in_title'],'module'=>$row['source_category_name'],'duration'=>(int)$row['duration']],
            'questions'=>$questions];
    }

    public static function safeHtml(string $html): string
    {
        if ($html==='') return '';
        $dom=new \DOMDocument('1.0','UTF-8');
        $previous=libxml_use_internal_errors(true);
        $dom->loadHTML('<?xml encoding="utf-8" ?><div>'.$html.'</div>', LIBXML_NONET);
        libxml_clear_errors();libxml_use_internal_errors($previous);
        $allowed=['div','p','br','b','strong','i','em','u','s','sub','sup','ul','ol','li','table','thead','tbody','tr','th','td','span','h3','h4','blockquote'];
        $nodes=[];foreach ($dom->getElementsByTagName('*') as $node) $nodes[]=$node;
        foreach (array_reverse($nodes) as $node) {
            $tag=strtolower($node->nodeName);
            if (in_array($tag,['script','style','iframe','object','embed','form','input','button','svg'],true)) { if($node->parentNode)$node->parentNode->removeChild($node); continue; }
            if (!in_array($tag,$allowed,true) && !in_array($tag,['html','body'],true)) {
                while($node->firstChild)$node->parentNode->insertBefore($node->firstChild,$node);
                if($node->parentNode)$node->parentNode->removeChild($node);
            } else {
                while($node->attributes->length)$node->removeAttributeNode($node->attributes->item(0));
            }
        }
        $body=$dom->getElementsByTagName('body')->item(0);$result='';
        if($body)foreach($body->childNodes as $node)$result.=$dom->saveHTML($node);
        return $result;
    }
}
