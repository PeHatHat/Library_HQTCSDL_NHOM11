USE QLThuVien;

-- ====================================================================
-- DEMO 18: DEADLOCK (BẾ TẮC - KHÓA CHÉO NHAU)
-- ====================================================================
-- Mô tả:
--   Minh họa tình huống 2 Transaction khóa chéo nhau:
--   - Transaction A khóa Sách 1, sau đó xin khóa Sách 2.
--   - Transaction B khóa Sách 2, sau đó xin khóa Sách 1.
--   => Tạo thành chu trình chờ khóa vòng tròn (Cyclic Dependency).
--   => MySQL InnoDB tự động phát hiện và Rollback một Transaction (Victim),
--      báo lỗi: ERROR 1213 (40001): Deadlock found when trying to get lock.
--
-- File kịch bản chạy song song 2 Session:
--   - Session A: database/demo/demo_18_session_A.sql
--   - Session B: database/demo/demo_18_session_B.sql
-- ====================================================================

DROP PROCEDURE IF EXISTS sp_demo_deadlock_t1;
DROP PROCEDURE IF EXISTS sp_demo_deadlock_t2;

DELIMITER //

-- Thủ tục cho Session A: Khóa Sách 1 -> Chờ -> Khóa Sách 2
CREATE PROCEDURE sp_demo_deadlock_t1(
    IN p_MaSachA INT,
    IN p_MaSachB INT,
    IN p_DelaySec INT
)
BEGIN
    START TRANSACTION;

    -- Bước 1: Khóa dòng sách thứ nhất
    UPDATE SACH 
    SET SoLuongCon = SoLuongCon - 1 
    WHERE MaSach = p_MaSachA;

    -- Tạm dừng để Session B kịp khóa sách thứ hai
    IF p_DelaySec > 0 THEN
        SELECT SLEEP(p_DelaySec) INTO @dummy;
    END IF;

    -- Bước 2: Xin khóa dòng sách thứ hai (mà Session B đang nắm giữ)
    UPDATE SACH 
    SET SoLuongCon = SoLuongCon - 1 
    WHERE MaSach = p_MaSachB;

    COMMIT;
END //

-- Thủ tục cho Session B: Khóa Sách 2 -> Chờ -> Khóa Sách 1
CREATE PROCEDURE sp_demo_deadlock_t2(
    IN p_MaSachB INT,
    IN p_MaSachA INT,
    IN p_DelaySec INT
)
BEGIN
    START TRANSACTION;

    -- Bước 1: Khóa dòng sách thứ hai
    UPDATE SACH 
    SET SoLuongCon = SoLuongCon - 1 
    WHERE MaSach = p_MaSachB;

    -- Tạm dừng để khớp nhịp với Session A
    IF p_DelaySec > 0 THEN
        SELECT SLEEP(p_DelaySec) INTO @dummy;
    END IF;

    -- Bước 2: Xin khóa dòng sách thứ nhất (mà Session A đang nắm giữ) -> KÍCH HOẠT DEADLOCK!
    UPDATE SACH 
    SET SoLuongCon = SoLuongCon - 1 
    WHERE MaSach = p_MaSachA;

    COMMIT;
END //

DELIMITER ;
