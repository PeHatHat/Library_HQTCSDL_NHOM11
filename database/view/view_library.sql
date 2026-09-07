USE QLThuVien;

-- VIEW 1: Danh sách sách
-- Dữ liệu: MaSach, TenSach, SoLuong, SoLuongCon
CREATE OR REPLACE VIEW vw_DanhSachSach AS
SELECT MaSach, TenSach, SoLuong, SoLuongCon
FROM SACH;

-- VIEW 2: Danh sách độc giả
-- Dữ liệu: MaDG, HoTen, TrangThai
CREATE OR REPLACE VIEW vw_DanhSachDocGia AS
SELECT MaDG, HoTen, TrangThai
FROM DOCGIA;

-- VIEW 3: Danh sách sách đang được mượn
-- Dữ liệu: MaPM, HoTen, TenSach, NgayMuon, HanTra, TrangThai
CREATE OR REPLACE VIEW vw_SachDangMuon AS
SELECT 
    PM.MaPM,
    DG.HoTen,
    S.TenSach,
    PM.NgayMuon,
    CT.HanTra,
    PM.TrangThai
FROM PHIEUMUON PM
JOIN DOCGIA DG ON PM.MaDG = DG.MaDG
JOIN CT_PHIEUMUON CT ON PM.MaPM = CT.MaPM
JOIN SACH S ON CT.MaSach = S.MaSach
WHERE PM.TrangThai = 'DangMuon';

-- VIEW 4: Sách đã hết
CREATE OR REPLACE VIEW vw_SachHet AS
SELECT MaSach, TenSach, SoLuong, SoLuongCon
FROM SACH
WHERE SoLuongCon = 0;