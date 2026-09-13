USE QLThuVien;

-- TASK 9: KIEM THU FUNCTION fn_SoNgayMuon
-- Ket qua mong doi: 14
SELECT fn_SoNgayMuon('2026-09-08', '2026-09-22') AS test_01_muon_14_ngay;

-- Ket qua mong doi: 0
SELECT fn_SoNgayMuon('2026-09-08', '2026-09-08') AS test_02_cung_ngay;

-- Ket qua mong doi: NULL
SELECT fn_SoNgayMuon(NULL, '2026-09-22') AS test_03_ngay_muon_null;

-- Kiem thu voi du lieu that trong he thong
SELECT
    PM.MaPM,
    PM.NgayMuon,
    CT.HanTra,
    fn_SoNgayMuon(DATE(PM.NgayMuon), CT.HanTra) AS SoNgayMuon
FROM PHIEUMUON PM
JOIN CT_PHIEUMUON CT ON PM.MaPM = CT.MaPM
ORDER BY PM.MaPM;
