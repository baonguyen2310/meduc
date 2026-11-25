<?php
declare(strict_types=1);

use App\Service\CommercePurchases;
use App\Service\ShopOrders;
use App\Service\Vouchers;
use Cake\Http\ServerRequest;

if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
if (getenv('MEDUC_VOUCHER_TEST_DB') !== DB_NAME) throw new RuntimeException('Select an isolated fixture database.');
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();

class OrderListFixtureResponse extends RuntimeException
{
    public $result;
    public function __construct(array $result)
    {
        parent::__construct('Fixture response');
        $this->result = $result;
    }
}

class OrderListFixtureController extends Admin\Controller\OrderController
{
    public $lang = 'vi';
    protected function responseJson($params = [])
    {
        throw new OrderListFixtureResponse($params);
    }
}

function checkOrderList(bool $ok, string $reason): void
{
    if (!$ok) throw new RuntimeException($reason);
}

function readOrderList(array $filters, int $limit = 25, int $page = 1, array $sort = []): array
{
    $request = (new ServerRequest())->withMethod('POST')->withParsedBody([
        'query' => $filters + ['type'=>ORDER],
        'pagination' => ['page'=>$page,'perpage'=>$limit],
        'sort' => $sort,
    ]);
    try {
        (new OrderListFixtureController($request))->listJson();
    } catch (OrderListFixtureResponse $response) {
        checkOrderList(($response->result[CODE] ?? '') === SUCCESS, 'List did not return a successful response.');
        return $response->result;
    }
    throw new RuntimeException('List did not respond.');
}

$db = CommercePurchases::db();
$db->begin();
try {
    $shopForm = (int)$db->execute('SELECT id FROM contacts_form WHERE code=? AND deleted=0',[Vouchers::SHOP_FORM])->fetchColumn(0);
    checkOrderList($shopForm > 0, 'Shop form not installed in test database.');
    $today = strtotime('today 09:00');
    $yesterday = strtotime('-1 day', $today);
    $archive = static function (string $code,int $created,string $status) use ($db,$shopForm): int {
        $db->insert('contacts', [
            'form_id'=>$shopForm,'deleted'=>0,'created'=>$created,'search_unicode'=>'nguoi nhan cu',
            'value'=>json_encode(['cartId'=>$code,'payment'=>'bank','totalPrice'=>120000,'totalQuantity'=>2,
                'full_name'=>'Người nhận cũ','email'=>'old-checkout@example.invalid','phone'=>'0912345678',
                'orderStatus'=>$status], JSON_UNESCAPED_UNICODE),
        ]);
        return (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    };
    $first = $archive('MEDUC111111', $today, 'success');
    $second = $archive('MEDUC222222', $yesterday, 'initial');
    $legacyOnly = readOrderList(['order_kind'=>'shop']);
    checkOrderList($legacyOnly[META]['total'] === 2, 'Shop filter is empty before the first new order.');
    checkOrderList(array_column($legacyOnly[DATA], 'archive_id') === [$first,$second], 'Archived rows are not ordered by purchase time.');
    checkOrderList(!$legacyOnly[DATA][0]['payment_summary']['paid'], 'An old approval was shown as paid.');

    $current = static function (string $code, string $kind, int $date, string $oldRef = '', int $oldId = 0) use ($db): int {
        $db->insert('orders', ['code'=>$code,'type'=>ORDER,'status'=>NEW_ORDER,'deleted'=>0,'source'=>WEBSITE,'created'=>$date,'total'=>125000,'count_items'=>1]);
        $id = (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
        $db->insert('orders_contact', ['order_id'=>$id,'customer_id'=>1,'full_name'=>'Người mua mới','search_unicode'=>'nguoi mua moi']);
        $payload = ['payment_method'=>'bank'];
        if ($oldRef !== '') $payload['archive_reference'] = $oldRef;
        $db->insert('commerce_purchases', [
            'order_id'=>$id,'public_code'=>$oldId ? substr(hash('sha256',ShopOrders::ARCHIVE_CODE_PREFIX.$oldId),0,32) : bin2hex(random_bytes(16)),
            'customer_id'=>1,'kind'=>$kind,'package_id'=>0,'package_name'=>'Kiểm thử', 'amount'=>125000,
            'original_amount'=>125000,'context_json'=>json_encode($payload),'created_at'=>$date,'updated_at'=>$date,
        ]);
        return $id;
    };
    $shop = $current('MEDUC333333', 'shop', $today+60);
    $course = $current('COURSE-TEST-ORDER', 'knowledge', $today+120);
    $page1 = readOrderList(['order_kind'=>'shop'],2);
    checkOrderList($page1[META]['total'] === 3 && array_column($page1[DATA],'id') === [$shop,-$first], 'Shop pagination does not mix new and archived rows.');
    $page2 = readOrderList(['order_kind'=>'shop'],2,2);
    checkOrderList(array_column($page2[DATA],'id') === [-$second], 'Second Shop page duplicated or dropped rows.');
    $all = readOrderList([]);
    checkOrderList($all[META]['total'] === 4 && $all[DATA][0]['id'] === $course, 'All orders did not include Shop history and courses.');
    $courseFilter = readOrderList(['order_kind'=>'knowledge']);
    checkOrderList($courseFilter[META]['total'] === 1 && $courseFilter[DATA][0]['id'] === $course, 'Shop history leaked into the course filter.');

    $searched = readOrderList(['order_kind'=>'shop','keyword'=>'old-checkout@example.invalid','create_from'=>date('d/m/Y',$today)]);
    checkOrderList(array_column($searched[DATA],'id') === [-$first], 'Shop history date or keyword filter is incorrect.');
    $converted = $current('ORD-TEST-IMPORTED', 'shop', $yesterday, 'MEDUC222222', $second);
    $after = readOrderList(['order_kind'=>'shop','keyword'=>'MEDUC222222']);
    checkOrderList($after[META]['total'] === 1 && array_column($after[DATA],'id') === [$converted], 'The imported order was lost or duplicated when finding its original reference.');
    echo "Shop order list: legacy-only, mixed pages, filters, archived payment status and import dedupe passed\n";
} finally {
    $db->rollback();
}
