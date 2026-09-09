USE QLThuVien;

-- =========================================
-- TEST TRIGGER - dung dung 4 case trong bang kich ban kiem thu
-- cua trigger_validate_so_luong_design.md (Task 12)
-- =========================================

-- Don dep sach test cu (neu chay lai nhieu lan)
DELETE FROM SACH WHERE TenSach LIKE 'Test_Trigger_%';

-- =========================================
-- CASE 1: Hop le (SoLuong=10, SoLuongCon=8) -> Thanh cong
-- =========================================
INSERT INTO SACH (TenSach, SoLuong, SoLuongCon)
VALUES ('Test_Trigger_HopLe', 10, 8);

SELECT * FROM SACH WHERE TenSach = 'Test_Trigger_HopLe';

-- =========================================
-- CASE 2: Tong am (SoLuong=-1, SoLuongCon=0) -> Bi chan
-- Loi mong doi: "Tong so luong sach khong hop le"
-- =========================================
INSERT INTO SACH (TenSach, SoLuong, SoLuongCon)
VALUES ('Test_Trigger_TongAm', -1, 0);

-- =========================================
-- CASE 3: So luong con am (SoLuong=10, SoLuongCon=-1) -> Bi chan
-- Loi mong doi: "So luong sach con khong hop le"
-- =========================================
INSERT INTO SACH (TenSach, SoLuong, SoLuongCon)
VALUES ('Test_Trigger_ConAm', 10, -1);

-- =========================================
-- CASE 4: So luong con lon hon tong (SoLuong=10, SoLuongCon=11) -> Bi chan
-- Loi mong doi: "So luong con khong duoc lon hon tong so luong"
-- =========================================
INSERT INTO SACH (TenSach, SoLuong, SoLuongCon)
VALUES ('Test_Trigger_ConLonHonTong', 10, 11);

-- Kiem tra: chi co dung 1 dong Test_Trigger_HopLe duoc tao,
-- 3 case con lai phai bi chan, khong co dong nao duoc them.
SELECT * FROM SACH WHERE TenSach LIKE 'Test_Trigger_%';

-- =========================================
-- CASE 5 (bo sung): UPDATE vi pham -> Bi chan
-- Ap dung lai dung quy tac tren cho UPDATE, dam bao trigger Update
-- hoat dong dong nhat voi trigger Insert
-- =========================================
UPDATE SACH SET SoLuongCon = SoLuong + 1
WHERE TenSach = 'Test_Trigger_HopLe';

SELECT * FROM SACH WHERE TenSach = 'Test_Trigger_HopLe';
