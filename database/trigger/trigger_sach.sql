USE QLThuVien;

-- =========================================
-- TRIGGER: Kiem soat so luong sach (bang SACH)
-- Thiet ke: Task 12 (Thanh Phat) - xem trigger_validate_so_luong_design.md
-- Implement: Task 13 (Sy Kiet)
-- =========================================
-- Van de can tu dong hoa:
--   Khong cho phep du lieu ton kho sach roi vao trang thai khong hop le
--   khi them (INSERT) hoac cap nhat (UPDATE) sach, bat ke thao tac do
--   co di qua Stored Procedure (sp_muon_sach, sp_tra_sach...) hay khong.
--
-- Quy tac nghiep vu:
--   1. SoLuong khong duoc nho hon 0.
--   2. SoLuongCon khong duoc nho hon 0.
--   3. SoLuongCon khong duoc lon hon SoLuong.

DROP TRIGGER IF EXISTS trg_Sach_Validate_Before_Insert;
DROP TRIGGER IF EXISTS trg_Sach_Validate_Before_Update;

DELIMITER //

CREATE TRIGGER trg_Sach_Validate_Before_Insert
BEFORE INSERT ON SACH
FOR EACH ROW
BEGIN
    IF NEW.SoLuong < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tong so luong sach khong hop le';
    END IF;

    IF NEW.SoLuongCon < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'So luong sach con khong hop le';
    END IF;

    IF NEW.SoLuongCon > NEW.SoLuong THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'So luong con khong duoc lon hon tong so luong';
    END IF;
END //

CREATE TRIGGER trg_Sach_Validate_Before_Update
BEFORE UPDATE ON SACH
FOR EACH ROW
BEGIN
    IF NEW.SoLuong < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tong so luong sach khong hop le';
    END IF;

    IF NEW.SoLuongCon < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'So luong sach con khong hop le';
    END IF;

    IF NEW.SoLuongCon > NEW.SoLuong THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'So luong con khong duoc lon hon tong so luong';
    END IF;
END //

DELIMITER ;
