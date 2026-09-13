# Demo 17 – Phantom Read (Đọc bóng ma)

## 1. Hiện tượng
Phantom Read xảy ra khi một Transaction thực hiện cùng một câu truy vấn tìm kiếm theo phạm vi hoặc điều kiện (Range Query) hai lần, nhưng lần đọc sau phát hiện thêm những dòng dữ liệu mới ("bóng ma" - phantoms) do một Transaction khác vừa thực hiện `INSERT` và `COMMIT` vào tập dữ liệu đó ở giữa hai lần đọc.

## 2. Điểm khác biệt giữa Unrepeatable Read và Phantom Read
- **Unrepeatable Read:** Một dòng dữ liệu **đã tồn tại** bị thay đổi nội dung (`UPDATE` hoặc `DELETE`) giữa 2 lần đọc.
- **Phantom Read:** Một hoặc nhiều dòng dữ liệu **hoàn toàn mới** được chèn vào (`INSERT`) thỏa mãn điều kiện `WHERE` của câu truy vấn giữa 2 lần đọc.

## 3. Tác động nghiệp vụ trong hệ thống Thư viện
- **Thống kê đầu sách theo thể loại:** Thủ thư đang lập báo cáo thống kê số lượng đầu sách thuộc thể loại *'Công nghệ thông tin'* (lần 1 đếm được 5 tựa sách). Trong lúc chuẩn bị in, thủ thư ở phòng nhập liệu nhập thêm một tựa sách CNTT mới và commit. Lần 2 đếm lại ra 6 tựa sách. Dữ liệu tổng hợp giữa 2 lần xuất báo cáo bị sai lệch.

## 4. Cách tái hiện trên 2 Session MySQL

Dữ liệu giả định: Bảng `SACH` có chỉ mục `idx_sach_theloai` trên cột `TheLoai`.

### Session A (Transaction thống kê - Đọc 2 lần ở READ COMMITTED)
```sql
USE QLThuVien;

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

-- Lần đọc 1: Đếm số lượng đầu sách CNTT
SELECT COUNT(*) AS SoLuongDauSach, GROUP_CONCAT(TenSach SEPARATOR '; ') AS DanhSach
FROM SACH 
WHERE TheLoai = 'Công nghệ thông tin';
-- Kết quả Lần 1: Có N cuốn

-- Giả lập độ trễ xử lý (5 giây)
SELECT SLEEP(5);

-- Lần đọc 2: Đọc lại cùng điều kiện trong cùng Transaction
SELECT COUNT(*) AS SoLuongDauSach, GROUP_CONCAT(TenSach SEPARATOR '; ') AS DanhSach
FROM SACH 
WHERE TheLoai = 'Công nghệ thông tin';
-- Kết quả Lần 2: Xuất hiện thêm dòng mới (N + 1 cuốn - BÓNG MA XUẤT HIỆN!)

COMMIT;
```

### Session B (Transaction nhập sách mới - INSERT và COMMIT)
```sql
USE QLThuVien;

START TRANSACTION;

-- Chèn thêm một đầu sách mới thuộc thể loại CNTT
INSERT INTO SACH (TenSach, TheLoai, ViTriKe, SoLuong, SoLuongCon)
VALUES ('Kỹ Nghệ Phần Mềm Hiện Đại', 'Công nghệ thông tin', 'Kệ C3', 10, 10);

COMMIT; -- Cam kết dòng mới vào CSDL
```

## 5. Kết quả quan sát (Lỗi Phantom Read)
- Session A nhận được số lượng dòng khác nhau giữa lần 1 và lần 2 trong cùng một transaction. Dòng dữ liệu do Session B thêm vào được gọi là dòng "bóng ma".

## 6. Cơ chế khắc phục trong MySQL InnoDB

### Giải pháp 1: Mức cô lập REPEATABLE READ (Consistent Read Snapshot)
- Ở mức mặc định `REPEATABLE READ`, câu lệnh `SELECT` thông thường sử dụng MVCC Snapshot. Transaction của Session A chỉ nhìn thấy bản chụp dữ liệu được tạo ở lần đọc đầu tiên. Dù Session B có `INSERT` và `COMMIT`, Session A vẫn không nhìn thấy dòng mới này.

### Giải pháp 2: Sử dụng Next-Key Lock (Khóa Record + Khóa Gap)
- Khi cần đọc dữ liệu có khóa bảo vệ (Locking Read) để xử lý logic:
  ```sql
  SELECT * FROM SACH WHERE TheLoai = 'Công nghệ thông tin' FOR UPDATE;
  ```
- **Cơ chế Next-Key Lock:** MySQL InnoDB sẽ áp dụng **Record Lock** trên tất cả các dòng thỏa mãn điều kiện, đồng thời kích hoạt **Gap Lock** khóa toàn bộ các "khoảng trống" (gaps) xung quanh chỉ mục `idx_sach_theloai`.
- Khi Session B cố gắng `INSERT` một đầu sách mới có `TheLoai = 'Công nghệ thông tin'`, Session B sẽ lập tức bị **BLOCK (chờ khóa)** cho đến khi Session A `COMMIT`. Nhờ đó, ngăn chặn hoàn toàn hiện tượng chèn dòng bóng ma!

### Giải pháp 3: Mức cô lập SERIALIZABLE
- Thiết lập `SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;`
- Ở mức này, InnoDB tự động biến tất cả các câu `SELECT` thông thường thành `SELECT ... FOR SHARE`, tự động kích hoạt Shared Next-Key Lock trên phạm vi quét, loại bỏ triệt để bóng ma.
