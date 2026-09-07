USE QLThuVien;

DROP PROCEDURE IF EXISTS sp_gia_han_sach;

DELIMITER //

CREATE PROCEDURE sp_gia_han_sach(
    IN p_MaPM INT
)
BEGIN
    DECLARE v_TrangThai VARCHAR(20);
    DECLARE v_HanTra DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Kiểm tra phiếu mượn
    SELECT TrangThai
    INTO v_TrangThai
    FROM PHIEUMUON
    WHERE MaPM = p_MaPM
    FOR UPDATE;

    IF v_TrangThai IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phieu muon khong ton tai';
    END IF;

    -- 2. Kiểm tra sách chưa được trả
    IF v_TrangThai <> 'DangMuon' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sach da duoc tra, khong the gia han';
    END IF;

    -- Lấy hạn trả hiện tại
    SELECT HanTra
    INTO v_HanTra
    FROM CT_PHIEUMUON
    WHERE MaPM = p_MaPM
    LIMIT 1
    FOR UPDATE;

    IF v_HanTra IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chi tiet phieu muon khong ton tai';
    END IF;

    -- 3. Kiểm tra điều kiện gia hạn
    -- Không cho gia hạn nếu đã quá hạn
    IF v_HanTra < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sach da qua han, khong the gia han';
    END IF;

    -- 4. Gia hạn thêm 14 ngày
    UPDATE CT_PHIEUMUON
    SET HanTra = DATE_ADD(HanTra, INTERVAL 14 DAY)
    WHERE MaPM = p_MaPM;

    -- 5. Xác nhận transaction
    COMMIT;
END //

DELIMITER ;