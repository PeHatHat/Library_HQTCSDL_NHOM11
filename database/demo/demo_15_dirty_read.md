# Demo 15 – Dirty Read

## Hiện tượng

Dirty Read xảy ra khi 1 Transaction đọc được dữ liệu do 1 Transaction khác
ghi ra nhưng CHƯA COMMIT. Nếu Transaction kia sau đó ROLLBACK, dữ liệu vừa
đọc trở thành dữ liệu "không có thật".

## Nguyên nhân

Session đọc dùng mức cô lập (isolation level) `READ UNCOMMITTED`, cho phép
đọc cả dữ liệu chưa COMMIT của Transaction khác.

## Cách tái hiện

Dữ liệu giả định: SACH có MaSach = 1, SoLuongCon = 5.

### Session A (Transaction ghi, cố tình chưa COMMIT ngay)

```sql
START TRANSACTION;

UPDATE SACH
SET SoLuongCon = SoLuongCon - 1
WHERE MaSach = 1;

-- Chưa COMMIT, giữ Transaction mở
SELECT SLEEP(5);

-- Sau khi Session B đã đọc xong ở bước giữa, huỷ thay đổi
ROLLBACK;
```

### Session B (Transaction đọc, dùng READ UNCOMMITTED)

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Chờ để chắc chắn Session A đã UPDATE nhưng chưa COMMIT
SELECT SLEEP(2);

-- (1) Đọc trong lúc Session A chưa COMMIT
SELECT SoLuongCon FROM SACH WHERE MaSach = 1;

-- Chờ đến khi Session A ROLLBACK
SELECT SLEEP(5);

-- (2) Đọc lại sau khi Session A đã ROLLBACK
SELECT SoLuongCon FROM SACH WHERE MaSach = 1;
```

## Kết quả mong đợi (SAI – thể hiện Dirty Read)

- Lần đọc (1) của Session B trả về `SoLuongCon = 4` — giá trị Session A
  chưa hề COMMIT.
- Session A sau đó ROLLBACK, dữ liệu thật sự trong CSDL vẫn là `5`.
- Lần đọc (2) của Session B trả về lại `SoLuongCon = 5`.
- => Giá trị `4` mà Session B đọc được ở lần (1) là dữ liệu "ảo", chưa từng
  tồn tại chính thức trong CSDL — đó chính là Dirty Read.

## Cách khắc phục

Đặt Session B ở mức cô lập mặc định của MySQL/MariaDB là `REPEATABLE READ`
(hoặc tối thiểu `READ COMMITTED`) thay vì `READ UNCOMMITTED`. Khi đó Session B
sẽ không đọc được dữ liệu chưa COMMIT của Session A.
