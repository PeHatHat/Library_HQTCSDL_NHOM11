-- DEMO 15 - DIRTY READ - SESSION A (Transaction ghi, chưa COMMIT ngay)
-- Mở 1 tab/kết nối MySQL riêng, USE QLThuVien, rồi chạy file này.
-- Chạy demo_15_session_B.sql ở 1 tab/kết nối KHÁC ngay sau khi Session A
-- chạy xong câu UPDATE (trong lúc Session A đang SLEEP(5), chưa COMMIT).

USE QLThuVien;

SELECT SoLuongCon FROM SACH WHERE MaSach = 1; -- Kiểm tra trước: kỳ vọng 5

START TRANSACTION;

UPDATE SACH
SET SoLuongCon = SoLuongCon - 1
WHERE MaSach = 1;

-- Chưa COMMIT, giữ Transaction mở để Session B kịp đọc dữ liệu "bẩn"
SELECT SLEEP(5);

-- Huỷ thay đổi: chứng minh dữ liệu Session B đọc được ở trên là không có thật
ROLLBACK;

SELECT SoLuongCon FROM SACH WHERE MaSach = 1; -- Trở lại 5
