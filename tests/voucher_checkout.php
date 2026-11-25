<?php
/** Run with --fixtures and MEDUC_VOUCHER_TEST_DB set to the disposable database name. */
declare(strict_types=1);

use App\Service\CommercePurchases;
use App\Service\Vouchers;
use App\Service\WeeklyStudyTime;
use Cake\Datasource\ConnectionManager;

if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') {
    exit(1);
}
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
if (getenv('MEDUC_VOUCHER_TEST_DB') !== DB_NAME) {
    throw new RuntimeException('Select an isolated fixture database with MEDUC_VOUCHER_TEST_DB.');
}
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();

function expectVoucher(bool $condition, string $failure): void
{
    if (!$condition) {
        throw new RuntimeException($failure);
    }
}

function rejectsVoucher(callable $action): void
{
    try {
        $action();
    } catch (InvalidArgumentException $error) {
        return;
    }
    throw new RuntimeException('The invalid voucher quote was accepted.');
}

function customerFixture($db, string $code, bool $partner = false): array
{
    $row = [
        'code' => $code, 'full_name' => 'Voucher fixture', 'email' => strtolower($code) . '@example.invalid',
        'phone' => '0912345678', 'status' => 1, 'deleted' => 0, 'created' => time(),
        'is_partner_affiliate' => (int)$partner, 'affiliate_percent' => $partner ? 5 : null,
    ];
    $db->insert('customers', $row);
    return $row + ['id' => (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0)];
}

function invoiceFixture($db, array $buyer, int $amount, int $created, string $status = DRAFT): int
{
    $db->insert('orders', [
        'code' => 'VTEST-' . bin2hex(random_bytes(8)), 'type' => ORDER, 'source' => WEBSITE, 'status' => $status,
        'total' => $amount, 'created' => $created, 'deleted' => 0,
    ]);
    $id = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    $db->insert('orders_contact', [
        'order_id' => $id, 'customer_id' => $buyer['id'], 'full_name' => $buyer['full_name'],
        'email' => $buyer['email'], 'phone' => $buyer['phone'],
    ]);
    return $id;
}

function paymentFixture($db, int $order, int $amount, int $time, int $status = 1, int $type = 1): void
{
    $db->insert('payments', [
        'foreign_type' => ORDER, 'foreign_id' => $order, 'type' => $type, 'amount' => $amount,
        'status' => $status, 'created' => $time, 'payment_time' => $time,
    ]);
}

