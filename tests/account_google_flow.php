<?php
/** CLI integration checks. Creates and removes only uniquely named .invalid fixtures. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
$app = new App\Application($root . '/coredaca/config');
$app->bootstrap();
if (!defined('LANGUAGE')) define('LANGUAGE', 'vi');
if (!defined('CDN_URL')) define('CDN_URL', 'https://cdn.meduc.vn');

use App\Lib\GoogleIdentity;
use App\Controller\Component\GoogleSignInComponent;
use Cake\Controller\ComponentRegistry;
use Cake\Datasource\ConnectionManager;
use Cake\Http\ServerRequest;
use Cake\ORM\TableRegistry;
use Cake\Utility\Security;
use Firebase\JWT\JWT;

class FlowFixtureIdentity extends GoogleIdentity
{
    public $keys;
    protected function certificates(string $kid): array { return $this->keys; }
}
class FlowFixtureGoogle extends GoogleSignInComponent
{
    public $verifier;
    protected function identityVerifier(): GoogleIdentity { return $this->verifier; }
}
function flowExpect($condition, string $message): void
{
    if (!$condition) throw new RuntimeException($message);
}
$request = (new ServerRequest(['environment' => ['REQUEST_METHOD' => 'POST', 'HTTP_HOST' => 'meducv3.duckdns.org', 'HTTPS' => 'on']]))->withMethod('POST');
$controller = new App\Controller\MemberController($request);
$member = $controller->loadComponent('Member');
$google = new FlowFixtureGoogle(new ComponentRegistry($controller));
$rsa = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);
openssl_pkey_export($rsa, $private);
$google->verifier = new FlowFixtureIdentity();
$google->verifier->keys = ['fixture' => openssl_pkey_get_details($rsa)['key']];
$session = $controller->getRequest()->getSession();
$db = ConnectionManager::get('default');
$tag = 'auth-check-' . bin2hex(random_bytes(7));
$email1 = $tag . '@example.invalid';
$email2 = $tag . '-google@example.invalid';
$email3 = str_repeat('a', 32) . '-' . $tag . '@example.invalid';
$password = 'Fixture-Password-78452';
$base = ['full_name' => 'MedUC Auth Fixture', 'school_name' => 'Trường kiểm thử MedUC', 'student_year' => '2',
    'password' => $password, 'verify_password' => $password];
$phone = function (): string { return '09' . str_pad((string)random_int(10000000, 99999999), 8, '0', STR_PAD_LEFT); };
$id = '999' . (string)random_int(100000000, 999999999) . (string)random_int(100000000, 999999999);
$signIn = function (string $email, string $googleId) use ($google, $private, $session) {
    $session->delete(MEMBER);
    $options = $google->options();
    $claims = ['iss' => 'https://accounts.google.com', 'aud' => $options[DATA]['client_id'],
        'nonce' => $options[DATA]['nonce'], 'sub' => $googleId, 'email' => $email, 'email_verified' => true,
        'name' => 'Google Fixture', 'iat' => time() - 5, 'exp' => time() + 300];
    return $google->login(['credential' => JWT::encode($claims, $private, 'RS256', 'fixture')]);
};
$checks = [];
try {
    $form = $base + ['email' => $email1, 'phone' => $phone(), 'birthday' => '2000-01-01', 'username' => 'ignored-value'];
    $beforeRegister = $google->options();
    $oldCredential = JWT::encode(['iss' => 'https://accounts.google.com', 'aud' => $beforeRegister[DATA]['client_id'],
        'nonce' => $beforeRegister[DATA]['nonce'], 'sub' => $id . '1', 'email' => $email2,
        'email_verified' => true, 'iat' => time() - 5, 'exp' => time() + 300], $private, 'RS256', 'fixture');
    $registered = $member->register($form, ['api' => true]);
    flowExpect(($registered[CODE] ?? null) === SUCCESS, 'Registration failed: ' . json_encode($registered));
    $cid = (int)$registered[DATA]['customer_id'];
    $row = $db->execute('SELECT c.email_verified,c.birthday,a.username,a.status FROM customers c INNER JOIN customers_account a ON a.customer_id=c.id WHERE c.id=?', [$cid])->fetch('assoc');
    flowExpect($row['username'] === $email1 && (int)$row['status'] === 1 && (int)$row['email_verified'] === 0 && !$row['birthday'], 'Registration did not create an active, unverified email username without DOB.');
    flowExpect((int)$session->read(MEMBER . '.customer_id') === $cid, 'Registration did not authenticate.');
    flowExpect((int)$db->execute('SELECT COUNT(*) n FROM email_token WHERE email=?', [$email1])->fetch('assoc')['n'] === 0, 'Registration created an email token.');
    $checks[] = 'registration_active_without_email_or_otp';
    flowExpect(!$session->read('Meduc.GoogleNonce'), 'Registration retained an earlier Google nonce.');
    $stale = $google->login(['credential' => $oldCredential]);
    flowExpect(($stale[CODE] ?? null) !== SUCCESS && (int)$session->read(MEMBER . '.customer_id') === $cid,
        'Google credential from before registration replaced the new member.');
    $profileChange = $member->updateProfile(['full_name' => $base['full_name'], 'email' => $email1,
        'phone' => $form['phone'], 'email_verified' => 1], ['api' => true]);
    flowExpect(($profileChange[CODE] ?? null) === SUCCESS &&
        (int)$db->execute('SELECT email_verified FROM customers WHERE id=?', [$cid])->fetch('assoc')['email_verified'] === 0,
        'Member profile update allowed verification-state spoofing.');
    $pendingBeforePassword = $signIn($email2, $id . '1');
    $google->options();
    $passwordLogin = $member->login(['username' => $email1, 'password' => $password], ['api' => true]);
    flowExpect(($passwordLogin[CODE] ?? null) === SUCCESS && !$session->read('Meduc.GoogleProfile') && !$session->read('Meduc.GoogleNonce'),
        'Password login retained pending Google state.');
    $staleProfile = $google->completeProfile($base + ['phone' => $phone(), 'profile_token' => $pendingBeforePassword[DATA]['profile_token']]);
    flowExpect(($staleProfile[CODE] ?? null) !== SUCCESS && (int)$session->read(MEMBER . '.customer_id') === $cid,
        'Old Google profile replaced a password-authenticated member.');
    $pendingBeforeLogout = $signIn($email2, $id . '1');
    $google->options();
    $member->logout();
    flowExpect(!$session->read('Meduc.GoogleProfile') && !$session->read('Meduc.GoogleNonce') && !$session->read(MEMBER), 'Logout retained Google state.');
    $staleProfile = $google->completeProfile($base + ['phone' => $phone(), 'profile_token' => $pendingBeforeLogout[DATA]['profile_token']]);
    flowExpect(($staleProfile[CODE] ?? null) !== SUCCESS && !$session->read(MEMBER), 'Old Google profile survived logout.');
    $checks[] = 'google_state_cleared_on_registration_password_login_and_logout';
    $checks[] = 'verification_flag_owned_by_server';
    $duplicate = $member->register($form, ['api' => true]);
    flowExpect(($duplicate[CODE] ?? null) !== SUCCESS, 'Duplicate email registration accepted.');
    $long = $member->register($base + ['email' => $email3, 'phone' => $phone()], ['api' => true]);
    flowExpect(($long[CODE] ?? null) === SUCCESS && $long[DATA]['email'] === $email3, 'Email username over 50 characters was truncated/rejected.');
    $checks[] = 'duplicate_email_and_long_username';
    foreach (['apple', 'facebook', 'APPLE', ['google']] as $type) {
        $session->delete(MEMBER);
        $denied = $member->socialLogin(['type' => $type, 'social_id' => '123', 'email' => $email1, 'full_name' => 'Forged']);
        flowExpect(($denied[CODE] ?? null) !== SUCCESS && !$session->read(MEMBER), 'Disabled provider authenticated.');
    }
    $checks[] = 'apple_facebook_and_aliases_denied';
    $db->execute('UPDATE customers SET school_name=NULL,student_year=NULL WHERE id=?', [$cid]);
    $pending = $signIn($email1, $id);
    flowExpect(($pending[CODE] ?? null) === SUCCESS && !empty($pending[DATA]['profile_required']) && !$session->read(MEMBER), 'Incomplete Google profile authenticated early.');
    $bad = $google->completeProfile($base + ['phone' => $form['phone'], 'profile_token' => 'wrong']);
    flowExpect(($bad[CODE] ?? null) !== SUCCESS && !$session->read(MEMBER), 'Invalid profile token accepted.');
    $complete = $google->completeProfile($base + ['phone' => $form['phone'], 'profile_token' => $pending[DATA]['profile_token']]);
    flowExpect(($complete[CODE] ?? null) === SUCCESS && (int)$complete[DATA]['customer_id'] === $cid && $complete[DATA]['email_verified'], 'Existing Google profile did not complete: ' . json_encode($complete));
    $again = $signIn($email1, $id);
    flowExpect(($again[CODE] ?? null) === SUCCESS && empty($again[DATA]['profile_required']) && (int)$again[DATA]['customer_id'] === $cid, 'Complete linked Google user was prompted again.');
    $checks[] = 'existing_google_profile_completion_then_direct_login';
    $new = $signIn($email2, $id . '1');
    flowExpect(!empty($new[DATA]['profile_required']) && !$session->read(MEMBER), 'New Google user bypassed profile form.');
    flowExpect((int)$db->execute('SELECT COUNT(*) n FROM customers WHERE email=?', [$email2])->fetch('assoc')['n'] === 0, 'New Google account created before required profile.');
    $created = $google->completeProfile($base + ['phone' => $phone(), 'profile_token' => $new[DATA]['profile_token']]);
    flowExpect(($created[CODE] ?? null) === SUCCESS && $created[DATA]['email'] === $email2 && $created[DATA]['email_verified'], 'New Google account did not complete.');
    $checks[] = 'new_google_requires_profile_without_registration_mail';
    $db->execute('UPDATE customers_account SET status=0 WHERE customer_id=?', [$cid]);
    $blocked = $signIn($email1, $id);
    flowExpect(($blocked[CODE] ?? null) !== SUCCESS && !$session->read(MEMBER), 'Blocked account was authenticated by Google.');
    $db->execute('UPDATE customers_account SET status=2 WHERE customer_id=?', [$cid]);
    $legacy = $member->login(['username' => $email1, 'password' => $password], ['api' => true]);
    flowExpect(($legacy[CODE] ?? null) === SUCCESS && $session->read(MEMBER . '.customer_id') == $cid, 'Legacy pending account cannot use new immediate-registration policy.');
    $checks[] = 'blocked_accounts_rejected_and_old_pending_can_login';
    $code = '492731';
    $hash = hash_hmac('sha256', 'password_reset_otp:' . $cid . ':' . $code, Security::getSalt());
    $db->execute('INSERT INTO email_token (email,type,code,end_time,status,customer_id,attempts,sent_at) VALUES (?,?,?,?,?,?,?,?)',
        [$email1, 'password_reset_otp', $hash, time() + 600, 0, $cid, 0, time()]);
    $reset = $controller->loadComponent('PasswordResetOtp')->reset($email1, $code, 'Fixture-New-Password-4292');
    flowExpect(($reset[CODE] ?? null) === SUCCESS, 'Existing password-reset OTP flow failed: ' . json_encode($reset));
    $checks[] = 'forgot_password_otp_preserved';
} finally {
    $rows = $db->execute('SELECT id FROM customers WHERE email IN (?,?,?)', [$email1, $email2, $email3])->fetchAll('assoc');
    foreach ($rows as $row) {
        $db->execute('DELETE FROM customers_address WHERE customer_id=?', [$row['id']]);
        $db->execute('DELETE FROM customers_account WHERE customer_id=?', [$row['id']]);
        $db->execute('DELETE FROM customers WHERE id=?', [$row['id']]);
    }
    $db->execute('DELETE FROM email_token WHERE email IN (?,?,?)', [$email1, $email2, $email3]);
    $session->delete(MEMBER);
    $session->delete('Meduc');
}
echo json_encode(['passed' => $checks, 'fixtures_removed' => true], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n";
