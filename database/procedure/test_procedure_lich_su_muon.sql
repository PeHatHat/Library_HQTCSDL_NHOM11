USE QLThuVien;

-- TEST 1: Doc gia ton tai va da co lich su muon.
-- Mong doi: tra ve lich su cua doc gia MaDG = 1.
CALL sp_LichSuMuonDocGia(1);

-- TEST 2: Doc gia ton tai nhung co the chua muon sach.
-- Mong doi: van tra ve thong tin doc gia; thong tin phieu co the NULL.
CALL sp_LichSuMuonDocGia(2);

-- Hai test loi ben duoi nen chay RIENG tung cau trong MySQL Workbench.

-- TEST 3: Ma doc gia khong ton tai.
-- Mong doi: Error Code 1644 - Doc gia khong ton tai.
CALL sp_LichSuMuonDocGia(9999);

-- TEST 4: Ma doc gia rong.
-- Mong doi: Error Code 1644 - Ma doc gia khong duoc de trong.
CALL sp_LichSuMuonDocGia(NULL);
