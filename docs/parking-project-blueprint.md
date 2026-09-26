# THIẾT KẾ KỸ THUẬT & TÀI LIỆU KIẾN TRÚC TOÀN DIỆN: HỆ THỐNG QUẢN LÝ CHUỖI BÃI ĐỖ XE THÔNG MINH (VERSION 6)

> **Dành cho:** Đồ án môn Quản lý Thông tin / Quản trị Cơ sở Dữ liệu (IE103)  
> **Kiến trúc Hệ thống:** Microsoft SQL Server 2022 (Docker Container / Windows Local port 1433) + Python 3.10+ Backend (Flask + pyodbc port 5001) + Modern Web Dashboard UI (HTML5, Vanilla CSS Design Tokens, Jinja2) có khả năng tích hợp mở rộng REST API / Angular Frontend  
> **Quy mô Nhóm:** 10 Thành viên (Chia thành 5 nhóm chuyên trách, mỗi nhóm 2 người)

---

## 🗄️ PHẦN I: THIẾT KẾ CƠ SỞ DỮ LIỆU VẬT LÝ HOÀN CHỈNH (11 BẢNG)

Cơ sở dữ liệu **`QuanLyBaiDoXe`** được thiết kế chuẩn hóa đạt dạng chuẩn 3 (3NF), phân tách dữ liệu theo từng chi nhánh bãi đỗ xe thông qua định danh `MaBai`, đồng thời tích hợp đầy đủ phân hệ **Quản trị Tài khoản - Phân quyền (RBAC)** và **Quản lý An toàn Thông tin - Sự cố**.

```
                         ┌──────────────┐
                         │  BAI_DO_XE   │
                         └──────┬───────┘
                                │ 1
            ┌───────────────────┼───────────────────┐
            │ N                 │ N                 │ N
     ┌──────┴──────┐     ┌──────┴──────┐     ┌──────┴──────┐
     │  LOAI_XE    │     │  VI_TRI_DO  │     │   THE_XE    │
     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
            │ 1                 │ 1                 │ 1
            │ N                 │ N                 │ N
     ┌──────┴──────┐     ┌──────┴──────┐     ┌──────┴──────┐
     │  VE_THANG   │─────│  LUOT_GUI   │─────│LICHSU_SU_CO │
     └──────┬──────┘     └─────────────┘     └─────────────┘
            │ N
     ┌──────┴──────┐
     │ HOA_DON_VT  │
     └─────────────┘

 [PHÂN HỆ BẢO MẬT & NHÂN SỰ]:
 ┌──────────────┐ 1       1 ┌──────────────┐
 │  NHAN_VIEN   │───────────│  TAI_KHOAN   │ (Mật khẩu băm SHA-256)
 └──────────────┘           └──────────────┘
```

---

### Chi Tiết Cấu Trúc 11 Bảng Dữ Liệu

#### 1. Bảng `BAI_DO_XE` (Danh mục chi nhánh bãi đỗ xe)
Quản lý các chi nhánh bãi đỗ thuộc hệ thống chuỗi.
- **`MaBai`** `VARCHAR(10)` **[PK]**: Mã định danh bãi xe (`BAI_Q1`, `BAI_Q3`, `BAI_BT`).
- **`TenBai`** `NVARCHAR(100)` `NOT NULL` `UNIQUE`: Tên bãi đỗ xe (*Bãi xe Quận 1 - Lê Lai*, *Bãi xe Landmark 81*).
- **`DiaChi`** `NVARCHAR(255)` `NOT NULL`: Địa chỉ thực tế của bãi đỗ.
- **`SucChua`** `INT` `NOT NULL`: Sức chứa tối đa (tổng số ô đỗ vật lý). **CHECK**: `SucChua > 0`.
- **`SoLuongHienTai`** `INT` `NOT NULL` `DEFAULT 0`: Số xe đang gửi thực tế. **CHECK**: `SoLuongHienTai >= 0 AND SoLuongHienTai <= SucChua`.

#### 2. Bảng `NHAN_VIEN` (Hồ sơ nhân sự)
Lưu trữ thông tin nhân viên bảo vệ, quản lý chi nhánh và ban quản trị.
- **`MaNV`** `VARCHAR(10)` **[PK]**: Mã định danh nhân viên (`NV001`, `NV002`).
- **`HoTen`** `NVARCHAR(100)` `NOT NULL`: Họ và tên đầy đủ của nhân viên.
- **`ChucVu`** `NVARCHAR(50)` `NOT NULL`: Chức vụ (*Giám đốc*, *Quản lý bãi*, *Bảo vệ*).
- **`SDT`** `VARCHAR(15)` `NOT NULL` `UNIQUE`: Số điện thoại liên lạc.
- **`Email`** `VARCHAR(100)` `NULL` `UNIQUE`: Hòm thư điện tử nội bộ.
- **`MaBai`** `VARCHAR(10)` `NULL` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`. Nhân viên quản lý chi nhánh/bảo vệ được gắn với bãi cụ thể; Admin/Giám đốc để `NULL` (quản trị toàn hệ thống).

#### 3. Bảng `TAI_KHOAN` (Tài khoản truy cập & Xác thực)
Quản lý tên đăng nhập và mật khẩu mã hóa cho nhân sự vận hành hệ thống.
- **`TenDangNhap`** `VARCHAR(50)` **[PK]**: Tên tài khoản truy cập (`admin`, `quanly_q1`, `baove_q1`).
- **`MatKhauHash`** `VARCHAR(255)` `NOT NULL`: Chuỗi mật khẩu đã qua băm an toàn (SHA-256 kết hợp salt).
- **`MaNV`** `VARCHAR(10)` `NOT NULL` **[FK]**: Liên kết trực tiếp `NHAN_VIEN(MaNV)`.
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Hoạt động'`: **CHECK**: `TrangThai IN (N'Hoạt động', N'Bị khóa')`.

