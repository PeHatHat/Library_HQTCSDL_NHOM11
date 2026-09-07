USE QLThuVien;

-- TEST 1: Mượn sách thành công
CALL sp_muon_sach(1, 1);

SELECT *
FROM PHIEUMUON
ORDER BY MaPM DESC
LIMIT 1;

SELECT MaSach, TenSach, SoLuongCon
FROM SACH
WHERE MaSach = 1;


-- TEST 2: Sách đã hết
CALL sp_muon_sach(1, 3);

SELECT MaSach, TenSach, SoLuongCon
FROM SACH
WHERE MaSach = 3;

SELECT *
FROM PHIEUMUON
ORDER BY MaPM DESC;


-- TEST 3: Độc giả bị khóa
CALL sp_muon_sach(2, 1);