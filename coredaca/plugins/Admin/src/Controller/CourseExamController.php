<?php
declare(strict_types=1);

namespace Admin\Controller;

use Admin\Service\CourseExamLibrary;
use Admin\Service\TeacherCourseAccess;
use App\Service\ExamWordExporter;
use Cake\Event\EventInterface;
use Cake\Http\Exception\ForbiddenException;
use Cake\Http\Exception\NotFoundException;
use Cake\Http\Exception\UnauthorizedException;

class CourseExamController extends AppController
{
    private $manager=false;

    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
        $user=$this->Auth->user();
        if (empty($user['id'])) throw new UnauthorizedException('Vui lòng đăng nhập.');
        $account=TeacherCourseAccess::accountState((int)$user['id']);
        $this->manager=!empty($user['supper_admin']) || ($account && (int)$account['role_id']===1 && (int)$account['status']===1 && (int)$account['deleted']===0);
        if (!$this->manager && !$this->teacherCourseOnly) throw new ForbiddenException('Chỉ quản trị viên và giáo viên được xem đề.');
        $this->autoRender=false;
    }

    private function requireCourse(int $courseId): void
    {
        if (!TeacherCourseAccess::isCourse($courseId)) throw new ForbiddenException('Không tìm thấy khóa học.');
        if (!$this->manager && \App\Service\CourseTypes::kind($courseId) === 'fa') throw new ForbiddenException('Fa chỉ dành cho admin.');
        if (!$this->manager && !TeacherCourseAccess::isAssigned((int)$this->Auth->user('id'),$courseId)) {
            throw new ForbiddenException('Khóa học chưa được phân công cho giáo viên này.');
        }
    }

    public function preview($courseId=null,$quizId=null)
    {
        $this->requireCourse((int)$courseId);
        $data=CourseExamLibrary::exam((int)$courseId,(int)$quizId);
        return $this->response->withType('application/json')->withHeader('Cache-Control','private, no-store')
            ->withStringBody(json_encode($data,JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_SUBSTITUTE));
    }

    public function word($courseId=null,$quizId=null)
    {
        if (\App\Service\CourseTypes::kind((int)$courseId) !== 'fa') throw new NotFoundException('Không tìm thấy trang.');
        $placement = (string)$this->request->getQuery('answers', 'end');
        if (!in_array($placement, ['inline','end'], true)) throw new \Cake\Http\Exception\BadRequestException('Vị trí đáp án không hợp lệ.');
        if (!$this->manager) throw new ForbiddenException('Chỉ quản trị viên được tải Word.');
        $this->requireCourse((int)$courseId);
        $data=CourseExamLibrary::exam((int)$courseId,(int)$quizId);
        @set_time_limit(120);
        try {
            $images=$this->loadImages($data['questions']);
            $path=(new ExamWordExporter())->create($data,static function($hash)use($images){return $images[$hash]??null;},$placement);
        } catch (\RuntimeException $error) {
            return $this->response->withStatus(503)->withType('application/json')->withHeader('Cache-Control','private, no-store')
                ->withStringBody(json_encode(['error'=>$error->getMessage()],JSON_UNESCAPED_UNICODE));
        }
        try { $bytes=file_get_contents($path); } finally { @unlink($path); }
        return $this->response->withType('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
            ->withHeader('Content-Disposition','attachment; filename="meduc-de-'.(int)$quizId.'-'.$placement.'.docx"')
            ->withHeader('Cache-Control','private, no-store')->withStringBody($bytes);
    }

    private function loadImages(array $questions): array
    {
        $hashes=[];foreach($questions as $q)foreach($q['images'] as $image)$hashes[$image['url_hash']]=true;
        $images=[];
        foreach(array_chunk(array_keys($hashes),8) as $batch){
            $multi=curl_multi_init();$handles=[];
            foreach($batch as $hash){
                $handle=curl_init('https://meduc.duckdns.org/api/media/'.$hash);
                curl_setopt_array($handle,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_CONNECTTIMEOUT=>5,CURLOPT_TIMEOUT=>12,CURLOPT_FOLLOWLOCATION=>false]);
                curl_multi_add_handle($multi,$handle);$handles[$hash]=$handle;
            }
            do {curl_multi_exec($multi,$running);if($running && curl_multi_select($multi,1.0)===-1)usleep(10000);}while($running);
            $failed=false;
            foreach($handles as $hash=>$handle){
                $bytes=curl_multi_getcontent($handle);$status=curl_getinfo($handle,CURLINFO_HTTP_CODE);
                $info=$status===200 && $bytes && strlen($bytes)<=8000000 ? @getimagesizefromstring($bytes) : false;
                if($info)$images[$hash]=['bytes'=>$bytes,'width'=>$info[0],'height'=>$info[1],'mime'=>$info['mime']];else $failed=true;
                curl_multi_remove_handle($multi,$handle);curl_close($handle);
            }
            curl_multi_close($multi);
            if($failed)throw new \RuntimeException('Chưa tải được hình minh họa của đề. Vui lòng thử tải Word lại.');
        }
        return $images;
    }
}
