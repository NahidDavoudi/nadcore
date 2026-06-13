-- Migration: shop_settings table
-- Run: mysql -u root -p restapi < database/shop_settings.sql

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `shop_settings` (
    `id`                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `shop_name`            VARCHAR(150)    NOT NULL DEFAULT 'فروشگاه',
    `shop_slogan`          VARCHAR(255)    NULL,
    `shop_logo`            VARCHAR(500)    NULL,
    `shop_poster`          VARCHAR(500)    NULL,
    `bank_card`            VARCHAR(30)     NULL,
    `bank_owner`           VARCHAR(150)    NULL,
    `payment_method`       ENUM('card_to_card', 'zarinpal', 'both') NOT NULL DEFAULT 'card_to_card',
    `zarinpal_merchant_id` VARCHAR(100)    NULL,
    `sms_enabled`          TINYINT(1)      NOT NULL DEFAULT 0,
    `created_at`           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `shop_settings` (`shop_name`, `payment_method`, `sms_enabled`)
SELECT 'فروشگاه', 'card_to_card', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `shop_settings` LIMIT 1);
