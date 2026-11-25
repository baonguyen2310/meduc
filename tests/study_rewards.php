<?php
/** Integration fixture. Apply both voucher migrations and use a disposable MedUC database. */
declare(strict_types=1);

use App\Controller\VoucherController;
use App\Service\Vouchers;
use App\Service\WeeklyStudyTime;
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
checkStudy(WeeklyStudyTime::installed(), 'The weekly rewards migration is required.');
$db->enableSavePoints(true);
$db->begin();
try {
    $now = time();
    [$week, $nextWeek] = WeeklyStudyTime::week($now);
    checkStudy($nextWeek - $week === 7 * 86400 && gmdate('N H:i', $week + 7 * 3600) === '1 00:00', 'The week does not start Monday at midnight in Vietnam.');
    $tiers = $db->execute('SELECT study_minutes,discount_value,scope FROM voucher_campaigns WHERE preset_key IS NOT NULL ORDER BY study_minutes')->fetchAll('assoc');
    checkStudy(array_map('intval', array_column($tiers, 'study_minutes')) === [60, 180, 300]
        && array_map('intval', array_column($tiers, 'discount_value')) === [20000, 50000, 100000]
        && array_unique(array_column($tiers, 'scope')) === ['knowledge'], 'The three configured presets differ.');
    $db->execute("UPDATE voucher_campaigns SET active=IF(preset_key IS NULL,0,1),starts_at=? WHERE kind='study'", [$week - 1]);

    $code = 'WEEK-' . bin2hex(random_bytes(6));
    $db->insert('customers', ['code' => $code, 'full_name' => 'Weekly study fixture', 'status' => 1, 'deleted' => 0]);
    $customer = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);

    WeeklyStudyTime::record($customer, $week, $week + 30);
    WeeklyStudyTime::record($customer, $week + 15, $week + 45);
    WeeklyStudyTime::record($customer, $week + 15, $week + 45);
    WeeklyStudyTime::record($customer, $week + 45, $week + 600);
    checkStudy(WeeklyStudyTime::total($customer, $now)['seconds'] === 45, 'Overlapping heartbeats or idle time received excess credit.');

    $rewards = [];
    foreach ([3599 => 0, 3600 => 1, 10800 => 2, 18000 => 3] as $seconds => $count) {
        $db->update('voucher_study_weeks', ['active_seconds' => $seconds], ['customer_id' => $customer, 'week_start' => $week]);
        $progress = Vouchers::studyProgress($customer, $now);
        $rewards = $progress['rewards'];
        checkStudy(count(array_filter(array_column($rewards, 'claimable'))) === $count, 'Reward unlocked at the wrong duration.');
        checkStudy(!array_filter(array_column($rewards, 'code')), 'Viewing progress auto-issued a reward.');
        if ($count === 0) {
            rejectedStudy(fn() => Vouchers::claimStudy($customer, $rewards[0]['id'], $week, $now), 'Claimed the reward before reaching the minimum.');
        }
    }
    $campaign = $rewards[2]['id'];
    $session = (new ServerRequest())->getSession();
    $request = static function ($method, array $body = []) use ($session) {
        return (new ServerRequest(['session' => $session]))->withMethod($method)->withParsedBody($body);
    };
    $claim = static function ($campaign, $week) use ($request) {
        return (new VoucherController($request('POST', ['campaign_id' => $campaign, 'week_start' => $week])))->claimStudy();
    };
    checkStudy($claim($campaign, $week)->getStatusCode() === 401, 'A guest was able to claim a study voucher.');
    $session->write(MEMBER, ['id' => $customer]);
    $claimResponse = $claim($campaign, $week);
    $claimed = json_decode((string)$claimResponse->getBody(), true)['data'];
    $code = $claimed['code'];
    checkStudy($claimResponse->getStatusCode() === 200 && $code && $claimed['progress']['rewards'][2]['code'] === $code,
        'The claim endpoint did not return the new voucher.');
    checkStudy(Vouchers::claimStudy($customer, $campaign, $week, $now) === $code, 'A repeated claim created a new code.');
    $offers = Vouchers::personalOffers(['id' => $customer], 'knowledge', $now, true);
    checkStudy(count($offers) === 3 && $offers[2]['code'] === $code && $offers[0]['claimable'], 'Checkout did not expose the correct claimable and claimed vouchers.');
    checkStudy(Vouchers::studyProgress($customer, $nextWeek)['seconds'] === 0
        && !array_filter(array_column(Vouchers::studyProgress($customer, $nextWeek)['rewards'], 'code')), 'The new week inherited old progress or vouchers.');
    WeeklyStudyTime::record($customer, $nextWeek - 18, $nextWeek + 12);
    checkStudy(WeeklyStudyTime::total($customer, $nextWeek - 1)['seconds'] === 18018
        && WeeklyStudyTime::total($customer, $nextWeek)['seconds'] === 12, 'An interval spanning midnight was placed in the wrong week.');
    $offer = Vouchers::quote(['id' => $customer], 'knowledge', 1000000, ['voucher_codes' => [$code]]);
    checkStudy($offer['total'] === 900000, 'The five-hour reward did not apply to a knowledge course.');
    rejectedStudy(fn() => Vouchers::quote(['id' => $customer], 'exam_solution', 1000000, ['voucher_codes' => [$code]]),
        'The reward was accepted for an exam course.');
    Vouchers::recordUses('order', $customer, $customer, $offer['discounts']);
    checkStudy(!in_array($campaign, array_column(Vouchers::studyProgress($customer, $now)['rewards'], 'id'), true)
        && !in_array($campaign, array_column(Vouchers::personalOffers(['id' => $customer], 'knowledge', $now, true), 'id'), true),
        'The used voucher still appeared in one of the coupon lists.');
    rejectedStudy(fn() => Vouchers::claimStudy($customer, $campaign, $week, $now), 'A used voucher could be claimed again in the same week.');
    rejectedStudy(fn() => Vouchers::claimStudy($customer, $campaign, $week, $nextWeek), 'An old request claimed a reward in the wrong week.');
    rejectedStudy(fn() => Vouchers::claimStudy($customer, $campaign, $nextWeek, $nextWeek), 'The next week allowed a claim without enough study time.');
    $db->update('voucher_study_weeks', ['active_seconds' => 18000], ['customer_id' => $customer, 'week_start' => $nextWeek]);
    checkStudy(Vouchers::claimStudy($customer, $campaign, $nextWeek, $nextWeek) !== $code, 'A new week could not issue a fresh code for an earlier redeemed tier.');

    $db->insert('products', ['course_kind' => 'knowledge', 'status' => 1, 'deleted' => 0, 'draft' => 0]);
    $course = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    $db->insert('quizs', ['status' => 1, 'deleted' => 0, 'draft' => 0]);
    $quiz = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    $db->insert('quizs_attribute', ['quiz_id' => $quiz, 'attribute_id' => 18, 'value' => json_encode([
        ['name_vi' => 'Câu hỏi kiểm thử', 'option_one_vi' => 'A', 'option_two_vi' => 'B', 'answer_vi' => 1],
    ])]);
    $db->insert('products_attribute', ['product_id' => $course, 'attribute_id' => 11, 'value' => json_encode([
        ['name_vi' => 'Bài video học thử', 'trial_vi' => 'y', 'youtube_id_vi' => 'abcdefghijk', 'quiz_id_vi' => $quiz],
        ['name_vi' => 'Bài video có phí', 'trial_vi' => 'n', 'youtube_id_vi' => 'abcdefghijl'],
    ])]);
    $study = static function ($method, array $body = []) use ($request) {
        return (new VoucherController($request($method, $body)))->study();
    };
    $session->delete(MEMBER);
    checkStudy($study('GET')->getStatusCode() === 401, 'A guest was able to read a member progress record.');
    $session->write(MEMBER, ['id' => $customer]);
    $db->delete('voucher_study_weeks', ['customer_id' => $customer, 'week_start' => $week]);
    $pulse = ['activity' => 'video', 'item_id' => 1, 'course_id' => $course, 'stream' => str_repeat('a', 24)];
    checkStudy($study('POST', $pulse)->getStatusCode() === 200, 'The trial video was not authorized.');
    $path = 'Vouchers.studyStreams.' . $pulse['stream'];
    $streams = $session->read($path);
    checkStudy($streams && $streams['item'] === 1, 'The active interval is missing its authorized source.');
    $lastSeen = time() - 15;
    $session->write($path . '.seen', $lastSeen);
    $stopped = $study('POST', ['stop' => '1'] + $pulse);
    $total = json_decode((string)$stopped->getBody(), true)['data'];
    checkStudy($stopped->getStatusCode() === 200 && !$session->read($path)
        && $total['seconds'] === $total['server_at'] - max($lastSeen, $total['week_start']),
        'Pausing a video did not close the recording interval.');
    checkStudy($study('POST', ['item_id' => 2, 'stream' => str_repeat('b', 24)] + $pulse)->getStatusCode() === 422, 'A locked video counted as study.');
    $db->insert('course_enrollments', ['product_id' => $course, 'customer_id' => $customer, 'source' => 'admin']);
    checkStudy($study('POST', ['item_id' => 2, 'stream' => str_repeat('b', 24)] + $pulse)->getStatusCode() === 200, 'The paid lesson did not start after enrollment.');
    checkStudy($study('POST', ['activity' => 'quiz', 'item_id' => $quiz, 'stream' => str_repeat('c', 24)] + $pulse)->getStatusCode() === 200, 'The available lesson quiz was not authorized.');
    $db->update('products', ['course_kind' => 'exam_solution'], ['id' => $course]);
    checkStudy($study('POST', ['stream' => str_repeat('d', 24)] + $pulse)->getStatusCode() === 422, 'An exam course counted as study.');
    echo "study rewards: claim, single use, weekly renewal, overlaps, trial video and authenticated exercise passed\n";
} finally {
    $db->rollback();
}
