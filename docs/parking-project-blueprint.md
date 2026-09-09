# THIẾT KẾ KỸ THUẬT & KẾ HOẠCH BÀI BẢN: HỆ THỐNG QUẢN LÝ CHUỖI BÃI ĐỖ XE (VERSION 6)

> **Dành cho:** Đồ án môn Quản lý Thông tin / Quản trị Cơ sở Dữ liệu (IE103)  
> **Kiến trúc Hệ thống:** SQL Server (Docker Azure SQL Edge trên Mac M1 / Windows Local) + Python Backend (FastAPI/pyodbc) + Angular 22 (Signals, Zoneless) + Tailwind CSS  
> **Quy mô Nhóm:** 10 Thành viên (Chia thành 5 nhóm nhỏ, mỗi nhóm 2 người)

---

## 🗄️ PHẦN I: THIẾT KẾ CƠ SỞ DỮ LIỆU VẬT LÝ HÒAN CHỈNH (11 BẢNG)

Cơ sở dữ liệu được thiết kế chuẩn hóa, phân tách triệt để dữ liệu theo từng chi nhánh bãi đỗ xe (`MaBai`), đồng thời tích hợp đầy đủ phân hệ **Quản trị Tài khoản - Phân quyền** và **Quản lý An toàn Thông tin**.

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

 [PHÂN HỆ BẢO MẬT]: NHAN_VIEN (1) <---> (1) TAI_KHOAN
```

### 1. Bảng `BAI_DO_XE` (Thông tin các bãi đỗ xe trong chuỗi)
Quản lý danh sách các chi nhánh bãi đỗ thuộc hệ thống chuỗi.
- **`MaBai`** `VARCHAR(10)` **[PK]**: Mã bãi đỗ xe (`BAI_Q1`, `BAI_Q3`, `BAI_BT`).
- **`TenBai`** `NVARCHAR(100)` `NOT NULL` `UNIQUE`: Tên bãi đỗ xe (*Bãi xe Lê Lai, Bãi xe Landmark 81*).
- **`DiaChi`** `NVARCHAR(255)` `NOT NULL`: Địa chỉ vật lý của bãi đỗ xe.
- **`SucChua`** `INT` `NOT NULL`: Số lượng vị trí đỗ (slot) tối đa thiết kế. **CHECK**: `SucChua > 0`.
- **`SoLuongHienTai`** `INT` `NOT NULL` `DEFAULT 0`: Số xe thực tế đang gửi. **CHECK**: `SoLuongHienTai >= 0 AND SoLuongHienTai <= SucChua`.

### 2. Bảng `NHAN_VIEN` (Hồ sơ nhân sự bãi đỗ xe)
Lưu trữ thông tin nhân viên bảo vệ, quản lý chi nhánh và ban giám đốc.
- **`MaNV`** `VARCHAR(10)` **[PK]**: Mã định danh nhân viên (`NV001`, `NV002`).
- **`HoTen`** `NVARCHAR(100)` `NOT NULL`: Họ và tên nhân viên.
- **`ChucVu`** `NVARCHAR(50)` `NOT NULL`: Chức vụ (*Giám đốc*, *Quản lý bãi*, *Bảo vệ*).
- **`SDT`** `VARCHAR(15)` `NOT NULL` `UNIQUE`: Số điện thoại liên hệ.
- **`Email`** `VARCHAR(100)` `NULL` `UNIQUE`: Email công vụ.
- **`MaBai`** `VARCHAR(10)` **[FK Nullable]**: Liên kết `BAI_DO_XE(MaBai)`. Nếu là Bảo vệ/Quản lý bãi thì chỉ định bãi cụ thể; nếu là Admin/Giám đốc thì gán `NULL` (quản lý toàn chuỗi).

### 3. Bảng `TAI_KHOAN` (Tài khoản truy cập & Xác thực)
Quản lý thông tin đăng nhập và mật khẩu mã hóa cho nhân viên.
- **`TenDangNhap`** `VARCHAR(50)` **[PK]**: Tên tài khoản truy cập hệ thống.
- **`MatKhauHash`** `VARCHAR(255)` `NOT NULL`: Chuỗi mật khẩu đã qua mã hóa HASH (SHA-256 / BCrypt).
- **`MaNV`** `VARCHAR(10)` **[FK]**: Liên kết `NHAN_VIEN(MaNV)`.
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Hoạt động'`: **CHECK**: `TrangThai IN (N'Hoạt động', N'Bị khóa')`.

