-- DEMO 14 - LOST UPDATE - SESSION B
-- Mở 1 tab/kết nối MySQL KHÁC (khác với Session A), USE QLThuVien.
-- Chạy file này khoảng 0.5 - 1 giây SAU khi bấm chạy demo_14_session_A.sql,
-- để cả 2 Session cùng đọc SoLuongCon trong lúc procedure đang SLEEP(3).

USE QLThuVien;

CALL sp_muon_sach_khongkhoa(3, 2);

SELECT SoLuongCon FROM SACH WHERE MaSach = 2;
SELECT * FROM PHIEUMUON WHERE TrangThai = 'DangMuon';
