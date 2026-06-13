-- =============================================================================
-- RestAPI — Database Schema
-- ساخته‌شده بر اساس مدل‌های ماژول‌های پروژه
--
-- نحوه اجرا (XAMPP):
--   mysql -u root -p < database/schema.sql
-- یا از phpMyAdmin فایل را Import کنید.
--
-- نام دیتابیس را با مقدار DB_NAME در فایل .env هماهنگ کنید.
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `restapi`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `restapi`;

-- ─── Users ───────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `refresh_tokens`;
DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`          VARCHAR(100)    NOT NULL,
    `phone`         VARCHAR(15)     NOT NULL,
    `email`         VARCHAR(150)    NULL,
    `password_hash` VARCHAR(255)    NOT NULL,
    `role`          ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `users_phone_unique` (`phone`),
    KEY `users_role_active_idx` (`role`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `addresses` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT UNSIGNED NOT NULL,
    `title`       VARCHAR(100)    NULL,
    `province`    VARCHAR(100)    NOT NULL,
    `city`        VARCHAR(100)    NOT NULL,
    `address`     TEXT            NOT NULL,
    `postal_code` VARCHAR(20)     NULL,
    `receiver`    VARCHAR(100)    NULL,
    `phone`       VARCHAR(15)     NULL,
    `is_default`  TINYINT(1)      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `addresses_user_id_idx` (`user_id`),
    CONSTRAINT `addresses_user_id_fk`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `refresh_tokens` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT UNSIGNED NOT NULL,
    `token_hash` CHAR(64)        NOT NULL,
    `expires_at` DATETIME        NOT NULL,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `refresh_tokens_user_id_idx` (`user_id`),
    KEY `refresh_tokens_hash_expires_idx` (`token_hash`, `expires_at`),
    CONSTRAINT `refresh_tokens_user_id_fk`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Category ────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `category_images`;
DROP TABLE IF EXISTS `categories`;

CREATE TABLE `categories` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`         VARCHAR(150)    NOT NULL,
    `slug`         VARCHAR(180)    NOT NULL,
    `description`  TEXT            NULL,
    `poster_image` VARCHAR(500)    NULL,
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `categories_slug_unique` (`slug`),
    KEY `categories_name_idx` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `category_images` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `category_id` BIGINT UNSIGNED NOT NULL,
    `image_url`   VARCHAR(500)    NOT NULL,
    `alt_text`    VARCHAR(255)    NULL,
    `is_main`     TINYINT(1)      NOT NULL DEFAULT 0,
    `sort_order`  INT UNSIGNED    NOT NULL DEFAULT 0,
    `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `category_images_category_id_idx` (`category_id`),
    KEY `category_images_main_idx` (`category_id`, `is_main`),
    CONSTRAINT `category_images_category_id_fk`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Product ─────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `product_options`;
DROP TABLE IF EXISTS `product_images`;
DROP TABLE IF EXISTS `products`;

CREATE TABLE `products` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(200)    NOT NULL,
    `slug`        VARCHAR(220)    NULL,
    `description` TEXT            NULL,
    `price`       BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `category_id` BIGINT UNSIGNED NULL,
    `era`         VARCHAR(100)    NULL,
    `material`    VARCHAR(100)    NULL,
    `badge`       VARCHAR(50)     NULL,
    `stock`       INT UNSIGNED    NOT NULL DEFAULT 0,
    `views`       INT UNSIGNED    NOT NULL DEFAULT 0,
    `featured`    TINYINT(1)      NOT NULL DEFAULT 0,
    `is_active`   TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `products_category_id_idx` (`category_id`),
    KEY `products_active_featured_idx` (`is_active`, `featured`),
    KEY `products_price_idx` (`price`),
    KEY `products_views_idx` (`views`),
    CONSTRAINT `products_category_id_fk`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_images` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `image_url`  VARCHAR(500)    NOT NULL,
    `alt_text`   VARCHAR(255)    NULL,
    `is_main`    TINYINT(1)      NOT NULL DEFAULT 0,
    `sort_order` INT UNSIGNED    NOT NULL DEFAULT 0,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `product_images_product_id_idx` (`product_id`),
    KEY `product_images_main_idx` (`product_id`, `is_main`),
    CONSTRAINT `product_images_product_id_fk`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `product_options` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `product_id`   BIGINT UNSIGNED NOT NULL,
    `option_type`  VARCHAR(100)    NOT NULL,
    `option_value` VARCHAR(255)    NOT NULL,
    PRIMARY KEY (`id`),
    KEY `product_options_product_id_idx` (`product_id`),
    CONSTRAINT `product_options_product_id_fk`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Cart ────────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `carts`;

