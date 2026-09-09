-- DEMO 15 - DIRTY READ - SESSION B (Transaction đọc, dùng READ UNCOMMITTED)
-- Mở 1 tab/kết nối MySQL KHÁC (khác với Session A), USE QLThuVien.
-- Chạy file này ngay sau khi Session A vừa chạy xong câu UPDATE
-- (trong lúc Session A đang SLEEP(5), chưa COMMIT/ROLLBACK).

USE QLThuVien;

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- (1) Đọc trong lúc Session A CHƯA COMMIT -> kỳ vọng thấy 4 (dữ liệu "bẩn")
SELECT SoLuongCon FROM SACH WHERE MaSach = 1;

-- Chờ đến khi Session A ROLLBACK xong
SELECT SLEEP(6);

-- (2) Đọc lại sau khi Session A đã ROLLBACK -> kỳ vọng thấy lại 5
SELECT SoLuongCon FROM SACH WHERE MaSach = 1;
