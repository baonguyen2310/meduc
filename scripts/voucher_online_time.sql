-- Apply after voucher_study_rewards.sql. Earlier lesson activity stays in its original columns.
SET @meduc_online_ddl = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='voucher_study_weeks' AND COLUMN_NAME='online_window'),
    'DO 0',
    'ALTER TABLE voucher_study_weeks ADD online_seconds INT UNSIGNED NOT NULL DEFAULT 0,
                                     ADD online_window TEXT NULL'
);
PREPARE meduc_online_statement FROM @meduc_online_ddl;
EXECUTE meduc_online_statement;
DEALLOCATE PREPARE meduc_online_statement;

SET NAMES utf8mb4;
UPDATE voucher_campaigns SET name = CASE preset_key
    WHEN 'study-week-1h' THEN 'Thưởng online 1 giờ'
    WHEN 'study-week-3h' THEN 'Thưởng online 3 giờ'
    WHEN 'study-week-5h' THEN 'Thưởng online 5 giờ'
    END
WHERE kind='study' AND preset_key IN ('study-week-1h', 'study-week-3h', 'study-week-5h')
  AND name IN ('Thưởng học 1 giờ', 'Thưởng học 3 giờ', 'Thưởng học 5 giờ');
