USE QLThuVien;

-- =========================================
-- KIỂM TRA DỮ LIỆU TRƯỚC KHI TEST
-- =========================================

SELECT * FROM SACH ORDER BY MaSach;

-- =========================================
-- TEST 1: UPDATE hợp lệ -> phải thành công
-- =========================================

UPDATE SACH SET SoLuongCon = SoLuongCon - 1 WHERE MaSach = 1;

SELECT * FROM SACH WHERE MaSach = 1;

-- =========================================
-- TEST 2: UPDATE vượt quá SoLuong -> phải báo lỗi
-- Lỗi mong đợi: "SoLuongCon khong the vuot qua SoLuong"
-- =========================================

UPDATE SACH SET SoLuongCon = SoLuong + 1 WHERE MaSach = 1;

-- Dữ liệu không được thay đổi so với sau TEST 1
SELECT * FROM SACH WHERE MaSach = 1;

-- =========================================
-- TEST 3: UPDATE thành số âm -> phải báo lỗi
-- Lỗi mong đợi: "SoLuongCon khong the am"
-- =========================================

UPDATE SACH SET SoLuongCon = -1 WHERE MaSach = 1;

SELECT * FROM SACH WHERE MaSach = 1;

-- =========================================
-- TEST 4: INSERT vi phạm ràng buộc -> phải báo lỗi
-- =========================================

INSERT INTO SACH (TenSach, SoLuong, SoLuongCon) VALUES ('Sach Test', 2, 5);

SELECT * FROM SACH ORDER BY MaSach;
