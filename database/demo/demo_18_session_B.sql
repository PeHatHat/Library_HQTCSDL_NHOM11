-- ====================================================================
-- DEMO 18 - DEADLOCK - SESSION B (Khóa Sách 2 -> Xin khóa Sách 1)
-- ====================================================================
-- Hướng dẫn:
--   1. Mở tab/kết nối MySQL thứ hai (Session B).
--   2. Ngay khi Session A chạy xong Bước 1, chạy lệnh Bước 1 dưới đây để khóa Sách #2.
--   3. Khi Session A bị treo chờ Sách #2, chạy tiếp lệnh Bước 2 để kích hoạt Deadlock!
-- ====================================================================

USE QLThuVien;

SELECT '=== SESSION B: BẮT ĐẦU TRANSACTION ===' AS ThongBao;
START TRANSACTION;

-- BƯỚC 1: Cập nhật và khóa Sách #2 (Độc quyền X-Lock trên MaSach = 2)
SELECT 'Bước 1: Session B khóa Sách #2' AS HanhDong;
UPDATE SACH 
SET SoLuongCon = SoLuongCon - 1 
WHERE MaSach = 2;

-- Chờ 1 giây để Session A chuyển sang xin khóa Sách #2 và bị treo
SELECT SLEEP(1);

-- BƯỚC 2: Xin khóa tiếp Sách #1 (Đang bị Session A giữ)
-- LỆNH NÀY TẠO THÀNH VÒNG CHỜ KHÓA CHÉO NHAU (DEADLOCK)!
-- InnoDB Deadlock Detector sẽ can thiệp ngay lập tức:
--   -> Session B bị rollback với mã lỗi ERROR 1213 (40001)
--   -> Hoặc Session A bị rollback, Session B được giải phóng chạy tiếp.
SELECT 'Bước 2: Session B xin khóa Sách #1 -> KÍCH HOẠT DEADLOCK!' AS HanhDong;
UPDATE SACH 
SET SoLuongCon = SoLuongCon - 1 
WHERE MaSach = 1;

COMMIT;
SELECT '=== SESSION B: HOÀN TẤT (Nếu không bị chọn làm Victim) ===' AS ThongBao;
SELECT MaSach, TenSach, SoLuongCon FROM SACH WHERE MaSach IN (1, 2);
