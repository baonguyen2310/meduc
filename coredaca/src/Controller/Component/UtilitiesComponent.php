<?php

namespace App\Controller\Component;
use Cake\Controller\Component;
use Cake\I18n\Date;
use Cake\I18n\Time;

class UtilitiesComponent extends Component
{
    public function errorModel($list_errors = [])
    {
        $result = [];
        if(empty($list_errors)) return [];
        foreach($list_errors as $key => $errors){
            if(is_array($errors)){
                foreach($errors as $k => $error){
                    if(is_array($error)){
                        foreach($error as $e){
                            @$result[] = $k . ' - ' . $e;
                        }
                    }else{
                        $result[] = $key . ' - ' . $error;    
                    }                    
                }
            }else{
                $result[] = $key . ' - ' . $error;
            }
        }
        return $result;
    }

    public function isJson($json_str = null)
    {
        return is_string($json_str) && is_array(json_decode($json_str, true)) && (json_last_error() == JSON_ERROR_NONE) ? true : false;
    }

    public function isDateClient($str = null)
    {
        // check date d/m/Y 
        $matches = [];
        $pattern = '/^([0-9]{1,2})\\/([0-9]{1,2})\\/([0-9]{4})$/';
        if (!preg_match($pattern, $str, $matches)) return false;
        if (!checkdate($matches[2], $matches[1], $matches[3])) return false;
        return true;
    }

    public function isDateTimeClient($str = null)
    {
        // check datetime H:i - d/m/Y
        $matches = [];
        $pattern = '/^([0-9]{1,2})\:([0-9]{1,2})\s\-\s([0-9]{1,2})\\/([0-9]{1,2})\\/([0-9]{4})$/';
        if (!preg_match($pattern, $str, $matches)) return false;
        if (!checkdate($matches[4], $matches[3], $matches[5])) return false;
        return true;
    }

    public function stringDateClientToInt($str_date = null)
    {   
        // check datetime d/m/Y 
        if(!$this->isDateClient($str_date)){
            return null;
        }
        return strtotime(date('Y-m-d', strtotime(str_replace('/', '-', $str_date))));
    }

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

    public function stringDateToInt($str_date = null)
    {   
        // check date Y-m-d
        $matches = [];
        $pattern = '/^([0-9]{4})\-([0-9]{1,2})\-([0-9]{1,2})$/';
        if(!preg_match($pattern, $str_date, $matches)) return null;
        if(!checkdate($matches[2], $matches[3], $matches[1])) return null;
        return strtotime(date('Y-m-d', strtotime($str_date)));
    }

    public function stringDateTimeToInt($str_date = null)
    {
        // check datetime Y-m-d H:i:s
        $matches = [];
        $pattern = '/^([0-9]{4})\-([0-9]{1,2})\-([0-9]{1,2})\s([0-9]{1,2})\:([0-9]{1,2})\:([0-9]{1,2})$/';
        if(!preg_match($pattern, $str_date, $matches)) return null;
        if(!checkdate($matches[2], $matches[3], $matches[1])) return null;
        return strtotime(date('Y-m-d H:i:s', strtotime($str_date)));
    }

