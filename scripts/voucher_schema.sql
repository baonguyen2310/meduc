-- Shop contacts and the customer record attached to a package order must roll
-- back with coupon use. Older databases still store these tables as MyISAM.
SET @meduc_voucher_ddl = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='contacts' AND ENGINE='InnoDB'),
    'DO 0', 'ALTER TABLE contacts ENGINE=InnoDB, ROW_FORMAT=DYNAMIC'
);
PREPARE meduc_voucher_statement FROM @meduc_voucher_ddl;
EXECUTE meduc_voucher_statement;
DEALLOCATE PREPARE meduc_voucher_statement;

SET @meduc_voucher_ddl = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='orders_contact' AND ENGINE='InnoDB'),
    'DO 0', 'ALTER TABLE orders_contact ENGINE=InnoDB, ROW_FORMAT=DYNAMIC'
);
PREPARE meduc_voucher_statement FROM @meduc_voucher_ddl;
EXECUTE meduc_voucher_statement;
DEALLOCATE PREPARE meduc_voucher_statement;

CREATE TABLE IF NOT EXISTS voucher_campaigns (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    kind VARCHAR(12) CHARACTER SET ascii NOT NULL,
    name VARCHAR(160) NOT NULL,
    code VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL,
    scope VARCHAR(16) CHARACTER SET ascii NOT NULL,
    discount_type VARCHAR(8) CHARACTER SET ascii NOT NULL,
    discount_value BIGINT UNSIGNED NOT NULL,
    starts_at BIGINT UNSIGNED NOT NULL,
    ends_at BIGINT UNSIGNED NULL,
    active TINYINT UNSIGNED NOT NULL DEFAULT 0,
    spend_from BIGINT UNSIGNED NULL,
    spend_until BIGINT UNSIGNED NULL,
    required_spend BIGINT UNSIGNED NULL,
    study_minutes SMALLINT UNSIGNED NULL,
    partner_id INT UNSIGNED NULL,
    UNIQUE KEY uq_voucher_campaign_code (code),
    KEY ix_voucher_campaign_active (active, kind, starts_at, ends_at),
    KEY ix_voucher_campaign_partner (partner_id, active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS voucher_grants (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT UNSIGNED NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    period_start BIGINT UNSIGNED NOT NULL,
    code VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    expires_at BIGINT UNSIGNED NULL,
    issued_at BIGINT UNSIGNED NOT NULL,
    used_at BIGINT UNSIGNED NULL,
    UNIQUE KEY uq_voucher_grant (campaign_id, customer_id, period_start),
    UNIQUE KEY uq_voucher_grant_code (code),
    KEY ix_voucher_grant_customer (customer_id, expires_at),
    CONSTRAINT fk_voucher_grant_campaign FOREIGN KEY (campaign_id) REFERENCES voucher_campaigns (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS voucher_study_weeks (
    customer_id INT UNSIGNED NOT NULL,
    week_start BIGINT UNSIGNED NOT NULL,
    active_minutes SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    last_minute BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (customer_id, week_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS voucher_uses (
    order_source VARCHAR(8) CHARACTER SET ascii NOT NULL,
    order_id INT UNSIGNED NOT NULL,
    kind VARCHAR(12) CHARACTER SET ascii NOT NULL,
    campaign_id INT UNSIGNED NOT NULL,
    grant_id BIGINT UNSIGNED NULL,
    code VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    amount BIGINT UNSIGNED NOT NULL,
    created_at BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (order_source, order_id, kind),
    KEY ix_voucher_use_grant (grant_id),
    KEY ix_voucher_use_campaign (campaign_id, created_at),
    CONSTRAINT fk_voucher_use_campaign FOREIGN KEY (campaign_id) REFERENCES voucher_campaigns (id),
    CONSTRAINT fk_voucher_use_grant FOREIGN KEY (grant_id) REFERENCES voucher_grants (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
