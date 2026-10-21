<?php
namespace App\Controller\Component;

use Cake\Controller\Component;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Cake\Utility\Security;

/** Registration-only OTPs. Password reset and profile-change tokens retain their own flows. */
class RegistrationOtpComponent extends Component
{
    public $components = ['System', 'Email'];
    private const TYPE = 'registration_otp';
    private const TTL = 600;
    private const RESEND_WAIT = 60;
    private const MAX_ATTEMPTS = 5;

    private function pendingAccount($email = null, $customerId = null)
    {
        $field = $customerId ? 'c.id' : 'c.email';
        return ConnectionManager::get('default')->execute(
            'SELECT c.id customer_id,c.email,a.id account_id FROM customers c
             INNER JOIN customers_account a ON a.customer_id=c.id
             WHERE c.deleted=0 AND c.status=1 AND a.deleted=0 AND a.status=2 AND ' . $field . '=? LIMIT 1',
            [$customerId ?: $email]
        )->fetch('assoc');
    }

    private function codeHash($customerId, $code)
    {
        return hash_hmac('sha256', $customerId . ':' . $code, Security::getSalt());
    }

    // Advisory locks serialize send/verify even though the legacy account tables use MyISAM.
    private function lock($customerId)
    {
        $key = 'meduc-registration-otp-' . (int)$customerId;
        $row = ConnectionManager::get('default')->execute('SELECT GET_LOCK(?,5) acquired', [$key])->fetch('assoc');
        return !empty($row['acquired']) ? $key : null;
    }

    private function unlock($key)
    {
        ConnectionManager::get('default')->execute('SELECT RELEASE_LOCK(?)', [$key]);
    }

    public function send($customerId)
    {
        $account = $this->pendingAccount(null, (int)$customerId);
        if (!$account) return $this->System->getResponse([MESSAGE => 'Không thể gửi mã cho tài khoản này.']);
        $lock = $this->lock($customerId);
        if (!$lock) return $this->System->getResponse([MESSAGE => 'Đang xử lý yêu cầu. Vui lòng thử lại.']);
        $conn = ConnectionManager::get('default');
        try {
            // Recheck after taking the lock: verification may have completed in another request.
            $account = $this->pendingAccount(null, (int)$customerId);
            if (!$account) return $this->System->getResponse([MESSAGE => 'Tài khoản này đã được xác thực hoặc không thể kích hoạt.']);
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
                'customer_id' => $customerId, 'email' => $account['email'], 'type' => self::TYPE,
                'code' => $this->codeHash($customerId, $code), 'end_time' => time() + self::TTL,
                'attempts' => 0, 'sent_at' => time(), 'status' => 2 // Not usable until SMTP accepts it.
            ]);
            if (!$table->save($row)) throw new \RuntimeException('Cannot store registration OTP');

