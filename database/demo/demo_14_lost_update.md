# Demo 14 – Lost Update

## Hiện tượng

Lost Update xảy ra khi 2 Transaction cùng đọc 1 giá trị, rồi cùng ghi đè
dựa trên giá trị cũ đó — kết quả là 1 trong 2 lần cập nhật bị "mất" dù cả
2 Transaction đều COMMIT thành công.

## Nguyên nhân

Đọc dữ liệu (SELECT) mà không khóa dòng (không FOR UPDATE) trước khi ghi
đè dựa trên giá trị vừa đọc.

## Cách tái hiện

Dùng `sp_muon_sach_khongkhoa` (phiên bản KHÔNG khóa dòng của sp_muon_sach)
để 2 Session cùng mượn 1 cuốn sách gần như đồng thời.

Dữ liệu giả định: SACH có MaSach = 2, SoLuongCon = 3.

### Session A (chạy trước ~0.5–1 giây)

```sql
CALL sp_muon_sach_khongkhoa(1, 2);
```

### Session B (chạy ngay sau đó, trong lúc Session A đang SLEEP(3))

```sql
CALL sp_muon_sach_khongkhoa(3, 2);
```

### Kiểm tra kết quả sau khi cả 2 Session hoàn tất

```sql
SELECT SoLuongCon FROM SACH WHERE MaSach = 2;
SELECT COUNT(*) FROM PHIEUMUON WHERE TrangThai = 'DangMuon';
```

## Kết quả mong đợi (SAI – thể hiện Lost Update)

- Có 2 phiếu mượn (PHIEUMUON) được tạo ra cho cùng 1 cuốn sách.
- Nhưng `SoLuongCon` chỉ giảm 1 (từ 3 còn 2) thay vì phải giảm 2 (còn 1).
- Một trong hai lượt cập nhật số lượng đã bị "mất" vì cả 2 Session đều đọc
  cùng giá trị `SoLuongCon = 3` trước khi Session nào kịp ghi lại.

## Đối chiếu với bản đã sửa lỗi

Nếu thay `sp_muon_sach_khongkhoa` bằng `sp_muon_sach` (bản chính thức, có
`FOR UPDATE`) và lặp lại đúng kịch bản trên, Session B sẽ phải chờ Session A
COMMIT xong mới đọc được `SoLuongCon` mới nhất, nên `SoLuongCon` sẽ giảm
đúng 2 (còn 1). Đây chính là lý do sp_muon_sach dùng `FOR UPDATE` để khóa
dòng khi đọc.
