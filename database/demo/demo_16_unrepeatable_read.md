# Demo 16 – Non-repeatable Read (Unrepeatable Read)

## 1. Hiện tượng
Non-repeatable Read xảy ra khi một Transaction thực hiện đọc cùng một dòng dữ liệu nhiều lần trong suốt thời gian tồn tại của nó, nhưng các lần đọc lại nhận về các giá trị khác nhau do một Transaction khác đã thực hiện `UPDATE` và `COMMIT` vào dòng dữ liệu đó ở giữa các lần đọc.

## 2. Tác động nghiệp vụ trong hệ thống Thư viện
- **Báo cáo kiểm kê không nhất quán:** Thủ thư đang kiểm kê số lượng sách `MaSach = 1` để in biên bản (lần 1 đọc thấy còn 5 cuốn). Trong lúc in ấn, độc giả ở quầy khác mượn 1 cuốn và giao dịch hoàn tất. Thủ thư bấm xác nhận (lần 2 đọc thấy còn 4 cuốn). Biên bản và báo cáo tổng kết bị mâu thuẫn số liệu.

## 3. Nguyên nhân kỹ thuật
- Giao dịch đọc được thiết lập ở mức cô lập `READ COMMITTED`.
- Ở mức này, mỗi câu lệnh `SELECT` (Consistent Nonlocking Read) đều khởi tạo một **Read View** mới tại thời điểm câu lệnh đó thực thi. Do đó, bất kỳ thay đổi nào đã được `COMMIT` bởi giao dịch khác trước thời điểm `SELECT` lần 2 đều sẽ được nhìn thấy.

## 4. Cách tái hiện trên 2 Session MySQL

Dữ liệu giả định: Sách `MaSach = 1` có `SoLuongCon = 5`.

### Session A (Transaction kiểm kê - Đọc 2 lần ở READ COMMITTED)
```sql
USE QLThuVien;

-- Thiết lập mức cô lập READ COMMITTED để thấy lỗi
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

-- Lần đọc 1: Đọc số lượng sách
SELECT MaSach, TenSach, SoLuongCon 
FROM SACH 
WHERE MaSach = 1;
-- Kết quả Lần 1: SoLuongCon = 5

-- Giả lập khoảng thời gian kiểm kê (chờ 5 giây)
SELECT SLEEP(5);

-- Lần đọc 2: Đọc lại cùng dòng dữ liệu trong cùng một Transaction
SELECT MaSach, TenSach, SoLuongCon 
FROM SACH 
WHERE MaSach = 1;
-- Kết quả Lần 2: SoLuongCon = 4 (ĐÃ BỊ THAY ĐỔI!)

COMMIT;
```

### Session B (Transaction mượn sách - Cập nhật và COMMIT trong lúc Session A đang chờ)
```sql
USE QLThuVien;

-- Chạy ngay khi Session A vừa đọc lần 1 (trong lúc Session A đang SLEEP)
START TRANSACTION;

UPDATE SACH
SET SoLuongCon = SoLuongCon - 1
WHERE MaSach = 1;

COMMIT; -- Cam kết dữ liệu mới
```

## 5. Kết quả quan sát (Lỗi Unrepeatable Read)
- Trong cùng một Transaction của Session A, hai câu lệnh `SELECT` giống hệt nhau nhưng trả về 2 kết quả khác nhau (`5` và `4`).
- Dữ liệu bị biến động giữa chừng dù Session A chưa hề kết thúc giao dịch.

## 6. Cơ chế khắc phục (REPEATABLE READ)
- Đặt mức cô lập của Session A thành **`REPEATABLE READ`** (mức mặc định của InnoDB Engine trong MySQL):
  ```sql
  SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
  ```
- **Nguyên lý bảo vệ:** Ở mức `REPEATABLE READ`, InnoDB sử dụng cơ chế **MVCC (Multi-Version Concurrency Control)**. Read View được tạo ra ngay tại thời điểm câu lệnh `SELECT` đầu tiên chạy và được duy trì không đổi trong suốt Transaction.
- Mọi câu lệnh `SELECT` sau đó đều đọc dữ liệu từ Snapshot ban đầu thông qua Undo Log, bỏ qua các thay đổi đã commit của Session B.
- Kết quả: Cả Lần 1 và Lần 2 đều trả về giá trị nhất quán là `5`.