### 4. Bảng `LOAI_XE` (Phân loại phương tiện & Biểu phí theo từng bãi)
Sử dụng **Khóa chính hỗn hợp (Composite PK)** gồm `MaLoaiXe` và `MaBai` để định nghĩa mức giá theo vị trí địa lý.
- **`MaLoaiXe`** `VARCHAR(10)` **[Composite PK]**: Mã loại xe (`XM` - Xe máy, `OT` - Ô tô, `XD` - Xe đạp).
- **`MaBai`** `VARCHAR(10)` **[Composite PK, FK]**: Liên kết `BAI_DO_XE(MaBai)`.
- **`TenLoai`** `NVARCHAR(50)` `NOT NULL`: Tên hiển thị loại xe (*Xe máy, Ô tô 4 chỗ*).
- **`DonGiaGio`** `DECIMAL(18,2)` `NOT NULL`: Đơn giá đỗ xe lượt trên 1 giờ (VND). **CHECK**: `DonGiaGio > 0`.
- **`GiaVeThang`** `DECIMAL(18,2)` `NOT NULL`: Đơn giá vé tháng 30 ngày (VND). **CHECK**: `GiaVeThang > 0`.

### 5. Bảng `VI_TRI_DO` (Sơ đồ mặt bằng các slot đỗ xe vật lý)
- **`MaViTri`** `VARCHAR(20)` **[PK]**: Định dạng duy nhất `MABAI_SLOT` (`Q1_A101`, `Q3_B202`).
- **`KhuVuc`** `NVARCHAR(20)` `NOT NULL`: Phân khu (*Khu A, Tầng hầm 1*).
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Trống'`: **CHECK**: `TrangThai IN (N'Trống', N'Đã đỗ')`.
- **`MaLoaiXe`** `VARCHAR(10)` **[FK]**: Khóa ngoại kết hợp `(MaLoaiXe, MaBai)` tham chiếu sang `LOAI_XE(MaLoaiXe, MaBai)`.
- **`MaBai`** `VARCHAR(10)` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`.

### 6. Bảng `THE_XE` (Quản lý kho thẻ chip gửi xe theo bãi)
- **`MaThe`** `VARCHAR(10)` **[PK]**: Mã số thẻ quét vật lý (`THE0001`, `THE0002`).
- **`MaBai`** `VARCHAR(10)` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`. Xác định thẻ thuộc bãi đỗ nào quản lý.
- **`LoaiThe`** `NVARCHAR(10)` `NOT NULL`: **CHECK**: `LoaiThe IN (N'Lượt', N'Tháng')`.
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Hoạt động'`: **CHECK**: `TrangThai IN (N'Hoạt động', N'Bị khóa', N'Mất')`.
- **`NgayCap`** `DATE` `NOT NULL` `DEFAULT GETDATE()`: Ngày nạp thẻ chip vào bãi.

### 7. Bảng `KHACH_HANG` (Hồ sơ chủ xe đăng ký vé tháng)
- **`MaKH`** `VARCHAR(10)` **[PK]**: Mã khách hàng thành viên (`KH0001`).
- **`HoTen`** `NVARCHAR(100)` `NOT NULL`: Họ và tên chủ xe.
- **`SDT`** `VARCHAR(15)` `NOT NULL` `UNIQUE`: Số điện thoại liên hệ.
- **`Email`** `VARCHAR(100)` `NULL` `UNIQUE`: Địa chỉ email nhận cảnh báo gia hạn.
- **`CMND_CCCD`** `VARCHAR(12)` `NOT NULL` `UNIQUE`: Số CCCD phục vụ an ninh.

