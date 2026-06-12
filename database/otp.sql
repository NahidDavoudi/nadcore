-- به users اضافه کن
ALTER TABLE `users`
  ADD COLUMN `two_factor_enabled` TINYINT(1) NOT NULL DEFAULT 0 AFTER `is_active`;

-- جدول OTP (اگه Redis نداری یا می‌خوای audit trail داشته باشی)
CREATE TABLE `otp_codes` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `phone`      VARCHAR(15)     NOT NULL,
    `code`       CHAR(6)         NOT NULL,
    `type`       ENUM('reset_password', 'two_factor', 'verify_phone') NOT NULL,
    `expires_at` DATETIME        NOT NULL,
    `used_at`    DATETIME        NULL,
    `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `otp_codes_phone_type_idx` (`phone`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
