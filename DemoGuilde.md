# 📋 TÀI LIỆU HƯỚNG DẪN THUYẾT TRÌNH & DEMO ĐỒ ÁN 
## HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE THÔNG MINH + CỔNG KHÁCH HÀNG VÉ THÁNG
> **Môn học:** Quản lý Thông tin / Quản trị Cơ sở Dữ liệu (IE103)  
> **Kiến trúc:** Microsoft SQL Server 2022 (Docker / port 1433) + Python Flask / pyodbc (port 5001) + giao diện web nhân viên và cổng khách hàng `/kh`  
> **Quy mô CSDL:** 21 bảng · 37 views · 23 stored procedures + 4 procedure cursor · 16 triggers · 12 functions · 4 role RBAC + Row-Level Security · **21 kịch bản demo 5 bước**  
> **Mục đích:** Cẩm nang bảo vệ đồ án, nối **bài toán thực tế** ↔ **thao tác trên web** ↔ **câu lệnh T-SQL đối chứng dưới SSMS**.

---

## 🎯 PHẦN I: CHUẨN BỊ TRƯỚC BUỔI BẢO VỆ

### 1. Khởi động SQL Server
```bash
docker ps -a                    # xem tên container SQL Server
docker start <ten_container>    # nếu container đang dừng; đợi ~20 giây cho SQL Server sẵn sàng
```

### 2. Cấu hình `.env` (thư mục gốc dự án)
```env
SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server
SQLSERVER_SERVER=localhost,1433
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=no
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=<mật khẩu sa>
PORT=5001
FLASK_SECRET_KEY=            # bỏ trống: mỗi lần khởi động sinh khóa ngẫu nhiên
KH_DEMO_ACCOUNTS=1           # hiện bảng "Tài khoản demo" trên trang đăng nhập cổng khách hàng
```

### 3. Khởi chạy web
```bash
source .venv/bin/activate
python run.py                # mở http://127.0.0.1:5001
```

### 4. Nạp CSDL (BẮT BUỘC trước mỗi buổi demo)
1. Vào **`/setup`** → hệ thống kiểm tra kết nối; khi trạng thái **CONNECTED**, khối **"Khởi tạo & nạp lại toàn bộ CSDL"** được mở khóa.
2. Bấm nạp CSDL. Full script `sql/QL_BaiDoXe_FullScript.sql` **xóa và tạo lại** `QuanLyBaiDoXe` (21 bảng, dữ liệu mẫu, procedures, triggers, views, RBAC, RLS) trong vài giây.
3. Kiểm tra khối số đếm trên `/setup`: 21 bảng, 23 stored procedures, 16 triggers, 12 functions, 4 cursors, 37 views, 4 roles + 1 RLS.
4. Cách thủ công: mở `sql/QL_BaiDoXe_FullScript.sql` trong SSMS / Azure Data Studio → Execute (F5).

> ⚠️ CSDL tạo từ phiên bản cũ chưa có phần cổng khách hàng (ví, sổ cái, tài khoản khách): các trang `/khach-hang`, `/kh` và 11 kịch bản cổng khách hàng sẽ lỗi cho tới khi nạp lại.

### 5. Bố trí màn hình
- **Trái:** trình duyệt, tab 1 là web nhân viên (`/`), tab 2 là **cửa sổ ẩn danh** mở cổng khách hàng `/kh` (sidebar → **"Cổng khách hàng ↗"**).
- **Phải:** SSMS, một cửa sổ Query đã chạy `USE QuanLyBaiDoXe;` để đối chứng số liệu trước / sau.

### 6. Lưu ý khi demo
- **Mỗi kịch bản thật sự ghi dữ liệu.** Chạy lại cùng kịch bản lần 2 có thể ra kết quả khác (ví dụ check-in lần 2 bị chặn vì thẻ đang trong bãi - 50014). Muốn quay về trạng thái ban đầu: nạp lại CSDL ở `/setup`.
- **Kịch bản trigger hiện khung lỗi đỏ là KẾT QUẢ MONG ĐỢI** (trigger chặn vi phạm và ROLLBACK). Đọc mã lỗi theo bảng ở Phần VI.
- Các kịch bản độc lập về dữ liệu nên chạy theo thứ tự tùy ý; nếu đã chạy nhiều kịch bản cổng khách hàng liên tiếp thì nạp lại CSDL trước khi vào phần hỏi đáp.

---

## 🗺️ PHẦN II: LỘ TRÌNH DEMO ĐỀ XUẤT (25 – 30 PHÚT)

