<?php
declare(strict_types=1);

namespace App\View\Helper;
use Cake\View\Helper;
use Cake\Core\Exception\Exception;
use Cake\I18n\Date;
use Cake\I18n\Time;
use Cake\View\Helper\UrlHelper;
use Cake\Routing\Router;
use Cake\ORM\TableRegistry;
use Cake\Utility\Text;
use Cake\Utility\Hash;

class UtilitiesHelper extends Helper
{
    /** Chuyển đổi định dạng int sang định dạng ngày tháng năm
     * 
     * $int*: thời gian(int)
     * $format: định dạng ngày ngày tháng năm(string)
     * 
     * {$this->Utilities->convertIntgerToDateString($article.created)}
    */
    public function convertIntgerToDateString($int = null, $format = 'd/m/Y')
    {
        if(empty($int)) return null;
        if(empty($format)) $format = 'd/m/Y';

        try{
            $result = date(strval($format), intval($int));
        }catch (Exception $e) {
            return null;
        }
        return $result;
    }

    /** Chuyển đổi định dạng int sang định dạng giờ phút - ngày tháng năm
     * 
     * $int*: thời gian(int)
     * $format: định dạng giờ phút - ngày ngày tháng năm(string)
     * 
     * {$this->Utilities->convertIntgerToDateTimeString($article.created)}
    */
    public function convertIntgerToDateTimeString($int = null, $format = 'H:i - d/m/Y')
    {
        if(empty($int)) return null;
        if(empty($format)) $format = 'H:i - d/m/Y';

        try{
            $result = date(strval($format), intval($int));
        }catch (Exception $e) {
            return null;
        }
        
        return $result;
    }

    /** Chuyển đổi định dạng int sang định dạng giờ phút - ngày tháng năm
     * 
     * $int*: thời gian(int)
     * $format: định dạng giờ phút - ngày ngày tháng năm(string)
     * 
     * {$this->Utilities->convertIntgerToDateTimeString($article.created)}
    */
    public function formatDateTimeClient($str_time = null, $format = 'H:i - d/m/Y')
    {
        if(empty($str_time)) return null;

        $int = $this->stringDateTimeClientToInt($str_time);

        if(empty($format)) $str_time;

        try{
            $result = date(strval($format), intval($int));
        }catch (Exception $e) {
            return null;
        }
        
        return $result;
    }

    /** Chuyển đổi định dạng DataTime sang định dạng Int
     * 
     * $str_date*: thời gian(string) ví dụ: H:i - d/m/Y 
     * 
     * {$this->Utilities->stringDateTimeClientToInt($str_date)}
    */
    public function stringDateTimeClientToInt($str_date = null)
    {
        // check datetime H:i - d/m/Y 
        if(!$this->isDateTimeClient($str_date)){
            return null;
        }

        $time = Time::createFromFormat('H:i - d/m/Y', $str_date, null);
        $time = $time->format('Y-m-d H:i:s');
        return strtotime($time);
    }

    /** Kiểm tra định dạng DateTime
     * 
     * $str*: thời gian(string) ví dụ: H:i - d/m/Y 
     * 
     * {$this->Utilities->isDateTimeClient($str)}
    */
    public function isDateTimeClient($str = null)
    {
        // check datetime H:i - d/m/Y
        $matches = [];
        $pattern = '/^([0-9]{1,2})\:([0-9]{1,2})\s\-\s([0-9]{1,2})\\/([0-9]{1,2})\\/([0-9]{4})$/';
        if (!preg_match($pattern, $str, $matches)) return false;

        return true;
    }

    /** Lấy thời gian hiện tại
     * 
     * $format: thời gian(string) ví dụ: d/m/Y 
     * 
     * {$this->Utilities->getCurrentDate($format)}
    */
    public function getCurrentDate($format = null)
    {
        if(empty($format)) $format = 'Y-m-d';

        try{
            $date = date(strval($format));
        }catch (Exception $e) {
            return null;
        }

        return $date;
    }

