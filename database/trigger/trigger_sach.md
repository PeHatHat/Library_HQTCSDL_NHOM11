# Task 13 – Implement Trigger kiểm soát số lượng sách

Bám sát đúng thiết kế của Task 12 (`trigger_validate_so_luong_design.md` – Thành Phát).

## Vấn đề cần tự động hóa

Không cho phép dữ liệu tồn kho sách rơi vào trạng thái không hợp lệ khi
thêm (INSERT) hoặc cập nhật (UPDATE) sách, bất kể thao tác đó có đi qua
Stored Procedure (sp_muon_sach, sp_tra_sach...) hay không.

## Quy tắc nghiệp vụ

1. `SoLuong` không được nhỏ hơn 0.
2. `SoLuongCon` không được nhỏ hơn 0.
3. `SoLuongCon` không được lớn hơn `SoLuong`.

Thứ tự kiểm tra đúng theo tài liệu Task 12: kiểm tra (1) trước, rồi (2), rồi (3).

## Database Object

- Trigger: `trg_Sach_Validate_Before_Insert` (BEFORE INSERT ON SACH)
- Trigger: `trg_Sach_Validate_Before_Update` (BEFORE UPDATE ON SACH)

## Kiểm thử (đúng bảng kịch bản của Task 12)

| Trường hợp | SoLuong | SoLuongCon | Mong đợi | Message lỗi |
|---|---:|---:|---|---|
| Hợp lệ | 10 | 8 | Thành công | — |
| Tổng âm | -1 | 0 | Bị chặn | `Tong so luong sach khong hop le` |
| Số lượng còn âm | 10 | -1 | Bị chặn | `So luong sach con khong hop le` |
| Số lượng còn lớn hơn tổng | 10 | 11 | Bị chặn | `So luong con khong duoc lon hon tong so luong` |

Đã test thêm case UPDATE vi phạm (không nằm trong bảng gốc nhưng để đảm
bảo trigger Update hoạt động đồng nhất với trigger Insert) — cũng bị chặn
đúng như mong đợi.

## Đã kiểm thử thực tế

Chạy trên MariaDB với đúng `core.sql` của repo — cả 5 case đều cho kết quả
và message lỗi khớp chính xác với thiết kế. Đã chạy lại toàn bộ
Transaction 1/2/3 và Demo 14/15 (Lost Update, Dirty Read) để xác nhận
không có gì bị ảnh hưởng khi đổi tên/logic trigger.
