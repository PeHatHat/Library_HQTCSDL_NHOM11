# Task 12 - Thiet ke TRIGGER kiem soat so luong sach

## Van de can tu dong hoa

Khong cho phep du lieu ton kho sach roi vao trang thai khong hop le khi them hoac cap nhat sach.

## Quy tac nghiep vu

- `SoLuong` khong duoc nho hon 0.
- `SoLuongCon` khong duoc nho hon 0.
- `SoLuongCon` khong duoc lon hon `SoLuong`.

## Trigger de xuat

### 1. trg_Sach_Validate_Before_Insert

- Thoi diem: `BEFORE INSERT`.
- Bang: `SACH`.
- Neu vi pham quy tac, dung `SIGNAL SQLSTATE '45000'` de huy thao tac.

### 2. trg_Sach_Validate_Before_Update

- Thoi diem: `BEFORE UPDATE`.
- Bang: `SACH`.
- Neu vi pham quy tac, dung `SIGNAL SQLSTATE '45000'` de huy thao tac.

## Thu tu kiem tra

1. Neu `NEW.SoLuong < 0`, bao `Tong so luong sach khong hop le`.
2. Neu `NEW.SoLuongCon < 0`, bao `So luong sach con khong hop le`.
3. Neu `NEW.SoLuongCon > NEW.SoLuong`, bao `So luong con khong duoc lon hon tong so luong`.

## Kich ban kiem thu cho Task 13

| Truong hop | SoLuong | SoLuongCon | Mong doi |
|---|---:|---:|---|
| Hop le | 10 | 8 | Thanh cong |
| Tong am | -1 | 0 | Bi chan |
| So luong con am | 10 | -1 | Bi chan |
| So luong con lon hon tong | 10 | 11 | Bi chan |

## Pham vi phoi hop

Task 12 chi thiet ke nghiep vu. Thanh vien phu trach Task 13 se viet hai trigger va file test dua tren tai lieu nay.