    /** Lấy mã ngẫu nhiên bao gồm cả số cả chữ
     * 
     * $length: độ dài(int) 
     * 
     * {assign var = data value = $this->Utilities->randomCode()}
    */
    public function randomCode($length = 10)
    {
        return substr(str_shuffle(str_repeat($x = '0123456789abcdefghijklmnopqrstuvwxyz', intval(ceil($length/strlen($x))))), 1, $length);
    }

    /** Lấy ảnh thumb
     * 
     * $url*: đường dẫn ảnh(str) 
     * $size*: kích thước ảnh thumb(str) - ví dụ: 50 | 150 | 250 | 350
     * $source: nguồn từ website hoặc cdn mặc định website - ví dụ: template
     * 
     * {CDN_URL}{$this->Utilities->getThumbs($url, 150)}
     * {$this->Utilities->getThumbs($url, 350, 'template')}
    */
    public function getThumbs($url = null, $size = null, $source = null)
    {
        $result = [];
        if(empty($url) || empty($size) || !in_array($size, [50, 150, 250, 350, 500, 720])) return $result;
        
        $path_info = pathinfo($url);
        $extension = !empty($path_info['extension']) ? $path_info['extension'] : '';
        $filename = !empty($path_info['filename']) ? $path_info['filename'] : '';
        
        if(empty($extension)) return $result;

        switch ($source) {
            case 'template':
                $url = $this->str_replace_first('media', 'media_thumbs', $url);
                $path = explode('/', $url);
                break;
            
            default:
                $path = explode('/', $url);
                $path[1] = 'thumbs';
                break;
        }

        $num_last =  count($path) - 1;
        $path[$num_last] = $filename . '_thumb_'. $size . '.'. $extension;
        return implode('/', $path);
    }

    /** thay thế string đầu tiên trong văn bản
     * 
     * $find_string*: Từ cần thay thế(str) 
     * $replace*: Từ được thay thế(str)
     * $content*: Nội dung văn bản được áp dụng
     * 
     * {$this->Utilities->str_replace_first('media', 'media_thumbs', $url)}
    */
    public function str_replace_first($find_string = null, $replace = null, $content = null)
    {
        $find_string = '/' . preg_quote($find_string, '/') . '/';

        return preg_replace($find_string, $replace, $content, 1);
    }

    /** Lấy tên file
     * 
     * $url_file*: đường dẫn file
     * 
     * {assign var = data value = $this->Utilities->getFileNameInUrl($url_file)}
    */
    public function getFileNameInUrl($url_file = null)
    {
        if(empty($url_file)) return null;
        return pathinfo($url_file, PATHINFO_BASENAME);
    }    

    /** Lấy đường dẫn nội bộ
     * 
     * $url*: đường dẫn
     * 
     * {$this->Utilities->checkInternalUrl($url)}
    */
    public function checkInternalUrl($url = null)
    {
        if(empty($url)) return '';

        if(strpos($url, $this->getUrlWebsite()) === 0){
            $url = str_replace($this->getUrlWebsite(), '', $url);
        }

        if(strpos($url, 'https://') === 0 || strpos($url, 'http://') === 0 || strpos($url, 'www') === 0 || strpos($url, 'https://www') === 0){
            return $url;
        }

        if(strpos($url, '/') === 0){
            return $url;
        }
        
        return '/' . $url;
    }

    /** Thêm tham số vào đường dẫn
     * 
     * $url*: đường dẫn
     * $add: option thêm tham số đường dẫn
     * $remove: option xóa tham số đường dẫn
     * $options: cho phép truyền nhiều giá trị cách nhau bởi "-"
     * 
     * {$this->Utilities->addParamsToUrl($this->Url->build(), ['item_color' => $option_id], [], ['merge' => true])}
     * {$this->Utilities->addParamsToUrl($this->Url->build(), [], ['item_color'])}
    */
    public function addParamsToUrl($url = null, $add = [], $remove = [], $options = [])
    {
        if(empty($url)){
            $url = '/';
        }

        if(empty($add) && empty($remove)) return $url;

        $url_data = parse_url($url);
        $path = !empty($url_data['path']) ? $url_data['path'] : '';
        $query = [];
        if(!empty($url_data['query'])){
            $tmp = [];
            parse_str($url_data['query'], $tmp);
            
            foreach ($tmp as $k => $value) {
                $k = str_replace('amp;', '', $k);
                $query[$k] = $value;
            }
        }
        if(!empty($add)){
            foreach ($add as $key => $value) {
                if(!empty($options['merge']) && !empty($query[$key])){
                    $value = $query[$key] . '-' . $value;
                    $list_value = array_unique(explode('-', $value));
                    $query[$key] = implode('-', $list_value);
                }else{
                    $query[$key] = $value;
                }                
            }
        }
        
        $query_result = [];
        foreach ($query as $k => $value) {
            $k = str_replace('amp;', '', $k);
            $query_result[$k] = $value;
        }

        if(!empty($remove)){
            foreach ($remove as $key) {
                unset($query_result[$key]);
            }
        }
        $query_result = http_build_query($query_result);         
        return !empty($query_result) ? $path . '?' . $query_result : $path;
    }