#### 4. Bảng `LOAI_XE` (Phân loại phương tiện & Biểu phí chi nhánh)
Sử dụng **Khóa chính hỗn hợp (Composite PK)** gồm `(MaLoaiXe, MaBai)` cho phép mỗi bãi có biểu phí riêng.
- **`MaLoaiXe`** `VARCHAR(10)` **[Composite PK]**: Mã loại phương tiện (`XM` - Xe máy, `OT` - Ô tô, `XD` - Xe đạp).
- **`MaBai`** `VARCHAR(10)` **[Composite PK, FK]**: Liên kết `BAI_DO_XE(MaBai)`.
- **`TenLoai`** `NVARCHAR(50)` `NOT NULL`: Tên hiển thị loại phương tiện (*Xe máy*, *Ô tô 4-7 chỗ*).
- **`DonGiaGio`** `DECIMAL(18,2)` `NOT NULL`: Giá vé lượt trên mỗi giờ gửi (VND). **CHECK**: `DonGiaGio > 0`.
- **`GiaVeThang`** `DECIMAL(18,2)` `NOT NULL`: Giá vé tháng 30 ngày (VND). **CHECK**: `GiaVeThang > 0`.

#### 5. Bảng `VI_TRI_DO` (Sơ đồ mặt bằng vị trí đỗ xe)
Quản lý các slot đỗ xe vật lý theo từng phân khu và bãi.
- **`MaViTri`** `VARCHAR(20)` **[PK]**: Định dạng `MABAI_SLOT` (`Q1_A101`, `Q3_B202`).
- **`KhuVuc`** `NVARCHAR(20)` `NOT NULL`: Phân khu (*Khu A*, *Khu B*, *Tầng hầm 1*).
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Trống'`: **CHECK**: `TrangThai IN (N'Trống', N'Đã đỗ')`.
- **`MaLoaiXe`** `VARCHAR(10)` `NOT NULL` **[FK]**: Tham chiếu khóa ngoại kết hợp `(MaLoaiXe, MaBai)` sang `LOAI_XE`.
- **`MaBai`** `VARCHAR(10)` `NOT NULL` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`.

#### 6. Bảng `THE_XE` (Quản lý kho thẻ từ/chip RFID)
Quản lý vòng đời thẻ quét vào/ra phân bổ theo chi nhánh.
- **`MaThe`** `VARCHAR(10)` **[PK]**: Mã số thẻ RFID quét vật lý (`THE0001`, `THE0002`).
- **`MaBai`** `VARCHAR(10)` `NOT NULL` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`. Xác định thẻ thuộc bãi đỗ nào.
- **`LoaiThe`** `NVARCHAR(10)` `NOT NULL`: **CHECK**: `LoaiThe IN (N'Lượt', N'Tháng')`.
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Hoạt động'`: **CHECK**: `TrangThai IN (N'Hoạt động', N'Bị khóa', N'Mất')`.
- **`NgayCap`** `DATE` `NOT NULL` `DEFAULT GETDATE()`: Ngày phát hành thẻ vào kho bãi.

#### 7. Bảng `KHACH_HANG` (Hồ sơ chủ xe đăng ký vé tháng)
Lưu trữ thông tin khách hàng mua thuê bao đỗ xe định kỳ.
- **`MaKH`** `VARCHAR(10)` **[PK]**: Mã số khách hàng (`KH0001`, `KH0002`).
- **`HoTen`** `NVARCHAR(100)` `NOT NULL`: Họ tên chủ phương tiện.
- **`SDT`** `VARCHAR(15)` `NOT NULL` `UNIQUE`: Số điện thoại nhận tin thông báo gia hạn.
- **`Email`** `VARCHAR(100)` `NULL` `UNIQUE`: Địa chỉ email nhận hóa đơn điện tử.
- **`CMND_CCCD`** `VARCHAR(12)` `NOT NULL` `UNIQUE`: Số định danh cá nhân phục vụ công tác an ninh.