    public function formatUnicode($str = null)
    {
        if (empty($str)) {
            return '';
        }

        $unicode = [
            'a' => 'á|à|ả|ã|ạ|ă|ắ|ặ|ằ|ẳ|ẵ|â|ấ|ầ|ẩ|ẫ|ậ|Á|À|Ả|Ã|Ạ|Ă|Ắ|Ặ|Ằ|Ẳ|Ẵ|Â|Ấ|Ầ|Ẩ|Ẫ|Ậ',
            'd' => 'đ|Đ',
            'e' => 'é|è|ẻ|ẽ|ẹ|ê|ế|ề|ể|ễ|ệ|É|È|Ẻ|Ẽ|Ẹ|Ê|Ế|Ề|Ể|Ễ|Ệ',
            'i' => 'í|ì|ỉ|ĩ|ị|Í|Ì|Ỉ|Ĩ|Ị',
            'o' => 'ó|ò|ỏ|õ|ọ|ô|ố|ồ|ổ|ỗ|ộ|ơ|ớ|ờ|ở|ỡ|ợ|Ó|Ò|Ỏ|Õ|Ọ|Ô|Ố|Ồ|Ổ|Ỗ|Ộ|Ơ|Ớ|Ờ|Ở|Ỡ|Ợ',
            'u' => 'ú|ù|ủ|ũ|ụ|ư|ứ|ừ|ử|ữ|ự|Ú|Ù|Ủ|Ũ|Ụ|Ư|Ứ|Ừ|Ử|Ữ|Ự',
            'y' => 'ý|ỳ|ỷ|ỹ|ỵ|Ý|Ỳ|Ỷ|Ỹ|Ỵ'
        ];
        foreach ($unicode as $nonUnicode => $uni) {
            $str = preg_replace("/($uni)/i", $nonUnicode, trim($str));
        }
        return $str;
    }

    public function formatSearchUnicode($data = [])
    {
        $result = [];
        foreach ($data as $k => $item) {
            if(!empty($item)){
                $str = str_replace('-', ' ', $this->formatUnicode($item));
                $str = str_replace('_', ' ', $str);
                $str = str_replace('+', '', $str);
                $str = str_replace('(', '', $str);
                $str = str_replace(')', '', $str);
                $str = str_replace('.', '', $str);
                $str = str_replace(',', '', $str);
                $str = str_replace('*', '', $str);
                $result[] = $str;
            }            
        }

        return !empty($result) ?  implode(' | ', $result) : null;
    }