    /** Đường dẫn hiện tại
     *
     * {$this->Utilities->getUrlCurrent()}
    */
    public function getUrlCurrent() 
    {
        return Router::url(null, true);
    }

    /** Đường dẫn hiện tại
     *
     * {$this->Utilities->getUrlPath()}
    */
    public function getUrlPath() 
    {
        $request = $this->getView()->getRequest();
        return $request->scheme() . '://' . $request->host() . $request->getPath();
    }

    /** tên miền
     *
     * {$this->Utilities->getUrlWebsite()}
    */
    public function getUrlWebsite()
    {
        $request = $this->getView()->getRequest();
        return $request->scheme() . '://' . $request->host();
    }

    /** Lấy value qua key trên url
     *
     * {assign var = data value = $this->Utilities->getParamsByKey('limit')}
    */
    public function getParamsByKey($key = null)
    {
        if(empty($key)) return null;
        return $this->getView()->getRequest()->getQuery($key);    
    }

    /** thay thế biến hệ thống
    */
    public function replaceVariableSystem($str = null)
    {
        if(empty($str)) return '';
        
        $str = str_replace('{URL_TEMPLATE}', URL_TEMPLATE, $str);
        $str = str_replace('{CDN_URL}', CDN_URL, $str);
        $str = str_replace('{PATH_TEMPLATE}', PATH_TEMPLATE, $str);
        $str = str_replace('{CODE_TEMPLATE}', CODE_TEMPLATE, $str);
        $str = str_replace('{PAGE_URL}', PAGE_URL, $str);
        $str = str_replace('{LANGUAGE}', LANGUAGE, $str);

        return $str;
    }

    /** Thay đổi định dạng thành danh sách id => value
     *
     * {assign var = data value = $this->Utilities->formatToList($data, 'id', 'name')}
    */
    public function formatToList($data = [], $key_id = 'id', $key_value = 'name')
    {
        if(empty($data) || !is_array($data)) return [];

        $result = [];
        foreach ($data as $item) {
            $id = !empty($item[$key_id]) ? $item[$key_id] : null;
            $value = !empty($item[$key_value]) ? $item[$key_value] : null;

            if(is_null($id) || is_null($value)) continue;
            $result[$id] = $value;
        }

        return $result;
    }

    /** Lấy ra bài quizs answer thỏa mãn >= $percent truyền vào
     * 
     * $customer_id: id người dùng
     * $product_id: id khóa học
     * $quiz_id: id bài quiz
     * $percent: phần trăm tối thiểu để thỏa mãn
     * 
     * {$this->Utilities->quizsAnswerPass($customer_id, $product_id, $quiz_id, $percent)}
    */
    public function quizsAnswerPass($customer_id = null, $product_id = null, $quiz_id = null, $percent = 0) {
        if(empty($customer_id)) return '';
        if(empty($product_id)) return '';
        if(empty($quiz_id)) return '';

        $quizs_answer_info = TableRegistry::get('QuizsAnswer')->find()->where([
            'deleted' => 0,
            'customer_id' => intval($customer_id),
            'product_id' => intval($product_id),
            'quiz_id' => intval($quiz_id),
            'answer_correct_percent >=' => floatval($percent),
        ])->select()->toList();

        if(empty($quizs_answer_info)) return [];

        return $quizs_answer_info;
    }