CREATE TABLE `carts` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT UNSIGNED NOT NULL,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `carts_user_id_unique` (`user_id`),
    CONSTRAINT `carts_user_id_fk`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cart_items` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `cart_id`    BIGINT UNSIGNED NOT NULL,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `quantity`   INT UNSIGNED    NOT NULL DEFAULT 1,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `cart_items_cart_product_unique` (`cart_id`, `product_id`),
    KEY `cart_items_product_id_idx` (`product_id`),
    CONSTRAINT `cart_items_cart_id_fk`
        FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `cart_items_product_id_fk`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Discount ────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `discount_codes`;

CREATE TABLE `discount_codes` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `code`       VARCHAR(50)     NOT NULL,
    `type`       ENUM('percent', 'fixed') NOT NULL,
    `value`      INT UNSIGNED    NOT NULL,
    `valid_from` DATETIME        NOT NULL,
    `valid_to`   DATETIME        NOT NULL,
    `is_active`  TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `discount_codes_code_unique` (`code`),
    KEY `discount_codes_active_valid_idx` (`is_active`, `valid_from`, `valid_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Order ───────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `payment_receipts`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;

CREATE TABLE `orders` (
    `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_number`     VARCHAR(30)     NOT NULL,
    `user_id`          BIGINT UNSIGNED NOT NULL,
    `customer_name`    VARCHAR(150)    NOT NULL,
    `customer_email`   VARCHAR(150)    NULL,
    `customer_phone`   VARCHAR(15)     NOT NULL,
    `shipping_address` TEXT            NOT NULL,
    `total_amount`     BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `discount_code_id` BIGINT UNSIGNED NULL,
    `payment_method`   ENUM('card', 'transfer', 'cash') NOT NULL DEFAULT 'cash',
    `status`           ENUM('pending', 'paid', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
    `notes`            TEXT            NULL,
    `created_at`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `orders_order_number_unique` (`order_number`),
    KEY `orders_user_id_idx` (`user_id`),
    KEY `orders_status_idx` (`status`),
    KEY `orders_created_at_idx` (`created_at`),
    CONSTRAINT `orders_user_id_fk`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `orders_discount_code_id_fk`
        FOREIGN KEY (`discount_code_id`) REFERENCES `discount_codes` (`id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `order_items` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_id`   BIGINT UNSIGNED NOT NULL,
    `product_id` BIGINT UNSIGNED NOT NULL,
    `quantity`   INT UNSIGNED    NOT NULL DEFAULT 1,
    `price`      BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    KEY `order_items_order_id_idx` (`order_id`),
    KEY `order_items_product_id_idx` (`product_id`),
    CONSTRAINT `order_items_order_id_fk`
        FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `order_items_product_id_fk`
        FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_receipts` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_id`   BIGINT UNSIGNED NOT NULL,
    `file_name`  VARCHAR(255)    NOT NULL,
    `file_path`  VARCHAR(500)    NOT NULL,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `payment_receipts_order_id_unique` (`order_id`),
    CONSTRAINT `payment_receipts_order_id_fk`
        FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Shop Settings ───────────────────────────────────────────────────────────

DROP TABLE IF EXISTS `shop_settings`;

CREATE TABLE `shop_settings` (
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

SET FOREIGN_KEY_CHECKS = 1;

-- ─── Seed Data (اختیاری) ─────────────────────────────────────────────────────

-- ادمین پیش‌فرض
-- تلفن: 09123456789 | رمز: Admin@1234
INSERT INTO `users` (`name`, `phone`, `password_hash`, `role`, `is_active`)
VALUES (
    'مدیر سیستم',
    '09123456789',
    '$2y$10$N2SAhve1aKKrzmLRouLQIO2ombZm56/z92biuOi0KGUBox6JXVDfq',
    'admin',
    1
);

-- نمونه دسته‌بندی
INSERT INTO `categories` (`name`, `slug`, `description`) VALUES
('مبلمان', 'furniture', 'مبلمان و دکوراسیون داخلی'),
('روشنایی', 'lighting', 'لوستر و آباژور'),
('دکور', 'decor', 'اشیای تزئینی');

-- نمونه کد تخفیف (۱۰٪ — یک سال اعتبار)
INSERT INTO `discount_codes` (`code`, `type`, `value`, `valid_from`, `valid_to`, `is_active`)
VALUES (
    'WELCOME10',
    'percent',
    10,
    NOW(),
    DATE_ADD(NOW(), INTERVAL 1 YEAR),
    1
);

-- تنظیمات پیش‌فرض فروشگاه
INSERT INTO `shop_settings` (`shop_name`, `payment_method`, `sms_enabled`)
VALUES ('فروشگاه', 'card_to_card', 0);