#### 8. Bảng `VE_THANG` (Bản đăng ký vé tháng)
Hợp đồng vé gửi xe định kỳ theo biển số và thẻ được cấp.
- **`MaVe`** `VARCHAR(10)` **[PK]**: Mã đăng ký vé tháng (`V0001`, `V0002`).
- **`MaThe`** `VARCHAR(10)` `NOT NULL` `UNIQUE` **[FK]**: Liên kết `THE_XE(MaThe)` (1 thẻ kích hoạt duy nhất 1 vé tháng).
- **`MaKH`** `VARCHAR(10)` `NOT NULL` **[FK]**: Liên kết `KHACH_HANG(MaKH)`.
- **`BienSo`** `VARCHAR(15)` `NOT NULL`: Biển kiểm soát đăng ký cố định.
- **`MaLoaiXe`** `VARCHAR(10)` `NOT NULL` **[FK]**: Loại phương tiện đăng ký.
- **`NgayDangKy`** `DATE` `NOT NULL` `DEFAULT GETDATE()`: Ngày bắt đầu kích hoạt gói thuê bao.
- **`NgayHetHan`** `DATE` `NOT NULL`: Thời điểm hết hạn của vé.
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Hoạt động'`: **CHECK**: `TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Hết hạn')`.
- **`MaBaiApDung`** `VARCHAR(10)` `NOT NULL`: Bãi đỗ được phép gửi (`BAI_Q1`, `BAI_Q3` hoặc `'ALL'` gửi toàn chuỗi).

#### 9. Bảng `LUOT_GUI` (Nhật ký check-in / check-out phương tiện)
Ghi nhận toàn bộ lưu vết xe vào/ra bãi đỗ phục vụ kiểm soát an ninh và tính tiền.
- **`MaLuot`** `INT` **[PK IDENTITY]**: Định danh lượt gửi tự động tăng.
- **`MaThe`** `VARCHAR(10)` `NOT NULL` **[FK]**: Thẻ quẹt tại trụ barrier.
- **`BienSo`** `VARCHAR(15)` `NOT NULL`: Biển số xe nhận dạng qua camera OCR.
- **`ThoiGianVao`** `DATETIME` `NOT NULL` `DEFAULT GETDATE()`: Thời điểm quét thẻ vào.
- **`ThoiGianRa`** `DATETIME` `NULL`: Thời điểm quét thẻ ra (`NULL` biểu thị xe đang đỗ trong bãi).
- **`MaViTri`** `VARCHAR(20)` `NULL` **[FK]**: Vị trí ô đỗ được cấp tự động.
- **`TienGui`** `DECIMAL(18,2)` `NOT NULL` `DEFAULT 0`: Số tiền thu thực tế khi xe check-out.
- **`MaBai`** `VARCHAR(10)` `NOT NULL` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`.

#### 10. Bảng `HOA_DON_VE_THANG` (Lịch sử thanh toán & Gia hạn thuê bao)
Chứng từ thu tiền gia hạn vé tháng định kỳ.
- **`MaHD`** `VARCHAR(15)` **[PK]**: Mã hóa đơn thu tiền (`HD20260908001`).
- **`MaVe`** `VARCHAR(10)` `NOT NULL` **[FK]**: Liên kết `VE_THANG(MaVe)`.
- **`NgayThanhToan`** `DATETIME` `NOT NULL` `DEFAULT GETDATE()`: Thời điểm nộp tiền.
- **`SoThangGiaHan`** `INT` `NOT NULL` `DEFAULT 1`: Số tháng gia hạn nộp trước. **CHECK**: `SoThangGiaHan > 0`.
- **`SoTien`** `DECIMAL(18,2)` `NOT NULL`: Số tiền thanh toán (VND). **CHECK**: `SoTien > 0`.
- **`MaBai`** `VARCHAR(10)` `NOT NULL` **[FK]**: Bãi thực hiện thu tiền và hạch toán doanh thu.

#### 11. Bảng `LICHSU_SU_CO` (Nhật ký biên bản sự cố an ninh & Vi phạm)
Ghi nhận các trường hợp mất thẻ, va chạm, hỏng hóc hoặc vi phạm nội quy bãi đỗ.
- **`MaSuCo`** `INT` **[PK IDENTITY]**: Mã biên bản sự cố tự tăng.
- **`MaThe`** `VARCHAR(10)` `NULL` **[FK]**: Mã thẻ liên quan đến sự cố (nếu có).
- **`BienSo`** `VARCHAR(15)` `NULL`: Biển kiểm soát phương tiện liên quan.
- **`ThoiGianSuCo`** `DATETIME` `NOT NULL` `DEFAULT GETDATE()`: Thời điểm lập biên bản.
- **`MoTa`** `NVARCHAR(500)` `NOT NULL`: Nội dung chi tiết diễn biến sự cố.
- **`TienPhat`** `DECIMAL(18,2)` `NOT NULL` `DEFAULT 0`: Số tiền phạt bồi hoàn. **CHECK**: `TienPhat >= 0`.
- **`TrangThaiXuLy`** `NVARCHAR(50)` `NOT NULL` `DEFAULT N'Chờ xử lý'`: **CHECK**: `TrangThaiXuLy IN (N'Chờ xử lý', N'Đang giải quyết', N'Đã giải quyết')`.
- **`MaBai`** `VARCHAR(10)` `NOT NULL` **[FK]**: Chi nhánh bãi xảy ra sự cố.

---

## 🔒 PHẦN II: AN TOÀN THÔNG TIN, PHÂN QUYỀN & QUẢN TRỊ CSDL

### 1. Phân Quyền Truy Cập (Role-Based Access Control - RBAC)
Hệ thống thiết lập 3 Roles người dùng trong SQL Server (`sql/08_security_rbac.sql`) nhằm thực thi nguyên tắc đặc quyền tối thiểu (Principle of Least Privilege):