    /** Kiểm tra xem học viên có ở trong lớp học không
     * 
     * $customer_id: id học viên
     * $class_room_id: id lớp học
     * 
     * {$this->Utilities->checkExistMemberInClassRoom($customer_id, $class_room_id)}
    */
    public function checkExistMemberInClassRoom($customer_id = null, $class_room_id = null) {
        if(empty($customer_id)) return false;
        if(empty($class_room_id)) return false;

        function formatTime($seconds) {
            $minutes = floor($seconds / 60);
            $remainingSeconds = $seconds % 60;
            return $minutes . 'p ' . $remainingSeconds . 's';
        }

        $where = [
            'ClassRooms.deleted' => 0,
            'ClassRooms.id' => intval($class_room_id),
            'ClassRooms.users LIKE' => '%' . Text::slug(strtolower($customer_id), ' ') . '%'
        ];

        $classRoom = TableRegistry::get('ClassRooms')->find()->where($where)->select()->first();

        if(empty($classRoom)) return false;

        $pattern = '/(MEDUC\d{9}|CUS\d{9})/';
        $users = [];
        preg_match_all($pattern, $classRoom["users"], $users);
        $uniqueUsers = array_unique($users[0]);

        // Mảng users ban đầu
        $listUser = TableRegistry::get('Customers')
            ->find()
            ->where(['code IN' => $uniqueUsers])
            ->select(['code', 'full_name'])
            ->toList();

        // Mảng listQuizAnswer ban đầu
        $listQuizAnswer = TableRegistry::get('QuizsAnswer')
            ->find()
            ->where([
                'member_code IN' => $uniqueUsers,
                'class_room_id' => $class_room_id
            ])
            ->select([
                'class_room_id', 
                'member_code',
                'quiz_id',
                'answer_total',
                'answer_correct',
                'answer_wrong',
                'answer_correct_percent',
                'total_time',
            ])
            ->toList();

        // Tạo một mảng để lưu trữ câu trả lời nhóm theo member_code và quiz_id
        $groupedAnswers = [];

        foreach ($listQuizAnswer as $answer) {
            $memberCode = $answer->member_code;
            $quizId = $answer->quiz_id;
            
            if (!isset($groupedAnswers[$memberCode])) {
                $groupedAnswers[$memberCode] = [];
            }
            
            if (!isset($groupedAnswers[$memberCode][$quizId])) {
                $groupedAnswers[$memberCode][$quizId] = [
                    'quiz_id' => $quizId,
                    'repeat' => 0,
                    'answer_total' => $answer->answer_total,
                    'answer_correct_max' => 0,
                    'total_time' => 0
                ];
            }
            
            $groupedAnswers[$memberCode][$quizId]['repeat'] += 1;

            // Kiểm tra và cập nhật answer_correct_max và total_time
            if ($answer->answer_correct > $groupedAnswers[$memberCode][$quizId]['answer_correct_max']) {
                $groupedAnswers[$memberCode][$quizId]['answer_correct_max'] = $answer->answer_correct;
                $groupedAnswers[$memberCode][$quizId]['total_time'] = $answer->total_time;
            }
        }

        // Tạo mảng mới kết hợp thông tin từ users và groupedAnswers
        $result = [];

        foreach ($listUser as $user) {
            $total_point = 0;
            $total_time = 0;

            if (isset($groupedAnswers[$user->code])) {
                foreach ($groupedAnswers[$user->code] as $answer) {
                    $total_point += $answer['answer_correct_max'];
                    $total_time += $answer['total_time'];
                }
            }

            $userArray = [
                'code' => $user->code,
                'full_name' => $user->full_name,
                'total_point' => $total_point,
                'total_time' => $total_time,
                'listAnswer' => isset($groupedAnswers[$user->code]) ? array_values($groupedAnswers[$user->code]) : null
            ];

            // Định dạng lại total_time cho từng câu trả lời trong listAnswer
            if (!empty($userArray['listAnswer'])) {
                foreach ($userArray['listAnswer'] as $key => $answer) {
                    $userArray['listAnswer'][$key]['total_time'] = formatTime($answer['total_time']);
                }
            }

            $result[] = $userArray;
        }

        // Sắp xếp mảng kết quả theo total_point giảm dần và total_time tăng dần
        usort($result, function($a, $b) {
            if ($a['total_point'] === $b['total_point']) {
                return $a['total_time'] - $b['total_time'];
            }
            return $b['total_point'] - $a['total_point'];
        });

        // Định dạng lại total_time trong mảng kết quả sau khi sắp xếp
        foreach ($result as &$user) {
            $user['total_time'] = formatTime($user['total_time']);
        }

        // Chia mảng $result thành 3 phần bằng cách tính độ dài của mảng
        // $totalUsers = count($result);
        // $greenSize = floor($totalUsers * 0.2);
        // $orangeSize = floor($totalUsers * 0.3);
        // $redSize = $totalUsers - $greenSize - $orangeSize; // Phần còn lại là 50%
        
        // Thêm thuộc tính 'color' vào từng phần
        // for ($i = 0; $i < $totalUsers; $i++) {
        //     if ($i < $greenSize) {
        //         $result[$i]['color'] = 'green';
        //     } elseif ($i >= $greenSize && $i < $greenSize + $orangeSize) {
        //         $result[$i]['color'] = 'orange';
        //     } else {
        //         $result[$i]['color'] = 'red';
        //     }
        // }
        
        $totalUsers = count($result);
        $greenSize = 10;
        $orangeSize = 20;
        
        for ($i = 0; $i < $totalUsers; $i++) {
            if ($i < $greenSize) {
                $result[$i]['color'] = 'green';
            } elseif ($i < $greenSize + $orangeSize) {
                $result[$i]['color'] = 'orange';
            } else {
                $result[$i]['color'] = 'red';
            }
        }

        return [
            "id" => $classRoom["id"],
            "class_name" => $classRoom["name"],
            "product_id" => $classRoom["product_id"],
            "users" => $result
        ];
    }