| Thời lượng | Phần | Nội dung gợi ý |
|:---:|---|---|
| 3' | Mở đầu | Giới thiệu bài toán chuỗi 5 bãi; **Bốt cổng `/gate`**: quẹt `THE0001` (mở barrier) và `THE0006` (thẻ mất, từ chối) |
| 8' | Procedure | `sp-xe-vao-bai` → mở `/map` thấy ô đổi màu; `sp-xe-ra-bai`; `sp-dang-ky-thanh-vien` (transaction); `sp-cap-lai-the` |
| 5' | Trigger | `trigger-chan-checkin-loi`, `trigger-chan-ve-het-han`, `trigger-chan-sai-bai` |
| 3' | Function + Cursor | `function-tinh-tien-slot`, `cursor-canh-bao-doanh-thu` |
| 8' | Cổng khách hàng | Kịch bản `kh-nap-tien-2-pha`, `rls-co-lap-du-lieu-khach-hang`, `trigger-so-cai-bat-bien`; rồi demo trực tiếp trên `/kh` (Phần IV mục 8) |
| còn lại | Hỏi đáp | Phần V; chạy câu lệnh giảng viên yêu cầu ở SQL Studio `/sql` |

---

## 🚀 PHẦN III: 21 KỊCH BẢN DEMO 5 BƯỚC

Trang chủ `/` liệt kê 21 kịch bản theo 5 nhóm (lọc nhanh bằng chip). Mỗi trang `/demo/<mã>` đi theo 5 bước: **B1** bài toán nghiệp vụ → **B2** script T-SQL sẽ gửi tới SQL Server → **B3** snapshot dữ liệu ban đầu → **B4** bấm *Kích hoạt thực thi* → **B5** đối chiếu dữ liệu sau thực thi với B3.

### Bảng tổng hợp

| # | Mã kịch bản (`/demo/...`) | Đối tượng CSDL chính | Kết quả mong đợi |
|:---:|---|---|---|
| **⚙️ Procedure** ||||
| 1 | `sp-xe-vao-bai` | `sp_XeVaoBai`, `f_TimSlotTrong`, `trg_DongBoTrangThaiSlot` | Cấp ô đỗ, ô chuyển *Đã đỗ*, bãi +1 xe |
| 2 | `sp-xe-ra-bai` | `sp_XeRaBai`, `f_TinhTienGuiXe` | Tính tiền theo block giờ, giải phóng ô |
| 3 | `sp-dang-ky-thanh-vien` | `sp_DangKyThanhVien` (transaction 4 bước) | Khách + thẻ tháng + vé + hóa đơn cùng lúc |
| 4 | `sp-gia-han-ve-thang` | `sp_GiaHanTheThang` → `sp_GiaHanVe_Core` | Hạn +2 tháng, hóa đơn mới |
| 5 | `sp-bao-mat-the` | `sp_BaoMatThe`, `trg_LogLichSuSuCo` | Thẻ *Mất*, biên bản phạt 50.000 ₫ |
| 6 | `sp-cap-lai-the` | `sp_DangKyThanhVien`, `f_VeHienHanhCuaThe`, index có lọc | Thẻ cũ cấp cho vé mới; **50065**, **50066** |
| 7 | `sp-dang-nhap-nhan-vien` | `sp_DangNhap`, `f_BamMatKhau` | Cùng mật khẩu khác hash; **50022**, **50021** |
| **⚡ Trigger** ||||
| 8 | `trigger-chan-checkin-loi` | `trg_KiemTraCheckIn` | **50002** (thẻ mất / bị khóa) |
| 9 | `trigger-chan-ve-het-han` | `trg_ChanSuDungVeHetHan` | **50003** (vé tháng hết hạn) |
| 10 | `trigger-chan-sai-bai` | `trg_KiemTraBaiApDungVeThang` | **50004** (vé gửi sai bãi) |
| **📐 Function** ||||
| 11 | `function-tinh-tien-slot` | `f_TinhTienGuiXe`, `f_TimSlotTrong`, `f_DanhSachXeTrongBai` | Bảng kết quả 3 hàm |
| **🔄 Cursor** ||||
| 12 | `cursor-canh-bao-doanh-thu` | `sp_DemoCanhBaoHanTheThang`, `sp_DemoTongKetDoanhThuChuoi` | Khóa vé quá hạn, tổng kết doanh thu theo bãi |
| **👛 Cổng khách hàng** ||||
| 13 | `kh-dang-ky-tai-khoan` | `sp_KH_DangKyTaiKhoan` | Tài khoản + ví 0 ₫; đăng ký lại **50032** |
| 14 | `kh-dang-nhap-khoa-tai-khoan` | `sp_KH_DangNhap`, `trg_NhatKyDangNhap_KhoaTaiKhoan` | 5 lần **50040**, lần 6 **50041** |
| 15 | `kh-nap-tien-2-pha` | `sp_KH_NapTien_KhoiTao` / `_XacNhan`, `trg_GiaoDich_CapNhatSoDu` | +500.000 ₫ đúng 1 lần dù callback lặp |
| 16 | `kh-gia-han-bang-vi` | `sp_KH_GiaHanBangVi`, `f_KH_TinhPhiGiaHan` | Trừ ví, gia hạn, hóa đơn kênh *Online* |
| 17 | `trigger-chan-so-du-am` | `trg_GiaoDich_CapNhatSoDu`, `CHECK SoDu >= 0` | **50031** ở cả 2 lớp, số dư không đổi |
| 18 | `rls-co-lap-du-lieu-khach-hang` | `r_KhachHang`, policy `bao_mat.rls_KhachHang` | Bảng gốc bị từ chối (229), khách khác 0 dòng |
| 19 | `kh-uy-quyen-ve` | `sp_KH_UyQuyenVe`, `f_KH_CoQuyen`, `trg_UyQuyen_KiemTra` | **50050**, người thứ 4 **50053** |
| 20 | `cursor-tu-dong-gia-han` | `sp_DemoTuDongGiaHanVeThang` (cursor + savepoint) | 2 vé gia hạn, 1 vé thiếu tiền chỉ hoàn tác riêng |
| 21 | `trigger-so-cai-bat-bien` | `trg_GiaoDich_BatBien`, `trg_GiaoDich_ChanXoa`, `sp_NV_HoanTien` | **50061**, **50060**, **50062**, **50063**; hoàn khoản trừ nhầm |

