USE QLThuVien;

DROP PROCEDURE IF EXISTS sp_LichSuMuonDocGia;

DELIMITER //

CREATE PROCEDURE sp_LichSuMuonDocGia(IN p_MaDG INT)
READS SQL DATA
BEGIN
    DECLARE v_SoDocGia INT DEFAULT 0;

    IF p_MaDG IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ma doc gia khong duoc de trong';
    END IF;

    SELECT COUNT(*)
    INTO v_SoDocGia
    FROM DOCGIA
    WHERE MaDG = p_MaDG;

    IF v_SoDocGia = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Doc gia khong ton tai';
    END IF;

    SELECT
        PM.MaPM,
        DG.MaDG,
        DG.HoTen,
        S.MaSach,
        S.TenSach,
        PM.NgayMuon,
        CT.HanTra,
        fn_SoNgayMuon(DATE(PM.NgayMuon), CT.HanTra) AS SoNgayMuon,
        PM.TrangThai
    FROM DOCGIA DG
    LEFT JOIN PHIEUMUON PM ON DG.MaDG = PM.MaDG
    LEFT JOIN CT_PHIEUMUON CT ON PM.MaPM = CT.MaPM
    LEFT JOIN SACH S ON CT.MaSach = S.MaSach
    WHERE DG.MaDG = p_MaDG
    ORDER BY PM.NgayMuon DESC, PM.MaPM DESC;
END //

DELIMITER ;
