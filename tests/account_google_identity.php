<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
require dirname(__DIR__) . '/coredaca/vendor/autoload.php';
use App\Lib\AccountProfile;
use App\Lib\GoogleIdentity;
use Firebase\JWT\JWT;

function expectAuth($condition, string $message): void
{
    if (!$condition) throw new RuntimeException($message);
}
function expectAuthRejected(callable $callback, string $message): void
{
    $rejected = false;
    try { $callback(); } catch (Throwable $expected) { $rejected = true; }
    expectAuth($rejected, $message);
}
class FixtureGoogleIdentity extends GoogleIdentity
{
    public $keys = [];
    protected function certificates(string $kid): array { return $this->keys; }
}
$key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);
openssl_pkey_export($key, $private);
$verifier = new FixtureGoogleIdentity();
$verifier->keys = ['fixture' => openssl_pkey_get_details($key)['key']];
$claims = ['iss' => 'https://accounts.google.com', 'aud' => 'fixture-client', 'sub' => '123456789012345678901',
    'email' => 'Fixture@Example.com', 'email_verified' => true, 'nonce' => 'fixture-browser-nonce',
    'iat' => time() - 10, 'exp' => time() + 300, 'name' => 'Test Student'];
$token = function (array $payload) use ($private): string { return JWT::encode($payload, $private, 'RS256', 'fixture'); };
$identity = $verifier->verify($token($claims), 'fixture-client', 'fixture-browser-nonce');
expectAuth($identity['email'] === 'fixture@example.com' && $identity['google_id'] === $claims['sub'], 'Valid Google identity failed.');
$rejected = 0;
foreach ([['aud' => 'other-client'], ['iss' => 'https://attacker.invalid'], ['exp' => time() - 60],
    ['nonce' => 'other-browser'], ['email_verified' => false], ['email' => 'not-an-email'], ['sub' => '']] as $override) {
    expectAuthRejected(function () use ($verifier, $token, $claims, $override) {
        $verifier->verify($token(array_replace($claims, $override)), 'fixture-client', 'fixture-browser-nonce');
    }, 'Unsafe Google claims accepted: ' . json_encode($override));
    $rejected++;
}
foreach (['', 'not.a.jwt', JWT::encode($claims, 'attacker-secret', 'HS256', 'fixture')] as $bad) {
    expectAuthRejected(function () use ($verifier, $bad) {
        $verifier->verify($bad, 'fixture-client', 'fixture-browser-nonce');
    }, 'Malformed/HS256 Google credential accepted.');
    $rejected++;
}
$parts = explode('.', $token($claims));
$parts[1] = JWT::urlsafeB64Encode(json_encode(array_replace($claims, ['email' => 'forged@example.com'])));
expectAuthRejected(function () use ($verifier, $parts) {
    $verifier->verify(implode('.', $parts), 'fixture-client', 'fixture-browser-nonce');
}, 'Forged Google signature accepted.');
$rejected++;
$profile = ['full_name' => 'Nguyễn Văn An', 'phone' => '0901234567', 'school_name' => 'Đại học Y', 'student_year' => '2'];
expectAuth(AccountProfile::missing($profile) === [], 'Complete profile was rejected.');
expectAuth(AccountProfile::missing(['full_name' => 'An', 'phone' => '', 'school_name' => null, 'student_year' => '99']) ===
    ['phone', 'school_name', 'student_year'], 'Missing profile fields not detected.');
expectAuth(AccountProfile::validate($profile)['phone'] === '0901234567', 'Valid profile changed.');
foreach (['phone' => 'bad', 'school_name' => ' ', 'student_year' => '99', 'full_name' => ' '] as $field => $bad) {
    try {
        AccountProfile::validate(array_replace($profile, [$field => $bad]));
        throw new RuntimeException('Invalid profile accepted: ' . $field);
    } catch (InvalidArgumentException $expected) {}
}
foreach (['full_name', 'school_name'] as $field) {
    expectAuthRejected(function () use ($profile, $field) {
        AccountProfile::validate(array_replace($profile, [$field => "\u{00A0}\u{00A0}"]));
    }, 'Unicode-only required profile field accepted: ' . $field);
    expectAuth(in_array($field, AccountProfile::missing(array_replace($profile, [$field => "\u{00A0}"])), true), 'Unicode-only field was not missing.');
}
expectAuth(AccountProfile::validate(array_replace($profile, ['student_year' => 2]))['student_year'] === '2', 'Numeric student year rejected.');
echo json_encode(['valid_google_identity' => true, 'rejected_credentials' => $rejected,
    'profile_validation' => true], JSON_PRETTY_PRINT) . "\n";
