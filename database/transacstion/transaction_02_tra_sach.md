# Transaction 2 – Trả sách

## Mục đích

Đảm bảo quá trình trả sách được thực hiện đầy đủ và đồng bộ giữa phiếu mượn và số lượng sách còn lại.

## Các Action

1. Kiểm tra phiếu mượn có tồn tại.
2. Kiểm tra phiếu mượn đang ở trạng thái Đang mượn.
3. Lấy thông tin sách trong phiếu mượn.
4. Tăng số lượng sách còn lại.
5. Cập nhật trạng thái phiếu mượn thành Đã trả.
6. Xác nhận giao dịch.

## Luồng Transaction

START TRANSACTION
→ Kiểm tra phiếu mượn
→ Kiểm tra trạng thái
→ Lấy sách
→ Tăng số lượng sách còn
→ Cập nhật trạng thái phiếu
→ COMMIT

Nếu có lỗi:
→ ROLLBACK

## Database Object

Stored Procedure: sp_tra_sach

## Kiểm thử

### Thành công

Trả phiếu mượn đang có trạng thái `DangMuon`.

Kết quả:

- Phiếu mượn chuyển thành `DaTra`.
- `SoLuongCon` của sách tăng lên 1.
- Transaction được COMMIT.

### Thất bại

Thực hiện trả lại phiếu đã có trạng thái `DaTra`.

Kết quả:

- Phát sinh lỗi `Phieu muon da duoc tra`.
- Không thay đổi dữ liệu.
- Transaction được ROLLBACK.