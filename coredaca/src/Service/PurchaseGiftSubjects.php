<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Utility\Text;

/** Stable subject keys shared by Academy gifts, Library documents and public exam courses. */
final class PurchaseGiftSubjects
{
    private const ALIASES = [
        'giai-phau-hoc' => 'giai-phau',
        'giai-phau-1-2' => 'giai-phau',
        'giai-phau-noi-tru' => 'giai-phau',
        'sinh-ly-hoc' => 'sinh-ly',
        'sinh-ly-1-2' => 'sinh-ly',
        'sinh-ly-noi-tru' => 'sinh-ly',
        'hoa-sinh-noi-tru' => 'hoa-sinh',
        'sinh-hoc' => 'sinh-hoc-di-truyen',
        'sinh-ly-benh-md' => 'sinh-ly-benh-mien-dich',
        'mo-hoc-phoi-thai-hoc' => 'mo-phoi',
        'phoi-thai-hoc' => 'mo-phoi',
        'ky-sinh-trung-y-hoc' => 'ky-sinh-trung',
        'vi-sinh' => 'vi-sinh-hoc',
        'duoc-ly' => 'duoc-ly-hoc',
        'duoc-ly-ly-thuyet' => 'duoc-ly-hoc',
        'duoc-ly-lam-sang' => 'duoc-lam-sang',
        'thong-ke-y-hoc' => 'xac-suat-thong-ke-y-hoc',
        'tieng-anh-y-khoa-1-2' => 'tieng-anh-y-khoa',
        'tieng-anh-chuyen-nganh' => 'tieng-anh-y-khoa',
        'tieng-anh-giao-tiep-y-khoa-trong-benh-vien' => 'tieng-anh-y-khoa',
        'lam-sang-noi-khoa' => 'noi-khoa',
        'noi-khoa-co-y-nhi' => 'noi-khoa',
        'noi-khoa-noi-tru' => 'noi-khoa',
        'noi-lam-sang-chuyen-sau-dgnl' => 'noi-khoa',
        'lam-sang-ngoai-khoa' => 'ngoai-khoa',
        'ngoai-khoa-noi-tru' => 'ngoai-khoa',
        'ngoai-lam-sang-chuyen-sau-dgnl' => 'ngoai-khoa',
        'lam-sang-san-khoa' => 'san-phu-khoa',
        'san-khoa' => 'san-phu-khoa',
        'lam-sang-nhi-khoa' => 'nhi-khoa',
        'nhi-khoa-noi-tru' => 'nhi-khoa',
        'ngoai-co-so-ngoai-trieu-chung' => 'ngoai-co-so',
        'ly-thuyet-lam-sang-ecg' => 'ecg',
        'dieu-duong' => 'dieu-duong-co-ban',
    ];

    public static function key(string $label): ?string
    {
        $label = preg_replace('/^(?:Năm\s*[1-6]|Y\s*[1-6](?:\s*[-–—]\s*Y\s*[1-6])?)\b[\s:–—-]*/iu', '', trim($label));
        $key = Text::slug(mb_strtolower($label ?? '', 'UTF-8'), '-');
        if (!$key || in_array($key, ['tai-lieu-khac', 'tai-lieu-y-khoa', 'tai-lieu-hoc-tap'], true)) return null;
        return self::ALIASES[$key] ?? $key;
    }

    public static function courseLabel(string $name): string
    {
        if (preg_match('/^\[([^\]]+)\]/u', trim($name), $match)) return trim($match[1]);
        $name = preg_replace('/\s*[\[(]?\s*Cơ Bản\s*[-–—>]+\s*Chuyên Sâu.*$/iu', '', trim($name));
        return trim($name ?? '');
    }

    /** Only public subjects with published questions can start a gift term. */
    public static function quizCatalog(bool $readyOnly = true): array
    {
        $sql =
            "SELECT p.id, pc.name FROM products p
             JOIN products_content pc ON pc.product_id=p.id AND pc.lang='vi'
             JOIN links l ON l.id=(SELECT MAX(latest.id) FROM links latest WHERE latest.foreign_id=p.id
                 AND latest.lang='vi' AND latest.type='product_detail' AND latest.deleted=0)
             WHERE p.course_kind='quiz' AND p.deleted=0 AND p.status=1 AND COALESCE(p.draft,0)=0";
        if ($readyOnly) {
            $sql .= " AND EXISTS (SELECT 1 FROM course_quiz_slots slot
                 STRAIGHT_JOIN quizs quiz ON quiz.id=slot.quiz_id AND quiz.status=1 AND quiz.deleted=0
                     AND COALESCE(quiz.draft,0)=0 AND COALESCE(quiz.fa_only,0)=0
                 STRAIGHT_JOIN quizs_attribute questions ON questions.quiz_id=quiz.id AND questions.attribute_id=18
                 WHERE slot.product_id=p.id AND CASE WHEN JSON_VALID(questions.value)
                     THEN JSON_TYPE(questions.value)='ARRAY' AND JSON_LENGTH(questions.value)>0 ELSE 0 END)";
        }
        $rows = CommercePurchases::db()->execute($sql . ' ORDER BY pc.name,p.id')->fetchAll('assoc');

        $catalog = [];
        foreach ($rows as $row) {
            $key = self::key($row['name']);
            if ($key === null) continue;
            $id = (int)$row['id'];
            $catalog[$id] = ['id'=>$id, 'name'=>$row['name'], 'subject_key'=>$key];
        }
        return $catalog;
    }

    public static function matchingQuiz(array $catalog, ?string $key): ?array
    {
        if ($key === null) return null;
        $matches = array_filter($catalog, static function (array $quiz) use ($key): bool {
            return $quiz['subject_key'] === $key;
        });
        return count($matches) === 1 ? reset($matches) : null;
    }

    public static function forShopProduct(int $product): int
    {
        return (int)CommercePurchases::db()->execute(
            'SELECT quiz_product_id FROM purchase_gift_products WHERE product_id=?', [$product]
        )->fetchColumn(0);
    }

    public static function assignShopProduct(int $product, int $quiz): void
    {
        $db = CommercePurchases::db();
        if (!$quiz) {
            $db->delete('purchase_gift_products', ['product_id'=>$product]);
            return;
        }
        if (CourseTypes::kind($quiz) !== 'quiz') {
            throw new \InvalidArgumentException('Môn Đề thi tặng kèm không còn khả dụng.');
        }
        $db->execute(
            'INSERT INTO purchase_gift_products (product_id,quiz_product_id) VALUES (?,?)
             ON DUPLICATE KEY UPDATE quiz_product_id=VALUES(quiz_product_id)', [$product,$quiz]
        );
    }

    public static function forShopOrders(array $orderIds): array
    {
        if (!$orderIds) return [];
        $placeholders = implode(',', array_fill(0, count($orderIds), '?'));
        $rows = CommercePurchases::db()->execute(
            "SELECT DISTINCT i.order_id,m.quiz_product_id FROM orders_item i
             JOIN purchase_gift_products m ON m.product_id=i.product_id WHERE i.order_id IN ($placeholders)", $orderIds
        )->fetchAll('assoc');
        $byOrder = [];
        foreach ($rows as $row) $byOrder[(int)$row['order_id']][] = (int)$row['quiz_product_id'];
        return $byOrder;
    }
}