### 8. Bảng `VE_THANG` (Bản đăng ký vé xe tháng)
- **`MaVe`** `VARCHAR(10)` **[PK]**: Mã vé tháng (`V0001`).
- **`MaThe`** `VARCHAR(10)` **[FK, UNIQUE]**: Liên kết `THE_XE(MaThe)`. 1 thẻ chỉ gán cho 1 vé đang hoạt động.
- **`MaKH`** `VARCHAR(10)` **[FK]**: Liên kết `KHACH_HANG(MaKH)`.
- **`BienSo`** `VARCHAR(15)` `NOT NULL`: Biển số xe đăng ký.
- **`MaLoaiXe`** `VARCHAR(10)` **[FK]**: Loại xe đăng ký.
- **`NgayDangKy`** `DATE` `NOT NULL` `DEFAULT GETDATE()`: Ngày kích hoạt.
- **`NgayHetHan`** `DATE` `NOT NULL`: Ngày hết hạn vé.
- **`TrangThai`** `NVARCHAR(20)` `NOT NULL` `DEFAULT N'Hoạt động'`: **CHECK**: `TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Hết hạn')`.
- **`MaBaiApDung`** `VARCHAR(10)` `NOT NULL`: Mã bãi cụ thể (`BAI_Q1`) hoặc `'ALL'` (đỗ toàn hệ thống).

### 9. Bảng `LUOT_GUI` (Nhật ký xe vào/ra chi tiết theo bãi)
- **`MaLuot`** `INT` **[PK IDENTITY]**: Mã lượt gửi tự tăng.
- **`MaThe`** `VARCHAR(10)` **[FK]**: Thẻ quét vào/ra.
- **`BienSo`** `VARCHAR(15)` `NOT NULL`: Biển số xe nhận diện.
- **`ThoiGianVao`** `DATETIME` `NOT NULL` `DEFAULT GETDATE()`: Thời điểm vào bãi.
- **`ThoiGianRa`** `DATETIME` `NULL`: Thời điểm ra bãi (`NULL` nếu đang đỗ).
- **`MaViTri`** `VARCHAR(20)` **[FK]**: Ô đỗ cấp cho xe.
- **`TienGui`** `DECIMAL(18,2)` `NOT NULL` `DEFAULT 0`: Phí thu thực tế.
- **`MaBai`** `VARCHAR(10)` **[FK]**: Liên kết `BAI_DO_XE(MaBai)`.

### 10. Bảng `HOA_DON_VE_THANG` (Lịch sử gia hạn vé tháng theo bãi)
- **`MaHD`** `VARCHAR(15)` **[PK]**: Mã hóa đơn (`HD20260908001`).
- **`MaVe`** `VARCHAR(10)` **[FK]**: Hóa đơn thuộc vé tháng nào.
- **`NgayThanhToan`** `DATETIME` `NOT NULL` `DEFAULT GETDATE()`: Ngày giờ đóng tiền.
- **`SoThangGiaHan`** `INT` `NOT NULL` `DEFAULT 1`: Số tháng đóng tiền trước. **CHECK**: `SoThangGiaHan > 0`.
- **`SoTien`** `DECIMAL(18,2)` `NOT NULL`: Tổng tiền thu.
- **`MaBai`** `VARCHAR(10)` **[FK]**: Ghi nhận doanh thu cho bãi thực hiện.

### 11. Bảng `LICHSU_SU_CO` (Nhật ký xử lý sự cố tại từng bãi)
- **`MaSuCo`** `INT` **[PK IDENTITY]**: Mã sự cố tự tăng.
- **`MaThe`** `VARCHAR(10)` **[FK NULL]**: Mã thẻ liên quan (nếu có).
- **`BienSo`** `VARCHAR(15)` `NULL`: Biển số xe liên quan.
- **`ThoiGianSuCo`** `DATETIME` `NOT NULL` `DEFAULT GETDATE()`: Thời điểm xảy ra sự cố.
- **`MoTa`** `NVARCHAR(500)` `NOT NULL`: Mô tả biên bản sự cố.
- **`TienPhat`** `DECIMAL(18,2)` `NOT NULL` `DEFAULT 0`: Số tiền phạt đền bù.
- **`TrangThaiXuLy`** `NVARCHAR(50)` `NOT NULL` `DEFAULT N'Chờ xử lý'`: **CHECK**: `TrangThaiXuLy IN (N'Chờ xử lý', N'Đang giải quyết', N'Đã giải quyết')`.
- **`MaBai`** `VARCHAR(10)` **[FK]**: Bãi đỗ xảy ra sự cố.

---

## 🔒 PHẦN II: AN TOÀN THÔNG TIN, PHÂN QUYỀN & QUẢN TRỊ CSDL

