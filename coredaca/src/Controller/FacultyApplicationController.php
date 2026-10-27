<?php
namespace App\Controller;

use App\Service\FacultyApplications;
use Cake\Core\Configure;
use Psr\Http\Message\UploadedFileInterface;

class FacultyApplicationController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
    }

    public function submit()
    {
        $this->autoRender = false;
        if (!$this->request->is('post')) return $this->json(405, 'Phương thức không hợp lệ.');
        if ((int)$this->request->getHeaderLine('Content-Length') > 55*1024*1024) return $this->json(413, 'Tổng dung lượng hồ sơ quá lớn. Mỗi file tối đa 10 MB, tối đa 5 file.');
        try {
            $input = $this->request->getData();
            if (!empty($input['company_website'])) return $this->json(422, 'Không gửi được hồ sơ. Vui lòng thử lại.');
            $token = $input['submission_token'] ?? '';
            if (!is_string($token) || !preg_match('/^[a-f0-9]{32}$/', $token)) return $this->json(422, 'Vui lòng tải lại trang và gửi hồ sơ.');
            $data = FacultyApplications::validate($input);
            $uploads = $input['attachments'] ?? [];
            if ($uploads instanceof UploadedFileInterface) $uploads = [$uploads];
            if (!is_array($uploads)) return $this->json(422, 'File đính kèm không hợp lệ.');
            $files = FacultyApplications::validateFiles($uploads);
            $session = $this->request->getSession();
            $secret = $session->read('FacultyApplication.secret');
            if (!$secret) { $secret = bin2hex(random_bytes(32)); $session->write('FacultyApplication.secret', $secret); }
            $key = hash_hmac('sha256', $token, $secret);
            $clientIp = (string)$this->request->clientIp();
            // Caddy forwards the real client as the last hop; the PHP port is bound to loopback.
            if (!filter_var($clientIp, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
                $forwarded = explode(',', $this->request->getHeaderLine('X-Forwarded-For'));
                $lastHop = trim((string)end($forwarded));
                if (filter_var($lastHop, FILTER_VALIDATE_IP)) $clientIp = $lastHop;
            }
            $ipHash = hash_hmac('sha256', $clientIp, (string)Configure::read('Security.salt'));
            $id = FacultyApplications::save($data, $files, $key, $ipHash);
        } catch (\InvalidArgumentException $error) {
            return $this->json(422, $error->getMessage());
        } catch (\OverflowException $error) {
            return $this->json(429, $error->getMessage());
        } catch (\Throwable $error) {
            $this->log('Could not save faculty application: '.$error->getMessage(), 'error');
            return $this->json(500, 'Chưa gửi được hồ sơ. Vui lòng giữ thông tin và thử lại.');
        }
        FacultyApplications::notify($id, function ($params) { return $this->loadComponent('Email')->sendEmail($params); });
        return $this->json(200, 'MedUC đã nhận hồ sơ ứng tuyển của bạn. Đội ngũ sẽ xem xét và liên hệ qua email hoặc số điện thoại đã cung cấp.', ['id'=>$id]);
    }

    private function json(int $status, string $message, array $data = [])
    {
        return $this->response->withStatus($status)->withType('application/json')->withHeader('Cache-Control', 'private, no-store')
            ->withStringBody(json_encode(['code'=>$status === 200 ? 'success' : 'error', 'message'=>$message, 'data'=>$data], JSON_UNESCAPED_UNICODE));
    }
}
