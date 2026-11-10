<?php
declare(strict_types=1);

namespace App\Controller\Component;

use App\Lib\AccountProfile;
use App\Lib\GoogleIdentity;
use Cake\Controller\Component;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;

class GoogleSignInComponent extends Component
{
    public $components = ['System', 'Admin.Customer'];
    private const NONCE = 'Meduc.GoogleNonce';
    private const PENDING = 'Meduc.GoogleProfile';
    private const TTL = 600;

    private function session()
    {
        return $this->_registry->getController()->getRequest()->getSession();
    }

    private function clientId(): string
    {
        $settings = TableRegistry::get('Settings')->getSettingWebsite();
        return trim((string)($settings['social']['google_client_id'] ?? ''));
    }

    public function options(): array
    {
        $clientId = $this->clientId();
        if ($clientId === '') return $this->System->getResponse([MESSAGE => 'Đăng nhập Google chưa được cấu hình.']);
        $nonce = bin2hex(random_bytes(24));
        $this->session()->write(self::NONCE, ['value' => $nonce, 'expires' => time() + self::TTL]);
        return $this->System->getResponse([CODE => SUCCESS, DATA => ['client_id' => $clientId, 'nonce' => $nonce]]);
    }

    protected function identityVerifier(): GoogleIdentity
    {
        return new GoogleIdentity();
    }

    public function login(array $data): array
    {
        $nonce = $this->session()->read(self::NONCE);
        if (!is_array($nonce) || ($nonce['expires'] ?? 0) < time() ||
            !is_string($data['credential'] ?? null) || $data['credential'] === '') {
            return $this->System->getResponse([MESSAGE => 'Phiên Google đã hết hạn. Vui lòng bấm đăng nhập Google lại.']);
        }
        try {
            $identity = $this->identityVerifier()->verify($data['credential'], $this->clientId(), $nonce['value']);
            $this->session()->delete(self::NONCE);
            $account = $this->findAccount($identity);
            $this->checkState($account);
            $profile = $account ?: ['full_name' => '', 'phone' => '', 'school_name' => '', 'student_year' => ''];
            if (AccountProfile::missing($profile)) {
                $token = bin2hex(random_bytes(24));
                $this->session()->delete(MEMBER);
                $this->session()->write(self::PENDING, [
                    'identity' => $identity, 'expires' => time() + self::TTL, 'token' => $token
                ]);
                return $this->System->getResponse([
                    CODE => SUCCESS, MESSAGE => 'Vui lòng bổ sung thông tin để tiếp tục học cùng MedUC.',
                    DATA => [
                        'profile_required' => true, 'profile_token' => $token,
                        'profile' => [
                            'email' => $identity['email'],
                            'full_name' => $profile['full_name'] ?: $identity['full_name'],
                            'phone' => $profile['phone'] ?? '', 'school_name' => $profile['school_name'] ?? '',
                            'student_year' => $profile['student_year'] ?? ''
                        ]
                    ]
                ]);
            }
            return $this->persist($identity, null);
        } catch (\Throwable $e) {
            $this->log('Google sign-in verification or account lookup failed.', 'error');
            return $this->System->getResponse([MESSAGE => $e instanceof \DomainException
                ? $e->getMessage() : 'Không xác thực được Google. Vui lòng thử lại.']);
        }
    }

    public function completeProfile(array $data): array
    {
        $pending = $this->session()->read(self::PENDING);
        if (!is_array($pending) || ($pending['expires'] ?? 0) < time() ||
            !is_string($data['profile_token'] ?? null) ||
            !hash_equals($pending['token'], $data['profile_token'])) {
            return $this->System->getResponse([MESSAGE => 'Phiên bổ sung thông tin đã hết hạn. Vui lòng đăng nhập Google lại.']);
        }
        try {
            $profile = AccountProfile::validate($data);
            return $this->persist($pending['identity'], $profile);
        } catch (\Throwable $e) {
            return $this->System->getResponse([MESSAGE => $e instanceof \InvalidArgumentException || $e instanceof \DomainException
                ? $e->getMessage() : 'Không lưu được thông tin. Vui lòng thử lại.']);
        }
    }