### 1. Phân quyền Truy cập (Role-Based Access Control - RBAC)
Thiết lập 3 vai trò người dùng trong SQL Server với mức độ truy cập được phân cấp chặt chẽ:

```sql
-- Tạo các Roles quản trị trong SQL Server
CREATE ROLE r_Admin;
CREATE ROLE r_QuanLyBai;
CREATE ROLE r_BaoVe;

-- 1. Quyền r_Admin: Quyền tối cao (Full Control)
GRANT CONTROL TO r_Admin;

-- 2. Quyền r_QuanLyBai: Được thao tác trên dữ liệu nghiệp vụ của bãi đỗ
GRANT SELECT, INSERT, UPDATE ON BAI_DO_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON VI_TRI_DO TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON THE_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON VE_THANG TO r_QuanLyBai;
GRANT SELECT ON LUOT_GUI TO r_QuanLyBai;
GRANT SELECT ON HOA_DON_VE_THANG TO r_QuanLyBai;

-- 3. Quyền r_BaoVe: Chỉ có quyền quét xe vào/ra và xem sơ đồ đỗ
GRANT EXECUTE ON sp_XeVaoBai TO r_BaoVe;
GRANT EXECUTE ON sp_XeRaBai TO r_BaoVe;
GRANT SELECT ON v_SodoOdoRealtime TO r_BaoVe;
DENY UPDATE, DELETE ON LUOT_GUI TO r_BaoVe; -- Chặn bảo vệ sửa tiền/xóa lượt gửi
```

### 2. Import & Export Dữ liệu Hàng loạt (Bulk Data)
- **Import thẻ xe từ CSV:**
```sql
BULK INSERT THE_XE
FROM 'C:\data	he_xe_import.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '
',
    FIRSTROW = 2
);
```
- **Export Báo cáo Doanh thu sang CSV/Excel:**
Sử dụng câu lệnh `bcp` hoặc script Python export dữ liệu trực tiếp từ các bảng View `v_DoanhThuTheoBai`.

### 3. Sao lưu & Khôi phục CSDL (Backup & Restore)
- **FULL BACKUP (Sao lưu toàn bộ - Thực hiện hàng tuần):**
```sql
BACKUP DATABASE QuanLyBaiDoXe
TO DISK = 'C:ackup\QuanLyBaiDoXe_Full.bak'
WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup QuanLyBaiDoXe';
```
- **DIFFERENTIAL BACKUP (Sao lưu phần thay đổi - Thực hiện hàng ngày):**
```sql
BACKUP DATABASE QuanLyBaiDoXe
TO DISK = 'C:ackup\QuanLyBaiDoXe_Diff.bak'
WITH DIFFERENTIAL;
```
- **RESTORE DATABASE (Khôi phục dữ liệu khi gặp sự cố):**
```sql
RESTORE DATABASE QuanLyBaiDoXe
FROM DISK = 'C:ackup\QuanLyBaiDoXe_Full.bak'
WITH REPLACE, NORECOVERY;
```

---

## 👁️ PHẦN III: DANH SÁCH BẢNG VÀO (VIEWS) VẬN HÀNH & BÁO CÁO

### 1. `v_SodoOdoRealtime`: Sơ đồ ô đỗ thời gian thực
```sql
CREATE VIEW v_SodoOdoRealtime AS
SELECT 
    v.MaBai, b.TenBai, v.MaViTri, v.KhuVuc, v.TrangThai,
    l.TenLoai, lg.BienSo, lg.ThoiGianVao
FROM VI_TRI_DO v
JOIN BAI_DO_XE b ON v.MaBai = b.MaBai
JOIN LOAI_XE l ON v.MaLoaiXe = l.MaLoaiXe AND v.MaBai = l.MaBai
LEFT JOIN LUOT_GUI lg ON v.MaViTri = lg.MaViTri AND lg.ThoiGianRa IS NULL;
```

### 2. `v_Xedangtrongbai`: Danh sách xe hiện đỗ trong bãi
```sql
CREATE VIEW v_Xedangtrongbai AS
SELECT 
    lg.MaLuot, lg.MaBai, b.TenBai, lg.MaThe, lg.BienSo, 
    lg.MaViTri, lg.ThoiGianVao, t.LoaiThe
FROM LUOT_GUI lg
JOIN BAI_DO_XE b ON lg.MaBai = b.MaBai
JOIN THE_XE t ON lg.MaThe = t.MaThe
WHERE lg.ThoiGianRa IS NULL;
```

