<?php
namespace App\Controller\Component;

use Cake\Controller\Component;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Cake\Utility\Security;

/** Password reset codes are separate from registration and never activate an account. */
class PasswordResetOtpComponent extends Component
{
    public $components = ['System', 'Email'];
    private const TYPE = 'password_reset_otp';
    private const TTL = 600;
    private const RESEND_WAIT = 60;
    private const MAX_ATTEMPTS = 5;

    private function account($email)
    {
        return ConnectionManager::get('default')->execute(
            'SELECT c.id customer_id,c.email,a.id account_id FROM customers c
             INNER JOIN customers_account a ON a.customer_id=c.id
             WHERE c.deleted=0 AND c.status=1 AND a.deleted=0 AND a.status=1 AND c.email=? LIMIT 1',
            [$email]
        )->fetch('assoc');
    }

    private function codeHash($customerId, $code)
    {
        return hash_hmac('sha256', self::TYPE . ':' . $customerId . ':' . $code, Security::getSalt());
    }

    private function lock($customerId)
    {
        $key = 'meduc-password-reset-' . (int)$customerId;
        $row = ConnectionManager::get('default')->execute('SELECT GET_LOCK(?,5) acquired', [$key])->fetch('assoc');
        return !empty($row['acquired']) ? $key : null;
    }

    private function unlock($key)
    {
        ConnectionManager::get('default')->execute('SELECT RELEASE_LOCK(?)', [$key]);
    }

    private function sentResponse($email)
    {
        return $this->System->getResponse([
            CODE => SUCCESS,
            MESSAGE => 'Nếu email này thuộc tài khoản đang hoạt động, MedUC đã gửi mã OTP để đặt lại mật khẩu.',
            DATA => ['email' => $email, 'resend_after' => self::RESEND_WAIT, 'expires_in' => self::TTL]
        ]);
    }

    public function send($email)
    {
        $account = $this->account($email);
        // Do not disclose whether an email belongs to an active account.
        if (!$account) return $this->sentResponse($email);
        $customerId = (int)$account['customer_id'];
        $lock = $this->lock($customerId);
        if (!$lock) return $this->System->getResponse([MESSAGE => 'Đang xử lý yêu cầu. Vui lòng thử lại.']);
        $conn = ConnectionManager::get('default');
        try {
            $account = $this->account($email);
            if (!$account) return $this->sentResponse($email);
            $last = $conn->execute('SELECT sent_at FROM email_token WHERE customer_id=? AND type=? ORDER BY id DESC LIMIT 1',
                [$customerId, self::TYPE])->fetch('assoc');
            $wait = $last ? max(0, (int)$last['sent_at'] + self::RESEND_WAIT - time()) : 0;
            if ($wait) return $this->System->getResponse([
                MESSAGE => 'Vui lòng chờ ' . $wait . ' giây trước khi gửi lại mã.',
                DATA => ['resend_after' => $wait]
            ]);

            $code = (string)random_int(100000, 999999);
            $table = TableRegistry::get('EmailToken');
            $row = $table->newEntity([
                'customer_id' => $customerId, 'email' => $email, 'type' => self::TYPE,
                'code' => $this->codeHash($customerId, $code), 'end_time' => time() + self::TTL,
                'attempts' => 0, 'sent_at' => time(), 'status' => 2
            ]);
            if (!$table->save($row)) throw new \RuntimeException('Cannot store reset OTP');
            $content = '<!doctype html><html lang="vi"><body style="margin:0;background:#f5f5f7;font-family:Arial,sans-serif;color:#202228">' .
                '<div style="max-width:520px;margin:32px auto;padding:32px;background:#fff;border-radius:12px">' .
                '<p style="font-size:20px;font-weight:bold">MedUC</p><h1 style="font-size:24px">Đặt lại mật khẩu</h1>' .
                '<p>Nhập mã dưới đây trong cửa sổ khôi phục tài khoản MedUC, sau đó chọn mật khẩu mới.</p>' .
                '<p style="font-size:36px;font-weight:bold;letter-spacing:8px;color:#df203c">' . $code . '</p>' .
                '<p>Mã có hiệu lực trong <strong>10 phút</strong> và chỉ dùng một lần. Khi gửi lại, hãy dùng mã trong email mới nhất.</p>' .
                '<p>Không chia sẻ mã này với bất kỳ ai. Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này; mật khẩu của bạn vẫn giữ nguyên.</p></div></body></html>';
            $sent = $this->Email->sendEmail([
                'to_email' => $email, 'send_try_content' => true,
                'subject' => 'MedUC — Mã OTP đặt lại mật khẩu', 'content' => $content,
                'from_website_template' => true, 'delivery_timeout' => 10
            ]);
            if (empty($sent[CODE]) || $sent[CODE] !== SUCCESS) return $this->System->getResponse([
                MESSAGE => 'Chưa gửi được email khôi phục. Vui lòng thử lại sau 60 giây.',
                DATA => ['resend_after' => self::RESEND_WAIT]
            ]);
            $conn->execute('UPDATE email_token SET status=1 WHERE customer_id=? AND type IN (?,?) AND status=0',
                [$customerId, self::TYPE, 'forgot_password']);
            $conn->execute('UPDATE email_token SET status=0 WHERE id=? AND status=2', [$row->id]);
            return $this->sentResponse($email);
        } catch (\Throwable $e) {
            $this->log('Password reset OTP delivery failed.', 'error');
            return $this->System->getResponse([MESSAGE => 'Không thể gửi email lúc này. Vui lòng thử lại.']);
        } finally {
            $this->unlock($lock);
        }
    }