---

### ⚙️ Nhóm Procedure

**1. Check-In (`sp-xe-vao-bai`)** — *Bài toán 1: kiểm soát barrier & cấp ô đỗ tự động.*  
Thẻ lượt `THE0003` vào bãi Lê Lai (`BAI_Q1`). Thủ tục gọi `f_TimSlotTrong` tìm ô trống, tạo lượt gửi; trigger `trg_DongBoTrangThaiSlot` đổi ô sang *Đã đỗ* và tăng `SoLuongHienTai`.  
**Điểm nhấn:** mở `/map`, chọn bãi Quận 1 → ô vừa cấp đã chuyển đỏ kèm biển số.
```sql
SELECT TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 1 * FROM dbo.LUOT_GUI WHERE MaThe = 'THE0003' ORDER BY MaLuot DESC;
```

**2. Check-Out & tính phí (`sp-xe-ra-bai`)** — *Bài toán 2.*  
Xe đang đỗ quét thẻ ra; `f_TinhTienGuiXe` tính tiền theo block giờ của bãi và loại xe; trigger giải phóng ô về *Trống*. Mở lại `/map` thấy ô chuyển xanh.

**3. Đăng ký vé tháng trong transaction (`sp-dang-ky-thanh-vien`)** — *Bài toán 3: ACID.*  
4 thao tác trong một `BEGIN TRANSACTION`: tạo / cập nhật khách (`KH####`), chuyển thẻ sang *Tháng*, sinh vé `V####`, lập hóa đơn `HD + ngày + STT`. Lỗi ở bất kỳ bước nào → `ROLLBACK` toàn bộ (ví dụ thiếu biểu phí: 50017).

**4. Gia hạn vé tại quầy (`sp-gia-han-ve-thang`)**  
`V0001` gia hạn 2 tháng. Thủ tục giữ chữ ký cũ nhưng gọi lõi chung `sp_GiaHanVe_Core` (dùng cho quầy, online và tự động). Quy tắc thu tiền: vé gắn bãi chỉ thu tại bãi áp dụng (50018); vé `ALL` thu tại `@MaBaiGiaHan`, mặc định bãi phát hành thẻ; thẻ đã báo mất không gia hạn (50019).

**5. Báo mất thẻ (`sp-bao-mat-the`)** — *Bài toán 4.*  
`THE0001` chuyển *Mất*; trigger `trg_LogLichSuSuCo` tự ghi biên bản vào `LICHSU_SU_CO` với tiền phạt 50.000 ₫ mà ứng dụng không cần viết câu INSERT nào. Vé tháng còn dùng của thẻ bị *Tạm khóa*.

