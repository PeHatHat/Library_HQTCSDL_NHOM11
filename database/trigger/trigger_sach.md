# Trigger – Bảo vệ số lượng sách còn lại (SoLuongCon)

## Mục đích

Tự động chặn mọi thao tác INSERT/UPDATE trên bảng SACH khiến dữ liệu vi phạm
ràng buộc nghiệp vụ, kể cả khi thao tác đó không đi qua Stored Procedure
(sp_muon_sach, sp_tra_sach...).

## Thao tác cần tự động hóa

- SoLuongCon không được nhỏ hơn 0.
- SoLuongCon không được lớn hơn SoLuong (số lượng nhập/tổng).

Đây là nghiệp vụ chỉ có 1 Action kiểm tra + chặn dữ liệu sai ngay khi ghi,
nên phù hợp làm Trigger (khác với Transaction 1/2/3 vốn có nhiều Action nối
tiếp nhau).

## Database Object

- Trigger: trg_sach_before_insert (BEFORE INSERT ON SACH)
- Trigger: trg_sach_before_update (BEFORE UPDATE ON SACH)

## Kiểm thử

### Thành công

UPDATE SACH SET SoLuongCon = SoLuongCon - 1 WHERE MaSach = 1;
(Với SoLuongCon hiện tại > 0 và <= SoLuong sau khi trừ)

Kết quả: Update thành công bình thường.

### Thất bại – Vượt quá SoLuong

UPDATE SACH SET SoLuongCon = SoLuong + 1 WHERE MaSach = 1;

Kết quả: Lỗi "SoLuongCon khong the vuot qua SoLuong", dữ liệu không đổi.

### Thất bại – Âm

UPDATE SACH SET SoLuongCon = -1 WHERE MaSach = 1;

Kết quả: Lỗi "SoLuongCon khong the am", dữ liệu không đổi.

### Thất bại khi INSERT

INSERT INTO SACH (TenSach, SoLuong, SoLuongCon) VALUES ('Sach X', 2, 5);

Kết quả: Lỗi "SoLuongCon khong the vuot qua SoLuong", không tạo dòng mới.