### 3. `v_DanhsachveThangsaphethan`: Danh sách vé tháng còn dưới 3 ngày sử dụng
```sql
CREATE VIEW v_DanhsachveThangsaphethan AS
SELECT 
    vt.MaVe, vt.MaThe, kh.HoTen, kh.SDT, vt.BienSo, 
    vt.NgayHetHan, DATEDIFF(DAY, GETDATE(), vt.NgayHetHan) AS SongayConLai, vt.MaBaiApDung
FROM VE_THANG vt
JOIN KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE DATEDIFF(DAY, GETDATE(), vt.NgayHetHan) BETWEEN 0 AND 3
  AND vt.TrangThai = N'Hoạt động';
```

---

## ⚙️ PHẦN IV: PROCEDURES, TRIGGERS, FUNCTIONS & CURSORS (KÈM DEMO 5 BƯỚC)

*Mỗi đối tượng lập trình đều chứa bình luận SQL phân tách rõ:*
- **HÀNH VI TÊN WEBSITE:** Thao tác người dùng click nút trên giao diện Angular 22.
- **KỊCH BẢN DEMO 5 BƯỚC TRONG SSMS:** Bộ lệnh SELECT kiểm chứng dữ liệu trước và sau khi thực thi.

### 1. Stored Procedures (`03_procedures.sql`)
- `sp_XeVaoBai`: Kiểm tra thẻ, tìm ô trống (`f_TimSlotTrong`), tạo lượt đỗ mới trong `LUOT_GUI`, đổi trạng thái ô đỗ.
- `sp_XeRaBai`: Tìm lượt gửi, tính tiền (`f_TinhTienGuiXe`), cập nhật `ThoiGianRa`, `TienGui`, giải phóng ô đỗ về `'Trống'`.
- `sp_DangKyThanhVien`: Tạo khách hàng, đăng ký vé tháng, xuất hóa đơn gia hạn (nằm trong **TRANSACTION**).
- `sp_GiaHanTheThang`: Cộng ngày hết hạn vé tháng, chèn bản ghi hóa đơn.
- `sp_BaoMatThe`: Đổi trạng thái thẻ sang `'Mất'`, tự ghi nhận sự cố, thu tiền phạt đền thẻ 50k.
- `sp_DangNhap`: Kiểm tra tài khoản, đối chiếu mật khẩu Hash, trả về quyền và `MaBai` được phân công.

### 2. Triggers (`04_triggers.sql`)
- `trg_KiemTraCheckIn`: Chặn xe vào nếu thẻ bị khóa/mất hoặc bãi đã đầy công suất (`SoLuongHienTai >= SucChua`).
- `trg_ChanSuDungVeHetHan`: Chặn xe tháng hết hạn đăng ký check-in bãi đỗ.
- `trg_DongBoTrangThaiSlot`: Tự động cập nhật `TrangThai` ô đỗ và tăng/giảm `SoLuongHienTai` của bãi đỗ khi check-in/out.
- `trg_LogLichSuSuCo`: Tự động chèn biên bản vào `LICHSU_SU_CO` khi thẻ bị chuyển trạng thái báo mất.
- `trg_ChanXoaDuLieuDangDung`: Chặn xóa bãi xe/thẻ xe nếu đang có xe đỗ chưa check-out.

### 3. Functions (`05_functions.sql`)
- `f_TinhTienGuiXe`: Tính phí đỗ xe lượt lũy tiến theo giờ và đơn giá bãi đỗ (trả về 0 nếu là vé tháng hợp lệ).
- `f_TimSlotTrong`: Trả về `MaViTri` ô đỗ trống đầu tiên khớp loại xe tại bãi đỗ chỉ định.
- `f_DanhSachXeTrongBai`: Trả về bảng danh sách xe đỗ thực tế.

