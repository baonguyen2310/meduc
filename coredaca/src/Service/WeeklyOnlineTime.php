<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Datasource\ConnectionManager;
use DateTimeImmutable;
use DateTimeZone;

final class WeeklyOnlineTime
{
    // Hidden tabs may be scheduled once a minute. Consecutive pulses still need
    // to be close enough to establish that the browser remained online.
    public const MAX_PULSE_GAP = 95;
    private const MERGE_WINDOW = 240;

    public static function installed(): bool
    {
        static $ready;
        if ($ready === null) {
            $ready = Vouchers::installed() && (bool)ConnectionManager::get('default')->execute(
                "SHOW COLUMNS FROM voucher_study_weeks LIKE 'online_window'"
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
        $seconds = self::installed() ? ConnectionManager::get('default')->execute(
            'SELECT online_seconds FROM voucher_study_weeks WHERE customer_id=? AND week_start=?',
            [$customer, $week]
        )->fetchColumn(0) : 0;
        return ['seconds' => (int)$seconds, 'week_start' => $week, 'resets_at' => $nextWeek];
    }

    public static function record(int $customer, int $from, int $now): void
    {
        if ($now <= $from || $now - $from > self::MAX_PULSE_GAP) {
            return;
        }
        ConnectionManager::get('default')->transactional(function ($db) use ($customer, $from, $now) {
            while ($from < $now) {
                [$week, $nextWeek] = self::week($from);
                $end = min($now, $nextWeek);
                self::recordInterval($db, $customer, $week, $from, $end);
                $from = $end;
            }
        });
    }

    private static function recordInterval($db, int $customer, int $week, int $from, int $end): void
    {
        $key = [$customer, $week];
        $db->execute(
            'INSERT INTO voucher_study_weeks (customer_id,week_start,last_minute) VALUES (?,?,0)
             ON DUPLICATE KEY UPDATE customer_id=customer_id', $key
        );
        $window = $db->execute(
            'SELECT online_window FROM voucher_study_weeks WHERE customer_id=? AND week_start=? FOR UPDATE', $key
        )->fetchColumn(0);
        $state = $window ? json_decode($window, true, 512, JSON_THROW_ON_ERROR) : ['before' => $week, 'ranges' => []];
        $from = max($from, $state['before']);
        if ($from >= $end) {
            return;
        }

        // Earlier pulses may commit after later ones on another tab or device.
        // Keep the recent union, so only overlapping seconds are subtracted.
        $added = $end - $from;
        foreach ($state['ranges'] as [$start, $finish]) {
            $added -= max(0, min($end, $finish) - max($from, $start));
        }
        if ($added === 0) {
            return;
        }

        $ranges = $state['ranges'];
        $ranges[] = [$from, $end];
        usort($ranges, static function (array $left, array $right): int { return $left[0] <=> $right[0]; });
        $before = max($state['before'], $end - self::MERGE_WINDOW);
        $merged = [];
        foreach ($ranges as [$start, $finish]) {
            if ($finish <= $before) {
                continue;
            }
            $start = max($start, $before);
            $last = count($merged) - 1;
            if ($last >= 0 && $start <= $merged[$last][1]) {
                $merged[$last][1] = max($merged[$last][1], $finish);
            } else {
                $merged[] = [$start, $finish];
            }
        }
        $db->execute(
            'UPDATE voucher_study_weeks SET online_seconds=online_seconds+?, online_window=? WHERE customer_id=? AND week_start=?',
            [$added, json_encode(['before' => $before, 'ranges' => $merged], JSON_THROW_ON_ERROR), $customer, $week]
        );
    }
}