function shopFixture($db, int $form, array $payload, int $created): int
{
    $db->insert('contacts', ['form_id' => $form, 'value' => json_encode($payload), 'created' => $created, 'deleted' => 0]);
    return (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
}

$db = ConnectionManager::get('default');
expectVoucher(WeeklyStudyTime::installed() && CommercePurchases::installed(), 'Apply the voucher, study rewards and commerce migrations first.');
$db->enableSavePoints(true);
$db->begin();
try {
    $db->execute('UPDATE voucher_campaigns SET active=0 WHERE active=1');
    $now = time();
    $tz = new DateTimeZone('Asia/Ho_Chi_Minh');
    $today = (new DateTimeImmutable('@' . $now))->setTimezone($tz)->setTime(0, 0);
    $old = $today->modify('-5 days')->getTimestamp();
    $buyer = customerFixture($db, 'BUY-' . bin2hex(random_bytes(4)));
    $partner = customerFixture($db, 'REF-' . bin2hex(random_bytes(4)), true);
    $other = customerFixture($db, 'OTHER-' . bin2hex(random_bytes(4)));
    $suffix = strtoupper(bin2hex(random_bytes(4)));
    $common = 'COMMON-' . $suffix;
    $shopOnly = 'SHOP-' . $suffix;
    $referral = 'REFER-' . $suffix;
    $program = [
        'name' => 'Voucher fixture ' . $suffix, 'scope' => 'all', 'discount_type' => 'fixed',
        'starts_at' => $today->modify('-1 day')->format('Y-m-d'), 'ends_at' => $today->modify('+8 days')->format('Y-m-d'),
        'active' => 1,
    ];
    $knowledgeOnly = 'KNOW-' . $suffix;
    Vouchers::saveCampaign(0, ['kind' => 'common', 'scope' => 'knowledge', 'code' => $knowledgeOnly, 'discount_value' => 10000] + $program);
    $knowledgeInput = ['voucher_codes' => [$knowledgeOnly], 'voucher_expected_amount' => 290000];
    expectVoucher(Vouchers::available('knowledge', $now), 'Knowledge-only voucher did not enable the offer.');
    expectVoucher(Vouchers::confirm($buyer, 'knowledge', 300000, $knowledgeInput)['total'] === 290000, 'Knowledge-only voucher was not honored.');
    foreach (['exam_solution', 'quiz', 'document', 'shop'] as $otherKind) {
        expectVoucher(!Vouchers::available($otherKind, $now), 'Knowledge-only campaign was advertised for ' . $otherKind . '.');
        rejectsVoucher(fn() => Vouchers::confirm($buyer, $otherKind, 300000, $knowledgeInput));
    }
    $solutionOnly = 'SOLUTION-' . $suffix;
    Vouchers::saveCampaign(0, ['kind' => 'common', 'scope' => 'exam_solution', 'code' => $solutionOnly, 'discount_value' => 10000] + $program);
    expectVoucher(Vouchers::quote($buyer, 'exam_solution', 300000, ['voucher_codes' => [$solutionOnly]])['total'] === 290000,
        'Exam course voucher was not honored.');
    rejectsVoucher(fn() => Vouchers::quote($buyer, 'knowledge', 300000, ['voucher_codes' => [$solutionOnly]]));
    $academy = 'ACADEMY-' . $suffix;
    Vouchers::saveCampaign(0, ['kind' => 'common', 'scope' => 'academy', 'code' => $academy, 'discount_value' => 10000] + $program);
    foreach (['knowledge', 'exam_solution'] as $courseKind) {
        expectVoucher(Vouchers::quote($buyer, $courseKind, 300000, ['voucher_codes' => [$academy]])['total'] === 290000,
            'Academy-wide voucher did not apply to ' . $courseKind . '.');
    }

    Vouchers::saveCampaign(0, ['kind' => 'common', 'code' => $common, 'discount_type' => 'percent',
        'discount_value' => 10] + $program);
    Vouchers::saveCampaign(0, ['kind' => 'common', 'scope' => 'shop', 'code' => $shopOnly, 'discount_value' => 10000] + $program);
    Vouchers::saveCampaign(0, ['kind' => 'study', 'scope' => 'knowledge', 'study_minutes' => 2, 'discount_value' => 20000] + $program);
    Vouchers::saveCampaign(0, [
        'kind' => 'loyalty', 'scope' => 'knowledge', 'discount_value' => 50000, 'required_spend' => 200000,
        'spend_from' => $today->format('Y-m-d'), 'spend_until' => $today->format('Y-m-d'),
    ] + $program);
    Vouchers::saveCampaign(0, [
        'kind' => 'referral', 'scope' => 'knowledge', 'code' => $referral, 'partner_code' => $partner['code'], 'discount_value' => 15000,
    ] + $program);

    $invoice = invoiceFixture($db, $buyer, 70000, $old);
    paymentFixture($db, $invoice, 70000, $now);
    foreach ([DRAFT, CANCEL] as $status) {
        $excluded = invoiceFixture($db, $buyer, 450000, $now, $status);
        paymentFixture($db, $excluded, 450000, $now, $status === DRAFT ? 2 : 1);
    }
    $refunded = invoiceFixture($db, $buyer, 450000, $now);
    paymentFixture($db, $refunded, 450000, $now);
    paymentFixture($db, $refunded, 100000, $now, 1, 0);
    $outOfWindow = invoiceFixture($db, $buyer, 450000, $old);
    paymentFixture($db, $outOfWindow, 450000, $old);

    $form = (int)$db->execute('SELECT id FROM contacts_form WHERE code=? AND deleted=0', [Vouchers::SHOP_FORM])->fetchColumn(0);
    expectVoucher($form > 0, 'Install the Shop order form fixture.');
    shopFixture($db, $form, [
        'totalPrice' => 50000, 'orderStatus' => 'success', 'customer_id' => $partner['id'],
        'affiliateCode' => $partner['code'], 'email' => $buyer['email'],
    ], $now);
    shopFixture($db, $form, ['totalPrice' => 450000, 'orderStatus' => 'success', 'customer_id' => $other['id'],
        'email' => $buyer['email']], $now);
    $pendingShop = [
        'totalPrice' => 80000, 'orderStatus' => 'initial', 'voucher_buyer_id' => $buyer['id'],
        'customer_id' => $buyer['id'], 'email' => $buyer['email'],
    ];
    $shop = shopFixture($db, $form, $pendingShop, $old);
    expectVoucher(!Vouchers::personalOffers($buyer, 'knowledge', $now), 'Unpaid or out-of-window spend awarded a code.');
    $paid = ['orderStatus' => 'success', 'voucher_paid_at' => $now] + $pendingShop;
    $db->update('contacts', ['value' => json_encode($paid)], ['id' => $shop]);
    Vouchers::awardLoyalty($buyer, $now);
    Vouchers::awardLoyalty($buyer, $now);
    $loyalty = Vouchers::personalOffers($buyer, 'knowledge', $now);
    expectVoucher(count($loyalty) === 1 && $loyalty[0]['kind'] === 'loyalty', 'Paid threshold was not honored by confirmation date.');
    expectVoucher((int)$db->execute('SELECT COUNT(*) FROM voucher_grants WHERE customer_id=?', [$buyer['id']])->fetchColumn(0) === 1, 'Loyalty award was duplicated.');
    expectVoucher(!Vouchers::personalOffers($partner, 'knowledge', $now), 'Old attributed Shop order credited the partner.');
    $loyaltyCode = $loyalty[0]['code'];
    $db->update('contacts', ['value' => json_encode(['orderStatus' => 'cancel'] + $paid)], ['id' => $shop]);
    rejectsVoucher(fn() => Vouchers::quote($buyer, 'knowledge', 300000, ['voucher_codes' => [$loyaltyCode]]));
    $db->update('contacts', ['value' => json_encode($paid)], ['id' => $shop]);

    [$week, $nextWeek] = WeeklyStudyTime::week($now);
    WeeklyStudyTime::record($buyer['id'], $week, $week + 30);
    WeeklyStudyTime::record($buyer['id'], $week, $week + 30);
    WeeklyStudyTime::record($buyer['id'], $week + 30, $week + 60);
    expectVoucher(count(Vouchers::personalOffers($buyer, 'knowledge', $now)) === 1, 'Concurrent tabs double-counted a study minute.');
    WeeklyStudyTime::record($buyer['id'], $week + 60, $week + 90);
    WeeklyStudyTime::record($buyer['id'], $week + 90, $week + 120);
    expectVoucher(count(Vouchers::personalOffers($buyer, 'knowledge', $now)) === 1, 'The study voucher was issued before it was claimed.');
    $eligible = array_column(Vouchers::personalOffers($buyer, 'knowledge', $now, true), null, 'kind');
    expectVoucher(!empty($eligible['study']['claimable']), 'The earned study voucher was not offered for claim.');
    Vouchers::claimStudy($buyer['id'], $eligible['study']['id'], $week, $now);
    $offers = array_column(Vouchers::personalOffers($buyer, 'knowledge', $now), null, 'kind');
    expectVoucher($offers['study']['expires_at'] === $nextWeek, 'Study voucher does not expire on Monday.');
    expectVoucher(count(Vouchers::personalOffers($buyer, 'knowledge', $nextWeek)) === 1, 'Study minutes leaked into a new week.');
    expectVoucher(!Vouchers::personalOffers($buyer, 'exam_solution', $now), 'Knowledge-only personal codes appeared on an exam course.');
    foreach ([$loyaltyCode, $offers['study']['code'], $referral] as $code) {
        rejectsVoucher(fn() => Vouchers::quote($buyer, 'exam_solution', 300000, ['voucher_codes' => [$code]]));
    }
    rejectsVoucher(fn() => Vouchers::quote($buyer, 'shop', 300000, ['voucher_codes' => [$offers['study']['code']]]));
    rejectsVoucher(fn() => Vouchers::quote($other, 'knowledge', 300000, ['voucher_codes' => [$loyaltyCode]]));
    rejectsVoucher(fn() => Vouchers::quote($buyer, 'shop', 300000, ['voucher_codes' => [$common, $shopOnly]]));
    rejectsVoucher(fn() => Vouchers::quote($buyer, 'knowledge', 50000, ['voucher_codes' => [$loyaltyCode]]));

    $input = ['voucher_codes' => [$common, $loyaltyCode, $offers['study']['code']],
        'voucher_referral' => $partner['code'], 'voucher_expected_amount' => 185000];
    $quote = Vouchers::quote($buyer, 'knowledge', 300000, $input);
    expectVoucher($quote['total'] === 185000 && count($quote['discounts']) === 4, 'Four voucher types did not stack at the advertised amount.');
    $skipped = Vouchers::quote($buyer, 'knowledge', 300000, ['voucher_skip_referral' => true] + $input);
    expectVoucher($skipped['total'] === 200000 && (int)$skipped['partner']['id'] === $partner['id'], 'Opting out removed referral attribution.');
    $outsideReferral = Vouchers::quote($buyer, 'exam_solution', 300000, ['voucher_referral' => $partner['code']]);
    expectVoucher(!$outsideReferral['discounts'] && $outsideReferral['total'] === 300000 && $outsideReferral['partner'],
        'Following an affiliate link applied a voucher to an out-of-scope course.');
    $small = Vouchers::quote($buyer, 'knowledge', 9999, ['voucher_referral' => $partner['code']]);
    expectVoucher($small['total'] === 9999 && $small['partner'], 'Automatic referral blocked a smaller order.');
    rejectsVoucher(fn() => Vouchers::quote($partner, 'knowledge', 300000, ['voucher_codes' => [$referral]]));
    rejectsVoucher(fn() => Vouchers::confirm($buyer, 'knowledge', 300000, ['voucher_expected_amount' => 1] + $input));

    $purchaseQuote = ['amount' => 300000, 'courses' => [['id' => 1, 'item_id' => 1]], 'package' => [
        'id' => 1, 'name' => 'Gói kiểm thử', 'list_name' => 'Voucher fixture', 'course_type' => 'knowledge',
        'duration_months' => 6, 'credit_count' => 0, 'price' => 400000,
    ]];
    $saveOrder = function ($data) use ($db, $buyer, $now) {
        return [CODE => SUCCESS, DATA => ['id' => invoiceFixture($db, $buyer, array_sum(array_column($data['items'], 'price')), $now)]];
    };
    $db->begin();
    $draft = CommercePurchases::create($buyer, $purchaseQuote, $saveOrder, [], $input);
    expectVoucher((int)$draft['amount'] === 185000, 'Order price did not carry the confirmed coupon amount.');
    $db->rollback();
    expectVoucher(!CommercePurchases::get((int)$draft['order_id']), 'Rolling back a draft left part of the order in place.');
    $draft = CommercePurchases::create($buyer, $purchaseQuote, $saveOrder, [], $input);
    $lines = (int)$db->execute("SELECT COUNT(*) FROM voucher_uses WHERE order_source='order' AND order_id=?", [$draft['order_id']])->fetchColumn(0);
    $paidTotal = (int)$db->execute('SELECT total FROM orders WHERE id=?', [$draft['order_id']])->fetchColumn(0);
    $attribution = $db->execute('SELECT affiliateCode FROM orders WHERE id=?', [$draft['order_id']])->fetchColumn(0);
    expectVoucher($lines === 4 && $paidTotal === 185000 && $attribution === $partner['code'], 'Invoice snapshot, ledger or partner was lost.');
    rejectsVoucher(fn() => Vouchers::quote($buyer, 'knowledge', 300000, $input));
    expectVoucher(!Vouchers::personalOffers($buyer, 'knowledge', $now), 'Redeemed personal codes returned as available.');
    expectVoucher(!Vouchers::personalOffers($buyer, 'knowledge', $now, true), 'A used study voucher was offered for claim again.');
    echo "voucher checkout: 4 types, course scopes, confirmation dates, accurate totals, retry rollback and single use passed\n";
} finally {
    $db->rollback();
}