    private function findAccount(array $identity)
    {
        $select = 'SELECT a.id account_id,a.customer_id,a.status account_status,c.status customer_status,
            c.full_name,c.email,c.phone,c.school_name,c.student_year,c.email_verified
            FROM customers_account a INNER JOIN customers c ON c.id=a.customer_id
            WHERE a.deleted=0 AND c.deleted=0 AND ';
        $db = ConnectionManager::get('default');
        $account = $db->execute($select . 'a.google_id=? ORDER BY a.id LIMIT 1', [$identity['google_id']])->fetch('assoc');
        // Preserve the existing same-email association policy, using only Google's verified claims.
        if (!$account) $account = $db->execute($select . 'c.email=? ORDER BY a.id LIMIT 1', [$identity['email']])->fetch('assoc');
        return $account ?: null;
    }

    private function checkState($account): void
    {
        if ($account && ((int)$account['customer_status'] !== 1 || !in_array((int)$account['account_status'], [1, 2], true))) {
            throw new \DomainException('Tài khoản MedUC này đang bị khóa. Vui lòng liên hệ hỗ trợ.');
        }
    }

    private function persist(array $identity, ?array $profile): array
    {
        $db = ConnectionManager::get('default');
        $lock = 'meduc-account-' . substr(hash('sha256', $identity['email']), 0, 45);
        if ((int)$db->execute('SELECT GET_LOCK(?,5) acquired', [$lock])->fetch('assoc')['acquired'] !== 1) {
            throw new \DomainException('Đang xử lý đăng nhập. Vui lòng thử lại.');
        }
        try {
            $account = $this->findAccount($identity);
            $this->checkState($account);
            if (!$profile && (!$account || AccountProfile::missing($account))) {
                throw new \DomainException('Vui lòng đăng nhập Google lại và hoàn tất thông tin học viên.');
            }
            if (!$account) {
                $result = $this->Customer->saveCustomer($profile + [
                    'username' => $identity['email'], 'email' => $identity['email'],
                    'password' => bin2hex(random_bytes(24)), 'status_account' => 1, 'email_verified' => 1
                ]);
                if (($result[CODE] ?? null) !== SUCCESS) return $result;
                $customerId = (int)$result[DATA]['id'];
                $account = $db->execute('SELECT id account_id,customer_id FROM customers_account WHERE customer_id=? AND deleted=0 ORDER BY id LIMIT 1',
                    [$customerId])->fetch('assoc');
                if (!$account) throw new \RuntimeException('Cannot load new Google account.');
            } else {
                $customerId = (int)$account['customer_id'];
                if ($profile) {
                    $result = $this->Customer->saveCustomer($profile, $customerId);
                    if (($result[CODE] ?? null) !== SUCCESS) return $result;
                }
                if (strcasecmp(trim((string)$account['email']), $identity['email']) === 0) {
                    $db->execute('UPDATE customers SET email_verified=1 WHERE id=? AND deleted=0', [$customerId]);
                }
            }
            $db->execute('UPDATE customers_account SET google_id=?,status=1 WHERE id=? AND customer_id=? AND deleted=0 AND status IN (1,2)',
                [$identity['google_id'], $account['account_id'], $customerId]);
            return $this->signIn($customerId);
        } finally {
            $db->execute('SELECT RELEASE_LOCK(?)', [$lock]);
        }
    }

    /** Shared final session establishment for complete Google and password registrations. */
    public function signIn(int $customerId): array
    {
        $table = TableRegistry::get('Customers');
        $detail = $table->getDetailCustomer($customerId, ['get_account' => true, 'get_default_address' => true]);
        if (empty($detail) || (int)$detail['status'] !== 1 || (int)($detail['Account']['status'] ?? 0) !== 1) {
            throw new \DomainException('Tài khoản chưa thể đăng nhập. Vui lòng liên hệ hỗ trợ.');
        }
        $profile = $table->formatDataCustomerDetail($detail);
        $session = $this->session();
        $session->renew();
        $session->delete(self::PENDING);
        $session->delete(self::NONCE);
        $session->delete(MEMBER);
        $session->write(MEMBER, $profile);
        return $this->System->getResponse([CODE => SUCCESS, MESSAGE => 'Đăng nhập thành công.', DATA => $profile]);
    }
}
