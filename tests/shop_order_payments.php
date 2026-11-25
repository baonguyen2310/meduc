<?php
/** Transactional fixtures for the shared Shop payment and affiliate workflow. */
declare(strict_types=1);

use App\Lib\BookCheckout;
use App\Service\AffiliateCommissions;
use App\Service\CommercePurchases;
use App\Service\CoursePricing;
use App\Service\OrderPayments;
use App\Service\ShopOrders;
use App\Service\Vouchers;
use Cake\Http\ServerRequest;

if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
if (!defined('LANGUAGE')) define('LANGUAGE', 'vi');
if (!defined('CDN_URL')) define('CDN_URL', 'https://example.invalid');

function checkShop(bool $ok, string $reason): void
{
    if (!$ok) throw new RuntimeException($reason);
}

function rejectShop(callable $action, string $reason): void
{
    try {
        $action();
    } catch (InvalidArgumentException $error) {
        return;
    }
    throw new RuntimeException($reason);
}

function shopCustomer($db, bool $partner = false): array
{
    $code = 'SHOP-' . bin2hex(random_bytes(6));
    $customer = [
        'code' => $code, 'full_name' => 'Kiểm thử đơn hàng', 'email' => $code . '@example.invalid',
        'phone' => '0912345678', 'status' => 1, 'deleted' => 0,
        'is_partner_affiliate' => (int)$partner, 'affiliate_percent' => $partner ? 5 : null,
        'affiliate_amount' => 0, 'affiliate_amount_unpaid' => 0, 'created' => time(),
    ];
    $db->insert('customers', $customer);
    return $customer + ['id' => (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0)];
}

class ShopFixtureResponse extends RuntimeException
{
    public $result;

    public function __construct(array $result)
    {
        parent::__construct('Fixture response');
        $this->result = $result;
    }
}

class ShopShippingFixture extends Admin\Controller\OrderController
{
    protected function responseJson($params = [])
    {
        throw new ShopFixtureResponse($params);
    }
}

