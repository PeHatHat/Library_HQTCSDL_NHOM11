USE QLThuVien;

-- =========================================
-- KIỂM TRA DỮ LIỆU TRƯỚC KHI TEST
-- =========================================

SELECT *
FROM PHIEUMUON
ORDER BY MaPM;

SELECT *
FROM CT_PHIEUMUON
ORDER BY MaPM;

SELECT *
FROM SACH
ORDER BY MaSach;


-- =========================================
-- TEST 1: TRẢ SÁCH THÀNH CÔNG
-- =========================================

-- Giả sử MaPM = 1 là phiếu đang mượn

CALL sp_tra_sach(1);


-- Kiểm tra phiếu đã chuyển sang DaTra
SELECT *
FROM PHIEUMUON
WHERE MaPM = 1;

-- Kiểm tra số lượng sách đã tăng
SELECT *
FROM SACH
WHERE MaSach = 1;


-- =========================================
-- TEST 2: ROLLBACK
-- =========================================

-- Gọi lại cùng phiếu đã trả
-- Kết quả phải báo lỗi:
-- "Phieu muon da duoc tra"

CALL sp_tra_sach(1);


-- Kiểm tra dữ liệu không bị thay đổi thêm
SELECT *
FROM PHIEUMUON
WHERE MaPM = 1;

SELECT *
FROM SACH
WHERE MaSach = 1;


-- =========================================
-- TEST 3: PHIẾU KHÔNG TỒN TẠI
-- =========================================

CALL sp_tra_sach(9999);