```sql
-- 1. Khởi tạo 3 Roles quản trị
CREATE ROLE r_Admin;
CREATE ROLE r_QuanLyBai;
CREATE ROLE r_BaoVe;

-- 2. Cấp đặc quyền r_Admin: Toàn quyền quản trị cơ sở dữ liệu
GRANT CONTROL ON DATABASE::QuanLyBaiDoXe TO r_Admin;

-- 3. Cấp đặc quyền r_QuanLyBai: Quản trị nghiệp vụ tại chi nhánh
GRANT SELECT, INSERT, UPDATE ON BAI_DO_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON VI_TRI_DO TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON THE_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON KHACH_HANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON VE_THANG TO r_QuanLyBai;
GRANT SELECT ON LUOT_GUI TO r_QuanLyBai;
GRANT SELECT ON HOA_DON_VE_THANG TO r_QuanLyBai;
GRANT SELECT, UPDATE ON LICHSU_SU_CO TO r_QuanLyBai;
GRANT EXECUTE ON sp_DangKyThanhVien TO r_QuanLyBai;
GRANT EXECUTE ON sp_GiaHanTheThang TO r_QuanLyBai;
GRANT EXECUTE ON sp_BaoMatThe TO r_QuanLyBai;
GRANT SELECT ON v_DoanhThuTheoBai TO r_QuanLyBai;
GRANT SELECT ON v_CongSuatBaiDo TO r_QuanLyBai;
GRANT SELECT ON v_BaoCaoSuCoChiNhanh TO r_QuanLyBai;

-- 4. Cấp đặc quyền r_BaoVe: Chỉ vận hành cổng barrier và xem sơ đồ đỗ
GRANT EXECUTE ON sp_XeVaoBai TO r_BaoVe;
GRANT EXECUTE ON sp_XeRaBai TO r_BaoVe;
GRANT SELECT ON v_SodoOdoRealtime TO r_BaoVe;
GRANT SELECT ON v_Xedangtrongbai TO r_BaoVe;
GRANT EXECUTE ON sp_BaoMatThe TO r_BaoVe;
-- Chặn tuyệt đối quyền can thiệp dữ liệu tài chính
DENY UPDATE, DELETE ON LUOT_GUI TO r_BaoVe;
DENY UPDATE, DELETE ON HOA_DON_VE_THANG TO r_BaoVe;
```

### 2. Xác Thực Mật Khẩu Băm (Hashing SHA-256)
Mật khẩu của tài khoản nhân sự được băm một chiều trong SQL Server bằng thuật toán chuẩn `SHA2_256`:
```sql
-- Kiểm tra đăng nhập với chuỗi băm an toàn
SELECT tk.TenDangNhap, nv.HoTen, nv.ChucVu, nv.MaBai
FROM TAI_KHOAN tk
JOIN NHAN_VIEN nv ON tk.MaNV = nv.MaNV
WHERE tk.TenDangNhap = @TenDangNhap
  AND tk.MatKhauHash = HASHBYTES('SHA2_256', @MatKhau)
  AND tk.TrangThai = N'Hoạt động';
```

### 3. Nhập & Xuất Dữ Liệu Hàng Loạt (Bulk Data Import/Export)
- **Import thẻ xe từ file CSV vào bảng `THE_XE`:**
```sql
BULK INSERT THE_XE
FROM '/var/opt/mssql/data/the_xe_import.csv' -- hoặc C:\data\the_xe_import.csv
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = '65001' -- Hỗ trợ UTF-8
);
```
- **Export Báo cáo Doanh thu sang CSV/Excel:**
Thực thi lệnh tiện ích `bcp` hoặc trích xuất tự động qua backend Python từ View `v_DoanhThuTheoBai`.

### 4. Chiến Lược Sao Lưu & Khôi Phục (Backup & Restore Strategy)
Thực thi đầy đủ theo chuẩn doanh nghiệp tại file `sql/09_backup_restore.sql`:
- **FULL BACKUP (Hàng tuần - Chủ nhật 00:00):**
```sql
BACKUP DATABASE QuanLyBaiDoXe
TO DISK = '/var/opt/mssql/backup/QuanLyBaiDoXe_Full.bak'
WITH FORMAT, INIT, MEDIANAME = 'ParkingBackups', NAME = 'Full Backup QuanLyBaiDoXe';
```
- **DIFFERENTIAL BACKUP (Hàng ngày - 23:00):**
```sql
BACKUP DATABASE QuanLyBaiDoXe
TO DISK = '/var/opt/mssql/backup/QuanLyBaiDoXe_Diff.bak'
WITH DIFFERENTIAL, INIT, NAME = 'Diff Backup QuanLyBaiDoXe';
```
- **TRANSACTION LOG BACKUP (Định kỳ mỗi 2 giờ):**
```sql
BACKUP LOG QuanLyBaiDoXe
TO DISK = '/var/opt/mssql/backup/QuanLyBaiDoXe_Log.trn'
WITH INIT, NAME = 'Log Backup QuanLyBaiDoXe';
```
- **RESTORE DATABASE (Kịch bản phục hồi thảm họa sự cố):**
```sql
RESTORE DATABASE QuanLyBaiDoXe
FROM DISK = '/var/opt/mssql/backup/QuanLyBaiDoXe_Full.bak'
WITH NORECOVERY, REPLACE;

RESTORE DATABASE QuanLyBaiDoXe
FROM DISK = '/var/opt/mssql/backup/QuanLyBaiDoXe_Diff.bak'
WITH RECOVERY;
```

---

## 👁️ PHẦN III: HỆ THỐNG BẢNG ẢO (VIEWS) GIÁM SÁT REALTIME & BÁO CÁO BI (15 VIEWS)

Triển khai đầy đủ trong `sql/07_views.sql`, chia thành 4 nhóm chuyên biệt:

