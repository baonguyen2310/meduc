<?php
declare(strict_types=1);
namespace App\Controller;

use App\Service\ThemeUsage;
use Cake\Http\Cookie\Cookie;
use Cake\ORM\TableRegistry;

class ThemeUsageController extends AppController
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
        $this->autoRender = false;
    }

    public function record()
    {
        $response = $this->response->withHeader('Cache-Control', 'private, no-store');
        if (!$this->request->is('post')) return $response->withStatus(405)->withHeader('Allow', 'POST');
        $theme = $this->request->getData('theme');
        if (!is_string($theme) || !in_array($theme, ['dark', 'light'], true)) return $response->withStatus(422);
        if (!ThemeUsage::installed()) return $response->withStatus(503);

        $session = $this->request->getSession();
        $browser = $this->request->getCookie('meduc-theme-visitor');
        if (!is_string($browser) || !preg_match('/^[a-f0-9]{64}$/', $browser)) {
            // The session also prevents two first-visit tabs from minting separate browser identities.
            $browser = $session->read('ThemeUsage.browser');
            if (!is_string($browser) || !preg_match('/^[a-f0-9]{64}$/', $browser)) $browser = bin2hex(random_bytes(32));
        }
        $session->write('ThemeUsage.browser', $browser);
        $member = $session->read(MEMBER) ?: [];
        $customerId = (int)($member['id'] ?? 0);
        if ($customerId && !TableRegistry::get('Customers')->find()->select(['id'])->where(['id'=>$customerId, 'deleted'=>0])->first()) $customerId = 0;

        try { ThemeUsage::record(hash('sha256', $browser), $theme, $customerId); }
        catch (\Throwable $e) { $this->log('Theme usage: '.$e->getMessage(), 'error'); return $response->withStatus(503); }

        $cookie = Cookie::create('meduc-theme-visitor', $browser, [
            'expires'=>time() + 365 * 86400, 'path'=>'/', 'httponly'=>true,
            'secure'=>$this->request->is('ssl'), 'samesite'=>'Lax',
        ]);
        return $response->withCookie($cookie)->withStatus(204);
    }
}
