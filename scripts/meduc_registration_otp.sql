-- Reuse email_token for six-digit registration OTPs; existing password-reset tokens are unchanged.
ALTER TABLE email_token
 MODIFY COLUMN code VARCHAR(128) NOT NULL,
 ADD COLUMN IF NOT EXISTS customer_id INT NULL DEFAULT NULL,
 ADD COLUMN IF NOT EXISTS attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
 ADD COLUMN IF NOT EXISTS sent_at INT NULL DEFAULT NULL;
-- New registration_otp rows store only an HMAC hash in code.
-- Expiry: 10 minutes; maximum wrong attempts: 5; resend interval: 60 seconds.