**6. Cấp lại thẻ cho vé tháng mới (`sp-cap-lai-the`)** — *thẻ vật lý được tái sử dụng.*  
Vé `V0008` hết hạn từ 15/07/2026; quầy Quận 7 cấp lại thẻ `THE0022` cho khách mới.
- Unique index có lọc `UX_VeThang_MaThe_ConDung ... WHERE TrangThai <> N'Hết hạn'`: mỗi thẻ chỉ có **một vé còn dùng**, vé đã hết hạn không giữ thẻ.
- Hàm `f_VeHienHanhCuaThe` cho trigger cổng, bốt cổng và báo mất thẻ chỉ xét vé hiện hành → vé cũ không chặn check-in, không nhân đôi biên bản.
- Kết quả B4: cấp thẻ `THE0002` (vé V0001 còn hạn) bị từ chối **50065**; đăng ký vé mới thành công; quẹt thẻ vào bãi thành công; gia hạn vé cũ V0008 bị từ chối **50066**.
- B5: thẻ có 2 vé trong lịch sử (cũ *Hết hạn*, mới *Hoạt động*); lượt gửi ghi đúng vé mới; bốt cổng chỉ 1 dòng.

**7. Đăng nhập nhân viên, mật khẩu có salt (`sp-dang-nhap-nhan-vien`)**  
B3 cho thấy `quanly_q1`, `baove_q1`, `baove_khoa` cùng mật khẩu `123456` nhưng **salt và chuỗi băm khác nhau** (SHA2_512, 64 byte), đối chiếu bằng `f_BamMatKhau` đều *Khớp*. B4: `admin` đăng nhập thành công; sai mật khẩu **50022**; tài khoản bị khóa **50021**. B5: quyền trên `TAI_KHOAN` — `r_QuanLyBai` bị DENY 2 cột hash / salt.

Tài khoản nhân viên mẫu (dùng thêm ở SQL Studio):

| Tên đăng nhập | Mật khẩu | Vai trò | Phạm vi | Trạng thái |
|---|---|---|---|---|
| `admin` | `Admin@2026` | Giám đốc điều hành | Toàn chuỗi | Hoạt động |
| `quanly_q1` / `quanly_q3` / `quanly_bt` / `quanly_tb` / `quanly_q7` | `123456` | Quản lý bãi | Bãi tương ứng | Hoạt động |
| `baove_q1` / `baove_q3` / `baove_bt` / `baove_tb` / `baove_q7` | `123456` | Bảo vệ trực cổng | Bãi tương ứng | Hoạt động |
| `baove_khoa` | `123456` | Bảo vệ | Bãi Quận 1 | **Bị khóa** |

### ⚡ Nhóm Trigger
> Nhấn mạnh với giảng viên: *khung lỗi đỏ không phải lỗi code web mà là trigger dưới CSDL chặn vi phạm, ROLLBACK giao dịch*. Đối chứng SSMS: số lượt trong `LUOT_GUI` không đổi.

**8. `trigger-chan-checkin-loi`** — thẻ `THE0006` (*Mất* / *Bị khóa*) quét vào bãi → `trg_KiemTraCheckIn` báo **50002**. Cùng trigger còn chặn bãi đầy (50001), thẻ đang trong bãi (50014), ô sai bãi / đã có xe (50015), thẻ lượt khác bãi phát hành (50016).

**9. `trigger-chan-ve-het-han`** — thẻ tháng `THE0008` (vé `V0003` đã hết hạn) quét vào → **50003**. Trigger xét **vé hiện hành** của thẻ (`f_VeHienHanhCuaThe`), nên thẻ đã cấp lại cho vé mới không bị vé cũ chặn.

**10. `trigger-chan-sai-bai`** — vé `V0006` chỉ dùng ở `BAI_TB` quét vào `BAI_Q1` → **50004**; vé toàn chuỗi `V0004` (`ALL`) đi được mọi bãi.

### 📐 Nhóm Function
**11. `function-tinh-tien-slot`** — `f_TinhTienGuiXe` (ô tô 5 giờ tại Landmark 81), `f_TimSlotTrong` (ô xe máy trống ở Quận 1), `f_DanhSachXeTrongBai` (hàm trả về bảng).

### 🔄 Nhóm Cursor
**12. `cursor-canh-bao-doanh-thu`** — `sp_DemoCanhBaoHanTheThang` duyệt từng vé: chuyển vé quá hạn sang *Hết hạn*, cảnh báo vé còn ≤ 3 ngày, ghi thông báo cho khách có tài khoản (vé bật tự động gia hạn và ví đủ tiền hiện "Sẽ tự động gia hạn"). `sp_DemoTongKetDoanhThuChuoi` duyệt từng bãi, cộng doanh thu lượt + vé tháng theo kênh, xếp hạng chi nhánh.

### 👛 Nhóm Cổng khách hàng
**13. `kh-dang-ky-tai-khoan`** — KH0005 tự tạo tài khoản bằng SĐT + CCCD; thủ tục băm SHA2_512 với salt ngẫu nhiên, tạo tài khoản + ví 0 ₫ + thông báo trong một transaction. Đăng ký lại → **50032**.

