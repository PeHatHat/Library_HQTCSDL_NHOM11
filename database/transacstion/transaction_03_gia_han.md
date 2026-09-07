# Transaction 3 – Gia hạn sách

## Mục đích

Đảm bảo việc gia hạn sách chỉ được thực hiện khi phiếu mượn còn hiệu lực và sách chưa được trả.

## Các Action

1. Kiểm tra phiếu mượn có tồn tại.
2. Kiểm tra sách chưa được trả.
3. Kiểm tra điều kiện gia hạn.
4. Cập nhật hạn trả mới.
5. Xác nhận giao dịch.

## Luồng Transaction

START TRANSACTION
→ Kiểm tra phiếu mượn
→ Kiểm tra trạng thái sách
→ Kiểm tra điều kiện gia hạn
→ Cập nhật hạn trả
→ COMMIT

Nếu có lỗi:
→ ROLLBACK

## Database Object

Stored Procedure: sp_gia_han_sach

## Kiểm thử

### Thành công

Gia hạn một phiếu mượn đang có trạng thái `DangMuon` và chưa quá hạn.

Kết quả:

- `HanTra` được tăng thêm 14 ngày.
- Transaction được COMMIT.

### Thất bại

Gia hạn một phiếu đã có trạng thái `DaTra`.

Kết quả:

- Phát sinh lỗi `Sach da duoc tra, khong the gia han`.
- `HanTra` không thay đổi.
- Transaction được ROLLBACK.