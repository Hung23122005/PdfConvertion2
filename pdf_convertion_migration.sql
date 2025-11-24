-- ============================================================
-- PDF CONVERSION DATABASE - MIGRATION SCRIPT
-- Cập nhật bảng users với các trường thông tin bổ sung
-- ============================================================

USE `pdf_convertion`;

-- Thêm các cột mới vào bảng users
ALTER TABLE `users` 
ADD COLUMN `email` VARCHAR(100) AFTER `password`,
ADD COLUMN `full_name` VARCHAR(100) AFTER `email`,
ADD COLUMN `phone` VARCHAR(20) AFTER `full_name`,
ADD COLUMN `date_of_birth` DATE AFTER `phone`,
ADD COLUMN `address` TEXT AFTER `date_of_birth`,
ADD COLUMN `gender` ENUM('Nam', 'Nữ', 'Khác') AFTER `address`;

-- Thêm unique constraint cho email
ALTER TABLE `users`
ADD UNIQUE KEY `email` (`email`);

-- ============================================================
-- LƯU Ý:
-- 1. Chạy script này TRƯỚC KHI test đăng ký với form mới
-- 2. Các user hiện tại sẽ có giá trị NULL cho các trường mới
-- 3. Email là bắt buộc ở phía client (form validation)
-- 4. Bạn CẦN cập nhật Java servlet để xử lý các trường mới!
-- ============================================================

-- Kiểm tra cấu trúc bảng sau khi cập nhật
DESCRIBE `users`;
