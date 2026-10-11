<?php
namespace App\Model\Table;

use Cake\ORM\Query;
use Cake\ORM\Table;
use Cake\ORM\TableRegistry;
use Cake\I18n\Date;
use Cake\I18n\Time;

class UtilitiesTable extends Table
{
    public function initialize(array $config): void
    {
        parent::initialize($config);
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

    public function convertIntgerToDateString($int = null)
    {
        if(empty($int)) return null;

        try{
            $result = date('d/m/Y', intval($int));
        }catch (Exception $e) {
            return null;
        }

        return $result;
    }

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
                $str = str_replace('-', '', $this->formatUnicode($item));
                $str = str_replace('+', '', $str);
                $str = str_replace('(', '', $str);
                $str = str_replace(')', '', $str);
                $str = str_replace('.', '', $str);
                $str = str_replace(',', '', $str);
                $str = str_replace('*', '', $str);
                $str = str_replace('_', '', $str);
                $result[] = $str;
            }            
        }

        return !empty($result) ?  implode(' | ', $result) : null;
    }

}