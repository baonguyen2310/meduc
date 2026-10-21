SET NAMES utf8mb4;
CREATE TABLE IF NOT EXISTS course_price_lists (
 id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(180) NOT NULL,
 slug VARCHAR(180) NOT NULL UNIQUE,
 description TEXT NULL,
 position INT NOT NULL DEFAULT 0,
 status TINYINT NOT NULL DEFAULT 1,
 created INT NOT NULL,
 updated INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS course_price_packages (
 id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 price_list_id INT NOT NULL,
 name VARCHAR(120) NOT NULL,
 course_count SMALLINT UNSIGNED NOT NULL,
 price DECIMAL(15,0) NOT NULL,
 sale_price DECIMAL(15,0) NULL,
 benefits TEXT NULL,
 recommended TINYINT NOT NULL DEFAULT 0,
 position INT NOT NULL DEFAULT 0,
 status TINYINT NOT NULL DEFAULT 1,
 created INT NOT NULL,
 updated INT NOT NULL,
 KEY price_list (price_list_id),
 CONSTRAINT course_price_package_list FOREIGN KEY (price_list_id) REFERENCES course_price_lists(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE products ADD COLUMN IF NOT EXISTS course_price_list_id INT NULL;
ALTER TABLE products ADD INDEX IF NOT EXISTS course_price_list_idx (course_price_list_id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS course_price_package_id INT NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS course_price_snapshot TEXT NULL;
