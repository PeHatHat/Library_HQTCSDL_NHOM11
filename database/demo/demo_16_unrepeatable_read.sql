USE QLThuVien;

-- ====================================================================
-- DEMO 16: NON-REPEATABLE READ (UNREPEATABLE READ)
-- ====================================================================
-- Mô tả:
--   Minh họa hiện tượng một giao dịch đọc cùng một bản ghi 2 lần
--   nhưng kết quả nhận được khác nhau do giao dịch khác UPDATE và COMMIT ở giữa.
--
-- File kịch bản chạy song song 2 Session:
--   - Session A: database/demo/demo_16_session_A.sql
--   - Session B: database/demo/demo_16_session_B.sql
-- ====================================================================

DROP PROCEDURE IF EXISTS sp_kiem_ke_doc_2_lan;

DELIMITER //

CREATE PROCEDURE sp_kiem_ke_doc_2_lan(
    IN p_MaSach INT,
    IN p_DelaySec INT
)
BEGIN
    -- Lần đọc 1
    SELECT 
        'LẦN ĐỌC 1' AS ThoiDiem,
        MaSach, 
        TenSach, 
        SoLuongCon,
        NOW() AS ThoiGian
    FROM SACH
    WHERE MaSach = p_MaSach;

    -- Giữ Transaction và chờ Session khác cập nhật
    IF p_DelaySec > 0 THEN
        SELECT SLEEP(p_DelaySec) INTO @dummy;
    END IF;

    -- Lần đọc 2: Trong cùng Transaction
    SELECT 
        'LẦN ĐỌC 2' AS ThoiDiem,
        MaSach, 
        TenSach, 
        SoLuongCon,
        NOW() AS ThoiGian
    FROM SACH
    WHERE MaSach = p_MaSach;
END //

DELIMITER ;
