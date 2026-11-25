<?php
declare(strict_types=1);

use App\Service\CommercePurchases as Purchases;
use App\Service\DocumentCredits;
use App\Service\DocumentDownloads;
use App\Service\OrderPayments;
use App\Service\PurchaseGifts;
use App\Service\PurchaseGiftSubjects;
use App\Service\ShopOrders;
use Cake\ORM\TableRegistry;

if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
if (getenv('MEDUC_VOUCHER_TEST_DB') !== DB_NAME) throw new RuntimeException('Select an isolated fixture database.');
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
if (!defined('LANGUAGE')) define('LANGUAGE', 'vi');
if (!defined('CDN_URL')) define('CDN_URL', 'https://cdn.meduc.vn');

function giftCheck(bool $passed, string $description): void
{
    if (!$passed) throw new RuntimeException($description);
}

function giftReject(callable $action, string $description): void
{
    try {
        $action();
    } catch (InvalidArgumentException $error) {
        return;
    }
    throw new RuntimeException($description);
}

$db = Purchases::db();
$db->enableSavePoints(true);
$db->begin();
try {
    $insert = static function (string $table, array $values) use ($db): int {
        $db->insert($table, $values);
        return (int)$db->execute('SELECT LAST_INSERT_ID()')->fetchColumn(0);
    };
    $buyer = static function () use ($insert): array {
        $code = bin2hex(random_bytes(5));
        $customer = ['full_name'=>'Khách kiểm thử','email'=>$code . '@example.invalid',
            'code'=>$code,'phone'=>'0912345678','status'=>1,'deleted'=>0,'created'=>time()];
        return ['id'=>$insert('customers',$customer)] + $customer;
    };
    $product = static function (?string $kind, string $name, string $slug, bool $questions = false, int $category = 50) use ($db,$insert): array {
        $id = $insert('products', ['course_kind'=>$kind,'main_category_id'=>$category,'status'=>1,'draft'=>0,'deleted'=>0,'created'=>time()]);
        $item = $insert('products_item',['product_id'=>$id,'code'=>'gift-'.$slug,'price'=>100000,'status'=>1,'deleted'=>0,'position'=>1]);
        $db->insert('products_content', ['product_id'=>$id,'lang'=>'vi','name'=>$name]);
        $db->insert('links', ['foreign_id'=>$id,'type'=>PRODUCT_DETAIL,'lang'=>'vi','url'=>$slug,'deleted'=>0]);
        $db->insert('categories_product', ['product_id'=>$id,'category_id'=>$category]);
        if ($kind === 'quiz') {
            $q = $insert('quizs', ['status'=>1,'draft'=>0,'deleted'=>0,'fa_only'=>0,'course_only'=>1]);
            $db->insert('course_quiz_slots', ['product_id'=>$id,'lesson_code'=>'fixture','slot'=>2,'quiz_id'=>$q]);
            $db->insert('quizs_attribute', ['quiz_id'=>$q,'attribute_id'=>18,'value'=>$questions?'[{"name":"Câu mẫu"}]':'[]']);
        }
        return ['id'=>$id,'item_id'=>$item,'name'=>$name];
    };
    [$anatomy,$chemistry,$biochemistry,$physiology] = [
        $product('knowledge','[Giải Phẫu 1, 2] Cơ Bản -> Chuyên Sâu','course-anatomy'),
        $product('knowledge','Hoá Học [Cơ Bản -> Chuyên Sâu]','course-chemistry'),
        $product('knowledge','Hoá sinh','course-biochemistry'),
        $product('knowledge','[Sinh Lý 1, 2] Cơ Bản -> Chuyên Sâu','course-physiology'),
    ];
    [$qa,$qc,$qb,$qp,$unrelated,$fa] = [
        $product('quiz','Giải phẫu học','quiz-anatomy',true)['id'],
        $product('quiz','Hóa học','quiz-chemistry',true)['id'],
        $product('quiz','Hóa sinh','quiz-biochemistry',true)['id'],
        $product('quiz','Sinh lý học','quiz-physiology')['id'],
        $product('quiz','Giải phẫu bệnh','quiz-pathology',true)['id'],
        $product('fa','Riêng cho admin','quiz-private')['id'],
    ];
    $book = $product(null,'Sách Giải phẫu','gift-book',false,79);
    $equipment = $product(null,'Thiết bị','gift-equipment',false,80);
    $blouse = $product(null,'Áo blouse','gift-blouse',false,997);
    PurchaseGiftSubjects::assignShopProduct($book['id'],$qa);
    giftReject(fn() => PurchaseGiftSubjects::assignShopProduct($equipment['id'],$fa), 'Fa was selectable as a Shop gift.');

    $saveOrder = static function (array $payload) use ($db,$insert): array {
        $amount = array_sum(array_map(static function (array $row) { return $row['quantity'] * $row['price']; }, $payload['items']));
        $amount -= $payload['discount_value'] ?? 0;
        $id = $insert('orders',['code'=>'GIFT-'.bin2hex(random_bytes(5)), 'type'=>ORDER,'source'=>WEBSITE,
            'status'=>$payload['status'],'total'=>$amount,'count_items'=>count($payload['items']),'created'=>time(),'deleted'=>0]);
        $db->insert('orders_contact', ['order_id'=>$id] + $payload['contact']);
        foreach ($payload['items'] as $item) $db->insert('orders_item',['order_id'=>$id] + $item);
        return [CODE=>SUCCESS, DATA=>['id'=>$id]];
    };
    $savePayment = static function (array $payment, ?int $id=null) use ($db,$insert): array {
        if ($id) $db->update('payments',$payment,['id'=>$id]);
        else $id = $insert('payments',$payment);
        return [CODE=>SUCCESS,DATA=>['id'=>$id]];
    };
    $create = static function (array $owner, string $kind, array $courses, int $months, int $credits = 0) use ($saveOrder): array {
        $package = ['id'=>1,'course_type'=>$kind,'name'=>'Kiểm thử','list_name'=>'Kiểm thử','price'=>100000,
            'duration_months'=>$months,'credit_count'=>$credits];
        return Purchases::create($owner,['package'=>$package,'courses'=>$courses,'amount'=>100000],$saveOrder);
    };
    $approve = static function (array $order) use ($savePayment): array {
        OrderPayments::approve((int)$order['order_id'],$savePayment,1);
        return Purchases::get((int)$order['order_id']);
    };
    $access = static function (int $buyer): array {
        return TableRegistry::get('CourseEnrollments')->activeCourses($buyer);
    };

    $one = $buyer();
    $id = $one['id'];
    $anatomyQuiz = ['id'=>$qa,'item_id'=>(int)$db->execute('SELECT id FROM products_item WHERE product_id=?',[$qa])->fetchColumn(0),'name'=>'Giải phẫu học'];
    $subscription = $approve($create($one,'quiz',[$anatomyQuiz],1));
    $course = $create($one,'knowledge',[$anatomy],36);
    $savePayment(['foreign_id'=>$course['order_id'],'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$id,
        'type'=>1,'amount'=>20000,'payment_method'=>BANK,'status'=>1]);
    Purchases::syncOrder((int)$course['order_id']);
    giftCheck(DocumentCredits::balance($id) === 0 && (int)$access($id)[$qa]['expires_at'] === (int)$subscription['expires_at'],
        'Partial payment issued a gift.');
    $course = $approve($course);
    $expected = Purchases::addMonths((int)$subscription['expires_at'],3);
    giftCheck(DocumentCredits::balanceForDocument($id,'giai-phau') === 5 && DocumentCredits::balanceForDocument($id,'giai-phau-benh') === 0,
        'Course credits crossed subjects.');
    giftCheck((int)$access($id)[$qa]['expires_at'] === $expected && !isset($access($id)[$unrelated]), 'Quiz gift did not extend only the matching subject.');
    $approve($course);
    giftCheck(DocumentCredits::balance($id) === 5 && (int)$access($id)[$qa]['expires_at'] === $expected, 'Repeated approval duplicated a gift.');

    $article = $insert('articles',['status'=>1,'draft'=>0,'deleted'=>0,'main_category_id'=>48,
        'files'=>'["https://meduc.vn/cdn/media/fixture.pdf"]','created'=>time()]);
    $db->insert('articles_content',['article_id'=>$article,'lang'=>'vi','name'=>'[Năm 1 - Giải Phẫu] Tài liệu kiểm thử']);
    $db->insert('categories_article',['article_id'=>$article,'category_id'=>48]);
    $db->insert('links',['foreign_id'=>$article,'type'=>ARTICLE_DETAIL,'lang'=>'vi','url'=>'document-gift-fixture','deleted'=>0]);
    $file = (new DocumentDownloads('vi'))->quote($article,0);
    giftCheck($file['subject_key'] === 'giai-phau', 'A Library document did not resolve to the matching Academy subject.');
    giftReject(fn() => DocumentCredits::issue($id,['subject_key'=>'giai-phau-benh']+$file), 'A related but different subject used the gift.');
    $ticket = basename(DocumentCredits::issue($id,$file)['url']);
    giftCheck(DocumentCredits::balance($id) === 5 && !DocumentCredits::ticket($ticket,$id+90000), 'Coupon was charged on ticket issue or shared with another buyer.');
    DocumentCredits::consume($ticket,$id);
    DocumentCredits::consume($ticket,$id);
    giftCheck(DocumentCredits::balance($id) === 4 && DocumentCredits::ticket($ticket,$id), 'Download retry charged twice or lost the ticket.');
    $db->update('orders',['status'=>CANCEL],['id'=>(int)$course['order_id']]);
    Purchases::syncOrder((int)$course['order_id']);
    giftCheck(DocumentCredits::balance($id) === 0 && !DocumentCredits::ticket($ticket,$id) &&
        (int)$access($id)[$qa]['expires_at'] === (int)$subscription['expires_at'], 'Cancellation removed a paid plan or left a gift active.');

    $downloadSku = $product(null,'Lượt tải','download-pack');
    $db->update('products',['status'=>0,'draft'=>1],['id'=>$downloadSku['id']]);
    $db->update('products_item',['code'=>'MEDUC_DOCUMENT_DOWNLOAD'],['id'=>$downloadSku['item_id']]);
    $documentPurchase = $approve($create($one,'document',[],0,1));
    $downloadToken = basename(DocumentCredits::issue($id,['subject_key'=>'giai-phau-benh']+$file)['url']);
    DocumentCredits::consume($downloadToken,$id);
    $charge = DocumentCredits::ticket($downloadToken,$id);
    giftCheck($charge && !$charge['gift_id'] && (int)$charge['grant_order_id'] === (int)$documentPurchase['order_id']
        && DocumentCredits::balance($id) === 0, 'A purchased credit no longer worked for any subject.');

    foreach ([[$anatomy,$chemistry],[$anatomy,$chemistry,$biochemistry,$physiology]] as $courses) {
        $owner = $buyer();
        $bundle = $approve($create($owner,'knowledge',$courses,36));
        giftCheck(DocumentCredits::balance($owner['id']) === 5 * count($courses), 'Combo credit count failed.');
        $enrolled = $access($owner['id']);
        giftCheck(isset($enrolled[$qa],$enrolled[$qc]) && !isset($enrolled[$unrelated]), 'Combo quiz coverage failed.');
        if (count($courses) === 4) {
            giftCheck(isset($enrolled[$qb]) && !isset($enrolled[$qp]), 'A placeholder subject started its term.');
            $pending = PurchaseGifts::pendingQuizGifts($owner['id']);
            giftCheck(count($pending) === 1 && !$pending[0]['choices'], 'The unpublished subject gift was not retained.');
            $db->execute("UPDATE quizs_attribute SET value='[{}]' WHERE attribute_id=18 AND quiz_id IN
                (SELECT quiz_id FROM course_quiz_slots WHERE product_id=?)",[$qp]);
            giftReject(fn() => PurchaseGifts::activateQuiz($owner['id'],$pending[0]['id'],$unrelated), 'Course claim accepted the wrong subject.');
            PurchaseGifts::activateQuiz($owner['id'],$pending[0]['id'],$qp);
            giftCheck(isset($access($owner['id'])[$qp]), 'The held course gift did not activate when the subject was published.');
        }
    }
    $examSolution = $product('exam_solution','Hoá sinh','solution-biochemistry');
    $solutionBuyer = $buyer();
    $approve($create($solutionBuyer,'exam_solution',[$examSolution],36));
    giftCheck(DocumentCredits::balance($solutionBuyer['id']) === 5 && isset($access($solutionBuyer['id'])[$qb]),
        'An Academy exam solution course did not receive its subject gift.');

    $shopBuyer = $buyer();
    $sameOrder = static function (array $owner, array $items, string $method) use ($saveOrder,$savePayment): array {
        return ShopOrders::place($owner, ['payment'=>$method,'cartId'=>'MEDUC'.random_int(100000000,999999999),
            'cartProducts'=>json_encode($items),'cartTotal'=>100000 * array_sum(array_column($items,'quantity')),
            'full_name'=>$owner['full_name'],'phone'=>$owner['phone'],'address'=>'Địa chỉ kiểm thử, Huế'], $saveOrder,$savePayment);
    };
    $order = $sameOrder($shopBuyer,[['id'=>$book['item_id'],'quantity'=>2]],COD);
    giftCheck(DocumentCredits::balance($shopBuyer['id']) === 0 && !$access($shopBuyer['id']), 'An unpaid COD order gave a gift.');
    $paidShop = $approve($order);
    giftCheck(DocumentCredits::balanceForDocument($shopBuyer['id'],'giai-phau-benh') === 3 &&
        (int)$access($shopBuyer['id'])[$qa]['expires_at'] === Purchases::addMonths((int)$paidShop['approved_at'],1),
        'Shop quantity multiplied the credits or configured subject did not open for one month.');
    $approve($order);
    giftCheck(DocumentCredits::balance($shopBuyer['id']) === 3, 'Repeated Shop confirmation paid out twice.');
    $other = $sameOrder($shopBuyer,[['id'=>$equipment['item_id'],'quantity'=>1]],BANK);
    $approve($other);
    $pending = PurchaseGifts::pendingQuizGifts($shopBuyer['id']);
    giftCheck(count($pending) === 1 && !$pending[0]['choices'] && DocumentCredits::balance($shopBuyer['id']) === 6,
        'Unconfigured Shop product lost the one-month gift or the three shared credits.');
    PurchaseGiftSubjects::assignShopProduct($equipment['id'],$qc);
    $giftId = $pending[0]['id'];
    giftReject(fn() => PurchaseGifts::activateQuiz($id,$giftId,$qc), 'Claim accepted another account.');
    giftReject(fn() => PurchaseGifts::activateQuiz($shopBuyer['id'],$giftId,$unrelated), 'Shop claim accepted an unconfigured subject.');
    PurchaseGifts::activateQuiz($shopBuyer['id'],$giftId,$qc);
    $expiry = $access($shopBuyer['id'])[$qc]['expires_at'];
    PurchaseGifts::activateQuiz($shopBuyer['id'],$giftId,$qc);
    giftCheck($access($shopBuyer['id'])[$qc]['expires_at'] === $expiry, 'Repeated Shop claim extended the term.');
    $multi = $approve($sameOrder($shopBuyer,[['id'=>$book['item_id'],'quantity'=>1],['id'=>$equipment['item_id'],'quantity'=>1]],COD));
    $choices = PurchaseGifts::pendingQuizGifts($shopBuyer['id']);
    giftCheck(count($choices) === 1 && count($choices[0]['choices']) === 2 && DocumentCredits::balance($shopBuyer['id']) === 9,
        'A multi-product Shop order did not offer one choice among its related subjects.');
    PurchaseGifts::activateQuiz($shopBuyer['id'],$choices[0]['id'],$qa);
    giftReject(fn() => PurchaseGifts::activateQuiz($shopBuyer['id'],$choices[0]['id'],$qc), 'A multi-product Shop order opened a second subject.');
    $savePayment(['foreign_id'=>$multi['order_id'],'foreign_type'=>ORDER,'object_type'=>CUSTOMER,'object_id'=>$shopBuyer['id'],
        'type'=>0,'amount'=>$multi['amount'],'payment_method'=>COD,'status'=>1]);
    giftCheck(DocumentCredits::balance($shopBuyer['id']) === 6 &&
        (int)$access($shopBuyer['id'])[$qa]['expires_at'] === Purchases::addMonths((int)$paidShop['approved_at'],1),
        'Refunding a Shop order did not remove its benefits.');
    PurchaseGiftSubjects::assignShopProduct($blouse['id'],$qb);
    $approve($sameOrder($shopBuyer,[['id'=>$blouse['item_id'],'quantity'=>1]],COD));
    giftCheck(DocumentCredits::balance($shopBuyer['id']) === 9 && isset($access($shopBuyer['id'])[$qb]),
        'A blouse purchase did not receive its configured Shop gifts.');
    echo "Purchase gifts: course and combos, scoped credits, stacked quiz access, refunds, COD and configurable Shop gifts passed.\n";
} finally {
    $db->rollback();
}