### Nhóm 1: Views Vận Hành Thời Gian Thực (Operational Realtime)
1. **`v_SodoOdoRealtime`**: Sơ đồ mặt bằng ô đỗ thời gian thực, hiển thị trạng thái `Trống` / `Đã đỗ`, liên kết biển số xe và giờ gửi nếu đang có xe đỗ.
2. **`v_Xedangtrongbai`**: Danh sách tất cả phương tiện đang đỗ thực tế trong từng bãi (`ThoiGianRa IS NULL`), kèm loại thẻ và thời gian vào bãi.
3. **`v_DanhsachveThangsaphethan`**: Danh sách thuê bao vé tháng còn hạn dưới 3 ngày hoặc đã quá hạn, hỗ trợ quản lý gọi điện/nhắn tin nhắc khách gia hạn.

### Nhóm 2: Views Báo Cáo Phân Tích Quản Trị & BI (Business Intelligence)
4. **`v_DoanhThuTheoBai`**: Tổng hợp doanh thu chi tiết từ vé lượt (`LUOT_GUI`) và vé tháng (`HOA_DON_VE_THANG`) theo từng chi nhánh bãi đỗ xe.
5. **`v_CongSuatBaiDo`**: Phân tích hiệu suất khai thác, tỷ lệ lấp đầy (`SoLuongHienTai / SucChua * 100%`) của từng bãi đỗ xe.
6. **`v_BaoCaoSuCoChiNhanh`**: Báo cáo tổng hợp số lượng sự cố an ninh, biên bản mất thẻ và tổng tiền phạt phát sinh theo từng chi nhánh.
7. **`v_ThongKeLoaiXe`**: Báo cáo cơ cấu phương tiện gửi tại bãi (tỷ lệ xe máy, ô tô 4 chỗ, xe đạp) phục vụ quy hoạch mặt bằng.
8. **`v_NhatKyVaoRaGanNhat`**: Top 100 sự kiện check-in / check-out mới nhất phục vụ màn hình camera giám sát tại phòng bảo vệ.

### Nhóm 3: Views Bốt Kiểm Soát Cổng Vào / Ra (Gate Control Kiosk)
Bộ 4 views này là nguồn dữ liệu duy nhất cho màn hình bảo vệ trực barrier: quét mã thẻ là ra ngay quyết định đóng/mở cổng, số tiền phải thu và cảnh báo an ninh kèm theo.

9. **`v_BotCong_TraCuuThe`**: Tra cứu thẻ tại bốt cổng, mỗi mã thẻ trả về đúng 1 dòng gồm tình trạng thẻ, hợp đồng vé tháng, lượt gửi đang mở, chiều quét kế tiếp (`Vào` / `Ra`), cờ `ChoPhepQuet` và `LyDoTuChoi` đối chiếu đúng các rào chặn của `trg_KiemTraCheckIn` (lỗi 50001 / 50002) và `trg_ChanSuDungVeHetHan` (lỗi 50003).
10. **`v_BotCong_XeChoRa`**: Màn hình check-out tại cổng ra, liệt kê xe đang trong bãi kèm số phút đỗ, số block giờ tính phí, `TienTamTinh` theo đúng công thức `f_TinhTienGuiXe` và chính sách miễn phí xe vé tháng của `sp_XeRaBai`, kèm cờ `CanhBaoLechBienSo`.
11. **`v_BotCong_NhatKyVaoRa`**: Bảng điện tử 200 sự kiện vào/ra mới nhất, mỗi lượt gửi được trải thành 2 dòng sự kiện (`Vào` và `Ra`) theo trục thời gian cho phòng bảo vệ đối chiếu camera giám sát.
12. **`v_BotCong_BangDenCong`**: Bảng đèn tín hiệu `CÒN CHỖ` / `HẾT CHỖ` đặt tại cổng vào theo từng cặp (bãi đỗ × loại phương tiện), kèm ô đỗ gợi ý do `f_TimSlotTrong` cấp phát và biểu phí niêm yết.

### Nhóm 4: Views Sơ Đồ Bãi Xe Thời Gian Thực (Realtime Parking Map)
Bộ 3 views này phục vụ trực tiếp màn hình `/map`: một view vẽ lưới ô đỗ, một view vẽ thanh tổng hợp theo khu vực và một view vẽ thẻ tổng quan công suất.

13. **`v_SodoBai_ODoChiTiet`**: Chi tiết từng ô đỗ trên sơ đồ mặt bằng (bảo đảm đúng 1 dòng / 1 ô đỗ), kèm phương tiện đang chiếm chỗ, thời gian lưu bãi, tiền tạm tính, hồ sơ chủ xe vé tháng và cờ `CanhBaoLechDuLieu` khi trạng thái ô đỗ không khớp lượt gửi đang mở.
14. **`v_SodoBai_TongHopKhuVuc`**: Tổng hợp số ô trống / đã đỗ theo từng khu vực – tầng, chia nhỏ theo loại phương tiện để bảo vệ hướng dẫn khách đi đúng tầng còn chỗ.
15. **`v_SodoBai_TongQuanBai`**: Thẻ tổng quan công suất từng bãi, đối soát bộ đếm `BAI_DO_XE.SoLuongHienTai` với số lượt gửi đang mở thực tế (cờ `CanhBaoLechBoDem`), kèm nhịp xe vào/ra và doanh thu vé lượt trong ngày.

---

## ⚙️ PHẦN IV: PROCEDURES, TRIGGERS, FUNCTIONS & CURSORS (KÈM KỊCH BẢN DEMO 5 BƯỚC)

