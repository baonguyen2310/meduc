<?php
declare(strict_types=1);

namespace App\Service;

use Cake\Datasource\ConnectionManager;
use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;

/** Display dates stay separate from the quiz's technical created/updated timestamps. */
final class QuizUpdateDates
{
    public const SEED_YEAR = 2026;
    private const TIMEZONE = 'Asia/Ho_Chi_Minh';

    /** Stable per quiz for this seed run; never chooses a future calendar date. */
    public static function seedDate(int $quizId, ?DateTimeImmutable $asOf = null): string
    {
        if ($quizId < 1) throw new InvalidArgumentException('Quiz ID must be positive.');
        $timezone = new DateTimeZone(self::TIMEZONE);
        $today = ($asOf ?: new DateTimeImmutable('now', $timezone))->setTimezone($timezone)->setTime(0, 0);
        $start = new DateTimeImmutable(self::SEED_YEAR . '-01-01', $timezone);
        $end = new DateTimeImmutable(self::SEED_YEAR . '-12-31', $timezone);
        if ($today < $start) throw new InvalidArgumentException('The seed year has not started.');
        if ($today < $end) $end = $today;
        $days = (int)$start->diff($end)->format('%a');
        $offset = hexdec(substr(hash('sha256', 'meduc-quiz-date-v1:' . $quizId), 0, 7)) % ($days + 1);
        return $start->modify('+' . $offset . ' days')->format('Y-m-d');
    }

    /** Safe for ORM saves and SQL importers: existing seeds and real edits are never replaced. */
    public static function seed(int $quizId): void
    {
        $date = self::seedDate($quizId);
        ConnectionManager::get('default')->execute(
            'UPDATE quizs SET display_seed_date=:date
             WHERE id=:id AND display_seed_date IS NULL AND deleted=0 AND fa_only=0',
            ['date' => $date, 'id' => $quizId]
        );
    }

    /** Called only after a successful, explicit save through the staff quiz editor. */
    public static function markManualUpdate(int $quizId): void
    {
        self::seed($quizId);
        ConnectionManager::get('default')->execute(
            'UPDATE quizs SET content_updated_at=GREATEST(COALESCE(content_updated_at,0),:now)
             WHERE id=:id AND deleted=0 AND fa_only=0',
            ['now' => time(), 'id' => $quizId]
        );
    }

    /** Real staff edits take precedence permanently, including after twelve months. */
    public static function display(array $row): array
    {
        $timezone = new DateTimeZone(self::TIMEZONE);
        $timestamp = (int)($row['content_updated_at'] ?? 0);
        if ($timestamp > 0) {
            $date = (new DateTimeImmutable('@' . $timestamp))->setTimezone($timezone);
            return ['date' => $date->format('d/m/Y'), 'iso_date' => $date->format('Y-m-d'), 'source' => 'manual'];
        }
        $seed = (string)($row['display_seed_date'] ?? '');
        $date = DateTimeImmutable::createFromFormat('!Y-m-d', $seed, $timezone);
        if (!$date || $date->format('Y-m-d') !== $seed) return [];
        return ['date' => $date->format('d/m/Y'), 'iso_date' => $seed, 'source' => 'seed'];
    }
}