    public function formatToUrl($str = null)
    {
        if(empty($str)) return '';
        
        $str = $this->formatUnicode($str);        
        $str = preg_replace('`\[.*\]`U', '', $str);
        $str = preg_replace('`&(amp;)?#?[a-z0-9]+;`i', '-', $str);        
        $str = preg_replace('`&([a-z])(acute|uml|circ|grave|ring|cedil|slash|tilde|caron|lig|quot|rsquo);`i', '\\1', $str);
        $options = [
            'delimiter' => '-',
            'limit' => 255,
            'lowercase' => true,
            'replacements' => [],
            'transliterate' => false,
        ];
        
        $char_map = [
            // Latin
            'À' => 'A', 'Á' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A', 'Å' => 'A', 'Æ' => 'AE', 'Ç' => 'C', 
            'È' => 'E', 'É' => 'E', 'Ê' => 'E', 'Ë' => 'E', 'Ì' => 'I', 'Í' => 'I', 'Î' => 'I', 'Ï' => 'I', 
            'Ð' => 'D', 'Ñ' => 'N', 'Ò' => 'O', 'Ó' => 'O', 'Ô' => 'O', 'Õ' => 'O', 'Ö' => 'O', 'Ő' => 'O', 
            'Ø' => 'O', 'Ù' => 'U', 'Ú' => 'U', 'Û' => 'U', 'Ü' => 'U', 'Ű' => 'U', 'Ý' => 'Y', 'Þ' => 'TH', 
            'ß' => 'ss', 
            'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a', 'å' => 'a', 'æ' => 'ae', 'ç' => 'c', 
            'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e', 'ì' => 'i', 'í' => 'i', 'î' => 'i', 'ï' => 'i', 
            'ð' => 'd', 'ñ' => 'n', 'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o', 'ő' => 'o', 
            'ø' => 'o', 'ù' => 'u', 'ú' => 'u', 'û' => 'u', 'ü' => 'u', 'ű' => 'u', 'ý' => 'y', 'þ' => 'th', 
            'ÿ' => 'y',
            // Latin symbols
            '©' => '(c)',
            // Greek
            'Α' => 'A', 'Β' => 'B', 'Γ' => 'G', 'Δ' => 'D', 'Ε' => 'E', 'Ζ' => 'Z', 'Η' => 'H', 'Θ' => '8',
            'Ι' => 'I', 'Κ' => 'K', 'Λ' => 'L', 'Μ' => 'M', 'Ν' => 'N', 'Ξ' => '3', 'Ο' => 'O', 'Π' => 'P',
            'Ρ' => 'R', 'Σ' => 'S', 'Τ' => 'T', 'Υ' => 'Y', 'Φ' => 'F', 'Χ' => 'X', 'Ψ' => 'PS', 'Ω' => 'W',
            'Ά' => 'A', 'Έ' => 'E', 'Ί' => 'I', 'Ό' => 'O', 'Ύ' => 'Y', 'Ή' => 'H', 'Ώ' => 'W', 'Ϊ' => 'I',
            'Ϋ' => 'Y',
            'α' => 'a', 'β' => 'b', 'γ' => 'g', 'δ' => 'd', 'ε' => 'e', 'ζ' => 'z', 'η' => 'h', 'θ' => '8',
            'ι' => 'i', 'κ' => 'k', 'λ' => 'l', 'μ' => 'm', 'ν' => 'n', 'ξ' => '3', 'ο' => 'o', 'π' => 'p',
            'ρ' => 'r', 'σ' => 's', 'τ' => 't', 'υ' => 'y', 'φ' => 'f', 'χ' => 'x', 'ψ' => 'ps', 'ω' => 'w',
            'ά' => 'a', 'έ' => 'e', 'ί' => 'i', 'ό' => 'o', 'ύ' => 'y', 'ή' => 'h', 'ώ' => 'w', 'ς' => 's',
            'ϊ' => 'i', 'ΰ' => 'y', 'ϋ' => 'y', 'ΐ' => 'i',
            // Turkish
            'Ş' => 'S', 'İ' => 'I', 'Ç' => 'C', 'Ü' => 'U', 'Ö' => 'O', 'Ğ' => 'G',
            'ş' => 's', 'ı' => 'i', 'ç' => 'c', 'ü' => 'u', 'ö' => 'o', 'ğ' => 'g', 
            // Russian
            'А' => 'A', 'Б' => 'B', 'В' => 'V', 'Г' => 'G', 'Д' => 'D', 'Е' => 'E', 'Ё' => 'Yo', 'Ж' => 'Zh',
            'З' => 'Z', 'И' => 'I', 'Й' => 'J', 'К' => 'K', 'Л' => 'L', 'М' => 'M', 'Н' => 'N', 'О' => 'O',
            'П' => 'P', 'Р' => 'R', 'С' => 'S', 'Т' => 'T', 'У' => 'U', 'Ф' => 'F', 'Х' => 'H', 'Ц' => 'C',
            'Ч' => 'Ch', 'Ш' => 'Sh', 'Щ' => 'Sh', 'Ъ' => '', 'Ы' => 'Y', 'Ь' => '', 'Э' => 'E', 'Ю' => 'Yu',
            'Я' => 'Ya',
            'а' => 'a', 'б' => 'b', 'в' => 'v', 'г' => 'g', 'д' => 'd', 'е' => 'e', 'ё' => 'yo', 'ж' => 'zh',
            'з' => 'z', 'и' => 'i', 'й' => 'j', 'к' => 'k', 'л' => 'l', 'м' => 'm', 'н' => 'n', 'о' => 'o',
            'п' => 'p', 'р' => 'r', 'с' => 's', 'т' => 't', 'у' => 'u', 'ф' => 'f', 'х' => 'h', 'ц' => 'c',
            'ч' => 'ch', 'ш' => 'sh', 'щ' => 'sh', 'ъ' => '', 'ы' => 'y', 'ь' => '', 'э' => 'e', 'ю' => 'yu',
            'я' => 'ya',
            // Ukrainian
            'Є' => 'Ye', 'І' => 'I', 'Ї' => 'Yi', 'Ґ' => 'G',
            'є' => 'ye', 'і' => 'i', 'ї' => 'yi', 'ґ' => 'g',
            // Czech
            'Č' => 'C', 'Ď' => 'D', 'Ě' => 'E', 'Ň' => 'N', 'Ř' => 'R', 'Š' => 'S', 'Ť' => 'T', 'Ů' => 'U', 
            'Ž' => 'Z', 
            'č' => 'c', 'ď' => 'd', 'ě' => 'e', 'ň' => 'n', 'ř' => 'r', 'š' => 's', 'ť' => 't', 'ů' => 'u',
            'ž' => 'z', 
            // Polish
            'Ą' => 'A', 'Ć' => 'C', 'Ę' => 'e', 'Ł' => 'L', 'Ń' => 'N', 'Ó' => 'o', 'Ś' => 'S', 'Ź' => 'Z', 
            'Ż' => 'Z', 
            'ą' => 'a', 'ć' => 'c', 'ę' => 'e', 'ł' => 'l', 'ń' => 'n', 'ó' => 'o', 'ś' => 's', 'ź' => 'z',
            'ż' => 'z',
            // Latvian
            'Ā' => 'A', 'Č' => 'C', 'Ē' => 'E', 'Ģ' => 'G', 'Ī' => 'i', 'Ķ' => 'k', 'Ļ' => 'L', 'Ņ' => 'N', 
            'Š' => 'S', 'Ū' => 'u', 'Ž' => 'Z',
            'ā' => 'a', 'č' => 'c', 'ē' => 'e', 'ģ' => 'g', 'ī' => 'i', 'ķ' => 'k', 'ļ' => 'l', 'ņ' => 'n',
            'š' => 's', 'ū' => 'u', 'ž' => 'z'
        ];
        
        // make custom replacements
        $str = preg_replace(array_keys($options['replacements']), $options['replacements'], $str);

        // transliterate characters to ASCII
        if ($options['transliterate']) {
            $str = str_replace(array_keys($char_map), $char_map, $str);
        }
        
        // replace non-alphanumeric characters with our delimiter
        $str = preg_replace('/[^\p{L}\p{Nd}]+/u', $options['delimiter'], $str);
        
        // remove duplicate delimiters
        $str = preg_replace('/(' . preg_quote($options['delimiter'], '/') . '){2,}/', '$1', $str);
        
        // truncate slug to max. characters
        $str = mb_substr($str, 0, ($options['limit'] ? $options['limit'] : mb_strlen($str, 'UTF-8')), 'UTF-8');
        
        // remove delimiter from ends
        $str = trim($str, $options['delimiter']);
        
        return $options['lowercase'] ? mb_strtolower($str, 'UTF-8') : $str;
    }