Hệ thống cung cấp đầy đủ các khối lệnh lập trình thủ tục nâng cao phục vụ vận hành bãi xe tự động.

### 1. Danh Mục Stored Procedures (`sql/03_procedures.sql`)
- **`sp_XeVaoBai`**: Quét thẻ vào cổng barrier, kiểm tra thẻ hợp lệ, gọi hàm `f_TimSlotTrong` để tự động xếp slot, tạo lượt đỗ mới trong `LUOT_GUI` và cập nhật slot sang `'Đã đỗ'`.
- **`sp_XeRaBai`**: Quét thẻ ra cổng barrier, gọi hàm `f_TinhTienGuiXe` để tính tiền gửi dựa theo đơn giá chi nhánh, ghi nhận `ThoiGianRa`, giải phóng ô đỗ về trạng thái `'Trống'`.
- **`sp_DangKyThanhVien`**: Đăng ký khách hàng mới, phát hành vé tháng, xuất hóa đơn tháng đầu trong một khối **TRANSACTION** bảo đảm tính nguyên tử (Atomicity).
- **`sp_GiaHanTheThang`**: Cộng thêm số ngày sử dụng cho vé tháng và tự sinh hóa đơn thanh toán trong `HOA_DON_VE_THANG`.
- **`sp_BaoMatThe`**: Khóa thẻ bị mất, tự động lập biên bản sự cố trong `LICHSU_SU_CO` và áp mức phạt bồi thường thẻ 50.000đ.
- **`sp_DangNhap`**: Xác thực đăng nhập hệ thống dựa trên tên đăng nhập và mật khẩu băm SHA-256, trả về thông tin nhân viên, chức vụ và bãi xe phụ trách.

### 2. Danh Mục Triggers (`sql/04_triggers.sql`)
- **`trg_KiemTraCheckIn`**: Chặn xe vào nếu thẻ bị khóa hoặc bãi đỗ đã đạt 100% sức chứa (`SoLuongHienTai >= SucChua`).
- **`trg_ChanSuDungVeHetHan`**: Chặn quẹt thẻ tháng nếu vé đăng ký đã quá ngày hết hạn (`NgayHetHan < GETDATE()`).
- **`trg_DongBoTrangThaiSlot`**: Tự động tăng/giảm `SoLuongHienTai` của bãi xe và cập nhật trạng thái ô đỗ trong `VI_TRI_DO` khi bản ghi `LUOT_GUI` được chèn hoặc cập nhật giờ ra.
- **`trg_LogLichSuSuCo`**: Tự động tạo bản ghi biên bản sự cố trong `LICHSU_SU_CO` khi trạng thái thẻ trong `THE_XE` chuyển thành `'Mất'`.
- **`trg_ChanXoaDuLieuDangDung`**: Chặn xóa thông tin bãi xe hoặc thẻ xe nếu đang có phương tiện đỗ thực tế trong bãi.

### 3. Danh Mục User-Defined Functions (`sql/05_functions.sql`)
- **`f_TinhTienGuiXe`**: Hàm vô hướng tính toán tiền gửi xe lũy tiến theo số giờ gửi thực tế và đơn giá loại xe của từng bãi (trả về 0đ nếu là vé tháng hợp lệ).
- **`f_TimSlotTrong`**: Hàm vô hướng trả về mã vị trí ô đỗ (`MaViTri`) còn trống đầu tiên phù hợp với loại phương tiện tại chi nhánh chỉ định.
- **`f_DanhSachXeTrongBai`**: Hàm bảng (Inline Table-Valued Function) trả về danh sách toàn bộ xe đang gửi tại bãi theo mã bãi truyền vào.

### 4. Danh Mục Cursors (`sql/06_cursors.sql`)
- **`cur_CanhBaoHanTheThang`**: Con trỏ duyệt toàn bộ danh sách vé tháng, kiểm tra hạn dùng, tự động chuyển trạng thái sang `'Hết hạn'` nếu quá hạn và xuất thông báo cảnh báo.
- **`cur_TongKetDoanhThuChuoi`**: Con trỏ duyệt qua từng chi nhánh trong chuỗi, tổng hợp doanh thu vé lượt và vé tháng, phục vụ báo cáo định kỳ cho ban giám đốc.

---

## 🖥️ PHẦN V: KIẾN TRÚC GIAO DIỆN WEB DEMO ĐIỀU HÀNH TRỰC QUAN (V6)

Ứng dụng Web Demo được xây dựng theo tiêu chuẩn Dashboard hiện đại, chạy trực tiếp tại địa chỉ **`http://localhost:5001`**, tuân thủ nguyên tắc thiết kế sang trọng, thanh Header/Nav đứng yên khi cuộn trang, spacing và bo góc không vượt quá 12px.