$db = CommercePurchases::db();
$db->enableSavePoints(true);
$db->begin();
try {
    $owner = shopCustomer($db);
    $partner = shopCustomer($db, true);
    $other = shopCustomer($db);
    $catalog = BookCheckout::catalog();
    $book = reset($catalog);
    checkShop(is_array($book), 'Missing a sellable physical product in the fixtures.');

    $backend = new App\Controller\CoursePriceController((new ServerRequest())->withMethod('POST'));
    $save = function ($payload) use ($backend) { return $backend->loadComponent('Admin.Order')->saveOrder($payload); };
    $pay = function ($data, $id = null) use ($backend) { return $backend->loadComponent('Admin.Payment')->savePayment($data, $id); };
    $campaign = 'SHOP-REGRESSION-' . strtoupper(bin2hex(random_bytes(4)));
    $db->insert('voucher_campaigns', [
        'kind' => 'common', 'name' => 'Kiểm thử voucher Shop', 'code' => $campaign, 'scope' => 'shop',
        'discount_type' => 'amount', 'discount_value' => 1000, 'starts_at' => time()-20, 'ends_at' => time()+60,
        'active' => 1,
    ]);
    $total = (int)round($book['price_special'] * 2) - 1000;
    $base = [
        'full_name' => 'Người nhận hàng', 'phone' => '0912345678', 'address' => '20 Đường kiểm thử, Huế',
        'cartProducts' => json_encode([['id'=>$book['id'],'quantity'=>2]]), 'cartTotal' => $total,
        'voucher_codes' => [$campaign], 'voucher_referral' => $partner['code'], 'voucher_skip_referral' => '1',
        'voucher_expected_amount' => $total,
    ];
    $pendingRefund = null;
    foreach ([BANK, COD] as $method) {
        $data = $base + ['payment' => $method, 'cartId' => 'MEDUC' . random_int(100000000000,999999999999)];
        $receipt = ShopOrders::place($owner, $data, $save, $pay);
        $id = $receipt['order_id'];
        $again = ShopOrders::place($owner, $data, function () {
            throw new RuntimeException('Repeated checkout created another order.');
        }, $pay);
        checkShop($again === $receipt && $receipt['payment'] === $method, 'Checkout replay did not return the same order.');
        rejectShop(function () use ($other, $data, $save, $pay) {
            ShopOrders::place($other, $data, $save, $pay);
        }, 'Another account reused the order reference.');
        $order = $db->execute('SELECT code,total,affiliateAmount FROM orders WHERE id=?', [$id])->fetch('assoc');
        checkShop($order['code'] === $data['cartId'] && (int)$order['total'] === $total, 'Order subtotal, discount or reference changed.');
        checkShop((float)$order['affiliateAmount'] === round($total * 0.05), 'Affiliate calculated on an incorrect amount.');
        $uses = $db->execute("SELECT COUNT(*) FROM voucher_uses WHERE order_source='order' AND order_id=?", [$id])->fetchColumn(0);
        checkShop((int)$uses === 1, 'Shop voucher use was omitted or duplicated.');
        rejectShop(fn() => AffiliateCommissions::approve($id), 'Affiliate approval bypassed the confirmed payment requirement.');
        rejectShop(fn() => OrderPayments::approve($id, $pay, 1, $total+1), 'Approval accepted a stale amount.');
        $pending = (int)$db->execute("SELECT COUNT(*) FROM payments WHERE foreign_type='order' AND foreign_id=? AND status=2", [$id])->fetchColumn(0);
        checkShop($pending === ($method === BANK ? 1 : 0), 'Initial payment report incorrectly booked a COD or transfer.');
        if ($method === COD) {
            $pay(['foreign_id'=>$id,'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$owner['id'],
                'type'=>1,'amount'=>$total,'payment_method'=>COD,'status'=>2]);
            $db->insert('shippings', [
                'order_id'=>$id,'code'=>'SHIP-'.$id,'shipping_method'=>NORMAL_SHIPPING,'status'=>DELIVERY,
            ]);
            $shipping = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
            $request = (new ServerRequest())->withMethod('POST')->withParsedBody(['status'=>DELIVERED]);
            try {
                (new ShopShippingFixture($request))->shippingChangeStatus($shipping);
                throw new LogicException('Shipping controller did not respond.');
            } catch (ShopFixtureResponse $result) {
                checkShop(($result->result[CODE] ?? '') === SUCCESS, 'Tracking update failed.');
            }
            $state = OrderPayments::summaries([$id])[$id];
            checkShop($state['shipping_status'] === DELIVERED && !$state['paid'], 'Marking delivery confirmed pending COD as received cash.');
        }
        checkShop(OrderPayments::approve($id,$pay,1,$total)['paid'], 'Shop receipt did not settle the order.');
        $settled = OrderPayments::approve($id,function () {
            throw new RuntimeException('Repeated payment approval recorded another receipt.');
        },1,$total);
        checkShop($settled['paid'] && ShopOrders::receipt($id,$owner['id'])['paid'], 'Paid state is inconsistent across order and receipt.');
        $confirmed = $db->execute("SELECT payment_method FROM payments WHERE foreign_type='order' AND foreign_id=? AND status=1", [$id])->fetchAll('assoc');
        checkShop($confirmed === [['payment_method' => $method]], 'Confirmed payment method or count is incorrect.');
        AffiliateCommissions::approve($id);
        AffiliateCommissions::approve($id);
        if ($method === COD) $pendingRefund = $id;
    }
    $commission = round($total * 0.05);
    checkShop(AffiliateCommissions::payable($partner['code']) === 2.0 * $commission, 'Commission was counted more than once.');
    $pay(['foreign_id'=>$pendingRefund,'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$owner['id'],
        'type'=>0,'amount'=>1000,'payment_method'=>COD,'status'=>1]);
    checkShop(AffiliateCommissions::payable($partner['code']) === $commission, 'Refunded order remained payable.');
    rejectShop(fn() => AffiliateCommissions::settle($partner['id'], 2 * $commission), 'Payout accepted a stale amount.');
    AffiliateCommissions::settle($partner['id'], $commission);
    rejectShop(fn() => AffiliateCommissions::settle($partner['id'], $commission), 'Payout confirmation was repeated.');
    $balance = $db->execute('SELECT affiliate_amount,affiliate_amount_unpaid FROM customers WHERE id=?', [$partner['id']])->fetch('assoc');
    checkShop((float)$balance['affiliate_amount'] === 2.0 * $commission && (float)$balance['affiliate_amount_unpaid'] === $commission,
        'Payout changed historical or unverified commission.');

    $failedRef = 'MEDUC' . random_int(100000000000,999999999999);
    try {
        ShopOrders::place($owner, $base + ['payment'=>BANK,'cartId'=>$failedRef], $save, function () {
            return [CODE=>ERROR];
        });
        throw new LogicException('Failed payment report left a checkout.');
    } catch (RuntimeException $error) {
        checkShop(!ShopOrders::byReference($failedRef, $owner['id']), 'Failed payment report left part of the order committed.');
        checkShop(!(int)$db->execute('SELECT COUNT(*) FROM orders WHERE code=?', [$failedRef])->fetchColumn(0),
            'Failed payment left an orphan order.');
    }

    $form = $db->execute('SELECT id FROM contacts_form WHERE code=? AND deleted=0', [Vouchers::SHOP_FORM])->fetchColumn(0);
    $oldReference = 'MEDUC' . random_int(100000, 999999);
    $archive = [
        'orderStatus'=>'initial','payment'=>BANK,'cartId'=>$oldReference,'totalPrice'=>120000,
        'full_name'=>'Khách nhận hàng','phone'=>'0912345678','address'=>'Địa chỉ kiểm thử','email'=>'guest@example.invalid',
        'cartProducts'=>json_encode([['id'=>$book['id'],'product_id'=>$book['product_id'],'total'=>120000,'quantity'=>1]]),
    ];
    $db->insert('contacts', ['form_id'=>$form,'value'=>json_encode($archive),'created'=>time(),'deleted'=>0]);
    $archiveId = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    $import = ShopOrders::importOpenArchive($archiveId,$save);
    checkShop(ShopOrders::importOpenArchive($archiveId,$save) === $import && ShopOrders::linkedArchive($archiveId) === $import,
        'Historical order was imported twice.');
    checkShop(!OrderPayments::summaries([$import])[$import]['paid'], 'Historical checkout status invented a receipt.');
    checkShop(OrderPayments::approve($import,$pay,1,120000)['paid'], 'Imported guest order could not be reconciled.');
    $ref = $db->execute("SELECT reference FROM payments WHERE foreign_type='order' AND foreign_id=? AND status=1", [$import])->fetchColumn(0);
    checkShop($ref === $oldReference, 'Historical transfer reference was lost.');

    foreach (CoursePricing::lists(true) as $list) {
        if ($list['course_type'] !== 'knowledge') continue;
        $package = CoursePricing::packages((int)$list['id'])[0];
        $courses = array_column(array_slice(CoursePricing::courses((int)$list['id']), 0, (int)$package['course_count']), 'id');
        $quote = CoursePricing::quote((int)$package['id'], $courses);
        $course = CommercePurchases::create($owner, $quote, $save, [], [
            'voucher_referral'=>$partner['code'], 'voucher_skip_referral'=>'1',
        ]);
        $orderId = (int)$course['order_id'];
        rejectShop(fn() => AffiliateCommissions::approve($orderId), 'An unpaid course earned commission.');
        OrderPayments::approve($orderId, $pay, 1, (float)$course['amount']);
        AffiliateCommissions::approve($orderId);
        checkShop(AffiliateCommissions::payable($partner['code']) === round($course['amount'] * 0.05),
            'The same partner could not receive a verified commission from a course.');
        break;
    }
    echo "Shop checkout and shared payment: transfer, COD, receipt lookup, retries, refunds and affiliate passed\n";
} finally {
    $db->rollback(true);
}
