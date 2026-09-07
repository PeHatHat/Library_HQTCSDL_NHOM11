USE QLThuVien;

-- =========================================
-- KIỂM TRA DỮ LIỆU TRƯỚC KHI TEST
-- =========================================

SELECT
    PM.MaPM,
    PM.MaDG,
    PM.NgayMuon,
    PM.TrangThai,
    CT.MaSach,
    CT.HanTra
FROM PHIEUMUON PM
JOIN CT_PHIEUMUON CT
    ON PM.MaPM = CT.MaPM
ORDER BY PM.MaPM;


-- =========================================
-- TEST 1: GIA HẠN THÀNH CÔNG
-- =========================================

-- Giả sử tạo một phiếu mượn mới trước khi test.
-- Sau đó lấy MaPM của phiếu đang DangMuon.

SELECT
    PM.MaPM,
    PM.TrangThai,
    CT.MaSach,
    CT.HanTra
FROM PHIEUMUON PM
JOIN CT_PHIEUMUON CT
    ON PM.MaPM = CT.MaPM
WHERE PM.TrangThai = 'DangMuon';


-- Ví dụ nếu MaPM = 2:
CALL sp_gia_han_sach(2);


-- Kiểm tra hạn trả mới
SELECT
    PM.MaPM,
    PM.TrangThai,
    CT.MaSach,
    CT.HanTra
FROM PHIEUMUON PM
JOIN CT_PHIEUMUON CT
    ON PM.MaPM = CT.MaPM
WHERE PM.MaPM = 2;


-- =========================================
-- TEST 2: ROLLBACK
-- =========================================

-- Nếu phiếu MaPM = 1 đã được trả ở Transaction 2
-- thì không thể gia hạn.

CALL sp_gia_han_sach(1);


-- Kiểm tra dữ liệu không thay đổi
SELECT
    PM.MaPM,
    PM.TrangThai,
    CT.MaSach,
    CT.HanTra
FROM PHIEUMUON PM
JOIN CT_PHIEUMUON CT
    ON PM.MaPM = CT.MaPM
WHERE PM.MaPM = 1;


-- =========================================
-- TEST 3: PHIẾU KHÔNG TỒN TẠI
-- =========================================

CALL sp_gia_han_sach(9999);