```
                  CỔNG WEB DEMO ĐIỀU HÀNH (PORT 5001)
┌────────────────────────────────────────────────────────────────────────┐
│ [Logo] QUẢN LÝ BÃI ĐỖ XE | Tổng quan | Sơ đồ | Bốt cổng | Bảng | Báo cáo│
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  [MÀN HÌNH TỔNG QUAN / DASHBOARD]                                     │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ BỘ LỌC KỊCH BẢN: [Tất cả (9)] [Procedure] [Trigger] [Function]...│  │
│  └──────────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────┐ │
│  │ ⚡ Procedure Check-In │ │ ⚡ Procedure Check-Out│ │ ⚡ Báo mất thẻ │ │
│  │ Xe vào & cấp slot tự  │ │ Xe ra & tính tiền lũy │ │ Khóa & lập BB │ │
│  │ [Chạy Demo 5 Bước]    │ │ [Chạy Demo 5 Bước]    │ │ [Chạy Demo]   │ │
│  └───────────────────────┘ └───────────────────────┘ └───────────────┘ │
│                                                                        │
│  [MÀN HÌNH TÍCH HỢP HEALTH & SETUP CSDL THÔNG MINH (/setup)]          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ KHỐI 1: KIỂM TRA KẾT NỐI SQL SERVER                              │  │
│  │ [Kiểm tra kết nối] ──> Trạng thái: CONNECTED (Port 1433)         │  │
│  └───────────────────────────────┬──────────────────────────────────┘  │
│                                  │ (Tự động mở khóa khi thành công)    │
│  ┌───────────────────────────────▼──────────────────────────────────┐  │
│  │ KHỐI 2: CÀI ĐẶT CƠ SỞ DỮ LIỆU                                    │  │
│  │ [Tạo nhanh Full CSDL (01-09)]  hoặc  [Chạy từng file tuần tự]    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

### Các Màn Hình Chức Năng Chính:
1. **Màn hình Tổng quan (`/`):**
   - Hiển thị danh mục 9 Kịch Bản Demo CSDL Chuẩn 5 Bước dưới dạng **List Card** phân chia theo 4 nhóm rõ ràng (`Procedure` | `Trigger` | `Function` | `Cursor`).
   - Tích hợp thanh lọc nhanh (Quick Filter Pills) kèm badge đếm số lượng kịch bản.
   - Hộp thoại nhập tham số tương tác và bảng so sánh Before / After trực quan khi thực thi kịch bản.
2. **Màn hình Sơ đồ Bãi xe Thời gian thực (`/map`):**
   - Bộ chọn chi nhánh bãi đỗ xe (`BAI_Q1`, `BAI_Q3`, `BAI_BT`).
   - Thống kê tỷ lệ lấp đầy, số chỗ trống/đã đỗ theo loại xe (Xe máy, Ô tô).
   - Mô phỏng ô đỗ trực quan, hiển thị biển kiểm soát dập nổi phản quang chân thực.
3. **Màn hình Bốt Kiểm Soát Cổng Vào/Ra (`/gate`):**
   - Khối quét thẻ tại barrier: nhập mã thẻ trả về đèn quyết định `MỞ BARRIER` / `TỪ CHỐI`, chiều quét kế tiếp, lý do từ chối và ghi chú cảnh báo an ninh (view `v_BotCong_TraCuuThe`).
   - Bảng đèn tín hiệu cổng vào theo loại phương tiện kèm ô đỗ gợi ý (view `v_BotCong_BangDenCong`).
   - Danh sách xe chờ ra cổng kèm tiền tạm tính và cảnh báo lệch biển số (view `v_BotCong_XeChoRa`).
   - Nhật ký dòng sự kiện xe qua barrier theo trục thời gian (view `v_BotCong_NhatKyVaoRa`).
4. **Màn hình Danh mục Bảng CSDL (`/tables`):**
   - Xem dữ liệu bảng trực tiếp và cấu trúc 11 bảng CSDL.
5. **Màn hình Báo cáo Quản trị BI (`/reports`):**
   - Trực quan hóa dữ liệu 15 Views báo cáo, doanh thu, công suất bãi đỗ, phân loại xe và sự cố.
6. **Màn hình Truy vấn SQL (`/sql`):**
   - Trình thực thi câu lệnh SQL trực tiếp kèm hiển thị kết quả truy vấn dạng bảng.
7. **Màn hình Tích hợp Health & Setup CSDL Thông minh (`/setup`):**
   - **Gom chung Health Check & Setup CSDL:** Tránh tình trạng người dùng click cài đặt khi cơ sở dữ liệu chưa sẵn sàng hoặc kết nối bị từ chối.
   - **Cơ chế khóa bảo vệ an toàn:** Khối Cài đặt CSDL bị ẩn và khóa ban đầu. Chỉ khi người dùng bấm *"Kiểm tra kết nối"* và hệ thống nhận phản hồi thành công (`CONNECTED`), phần Setup mới tự động mở khóa và hiển thị với hiệu ứng slide-in.
   - **Hỗ trợ 2 phương thức cài đặt:** Khởi tạo trọn gói tự động bằng file tổng hợp `QL_BaiDoXe_FullScript.sql` hoặc chạy tuần tự từng script từ `01` đến `09`.

---

## 👥 PHẦN VI: KẾ HOẠCH BÀI BẢN CHIA VIỆC CHO 10 THÀNH VIÊN

Đồ án được phân rã thành **5 nhóm chuyên môn** (mỗi nhóm 2 người) nhằm đảm bảo khối lượng công việc đồng đều, rõ ràng và minh bạch theo chuẩn đồ án đại học:

| Nhóm | Thành viên | Đầu Việc Phụ Trách (Task Allocation) | Sản Phẩm Bàn Giao (Deliverables) |
| :--- | :--- | :--- | :--- |
| **Nhóm 1** | **Thành viên A, B** | **Phân tích Thiết kế ERD & Phân quyền RBAC:**<br>- Thiết kế mô hình quan hệ ERD 11 bảng chuẩn 3NF.<br>- Biên soạn Từ điển Dữ liệu (Data Dictionary).<br>- Viết mã lệnh phân quyền Roles (`r_Admin`, `r_QuanLyBai`, `r_BaoVe`) và các chính sách `GRANT/DENY`. | - File sơ đồ ERD chuẩn dạng PNG/PDF.<br>- Tài liệu Word Từ điển dữ liệu.<br>- File script `sql/08_security_rbac.sql`. |
| **Nhóm 2** | **Thành viên C, D** | **Thiết Lập Môi Trường Docker & Core Schema:**<br>- Cấu hình Docker Container (`Azure SQL Edge` / SQL Server 2022) trên Mac M1 & Windows.<br>- Lập trình file `01_schema.sql` tạo 11 bảng, PK, FK, Composite PK, ràng buộc `CHECK/DEFAULT`.<br>- Tổng hợp file chạy tự động `QL_BaiDoXe_FullScript.sql`. | - File `docker-compose.yml`.<br>- File `sql/01_schema.sql` chạy 100% không lỗi.<br>- File `sql/QL_BaiDoXe_FullScript.sql`. |
| **Nhóm 3** | **Thành viên E, F** | **Lập Trình Stored Procedures, Triggers & Backup:**<br>- Viết 6 Stored Procedures nghiệp vụ (`sp_XeVaoBai`, `sp_XeRaBai`, `sp_DangNhap`,...).<br>- Viết 5 Triggers kiểm soát an ninh bãi xe.<br>- Lập trình kịch bản Full/Diff/Log Backup & Restore CSDL. | - File `sql/03_procedures.sql`.<br>- File `sql/04_triggers.sql`.<br>- File script `sql/09_backup_restore.sql`. |
| **Nhóm 4** | **Thành viên G, H** | **Lập Trình Views, Functions, Cursors & Bulk Data:**<br>- Viết 15 Bảng Views giám sát realtime, bốt kiểm soát cổng vào/ra và báo cáo BI.<br>- Viết 3 Functions tính phí và xếp slot tự động.<br>- Viết 2 Cursors duyệt quét tự động.<br>- Viết script Bulk Insert Import thẻ xe từ file CSV. | - File `sql/05_functions.sql`.<br>- File `sql/06_cursors.sql`.<br>- File `sql/07_views.sql`.<br>- Data file CSV mẫu & kịch bản bulk data. |
| **Nhóm 5** | **Thành viên I, K** | **Dữ Liệu Mẫu, Web Demo UI & Biên Soạn Báo Cáo:**<br>- Chuẩn bị dữ liệu mẫu thực tế cho 11 bảng (`02_sample_data.sql`).<br>- Phát triển giao diện Web Dashboard điều hành trực quan (Flask + Jinja2 + Modern UI).<br>- Biên soạn Báo cáo hoàn chỉnh theo mẫu template trường quy định. | - File `sql/02_sample_data.sql`.<br>- Source code Web App (`app/`, `run.py`).<br>- File Báo cáo Word/PDF hoàn chỉnh (< 20 trang). |

---

## 📋 PHẦN VII: CHECKLIST ĐÓNG GÓI SẢN PHẨM NỘP BÀI (`DoAn_NhomX.zip`)

Cấu trúc gói nộp bài chuẩn bị sẵn sàng bàn giao cho giảng viên chấm thi:

- [x] **File Báo Cáo Chính Thức (PDF):** Trình bày theo đúng mẫu `Report_Template (Team).docx`, dưới 20 trang, bao gồm mô hình ERD, mô tả 11 bảng, phân quyền RBAC và bảng phân công trách nhiệm 10 thành viên.
- [x] **File Slide Thuyết Trình (PDF/PPTX):** 15-20 slides tóm tắt đề tài, điểm nổi bật của hệ thống CSDL, kiến trúc bảo mật và hình ảnh demo.
- [x] **Link Video Thuyết Minh Demo:** File text ghi rõ link video 15-20 phút (upload YouTube/Google Drive chế độ công khai) minh họa kịch bản 5 bước chạy trong SSMS và trên giao diện Web.
- [x] **Thư Mục Mã Nguồn CSDL (`sql/`):**
  - `01_schema.sql`: Script khởi tạo 11 bảng.
  - `02_sample_data.sql`: Dữ liệu mẫu thực tế.
  - `03_procedures.sql`: 6 Stored Procedures nghiệp vụ.
  - `04_triggers.sql`: 5 Triggers an ninh & toàn vẹn dữ liệu.
  - `05_functions.sql`: 3 Functions tính phí và tìm slot.
  - `06_cursors.sql`: 2 Cursors duyệt tự động.
  - `07_views.sql`: 15 Views vận hành, bốt cổng, sơ đồ realtime & báo cáo BI.
  - `08_security_rbac.sql`: Phân quyền 3 Roles RBAC.
  - `09_backup_restore.sql`: Chiến lược sao lưu và khôi phục CSDL.
  - `QL_BaiDoXe_FullScript.sql`: Script tổng hợp toàn bộ CSDL chạy 1 lần duy nhất.
- [x] **Thư Mục Mã Nguồn Web Ứng Dụng (`app/`, `run.py`, `requirements.txt`):** Ứng dụng điều hành trực quan cổng 5001.
- [x] **Tài Liệu Hướng Dẫn Chạy:** `README.md` và `DemoGuilde.md` hướng dẫn chi tiết các bước thiết lập từ số 0.
