USE QLThuVien;

-- =========================================
-- TRIGGER: Bảo vệ tính toàn vẹn của SoLuongCon trên bảng SACH
-- =========================================
-- Thao tác cần tự động hóa:
--   Các Stored Procedure (sp_muon_sach, sp_tra_sach) đã tự kiểm tra điều kiện
--   trước khi UPDATE, nhưng đó là kiểm tra ở tầng ứng dụng/logic nghiệp vụ.
--   Nếu có bất kỳ câu lệnh UPDATE/INSERT nào khác (thao tác tay, script khác,
--   lỗi logic phát sinh sau này...) tác động trực tiếp lên bảng SACH mà bỏ qua
--   các Stored Procedure, dữ liệu vẫn có thể bị sai (SoLuongCon âm, hoặc
--   SoLuongCon > SoLuong). Trigger đảm nhiệm việc chặn các trường hợp này ngay
--   tại tầng dữ liệu (database-level constraint), bất kể ai/đâu ghi vào bảng.

DROP TRIGGER IF EXISTS trg_sach_before_insert;
DROP TRIGGER IF EXISTS trg_sach_before_update;

DELIMITER //

CREATE TRIGGER trg_sach_before_insert
BEFORE INSERT ON SACH
FOR EACH ROW
BEGIN
    IF NEW.SoLuongCon < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'SoLuongCon khong the am';
    END IF;

    IF NEW.SoLuongCon > NEW.SoLuong THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'SoLuongCon khong the vuot qua SoLuong';
    END IF;
END //

CREATE TRIGGER trg_sach_before_update
BEFORE UPDATE ON SACH
FOR EACH ROW
BEGIN
    IF NEW.SoLuongCon < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'SoLuongCon khong the am';
    END IF;

    IF NEW.SoLuongCon > NEW.SoLuong THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'SoLuongCon khong the vuot qua SoLuong';
    END IF;
END //

DELIMITER ;
