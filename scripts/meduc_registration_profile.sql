-- Registration profile: birthday reuses the existing customers.birthday column (Unix date).
-- Nullable columns preserve existing accounts; new registrations require school_name and student_year.
-- student_year: 1..6 or graduate (graduated/postgraduate).
-- Rollback code independently; retain new profile columns to preserve collected data.
SET NAMES utf8mb4;
ALTER TABLE customers
 ADD COLUMN IF NOT EXISTS school_name VARCHAR(255) NULL DEFAULT NULL,
 ADD COLUMN IF NOT EXISTS student_year VARCHAR(16) NULL DEFAULT NULL;
UPDATE settings SET value='0' WHERE group_setting='social' AND code='google_load_sdk';