**14. `kh-dang-nhap-khoa-tai-khoan`** — dò mật khẩu 5 lần → trigger khóa 15 phút; lần 6 đúng mật khẩu vẫn **50041**. Sai tên đăng nhập và sai mật khẩu cùng trả **50040** để chống dò tài khoản.

**15. `kh-nap-tien-2-pha`** — pha 1 tạo giao dịch *Chờ xử lý* (số dư chưa đổi); pha 2 callback MoMo chuyển *Thành công*, trigger cộng ví; callback lặp với cùng mã tham chiếu → không cộng lần 2 (idempotent).

**16. `kh-gia-han-bang-vi`** — KH0002 gia hạn `V0002` 1 tháng bằng ví: trừ ví (trigger), lõi gia hạn, hóa đơn kênh *Online* gắn mã giao dịch, trigger gửi thông báo — tất cả trong một transaction.

**17. `trigger-chan-so-du-am`** — ví 50.000 ₫ gia hạn 3 tháng (4.500.000 ₫): lớp 1 thủ tục báo thiếu bao nhiêu (**50031**); lớp 2 ghi thẳng vào sổ cái để vượt thủ tục → trigger sổ cái thấy số dư sẽ âm, ROLLBACK (**50031**).

**18. `rls-co-lap-du-lieu-khach-hang`** — chạy dưới user `u_WebKhachHang` (role `r_KhachHang`): cùng câu SELECT trên `vw_KH_LichSuGiaoDich` ra dữ liệu khác nhau theo khách trong `SESSION_CONTEXT`; đọc thẳng bảng `GIAO_DICH` bị từ chối (lỗi 229 - lớp DENY); KH0002 xem sao kê ví KH0001 nhận 0 dòng (lớp RLS); nhân viên (`dbo`) vẫn thấy toàn bộ.

**19. `kh-uy-quyen-ve`** — KH0004 chia sẻ `V0004` cho KH0007 vai trò *Thành viên*: KH0007 xem được vé và lịch sử nhưng gia hạn bị `f_KH_CoQuyen` từ chối (**50050**); chia sẻ người thứ 4 bị chặn (**50053**).

**20. `cursor-tu-dong-gia-han`** — 3 vé bật tự động gia hạn còn ≤ 3 ngày; cursor xử lý mỗi vé trong **savepoint** riêng: 2 vé gia hạn (hóa đơn kênh *Tự động*), vé thiếu tiền chỉ hoàn tác phần của nó và khách nhận thông báo (tối đa 1 thông báo / vé / ngày).

**21. `trigger-so-cai-bat-bien`** — sửa số tiền (**50061**), xóa giao dịch (**50060**), tự cộng số dư (**50062**) đều bị chặn. Hoàn khoản *đã xuất hóa đơn gia hạn* bị từ chối (**50063**: vé đã được cộng hạn, doanh thu đã ghi nhận). Cách hợp lệ: hoàn khoản *trừ nhầm chưa gắn hóa đơn* bằng `sp_NV_HoanTien` (giao dịch đối ứng, gốc chuyển *Đã hoàn*); số dư trở về như trước sự cố.

---

## 🖥️ PHẦN IV: CÁC MÀN HÌNH CHỨC NĂNG

### 🚦 1. Bốt kiểm soát cổng (`/gate`) — điểm nhấn
- **Quét thẻ (`v_BotCong_TraCuuThe`):** `THE0001` → đèn xanh **MỞ BARRIER**, chiều quét kế tiếp, ô gợi ý; `THE0006` → đèn đỏ **TỪ CHỐI** kèm lý do (thẻ mất, trigger sẽ báo 50002). Hồ sơ thẻ có badge *Có tài khoản online* / *Tự động gia hạn*. Thẻ cấp lại chỉ hiện vé hiện hành.
- **Bảng đèn cổng (`v_BotCong_BangDenCong`):** 🟢 còn chỗ / 🟡 sắp đầy / 🔴 hết chỗ theo loại xe, số ô trống, đơn giá.
- **Xe chờ ra (`v_BotCong_XeChoRa`):** số phút đỗ, tiền tạm tính, cờ `CanhBaoLechBienSo`.
- **Nhật ký barrier (`v_BotCong_NhatKyVaoRa`):** 200 sự kiện vào / ra mới nhất.

### 🗺️ 2. Sơ đồ ô đỗ thời gian thực (`/map`)
Chọn bãi bất kỳ trong 5 bãi bằng bộ chọn bãi (tìm kiếm, phím mũi tên). Thanh công suất từ `v_SodoBai_TongQuanBai`; ô trống xanh, ô có xe đỏ kèm biển số; dữ liệu từ `v_SodoBai_ODoChiTiet`, `v_SodoBai_TongHopKhuVuc`.

