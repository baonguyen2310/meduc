<?php
namespace App\Service;

use Cake\Core\Configure;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Psr\Http\Message\UploadedFileInterface;

/** Application records and private files; notification delivery never rolls back a saved application. */
class FacultyApplications
{
    public const MAX_FILES = 5;
    public const MAX_FILE_SIZE = 10 * 1024 * 1024;
    public const STATUSES = [
        'new' => 'Mới', 'reviewing' => 'Đang xem', 'contacted' => 'Đã liên hệ',
        'accepted' => 'Phù hợp', 'rejected' => 'Chưa phù hợp',
    ];
    public const QUALIFICATIONS = ['Thạc sĩ', 'Bác sĩ nội trú', 'Chuyên khoa I', 'Chuyên khoa II', 'Tiến sĩ', 'Khác'];

    public static function directory(): string
    {
        return ROOT . DS . 'private' . DS . 'faculty-applications';
    }

    public static function find(int $id): ?array
    {
        $row = ConnectionManager::get('default')->execute('SELECT * FROM faculty_applications WHERE id=:id', ['id' => $id])->fetch('assoc');
        if (!$row) return null;
        $row['files'] = json_decode($row['attachment_files'], true) ?: [];
        return $row;
    }

    public static function validate(array $input): array
    {
        $data = [];
        foreach (['full_name'=>160, 'email'=>254, 'phone'=>30, 'specialty'=>200, 'qualification'=>100,
            'workplace'=>255, 'portfolio_url'=>500, 'introduction'=>5000] as $key => $max) {
            if (isset($input[$key]) && !is_scalar($input[$key])) throw new \InvalidArgumentException('Thông tin hồ sơ không hợp lệ.');
            $value = trim((string)($input[$key] ?? ''));
            if (mb_strlen($value) > $max || strpos($value, "\0") !== false) throw new \InvalidArgumentException('Thông tin nhập quá dài hoặc không hợp lệ.');
            $data[$key] = $value;
        }
        if (mb_strlen($data['full_name']) < 2 || !$data['specialty'] || mb_strlen($data['introduction']) < 20) {
            throw new \InvalidArgumentException('Vui lòng điền họ tên, chuyên môn và giới thiệu kinh nghiệm ít nhất 20 ký tự.');
        }
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) throw new \InvalidArgumentException('Địa chỉ email chưa hợp lệ.');
        if (!preg_match('/^[0-9+().\s-]{7,30}$/', $data['phone']) || !preg_match('/^[0-9]{7,16}$/', preg_replace('/\D/', '', $data['phone']))) {
            throw new \InvalidArgumentException('Vui lòng nhập số điện thoại hợp lệ.');
        }
        if (!in_array($data['qualification'], self::QUALIFICATIONS, true)) throw new \InvalidArgumentException('Vui lòng chọn trình độ chuyên môn.');
        if ($data['portfolio_url'] && (!filter_var($data['portfolio_url'], FILTER_VALIDATE_URL) ||
            !in_array(strtolower((string)parse_url($data['portfolio_url'], PHP_URL_SCHEME)), ['http', 'https'], true))) {
            throw new \InvalidArgumentException('Liên kết hồ sơ phải bắt đầu bằng https:// hoặc http://.');
        }
        $years = $input['experience_years'] ?? '';
        if ($years !== '' && $years !== null && (filter_var($years, FILTER_VALIDATE_INT) === false || (int)$years < 0 || (int)$years > 60)) {
            throw new \InvalidArgumentException('Số năm kinh nghiệm phải từ 0 đến 60.');
        }
        $data['experience_years'] = ($years === '' || $years === null) ? null : (int)$years;
        return $data;
    }

    public static function validateFiles(array $uploads): array
    {
        $uploads = array_values(array_filter($uploads, static function ($file) {
            return !($file instanceof UploadedFileInterface) || $file->getError() !== UPLOAD_ERR_NO_FILE;
        }));
        if (count($uploads) > self::MAX_FILES) throw new \InvalidArgumentException('Chỉ được đính kèm tối đa 5 file.');
        $allowed = [
            'pdf' => ['application/pdf'], 'jpg' => ['image/jpeg'], 'jpeg' => ['image/jpeg'],
            'png' => ['image/png'], 'webp' => ['image/webp'],
            'doc' => ['application/msword', 'application/CDFV2', 'application/x-ole-storage'],
            'docx' => ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/zip'],
        ];
        $validated = [];
        foreach ($uploads as $file) {
            if (!$file instanceof UploadedFileInterface || $file->getError() !== UPLOAD_ERR_OK || !$file->getSize() || $file->getSize() > self::MAX_FILE_SIZE) {
                throw new \InvalidArgumentException('Không tải được file. Mỗi file tối đa 10 MB.');
            }
            $original = basename(str_replace('\\', '/', (string)$file->getClientFilename()));
            $original = mb_substr(preg_replace('/[\x00-\x1f\x7f]/u', '', $original), 0, 180);
            $extension = strtolower(pathinfo($original, PATHINFO_EXTENSION));
            $path = $file->getStream()->getMetadata('uri');
            $mime = is_string($path) && is_file($path) ? (new \finfo(FILEINFO_MIME_TYPE))->file($path) : '';
            if (!isset($allowed[$extension]) || !in_array($mime, $allowed[$extension], true)) {
                throw new \InvalidArgumentException('Chỉ nhận file PDF, DOC, DOCX, JPG, PNG hoặc WebP đúng định dạng.');
            }
            if (in_array($extension, ['jpg', 'jpeg', 'png', 'webp'], true) && !@getimagesize($path)) {
                throw new \InvalidArgumentException('File ảnh không hợp lệ.');
            }
            if ($extension === 'docx') {
                $zip = new \ZipArchive();
                if ($zip->open($path) !== true) throw new \InvalidArgumentException('File Word không hợp lệ.');
                $valid = $zip->locateName('[Content_Types].xml') !== false && $zip->locateName('word/document.xml') !== false;
                $zip->close();
                if (!$valid) throw new \InvalidArgumentException('File Word không hợp lệ.');
                $mime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            $validated[] = ['upload' => $file, 'original_name' => $original, 'mime' => $mime,
                'size' => (int)$file->getSize(), 'extension' => $extension === 'jpeg' ? 'jpg' : $extension];
        }
        return $validated;
    }

    public static function save(array $data, array $files, string $key, string $ipHash): int
    {
        $db = ConnectionManager::get('default');
        $existing = $db->execute('SELECT id FROM faculty_applications WHERE submission_key=:key', ['key' => $key])->fetchColumn(0);
        if ($existing) return (int)$existing;
        $recent = $db->execute('SELECT COUNT(*) FROM faculty_applications WHERE ip_hash=:ip AND created>=:since', ['ip' => $ipHash, 'since' => time()-3600])->fetchColumn(0);
        if ((int)$recent >= 10) throw new \OverflowException('Bạn đã gửi nhiều hồ sơ trong giờ qua. Vui lòng thử lại sau.');
        $saved = [];
        try {
            $dir = self::directory();
            if ($files && !is_dir($dir) && !mkdir($dir, 0700, true) && !is_dir($dir)) throw new \RuntimeException('Private upload directory unavailable');
            foreach ($files as $file) {
                $name = bin2hex(random_bytes(20)) . '.' . $file['extension'];
                $file['upload']->moveTo($dir . DS . $name);
                $saved[] = ['stored_name' => $name, 'original_name' => $file['original_name'], 'mime' => $file['mime'], 'size' => $file['size']];
                chmod($dir . DS . $name, 0600);
            }
            $params = $data + ['submission_key' => $key, 'ip_hash' => $ipHash,
                'attachment_files' => json_encode($saved, JSON_UNESCAPED_UNICODE), 'created' => time(), 'updated' => time()];
            $columns = array_keys($params);
            $db->execute('INSERT INTO faculty_applications (`'.implode('`,`', $columns).'`) VALUES (:'.implode(',:', $columns).')', $params);
            return (int)$db->getDriver()->lastInsertId();
        } catch (\Throwable $error) {
            foreach ($saved as $file) @unlink(self::directory() . DS . $file['stored_name']);
            // A retried request may race the first one. The unique key keeps one application.
            $existing = $db->execute('SELECT id FROM faculty_applications WHERE submission_key=:key', ['key' => $key])->fetchColumn(0);
            if ($existing) return (int)$existing;
            throw $error;
        }
    }

    public static function notify(int $id, callable $send): bool
    {
        $db = ConnectionManager::get('default');
        $claim = $db->execute("UPDATE faculty_applications SET notification_status='sending', notification_attempts=notification_attempts+1,
            notification_attempted_at=:now WHERE id=:id AND (notification_status IN ('pending','failed') OR
            (notification_status='sending' AND notification_attempted_at<:stale))", ['now' => time(), 'id' => $id, 'stale' => time()-120]);
        if (!$claim->rowCount()) return (self::find($id)['notification_status'] ?? '') === 'sent';
        $sent = false;
        try {
            $row = self::find($id);
            $settings = TableRegistry::get('Settings')->getSettingWebsite();
            $recipients = array_values(array_unique(array_filter(preg_split('/[,;\s]+/', trim((string)($settings['email']['email_administrator'] ?? ''))), static function ($email) {
                return (bool)filter_var($email, FILTER_VALIDATE_EMAIL);
            })));
            $escape = static function ($value) { return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); };
            $url = rtrim((string)Configure::read('App.fullBaseUrl'), '/') . '/admin/faculty-applications/detail/' . $id;
            $content = '<h2>Hồ sơ ứng tuyển giảng viên mới #'.$id.'</h2><p><b>'.$escape($row['full_name']).'</b></p>';
            foreach (['email'=>'Email', 'phone'=>'Điện thoại', 'specialty'=>'Chuyên môn', 'qualification'=>'Trình độ', 'workplace'=>'Nơi công tác'] as $field => $label) {
                $content .= '<p>'.$label.': '.$escape($row[$field]).'</p>';
            }
            $content .= '<p>'.count($row['files']).' file đính kèm. File được xem và tải trong trang quản trị.</p><p><a href="'.$escape($url).'">Xem hồ sơ ứng tuyển</a></p>';
            if ($recipients) {
                $result = $send(['to_email'=>$recipients, 'send_try_content'=>true, 'subject'=>'MedUC: hồ sơ ứng tuyển giảng viên #'.$id,
                    'content'=>$content, 'delivery_timeout'=>10]);
                $sent = ($result[CODE] ?? null) === SUCCESS;
            }
        } catch (\Throwable $error) {
            \Cake\Log\Log::error('Faculty application notification failed for #'.$id);
        }
        $db->execute('UPDATE faculty_applications SET notification_status=:status, notified_at=:sent WHERE id=:id', [
            'status'=>$sent ? 'sent' : 'failed', 'sent'=>$sent ? time() : null, 'id'=>$id,
        ]);
        return $sent;
    }
}