    /** Kiểm tra xem học viên có ở trong lớp học không
     * 
     * $product_id: id lớp học
     * $attribute_id: id danh sách tiết học
     * 
     * {$this->Utilities->getListQuiz($customer_id, $class_room_id)}
    */
    public function getListQuiz($product_id = null, $attribute_id = null) {
        if(empty($product_id)) return false;
        if(empty($attribute_id)) return false;

        $productAttribute = TableRegistry::get('ProductsAttribute')
            ->find()
            ->where([
                'product_id' => $product_id,
                'attribute_id' => $attribute_id
            ])
            ->first();

        if(empty($productAttribute)) return false;

        $arrayValue = json_decode($productAttribute["value"], true);
        $quizIds = Hash::extract($arrayValue, '{n}.quiz_id_vi');
        $quizIds = array_filter($quizIds, function($value) {
            return !empty($value);
        });
        $quizIds = array_map('intval', $quizIds);

        // Kiểm tra nếu $quizIds rỗng và trả về mảng rỗng nếu đúng
        if (empty($quizIds)) {
            return [];
        }

        $listQuizContent = TableRegistry::get('QuizsContent')
            ->find()
            ->where(['quiz_id IN' => array_values($quizIds)])
            ->select(['quiz_id', 'name'])
            ->toList();

        // Tạo một mảng kết hợp từ kết quả truy vấn với quiz_id làm khóa
        $quizContentById = [];
        foreach ($listQuizContent as $quizContent) {
            $quizContentById[$quizContent->quiz_id] = $quizContent;
        }

        // Sắp xếp kết quả theo thứ tự của $quizIds
        $sortedQuizContent = [];
        foreach ($quizIds as $key => $quizId) {
            if (isset($quizContentById[$quizId])) {
                $sortedQuizContent[] = $quizContentById[$quizId];
            }
        }

        return $sortedQuizContent;
    }

    /** Định dạng số giây sang phút và giây */
    public function formatQuizTime($seconds = 0) {
        $seconds = (int)$seconds;
        $minutes = floor($seconds / 60);
        $remainingSeconds = $seconds % 60;
        return $minutes . 'p ' . $remainingSeconds . 's';
    }

