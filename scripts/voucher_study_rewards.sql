-- Apply after voucher_schema.sql. Repeatable on MariaDB and MySQL.
SET NAMES utf8mb4;

SET @meduc_study_ddl = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='voucher_study_weeks' AND COLUMN_NAME='active_seconds'),
    'DO 0',
    'ALTER TABLE voucher_study_weeks ADD active_seconds INT UNSIGNED NOT NULL DEFAULT 0,
                                     ADD credited_until BIGINT UNSIGNED NOT NULL DEFAULT 0'
);
PREPARE meduc_study_statement FROM @meduc_study_ddl;
EXECUTE meduc_study_statement;
DEALLOCATE PREPARE meduc_study_statement;

SET @meduc_study_ddl = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='voucher_campaigns' AND COLUMN_NAME='preset_key'),
    'DO 0',
    'ALTER TABLE voucher_campaigns ADD preset_key VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL,
                                  ADD UNIQUE KEY uq_voucher_campaign_preset_key (preset_key)'
);
PREPARE meduc_study_statement FROM @meduc_study_ddl;
EXECUTE meduc_study_statement;
DEALLOCATE PREPARE meduc_study_statement;

START TRANSACTION;
UPDATE voucher_study_weeks
SET active_seconds=active_minutes*60, credited_until=(last_minute+1)*60
WHERE credited_until=0 AND active_minutes>0;

UPDATE voucher_campaigns SET scope='knowledge' WHERE kind='study' AND scope<>'knowledge';
INSERT INTO voucher_campaigns (preset_key,kind,name,scope,discount_type,discount_value,starts_at,active,study_minutes)
VALUES
    ('study-week-1h','study','Thưởng học 1 giờ','knowledge','fixed',20000,UNIX_TIMESTAMP(),1,60),
    ('study-week-3h','study','Thưởng học 3 giờ','knowledge','fixed',50000,UNIX_TIMESTAMP(),1,180),
    ('study-week-5h','study','Thưởng học 5 giờ','knowledge','fixed',100000,UNIX_TIMESTAMP(),1,300)
ON DUPLICATE KEY UPDATE preset_key=VALUES(preset_key);
COMMIT;
