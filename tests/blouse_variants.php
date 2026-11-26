<?php
/**
 * Shop quotes for blouse variants and name embroidery. Read-only: BookCheckout::quote never writes.
 * Needs a database that has run scripts/blouse_variants.sql and holds at least one blouse SKU with a
 * price and stock, on a product whose "phi_theu_ten" is set, plus one book on sale.
 *   php tests/blouse_variants.php --fixtures
 */
declare(strict_types=1);

use App\Lib\BlouseProducts;
use App\Lib\BookCheckout;

if (PHP_SAPI !== 'cli' || ($argv[1] ?? '') !== '--fixtures') exit(1);
$root = dirname(__DIR__);
define('SOURCE_DOMAIN', $root);
require $root . '/config_database.php';
require $root . '/coredaca/vendor/autoload.php';
(new App\Application($root . '/coredaca/config'))->bootstrap();
if (!defined('LANGUAGE')) define('LANGUAGE', 'vi');
if (!defined('CDN_URL')) define('CDN_URL', 'https://example.invalid');

$failures = 0;
function check(bool $ok, string $reason): void
{
    global $failures;
    echo ($ok ? 'ok   ' : 'FAIL ') . $reason . "\n";
    if (!$ok) $failures++;
}
function rejects(callable $action, string $reason): void
{
    try {
        $action();
    } catch (InvalidArgumentException $error) {
        check(true, $reason . ' (' . $error->getMessage() . ')');
        return;
    }
    check(false, $reason);
}

$catalog = BookCheckout::catalog();
$embroidered = $plain = $book = null;
foreach ($catalog as $id => $item) {
    $isBlouse = strpos((string)$item['name'], 'Size ') !== false;
    if ($isBlouse && ($item['embroidery_fee'] ?? 0) > 0 && ($item['maximum'] ?? 0) >= 2 && !$embroidered) $embroidered = $item;
    if ($isBlouse && empty($item['embroidery_fee']) && ($item['maximum'] ?? 0) >= 1 && !$plain) $plain = $item;
    if (!$isBlouse && !isset($item['maximum']) && !$book) $book = $item;
}
check((bool)$embroidered, 'catalog has a blouse SKU that offers embroidery');
check((bool)$book, 'catalog has a book on sale');
if (!$embroidered || !$book) exit(1);
$fee = (float)$embroidered['embroidery_fee'];
check((bool)preg_match('/\(.+ · Size [^)]+\)$/u', $embroidered['name']), 'variant name lists every chosen option: ' . $embroidered['name']);

$quote = BookCheckout::quote([
    ['id' => $embroidered['id'], 'quantity' => 1, 'embroidery' => "  BS.  Nguyễn\tVăn A "],
    ['id' => $embroidered['id'], 'quantity' => 1],
    ['id' => $book['id'], 'quantity' => 2],
]);
check(count($quote) === 3, 'one SKU can appear with and without a name');
check($quote[0]['embroidery'] === 'BS. Nguyễn Văn A', 'embroidery text is trimmed and spaces collapsed');
check(abs($quote[0]['total'] - ($embroidered['price_special'] + $fee)) < 0.001, 'embroidered line adds the fee per shirt');
check(abs($quote[1]['total'] - $embroidered['price_special']) < 0.001 && empty($quote[1]['embroidery']), 'line without a name has no fee');
check(substr($quote[0]['name'], -strlen('“BS. Nguyễn Văn A”')) === '“BS. Nguyễn Văn A”', 'saved line name shows the name to embroider');
check(abs($quote[2]['total'] - 2 * $book['price_special']) < 0.001 && (float)$quote[2]['embroidery_fee'] === 0.0, 'book price is unchanged');
$decomposed = class_exists('Normalizer') ? Normalizer::normalize('Nguyễn', Normalizer::FORM_D) : 'Nguyễn';
check(BlouseProducts::embroideryText($decomposed) === 'Nguyễn', 'decomposed Vietnamese input is stored composed');

rejects(function () use ($book) { BookCheckout::quote([['id' => $book['id'], 'quantity' => 1, 'embroidery' => 'An']]); }, 'book cannot be embroidered');
if ($plain) rejects(function () use ($plain) { BookCheckout::quote([['id' => $plain['id'], 'quantity' => 1, 'embroidery' => 'An']]); }, 'blouse without a fee cannot be embroidered');
rejects(function () use ($embroidered) { BookCheckout::quote([['id' => $embroidered['id'], 'quantity' => 1, 'embroidery' => '<b>An</b>']]); }, 'markup is refused');
rejects(function () use ($embroidered) { BookCheckout::quote([['id' => $embroidered['id'], 'quantity' => 1, 'embroidery' => str_repeat('A', BlouseProducts::EMBROIDERY_MAX_LENGTH + 1)]]); }, 'over-long name is refused');
rejects(function () use ($embroidered) { BookCheckout::quote([['id' => $embroidered['id'], 'quantity' => 1, 'embroidery' => ['An']]]); }, 'non-string name is refused');
rejects(function () use ($embroidered) { BookCheckout::quote([['id' => $embroidered['id'], 'quantity' => 1, 'embroidery' => 'An'], ['id' => $embroidered['id'], 'quantity' => 1, 'embroidery' => ' An ']]); }, 'the same SKU and name cannot be sent on two lines');
$stock = (int)$embroidered['maximum'];
rejects(function () use ($embroidered, $stock) { BookCheckout::quote([['id' => $embroidered['id'], 'quantity' => $stock, 'embroidery' => 'An'], ['id' => $embroidered['id'], 'quantity' => 1]]); }, 'lines of one SKU share its stock');
check(count(BookCheckout::quote([['id' => $embroidered['id'], 'quantity' => $stock - 1, 'embroidery' => 'An'], ['id' => $embroidered['id'], 'quantity' => 1]])) === 2, 'lines of one SKU may use all of its stock');

check(BlouseProducts::swatch(['code' => 'mau_5F6B58', 'name' => 'Bất kỳ']) === '#5f6b58', 'swatch reads a hex code from the option code');
check(BlouseProducts::swatch(['code' => 'blouse_x', 'name' => 'Xanh rêu']) === '#5f6b58', 'swatch falls back to a known colour name');
check(BlouseProducts::fee('35,000') === 35000.0 && BlouseProducts::fee('35000.00') === 35000.0 && BlouseProducts::fee('') === 0.0, 'fee accepts the admin number format');

echo $failures ? "\n$failures failed\n" : "\nall passed\n";
exit($failures ? 1 : 0);