    public function generateRandomString($length = 10)
    {
        return substr(str_shuffle(str_repeat($x = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length/strlen($x)) )), 1, $length);
    }

    public function generateRandomNumber($length = 10) {
        return substr(str_shuffle(str_repeat($x = '0123456789', ceil($length/strlen($x)) )), 1, $length);
    }

    public function formatPaginationInfo($pagination_info = [])
    {
        $result = [
            'field' => !empty($pagination_info['sort']) ? $pagination_info['sort'] : 'id',
            'sort' => !empty($pagination_info['direction']) ? $pagination_info['direction'] : DESC,
            'page' => !empty($pagination_info['page']) ? intval($pagination_info['page']) : 1,
            'pages' => !empty($pagination_info['pageCount']) ? intval($pagination_info['pageCount']) : 1,
            'perpage' => !empty($pagination_info['perPage']) ? intval($pagination_info['perPage']) : PAGINATION_LIMIT_ADMIN,
            'current' => !empty($pagination_info['current']) ? intval($pagination_info['current']) : 0,
            'total' => !empty($pagination_info['count']) ? intval($pagination_info['count']) : 0
        ];

        return $result;
    }

    public function formatToDecimal($number = 0, $decimal = 2)
    {
        if(empty($number)){
            return NUMBER_EMPTY;
        }

        return number_format((float)$number, $decimal, '.', '');
    }

    public function str_replace_first($find_string = null, $replace = null, $content = null)
    {
        $find_string = '/' . preg_quote($find_string, '/') . '/';

        return preg_replace($find_string, $replace, $content, 1);
    }
}