    /** Lịch sử làm bài tập của học viên
     * 
     * $member_code: id học viên
     * 
     * {$this->Utilities->getListHistoryQuiz($member_code)}
    */
    public function getListHistoryQuiz($member_code = null) {
        if(empty($member_code)) return [];

        $listHistoryQuiz = TableRegistry::get('QuizsAnswer')
            ->find()
            ->where([
                'member_code' => $member_code
            ])
            ->order(['created' => 'DESC'])
            ->toList();

        if(empty($listHistoryQuiz)) return [];

        $result = [];
        foreach ($listHistoryQuiz as $index => $item) {
            $classRoom = TableRegistry::get('ClassRooms')
                ->find()
                ->where([
                    'id' => $item["class_room_id"]
                ])
                ->first();

            $quizsContent = TableRegistry::get('QuizsContent')
                ->find()
                ->where([
                    'id' => $item["quiz_id"]
                ])
                ->first();

            $formattedTime = $this->formatQuizTime($item['total_time'] ?? 0);

            $result[$index] = [
                "id" => $item["id"],
                "class_name" => !empty($classRoom["name"]) ? $classRoom["name"] : 'Chung',
                "quiz_name" => !empty($quizsContent["name"]) ? $quizsContent["name"] : 'Bài tập',
                "answer_total" => $item["answer_total"] ?? 0,
                "answer_correct" => $item["answer_correct"] ?? 0,
                "total_time" => $formattedTime,
                "created" => $item["created"] ?? 0,
            ];
        }

        return $result;
    }

    /** Lấy ra chi tiết kết quả bài làm của học viên
     * 
     * $member_code: id học viên
     * $id: id bài làm
     * 
     * {$this->Utilities->getResultQuiz($member_code, $id)}
    */
    public function getResultQuiz($member_code = null, $id = null) {
        if(empty($member_code)) return false;
        if(empty($id)) return false;

        $resultQuiz = TableRegistry::get('QuizsAnswer')
            ->find()
            ->where([
                'id' => $id,
                'member_code' => $member_code
            ])
            ->first();

        if(empty($resultQuiz)) return false;

        $classRoom = TableRegistry::get('ClassRooms')
            ->find()
            ->where([
                'id' => $resultQuiz["class_room_id"]
            ])
            ->first();

        $quizsContent = TableRegistry::get('QuizsContent')
            ->find()
            ->where([
                'id' => $resultQuiz["quiz_id"]
            ])
            ->first();

        $quizsAttribute = TableRegistry::get('QuizsAttribute')
            ->find()
            ->where([
                'quiz_id' => $resultQuiz["quiz_id"],
                'attribute_id' => 18,
            ])
            ->first();

        $questions = !empty($quizsAttribute["value"]) ? json_decode($quizsAttribute["value"]) : [];
        $answers = !empty($resultQuiz["answers"]) ? json_decode($resultQuiz["answers"]) : [];

        $formattedTime = $this->formatQuizTime($resultQuiz['total_time'] ?? 0);

        $questionsAnswers = [];

        if (is_array($questions) || is_object($questions)) {
            foreach ($questions as $question) {
                if (isset($question->code)) {
                    $questionsAnswers[$question->code] = (array) $question;
                }
            }
        }

        if (is_array($answers) || is_object($answers)) {
            foreach ($answers as $answer) {
                if (isset($answer->code) && isset($questionsAnswers[$answer->code])) {
                    $questionsAnswers[$answer->code]['answer_choose'] = $answer->answer;
                }
            }
        }

        $result = [
            "id" => $resultQuiz["id"],
            "class_name" => !empty($classRoom["name"]) ? $classRoom["name"] : 'Chung',
            "quiz_name" => !empty($quizsContent["name"]) ? $quizsContent["name"] : 'Bài tập',
            "answer_total" => $resultQuiz["answer_total"] ?? 0,
            "answer_correct" => $resultQuiz["answer_correct"] ?? 0,
            "answer_wrong" => $resultQuiz["answer_wrong"] ?? 0,
            "answer_correct_percent" => $resultQuiz["answer_correct_percent"] ?? 0,
            "total_time" => $formattedTime,
            "questionsAnswers" => $questionsAnswers,
            "created" => $resultQuiz["created"] ?? 0,
        ];

        return $result;
    }
    
