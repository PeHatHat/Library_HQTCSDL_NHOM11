USE QLThuVien;

DROP PROCEDURE IF EXISTS sp_tra_sach;

DELIMITER //

CREATE PROCEDURE sp_tra_sach(
    IN p_MaPM INT
)
BEGIN
    DECLARE v_MaSach INT;
    DECLARE v_TrangThai VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Kiểm tra phiếu mượn có tồn tại
    SELECT TrangThai
    INTO v_TrangThai
    FROM PHIEUMUON
    WHERE MaPM = p_MaPM
    FOR UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu muon khong ton tai';
    END IF;

    -- 2. Kiểm tra phiếu đang được mượn
    IF v_TrangThai <> 'DangMuon' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu muon da duoc tra';
    END IF;

    -- Lấy mã sách trong phiếu
    SELECT MaSach
    INTO v_MaSach
    FROM CT_PHIEUMUON
    WHERE MaPM = p_MaPM
    LIMIT 1
    FOR UPDATE;

    IF v_MaSach IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chi tiet phieu muon khong ton tai';
    END IF;

    -- 3. Tăng số lượng sách còn lại
    UPDATE SACH
    SET SoLuongCon = SoLuongCon + 1
    WHERE MaSach = v_MaSach;

    -- 4. Cập nhật trạng thái phiếu mượn
    UPDATE PHIEUMUON
    SET TrangThai = 'DaTra'
    WHERE MaPM = p_MaPM;

    -- 5. Xác nhận transaction
    COMMIT;
END //

DELIMITER ;