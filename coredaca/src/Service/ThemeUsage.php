<?php
declare(strict_types=1);
namespace App\Service;

use Cake\Datasource\ConnectionManager;

/** Latest palette per customer, or per browser until it has identified a customer. */
class ThemeUsage
{
    public static function db() { return ConnectionManager::get('default'); }

    public static function installed(): bool
    {
        static $ready;
        if ($ready === null) {
            $db = self::db();
            $ready = (bool)$db->execute("SHOW TABLES LIKE 'theme_usage_browsers'")->fetch()
                && (bool)$db->execute("SHOW TABLES LIKE 'theme_usage_customers'")->fetch();
        }
        return $ready;
    }

    public static function record(string $browserKey, string $theme, int $customerId = 0): void
    {
        if (!preg_match('/^[a-f0-9]{64}$/', $browserKey) || !in_array($theme, ['dark', 'light'], true) || $customerId < 0) {
            throw new \InvalidArgumentException('Invalid theme observation.');
        }
        self::db()->transactional(function ($db) use ($browserKey, $theme, $customerId) {
            $now = time();
            // Identified browsers never return to the guest count after logout.
            $db->execute('INSERT INTO theme_usage_browsers (browser_key, theme, identified, first_seen, last_seen)
                VALUES (:browser, :theme, :identified, :first, :last)
                ON DUPLICATE KEY UPDATE theme=VALUES(theme), identified=GREATEST(identified, VALUES(identified)), last_seen=VALUES(last_seen)',
                ['browser'=>$browserKey, 'theme'=>$theme, 'identified'=>$customerId > 0 ? 1 : 0, 'first'=>$now, 'last'=>$now]);
            if ($customerId > 0) {
                $db->execute('INSERT INTO theme_usage_customers (customer_id, theme, first_seen, last_seen)
                    VALUES (:customer, :theme, :first, :last)
                    ON DUPLICATE KEY UPDATE theme=VALUES(theme), last_seen=VALUES(last_seen)',
                    ['customer'=>$customerId, 'theme'=>$theme, 'first'=>$now, 'last'=>$now]);
            }
        });
    }

    public static function summary(): array
    {
        $result = ['installed'=>self::installed(), 'total'=>0,
            'dark'=>['total'=>0, 'customers'=>0, 'browsers'=>0, 'percent'=>0],
            'light'=>['total'=>0, 'customers'=>0, 'browsers'=>0, 'percent'=>0]];
        if (!$result['installed']) return $result;
        $rows = self::db()->execute("SELECT theme, 'browsers' kind, COUNT(*) total FROM theme_usage_browsers WHERE identified=0 GROUP BY theme
            UNION ALL SELECT theme, 'customers' kind, COUNT(*) total FROM theme_usage_customers GROUP BY theme")->fetchAll('assoc');
        foreach ($rows as $row) {
            $theme = $row['theme'];
            if (!isset($result[$theme])) continue;
            $count = (int)$row['total'];
            $result[$theme][$row['kind']] = $count;
            $result[$theme]['total'] += $count;
            $result['total'] += $count;
        }
        foreach (['dark', 'light'] as $theme) {
            $result[$theme]['percent'] = $result['total'] ? round(100 * $result[$theme]['total'] / $result['total'], 1) : 0;
        }
        return $result;
    }
}