    public function getUrlPathTwo() 
    {
        $path = $this->getView()->getRequest()->getPath();
        $path = str_replace("/", "", $path);

        if(strpos($path, '/') === 0){
            return $path;
        }
        
        return $path;
    }
    
    // public function getAllArticleFromSlug($slug = null)
    // {
    //     if(empty($slug)) return '';

    //     $result = [];

    //     $link = TableRegistry::get('Links')->find()->where([
    //         'Links.url' => $slug,
    //         'Links.deleted' => 0,
    //     ])->first();

    //     $article = TableRegistry::get('Articles')->find()->where([
    //         'Articles.id' => $link["foreign_id"],
    //         'Articles.deleted' => 0,
    //     ])->first();

    //     $categoryCurrent = TableRegistry::get('Categories')->find()->where([
    //         'Categories.id' => $article["main_category_id"],
    //         'Categories.deleted' => 0,
    //     ])->first();

    //     $category_id = TableRegistry::get('Categories')->getAllChildCategoryId($categoryCurrent["parent_id"], "ASC");

    //     $data = [];

    //     foreach($category_id as $key => $id){
    //         $info = TableRegistry::get('Categories')->find()->contain(['CategoriesContent', 'Links'])->where([
    //             'Categories.id' => $id,
    //             'Categories.deleted' => 0,
    //         ])->first();
    //         if($key !== 0) {
    //             $obj = [];
    //             $obj["id"] = $info["id"];
    //             $obj["name"] = $info["CategoriesContent"]["name"];
    //             $obj["link"] = $info["Links"]["url"];

    //             $arts = TableRegistry::get('Articles')->find()->contain(['ArticlesContent', 'Links'])->where([
    //                 'Articles.deleted' => 0,
    //                 'Articles.main_category_id' => $id,
    //                 'Links.deleted' => 0,
    //                 'Links.type' => 'article_detail',
    //             ])->select(['Articles.id', 'ArticlesContent.name', 'Links.url'])->order(['Articles.position' => 'ASC'])->toList();

    //             $obj["arts"] = $arts;
            
    //             $data[] = $obj;
    //         }
    //     }
        
    //     $result["data"] = $data;
        
    //     return $result;
    // }
    
    public function getAllArticleFromSlug($slug = null)
    {
        if (empty($slug)) return '';
    
        $result = [];
    
        // Tìm link bài viết
        $link = TableRegistry::get('Links')->find()->where([
            'Links.url' => $slug,
            'Links.deleted' => 0,
        ])->first();
    
        if (empty($link)) return '';
    
        // Lấy bài viết từ link
        $article = TableRegistry::get('Articles')->find()->where([
            'Articles.id' => $link["foreign_id"],
            'Articles.deleted' => 0,
        ])->first();
    
        if (empty($article)) return '';
    
        // ✅ Lấy chính danh mục mà bài viết này thuộc về
        $category = TableRegistry::get('Categories')->find()
            ->contain(['CategoriesContent', 'Links'])
            ->where([
                'Categories.id' => $article["main_category_id"],
                'Categories.deleted' => 0,
            ])
            ->first();
    
        if (empty($category)) return '';
    
        // ✅ Lấy danh sách bài viết trong danh mục đó
        $articlesInCategory = TableRegistry::get('Articles')->find()
            ->contain(['ArticlesContent', 'Links'])
            ->where([
                'Articles.deleted' => 0,
                'Articles.main_category_id' => $category["id"],
                'Links.deleted' => 0,
                'Links.type' => 'article_detail',
            ])
            ->select(['Articles.id', 'ArticlesContent.name', 'Links.url'])
            ->order(['Articles.position' => 'ASC'])
            ->toList();
    
        // ✅ Chuẩn bị dữ liệu trả về
        $data = [];
        $obj = [
            "id" => $category["id"],
            "name" => $category["CategoriesContent"]["name"],
            "link" => $category["Links"]["url"],
            "arts" => $articlesInCategory
        ];
    
        $data[] = $obj;
    
        $result["data"] = $data;
    
        return $result;
    }

}
