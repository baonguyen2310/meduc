<?php
/** Integration fixture. Apply the voucher migrations and use a disposable MedUC database. */
declare(strict_types=1);

use App\Controller\VoucherController;
use App\Service\Vouchers;
use App\Service\WeeklyOnlineTime;
use Cake\Datasource\ConnectionManager;
use Cake\Http\ServerRequest;

if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') {
    exit(1);
}
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
if (getenv('MEDUC_VOUCHER_TEST_DB') !== DB_NAME) {
    throw new RuntimeException('Select an isolated fixture database.');
}
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();

function checkStudy($condition, string $why): void
{
    if (!$condition) {
        throw new RuntimeException($why);
    }
}

function rejectedStudy(callable $action, string $why): void
{
    try {
        $action();
    } catch (InvalidArgumentException $expected) {
        return;
    }
    throw new RuntimeException($why);
}

$db = ConnectionManager::get('default');
checkStudy(WeeklyOnlineTime::installed(), 'The online time migration is required.');
$db->enableSavePoints(true);
$db->begin();
try {
    $now = time();
    [$week, $nextWeek] = WeeklyOnlineTime::week($now);
    checkStudy($nextWeek - $week === 7 * 86400 && gmdate('N H:i', $week + 7 * 3600) === '1 00:00', 'The week does not start Monday at midnight in Vietnam.');
    $tiers = $db->execute('SELECT study_minutes,discount_value,scope FROM voucher_campaigns WHERE preset_key IS NOT NULL ORDER BY study_minutes')->fetchAll('assoc');
    checkStudy(array_map('intval', array_column($tiers, 'study_minutes')) === [60, 180, 300]
        && array_map('intval', array_column($tiers, 'discount_value')) === [20000, 50000, 100000]
        && array_unique(array_column($tiers, 'scope')) === ['knowledge'], 'The three configured presets differ.');
    $db->execute("UPDATE voucher_campaigns SET active=0 WHERE kind<>'study'");
    $db->execute("UPDATE voucher_campaigns SET active=IF(preset_key IS NULL,0,1),starts_at=? WHERE kind='study'", [$week - 1]);

    $code = 'WEEK-' . bin2hex(random_bytes(6));
    $db->insert('customers', ['code' => $code, 'full_name' => 'Weekly online fixture', 'status' => 1, 'deleted' => 0]);
    $customer = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);

    WeeklyOnlineTime::record($customer, $week + 15, $week + 45);
    WeeklyOnlineTime::record($customer, $week, $week + 30);
    WeeklyOnlineTime::record($customer, $week + 15, $week + 45);
    WeeklyOnlineTime::record($customer, $week + 45, $week + 600);
    checkStudy(WeeklyOnlineTime::total($customer, $now)['seconds'] === 45, 'Out-of-order overlapping pulses changed the union of online time.');

    WeeklyOnlineTime::record($customer, $week + 45, $week + 105);
    $db->update('voucher_study_weeks', ['active_seconds' => 36000], ['customer_id' => $customer, 'week_start' => $week]);
    checkStudy(WeeklyOnlineTime::total($customer, $now)['seconds'] === 105,
        'A scheduled background pulse was lost, or old lesson time counted as online.');
    checkStudy(!Vouchers::available('knowledge', $now, $customer), 'Unclaimed rewards enabled voucher entry at checkout.');
    $rewards = [];
    foreach ([3599 => 0, 3600 => 1, 10800 => 2, 18000 => 3] as $seconds => $count) {
        $db->update('voucher_study_weeks', ['online_seconds' => $seconds], ['customer_id' => $customer, 'week_start' => $week]);
        $progress = Vouchers::onlineProgress($customer, $now);
        $rewards = $progress['rewards'];
        checkStudy(count(array_filter(array_column($rewards, 'claimable'))) === $count, 'Reward unlocked at the wrong duration.');
        checkStudy(!array_filter(array_column($rewards, 'code')), 'Viewing progress auto-issued a reward.');
        if ($count === 0) {
            rejectedStudy(fn() => Vouchers::claimOnlineReward($customer, $rewards[0]['id'], $week, $now), 'Claimed the reward before reaching the minimum.');
        }
    }
    $campaign = $rewards[2]['id'];
    $session = (new ServerRequest())->getSession();
    $request = static function ($method, array $body = []) use ($session) {
        return (new ServerRequest(['session' => $session]))->withMethod($method)->withParsedBody($body);
    };
    $claim = static function ($campaign, $week) use ($request) {
        return (new VoucherController($request('POST', ['campaign_id' => $campaign, 'week_start' => $week])))->claimOnline();
    };
    checkStudy($claim($campaign, $week)->getStatusCode() === 401, 'A guest was able to claim a study voucher.');
    $session->write(MEMBER, ['customer_id' => $customer]);
    $claimResponse = $claim($campaign, $week);
    $claimed = json_decode((string)$claimResponse->getBody(), true)['data'];
    $code = $claimed['code'];
    checkStudy($claimResponse->getStatusCode() === 200 && $code && $claimed['progress']['rewards'][2]['code'] === $code,
        'The claim endpoint did not return the new voucher.');
    checkStudy(Vouchers::claimOnlineReward($customer, $campaign, $week, $now) === $code, 'A repeated claim created a new code.');
    $offers = Vouchers::personalOffers(['id' => $customer], 'knowledge', $now);
    checkStudy(count($offers) === 1 && $offers[0]['code'] === $code, 'Checkout should offer issued codes only.');
    checkStudy(Vouchers::available('knowledge', $now, $customer) && !Vouchers::available('quiz', $now, $customer),
        'The claimed code did not enable checkout for the correct product type.');
    checkStudy(Vouchers::onlineProgress($customer, $nextWeek)['seconds'] === 0
        && !array_filter(array_column(Vouchers::onlineProgress($customer, $nextWeek)['rewards'], 'code')), 'The new week inherited old progress or vouchers.');
    WeeklyOnlineTime::record($customer, $nextWeek - 18, $nextWeek + 12);
    checkStudy(WeeklyOnlineTime::total($customer, $nextWeek - 1)['seconds'] === 18018
        && WeeklyOnlineTime::total($customer, $nextWeek)['seconds'] === 12, 'An interval spanning midnight was placed in the wrong week.');
    $offer = Vouchers::quote(['id' => $customer], 'knowledge', 1000000, ['voucher_codes' => [$code]]);
    checkStudy($offer['total'] === 900000, 'The five-hour reward did not apply to a knowledge course.');
    rejectedStudy(fn() => Vouchers::quote(['id' => $customer], 'exam_solution', 1000000, ['voucher_codes' => [$code]]),
        'The reward was accepted for an exam course.');
    Vouchers::recordUses('order', $customer, $customer, $offer['discounts']);
    checkStudy(!in_array($campaign, array_column(Vouchers::onlineProgress($customer, $now)['rewards'], 'id'), true)
        && !in_array($campaign, array_column(Vouchers::personalOffers(['id' => $customer], 'knowledge', $now), 'id'), true),
        'The used voucher still appeared in one of the coupon lists.');
    rejectedStudy(fn() => Vouchers::claimOnlineReward($customer, $campaign, $week, $now), 'A used voucher could be claimed again in the same week.');
    rejectedStudy(fn() => Vouchers::claimOnlineReward($customer, $campaign, $week, $nextWeek), 'An old request claimed a reward in the wrong week.');
    rejectedStudy(fn() => Vouchers::claimOnlineReward($customer, $campaign, $nextWeek, $nextWeek), 'The next week allowed a claim without enough study time.');
    $db->update('voucher_study_weeks', ['online_seconds' => 18000], ['customer_id' => $customer, 'week_start' => $nextWeek]);
    checkStudy(Vouchers::claimOnlineReward($customer, $campaign, $nextWeek, $nextWeek) !== $code, 'A new week could not issue a fresh code for an earlier redeemed tier.');

    $pulse = static function (array $body) use ($request) {
        return (new VoucherController($request('POST', $body)))->online();
    };
    $session->delete(MEMBER);
    checkStudy($pulse(['stream' => str_repeat('a', 32)])->getStatusCode() === 401, 'Guest online time was accepted.');
    $session->write(MEMBER, ['id' => $customer]);
    $db->delete('voucher_study_weeks', ['customer_id' => $customer, 'week_start' => $week]);
    $streamA = str_repeat('a', 32);
    $streamB = str_repeat('b', 32);
    checkStudy($pulse(['stream' => 'unrecognized'])->getStatusCode() === 422, 'Invalid stream ID was accepted.');
    checkStudy($pulse(['stream' => $streamA])->getStatusCode() === 200, 'A new page failed to start.');
    $lastSeen = time() - 35;
    $path = 'Vouchers.onlineStreams.';
    $session->write($path . $streamA . '.seen', $lastSeen);
    $pulse(['stream' => $streamB]);
    $session->write($path . $streamB . '.seen', $lastSeen + 10);
    $response = $pulse(['stream' => $streamB]);
    $data = json_decode((string)$response->getBody(), true)['data'];
    checkStudy($data['seconds'] === $data['server_at'] - $lastSeen - 10, 'Background page time was not credited.');
    $response = $pulse(['stream' => $streamA, 'leaving' => '1', 'seconds' => 3600]);
    $data = json_decode((string)$response->getBody(), true)['data'];
    checkStudy($data['seconds'] === $data['server_at'] - $lastSeen && !$session->read($path . $streamA),
        'Overlapping pages double-counted time, or closing a page did not end the stream.');
    $session->write($path . $streamB . '.seen', time() - WeeklyOnlineTime::MAX_PULSE_GAP - 5);
    $response = $pulse(['stream' => $streamB]);
    checkStudy(json_decode((string)$response->getBody(), true)['data']['seconds'] === $data['seconds'], 'An interrupted browser session received time.');
    $legacy = new VoucherController($request('POST'));
    checkStudy(json_decode((string)$legacy->study()->getBody(), true)['data']['enabled'] === false
        && $legacy->claimStudy()->getStatusCode() === 410, 'The previous classroom endpoints remained active.');
    echo "online rewards: background pulses, non-overlapping time, claims, checkout and weekly renewal passed\n";
} finally {
    $db->rollback();
}