            $content = '<!doctype html><html lang="vi"><body style="margin:0;background:#f5f5f7;font-family:Arial,sans-serif;color:#202228">' .
                '<div style="max-width:520px;margin:32px auto;padding:32px;background:#fff;border-radius:12px">' .
                '<p style="font-size:20px;font-weight:bold">MedUC Master</p><h1 style="font-size:24px">Xác thực email đăng ký</h1>' .
                '<p>Nhập mã dưới đây trong cửa sổ đăng ký MedUC để hoàn tất và bắt đầu học.</p>' .
                '<p style="font-size:36px;font-weight:bold;letter-spacing:8px;color:#df203c">' . $code . '</p>' .
                '<p>Mã có hiệu lực trong <strong>10 phút</strong> và chỉ dùng một lần. Khi yêu cầu gửi lại, hãy dùng mã trong email mới nhất.</p>' .
                '<p>Không chia sẻ mã này với bất kỳ ai. Nếu bạn không đăng ký tài khoản MedUC, hãy bỏ qua email này.</p></div></body></html>';
            // Synchronous delivery reports an SMTP failure instead of claiming a background job succeeded.
            $sent = $this->Email->sendEmail([
                'to_email' => $account['email'], 'send_try_content' => true,
                'subject' => 'MedUC — Mã OTP xác thực đăng ký', 'content' => $content,
                'from_website_template' => true, 'delivery_timeout' => 10
            ]);
            if (empty($sent[CODE]) || $sent[CODE] !== SUCCESS) {
                return $this->System->getResponse([
                    MESSAGE => 'Chưa gửi được email xác thực. Vui lòng thử Gửi lại mã sau 60 giây.',
                    DATA => ['resend_after' => self::RESEND_WAIT]
                ]);
            }
            $conn->execute('UPDATE email_token SET status=1 WHERE customer_id=? AND type=? AND status=0',
                [$customerId, self::TYPE]);
            $conn->execute('UPDATE email_token SET status=0 WHERE id=? AND status=2', [$row->id]);
            return $this->System->getResponse([
                CODE => SUCCESS, MESSAGE => 'Đã gửi mã OTP đến email của bạn.',
                DATA => ['resend_after' => self::RESEND_WAIT, 'expires_in' => self::TTL]
            ]);
        } catch (\Throwable $e) {
            $this->log('Registration OTP delivery failed.', 'error');
            return $this->System->getResponse([MESSAGE => 'Không thể gửi mã xác thực lúc này. Vui lòng thử lại.']);
        } finally {
            $this->unlock($lock);
        }
    }

    public function resend($email)
    {
        $account = $this->pendingAccount($email);
        if (!$account) return $this->System->getResponse([MESSAGE => 'Không thể gửi mã cho tài khoản này.']);
        return $this->send((int)$account['customer_id']);
    }

    public function verify($email, $code)
    {
        $account = $this->pendingAccount($email);
        if (!$account) return $this->System->getResponse([MESSAGE => 'Tài khoản đã được xác thực hoặc không thể kích hoạt. Vui lòng đăng nhập.']);
        $customerId = (int)$account['customer_id'];
        $lock = $this->lock($customerId);
        if (!$lock) return $this->System->getResponse([MESSAGE => 'Đang xử lý yêu cầu. Vui lòng thử lại.']);
        $conn = ConnectionManager::get('default');
        try {
            $account = $this->pendingAccount($email);
            if (!$account) return $this->System->getResponse([MESSAGE => 'Tài khoản đã được xác thực. Vui lòng đăng nhập.']);
            $row = $conn->execute('SELECT * FROM email_token WHERE customer_id=? AND type=? ORDER BY id DESC LIMIT 1',
                [$customerId, self::TYPE])->fetch('assoc');
            if (!$row || (int)$row['status'] !== 0 || (int)$row['end_time'] < time()) {
                return $this->System->getResponse([MESSAGE => 'Mã OTP đã hết hạn hoặc không còn hiệu lực. Vui lòng gửi lại mã.']);
            }
            if ((int)$row['attempts'] >= self::MAX_ATTEMPTS) {
                return $this->System->getResponse([MESSAGE => 'Đã nhập sai 5 lần. Vui lòng gửi lại mã OTP.']);
            }
            if (!preg_match('/^\d{6}$/D', $code) || !hash_equals($row['code'], $this->codeHash($customerId, $code))) {
                $conn->execute('UPDATE email_token SET attempts=attempts+1 WHERE id=? AND status=0', [$row['id']]);
                $remaining = self::MAX_ATTEMPTS - (int)$row['attempts'] - 1;
                return $this->System->getResponse([MESSAGE => $remaining
                    ? 'Mã OTP không đúng. Bạn còn ' . $remaining . ' lần thử.'
                    : 'Đã nhập sai 5 lần. Vui lòng gửi lại mã OTP.']);
            }
            $used = $conn->execute('UPDATE email_token SET status=1 WHERE id=? AND status=0 AND attempts<? AND end_time>=?',
                [$row['id'], self::MAX_ATTEMPTS, time()]);
            if ($used->rowCount() !== 1) throw new \RuntimeException('OTP already consumed');
            $activated = $conn->execute('UPDATE customers_account SET status=1 WHERE id=? AND customer_id=? AND status=2 AND deleted=0',
                [$account['account_id'], $customerId]);
            if ($activated->rowCount() !== 1) throw new \RuntimeException('Cannot activate account');
            // Invalidate any legacy activation codes for this email too.
            $conn->execute('UPDATE email_token SET status=1 WHERE email=? AND type=? AND status=0', [$email, 'active_account']);
            $table = TableRegistry::get('Customers');
            $profile = $table->formatDataCustomerDetail($table->getDetailCustomer($customerId, [
                'get_account' => true, 'get_default_address' => true
            ]));
            if (empty($profile['customer_id'])) throw new \RuntimeException('Cannot load account');
            $session = $this->_registry->getController()->getRequest()->getSession();
            $session->renew();
            $session->write(MEMBER, $profile);
            return $this->System->getResponse([
                CODE => SUCCESS, MESSAGE => 'Xác thực thành công. Bạn đã đăng nhập MedUC.',
                DATA => $profile
            ]);
        } catch (\Throwable $e) {
            $this->log('Registration OTP verification failed.', 'error');
            return $this->System->getResponse([MESSAGE => 'Không thể hoàn tất xác thực. Vui lòng thử lại hoặc đăng nhập.']);
        } finally {
            $this->unlock($lock);
        }
    }
}
