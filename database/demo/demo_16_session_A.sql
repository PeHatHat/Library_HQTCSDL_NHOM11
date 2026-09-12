-- ====================================================================
-- DEMO 16 - UNREPEATABLE READ - SESSION A (Transaction kiểm kê đọc 2 lần)
-- ====================================================================
-- Hướng dẫn:
--   1. Mở tab/kết nối MySQL thứ nhất (Session A).
--   2. Đảm bảo chạy file demo_16_unrepeatable_read.sql trước nếu dùng procedure.
--   3. Chạy file này trước.
--   4. Trong lúc Session A đang SLEEP(5), nhanh chóng sang tab Session B chạy demo_16_session_B.sql.
-- ====================================================================

USE QLThuVien;

-- BƯỚC 1: ĐẶT MỨC CÔ LẬP READ COMMITTED ĐỂ MINH HỌA LỖI
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT '=== BẮT ĐẦU TRANSACTION KIỂM KÊ (READ COMMITTED) ===' AS ThongBao;
START TRANSACTION;

-- LẦN ĐỌC 1: Đọc số lượng sách hiện tại (kỳ vọng thấy SoLuongCon ban đầu, vd: 5)
SELECT 'LẦN ĐỌC 1 (Trước khi Session B sửa)' AS MoTa, MaSach, TenSach, SoLuongCon 
FROM SACH 
WHERE MaSach = 1;

-- Tạm dừng 5 giây để Session B có thời gian UPDATE và COMMIT
SELECT SLEEP(5);

-- LẦN ĐỌC 2: Đọc lại cùng dòng dữ liệu trong cùng một transaction
-- KẾT QUẢ SAI LỆCH (UNREPEATABLE READ): Nhìn thấy dữ liệu mới đã COMMIT của Session B!
SELECT 'LẦN ĐỌC 2 (Sau khi Session B sửa & Commit)' AS MoTa, MaSach, TenSach, SoLuongCon 
FROM SACH 
WHERE MaSach = 1;

COMMIT;
SELECT '=== TRANSACTION KIỂM KÊ KẾT THÚC ===' AS ThongBao;

-- ====================================================================
-- ĐỐI CHỨNG VỚI REPEATABLE READ (KHÔNG CÒN LỖI):
-- Chạy lại các lệnh dưới đây sau khi đã reset lại dữ liệu:
-- ====================================================================
/*
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT 'LẦN ĐỌC 1' AS MoTa, MaSach, TenSach, SoLuongCon FROM SACH WHERE MaSach = 1;
SELECT SLEEP(5);
-- Lần 2 vẫn đọc thấy giá trị cũ (không đổi) nhờ MVCC Snapshot!
SELECT 'LẦN ĐỌC 2' AS MoTa, MaSach, TenSach, SoLuongCon FROM SACH WHERE MaSach = 1;
COMMIT;
*/
