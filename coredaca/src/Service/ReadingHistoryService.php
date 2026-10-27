<?php
declare(strict_types=1);
namespace App\Service;

use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use App\Lib\LessonQuizzes;

/** Resolve public CMS records; never trust titles, destinations or file URLs posted by a browser. */
class ReadingHistoryService
{
    private $lang;
    public function __construct(string $lang) { $this->lang=$lang; }

    public function articles(string $kind,array $ids): array
    {
        $ids=array_values(array_unique(array_filter(array_map('intval',$ids),function($id){return $id>0;})));
        if (!$ids) return [];
        if (in_array($kind,['course','exam_course'],true)) return $this->courses($kind,$ids);
        $table=TableRegistry::get('Articles');
        $rows=$table->queryListArticles(['get_categories'=>true,FILTER=>[LANG=>$this->lang,STATUS=>1,'ids'=>$ids,'id_categories'=>$kind==='blog'?[45,113]:[48]]])->where(['Articles.draft'=>0])->enableHydration(false)->toList();
        $result=[];
        foreach ($rows as $row) {
            $a=$table->formatDataArticleDetail($row,$this->lang);
            $url=trim((string)($a['url']??''));
            if (!$url || preg_match('~^(?:[a-z][a-z0-9+.-]*:|//)~i',$url)) continue;
            $name=$this->plain((string)($a['name']??''));
            if (!$name) continue;
            $topic=$kind==='blog'?'Góc học tập':'Tài liệu Y khoa';
            foreach ($a['categories']??[] as $cat) {
                if (in_array((int)$cat['id'],[45,48,113],true)) continue;
                $topic=preg_replace('/^(?:Blog|Tài liệu)\s+/iu','',$this->plain((string)$cat['name']));break;
            }
            $title=$name;
            if ($kind==='document' && preg_match('/^\[([^\]]+)\]\s*(.+)$/u',$name,$m)) {
                $title=$m[2];$topic=trim(preg_replace('/^Năm\s*[1-4]\s*[-–—]?\s*/iu','',$m[1]));
            }
            $image=(string)($a['image_avatar']??'');
            if ($image && !preg_match('~^https?://~i',$image)) $image=rtrim(CDN_URL,'/').'/'.ltrim($image,'/');
            if ($image && !preg_match('~^https?://~i',$image)) $image='';
            $result[(int)$a['id']]=['article_id'=>(int)$a['id'],'kind'=>$kind,'title'=>$title,'topic'=>$topic,'image'=>$image,'url'=>'/'.ltrim($url,'/'),'files'=>$this->files($a)];
        }
        return $result;
    }

    /** Public course metadata only. The history key's kind separates regular courses from exam preparation. */
    private function courses(string $kind,array $ids): array
    {
        $table=TableRegistry::get('Products');
        $rows=$table->queryListProducts(['get_categories'=>true,'get_attributes'=>true,
            FILTER=>[LANG=>$this->lang,STATUS=>1,STATUS_ITEM=>1,'draft'=>'0','ids'=>$ids,'id_categories'=>[50]]])->where(['Products.draft'=>0])->limit(3)->toList();
        $examCategories=TableRegistry::get('Categories')->getAllChildCategoryId(125);
        $result=[];
        foreach ($rows as $row) {
            $course=$table->formatDataProductDetail($row,$this->lang);
            $exam=(int)$course['main_category_id']===125 || (bool)array_intersect(array_keys($course['categories']??[]),$examCategories);
            if ($exam!==($kind==='exam_course')) continue;
            $url=trim((string)($course['url']??''));$name=$this->plain((string)($course['name']??''));
            if (!$name || !$url || preg_match('~^(?:[a-z][a-z0-9+.-]*:|//)~i',$url)) continue;
            $url='/'.ltrim($url,'/');
            $lessons=json_decode($course['attributes']['danhsachtiethoc']['value']??'',true);
            $chapters=$count=$video=$quiz=0;
            foreach (is_array($lessons)?$lessons:[] as $lesson) {
                if (!is_array($lesson) || empty($lesson['name_'.$this->lang])) continue;
                if (($lesson['chapter_'.$this->lang]??'')==='y') { $chapters++;continue; }
                $count++;
                $youtube=preg_replace('/[^\w-].*$/s','',trim((string)($lesson['youtube_id_'.$this->lang]??'')));
                if (!$video && ($lesson['trial_'.$this->lang]??'')==='y' && strlen($youtube)===11) $video=$count;
                foreach (LessonQuizzes::of($lesson,$this->lang) as $exercise) if (!$quiz && $exercise['free']) $quiz=$count;
            }
            $preview=$exam?$quiz:($video?:$quiz);
            $previewUrl=$preview?$url.'?bai='.$preview.'&tab='.($exam||!$video?'quiz':'video'):$url;
            $first=$course['items'][0]??[];$price=(float)($first['price']??0);$old=0;
            if (!empty($first['apply_special']) && (float)($first['price_special']??0)>0 && (float)$first['price_special']<$price) {
                $old=$price;$price=(float)$first['price_special'];
            }
            $image=(string)(array_values($course['all_images']??[])[0]??'');
            if ($image && !preg_match('~^https?://~i',$image)) $image=rtrim(CDN_URL,'/').'/'.ltrim($image,'/');
            if ($image && !preg_match('~^https?://~i',$image)) $image='';
            $id=(int)$course['id'];
            $result[$id]=['article_id'=>$id,'kind'=>$kind,'title'=>$name,'image'=>$image,'url'=>$url,
                'chapters'=>$chapters,'lessons'=>$count,'price'=>$price,'old_price'=>$old,
                'preview_url'=>$previewUrl,'preview_label'=>$preview?($exam?'Luyện thi miễn phí':'Học thử miễn phí'):'Xem lại khoá học'];
        }
        return $result;
    }

