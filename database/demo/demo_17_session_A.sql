-- ====================================================================
-- DEMO 17 - PHANTOM READ - SESSION A (Transaction thống kê phạm vi)
-- ====================================================================
-- Hướng dẫn:
--   1. Mở tab/kết nối MySQL thứ nhất (Session A).
--   2. Chạy file này trước.
--   3. Trong lúc Session A đang SLEEP(5), nhanh chóng sang tab Session B chạy demo_17_session_B.sql.
-- ====================================================================

USE QLThuVien;

-- BƯỚC 1: ĐẶT MỨC CÔ LẬP READ COMMITTED ĐỂ MINH HỌA LỖI PHANTOM
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT '=== BẮT ĐẦU TRANSACTION THỐNG KÊ (READ COMMITTED) ===' AS ThongBao;
START TRANSACTION;

-- LẦN ĐỌC 1: Thống kê số lượng đầu sách Công nghệ thông tin
SELECT 
    'LẦN ĐỌC 1 (Trước khi Session B chèn sách mới)' AS MoTa,
    COUNT(*) AS TongDauSach,
    GROUP_CONCAT(TenSach SEPARATOR '; ') AS DanhSachSach
FROM SACH 
WHERE TheLoai = 'Công nghệ thông tin';

-- Tạm dừng 5 giây để Session B có thời gian INSERT và COMMIT
SELECT SLEEP(5);

-- LẦN ĐỌC 2: Thống kê lại trong cùng transaction
-- KẾT QUẢ SAI LỆCH (PHANTOM READ): Xuất hiện thêm sách mới do Session B vừa chèn!
SELECT 
    'LẦN ĐỌC 2 (Sau khi Session B INSERT & Commit)' AS MoTa,
    COUNT(*) AS TongDauSach,
    GROUP_CONCAT(TenSach SEPARATOR '; ') AS DanhSachSach
FROM SACH 
WHERE TheLoai = 'Công nghệ thông tin';

COMMIT;
SELECT '=== TRANSACTION THỐNG KÊ KẾT THÚC ===' AS ThongBao;

-- ====================================================================
-- ĐỐI CHỨNG VỚI KHÓA KHOẢNG (NEXT-KEY LOCK / FOR UPDATE HOẶC SERIALIZABLE)
-- Khi Session A chạy với SELECT ... FOR UPDATE trên REPEATABLE READ:
-- InnoDB sẽ khóa Gap xung quanh index 'TheLoai'.
-- Session B khi cố gắng INSERT thể loại này sẽ bị BLOCK CHỜ khóa,
-- hoàn toàn ngăn ngừa hiện tượng bóng ma!
-- ====================================================================
