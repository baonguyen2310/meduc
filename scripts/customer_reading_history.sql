-- Private reading positions. Guests stay in first-party browser storage.
CREATE TABLE IF NOT EXISTS customer_reading_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NOT NULL,
  kind VARCHAR(12) NOT NULL,
  article_id BIGINT UNSIGNED NOT NULL,
  progress TEXT NULL,
  visited_at BIGINT UNSIGNED NOT NULL,
  updated_at BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reader_item (customer_id,kind,article_id),
  KEY idx_reader_recent (customer_id,kind,visited_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
