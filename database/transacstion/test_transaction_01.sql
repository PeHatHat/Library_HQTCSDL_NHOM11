USE QLThuVien;

-- TEST 1: Mượn thành công
CALL sp_muon_sach(1, 1);

SELECT *
FROM PHIEUMUON
ORDER BY MaPM DESC
LIMIT 1;

SELECT *
FROM CT_PHIEUMUON
ORDER BY MaPM DESC
LIMIT 1;

SELECT *
FROM SACH
WHERE MaSach = 1;


-- TEST 2: Độc giả bị khóa
CALL sp_muon_sach(2, 1);


-- TEST 3: Sách hết
CALL sp_muon_sach(1, 3);


-- TEST 4: Sách không tồn tại
CALL sp_muon_sach(1, 999);