USE QLThuVien;

-- =========================================
-- DEMO 14: LOST UPDATE
-- =========================================
-- Đây là 1 bản "sp_muon_sach" phiên bản KHÔNG khóa dòng (bỏ FOR UPDATE),
-- dựng riêng để tái hiện hiện tượng Lost Update. Không dùng procedure này
-- trong ứng dụng thật — ứng dụng thật phải dùng sp_muon_sach (đã có FOR UPDATE).

DROP PROCEDURE IF EXISTS sp_muon_sach_khongkhoa;

DELIMITER //

CREATE PROCEDURE sp_muon_sach_khongkhoa(
    IN p_MaDG INT,
    IN p_MaSach INT
)
BEGIN
    DECLARE v_SoLuongCon INT;
    DECLARE v_MaPM INT;

    START TRANSACTION;

    -- Đọc số lượng còn lại NHƯNG KHÔNG khóa dòng (không FOR UPDATE)
    SELECT SoLuongCon
    INTO v_SoLuongCon
    FROM SACH
    WHERE MaSach = p_MaSach;

    -- Giả lập thời gian xử lý (để 2 Transaction có cơ hội cùng đọc
    -- được giá trị cũ trước khi Transaction nào ghi xuống trước)
    DO SLEEP(3);

    IF v_SoLuongCon > 0 THEN
        INSERT INTO PHIEUMUON (MaDG, TrangThai)
        VALUES (p_MaDG, 'DangMuon');

        SET v_MaPM = LAST_INSERT_ID();

        INSERT INTO CT_PHIEUMUON (MaPM, MaSach, HanTra)
        VALUES (v_MaPM, p_MaSach, DATE_ADD(CURDATE(), INTERVAL 14 DAY));

        -- Ghi lại dựa trên giá trị v_SoLuongCon đã đọc từ trước (có thể đã cũ)
        UPDATE SACH
        SET SoLuongCon = v_SoLuongCon - 1
        WHERE MaSach = p_MaSach;
    END IF;

    COMMIT;
END //

DELIMITER ;
