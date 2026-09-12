-- ====================================================================
-- DEMO 17 - PHANTOM READ - SESSION B (Transaction chèn thêm sách mới)
-- ====================================================================
-- Hướng dẫn:
--   Chạy file này ở tab/kết nối MySQL thứ hai ngay sau khi Session A bắt đầu
--   (trong khoảng 5 giây mà Session A đang SLEEP).
-- ====================================================================

USE QLThuVien;

SELECT '=== SESSION B: BẮT ĐẦU CHÈN ĐẦU SÁCH MỚI ===' AS ThongBao;

START TRANSACTION;

-- Chèn thêm một đầu sách CNTT mới
INSERT INTO SACH (TenSach, TheLoai, ViTriKe, SoLuong, SoLuongCon)
VALUES (CONCAT('Sách CNTT Mới_', UNIX_TIMESTAMP()), 'Công nghệ thông tin', 'Kệ C4', 5, 5);

-- Cam kết dữ liệu mới
COMMIT;

SELECT '=== SESSION B: ĐÃ CHÈN VÀ COMMIT THÀNH CÔNG! ===' AS ThongBao;
SELECT MaSach, TenSach, TheLoai, SoLuongCon FROM SACH WHERE TheLoai = 'Công nghệ thông tin';
