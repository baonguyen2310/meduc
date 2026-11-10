<?php
declare(strict_types=1);

namespace App\Lib;

use Cake\Cache\Cache;
use Cake\Http\Client;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/** Accept only Google-signed, audience- and browser-session-bound identities. */
class GoogleIdentity
{
    public function verify(string $credential, string $clientId, string $nonce): array
    {
        if ($clientId === '' || $nonce === '' || strlen($credential) > 16000) {
            throw new \InvalidArgumentException('Invalid Google credential.');
        }
        $parts = explode('.', $credential);
        if (count($parts) !== 3) throw new \InvalidArgumentException('Invalid Google credential.');
        $header = json_decode(JWT::urlsafeB64Decode($parts[0]), true);
        if (!is_array($header) || ($header['alg'] ?? '') !== 'RS256' ||
            !is_string($header['kid'] ?? null) || $header['kid'] === '' || strlen($header['kid']) > 200) {
            throw new \InvalidArgumentException('Invalid Google signing key.');
        }
        $certificates = $this->certificates($header['kid']);
        if (empty($certificates[$header['kid']])) throw new \InvalidArgumentException('Unknown Google signing key.');
        // The two deployed environments have JWT-compatible dependencies; support v5 and v6.
        $keys = $certificates;
        if (class_exists(Key::class)) {
            foreach ($keys as $kid => $certificate) $keys[$kid] = new Key($certificate, 'RS256');
            $claims = (array)JWT::decode($credential, $keys);
        } else {
            $claims = (array)JWT::decode($credential, $keys, ['RS256']);
        }
        if (!in_array($claims['iss'] ?? null, ['accounts.google.com', 'https://accounts.google.com'], true) ||
            ($claims['aud'] ?? null) !== $clientId || (int)($claims['exp'] ?? 0) <= time() ||
            !is_string($claims['nonce'] ?? null) || !hash_equals($nonce, $claims['nonce']) ||
            !is_string($claims['sub'] ?? null) || $claims['sub'] === '' || strlen($claims['sub']) > 250 ||
            !in_array($claims['email_verified'] ?? false, [true, 'true', 1, '1'], true)) {
            throw new \InvalidArgumentException('Google identity verification failed.');
        }
        $email = is_string($claims['email'] ?? null) ? strtolower(trim($claims['email'])) : '';
        if (strlen($email) > 255 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException('Google did not supply a valid email.');
        }
        return [
            'google_id' => $claims['sub'], 'email' => $email,
            'full_name' => is_string($claims['name'] ?? null) ? mb_substr(trim($claims['name']), 0, 255) : ''
        ];
    }

    protected function certificates(string $kid): array
    {
        $cached = Cache::read('meduc_google_signin_certificates');
        if (is_array($cached) && ($cached['expires'] ?? 0) > time() && !empty($cached['keys'][$kid])) {
            return $cached['keys'];
        }
        $response = (new Client(['timeout' => 8]))->get('https://www.googleapis.com/oauth2/v1/certs');
        $keys = $response->getJson();
        if ($response->getStatusCode() !== 200 || !is_array($keys) || !$keys) {
            throw new \RuntimeException('Cannot retrieve Google certificates.');
        }
        foreach ($keys as $id => $certificate) {
            if (!is_string($id) || !is_string($certificate)) throw new \RuntimeException('Invalid Google certificates.');
        }
        Cache::write('meduc_google_signin_certificates', ['expires' => time() + 3600, 'keys' => $keys]);
        return $keys;
    }
}
