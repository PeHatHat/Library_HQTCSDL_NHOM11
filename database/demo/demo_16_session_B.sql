-- ====================================================================
-- DEMO 16 - UNREPEATABLE READ - SESSION B (Transaction cập nhật & commit)
-- ====================================================================
-- Hướng dẫn:
--   Chạy file này ở tab/kết nối MySQL thứ hai ngay sau khi Session A bắt đầu
--   (trong khoảng 5 giây mà Session A đang SLEEP).
-- ====================================================================

USE QLThuVien;

SELECT '=== SESSION B: BẮT ĐẦU CẬP NHẬT DỮ LIỆU ===' AS ThongBao;

START TRANSACTION;

-- Mượn 1 cuốn hoặc giảm số lượng còn lại của Sách #1
UPDATE SACH
SET SoLuongCon = SoLuongCon - 1
WHERE MaSach = 1;

-- Cam kết thay đổi ngay lập tức
COMMIT;

SELECT '=== SESSION B: ĐÃ COMMIT THÀNH CÔNG! ===' AS ThongBao;
SELECT MaSach, TenSach, SoLuongCon FROM SACH WHERE MaSach = 1;
