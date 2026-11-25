<?php
declare(strict_types=1);

namespace App\Service;

use InvalidArgumentException;

/** Benefits attached to settled invoices, independently of the purchased items. */
final class PurchaseGifts
{
    public const COURSE_DOWNLOADS = 5;
    public const COURSE_QUIZ_MONTHS = 3;
    public const SHOP_DOWNLOADS = 3;
    public const SHOP_QUIZ_MONTHS = 1;

    public static function installed(): bool
    {
        static $installed;
        if ($installed === null) {
            $installed = (bool)CommercePurchases::db()->execute("SHOW TABLES LIKE 'purchase_gifts'")->fetchColumn(0);
        }
        return $installed;
    }

    public static function courseTerms(array $quote): array
    {
        if (!in_array($quote['package']['course_type'], ['knowledge', 'exam_solution'], true)) return [];
        $records = [];
        foreach ($quote['courses'] as $course) {
            $label = PurchaseGiftSubjects::courseLabel($course['name']);
            $records[] = [
                'course_product_id'=>(int)$course['id'],
                'subject_key'=>PurchaseGiftSubjects::key($label),
                'subject_name'=>mb_substr($label, 0, 255),
                'download_credits'=>self::COURSE_DOWNLOADS,
                'quiz_months'=>self::COURSE_QUIZ_MONTHS,
            ];
        }
        return $records;
    }

    public static function shopTerms(): array
    {
        return [[
            'course_product_id'=>0, 'subject_key'=>null, 'subject_name'=>null,
            'download_credits'=>self::SHOP_DOWNLOADS, 'quiz_months'=>self::SHOP_QUIZ_MONTHS,
        ]];
    }

    /** Called from the existing payment transaction on first settlement. */
    public static function grant(array $purchase, int $settledAt): void
    {
        $owner = (int)$purchase['customer_id'];
        $terms = json_decode((string)$purchase['context_json'], true)['purchase_gifts'] ?? [];
        if (!$owner || !$terms) return;

        $orderId = (int)$purchase['order_id'];
        $shop = $purchase['kind'] === 'shop';
        $configured = $shop ? (PurchaseGiftSubjects::forShopOrders([$orderId])[$orderId] ?? []) : [];
        $catalog = !$shop || $configured ? PurchaseGiftSubjects::quizCatalog() : [];
        foreach ($terms as $term) {
            $target = 0;
            if (!$shop) {
                $target = PurchaseGiftSubjects::matchingQuiz($catalog, $term['subject_key'])['id'] ?? 0;
            } elseif (count($configured) === 1 && isset($catalog[$configured[0]])) {
                $target = $configured[0];
            }
            CommercePurchases::db()->insert('purchase_gifts', $term + [
                'order_id'=>$orderId, 'customer_id'=>$owner, 'granted_at'=>$settledAt,
                'quiz_product_id'=>$target ?: null, 'quiz_started_at'=>$target ? $settledAt : null,
            ]);
        }
    }

    private static function settledSelect(string $columns): string
    {
        return "SELECT $columns,
            p.kind,p.amount,p.customer_id,o.total order_total,o.status order_status,o.deleted order_deleted,
            c.customer_id order_customer,
            COALESCE((SELECT SUM(CASE WHEN r.type=1 THEN r.amount ELSE -r.amount END)
                FROM payments r WHERE r.foreign_id=p.order_id AND r.foreign_type='order' AND r.status=1),0) confirmed
            FROM commerce_purchases p JOIN orders o ON o.id=p.order_id
            JOIN orders_contact c ON c.order_id=o.id AND c.customer_id=p.customer_id";
    }

    private static function paidGifts(int $customer, string $columns, string $condition = '', array $params = []): array
    {
        if (!$customer || !self::installed()) return [];
        $sql = self::settledSelect($columns) . " JOIN purchase_gifts g ON g.order_id=p.order_id AND g.customer_id=p.customer_id
            WHERE g.customer_id=? AND p.approved_at IS NOT NULL AND o.deleted=0 AND o.status<>'cancel' " . $condition;
        $rows = CommercePurchases::db()->execute($sql, array_merge([$customer], $params))->fetchAll('assoc');
        return array_values(array_filter($rows, [CommercePurchases::class, 'paid']));
    }

    /** Match specific gifts before shared credits. A gift with no resolved subject cannot pay for an unrelated file. */
    public static function downloadGrants(int $customer, ?string $subject, bool $all = false): array
    {
        $condition = $all ? '' : ' AND (g.course_product_id=0 OR g.subject_key=?)';
        $rows = self::paidGifts($customer, 'g.id gift_id,g.order_id,g.course_product_id,g.subject_key,g.subject_name,
            CAST(g.download_credits AS SIGNED)-(SELECT COUNT(*) FROM document_credit_uses u WHERE u.gift_id=g.id AND u.used_at IS NOT NULL) remaining',
            $condition . ' ORDER BY (g.course_product_id=0),g.granted_at,g.id', $all ? [] : [$subject]);
        return array_values(array_filter($rows, static function (array $row): bool {
            return (int)$row['remaining'] > 0;
        }));
    }

    public static function validDownloadGrant(int $id, int $customer): bool
    {
        return (bool)self::paidGifts($customer, 'g.id', ' AND g.id=?', [$id]);
    }