### 4. Cursors (`06_cursors.sql`)
- `cur_CanhBaoHanTheThang`: Quét danh sách vé tháng sắp hết hạn, tự chuyển trạng thái `'Hết hạn'` nếu quá ngày.
- `cur_TongKetDoanhThuChuoi`: Duyệt qua từng bãi xe trong chuỗi, tính toán doanh thu tổng lượt và tháng trong tuần.

---

## 👥 PHẦN V: KẾ HOẠCH BÀI BẢN CHIA VIỆC CHO 10 THÀNH VIÊN

Dự án được phân rã thành **5 nhóm làm việc nhỏ** (mỗi nhóm 2 người) giúp đảm bảo sự đồng đều, minh bạch trách nhiệm và hỗ trợ lẫn nhau theo đúng mẫu báo cáo của trường.

| Nhóm | Thành viên | Đầu việc Phụ trách (Task Allocation) | Sản phẩm Bàn giao (Deliverables) |
| :--- | :--- | :--- | :--- |
| **Nhóm 1** | **Thành viên A, B** | **Phân tích ERD & Phân quyền RBAC:**<br>- Vẽ sơ đồ ERD 11 bảng chuẩn hóa.<br>- Viết tài liệu Từ điển Dữ liệu (Data Dictionary).<br>- Viết mã lệnh SQL tạo Role (`r_Admin`, `r_QuanLyBai`, `r_BaoVe`) và các câu lệnh `GRANT/DENY`. | - Sơ đồ ERD chuẩn dạng PNG.<br>- File Word Từ điển dữ liệu.<br>- Script phân quyền SQL. |
| **Nhóm 2** | **Thành viên C, D** | **Setup Docker & Core Schema SQL:**<br>- Cấu hình Docker (`Azure SQL Edge`) trên Mac M1 (bạn).<br>- Viết file `01_schema.sql` tạo 11 bảng, PK, FK, ràng buộc `CHECK/DEFAULT`.<br>- Kiểm thử chạy script tạo bảng trên Mac và Windows. | - File `docker-compose.yml`.<br>- File `01_schema.sql` chạy 100% không lỗi. |
| **Nhóm 3** | **Thành viên E, F** | **Lập trình Procedures, Triggers & Backup:**<br>- Viết 5 Stored Procedures nghiệp vụ (`sp_XeVaoBai`, `sp_XeRaBai`,...).<br>- Viết 5 Triggers bẫy lỗi an toàn bãi xe.<br>- Viết script **Full/Diff Backup & Restore** CSDL. | - File `03_procedures.sql`.<br>- File `04_triggers.sql`.<br>- Script Backup/Restore. |
| **Nhóm 4** | **Thành viên G, H** | **Lập trình Views & Script Import/Export:**<br>- Viết 3-5 bảng View giám sát realtime và báo cáo.<br>- Viết lệnh `BULK INSERT` Import dữ liệu thẻ từ CSV.<br>- Viết script Export báo cáo doanh thu ra CSV. | - File `05_functions.sql` & Views.<br>- Data file CSV & Script Import/Export. |
| **Nhóm 5** | **Thành viên I, K** | **Dữ liệu mẫu & Biên soạn Báo cáo cuối kỳ:**<br>- Chuẩn bị dữ liệu mẫu 10-20 dòng/bảng (`02_sample_data.sql`).<br>- Tổng hợp báo cáo vào template `Report_Template (Team).docx`.<br>- Soạn nội dung chương "An toàn thông tin & Phân quyền". | - File `02_sample_data.sql`.<br>- File Báo cáo Word hoàn chỉnh (< 20 trang). |

---

## 📋 CHECKLIST ĐÓNG GÓI SẢN PHẨM NỘP BÀI (`DoAn_NhomX.zip`)

- [x] **File Báo cáo PDF:** Trình bày theo mẫu `Report_Template (Team).docx`, dưới 20 trang, chứa bảng phân công 10 người.
- [x] **File Slide Thuyết trình PDF:** 15-20 slides tóm tắt đề tài, mô hình ERD, phân quyền và demo.
- [x] **Link Video Demo:** File text chứa link video 15-20 phút (upload Google Drive công khai).
- [x] **Thư mục `database/`:** Chứa đầy đủ 6 file SQL (`01_schema.sql` đến `06_cursors.sql` + script Phân quyền, Backup).
- [x] **Thư mục Source Code:** Mã nguồn Web Python (FastAPI) + Angular 22.
