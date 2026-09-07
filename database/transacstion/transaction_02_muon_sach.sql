USE QLThuVien;

DROP PROCEDURE IF EXISTS sp_muon_sach;

DELIMITER //

CREATE PROCEDURE sp_muon_sach(
    IN p_MaDG INT,
    IN p_MaSach INT
)
BEGIN
    DECLARE v_TrangThaiDG VARCHAR(20);
    DECLARE v_SoLuongCon INT;
    DECLARE v_MaPM INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT TrangThai
    INTO v_TrangThaiDG
    FROM DOCGIA
    WHERE MaDG = p_MaDG
    FOR UPDATE;

    IF v_TrangThaiDG IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Doc gia khong ton tai';
    END IF;

    IF v_TrangThaiDG <> 'HoatDong' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Doc gia dang bi khoa';
    END IF;

    SELECT SoLuongCon
    INTO v_SoLuongCon
    FROM SACH
    WHERE MaSach = p_MaSach
    FOR UPDATE;

    IF v_SoLuongCon IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sach khong ton tai';
    END IF;

    IF v_SoLuongCon <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sach da het';
    END IF;

    INSERT INTO PHIEUMUON (MaDG, TrangThai)
    VALUES (p_MaDG, 'DangMuon');

    SET v_MaPM = LAST_INSERT_ID();

    INSERT INTO CT_PHIEUMUON (MaPM, MaSach, HanTra)
    VALUES (
        v_MaPM,
        p_MaSach,
        DATE_ADD(CURDATE(), INTERVAL 14 DAY)
    );

    UPDATE SACH
    SET SoLuongCon = SoLuongCon - 1
    WHERE MaSach = p_MaSach;

    COMMIT;
END //

DELIMITER ;