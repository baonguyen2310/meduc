<?php
/** Read-only checks for payment-recipient routing against the current catalogue. */
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
$app = new App\Application($root . '/coredaca/config');
$app->bootstrap();
if (!defined('LANGUAGE')) define('LANGUAGE', 'vi');
if (!defined('CODE_TEMPLATE')) define('CODE_TEMPLATE', 'app01');
if (!defined('CURRENCY_UNIT')) define('CURRENCY_UNIT', 'đ');

use App\View\Helper\CheckoutHelper;
use Cake\ORM\TableRegistry;
use Cake\View\View;

function expectBank($condition, string $message): void
{
    if (!$condition) throw new RuntimeException($message);
}
class PaymentBankView extends App\View\SmartyView
{
    public function payment(array $data): string
    {
        return $this->_render(SOURCE_DOMAIN . '/templates/app01/Order/meduc_payment.tpl', $data);
    }
}
$helper = new CheckoutHelper(new View());
$legacy = TableRegistry::get('PaymentsGateway')->getList(LANGUAGE)['bank']['config'][0];
$old = $helper->bank();
expectBank($old['account_number'] === $legacy['account_number'] && $old['account_holder'] === $legacy['account_holder'] &&
    $old['qr_file'] === 'bank-qr.jpg', 'Default/course bank account changed.');
foreach (['book', 'document', 'quiz'] as $purpose) {
    $bank = $helper->bank($purpose);
    expectBank($bank['account_number'] === '109886529080' && $bank['account_holder'] === 'HO KINH DOANH NHA SACH MEDUCBO' &&
        $bank['qr_file'] === 'bank-qr-meducbo-vietqr.png', 'Incorrect bank for ' . $purpose);
    $size = getimagesize($root . '/templates/app01/assets/meduc-v2/payment/' . $bank['qr_file']);
    expectBank($size && $size[0] === $bank['qr_width'] && $size[1] === $bank['qr_height'], 'QR metadata differs from the supplied image.');
}
$ids = [];
foreach (['knowledge', 'exam_solution', 'quiz'] as $kind) {
    $product = TableRegistry::get('Products')->find()->select(['id'])->where(['course_kind' => $kind, 'deleted' => 0])->first();
    expectBank($product, 'Missing catalogue control: ' . $kind);
    $ids[$kind] = (int)$product['id'];
    $bank = $helper->bank('order', ['items' => [['product_id' => $ids[$kind]]]]);
    $expected = $kind === 'quiz' ? '109886529080' : $legacy['account_number'];
    expectBank($bank['account_number'] === $expected, 'Incorrect invoice bank for ' . $kind);
}
$book = TableRegistry::get('CategoriesProduct')->find()->select(['product_id'])->where(['category_id' => 79])->first();
expectBank($book, 'Missing book catalogue control.');
$bank = $helper->bank('order', ['items' => [['product_id' => (int)$book['product_id']]]]);
expectBank($bank['account_number'] === '109886529080', 'Book invoice used the course account.');
foreach ([[], ['items' => [['product_id' => 2147483647]]],
    ['items' => [['product_id' => $ids['knowledge']], ['product_id' => $ids['quiz']]]]] as $order) {
    expectBank($helper->bank('order', $order)['account_number'] === $legacy['account_number'], 'Unknown/course invoice lost the existing account.');
}
$cases = [['book', [], true], ['document', [], true],
    ['order', ['items' => [['product_id' => $ids['quiz']]]], true],
    ['order', ['items' => [['product_id' => $ids['knowledge']]]], false],
    ['order', ['items' => [['product_id' => $ids['exam_solution']]]], false]];
foreach ($cases as [$purpose, $order, $bookstore]) {
    $view = new PaymentBankView();
    $view->loadHelper('Checkout');
    $html = $view->payment(['payment_purpose' => $purpose, 'order_info' => $order, 'payment_reference' => 'PAYMENT CHECK', 'allow_cod'=>$purpose==='book']);
    expectBank((strpos($html, 'id="qr-cod-tab"') !== false) === ($purpose==='book'), 'COD shown outside book checkout.');
    $number = $bookstore ? '109886529080' : $legacy['account_number'];
    $file = $bookstore ? 'bank-qr-meducbo-vietqr.png' : 'bank-qr.jpg';
    expectBank(strpos($html, '<strong>' . $number . '</strong>') !== false && strpos($html, 'data-copy="' . $number . '"') !== false &&
        substr_count($html, '/payment/' . $file . '"') === 2, 'Rendered bank text, copy action and QR disagree.');
    expectBank((strpos($html, 'mco-qr-panel--compact') !== false) === $bookstore, 'Compact QR layout leaked into the original course payment.');
    expectBank((stripos($html, 'momo') === false) === $bookstore, 'MoMo visibility does not match the payment type.');
    expectBank(strpos($html, 'role="tablist"') !== false && strpos($html, 'role="tabpanel"') !== false, 'Payment tabs have an invalid relationship.');
}
echo json_encode(['passed' => ['legacy_course_account_preserved', 'books_documents_quiz_use_meducbo',
    'knowledge_and_solution_invoices_preserved', 'quiz_and_book_invoices_routed', 'supplied_qr_dimensions_match',
    'unknown_and_course_invoices_keep_existing_account', 'rendered_account_copy_and_qr_match', 'momo_removed_from_books_documents_quiz_only'], 'database_writes' => 0], JSON_PRETTY_PRINT) . "\n";
