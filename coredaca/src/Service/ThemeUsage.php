<?php
declare(strict_types=1);
namespace App\Service;

use Cake\Datasource\ConnectionManager;

/** Account preferences are authoritative; browser observations and transitions remain auditable. */
class ThemeUsage
{
    public const VERSION = 20261113;
    public static function db() { return ConnectionManager::get('default'); }

    public static function installed(): bool
    {
        static $ready;
        if ($ready === null) $ready = (bool)self::db()->execute("SHOW TABLES LIKE 'theme_usage_events'")->fetch();
        return $ready;
    }

    /** Read only. Render an authenticated preference before the first paint. */
    public static function initial(int $customerId): array
    {
        $theme = 'light';
        if ($customerId > 0 && self::installed()) {
            $saved = self::db()->execute('SELECT theme FROM theme_usage_customers WHERE customer_id=:id AND preference_version=:version',
                ['id'=>$customerId, 'version'=>self::VERSION])->fetch('assoc');
            if ($saved && in_array($saved['theme'], ['light', 'dark'], true)) $theme = $saved['theme'];
        }
        return ['customer_id'=>$customerId, 'theme'=>$theme, 'version'=>self::VERSION];
    }

    /** Lock each account before its browser. A sync must never save stale local storage into an account. */
    public static function record(string $browserKey, string $theme, int $customerId, string $mode, ?string $eventKey = null, ?string $legacyTheme = null): array
    {
        if (!preg_match('/^[a-f0-9]{64}$/', $browserKey) || !in_array($theme, ['dark', 'light'], true)
            || $customerId < 0 || !in_array($mode, ['sync', 'change'], true)
            || ($mode === 'change' && !preg_match('/^[a-f0-9]{32}$/', (string)$eventKey))) {
            throw new \InvalidArgumentException('Invalid theme preference.');
        }
        return self::db()->transactional(function ($db) use ($browserKey, $theme, $customerId, $mode, $eventKey, $legacyTheme) {
            $now = time(); $customer = null; $newCustomer = false;
            if ($customerId) {
                $newCustomer = $db->execute("INSERT IGNORE INTO theme_usage_customers (customer_id, theme, preference_version, first_seen, last_seen)
                    VALUES (:id, 'light', 0, :first, :last)", ['id'=>$customerId, 'first'=>$now, 'last'=>$now])->rowCount() > 0;
                $customer = $db->execute('SELECT * FROM theme_usage_customers WHERE customer_id=:id FOR UPDATE', ['id'=>$customerId])->fetch('assoc');
            }
            $newBrowser = $db->execute("INSERT IGNORE INTO theme_usage_browsers (browser_key, theme, identified, customer_id, preference_version, first_seen, last_seen)
                VALUES (:browser, 'light', 0, 0, 0, :first, :last)", ['browser'=>$browserKey, 'first'=>$now, 'last'=>$now])->rowCount() > 0;
            $browser = $db->execute('SELECT * FROM theme_usage_browsers WHERE browser_key=:browser FOR UPDATE', ['browser'=>$browserKey])->fetch('assoc');
            $browserCurrent = (int)$browser['preference_version'] === self::VERSION;
            $customerCurrent = $customer && (int)$customer['preference_version'] === self::VERSION;
            $beforeBrowser = $browserCurrent ? $browser['theme'] : 'light';
            $beforeCustomer = $customerCurrent ? $customer['theme'] : ($customerId ? 'light' : null);

            // A retried change must never replay an old preference after a newer change succeeded.
            if ($mode === 'change' && $db->execute('SELECT id FROM theme_usage_events WHERE browser_key=:browser AND event_key=:event',
                ['browser'=>$browserKey, 'event'=>$eventKey])->fetch()) {
                return ['theme'=>$customerId ? $beforeCustomer : $beforeBrowser, 'customer_id'=>$customerId, 'version'=>self::VERSION];
            }
            $next = $mode === 'change' || !$customerId ? $theme : $beforeCustomer;
            $reason = $mode === 'change' ? 'change' : ($customerId ? 'account_sync' : 'browser_sync');
            $changed = $mode === 'change' || $beforeBrowser !== $next || ($customerId && $beforeCustomer !== $next);
            $previous = $beforeBrowser; $previousCustomer = $beforeCustomer;
            if ($mode === 'sync' && (!$browserCurrent || ($customerId && !$customerCurrent))) {
                $reset = (!$newBrowser && !$browserCurrent) || (!$newCustomer && $customer && !$customerCurrent)
                    || in_array($legacyTheme, ['light', 'dark'], true);
                $reason = $customerCurrent ? 'account_sync' : ($reset ? 'reset' : 'initial');
                $previous = !$newBrowser ? $browser['theme'] : ($legacyTheme ?: null);
                $previousCustomer = $customer && !$newCustomer ? $customer['theme'] : null;
                $changed = true;
            }
            if ($customerId) {
                $db->execute('UPDATE theme_usage_customers SET theme=:theme, preference_version=:version, last_seen=:seen WHERE customer_id=:id',
                    ['theme'=>$next, 'version'=>self::VERSION, 'seen'=>$now, 'id'=>$customerId]);
            }
            $db->execute('UPDATE theme_usage_browsers SET theme=:theme, preference_version=:version, customer_id=:customer,
                identified=GREATEST(identified,:identified), last_seen=:seen WHERE browser_key=:browser',
                ['theme'=>$next, 'version'=>self::VERSION, 'customer'=>$customerId, 'identified'=>$customerId ? 1 : 0, 'seen'=>$now, 'browser'=>$browserKey]);
            if ($changed) {
                $db->execute('INSERT INTO theme_usage_events (browser_key, customer_id, previous_theme, customer_previous_theme, theme, reason, preference_version, event_key, created)
                    VALUES (:browser,:customer,:previous,:customer_previous,:theme,:reason,:version,:event,:created)',
                    ['browser'=>$browserKey, 'customer'=>$customerId, 'previous'=>$previous, 'customer_previous'=>$previousCustomer,
                        'theme'=>$next, 'reason'=>$reason, 'version'=>self::VERSION, 'event'=>$mode === 'change' ? $eventKey : null, 'created'=>$now]);
            }
            return ['theme'=>$next, 'customer_id'=>$customerId, 'version'=>self::VERSION];
        });
    }

    public static function summary(): array
    {
        $result = ['installed'=>self::installed(), 'total'=>0, 'pending'=>0,
            'dark'=>['total'=>0, 'customers'=>0, 'browsers'=>0, 'percent'=>0],
            'light'=>['total'=>0, 'customers'=>0, 'browsers'=>0, 'percent'=>0]];
        if (!$result['installed']) return $result;
        $rows = self::db()->execute("SELECT theme, 'browsers' kind, COUNT(*) total FROM theme_usage_browsers WHERE identified=0 AND preference_version=:browser_version GROUP BY theme
            UNION ALL SELECT theme, 'customers' kind, COUNT(*) total FROM theme_usage_customers WHERE preference_version=:customer_version GROUP BY theme",
            ['browser_version'=>self::VERSION, 'customer_version'=>self::VERSION])->fetchAll('assoc');
        foreach ($rows as $row) {
            $theme = $row['theme'];
            if (!isset($result[$theme])) continue;
            $count = (int)$row['total'];
            $result[$theme][$row['kind']] = $count;
            $result[$theme]['total'] += $count; $result['total'] += $count;
        }
        foreach (['dark', 'light'] as $theme) $result[$theme]['percent'] = $result['total'] ? round(100 * $result[$theme]['total'] / $result['total'], 1) : 0;
        $result['pending'] = (int)self::db()->execute('SELECT (SELECT COUNT(*) FROM theme_usage_customers WHERE preference_version<>:customer_version)
            + (SELECT COUNT(*) FROM theme_usage_browsers WHERE identified=0 AND preference_version<>:browser_version)',
            ['customer_version'=>self::VERSION, 'browser_version'=>self::VERSION])->fetchColumn(0);
        return $result;
    }
}