### 🗄️ 3. Bảng dữ liệu (`/tables`)
21 bảng nhóm theo phân hệ (Vận hành bãi · Vé tháng & khách hàng · Thanh toán & ví điện tử · Bảo mật & phân quyền), có ô tìm kiếm. Bấm từng bảng xem dữ liệu thật; các cột mật khẩu / salt / hash luôn hiển thị `•••••• (đã ẩn)`.

### 📊 4. Báo cáo BI (`/reports`)
23 thẻ view: 16 view báo cáo BI chia 4 nhóm (Vận hành & công suất · Doanh thu & tài chính · Thanh toán & ví điện tử · An ninh & chăm sóc khách hàng) và 7 view vận hành của bốt cổng / sơ đồ, có ô tìm kiếm; ví dụ `vw_Report_DoanhThuTheoPhuongThuc` (doanh thu theo kênh Tại quầy / Online / Tự động), `vw_Report_TongQuanViDienTu` (số dư khách đang giữ). Các view `vw_KH_*` không nằm ở đây vì phụ thuộc phiên đăng nhập của khách.

### 💻 5. SQL Studio (`/sql`)
Chạy bất kỳ câu lệnh giảng viên yêu cầu; có snippet mẫu (sao kê ví `f_KH_SaoKeVi`, đối soát ví `sp_DemoDoiSoatViDienTu`, đặt `SESSION_CONTEXT` rồi đọc `vw_KH_*`) và chèn nhanh tên 21 bảng.

### 🛡️ 6. Phân quyền RBAC + RLS (`sql/08_security_rbac.sql`)
- `r_Admin`: quản trị toàn quyền.
- `r_QuanLyBai`: nghiệp vụ bãi, báo cáo, thủ tục nhân viên `sp_NV_*`; **không** xem cột mật khẩu (`TAI_KHOAN`, `TAI_KHOAN_KH`), không sửa số dư / sổ cái.
- `r_BaoVe`: chỉ quẹt xe qua thủ tục và xem sơ đồ; `DENY UPDATE, DELETE` trên `LUOT_GUI`, `HOA_DON_VE_THANG`; DENY toàn bộ dữ liệu tài chính và tài khoản khách.
- `r_KhachHang`: chỉ `EXECUTE sp_KH_*` và `SELECT vw_KH_*`, DENY mọi bảng gốc; **Row-Level Security** (`bao_mat.rls_KhachHang`) lọc 7 bảng theo khách trong `SESSION_CONTEXT`.

### 👥 7. Khách hàng & Thanh toán (`/khach-hang`, màn hình nhân viên)
- **Tài khoản:** tài khoản bị khóa lên đầu, nút **Mở khóa** (`sp_NV_MoKhoaTaiKhoanKH`), **Nạp tiền mặt** tại quầy (`sp_NV_NapTienTaiQuay`, có hộp xác nhận số tiền).
- **Giao dịch:** hàng đợi giao dịch treo / thất bại; sổ cái gần nhất; **Hoàn tiền** (bắt nhập lý do) — chỉ khoản trừ nhầm chưa xuất hóa đơn, khoản có hóa đơn hiện thông báo 50063.
- **Bảo mật:** đăng nhập sai 24 giờ, IP đáng ngờ.
- Nút **"Mở cổng khách hàng ↗"** mở `/kh` ở tab mới để demo song song.

### 👤 8. Cổng khách hàng vé tháng (`/kh`) — demo song hành với `/khach-hang`
Mở ở **cửa sổ ẩn danh**. Trang đăng nhập có bảng **Tài khoản demo**: bấm tên để điền sẵn, mật khẩu mẫu `Khach@2026`. Mỗi request của cổng chạy dưới quyền `r_KhachHang`, nên dữ liệu khách thấy được lọc bởi RLS thật.
1. **Đăng nhập Nguyễn Văn An (0903112233):** tổng quan chỉ hiện vé V0001 của chính khách, số dư ví, thông báo, lượt gửi gần đây.
2. **Nạp tiền:** chọn MoMo, 500.000 ₫ (có nút chọn nhanh, hiện hạn mức còn lại trong ngày) → **cổng thanh toán mô phỏng**: giao dịch *Chờ xử lý* → **Thanh toán thành công** → số dư tăng → **Gửi lại callback** → báo "đã xử lý trước đó, không cộng tiền lần nữa". Không có lựa chọn tiền mặt (chỉ nạp tại quầy).
3. **Gia hạn vé:** chọn 1 / 3 / 6 / 12 tháng, xem trước phí và số dư sau gia hạn; thiếu tiền thì nút đổi thành "Nạp thêm X ₫". Thanh toán → nhận mã hóa đơn; tab nhân viên `/khach-hang` → Giao dịch thấy ngay dòng sổ cái mới.
4. **Chia sẻ vé:** chia sẻ V0001 cho 0938135790 vai trò *Thành viên*. Đăng nhập tài khoản đó ở cửa sổ ẩn danh khác: thấy V0001 nhưng **không có nút Gia hạn**; gọi thẳng URL gia hạn → 50050. Chủ vé bấm **Thu hồi** → vé biến mất khỏi cổng người nhận.
5. **Khóa tài khoản:** nhập sai mật khẩu 5 lần cho 0934556677 → lần 6 đúng mật khẩu vẫn bị từ chối (50041). Tab nhân viên → Tài khoản: TK0004 lên đầu với *Tạm khóa* → **Mở khóa**.
6. **Bảo mật:** đổi mật khẩu với thước đo chính sách (≥ 8 ký tự, hoa, thường, số, ký tự đặc biệt); xem 10 lần đăng nhập gần nhất.

