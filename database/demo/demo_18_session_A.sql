-- ====================================================================
-- DEMO 18 - DEADLOCK - SESSION A (Khóa Sách 1 -> Xin khóa Sách 2)
-- ====================================================================
-- Hướng dẫn:
--   1. Mở tab/kết nối MySQL thứ nhất (Session A).
--   2. Đảm bảo chạy file demo_18_deadlock.sql trước.
--   3. Chạy từng lệnh hoặc chạy toàn bộ file này.
--   4. Trong lúc Session A đang SLEEP(3), nhanh chóng sang tab Session B chạy lệnh bước 1 của demo_18_session_B.sql.
-- ====================================================================

USE QLThuVien;

SELECT '=== SESSION A: BẮT ĐẦU TRANSACTION ===' AS ThongBao;
START TRANSACTION;

-- BƯỚC 1: Cập nhật và khóa Sách #1 (Độc quyền X-Lock trên MaSach = 1)
SELECT 'Bước 1: Session A khóa Sách #1' AS HanhDong;
UPDATE SACH 
SET SoLuongCon = SoLuongCon - 1 
WHERE MaSach = 1;

-- Tạm dừng 3 giây để Session B kịp khóa Sách #2
SELECT SLEEP(3);

-- BƯỚC 2: Xin khóa tiếp Sách #2 (Đang bị Session B giữ)
-- LỆNH NÀY SẼ BỊ TREO CHỜ (LOCK WAIT)...
-- Cho đến khi Session B xin khóa Sách #1 -> InnoDB phát hiện Deadlock!
SELECT 'Bước 2: Session A xin khóa Sách #2 (Đợi Session B)...' AS HanhDong;
UPDATE SACH 
SET SoLuongCon = SoLuongCon - 1 
WHERE MaSach = 2;

-- Nếu Session A không bị chọn làm Victim, giao dịch sẽ commit thành công
COMMIT;
SELECT '=== SESSION A: GIAO DỊCH THÀNH CÔNG (ĐƯỢC GIỮ LẠI) ===' AS ThongBao;
SELECT MaSach, TenSach, SoLuongCon FROM SACH WHERE MaSach IN (1, 2);
