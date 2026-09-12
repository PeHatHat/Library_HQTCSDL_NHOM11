USE QLThuVien;

-- ====================================================================
-- DEMO 17: PHANTOM READ (ĐỌC BÓNG MA)
-- ====================================================================
-- Mô tả:
--   Minh họa hiện tượng một giao dịch thực hiện truy vấn khoảng (Range Query)
--   nhưng xuất hiện thêm dòng mới do giao dịch khác INSERT và COMMIT ở giữa.
--
-- File kịch bản chạy song song 2 Session:
--   - Session A: database/demo/demo_17_session_A.sql
--   - Session B: database/demo/demo_17_session_B.sql
-- ====================================================================

DROP PROCEDURE IF EXISTS sp_thong_ke_the_loai_doc_2_lan;

DELIMITER //

CREATE PROCEDURE sp_thong_ke_the_loai_doc_2_lan(
    IN p_TheLoai VARCHAR(100),
    IN p_DelaySec INT
)
BEGIN
    -- Lần đọc 1: Đếm và liệt kê sách theo thể loại
    SELECT 
        'LẦN ĐỌC 1' AS ThoiDiem,
        COUNT(*) AS TongDauSach,
        GROUP_CONCAT(TenSach SEPARATOR '; ') AS DanhSachSach,
        NOW() AS ThoiGian
    FROM SACH
    WHERE TheLoai = p_TheLoai;

    -- Tạm dừng để Session B kịp INSERT
    IF p_DelaySec > 0 THEN
        SELECT SLEEP(p_DelaySec) INTO @dummy;
    END IF;

    -- Lần đọc 2: Đọc lại trong cùng Transaction
    SELECT 
        'LẦN ĐỌC 2' AS ThoiDiem,
        COUNT(*) AS TongDauSach,
        GROUP_CONCAT(TenSach SEPARATOR '; ') AS DanhSachSach,
        NOW() AS ThoiGian
    FROM SACH
    WHERE TheLoai = p_TheLoai;
END //

DELIMITER ;