---

## ❓ PHẦN V: CÂU HỎI VẤN ĐÁP THƯỜNG GẶP

**1. Vì sao tính tiền gửi xe bằng `f_TinhTienGuiXe` dưới CSDL thay vì ở Python?**  
> Một công thức duy nhất cho mọi ứng dụng (web, máy POS, BI); nhân viên không sửa được logic ở tầng giao diện; CSDL tính ngay trên dữ liệu, không phải tải dữ liệu thô lên ứng dụng.

**2. Đăng ký vé tháng mà lỗi ở bước hóa đơn thì có dữ liệu rác không?**  
> Không. 4 thao tác nằm trong `BEGIN TRANSACTION … COMMIT` với `TRY/CATCH`; lỗi ở bất kỳ bước nào → `ROLLBACK` toàn bộ (tính nguyên tử - ACID).

**3. Làm sao ngăn bảo vệ thông đồng gian lận tiền gửi xe?**  
> 3 lớp: RBAC (`r_BaoVe` bị `DENY UPDATE, DELETE` trên `LUOT_GUI`, `HOA_DON_VE_THANG`, chỉ thao tác qua procedure); đối soát tự động (`v_BotCong_XeChoRa` tính tiền tạm theo giờ vào thực tế, cờ lệch biển số); lưu vết sự cố bằng trigger.

**4. Vì sao `LOAI_XE` dùng khóa chính hỗn hợp `(MaLoaiXe, MaBai)`?**  
> Mỗi bãi có biểu phí riêng (mặt bằng Quận 1 đắt hơn Bình Thạnh); khóa hỗn hợp cho mỗi chi nhánh tự định giá cùng một loại xe mà không cần thêm bảng.

**5. Số dư ví có thể bị sửa sai hoặc âm không?**  
> Không. Số dư **chỉ** được đổi bởi trigger sổ cái `trg_GiaoDich_CapNhatSoDu` khi giao dịch chuyển *Thành công*; `trg_ViDienTu_ChanSuaTrucTiep` chặn mọi lệnh UPDATE số dư khác (50062), kể cả của admin. Sổ cái chỉ ghi thêm: không sửa (50061), không xóa (50060). Số dư âm bị chặn ở thủ tục, ở trigger và bởi `CHECK SoDu >= 0`. Cursor `sp_DemoDoiSoatViDienTu` đối chiếu số dư với tổng sổ cái.

**6. Row-Level Security khác gì viết thêm `WHERE MaKH = …` trong code?**  
> `WHERE` phụ thuộc lập trình viên nhớ viết đúng ở mọi câu lệnh. RLS là policy gắn vào bảng: với user thuộc `r_KhachHang`, SQL Server tự lọc theo `SESSION_CONTEXT('MaKH')` (đặt read-only khi đăng nhập) cho mọi truy vấn, kể cả câu viết sai. Kết hợp DENY bảng gốc và kiểm tra quyền nghiệp vụ `f_KH_CoQuyen` thành 3 lớp phòng thủ.

**7. Callback cổng thanh toán gửi lặp thì có cộng tiền 2 lần không?**  
> Không. `sp_KH_NapTien_XacNhan` khóa dòng giao dịch (`UPDLOCK, HOLDLOCK`); giao dịch đã xử lý thì chỉ trả lại kết quả cũ (idempotent); mã tham chiếu đã dùng cho giao dịch khác bị từ chối (50039).

