# Transaction 1 – Mượn sách

## Mục đích

Đảm bảo quá trình mượn sách được thực hiện đầy đủ và đồng bộ
giữa độc giả, phiếu mượn, chi tiết phiếu mượn và số lượng sách còn lại.

## Các Action

1. Kiểm tra độc giả có tồn tại và đang hoạt động.
2. Kiểm tra sách có tồn tại.
3. Kiểm tra sách còn có thể cho mượn.
4. Tạo phiếu mượn.
5. Tạo chi tiết phiếu mượn.
6. Cập nhật số lượng sách còn lại.
7. Xác nhận giao dịch.

## Luồng Transaction

START TRANSACTION
→ Kiểm tra độc giả
→ Kiểm tra sách
→ Kiểm tra số lượng
→ Tạo phiếu mượn
→ Tạo chi tiết
→ Cập nhật số lượng
→ COMMIT

Nếu có lỗi:
→ ROLLBACK

## Database Object

Stored Procedure:
sp_muon_sach

## Kiểm thử

### Thành công
MaDG = 1, MaSach = 1

Kết quả:
- Tạo PHIEUMUON
- Tạo CT_PHIEUMUON
- SoLuongCon giảm 1
- COMMIT

### Thất bại
MaDG = 1, MaSach = 3

Kết quả:
- Sách hết
- Phát sinh lỗi "Sach da het"
- ROLLBACK
- Không tạo phiếu mượn mới