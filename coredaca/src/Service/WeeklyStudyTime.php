<?php
declare(strict_types=1);

namespace App\Service;

use App\Lib\LessonMetadata;
use App\Lib\LessonQuizzes;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use DateTimeImmutable;
use DateTimeZone;

final class WeeklyStudyTime
{
    private const MAX_HEARTBEAT_GAP = 30;

    public static function installed(): bool
    {
        static $ready;
        if ($ready === null) {
            $ready = Vouchers::installed() && (bool)ConnectionManager::get('default')->execute(
                "SHOW COLUMNS FROM voucher_study_weeks LIKE 'active_seconds'"
            )->fetch();
        }
        return $ready;
    }

    public static function week(int $now): array
    {
        $monday = (new DateTimeImmutable('@' . $now))->setTimezone(new DateTimeZone('Asia/Ho_Chi_Minh'))
            ->modify('monday this week')->setTime(0, 0);
        return [$monday->getTimestamp(), $monday->modify('+1 week')->getTimestamp()];
    }

    public static function total(int $customer, int $now): array
    {
        [$week, $nextWeek] = self::week($now);
        $column = self::installed() ? 'active_seconds' : 'active_minutes*60';
        $seconds = ConnectionManager::get('default')->execute(
            "SELECT $column FROM voucher_study_weeks WHERE customer_id=? AND week_start=?", [$customer, $week]
        )->fetchColumn(0);
        return ['seconds' => (int)$seconds, 'week_start' => $week, 'resets_at' => $nextWeek];
    }

    /** An expired heartbeat starts a new interval. Both endpoints use the server clock. */
    public static function record(int $customer, int $from, int $now): void
    {
        if ($now <= $from || $now - $from > self::MAX_HEARTBEAT_GAP) {
            return;
        }
        $db = ConnectionManager::get('default');
        // Split an interval at Monday midnight. Lock each account/week row as
        // part of the upsert so other tabs or devices cannot add the same time.
        $db->transactional(function () use ($db, $customer, $from, $now) {
            while ($from < $now) {
                [$week, $nextWeek] = self::week($from);
                $end = min($now, $nextWeek);
                $db->execute(
                    'INSERT INTO voucher_study_weeks (customer_id,week_start,last_minute,active_seconds,credited_until)
                     VALUES (?,?,0,?,?)
                     ON DUPLICATE KEY UPDATE active_seconds=active_seconds+
                       IF(credited_until<VALUES(credited_until), VALUES(credited_until)-GREATEST(credited_until,?), 0),
                       credited_until=GREATEST(credited_until,VALUES(credited_until))',
                    [$customer, $week, $end - $from, $end, $from]
                );
                $from = $end;
            }
        });
    }

    /** Call after checking that this is a published knowledge course. */
    public static function canWatch(array $member, int $course, int $number): bool
    {
        $outline = ConnectionManager::get('default')->execute(
            'SELECT value FROM products_attribute WHERE product_id=? AND attribute_id=11 LIMIT 1', [$course]
        )->fetchColumn(0);
        $lessons = array_values(array_filter(LessonQuizzes::lessons($outline), static function ($lesson) {
            return !empty($lesson['name_vi']) && !LessonMetadata::isGroup($lesson);
        }));
        $lesson = $lessons[$number - 1] ?? [];
        if (!preg_match('/^[\w-]{11}(?![\w-])/', trim((string)($lesson['youtube_id_vi'] ?? '')))) {
            return false;
        }
        return ($lesson['trial_vi'] ?? '') === 'y'
            || !empty(TableRegistry::get('CourseEnrollments')->activeCourses($member['id'])[$course])
            || (!empty($member['code']) && TableRegistry::get('ClassRooms')->exists([
                'product_id' => $course, 'deleted' => 0, 'users LIKE' => '%' . $member['code'] . '%',
            ]));
    }
}