    /** Combine paid quiz terms and gifts chronologically, keeping separate manual/lifetime rights intact. */
    public static function mergeQuizAccess(int $customer, array $access): array
    {
        $rows = self::paidGifts($customer, 'g.id,g.quiz_product_id product_id,g.quiz_started_at starts_at,
            g.quiz_months months,g.order_id', " AND g.quiz_started_at IS NOT NULL AND EXISTS (
                SELECT 1 FROM products quiz WHERE quiz.id=g.quiz_product_id AND quiz.course_kind='quiz'
                AND quiz.status=1 AND quiz.deleted=0 AND COALESCE(quiz.draft,0)=0)");
        if (!$rows) return $access;

        $terms = [];
        foreach ($rows as $row) $terms[(int)$row['product_id']][] = $row;
        $ids = array_keys($terms);
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $sql = self::settledSelect('p.product_id,p.approved_at starts_at,p.duration_months months,p.order_id') .
            " WHERE p.customer_id=? AND p.kind='quiz' AND p.approved_at IS NOT NULL AND o.deleted=0
              AND o.status<>'cancel' AND p.product_id IN ($placeholders)";
        foreach (CommercePurchases::db()->execute($sql, array_merge([$customer], $ids))->fetchAll('assoc') as $row) {
            if (CommercePurchases::paid($row)) $terms[(int)$row['product_id']][] = $row;
        }

        $now = time();
        foreach ($terms as $product => $events) {
            if (isset($access[$product]) && empty($access[$product]['expires_at'])) continue;
            usort($events, static function (array $a, array $b): int {
                return [(int)$a['starts_at'],(int)$a['order_id'],(int)($a['id'] ?? 0)]
                    <=> [(int)$b['starts_at'],(int)$b['order_id'],(int)($b['id'] ?? 0)];
            });
            $expiry = 0;
            foreach ($events as $event) {
                if (!$event['months']) {
                    $expiry = null;
                    break;
                }
                $expiry = CommercePurchases::addMonths(max($expiry, (int)$event['starts_at']), (int)$event['months']);
            }
            if ($expiry !== null && $expiry <= max($now, (int)($access[$product]['expires_at'] ?? 0))) continue;
            $access[$product] = [
                'id'=>(int)($access[$product]['id'] ?? 0), 'product_id'=>$product, 'source'=>'gift',
                'order_id'=>(int)$event['order_id'], 'expires_at'=>$expiry,
            ];
        }
        return $access;
    }

    public static function pendingQuizGifts(int $customer): array
    {
        $rows = self::paidGifts($customer,
            'g.id,g.order_id,o.code order_code,g.course_product_id,g.subject_key,g.subject_name,g.quiz_months',
            ' AND g.quiz_started_at IS NULL ORDER BY g.granted_at,g.id');
        if (!$rows) return [];

        $catalog = PurchaseGiftSubjects::quizCatalog();
        $shop = array_filter($rows, static function (array $row): bool { return $row['kind'] === 'shop'; });
        $configured = PurchaseGiftSubjects::forShopOrders(array_column($shop, 'order_id'));
        $result = [];
        foreach ($rows as $row) {
            $shop = $row['kind'] === 'shop';
            $choices = $shop
                ? array_intersect_key($catalog, array_fill_keys($configured[(int)$row['order_id']] ?? [], true))
                : array_filter([PurchaseGiftSubjects::matchingQuiz($catalog, $row['subject_key'])]);
            $result[] = [
                'id'=>(int)$row['id'], 'order_code'=>$row['order_code'], 'subject_name'=>$row['subject_name'],
                'months'=>(int)$row['quiz_months'], 'shop'=>$shop, 'choices'=>array_values($choices),
            ];
        }
        return $result;
    }

    public static function activateQuiz(int $customer, int $id, int $product): void
    {
        $db = CommercePurchases::db();
        $db->transactional(function () use ($db, $customer, $id, $product): void {
            $gift = $db->execute('SELECT * FROM purchase_gifts WHERE id=? AND customer_id=? FOR UPDATE', [$id,$customer])->fetch('assoc');
            $order = $gift ? CommercePurchases::get((int)$gift['order_id']) : null;
            if (!$order || !$order['approved_at'] || !CommercePurchases::paid($order)) {
                throw new InvalidArgumentException('Quà tặng không còn khả dụng.');
            }
            if ($gift['quiz_started_at']) {
                if ((int)$gift['quiz_product_id'] === $product) return;
                throw new InvalidArgumentException('Quà này đã được nhận.');
            }
            $catalog = PurchaseGiftSubjects::quizCatalog();
            $eligible = $order['kind'] === 'shop'
                ? (PurchaseGiftSubjects::forShopOrders([(int)$gift['order_id']])[(int)$gift['order_id']] ?? [])
                : [PurchaseGiftSubjects::matchingQuiz($catalog, $gift['subject_key'])['id'] ?? 0];
            if (!isset($catalog[$product]) || !in_array($product, $eligible, true)) {
                throw new InvalidArgumentException('Môn này không thuộc quà tặng của đơn.');
            }
            $db->update('purchase_gifts', ['quiz_product_id'=>$product,'quiz_started_at'=>time()], ['id'=>$id]);
        });
    }
}
