# Demo 18 – Deadlock (Khóa chéo nhau)

## 1. Hiện tượng Deadlock
Deadlock (Bế tắc) xảy ra khi có từ 2 Transaction trở lên cùng nắm giữ khóa trên một tài nguyên (ví dụ: dòng dữ liệu Sách #1) và đồng thời yêu cầu xin cấp khóa độc quyền trên tài nguyên mà Transaction kia đang nắm giữ (ví dụ: dòng dữ liệu Sách #2). 

Kết quả tạo thành một chu trình chờ khóa vòng tròn (Cyclic Dependency):
- Transaction A chờ Transaction B nhả khóa.
- Transaction B chờ Transaction A nhả khóa.
- Không transaction nào có thể tiếp tục tự giải phóng nếu không có sự can thiệp từ bên ngoài.

```
Transaction A (Giữ khóa Sách 1) ---- Đang xin khóa Sách 2 ----> [Sách 2]
      ^                                                            |
      |                                                            |
      +---- [Sách 1] <---- Đang xin khóa Sách 1 ---- Transaction B (Giữ khóa Sách 2)
```

## 2. Cơ chế xử lý Deadlock tự động của MySQL InnoDB
- MySQL Engine tích hợp sẵn bộ phát hiện bế tắc: **InnoDB Deadlock Detector** (`innodb_deadlock_detect = ON`).
- Khi phát hiện chu trình phụ thuộc vòng, InnoDB sẽ lập tức can thiệp:
  1. Chọn một Transaction làm **"Victim"** (thường là Transaction có ít thao tác thay đổi dữ liệu / ít undo log hơn).
  2. Tự động thực hiện `ROLLBACK` đối với Transaction Victim để giải phóng khóa.
  3. Báo lỗi về Client với mã lỗi chuẩn:
     `ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction`.
  4. Cho phép Transaction còn lại tiếp tục thực thi và `COMMIT` thành công.

## 3. Kịch bản tái hiện Deadlock trên 2 Session MySQL

Dữ liệu giả định: 2 cuốn sách trong bảng `SACH`:
- Cuốn Sách #1 (`MaSach = 1`)
- Cuốn Sách #2 (`MaSach = 2`)

### Trình tự các bước thực hiện:

| Mốc thời gian | Thao tác tại Session A (Thủ thư 1) | Thao tác tại Session B (Thủ thư 2) | Trạng thái khóa InnoDB |
| :---: | :--- | :--- | :--- |
| **T1** | `START TRANSACTION;`<br>`UPDATE SACH SET SoLuongCon = SoLuongCon - 1 WHERE MaSach = 1;` | | Session A giữ Exclusive Lock (X-Lock) trên Sách #1 |
| **T2** | | `START TRANSACTION;`<br>`UPDATE SACH SET SoLuongCon = SoLuongCon - 1 WHERE MaSach = 2;` | Session B giữ Exclusive Lock (X-Lock) trên Sách #2 |
| **T3** | `UPDATE SACH SET SoLuongCon = SoLuongCon - 1 WHERE MaSach = 2;` | | Session A xin khóa Sách #2 -> **Bị TREO (Lock Wait)** vì Session B đang giữ |
| **T4** | | `UPDATE SACH SET SoLuongCon = SoLuongCon - 1 WHERE MaSach = 1;` | Session B xin khóa Sách #1 -> **DEADLOCK PHÁT HIỆN!** |
| **T5** | **TIẾP TỤC THÀNH CÔNG:**<br>Session A được giải phóng khóa và chạy tiếp. | **BỊ ROLLBACK BỞI CSDL:**<br>Nhận lỗi: `ERROR 1213 (40001): Deadlock found...` | InnoDB tự động giải thoát bế tắc. |

---

## 4. Cách phòng ngừa và khắc phục Deadlock trong thiết kế CSDL

### Nguyên tắc 1: Chuẩn hóa thứ tự truy xuất tài nguyên (Lock Ordering)
- **Quy tắc vàng:** Tất cả các Stored Procedures, Transactions khi cập nhật nhiều bản ghi phải luôn luôn khóa tài nguyên theo một thứ tự xác định duy nhất (ví dụ: theo thứ tự tăng dần của Khóa chính `MaSach ASC`).
- **Ví dụ:** Khi độc giả mượn cả Sách #1 và Sách #2:
  - Thủ tục luôn khóa Sách nhỏ trước (`MaSach = 1`), sau đó mới khóa Sách lớn (`MaSach = 2`).
  - Khi cả hai Session đều tuân thủ thứ tự `1 -> 2`, Session nào đến trước sẽ khóa được Sách 1, Session sau sẽ phải chờ ngay tại Sách 1, **loại bỏ 100% khả năng xảy ra chu trình chờ chéo!**

### Nguyên tắc 2: Thu hẹp phạm vi và thời gian giao dịch
- Không đặt các tương tác người dùng, xử lý tính toán phức tạp hoặc câu lệnh mạng chậm bên trong transaction.
- Mở transaction, thực hiện cập nhật và `COMMIT` càng nhanh càng tốt.

### Nguyên tắc 3: Xử lý ngoại lệ Deadlock (Retry Logic)
- Bắt lỗi `SQLSTATE '40001' / ERROR 1213` ở tầng Stored Procedure hoặc Backend:
  ```sql
  DECLARE CONTINUE HANDLER FOR 1213
  BEGIN
      -- Log và thực hiện thử lại giao dịch (Retry)
  END;
  ```
