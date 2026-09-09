-- DEMO 14 - LOST UPDATE - SESSION A
-- Mở 1 tab/kết nối MySQL riêng, USE QLThuVien, rồi chạy file này.
-- Chạy file demo_14_session_B.sql ở 1 tab/kết nối KHÁC ngay trong lúc
-- Session A đang chờ (SLEEP 3 giây bên trong procedure).

USE QLThuVien;

SELECT SoLuongCon FROM SACH WHERE MaSach = 2; -- Kiểm tra trước: kỳ vọng 3

CALL sp_muon_sach_khongkhoa(1, 2);

SELECT SoLuongCon FROM SACH WHERE MaSach = 2; -- Sau khi cả 2 Session xong: SAI nếu chỉ còn 2 (đúng ra phải còn 1)
SELECT * FROM PHIEUMUON WHERE TrangThai = 'DangMuon';