**8. Vì sao lưu mật khẩu bằng hash có salt?**  
> Hash một chiều nên CSDL bị lộ cũng không đọc được mật khẩu. Salt ngẫu nhiên 16 byte riêng từng tài khoản khiến hai người cùng mật khẩu có hash khác nhau, vô hiệu hóa bảng tra hash có sẵn (rainbow table). Nhân viên và khách hàng dùng chung `f_BamMatKhau` (SHA2_512). Khách đăng nhập sai 5 lần trong 15 phút bị khóa 15 phút.

**9. Thẻ vật lý dùng lại cho vé mới mà lịch sử cũ có bị lẫn không?**  
> Không. Unique index có lọc chỉ cấm 2 vé *còn dùng* trên một thẻ; mỗi lượt gửi ghi `LUOT_GUI.MaVe` nên lịch sử gắn đúng vé; mọi chỗ tra vé theo thẻ dùng `f_VeHienHanhCuaThe` nên vé cũ không ảnh hưởng vé mới.

**10. Cursor tự động gia hạn gặp một vé thiếu tiền thì các vé khác có bị hủy theo không?**  
> Không. Mỗi vé chạy trong `SAVE TRANSACTION` riêng; lỗi chỉ `ROLLBACK` về savepoint của vé đó. Lõi `sp_GiaHanVe_Core` cũng dùng mẫu transaction lồng an toàn nên được gọi được từ quầy, cổng online và cursor.

---

## 🧾 PHẦN VI: BẢNG TRA MÃ LỖI HAY GẶP KHI DEMO

| Mã | Ý nghĩa | Nơi phát sinh |
|---|---|---|
| 50001 / 50002 | Bãi đầy / thẻ mất hoặc bị khóa | `trg_KiemTraCheckIn` |
| 50003 | Vé tháng hết hạn | `trg_ChanSuDungVeHetHan` |
| 50004 | Vé tháng gửi sai bãi áp dụng | `trg_KiemTraBaiApDungVeThang` |
| 50014 / 50015 / 50016 | Thẻ đang trong bãi / ô sai bãi hoặc đã có xe / thẻ lượt khác bãi | `trg_KiemTraCheckIn` |
| 50017 / 50018 / 50019 | Thiếu biểu phí / gia hạn sai bãi / thẻ đã báo mất | Đăng ký, gia hạn vé |
| 50021 / 50022 | Tài khoản nhân viên bị khóa / sai mật khẩu | `sp_DangNhap` |
| 50031 | Số dư ví không đủ | `sp_KH_GiaHanBangVi`, trigger sổ cái |
| 50032 / 50034 | Khách đã có tài khoản / mật khẩu yếu | Đăng ký, đổi mật khẩu |
| 50035 | Phương thức thanh toán không hợp lệ (ví dụ tiền mặt online) | Nạp tiền, đăng ký vé |
| 50040 / 50041 | Sai tên đăng nhập hoặc mật khẩu / tài khoản tạm khóa | `sp_KH_DangNhap` |
| 50050 / 50053 / 50054 | Không đủ quyền trên vé / quá 3 người chia sẻ / vé hết hạn không chia sẻ | Ủy quyền |
| 50060 / 50061 / 50062 | Xóa / sửa sổ cái / sửa thẳng số dư | Trigger sổ cái, ví |
| 50063 | Hoàn tiền không hợp lệ (khoản đã xuất hóa đơn hoặc thiếu lý do) | `sp_NV_HoanTien` |
| 50065 / 50066 | Thẻ đang gắn vé còn hiệu lực / vé cũ của thẻ đã cấp lại | Đăng ký, gia hạn vé |
| 229 | Không có quyền truy cập bảng (DENY) | Kịch bản RLS |

---

## 🏆 PHẦN VII: ĐIỂM NỔI BẬT

1. **CSDL 21 bảng chuẩn hóa**, gồm phân hệ vận hành bãi, nhân sự và cổng khách hàng (ví trả trước, sổ cái bất biến, ủy quyền vé).
2. **Đầy đủ đối tượng nâng cao:** 23 procedures + 4 cursor, 16 triggers, 12 functions, 37 views, 4 role RBAC + Row-Level Security, kịch bản backup / restore.
3. **Toàn vẹn tài chính:** số dư chỉ đổi qua sổ cái, nạp tiền 2 pha idempotent, transaction lồng nhau an toàn với savepoint.
4. **Bảo mật nhiều lớp:** DENY bảng gốc, RLS theo phiên, quyền nghiệp vụ theo vai trò, mật khẩu SHA2_512 có salt, khóa tài khoản khi dò mật khẩu.
5. **Giao diện demo trực quan:** 21 kịch bản 5 bước, bốt cổng barrier, sơ đồ ô đỗ, màn hình nhân viên và cổng khách hàng riêng, giao diện Sáng / Tối, dùng được trên điện thoại.