    public function reset($email, $code, $password)
    {
        $invalid = 'Mã OTP không đúng, đã hết hạn hoặc không còn hiệu lực. Vui lòng kiểm tra email mới nhất.';
        $account = $this->account($email);
        if (!$account) return $this->System->getResponse([MESSAGE => $invalid]);
        $customerId = (int)$account['customer_id'];
        $lock = $this->lock($customerId);
        if (!$lock) return $this->System->getResponse([MESSAGE => 'Đang xử lý yêu cầu. Vui lòng thử lại.']);
        $conn = ConnectionManager::get('default');
        try {
            $account = $this->account($email);
            if (!$account) return $this->System->getResponse([MESSAGE => $invalid]);
            $row = $conn->execute('SELECT * FROM email_token WHERE customer_id=? AND type=? ORDER BY id DESC LIMIT 1',
                [$customerId, self::TYPE])->fetch('assoc');
            if (!$row || (int)$row['status'] !== 0 || (int)$row['end_time'] < time()) {
                return $this->System->getResponse([MESSAGE => $invalid]);
            }
            if ((int)$row['attempts'] >= self::MAX_ATTEMPTS) return $this->System->getResponse([
                MESSAGE => 'Đã nhập sai 5 lần. Vui lòng gửi lại mã OTP.'
            ]);
            if (!preg_match('/^\d{6}$/D', $code) || !hash_equals($row['code'], $this->codeHash($customerId, $code))) {
                $conn->execute('UPDATE email_token SET attempts=attempts+1 WHERE id=? AND status=0', [$row['id']]);
                $remaining = self::MAX_ATTEMPTS - (int)$row['attempts'] - 1;
                return $this->System->getResponse([MESSAGE => $remaining
                    ? 'Mã OTP không đúng. Bạn còn ' . $remaining . ' lần thử.'
                    : 'Đã nhập sai 5 lần. Vui lòng gửi lại mã OTP.']);
            }
            // Serialize and consume before changing the password: legacy tables use MyISAM.
            $used = $conn->execute('UPDATE email_token SET status=1 WHERE id=? AND status=0 AND attempts<? AND end_time>=?',
                [$row['id'], self::MAX_ATTEMPTS, time()]);
            if ($used->rowCount() !== 1) throw new \RuntimeException('OTP already consumed');
            // Keep compatibility with the existing member login password format.
            $changed = $conn->execute('UPDATE customers_account SET password=? WHERE id=? AND customer_id=? AND status=1 AND deleted=0',
                [Security::hash($password, 'md5', false), $account['account_id'], $customerId]);
            $saved = $conn->execute('SELECT id FROM customers_account WHERE id=? AND customer_id=? AND status=1 AND deleted=0 AND password=?',
                [$account['account_id'], $customerId, Security::hash($password, 'md5', false)])->fetch('assoc');
            if (!$saved) throw new \RuntimeException('Cannot update account password');
            $conn->execute('UPDATE email_token SET status=1 WHERE customer_id=? AND type IN (?,?) AND status=0',
                [$customerId, self::TYPE, 'forgot_password']);
            return $this->System->getResponse([
                CODE => SUCCESS, MESSAGE => 'Đã đổi mật khẩu. Bạn có thể đăng nhập bằng mật khẩu mới.',
                DATA => ['email' => $email]
            ]);
        } catch (\Throwable $e) {
            $this->log('Password reset OTP verification failed.', 'error');
            return $this->System->getResponse([MESSAGE => 'Chưa đổi được mật khẩu. Vui lòng yêu cầu mã OTP mới và thử lại.']);
        } finally {
            $this->unlock($lock);
        }
    }
}