    /** Same attachment order and normalization as DocumentHelper's detail page. */
    private function files(array $article): array
    {
        $files=[];
        foreach ($article['files']??[] as $file) {
            if (!is_string($file) || trim($file)==='') continue;
            $path=str_replace('\\','',trim($file));
            if (preg_match('~^https?://~i',$path)) $url=$path;
            elseif (strpos($path,'/media/')===0 || strpos($path,'media/')===0) $url='https://meduc.vn/cdn/'.ltrim($path,'/');
            else continue;
            $url=str_replace(' ','%20',$url);
            if (isset($files[$url])) continue;
            $files[$url]=['url'=>$url,'pdf'=>strtolower(pathinfo(rawurldecode((string)parse_url($url,PHP_URL_PATH)),PATHINFO_EXTENSION))==='pdf'];
        }
        return array_values($files);
    }

    public function recent(int $customer,string $kind): array
    {
        $rows=ConnectionManager::get('default')->execute('SELECT article_id,progress,visited_at FROM customer_reading_history WHERE customer_id=:customer AND kind=:kind ORDER BY visited_at DESC,id DESC LIMIT 3',['customer'=>$customer,'kind'=>$kind])->fetchAll('assoc');
        $articles=$this->articles($kind,array_column($rows,'article_id'));
        $items=[];
        foreach ($rows as $row) {
            $id=(int)$row['article_id'];if (!isset($articles[$id])) continue;
            $item=$articles[$id];unset($item['files']);
            $item['progress']=json_decode((string)$row['progress'],true)?:[];
            $item['visited_at']=(int)$row['visited_at'];$items[]=$item;
        }
        return $items;
    }

    public function visit(int $customer,string $kind,int $id): void
    {
        $db=ConnectionManager::get('default');
        $db->transactional(function()use($db,$customer,$kind,$id){
            // Serialize visits from multiple tabs before keeping exactly three records per kind.
            $db->execute('SELECT id FROM customers WHERE id=:id FOR UPDATE',['id'=>$customer])->fetch('assoc');
            $now=(int)floor(microtime(true)*1000);
            $db->execute('INSERT INTO customer_reading_history (customer_id,kind,article_id,progress,visited_at,updated_at) VALUES (:customer,:kind,:article,\'{}\',:visited,:updated) ON DUPLICATE KEY UPDATE visited_at=VALUES(visited_at)',['customer'=>$customer,'kind'=>$kind,'article'=>$id,'visited'=>$now,'updated'=>$now]);
            $keep=$db->execute('SELECT id FROM customer_reading_history WHERE customer_id=:customer AND kind=:kind ORDER BY visited_at DESC,id DESC LIMIT 3',['customer'=>$customer,'kind'=>$kind])->fetchAll('assoc');
            $ids=implode(',',array_map('intval',array_column($keep,'id')));
            if ($ids) $db->execute('DELETE FROM customer_reading_history WHERE customer_id=:customer AND kind=:kind AND id NOT IN ('.$ids.')',['customer'=>$customer,'kind'=>$kind]);
        });
    }

    public function save(int $customer,string $kind,int $id,array $progress): void
    {
        ConnectionManager::get('default')->execute('UPDATE customer_reading_history SET progress=:progress,updated_at=:updated WHERE customer_id=:customer AND kind=:kind AND article_id=:article',['customer'=>$customer,'kind'=>$kind,'article'=>$id,'progress'=>json_encode($progress,JSON_UNESCAPED_UNICODE),'updated'=>(int)floor(microtime(true)*1000)]);
    }

    public function progress(string $kind,array $p,array $article): array
    {
        if ($kind==='document') {
            $file=filter_var($p['file_index']??null,FILTER_VALIDATE_INT);
            $page=filter_var($p['page']??null,FILTER_VALIDATE_INT);
            if ($file===false || $file===null || !isset($article['files'][$file]) || $page===false || $page===null || $page<1 || $page>100000) throw new \InvalidArgumentException('Vị trí tài liệu không hợp lệ.');
            return ['file_index'=>$file,'page'=>$page];
        }
        $ratio=filter_var($p['ratio']??null,FILTER_VALIDATE_FLOAT);
        if ($ratio===false || $ratio===null || !is_finite($ratio) || $ratio<0 || $ratio>1) throw new \InvalidArgumentException('Vị trí bài viết không hợp lệ.');
        $index=max(0,min(100000,(int)($p['anchor_index']??0)));
        $offset=max(0,min(10000,(int)($p['offset']??0)));
        $text=is_string($p['anchor_text']??null)?mb_substr($p['anchor_text'],0,160):'';
        return ['ratio'=>$ratio,'anchor_index'=>$index,'anchor_text'=>$text,'offset'=>$offset];
    }

    private function plain(string $s): string { return trim(preg_replace('/\s+/u',' ',html_entity_decode(strip_tags($s),ENT_QUOTES|ENT_HTML5,'UTF-8'))??''); }
}
