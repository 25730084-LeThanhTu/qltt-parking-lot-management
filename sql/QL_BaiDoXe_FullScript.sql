-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- KỊCH BẢN ĐỒNG BỘ TOÀN DIỆN (FULL AUTOMATED SCRIPT: 21 BẢNG, PROCEDURES, TRIGGERS, VIEWS, RBAC, RLS)
-- FILE SINH TỰ ĐỘNG BỞI tools/build_fullscript.py TỪ CÁC MODULE TRONG sql/. KHÔNG SỬA TAY.
-- ====================================================================================

USE master;
GO

IF DB_ID('QuanLyBaiDoXe') IS NOT NULL
BEGIN
    ALTER DATABASE QuanLyBaiDoXe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyBaiDoXe;
END;
GO

CREATE DATABASE QuanLyBaiDoXe;
GO

USE QuanLyBaiDoXe;
GO


-- ==================== BẮT ĐẦU: 01_schema.sql (21 BẢNG, SEQUENCE, DANH MỤC TRA CỨU) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 1: TẠO CẤU TRÚC BẢNG CƠ SỞ DỮ LIỆU VẬT LÝ (11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

-- Hủy đối tượng phần cổng khách hàng (nếu có) trước: security policy và các hàm RLS gắn SCHEMABINDING
-- vào bảng sẽ chặn DROP TABLE, các bảng cổng khách hàng có khóa ngoại trỏ vào bảng vận hành (xem phần cổng khách hàng cuối file)
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'rls_KhachHang') DROP SECURITY POLICY bao_mat.rls_KhachHang;
IF OBJECT_ID('bao_mat.fn_rls_KhachHang', 'IF') IS NOT NULL DROP FUNCTION bao_mat.fn_rls_KhachHang;
IF OBJECT_ID('bao_mat.fn_rls_VeThang', 'IF') IS NOT NULL DROP FUNCTION bao_mat.fn_rls_VeThang;
IF OBJECT_ID('bao_mat.fn_rls_GiaoDich', 'IF') IS NOT NULL DROP FUNCTION bao_mat.fn_rls_GiaoDich;
IF OBJECT_ID('bao_mat.fn_rls_TheoVe', 'IF') IS NOT NULL DROP FUNCTION bao_mat.fn_rls_TheoVe;
IF OBJECT_ID('dbo.UY_QUYEN_VE', 'U') IS NOT NULL DROP TABLE dbo.UY_QUYEN_VE;
IF OBJECT_ID('dbo.VAI_TRO_QUYEN', 'U') IS NOT NULL DROP TABLE dbo.VAI_TRO_QUYEN;
IF OBJECT_ID('dbo.VAI_TRO_KH', 'U') IS NOT NULL DROP TABLE dbo.VAI_TRO_KH;
IF OBJECT_ID('dbo.QUYEN_KH', 'U') IS NOT NULL DROP TABLE dbo.QUYEN_KH;
IF OBJECT_ID('dbo.THONG_BAO', 'U') IS NOT NULL DROP TABLE dbo.THONG_BAO;
IF OBJECT_ID('dbo.NHAT_KY_DANG_NHAP', 'U') IS NOT NULL DROP TABLE dbo.NHAT_KY_DANG_NHAP;
IF OBJECT_ID('dbo.HOA_DON_VE_THANG', 'U') IS NOT NULL DROP TABLE dbo.HOA_DON_VE_THANG;
IF OBJECT_ID('dbo.GIAO_DICH', 'U') IS NOT NULL DROP TABLE dbo.GIAO_DICH;
IF OBJECT_ID('dbo.VI_DIEN_TU', 'U') IS NOT NULL DROP TABLE dbo.VI_DIEN_TU;
IF OBJECT_ID('dbo.TAI_KHOAN_KH', 'U') IS NOT NULL DROP TABLE dbo.TAI_KHOAN_KH;
IF OBJECT_ID('dbo.PHUONG_THUC_THANH_TOAN', 'U') IS NOT NULL DROP TABLE dbo.PHUONG_THUC_THANH_TOAN;
IF OBJECT_ID('dbo.seq_GiaoDich', 'SO') IS NOT NULL DROP SEQUENCE dbo.seq_GiaoDich;

-- Hủy bảng cũ theo thứ tự ngược phụ thuộc khóa ngoại
IF OBJECT_ID('dbo.LICHSU_SU_CO', 'U') IS NOT NULL DROP TABLE dbo.LICHSU_SU_CO;
IF OBJECT_ID('dbo.HOA_DON_VE_THANG', 'U') IS NOT NULL DROP TABLE dbo.HOA_DON_VE_THANG;
IF OBJECT_ID('dbo.LUOT_GUI', 'U') IS NOT NULL DROP TABLE dbo.LUOT_GUI;
IF OBJECT_ID('dbo.VE_THANG', 'U') IS NOT NULL DROP TABLE dbo.VE_THANG;
IF OBJECT_ID('dbo.KHACH_HANG', 'U') IS NOT NULL DROP TABLE dbo.KHACH_HANG;
IF OBJECT_ID('dbo.THE_XE', 'U') IS NOT NULL DROP TABLE dbo.THE_XE;
IF OBJECT_ID('dbo.VI_TRI_DO', 'U') IS NOT NULL DROP TABLE dbo.VI_TRI_DO;
IF OBJECT_ID('dbo.LOAI_XE', 'U') IS NOT NULL DROP TABLE dbo.LOAI_XE;
IF OBJECT_ID('dbo.TAI_KHOAN', 'U') IS NOT NULL DROP TABLE dbo.TAI_KHOAN;
IF OBJECT_ID('dbo.NHAN_VIEN', 'U') IS NOT NULL DROP TABLE dbo.NHAN_VIEN;
IF OBJECT_ID('dbo.BAI_DO_XE', 'U') IS NOT NULL DROP TABLE dbo.BAI_DO_XE;
GO

-- 1. Bảng BAI_DO_XE: Quản lý danh sách các chi nhánh bãi xe trong chuỗi
CREATE TABLE dbo.BAI_DO_XE (
    MaBai VARCHAR(10) NOT NULL,
    TenBai NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255) NOT NULL,
    SucChua INT NOT NULL,
    SoLuongHienTai INT NOT NULL DEFAULT 0,
    CONSTRAINT PK_BAI_DO_XE PRIMARY KEY (MaBai),
    CONSTRAINT UQ_TenBai UNIQUE (TenBai),
    CONSTRAINT CK_SucChua CHECK (SucChua > 0),
    CONSTRAINT CK_SoLuongHienTai CHECK (SoLuongHienTai >= 0 AND SoLuongHienTai <= SucChua)
);
GO

-- 2. Bảng NHAN_VIEN: Hồ sơ nhân sự bãi đỗ xe (Phân hệ Bảo mật & Nhân sự)
CREATE TABLE dbo.NHAN_VIEN (
    MaNV VARCHAR(10) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    ChucVu NVARCHAR(50) NOT NULL,
    SDT VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NULL,
    MaBai VARCHAR(10) NULL,
    CONSTRAINT PK_NHAN_VIEN PRIMARY KEY (MaNV),
    CONSTRAINT UQ_NhanVien_SDT UNIQUE (SDT),
    CONSTRAINT FK_NhanVien_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai),
    CONSTRAINT CK_NhanVien_ChucVu CHECK (ChucVu IN (N'Giám đốc điều hành', N'Quản lý bãi', N'Bảo vệ'))
);
GO

-- Email duy nhất khi có giá trị; cho phép nhiều nhân viên để trống (UNIQUE constraint chỉ nhận một NULL)
CREATE UNIQUE INDEX UQ_NhanVien_Email ON dbo.NHAN_VIEN(Email) WHERE Email IS NOT NULL;
GO

-- 3. Bảng TAI_KHOAN: Tài khoản truy cập & Xác thực nhân viên (Phân hệ An toàn thông tin)
CREATE TABLE dbo.TAI_KHOAN (
    TenDangNhap VARCHAR(50) NOT NULL,
    MatKhauHash VARBINARY(64) NOT NULL,   -- SHA2_512(salt + mật khẩu) qua dbo.f_BamMatKhau (N5)
    MatKhauSalt VARBINARY(16) NOT NULL,   -- salt ngẫu nhiên riêng từng tài khoản
    MaNV VARCHAR(10) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Hoạt động',
    CONSTRAINT PK_TAI_KHOAN PRIMARY KEY (TenDangNhap),
    CONSTRAINT FK_TaiKhoan_NhanVien FOREIGN KEY (MaNV) REFERENCES dbo.NHAN_VIEN(MaNV),
    CONSTRAINT CK_TaiKhoan_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Bị khóa'))
);
GO

-- 4. Bảng LOAI_XE: Biểu phí gửi lượt và gửi tháng theo từng bãi đỗ (Khóa chính hỗn hợp)
CREATE TABLE dbo.LOAI_XE (
    MaLoaiXe VARCHAR(10) NOT NULL,
    MaBai VARCHAR(10) NOT NULL,
    TenLoai NVARCHAR(50) NOT NULL,
    DonGiaGio DECIMAL(18,2) NOT NULL,
    GiaVeThang DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_LOAI_XE PRIMARY KEY (MaLoaiXe, MaBai),
    CONSTRAINT FK_LoaiXe_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai) ON DELETE CASCADE,
    CONSTRAINT CK_DonGiaGio CHECK (DonGiaGio > 0),
    CONSTRAINT CK_GiaVeThang CHECK (GiaVeThang > 0)
);
GO

-- 5. Bảng VI_TRI_DO: Danh mục các ô đỗ xe vật lý theo từng bãi
CREATE TABLE dbo.VI_TRI_DO (
    MaViTri VARCHAR(20) NOT NULL,
    KhuVuc NVARCHAR(20) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Trống',
    MaLoaiXe VARCHAR(10) NOT NULL,
    MaBai VARCHAR(10) NOT NULL,
    CONSTRAINT PK_VI_TRI_DO PRIMARY KEY (MaViTri),
    CONSTRAINT FK_ViTriDo_LoaiXe FOREIGN KEY (MaLoaiXe, MaBai) REFERENCES dbo.LOAI_XE(MaLoaiXe, MaBai),
    CONSTRAINT FK_ViTriDo_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai),
    CONSTRAINT CK_TrangThaiViTri CHECK (TrangThai IN (N'Trống', N'Đã đỗ'))
);
GO

-- 6. Bảng THE_XE: Kho thẻ chip gửi xe phân chia theo từng bãi sở hữu
CREATE TABLE dbo.THE_XE (
    MaThe VARCHAR(10) NOT NULL,
    MaBai VARCHAR(10) NOT NULL,
    LoaiThe NVARCHAR(10) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Hoạt động',
    NgayCap DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_THE_XE PRIMARY KEY (MaThe),
    CONSTRAINT FK_TheXe_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai),
    CONSTRAINT CK_LoaiThe CHECK (LoaiThe IN (N'Lượt', N'Tháng')),
    CONSTRAINT CK_TrangThaiThe CHECK (TrangThai IN (N'Hoạt động', N'Bị khóa', N'Mất'))
);
GO

-- 7. Bảng KHACH_HANG: Hồ sơ khách hàng đăng ký vé tháng
CREATE TABLE dbo.KHACH_HANG (
    MaKH VARCHAR(10) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NULL,
    CMND_CCCD VARCHAR(12) NOT NULL,
    CONSTRAINT PK_KHACH_HANG PRIMARY KEY (MaKH),
    CONSTRAINT UQ_KhachHang_SDT UNIQUE (SDT),
    CONSTRAINT UQ_KhachHang_CMND UNIQUE (CMND_CCCD)
);
GO

-- Email duy nhất khi có giá trị; cho phép nhiều khách hàng để trống (UNIQUE constraint chỉ nhận một NULL)
CREATE UNIQUE INDEX UQ_KhachHang_Email ON dbo.KHACH_HANG(Email) WHERE Email IS NOT NULL;
GO

-- 8. Bảng VE_THANG: Quản lý vé gửi xe định kỳ hàng tháng
CREATE TABLE dbo.VE_THANG (
    MaVe VARCHAR(10) NOT NULL,
    MaThe VARCHAR(10) NOT NULL,
    MaKH VARCHAR(10) NOT NULL,
    BienSo VARCHAR(15) NOT NULL,
    MaLoaiXe VARCHAR(10) NOT NULL,
    NgayDangKy DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    NgayHetHan DATE NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Hoạt động',
    MaBaiApDung VARCHAR(10) NOT NULL,
    CONSTRAINT PK_VE_THANG PRIMARY KEY (MaVe),
    CONSTRAINT FK_VeThang_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe),
    CONSTRAINT FK_VeThang_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH),
    CONSTRAINT CK_VeThang_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Hết hạn')),
    CONSTRAINT CK_VeThang_Han CHECK (NgayHetHan >= NgayDangKy)
);
GO

-- Mỗi thẻ chỉ gắn với một vé còn dùng (Hoạt động / Tạm khóa); vé đã Hết hạn không giữ thẻ (N4),
-- nên thẻ vật lý được cấp lại cho vé mới. "Vé hiện hành" của thẻ lấy qua dbo.f_VeHienHanhCuaThe.
CREATE UNIQUE INDEX UX_VeThang_MaThe_ConDung ON dbo.VE_THANG (MaThe) WHERE TrangThai <> N'Hết hạn';
GO

-- 9. Bảng LUOT_GUI: Nhật ký xe ra vào bãi xe (Check-In / Check-Out)
CREATE TABLE dbo.LUOT_GUI (
    MaLuot INT IDENTITY(1,1) NOT NULL,
    MaThe VARCHAR(10) NOT NULL,
    BienSo VARCHAR(15) NOT NULL,
    ThoiGianVao DATETIME NOT NULL DEFAULT GETDATE(),
    ThoiGianRa DATETIME NULL,
    MaViTri VARCHAR(20) NOT NULL,
    TienGui DECIMAL(18,2) NOT NULL DEFAULT 0,
    MaBai VARCHAR(10) NOT NULL,
    CONSTRAINT PK_LUOT_GUI PRIMARY KEY (MaLuot),
    CONSTRAINT FK_LuotGui_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe),
    CONSTRAINT FK_LuotGui_ViTriDo FOREIGN KEY (MaViTri) REFERENCES dbo.VI_TRI_DO(MaViTri),
    CONSTRAINT FK_LuotGui_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai),
    CONSTRAINT CK_LuotGui_TienGui CHECK (TienGui >= 0),
    CONSTRAINT CK_LuotGui_ThoiGianRa CHECK (ThoiGianRa IS NULL OR ThoiGianRa >= ThoiGianVao)
);
GO

-- 10. Bảng HOA_DON_VE_THANG: Lịch sử nộp tiền đăng ký và gia hạn vé tháng
CREATE TABLE dbo.HOA_DON_VE_THANG (
    MaHD VARCHAR(15) NOT NULL,
    MaVe VARCHAR(10) NOT NULL,
    NgayThanhToan DATETIME NOT NULL DEFAULT GETDATE(),
    SoThangGiaHan INT NOT NULL DEFAULT 1,
    SoTien DECIMAL(18,2) NOT NULL,
    MaBai VARCHAR(10) NOT NULL,
    CONSTRAINT PK_HOA_DON_VE_THANG PRIMARY KEY (MaHD),
    CONSTRAINT FK_HoaDon_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe),
    CONSTRAINT FK_HoaDon_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai),
    CONSTRAINT CK_HoaDon_SoThang CHECK (SoThangGiaHan > 0),
    CONSTRAINT CK_HoaDon_SoTien CHECK (SoTien > 0)
);
GO

-- 11. Bảng LICHSU_SU_CO: Biên bản xử lý sự cố (mất thẻ, hư hại) tại các bãi xe
CREATE TABLE dbo.LICHSU_SU_CO (
    MaSuCo INT IDENTITY(1,1) NOT NULL,
    MaThe VARCHAR(10) NULL,
    BienSo VARCHAR(15) NULL,
    ThoiGianSuCo DATETIME NOT NULL DEFAULT GETDATE(),
    MoTa NVARCHAR(500) NOT NULL,
    TienPhat DECIMAL(18,2) NOT NULL DEFAULT 0,
    TrangThaiXuLy NVARCHAR(50) NOT NULL DEFAULT N'Chờ xử lý',
    MaBai VARCHAR(10) NOT NULL,
    CONSTRAINT PK_LICHSU_SU_CO PRIMARY KEY (MaSuCo),
    CONSTRAINT FK_SuCo_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe),
    CONSTRAINT FK_SuCo_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai),
    CONSTRAINT CK_SuCo_TienPhat CHECK (TienPhat >= 0),
    CONSTRAINT CK_SuCo_TrangThai CHECK (TrangThaiXuLy IN (N'Chờ xử lý', N'Đang giải quyết', N'Đã giải quyết'))
);
GO

-- Tối ưu tra cứu xe đang đỗ theo bãi và vị trí cho sơ đồ bãi xe thời gian thực
CREATE INDEX IX_LuotGui_DangDo
ON dbo.LUOT_GUI (MaBai, MaViTri)
INCLUDE (MaThe, BienSo, ThoiGianVao)
WHERE ThoiGianRa IS NULL;
GO

-- Tối ưu báo cáo và tác vụ quét hạn vé tháng
CREATE INDEX IX_VeThang_TrangThai_NgayHetHan
ON dbo.VE_THANG (TrangThai, NgayHetHan)
INCLUDE (MaThe, MaKH, BienSo, MaBaiApDung);
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- SCHEMA CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 3)
-- 10 bảng mới, cột mới trên 4 bảng cũ, chỉ mục, danh mục tra cứu (PTTT, quyền, vai trò).
-- Script idempotent: chạy lại nhiều lần trên CSDL đã nâng cấp không lỗi, không nhân đôi dữ liệu.
-- Danh mục tra cứu nạp ngay tại đây vì khóa ngoại của cột cũ (HOA_DON_VE_THANG.MaPTTT) cần dữ liệu cha.
-- ====================================================================================

-- 1. Sequence sinh mã giao dịch ví (D9): GIAO_DICH ghi nhiều và đồng thời nên không dùng MAX + 1
IF OBJECT_ID('dbo.seq_GiaoDich', 'SO') IS NULL
    CREATE SEQUENCE dbo.seq_GiaoDich AS BIGINT START WITH 1 INCREMENT BY 1;
GO

-- 2. Bảng PHUONG_THUC_THANH_TOAN: Danh mục phương thức thanh toán
IF OBJECT_ID('dbo.PHUONG_THUC_THANH_TOAN', 'U') IS NULL
CREATE TABLE dbo.PHUONG_THUC_THANH_TOAN (
    MaPTTT VARCHAR(20) NOT NULL,
    TenPTTT NVARCHAR(100) NOT NULL,
    LoaiKenh NVARCHAR(30) NOT NULL,
    PhiPhanTram DECIMAL(5,2) NOT NULL CONSTRAINT DF_PTTT_PhiPhanTram DEFAULT 0,
    SoTienToiThieu DECIMAL(18,2) NOT NULL CONSTRAINT DF_PTTT_SoTienToiThieu DEFAULT 10000,
    ChoPhepNapVi BIT NOT NULL CONSTRAINT DF_PTTT_ChoPhepNapVi DEFAULT 1,
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_PTTT_TrangThai DEFAULT N'Hoạt động',
    CONSTRAINT PK_PHUONG_THUC_THANH_TOAN PRIMARY KEY (MaPTTT),
    CONSTRAINT UQ_PTTT_TenPTTT UNIQUE (TenPTTT),
    CONSTRAINT CK_PTTT_LoaiKenh CHECK (LoaiKenh IN (N'Tiền mặt', N'Ngân hàng', N'Ví điện tử', N'Thẻ', N'Số dư ví')),
    CONSTRAINT CK_PTTT_PhiPhanTram CHECK (PhiPhanTram BETWEEN 0 AND 10),
    CONSTRAINT CK_PTTT_SoTienToiThieu CHECK (SoTienToiThieu >= 0),
    CONSTRAINT CK_PTTT_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm ngưng'))
);
GO

-- 3. Bảng TAI_KHOAN_KH: Tài khoản đăng nhập của khách hàng (tách biệt TAI_KHOAN của nhân viên - D1)
IF OBJECT_ID('dbo.TAI_KHOAN_KH', 'U') IS NULL
CREATE TABLE dbo.TAI_KHOAN_KH (
    MaTK VARCHAR(12) NOT NULL,
    MaKH VARCHAR(10) NOT NULL,
    TenDangNhap VARCHAR(100) NOT NULL,
    MatKhauHash VARBINARY(64) NOT NULL,
    MatKhauSalt VARBINARY(16) NOT NULL,
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_TKKH_TrangThai DEFAULT N'Hoạt động',
    SoLanSaiLienTiep TINYINT NOT NULL CONSTRAINT DF_TKKH_SoLanSaiLienTiep DEFAULT 0,
    KhoaDen DATETIME NULL,
    NgayTao DATETIME NOT NULL CONSTRAINT DF_TKKH_NgayTao DEFAULT GETDATE(),
    LanDangNhapCuoi DATETIME NULL,
    CONSTRAINT PK_TAI_KHOAN_KH PRIMARY KEY (MaTK),
    CONSTRAINT UQ_TKKH_MaKH UNIQUE (MaKH),
    CONSTRAINT UQ_TKKH_TenDangNhap UNIQUE (TenDangNhap),
    CONSTRAINT FK_TKKH_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH),
    CONSTRAINT CK_TKKH_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Đã đóng')),
    CONSTRAINT CK_TKKH_DinhDangMa CHECK (MaTK LIKE 'TK[0-9][0-9][0-9][0-9]%'),
    CONSTRAINT CK_TKKH_DoDaiSalt CHECK (DATALENGTH(MatKhauSalt) = 16)
);
GO

-- 4. Bảng NHAT_KY_DANG_NHAP: Nhật ký đăng nhập cổng khách hàng (audit bảo mật)
IF OBJECT_ID('dbo.NHAT_KY_DANG_NHAP', 'U') IS NULL
CREATE TABLE dbo.NHAT_KY_DANG_NHAP (
    MaNK BIGINT IDENTITY(1,1) NOT NULL,
    MaTK VARCHAR(12) NULL,
    TenDangNhapNhap VARCHAR(100) NOT NULL,
    ThoiGian DATETIME NOT NULL CONSTRAINT DF_NKDN_ThoiGian DEFAULT GETDATE(),
    KetQua NVARCHAR(20) NOT NULL,
    DiaChiIP VARCHAR(45) NULL,
    ThietBi NVARCHAR(200) NULL,
    CONSTRAINT PK_NHAT_KY_DANG_NHAP PRIMARY KEY (MaNK),
    CONSTRAINT FK_NKDN_TaiKhoanKH FOREIGN KEY (MaTK) REFERENCES dbo.TAI_KHOAN_KH(MaTK),
    CONSTRAINT CK_NKDN_KetQua CHECK (KetQua IN (N'Thành công', N'Sai mật khẩu', N'Không tồn tại', N'Bị khóa'))
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_NhatKy_MaTK_ThoiGian' AND object_id = OBJECT_ID('dbo.NHAT_KY_DANG_NHAP'))
    CREATE INDEX IX_NhatKy_MaTK_ThoiGian ON dbo.NHAT_KY_DANG_NHAP (MaTK, ThoiGian DESC) INCLUDE (KetQua);
GO

-- 5. Bảng VI_DIEN_TU: Ví trả trước của khách hàng (số dư chỉ do trigger sổ cái cập nhật - D4)
IF OBJECT_ID('dbo.VI_DIEN_TU', 'U') IS NULL
CREATE TABLE dbo.VI_DIEN_TU (
    MaVi VARCHAR(12) NOT NULL,
    MaKH VARCHAR(10) NOT NULL,
    SoDu DECIMAL(18,2) NOT NULL CONSTRAINT DF_Vi_SoDu DEFAULT 0,
    HanMucNapNgay DECIMAL(18,2) NOT NULL CONSTRAINT DF_Vi_HanMucNapNgay DEFAULT 20000000,
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_Vi_TrangThai DEFAULT N'Hoạt động',
    NgayTao DATETIME NOT NULL CONSTRAINT DF_Vi_NgayTao DEFAULT GETDATE(),
    PhienBan ROWVERSION,
    CONSTRAINT PK_VI_DIEN_TU PRIMARY KEY (MaVi),
    CONSTRAINT UQ_Vi_MaKH UNIQUE (MaKH),
    CONSTRAINT FK_Vi_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH),
    CONSTRAINT CK_Vi_SoDu CHECK (SoDu >= 0),
    CONSTRAINT CK_Vi_HanMucNapNgay CHECK (HanMucNapNgay > 0),
    CONSTRAINT CK_Vi_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Đóng băng')),
    CONSTRAINT CK_Vi_DinhDangMa CHECK (MaVi LIKE 'VI[0-9][0-9][0-9][0-9]%')
);
GO

-- 6. Bảng GIAO_DICH: Sổ cái giao dịch ví, chỉ ghi thêm (append-only - D3)
IF OBJECT_ID('dbo.GIAO_DICH', 'U') IS NULL
CREATE TABLE dbo.GIAO_DICH (
    MaGD VARCHAR(16) NOT NULL,
    MaVi VARCHAR(12) NOT NULL,
    LoaiGD NVARCHAR(30) NOT NULL,
    HuongTien SMALLINT NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    PhiGiaoDich DECIMAL(18,2) NOT NULL CONSTRAINT DF_GD_PhiGiaoDich DEFAULT 0,
    SoDuTruoc DECIMAL(18,2) NULL,
    SoDuSau DECIMAL(18,2) NULL,
    MaPTTT VARCHAR(20) NOT NULL,
    MaThamChieu VARCHAR(64) NULL,
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_GD_TrangThai DEFAULT N'Chờ xử lý',
    MaVe VARCHAR(10) NULL,
    MaGDGoc VARCHAR(16) NULL,
    NguoiThucHien NVARCHAR(20) NOT NULL CONSTRAINT DF_GD_NguoiThucHien DEFAULT N'Khách hàng',
    MaNV VARCHAR(10) NULL,
    ThoiGianTao DATETIME NOT NULL CONSTRAINT DF_GD_ThoiGianTao DEFAULT GETDATE(),
    ThoiGianHoanTat DATETIME NULL,
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT PK_GIAO_DICH PRIMARY KEY (MaGD),
    CONSTRAINT FK_GD_ViDienTu FOREIGN KEY (MaVi) REFERENCES dbo.VI_DIEN_TU(MaVi),
    CONSTRAINT FK_GD_PTTT FOREIGN KEY (MaPTTT) REFERENCES dbo.PHUONG_THUC_THANH_TOAN(MaPTTT),
    CONSTRAINT FK_GD_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe),
    CONSTRAINT FK_GD_GiaoDichGoc FOREIGN KEY (MaGDGoc) REFERENCES dbo.GIAO_DICH(MaGD),
    CONSTRAINT FK_GD_NhanVien FOREIGN KEY (MaNV) REFERENCES dbo.NHAN_VIEN(MaNV),
    CONSTRAINT CK_GD_LoaiGD CHECK (LoaiGD IN (N'Nạp tiền', N'Thanh toán vé tháng', N'Hoàn tiền', N'Điều chỉnh')),
    CONSTRAINT CK_GD_HuongTien CHECK (HuongTien IN (1, -1)),
    CONSTRAINT CK_GD_HuongTien_Loai CHECK (
        (LoaiGD IN (N'Nạp tiền', N'Hoàn tiền') AND HuongTien = 1)
        OR (LoaiGD = N'Thanh toán vé tháng' AND HuongTien = -1)
        OR LoaiGD = N'Điều chỉnh'),
    CONSTRAINT CK_GD_SoTien CHECK (SoTien > 0),
    CONSTRAINT CK_GD_PhiGiaoDich CHECK (PhiGiaoDich >= 0),
    CONSTRAINT CK_GD_TrangThai CHECK (TrangThai IN (N'Chờ xử lý', N'Thành công', N'Thất bại', N'Đã hoàn')),
    CONSTRAINT CK_GD_VeThang CHECK (LoaiGD <> N'Thanh toán vé tháng' OR MaVe IS NOT NULL),
    CONSTRAINT CK_GD_HoanTienCoGoc CHECK (LoaiGD <> N'Hoàn tiền' OR MaGDGoc IS NOT NULL),
    CONSTRAINT CK_GD_NguoiThucHien CHECK (NguoiThucHien IN (N'Khách hàng', N'Nhân viên', N'Hệ thống'))
);
GO

-- Idempotency callback cổng thanh toán: mỗi mã tham chiếu chỉ gắn với đúng 1 giao dịch
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_GiaoDich_MaThamChieu' AND object_id = OBJECT_ID('dbo.GIAO_DICH'))
    CREATE UNIQUE INDEX UX_GiaoDich_MaThamChieu ON dbo.GIAO_DICH (MaThamChieu) WHERE MaThamChieu IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_GiaoDich_MaVi_ThoiGian' AND object_id = OBJECT_ID('dbo.GIAO_DICH'))
    CREATE INDEX IX_GiaoDich_MaVi_ThoiGian ON dbo.GIAO_DICH (MaVi, ThoiGianTao DESC) INCLUDE (LoaiGD, SoTien, TrangThai);
GO

-- 7. Bảng THONG_BAO: Hộp thư thông báo của khách hàng
IF OBJECT_ID('dbo.THONG_BAO', 'U') IS NULL
CREATE TABLE dbo.THONG_BAO (
    MaTB BIGINT IDENTITY(1,1) NOT NULL,
    MaKH VARCHAR(10) NOT NULL,
    LoaiTB NVARCHAR(30) NOT NULL,
    TieuDe NVARCHAR(150) NOT NULL,
    NoiDung NVARCHAR(1000) NOT NULL,
    MaVe VARCHAR(10) NULL,
    MaGD VARCHAR(16) NULL,
    DaDoc BIT NOT NULL CONSTRAINT DF_TB_DaDoc DEFAULT 0,
    ThoiGianTao DATETIME NOT NULL CONSTRAINT DF_TB_ThoiGianTao DEFAULT GETDATE(),
    CONSTRAINT PK_THONG_BAO PRIMARY KEY (MaTB),
    CONSTRAINT FK_TB_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH),
    CONSTRAINT FK_TB_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe),
    CONSTRAINT FK_TB_GiaoDich FOREIGN KEY (MaGD) REFERENCES dbo.GIAO_DICH(MaGD),
    CONSTRAINT CK_TB_LoaiTB CHECK (LoaiTB IN (N'Giao dịch', N'Sắp hết hạn', N'Hết hạn', N'Bảo mật', N'Ủy quyền', N'Hệ thống'))
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ThongBao_MaKH_DaDoc' AND object_id = OBJECT_ID('dbo.THONG_BAO'))
    CREATE INDEX IX_ThongBao_MaKH_DaDoc ON dbo.THONG_BAO (MaKH, DaDoc, ThoiGianTao DESC);
GO

-- 8. Bảng QUYEN_KH: Danh mục quyền nghiệp vụ của tài khoản khách hàng
IF OBJECT_ID('dbo.QUYEN_KH', 'U') IS NULL
CREATE TABLE dbo.QUYEN_KH (
    MaQuyen VARCHAR(30) NOT NULL,
    MoTa NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_QUYEN_KH PRIMARY KEY (MaQuyen)
);
GO

-- 9. Bảng VAI_TRO_KH: Vai trò của tài khoản trên một vé tháng
IF OBJECT_ID('dbo.VAI_TRO_KH', 'U') IS NULL
CREATE TABLE dbo.VAI_TRO_KH (
    MaVaiTro VARCHAR(20) NOT NULL,
    TenVaiTro NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(300) NULL,
    CONSTRAINT PK_VAI_TRO_KH PRIMARY KEY (MaVaiTro),
    CONSTRAINT UQ_VaiTroKH_Ten UNIQUE (TenVaiTro)
);
GO

-- 10. Bảng VAI_TRO_QUYEN: Ma trận vai trò x quyền
IF OBJECT_ID('dbo.VAI_TRO_QUYEN', 'U') IS NULL
CREATE TABLE dbo.VAI_TRO_QUYEN (
    MaVaiTro VARCHAR(20) NOT NULL,
    MaQuyen VARCHAR(30) NOT NULL,
    CONSTRAINT PK_VAI_TRO_QUYEN PRIMARY KEY (MaVaiTro, MaQuyen),
    CONSTRAINT FK_VTQ_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES dbo.VAI_TRO_KH(MaVaiTro),
    CONSTRAINT FK_VTQ_Quyen FOREIGN KEY (MaQuyen) REFERENCES dbo.QUYEN_KH(MaQuyen)
);
GO

-- 11. Bảng UY_QUYEN_VE: Chủ vé chia sẻ vé cho tài khoản khác với vai trò hạn chế
IF OBJECT_ID('dbo.UY_QUYEN_VE', 'U') IS NULL
CREATE TABLE dbo.UY_QUYEN_VE (
    MaUyQuyen INT IDENTITY(1,1) NOT NULL,
    MaVe VARCHAR(10) NOT NULL,
    MaTKDuocUyQuyen VARCHAR(12) NOT NULL,
    MaVaiTro VARCHAR(20) NOT NULL,
    NgayBatDau DATE NOT NULL CONSTRAINT DF_UQ_NgayBatDau DEFAULT CAST(GETDATE() AS DATE),
    NgayKetThuc DATE NULL,
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_UQ_TrangThai DEFAULT N'Hiệu lực',
    MaTKCap VARCHAR(12) NOT NULL,
    NgayTao DATETIME NOT NULL CONSTRAINT DF_UQ_NgayTao DEFAULT GETDATE(),
    CONSTRAINT PK_UY_QUYEN_VE PRIMARY KEY (MaUyQuyen),
    CONSTRAINT FK_UQ_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe),
    CONSTRAINT FK_UQ_TaiKhoanNhan FOREIGN KEY (MaTKDuocUyQuyen) REFERENCES dbo.TAI_KHOAN_KH(MaTK),
    CONSTRAINT FK_UQ_TaiKhoanCap FOREIGN KEY (MaTKCap) REFERENCES dbo.TAI_KHOAN_KH(MaTK),
    CONSTRAINT FK_UQ_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES dbo.VAI_TRO_KH(MaVaiTro),
    CONSTRAINT CK_UQ_KhongPhaiChuVe CHECK (MaVaiTro <> 'CHU_SO_HUU'),
    CONSTRAINT CK_UQ_ThoiHan CHECK (NgayKetThuc IS NULL OR NgayKetThuc >= NgayBatDau),
    CONSTRAINT CK_UQ_TrangThai CHECK (TrangThai IN (N'Hiệu lực', N'Đã thu hồi'))
);
GO

-- Mỗi tài khoản chỉ có tối đa 1 ủy quyền còn hiệu lực trên cùng một vé
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_UyQuyen_HieuLuc' AND object_id = OBJECT_ID('dbo.UY_QUYEN_VE'))
    CREATE UNIQUE INDEX UX_UyQuyen_HieuLuc ON dbo.UY_QUYEN_VE (MaVe, MaTKDuocUyQuyen) WHERE TrangThai = N'Hiệu lực';
GO

-- ====================================================================================
-- 12. DANH MỤC TRA CỨU (MERGE để chạy lại không nhân đôi)
-- ====================================================================================
MERGE dbo.PHUONG_THUC_THANH_TOAN AS dich
USING (VALUES
    ('TIEN_MAT',     N'Tiền mặt tại quầy',        N'Tiền mặt',   0.00, 10000,  1, N'Hoạt động'),
    ('CHUYEN_KHOAN', N'Chuyển khoản ngân hàng',   N'Ngân hàng',  0.00, 50000,  1, N'Hoạt động'),
    ('MOMO',         N'Ví MoMo',                  N'Ví điện tử', 1.50, 10000,  1, N'Hoạt động'),
    ('ZALOPAY',      N'Ví ZaloPay',               N'Ví điện tử', 1.20, 10000,  1, N'Tạm ngưng'),
    ('VNPAY',        N'Cổng VNPay',               N'Ví điện tử', 1.10, 10000,  1, N'Hoạt động'),
    ('THE_NH',       N'Thẻ ngân hàng (ATM/Visa)', N'Thẻ',        2.00, 50000,  1, N'Hoạt động'),
    ('SO_DU_VI',     N'Số dư ví SmartPark',       N'Số dư ví',   0.00, 0,      0, N'Hoạt động')
) AS nguon (MaPTTT, TenPTTT, LoaiKenh, PhiPhanTram, SoTienToiThieu, ChoPhepNapVi, TrangThai)
ON dich.MaPTTT = nguon.MaPTTT
WHEN NOT MATCHED THEN
    INSERT (MaPTTT, TenPTTT, LoaiKenh, PhiPhanTram, SoTienToiThieu, ChoPhepNapVi, TrangThai)
    VALUES (nguon.MaPTTT, nguon.TenPTTT, nguon.LoaiKenh, nguon.PhiPhanTram, nguon.SoTienToiThieu, nguon.ChoPhepNapVi, nguon.TrangThai);
GO

MERGE dbo.QUYEN_KH AS dich
USING (VALUES
    ('VE.XEM',           N'Xem thông tin vé tháng và hạn dùng'),
    ('LICHSU.XEM',       N'Xem lịch sử đỗ xe của vé'),
    ('VE.GIAHAN',        N'Gia hạn vé bằng số dư ví'),
    ('VE.BAOMAT',        N'Báo mất thẻ của vé (khóa thẻ ngay)'),
    ('VI.XEM',           N'Xem số dư và sao kê ví của chính mình'),
    ('VI.NAPTIEN',       N'Nạp tiền vào ví của chính mình'),
    ('GIAODICH.XEM',     N'Xem lịch sử giao dịch của chính mình'),
    ('VE.UYQUYEN',       N'Chia sẻ hoặc thu hồi quyền trên vé cho tài khoản khác'),
    ('VE.TUDONGGIAHAN',  N'Bật hoặc tắt tự động gia hạn vé')
) AS nguon (MaQuyen, MoTa)
ON dich.MaQuyen = nguon.MaQuyen
WHEN NOT MATCHED THEN INSERT (MaQuyen, MoTa) VALUES (nguon.MaQuyen, nguon.MoTa);
GO

MERGE dbo.VAI_TRO_KH AS dich
USING (VALUES
    ('CHU_SO_HUU',  N'Chủ sở hữu vé',          N'Khách hàng đứng tên vé tháng. Vai trò được suy ra từ VE_THANG.MaKH, không lưu trong UY_QUYEN_VE.'),
    ('THANH_VIEN',  N'Thành viên (người nhà)', N'Người nhà hoặc tài xế: xem vé, xem lịch sử đỗ xe, báo mất thẻ.'),
    ('XEM_LICH_SU', N'Chỉ xem lịch sử',        N'Kế toán doanh nghiệp: chỉ xem vé và lịch sử đỗ xe.')
) AS nguon (MaVaiTro, TenVaiTro, MoTa)
ON dich.MaVaiTro = nguon.MaVaiTro
WHEN NOT MATCHED THEN INSERT (MaVaiTro, TenVaiTro, MoTa) VALUES (nguon.MaVaiTro, nguon.TenVaiTro, nguon.MoTa);
GO

-- Quyền ví/giao dịch (VI.*, GIAODICH.*) luôn chỉ áp dụng trên ví của chính tài khoản, xem f_KH_CoQuyen
MERGE dbo.VAI_TRO_QUYEN AS dich
USING (VALUES
    ('CHU_SO_HUU', 'VE.XEM'), ('CHU_SO_HUU', 'LICHSU.XEM'), ('CHU_SO_HUU', 'VE.BAOMAT'),
    ('CHU_SO_HUU', 'VE.GIAHAN'), ('CHU_SO_HUU', 'VE.TUDONGGIAHAN'), ('CHU_SO_HUU', 'VE.UYQUYEN'),
    ('THANH_VIEN', 'VE.XEM'), ('THANH_VIEN', 'LICHSU.XEM'), ('THANH_VIEN', 'VE.BAOMAT'),
    ('XEM_LICH_SU', 'VE.XEM'), ('XEM_LICH_SU', 'LICHSU.XEM')
) AS nguon (MaVaiTro, MaQuyen)
ON dich.MaVaiTro = nguon.MaVaiTro AND dich.MaQuyen = nguon.MaQuyen
WHEN NOT MATCHED THEN INSERT (MaVaiTro, MaQuyen) VALUES (nguon.MaVaiTro, nguon.MaQuyen);
GO

-- ====================================================================================
-- 13. CỘT MỚI TRÊN BẢNG CŨ (chỉ thêm cột NULL hoặc có DEFAULT, an toàn ngược - UPGRADE_PLAN 3.3)
-- ====================================================================================

-- HOA_DON_VE_THANG: phương thức, kênh thanh toán, giao dịch ví liên kết, nhân viên thu
IF COL_LENGTH('dbo.HOA_DON_VE_THANG', 'MaPTTT') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD MaPTTT VARCHAR(20) NOT NULL
        CONSTRAINT DF_HoaDon_MaPTTT DEFAULT 'TIEN_MAT';
GO
IF COL_LENGTH('dbo.HOA_DON_VE_THANG', 'KenhThanhToan') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD KenhThanhToan NVARCHAR(20) NOT NULL
        CONSTRAINT DF_HoaDon_KenhThanhToan DEFAULT N'Tại quầy';
GO
IF COL_LENGTH('dbo.HOA_DON_VE_THANG', 'MaGD') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD MaGD VARCHAR(16) NULL;
GO
IF COL_LENGTH('dbo.HOA_DON_VE_THANG', 'MaNVThu') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD MaNVThu VARCHAR(10) NULL;
GO
IF OBJECT_ID('dbo.FK_HoaDon_PTTT', 'F') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD CONSTRAINT FK_HoaDon_PTTT
        FOREIGN KEY (MaPTTT) REFERENCES dbo.PHUONG_THUC_THANH_TOAN(MaPTTT);
GO
IF OBJECT_ID('dbo.FK_HoaDon_GiaoDich', 'F') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD CONSTRAINT FK_HoaDon_GiaoDich
        FOREIGN KEY (MaGD) REFERENCES dbo.GIAO_DICH(MaGD);
GO
IF OBJECT_ID('dbo.FK_HoaDon_NhanVienThu', 'F') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD CONSTRAINT FK_HoaDon_NhanVienThu
        FOREIGN KEY (MaNVThu) REFERENCES dbo.NHAN_VIEN(MaNV);
GO
IF OBJECT_ID('dbo.CK_HoaDon_KenhThanhToan', 'C') IS NULL
    ALTER TABLE dbo.HOA_DON_VE_THANG ADD CONSTRAINT CK_HoaDon_KenhThanhToan
        CHECK (KenhThanhToan IN (N'Tại quầy', N'Online', N'Tự động'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HoaDon_MaGD' AND object_id = OBJECT_ID('dbo.HOA_DON_VE_THANG'))
    CREATE UNIQUE INDEX UX_HoaDon_MaGD ON dbo.HOA_DON_VE_THANG (MaGD) WHERE MaGD IS NOT NULL;
GO

-- VE_THANG: cấu hình tự động gia hạn bằng số dư ví
IF COL_LENGTH('dbo.VE_THANG', 'TuDongGiaHan') IS NULL
    ALTER TABLE dbo.VE_THANG ADD TuDongGiaHan BIT NOT NULL
        CONSTRAINT DF_VeThang_TuDongGiaHan DEFAULT 0;
GO
IF COL_LENGTH('dbo.VE_THANG', 'SoThangTuDongGiaHan') IS NULL
    ALTER TABLE dbo.VE_THANG ADD SoThangTuDongGiaHan TINYINT NOT NULL
        CONSTRAINT DF_VeThang_SoThangTuDongGiaHan DEFAULT 1;
GO
IF OBJECT_ID('dbo.CK_VeThang_SoThangTuDongGiaHan', 'C') IS NULL
    ALTER TABLE dbo.VE_THANG ADD CONSTRAINT CK_VeThang_SoThangTuDongGiaHan
        CHECK (SoThangTuDongGiaHan BETWEEN 1 AND 12);
GO

-- LUOT_GUI: lượt gửi thuộc vé tháng nào (lịch sử đỗ xe đúng theo vé kể cả khi thẻ được cấp lại)
IF COL_LENGTH('dbo.LUOT_GUI', 'MaVe') IS NULL
    ALTER TABLE dbo.LUOT_GUI ADD MaVe VARCHAR(10) NULL;
GO
IF OBJECT_ID('dbo.FK_LuotGui_VeThang', 'F') IS NULL
    ALTER TABLE dbo.LUOT_GUI ADD CONSTRAINT FK_LuotGui_VeThang
        FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LuotGui_MaVe_ThoiGianVao' AND object_id = OBJECT_ID('dbo.LUOT_GUI'))
    CREATE INDEX IX_LuotGui_MaVe_ThoiGianVao ON dbo.LUOT_GUI (MaVe, ThoiGianVao DESC) WHERE MaVe IS NOT NULL;
GO

-- KHACH_HANG: ngày tạo hồ sơ
IF COL_LENGTH('dbo.KHACH_HANG', 'NgayTao') IS NULL
    ALTER TABLE dbo.KHACH_HANG ADD NgayTao DATETIME NOT NULL
        CONSTRAINT DF_KhachHang_NgayTao DEFAULT GETDATE();
GO

-- ====================================================================================
-- 14. BACKFILL: gắn lượt gửi cũ của thẻ tháng với vé có hiệu lực tại thời điểm xe vào
-- (UPDATE trên LUOT_GUI kích hoạt trg_DongBoTrangThaiSlot nhưng không đổi ThoiGianRa nên không ảnh hưởng ô đỗ)
-- ====================================================================================
UPDATE lg
SET lg.MaVe = vt.MaVe
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.THE_XE tx ON lg.MaThe = tx.MaThe
INNER JOIN dbo.VE_THANG vt ON vt.MaThe = lg.MaThe
WHERE lg.MaVe IS NULL
  AND tx.LoaiThe = N'Tháng'
  AND CAST(lg.ThoiGianVao AS DATE) BETWEEN vt.NgayDangKy AND vt.NgayHetHan;
GO


-- ==================== BẮT ĐẦU: 02_sample_data.sql (DỮ LIỆU MẪU) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 2: NẠP DỮ LIỆU KHỞI TẠO MẪU (SAMPLE DATA CHO 11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

-- SINH TỰ ĐỘNG TỪ docs/QuanLyBaiDoXe_DuLieuMau.xlsx (NGUỒN CHUẨN CỦA DỮ LIỆU MẪU).
-- Không sửa tay file này: sửa dữ liệu trong Excel (sheet KiemTra phải ĐẠT hết) rồi sinh lại.
-- Các cột dẫn xuất (SucChua, SoLuongHienTai, VI_TRI_DO.TrangThai, TienGui, SoTien, NgayHetHan, MaHD...)
-- được ghi đúng giá trị Excel đã tính, nên không cần UPDATE đồng bộ sau khi nạp.
-- Dòng có mốc tương đối (xe đang đỗ, vé V0007) dùng DATEADD(..., GETDATE()) để luôn đúng tại thời điểm nạp.

-- 1. Bãi Đỗ Xe (5 chi nhánh; SucChua = số ô đỗ, SoLuongHienTai = số xe đang đỗ)
INSERT INTO dbo.BAI_DO_XE (MaBai, TenBai, DiaChi, SucChua, SoLuongHienTai) VALUES
('BAI_Q1', N'Bãi xe Lê Lai - Bến Thành', N'Số 26 Lê Lai, Phường Bến Thành, Quận 1, TP.HCM', 12, 2),
('BAI_Q3', N'Bãi xe Hai Bà Trưng', N'Số 180 Hai Bà Trưng, Phường Đa Kao, Quận 3, TP.HCM', 10, 1),
('BAI_BT', N'Bãi xe Landmark 81', N'Số 208 Nguyễn Hữu Cảnh, Phường 22, Bình Thạnh, TP.HCM', 12, 1),
('BAI_TB', N'Bãi xe TCP Park - Sân bay Tân Sơn Nhất', N'Cạnh nhà ga quốc nội, Cảng HKQT Tân Sơn Nhất, Phường 2, Quận Tân Bình, TP.HCM', 14, 3),
('BAI_Q7', N'Bãi xe SC VivoCity', N'Số 1058 Nguyễn Văn Linh, Phường Tân Phong, Quận 7, TP.HCM', 12, 2);
GO

-- 2. Hồ sơ Nhân Viên (Ban giám đốc, Quản lý bãi, Bảo vệ ca trực)
INSERT INTO dbo.NHAN_VIEN (MaNV, HoTen, ChucVu, SDT, Email, MaBai) VALUES
('NV001', N'Nguyễn Hữu Trí', N'Giám đốc điều hành', '0901000001', 'tri.nguyen@smartparking.vn', NULL),
('NV002', N'Trần Văn Hùng', N'Quản lý bãi', '0901000002', 'hung.tran@smartparking.vn', 'BAI_Q1'),
('NV003', N'Lê Thị Bích Ngọc', N'Quản lý bãi', '0901000003', 'ngoc.le@smartparking.vn', 'BAI_Q3'),
('NV004', N'Hoàng Đình Nam', N'Quản lý bãi', '0901000004', 'nam.hoang@smartparking.vn', 'BAI_BT'),
('NV005', N'Phạm Văn Cường', N'Bảo vệ', '0901000005', 'cuong.pham@smartparking.vn', 'BAI_Q1'),
('NV006', N'Đặng Minh Tuấn', N'Bảo vệ', '0901000006', 'tuan.dang@smartparking.vn', 'BAI_Q3'),
('NV007', N'Vũ Đức Thắng', N'Bảo vệ', '0901000007', 'thang.vu@smartparking.vn', 'BAI_BT'),
('NV008', N'Huỳnh Quốc Bảo', N'Quản lý bãi', '0901000008', 'bao.huynh@smartparking.vn', 'BAI_TB'),
('NV009', N'Ngô Thị Thanh Hà', N'Quản lý bãi', '0901000009', 'ha.ngo@smartparking.vn', 'BAI_Q7'),
('NV010', N'Trương Văn Lộc', N'Bảo vệ', '0901000010', 'loc.truong@smartparking.vn', 'BAI_TB'),
('NV011', N'Bùi Thành Đạt', N'Bảo vệ', '0901000011', 'dat.bui@smartparking.vn', 'BAI_Q7');
GO

-- 3. Tài Khoản Truy Cập (mật khẩu mẫu từ cột MatKhauMau của Excel)
--    Băm SHA2_512(salt + mật khẩu) giống dbo.f_BamMatKhau (N5). Salt cố định = 16 byte đầu SHA-256(TenDangNhap)
--    để seed tái lập được; tài khoản tạo mới sau này dùng salt ngẫu nhiên CRYPT_GEN_RANDOM(16).
INSERT INTO dbo.TAI_KHOAN (TenDangNhap, MatKhauHash, MatKhauSalt, MaNV, TrangThai) VALUES
('admin', HASHBYTES('SHA2_512', 0x8C6976E5B5410415BDE908BD4DEE15DF + CAST('Admin@2026' AS VARBINARY(100))), 0x8C6976E5B5410415BDE908BD4DEE15DF, 'NV001', N'Hoạt động'),
('quanly_q1', HASHBYTES('SHA2_512', 0xA96A1945520B26CBAAE8A493E34ACFB9 + CAST('123456' AS VARBINARY(100))), 0xA96A1945520B26CBAAE8A493E34ACFB9, 'NV002', N'Hoạt động'),
('quanly_q3', HASHBYTES('SHA2_512', 0xF653957CF726492E0F2E5258DB1CC602 + CAST('123456' AS VARBINARY(100))), 0xF653957CF726492E0F2E5258DB1CC602, 'NV003', N'Hoạt động'),
('quanly_bt', HASHBYTES('SHA2_512', 0x8105CD0384432837517622656FE8AE3A + CAST('123456' AS VARBINARY(100))), 0x8105CD0384432837517622656FE8AE3A, 'NV004', N'Hoạt động'),
('baove_khoa', HASHBYTES('SHA2_512', 0xC9DA96BE9B174D7E3ADB8BC19C056135 + CAST('123456' AS VARBINARY(100))), 0xC9DA96BE9B174D7E3ADB8BC19C056135, 'NV005', N'Bị khóa'),
('baove_q1', HASHBYTES('SHA2_512', 0xF2681DF9DA242214531CB15BCB0D0EB8 + CAST('123456' AS VARBINARY(100))), 0xF2681DF9DA242214531CB15BCB0D0EB8, 'NV005', N'Hoạt động'),
('baove_q3', HASHBYTES('SHA2_512', 0x4E141F23D8E2E4B9F45924CE23AB94E2 + CAST('123456' AS VARBINARY(100))), 0x4E141F23D8E2E4B9F45924CE23AB94E2, 'NV006', N'Hoạt động'),
('baove_bt', HASHBYTES('SHA2_512', 0xB41CF81A62EBB47CA02AB86856BFC382 + CAST('123456' AS VARBINARY(100))), 0xB41CF81A62EBB47CA02AB86856BFC382, 'NV007', N'Hoạt động'),
('quanly_tb', HASHBYTES('SHA2_512', 0xAE05E863F787058E47BAC04DDD713846 + CAST('123456' AS VARBINARY(100))), 0xAE05E863F787058E47BAC04DDD713846, 'NV008', N'Hoạt động'),
('quanly_q7', HASHBYTES('SHA2_512', 0x2C5A92CBA8CC97544F324DB0B6AF48FF + CAST('123456' AS VARBINARY(100))), 0x2C5A92CBA8CC97544F324DB0B6AF48FF, 'NV009', N'Hoạt động'),
('baove_tb', HASHBYTES('SHA2_512', 0xE3E16ADEA5EE497E9A25D94990CC8B7C + CAST('123456' AS VARBINARY(100))), 0xE3E16ADEA5EE497E9A25D94990CC8B7C, 'NV010', N'Hoạt động'),
('baove_q7', HASHBYTES('SHA2_512', 0x3CBFAFBA0CF795F7640B45765C5639D9 + CAST('123456' AS VARBINARY(100))), 0x3CBFAFBA0CF795F7640B45765C5639D9, 'NV011', N'Hoạt động');
GO

-- 4. Phân Loại Phương Tiện & Biểu Phí theo từng Bãi Đỗ
INSERT INTO dbo.LOAI_XE (MaLoaiXe, MaBai, TenLoai, DonGiaGio, GiaVeThang) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 3 loại xe
('OT', 'BAI_Q1', N'Ô tô 4-7 chỗ', 25000, 1800000),
('XD', 'BAI_Q1', N'Xe đạp / Xe điện', 3000, 80000),
('XM', 'BAI_Q1', N'Xe máy', 6000, 180000),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 3 loại xe
('OT', 'BAI_Q3', N'Ô tô 4-7 chỗ', 20000, 1500000),
('XD', 'BAI_Q3', N'Xe đạp / Xe điện', 2000, 60000),
('XM', 'BAI_Q3', N'Xe máy', 5000, 150000),

-- Bãi xe Landmark 81 (BAI_BT) - 3 loại xe
('OT', 'BAI_BT', N'Ô tô 4-7 chỗ', 30000, 2200000),
('XD', 'BAI_BT', N'Xe đạp / Xe điện', 4000, 90000),
('XM', 'BAI_BT', N'Xe máy', 7000, 200000),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 3 loại xe
('OT', 'BAI_TB', N'Ô tô 4-7 chỗ', 25000, 1600000),
('XD', 'BAI_TB', N'Xe đạp / Xe điện', 3000, 80000),
('XM', 'BAI_TB', N'Xe máy', 5000, 200000),

-- Bãi xe SC VivoCity (BAI_Q7) - 3 loại xe
('OT', 'BAI_Q7', N'Ô tô 4-7 chỗ', 20000, 1700000),
('XD', 'BAI_Q7', N'Xe đạp / Xe điện', 2000, 70000),
('XM', 'BAI_Q7', N'Xe máy', 5000, 170000);
GO

-- 5. Vị Trí Ô Đỗ Xe (60 vị trí; TrangThai = 'Đã đỗ' khi có lượt đang mở)
INSERT INTO dbo.VI_TRI_DO (MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 12 vị trí
('Q1_OT_01', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_02', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_03', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_04', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_XD_01', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XD_02', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XM_01', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_02', N'Khu A - Tầng 1', N'Đã đỗ', 'XM', 'BAI_Q1'),
('Q1_XM_03', N'Khu A - Tầng 1', N'Đã đỗ', 'XM', 'BAI_Q1'),
('Q1_XM_04', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_05', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_06', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 10 vị trí
('Q3_OT_01', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_02', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_03', N'Khu Ô tô Sân 2', N'Trống', 'OT', 'BAI_Q3'),
('Q3_XD_01', N'Khu Xe đạp 1', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XD_02', N'Khu Xe đạp 2', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XM_01', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_02', N'Khu Máy A', N'Đã đỗ', 'XM', 'BAI_Q3'),
('Q3_XM_03', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_04', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_05', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),

-- Bãi xe Landmark 81 (BAI_BT) - 12 vị trí
('BT_OT_01', N'Hầm B2 - Zone A', N'Đã đỗ', 'OT', 'BAI_BT'),
('BT_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_03', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_XD_01', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XD_02', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XM_01', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_02', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_03', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_04', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_05', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_06', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 14 vị trí
('TB_OT_01', N'Tầng 2 - Khu ô tô', N'Đã đỗ', 'OT', 'BAI_TB'),
('TB_OT_02', N'Tầng 2 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_03', N'Tầng 2 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_04', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_05', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_06', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_XD_01', N'Tầng 1 - Cổng vào', N'Trống', 'XD', 'BAI_TB'),
('TB_XD_02', N'Tầng 1 - Cổng vào', N'Trống', 'XD', 'BAI_TB'),
('TB_XM_01', N'Tầng 1 - Khu xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_02', N'Tầng 1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_TB'),
('TB_XM_03', N'Tầng 1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_TB'),
('TB_XM_04', N'Tầng 1 - Khu xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_05', N'Tầng lửng - Xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_06', N'Tầng lửng - Xe máy', N'Trống', 'XM', 'BAI_TB'),

-- Bãi xe SC VivoCity (BAI_Q7) - 12 vị trí
('Q7_OT_01', N'Hầm B2 - Zone A', N'Đã đỗ', 'OT', 'BAI_Q7'),
('Q7_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_03', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_05', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_Q7'),
('Q7_XD_01', N'Hầm B1 - Khu xe đạp', N'Trống', 'XD', 'BAI_Q7'),
('Q7_XD_02', N'Hầm B1 - Khu xe đạp', N'Trống', 'XD', 'BAI_Q7'),
('Q7_XM_01', N'Hầm B1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_Q7'),
('Q7_XM_02', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_03', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_04', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_05', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7');
GO

-- 6. Kho Thẻ Xe theo bãi phát hành
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 6 thẻ
('THE0001', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0002', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-01'),
('THE0003', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0004', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-10'),
('THE0005', 'BAI_Q1', N'Lượt', N'Bị khóa', '2026-01-12'),
('THE0006', 'BAI_Q1', N'Lượt', N'Mất', '2026-01-15'),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 4 thẻ
('THE0007', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0008', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-03'),
('THE0009', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0010', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-08'),

-- Bãi xe Landmark 81 (BAI_BT) - 5 thẻ
('THE0011', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0012', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-02'),
('THE0013', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0014', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-06'),
('THE0015', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-10'),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 5 thẻ
('THE0016', 'BAI_TB', N'Lượt', N'Hoạt động', '2026-02-01'),
('THE0017', 'BAI_TB', N'Tháng', N'Hoạt động', '2026-03-01'),
('THE0018', 'BAI_TB', N'Lượt', N'Hoạt động', '2026-02-01'),
('THE0019', 'BAI_TB', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE)),
('THE0020', 'BAI_TB', N'Lượt', N'Bị khóa', '2026-02-10'),

-- Bãi xe SC VivoCity (BAI_Q7) - 5 thẻ
('THE0021', 'BAI_Q7', N'Lượt', N'Hoạt động', '2026-01-15'),
('THE0022', 'BAI_Q7', N'Tháng', N'Hoạt động', '2026-01-15'),
('THE0023', 'BAI_Q7', N'Lượt', N'Hoạt động', '2026-01-15'),
('THE0024', 'BAI_Q7', N'Tháng', N'Hoạt động', '2026-06-01'),
('THE0025', 'BAI_Q7', N'Lượt', N'Mất', '2026-01-20');
GO

-- 7. Hồ sơ Khách Hàng
INSERT INTO dbo.KHACH_HANG (MaKH, HoTen, SDT, Email, CMND_CCCD) VALUES
('KH0001', N'Nguyễn Văn An', '0903112233', 'nguyenvanan@gmail.com', '079090001111'),
('KH0002', N'Trần Thị Mai', '0912445566', 'tranmai.hcm@gmail.com', '079090002222'),
('KH0003', N'Lê Hoàng Long', '0988776655', 'long.lehoang@yahoo.com', '079090003333'),
('KH0004', N'Phạm Thu Trang', '0934556677', 'trangpham@outlook.com', '079090004444'),
('KH0005', N'Võ Minh Quân', '0977112244', 'quan.vominh@gmail.com', '079090005555'),
('KH0006', N'Đỗ Thanh Phong', '0908246810', 'phong.dothanh@gmail.com', '079090006666'),
('KH0007', N'Lý Ngọc Hân', '0938135790', 'han.lyngoc@gmail.com', '079090007777'),
('KH0008', N'Châu Minh Khang', '0917258036', 'khang.chau@outlook.com', '079090018888'),
('KH0009', N'Tạ Thị Kim Oanh', '0966369147', 'oanh.takim@yahoo.com', '079090009999'),
('KH0010', N'Phan Gia Huy', '0945112233', 'huy.phangia@gmail.com', '079090010101');
GO

-- 8. Vé Tháng (NgayHetHan = NgayDangKy + tổng số tháng trên hóa đơn)
INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung) VALUES
('V0001', 'THE0002', 'KH0001', '59A-123.45', 'XM', '2026-01-01', '2027-01-01', N'Hoạt động', 'BAI_Q1'),
('V0002', 'THE0004', 'KH0002', '51G-888.99', 'OT', '2026-01-10', '2026-10-10', N'Hoạt động', 'BAI_Q1'),
('V0003', 'THE0008', 'KH0003', '59B-456.78', 'XM', '2026-01-03', '2026-02-03', N'Hết hạn', 'BAI_Q3'),
('V0004', 'THE0010', 'KH0004', '51H-999.11', 'OT', '2026-01-08', '2026-11-08', N'Hoạt động', 'ALL'),
('V0005', 'THE0012', 'KH0005', '59C-678.90', 'XM', '2026-01-02', '2027-01-02', N'Hoạt động', 'BAI_BT'),
('V0006', 'THE0017', 'KH0006', '51K-246.80', 'OT', '2026-03-01', '2027-03-01', N'Hoạt động', 'BAI_TB'),
('V0007', 'THE0019', 'KH0007', '59P-357.91', 'XM', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -28, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_TB'),
('V0008', 'THE0022', 'KH0008', '59N-147.25', 'XM', '2026-01-15', '2026-07-15', N'Hết hạn', 'BAI_Q7'),
('V0009', 'THE0024', 'KH0009', '51L-802.46', 'OT', '2026-06-01', '2026-12-01', N'Hoạt động', 'BAI_Q7'),
('V0010', 'THE0014', 'KH0010', '51M-135.24', 'OT', '2026-01-06', '2027-01-06', N'Hoạt động', 'BAI_BT');
GO

-- 9. Hóa Đơn Vé Tháng (SoTien = số tháng x giá vé tháng tại bãi tính giá)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai) VALUES
('HD20260101001', 'V0001', '2026-01-01 00:00:00', 12, 2160000, 'BAI_Q1'),
('HD20260110002', 'V0002', '2026-01-10 00:00:00', 9, 16200000, 'BAI_Q1'),
('HD20260103003', 'V0003', '2026-01-03 00:00:00', 1, 150000, 'BAI_Q3'),
('HD20260108004', 'V0004', '2026-01-08 00:00:00', 10, 15000000, 'BAI_Q3'),
('HD20260102005', 'V0005', '2026-01-02 00:00:00', 12, 2400000, 'BAI_BT'),
('HD20260301006', 'V0006', '2026-03-01 00:00:00', 12, 19200000, 'BAI_TB'),
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), 'yyyyMMdd'), '007'), 'V0007', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), 1, 200000, 'BAI_TB'),
('HD20260115008', 'V0008', '2026-01-15 00:00:00', 6, 1020000, 'BAI_Q7'),
('HD20260601009', 'V0009', '2026-06-01 00:00:00', 6, 10200000, 'BAI_Q7'),
('HD20260106010', 'V0010', '2026-01-06 00:00:00', 12, 26400000, 'BAI_BT');
GO

-- 10. Nhật Ký Lượt Gửi Xe (MaLuot IDENTITY theo thứ tự dòng; TienGui theo f_TinhTienGuiXe, thẻ tháng = 0)
-- Lượt đã check-out
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59A-111.22', '2026-09-07 07:15:00', '2026-09-07 11:15:00', 'Q1_XM_01', 24000, 'BAI_Q1'),
('THE0003', '51G-222.33', '2026-09-07 08:00:00', '2026-09-07 14:00:00', 'Q1_OT_01', 150000, 'BAI_Q1'),
('THE0007', '59B-333.44', '2026-09-07 09:30:00', '2026-09-07 12:30:00', 'Q3_XM_01', 15000, 'BAI_Q3'),
('THE0011', '59C-444.55', '2026-09-07 06:45:00', '2026-09-07 17:45:00', 'BT_XM_01', 77000, 'BAI_BT'),
('THE0016', '59D-234.56', '2026-09-07 05:30:00', '2026-09-07 08:10:00', 'TB_XM_01', 15000, 'BAI_TB'),
('THE0018', '51F-135.79', '2026-09-07 10:00:00', '2026-09-07 15:20:00', 'TB_OT_04', 150000, 'BAI_TB'),
('THE0017', '51K-246.80', '2026-09-08 06:00:00', '2026-09-08 18:00:00', 'TB_OT_02', 0, 'BAI_TB'),
('THE0021', '59T-111.22', '2026-09-07 18:00:00', '2026-09-07 21:45:00', 'Q7_XM_02', 20000, 'BAI_Q7'),
('THE0023', '51H-246.13', '2026-09-07 11:00:00', '2026-09-07 11:10:00', 'Q7_OT_03', 0, 'BAI_Q7');

-- Lượt hiện đang đỗ (ThoiGianRa IS NULL)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59K-987.65', DATEADD(MINUTE, -120, GETDATE()), NULL, 'Q1_XM_02', 0, 'BAI_Q1'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -240, GETDATE()), NULL, 'Q1_XM_03', 0, 'BAI_Q1'),
('THE0007', '59E-555.66', DATEADD(MINUTE, -60, GETDATE()), NULL, 'Q3_XM_02', 0, 'BAI_Q3'),
('THE0013', '51A-777.88', DATEADD(MINUTE, -180, GETDATE()), NULL, 'BT_OT_01', 0, 'BAI_BT'),
('THE0016', '59D-678.12', DATEADD(MINUTE, -90, GETDATE()), NULL, 'TB_XM_02', 0, 'BAI_TB'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -300, GETDATE()), NULL, 'TB_XM_03', 0, 'BAI_TB'),
('THE0018', '51G-468.02', DATEADD(MINUTE, -120, GETDATE()), NULL, 'TB_OT_01', 0, 'BAI_TB'),
('THE0024', '51L-802.46', DATEADD(MINUTE, -360, GETDATE()), NULL, 'Q7_OT_01', 0, 'BAI_Q7'),
('THE0021', '59T-579.13', DATEADD(MINUTE, -60, GETDATE()), NULL, 'Q7_XM_01', 0, 'BAI_Q7');
GO

-- 11. Nhật Ký Sự Cố (sự cố mất thẻ áp phí phạt PhatMatThe)
INSERT INTO dbo.LICHSU_SU_CO (MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai) VALUES
('THE0006', '59X-999.01', '2026-01-15 11:00:00', N'Khách hàng làm rơi thẻ xe tại quầy nước, lập biên bản báo mất thẻ chip', 50000, N'Đã giải quyết', 'BAI_Q1'),
(NULL, '51B-123.45', '2026-02-10 18:30:00', N'Va quẹt nhẹ gương chiếu hậu khi lùi xe vào ô đỗ Q3_OT_01', 200000, N'Đã giải quyết', 'BAI_Q3'),
(NULL, '51F-135.79', '2026-09-07 10:05:00', N'Ô tô cọ quẹt trụ bê tông tại dốc lên Tầng 3, trầy sơn hông xe, đang chờ đối chiếu camera', 300000, N'Đang giải quyết', 'BAI_TB'),
('THE0025', NULL, '2026-08-20 20:15:00', N'Khách hàng báo mất thẻ chip THE0025 (Loại: Lượt). Hệ thống tự động khóa thẻ và áp phí phạt đền bù thẻ vật lý.', 50000, N'Đã giải quyết', 'BAI_Q7');
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- DỮ LIỆU MẪU CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 11)
--
-- TẠM THỜI VIẾT TAY: script sinh seed từ docs/QuanLyBaiDoXe_DuLieuMau.xlsx chưa có trong repo (N8).
-- Khi có script, chuyển dữ liệu dưới đây vào các sheet tương ứng của Excel master (D11) và sinh lại file này.
--
-- Quy ước giống 02_sample_data.sql:
-- - Chạy một lần trên CSDL vừa nạp 01 -> 10 (không idempotent, giống 02).
-- - Cột dẫn xuất ghi giá trị đã tính sẵn: VI_DIEN_TU.SoDu, GIAO_DICH.SoDuTruoc / SoDuSau (file này chạy TRƯỚC
--   khi trigger sổ cái ở bước 14 được tạo, nên không dựa vào trigger để tính số dư).
-- - Mốc thời gian tương đối dùng DATEADD(..., GETDATE()) để luôn đúng khi nạp lại.
-- - Mật khẩu mẫu của mọi tài khoản khách: 'Khach@2026', salt cố định (giá trị tổng hợp cho demo) để seed tái lập được.
--   Biểu thức hash trùng với dbo.f_BamMatKhau: HASHBYTES('SHA2_512', salt + CAST(<mật khẩu VARCHAR> AS VARBINARY(100))).
-- - Các lượt gửi lịch sử chèn ở đây đi qua trigger V6 của LUOT_GUI nên chỉ dùng vé còn hạn, đúng bãi, thẻ hoạt động.
-- ====================================================================================

-- 1. Tài khoản cổng khách hàng (8 tài khoản; KH0005 và KH0008 chưa có tài khoản - dùng cho demo đăng ký)
-- TK0005 (KH0006) đang tạm khóa để màn hình nhân viên có dữ liệu "Mở khóa".
INSERT INTO dbo.TAI_KHOAN_KH (MaTK, MaKH, TenDangNhap, MatKhauHash, MatKhauSalt, TrangThai, SoLanSaiLienTiep, KhoaDen, NgayTao, LanDangNhapCuoi) VALUES
('TK0001', 'KH0001', '0903112233', HASHBYTES('SHA2_512', 0x1F8A3C5E7B9D2F4061A3C5E7092B4D6F + CAST('Khach@2026' AS VARBINARY(100))), 0x1F8A3C5E7B9D2F4061A3C5E7092B4D6F, N'Hoạt động', 0, NULL, DATEADD(DAY, -60, GETDATE()), DATEADD(HOUR, -20, GETDATE())),
('TK0002', 'KH0002', '0912445566', HASHBYTES('SHA2_512', 0x2E9B4D6F8CAE3051728495A6B7C8D9E0 + CAST('Khach@2026' AS VARBINARY(100))), 0x2E9B4D6F8CAE3051728495A6B7C8D9E0, N'Hoạt động', 0, NULL, DATEADD(DAY, -45, GETDATE()), DATEADD(HOUR, -5, GETDATE())),
('TK0003', 'KH0003', '0988776655', HASHBYTES('SHA2_512', 0x3DAC5E7091BF416283A5C7E90B2D4F61 + CAST('Khach@2026' AS VARBINARY(100))), 0x3DAC5E7091BF416283A5C7E90B2D4F61, N'Hoạt động', 0, NULL, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -12, GETDATE())),
('TK0004', 'KH0004', '0934556677', HASHBYTES('SHA2_512', 0x4CBD6F81A2C05273940B6D8FA1C3E507 + CAST('Khach@2026' AS VARBINARY(100))), 0x4CBD6F81A2C05273940B6D8FA1C3E507, N'Hoạt động', 0, NULL, DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -2, GETDATE())),
('TK0005', 'KH0006', '0908246810', HASHBYTES('SHA2_512', 0x5BCE7092B3D16384A51C7E90B2D4F618 + CAST('Khach@2026' AS VARBINARY(100))), 0x5BCE7092B3D16384A51C7E90B2D4F618, N'Tạm khóa', 5, DATEADD(MINUTE, 10, GETDATE()), DATEADD(DAY, -62, GETDATE()), DATEADD(DAY, -3, GETDATE())),
('TK0006', 'KH0007', '0938135790', HASHBYTES('SHA2_512', 0x6ADF81A3C4E27495B62D8FA1C3E50729 + CAST('Khach@2026' AS VARBINARY(100))), 0x6ADF81A3C4E27495B62D8FA1C3E50729, N'Hoạt động', 0, NULL, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -1, GETDATE())),
('TK0007', 'KH0009', '0966369147', HASHBYTES('SHA2_512', 0x79E092B4D5F385A6C73E90B2D4F6183A + CAST('Khach@2026' AS VARBINARY(100))), 0x79E092B4D5F385A6C73E90B2D4F6183A, N'Hoạt động', 0, NULL, DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -4, GETDATE())),
('TK0008', 'KH0010', '0945112233', HASHBYTES('SHA2_512', 0x88F1A3C5E60496B7D84FA1C3E507294B + CAST('Khach@2026' AS VARBINARY(100))), 0x88F1A3C5E60496B7D84FA1C3E507294B, N'Hoạt động', 0, NULL, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -5, GETDATE()));
GO

-- 2. Nhật ký đăng nhập (TK0005 sai 5 lần trong 15 phút gần nhất -> đang tạm khóa)
INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP, ThietBi) VALUES
('TK0001', '0903112233', DATEADD(HOUR, -20, GETDATE()), N'Thành công', '113.161.45.10', N'Chrome / Windows'),
('TK0002', '0912445566', DATEADD(HOUR, -5, GETDATE()), N'Thành công', '14.169.22.81', N'Safari / iOS'),
('TK0004', '0934556677', DATEADD(DAY, -2, GETDATE()), N'Thành công', '27.72.98.140', N'Chrome / Android'),
('TK0006', '0938135790', DATEADD(DAY, -1, GETDATE()), N'Thành công', '171.244.10.55', N'Chrome / macOS'),
(NULL, '0900000000', DATEADD(HOUR, -3, GETDATE()), N'Không tồn tại', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -9, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -8, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -7, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -6, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -5, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4');
GO

-- 3. Ví điện tử (SoDu = tổng sổ cái các giao dịch 'Thành công' / 'Đã hoàn' ở mục 4)
INSERT INTO dbo.VI_DIEN_TU (MaVi, MaKH, SoDu, NgayTao) VALUES
('VI0001', 'KH0001', 300000, DATEADD(DAY, -60, GETDATE())),
('VI0002', 'KH0002', 3000000, DATEADD(DAY, -45, GETDATE())),
('VI0003', 'KH0003', 0, DATEADD(DAY, -40, GETDATE())),
('VI0004', 'KH0004', 50000, DATEADD(DAY, -42, GETDATE())),
('VI0005', 'KH0006', 2600000, DATEADD(DAY, -62, GETDATE())),
('VI0006', 'KH0007', 300000, DATEADD(DAY, -27, GETDATE())),
('VI0007', 'KH0009', 5000000, DATEADD(DAY, -21, GETDATE())),
('VI0008', 'KH0010', 100000, DATEADD(DAY, -6, GETDATE()));
GO

-- 4. Sổ cái giao dịch (theo thứ tự thời gian trong từng ví; SoDuTruoc / SoDuSau liên tục)
-- VI0001: 0 -> +480.000 (MoMo) -> -180.000 (gia hạn V0001 online) = 300.000; 1 lệnh VNPay thất bại
-- VI0002: 0 -> +3.000.000 (tiền mặt tại quầy) = 3.000.000; 1 lệnh chuyển khoản treo 2 giờ (cursor đối soát sẽ chuyển Thất bại)
-- VI0004: 0 -> +1.550.000 (thẻ) -> -1.500.000 (gia hạn V0004 online, giá bãi phát hành thẻ BAI_Q3) = 50.000
-- VI0005: 0 -> +2.600.000 -> -1.600.000 (gia hạn V0006) -> +1.600.000 -> -1.600.000 (trừ trùng, đã hoàn) -> +1.600.000 (hoàn) = 2.600.000
-- VI0006: +300.000 (ZaloPay, trước khi cổng tạm ngưng) | VI0007: +5.000.000 | VI0008: +100.000
INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, PhiGiaoDich, SoDuTruoc, SoDuSau, MaPTTT, MaThamChieu, TrangThai, MaVe, MaGDGoc, NguoiThucHien, MaNV, ThoiGianTao, ThoiGianHoanTat, GhiChu) VALUES
('GD260900000001', 'VI0001', N'Nạp tiền', 1, 480000, 7200, 0, 480000, 'MOMO', 'MOMO-SEED-0001', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000002', 'VI0001', N'Thanh toán vé tháng', -1, 180000, 0, 480000, 300000, 'SO_DU_VI', NULL, N'Thành công', 'V0001', NULL, N'Khách hàng', NULL, DATEADD(DAY, -24, GETDATE()), DATEADD(DAY, -24, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000003', 'VI0001', N'Nạp tiền', 1, 200000, 2200, NULL, NULL, 'VNPAY', 'VNPAY-SEED-0003', N'Thất bại', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -10, GETDATE()), N'Cổng thanh toán báo thất bại'),
('GD260900000004', 'VI0002', N'Nạp tiền', 1, 3000000, 0, 0, 3000000, 'TIEN_MAT', NULL, N'Thành công', NULL, NULL, N'Nhân viên', 'NV002', DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -30, GETDATE()), N'Nạp tiền mặt tại quầy'),
('GD260900000005', 'VI0002', N'Nạp tiền', 1, 1000000, 0, NULL, NULL, 'CHUYEN_KHOAN', NULL, N'Chờ xử lý', NULL, NULL, N'Khách hàng', NULL, DATEADD(MINUTE, -120, GETDATE()), NULL, N'Chờ kết quả từ cổng thanh toán'),
('GD260900000006', 'VI0004', N'Nạp tiền', 1, 1550000, 31000, 0, 1550000, 'THE_NH', 'THENH-SEED-0006', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -40, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000007', 'VI0004', N'Thanh toán vé tháng', -1, 1500000, 0, 1550000, 50000, 'SO_DU_VI', NULL, N'Thành công', 'V0004', NULL, N'Khách hàng', NULL, DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -39, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000008', 'VI0005', N'Nạp tiền', 1, 2600000, 28600, 0, 2600000, 'VNPAY', 'VNPAY-SEED-0008', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -60, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000009', 'VI0005', N'Thanh toán vé tháng', -1, 1600000, 0, 2600000, 1000000, 'SO_DU_VI', NULL, N'Thành công', 'V0006', NULL, N'Khách hàng', NULL, DATEADD(DAY, -59, GETDATE()), DATEADD(DAY, -59, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000010', 'VI0005', N'Nạp tiền', 1, 1600000, 24000, 1000000, 2600000, 'MOMO', 'MOMO-SEED-0010', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -31, GETDATE()), DATEADD(DAY, -31, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000011', 'VI0005', N'Thanh toán vé tháng', -1, 1600000, 0, 2600000, 1000000, 'SO_DU_VI', NULL, N'Đã hoàn', 'V0006', NULL, N'Khách hàng', NULL, DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -30, GETDATE()), N'Trừ trùng do lỗi kết nối | Đã hoàn tiền bởi GD260900000012'),
('GD260900000012', 'VI0005', N'Hoàn tiền', 1, 1600000, 0, 1000000, 2600000, 'SO_DU_VI', NULL, N'Thành công', 'V0006', 'GD260900000011', N'Nhân viên', 'NV008', DATEADD(DAY, -29, GETDATE()), DATEADD(DAY, -29, GETDATE()), N'Hoàn tiền giao dịch trừ trùng'),
('GD260900000013', 'VI0006', N'Nạp tiền', 1, 300000, 3600, 0, 300000, 'ZALOPAY', 'ZALO-SEED-0013', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -27, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000014', 'VI0007', N'Nạp tiền', 1, 5000000, 0, 0, 5000000, 'CHUYEN_KHOAN', 'BANK-SEED-0014', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -20, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000015', 'VI0008', N'Nạp tiền', 1, 100000, 1500, 0, 100000, 'MOMO', 'MOMO-SEED-0015', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, GETDATE()), N'Cổng thanh toán xác nhận thành công');
GO

-- Mã giao dịch sinh mới bắt đầu sau dải mã seed
ALTER SEQUENCE dbo.seq_GiaoDich RESTART WITH 1000;
GO

-- 5. Hai vé tháng mới có mốc tương đối (giống V0007): đăng ký 1 tháng cách thời điểm nạp 29 ngày,
--    nên luôn còn <= 3 ngày khi demo cursor tự động gia hạn.
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
('THE0026', 'BAI_Q7', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)),
('THE0027', 'BAI_BT', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE));
GO

INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung, TuDongGiaHan, SoThangTuDongGiaHan) VALUES
('V0011', 'THE0026', 'KH0009', '51L-913.57', 'OT', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_Q7', 1, 1),
('V0012', 'THE0027', 'KH0010', '51M-468.20', 'OT', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_BT', 1, 1);
GO

-- Bật tự động gia hạn cho V0007 (mốc tương đối sẵn có trong seed V6)
UPDATE dbo.VE_THANG SET TuDongGiaHan = 1, SoThangTuDongGiaHan = 1 WHERE MaVe = 'V0007';
GO

-- 6. Hóa đơn: 2 hóa đơn tại quầy của V0011 / V0012 và 3 hóa đơn online gắn giao dịch ví
-- (10 hóa đơn V6 tự nhận MaPTTT = 'TIEN_MAT', KenhThanhToan = 'Tại quầy' từ DEFAULT ở bước 10)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai, MaPTTT, KenhThanhToan, MaGD, MaNVThu) VALUES
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 'yyyyMMdd'), '011'), 'V0011', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 1, 1700000, 'BAI_Q7', 'TIEN_MAT', N'Tại quầy', NULL, 'NV009'),
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 'yyyyMMdd'), '012'), 'V0012', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 1, 2200000, 'BAI_BT', 'TIEN_MAT', N'Tại quầy', NULL, 'NV004'),
(CONCAT('HD', FORMAT(DATEADD(DAY, -24, GETDATE()), 'yyyyMMdd'), '013'), 'V0001', DATEADD(DAY, -24, GETDATE()), 1, 180000, 'BAI_Q1', 'SO_DU_VI', N'Online', 'GD260900000002', NULL),
(CONCAT('HD', FORMAT(DATEADD(DAY, -39, GETDATE()), 'yyyyMMdd'), '014'), 'V0004', DATEADD(DAY, -39, GETDATE()), 1, 1500000, 'BAI_Q3', 'SO_DU_VI', N'Online', 'GD260900000007', NULL),
(CONCAT('HD', FORMAT(DATEADD(DAY, -59, GETDATE()), 'yyyyMMdd'), '015'), 'V0006', DATEADD(DAY, -59, GETDATE()), 1, 1600000, 'BAI_TB', 'SO_DU_VI', N'Online', 'GD260900000009', NULL);
GO

-- Hạn dùng của 3 vé được gia hạn online tăng thêm 1 tháng (chuỗi hạn dùng nối theo hóa đơn, giống Excel master)
UPDATE dbo.VE_THANG
SET NgayHetHan = DATEADD(MONTH, 1, NgayHetHan)
WHERE MaVe IN ('V0001', 'V0004', 'V0006');
GO

-- 7. Ủy quyền: KH0001 chia sẻ V0001 cho tài khoản KH0002 với vai trò chỉ xem lịch sử
INSERT INTO dbo.UY_QUYEN_VE (MaVe, MaTKDuocUyQuyen, MaVaiTro, NgayBatDau, NgayKetThuc, TrangThai, MaTKCap, NgayTao) VALUES
('V0001', 'TK0002', 'XEM_LICH_SU', CAST(DATEADD(DAY, -10, GETDATE()) AS DATE), NULL, N'Hiệu lực', 'TK0001', DATEADD(DAY, -10, GETDATE()));
GO

-- 8. Thông báo mẫu (mỗi khách có tài khoản có ít nhất 1 thông báo chưa đọc)
INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe, MaGD, DaDoc, ThoiGianTao) VALUES
('KH0001', N'Giao dịch', N'Gia hạn vé tháng online thành công', N'Vé V0001 đã được gia hạn thêm 1 tháng bằng số dư ví (180.000 đồng).', 'V0001', 'GD260900000002', 1, DATEADD(DAY, -24, GETDATE())),
('KH0001', N'Ủy quyền', N'Đã chia sẻ vé tháng', N'Bạn đã chia sẻ vé V0001 cho tài khoản 0912445566 với vai trò Chỉ xem lịch sử.', 'V0001', NULL, 0, DATEADD(DAY, -10, GETDATE())),
('KH0002', N'Giao dịch', N'Nạp tiền tại quầy thành công', N'Ví đã được cộng 3.000.000 đồng tiền mặt tại quầy (giao dịch GD260900000004).', NULL, 'GD260900000004', 1, DATEADD(DAY, -30, GETDATE())),
('KH0002', N'Ủy quyền', N'Bạn được chia sẻ một vé tháng', N'Vé V0001 đã được chia sẻ cho bạn với vai trò Chỉ xem lịch sử (không thời hạn).', 'V0001', NULL, 0, DATEADD(DAY, -10, GETDATE())),
('KH0003', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Bạn có thể nạp tiền vào ví, tự gia hạn vé tháng và xem lịch sử đỗ xe.', NULL, NULL, 0, DATEADD(DAY, -40, GETDATE())),
('KH0004', N'Giao dịch', N'Gia hạn vé tháng online thành công', N'Vé V0004 đã được gia hạn thêm 1 tháng bằng số dư ví (1.500.000 đồng).', 'V0004', 'GD260900000007', 0, DATEADD(DAY, -39, GETDATE())),
('KH0006', N'Giao dịch', N'Hoàn tiền vào ví', N'Ví được hoàn 1.600.000 đồng cho giao dịch GD260900000011. Lý do: Hoàn tiền giao dịch trừ trùng.', 'V0006', 'GD260900000012', 1, DATEADD(DAY, -29, GETDATE())),
('KH0006', N'Bảo mật', N'Tài khoản tạm khóa do đăng nhập sai nhiều lần', N'Phát hiện 5 lần nhập sai mật khẩu trong 15 phút. Tài khoản đang tạm khóa.', NULL, NULL, 0, DATEADD(MINUTE, -5, GETDATE())),
('KH0007', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Hãy bật tự động gia hạn để không bị gián đoạn khi gửi xe.', NULL, NULL, 0, DATEADD(DAY, -27, GETDATE())),
('KH0009', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Ví đã sẵn sàng để gia hạn vé tháng online.', NULL, NULL, 0, DATEADD(DAY, -21, GETDATE())),
('KH0010', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Ví đã sẵn sàng để gia hạn vé tháng online.', NULL, NULL, 0, DATEADD(DAY, -6, GETDATE()));
GO

-- 9. Lượt gửi lịch sử của xe vé tháng trong 30 ngày gần nhất (đã ra bãi, xe tháng miễn phí lượt gửi)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai, MaVe) VALUES
('THE0002', '59A-123.45', DATEADD(MINUTE, -(3 * 1440 + 620), GETDATE()), DATEADD(MINUTE, -(3 * 1440 + 80), GETDATE()), 'Q1_XM_01', 0, 'BAI_Q1', 'V0001'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -(6 * 1440 + 610), GETDATE()), DATEADD(MINUTE, -(6 * 1440 + 95), GETDATE()), 'Q1_XM_04', 0, 'BAI_Q1', 'V0001'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -(9 * 1440 + 600), GETDATE()), DATEADD(MINUTE, -(9 * 1440 + 70), GETDATE()), 'Q1_XM_05', 0, 'BAI_Q1', 'V0001'),
('THE0012', '59C-678.90', DATEADD(MINUTE, -(2 * 1440 + 540), GETDATE()), DATEADD(MINUTE, -(2 * 1440 + 30), GETDATE()), 'BT_XM_02', 0, 'BAI_BT', 'V0005'),
('THE0012', '59C-678.90', DATEADD(MINUTE, -(7 * 1440 + 560), GETDATE()), DATEADD(MINUTE, -(7 * 1440 + 45), GETDATE()), 'BT_XM_02', 0, 'BAI_BT', 'V0005'),
('THE0017', '51K-246.80', DATEADD(MINUTE, -(4 * 1440 + 480), GETDATE()), DATEADD(MINUTE, -(4 * 1440 + 120), GETDATE()), 'TB_OT_03', 0, 'BAI_TB', 'V0006'),
('THE0017', '51K-246.80', DATEADD(MINUTE, -(12 * 1440 + 500), GETDATE()), DATEADD(MINUTE, -(12 * 1440 + 60), GETDATE()), 'TB_OT_03', 0, 'BAI_TB', 'V0006'),
('THE0014', '51M-135.24', DATEADD(MINUTE, -(1 * 1440 + 600), GETDATE()), DATEADD(MINUTE, -(1 * 1440 + 50), GETDATE()), 'BT_OT_02', 0, 'BAI_BT', 'V0010'),
('THE0014', '51M-135.24', DATEADD(MINUTE, -(5 * 1440 + 620), GETDATE()), DATEADD(MINUTE, -(5 * 1440 + 40), GETDATE()), 'BT_OT_02', 0, 'BAI_BT', 'V0010'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -(3 * 1440 + 400), GETDATE()), DATEADD(MINUTE, -(3 * 1440 + 100), GETDATE()), 'TB_XM_04', 0, 'BAI_TB', 'V0007'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -(10 * 1440 + 420), GETDATE()), DATEADD(MINUTE, -(10 * 1440 + 90), GETDATE()), 'TB_XM_04', 0, 'BAI_TB', 'V0007'),
('THE0010', '51H-999.11', DATEADD(MINUTE, -(2 * 1440 + 500), GETDATE()), DATEADD(MINUTE, -(2 * 1440 + 100), GETDATE()), 'Q1_OT_02', 0, 'BAI_Q1', 'V0004'),
('THE0010', '51H-999.11', DATEADD(MINUTE, -(9 * 1440 + 480), GETDATE()), DATEADD(MINUTE, -(9 * 1440 + 60), GETDATE()), 'Q3_OT_02', 0, 'BAI_Q3', 'V0004'),
('THE0026', '51L-913.57', DATEADD(MINUTE, -(6 * 1440 + 300), GETDATE()), DATEADD(MINUTE, -(6 * 1440 + 60), GETDATE()), 'Q7_OT_02', 0, 'BAI_Q7', 'V0011'),
('THE0027', '51M-468.20', DATEADD(MINUTE, -(8 * 1440 + 360), GETDATE()), DATEADD(MINUTE, -(8 * 1440 + 30), GETDATE()), 'BT_OT_03', 0, 'BAI_BT', 'V0012');
GO


-- ==================== BẮT ĐẦU: 05_functions.sql (FUNCTIONS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 3: DATABASE FUNCTIONS (3 FUNCTIONS)
-- ====================================================================================

-- 1. Function f_TinhTienGuiXe: Tính toán phí gửi xe lượt theo block giờ lũy tiến
CREATE OR ALTER FUNCTION dbo.f_TinhTienGuiXe
(
    @ThoiGianVao DATETIME,
    @ThoiGianRa DATETIME,
    @MaLoaiXe VARCHAR(10),
    @MaBai VARCHAR(10)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    IF @ThoiGianRa IS NULL OR @ThoiGianVao IS NULL OR @ThoiGianRa < @ThoiGianVao
        RETURN 0;

    DECLARE @DonGiaGio DECIMAL(18,2);
    SELECT @DonGiaGio = DonGiaGio
    FROM dbo.LOAI_XE
    WHERE MaLoaiXe = @MaLoaiXe AND MaBai = @MaBai;

    IF @DonGiaGio IS NULL OR @DonGiaGio <= 0
        RETURN 0;

    -- Tính tổng số phút đỗ xe
    DECLARE @TongSoPhut INT = DATEDIFF(MINUTE, @ThoiGianVao, @ThoiGianRa);

    -- Dưới 15 phút miễn phí đỗ xe (khách quay đầu / đón trả nhanh)
    IF @TongSoPhut <= 15
        RETURN 0;

    -- Quy đổi ra số block giờ (làm tròn lên block giờ tiếp theo)
    DECLARE @SoGio INT = CEILING(CAST(@TongSoPhut AS FLOAT) / 60.0);
    IF @SoGio <= 0 SET @SoGio = 1;

    RETURN CAST(@SoGio * @DonGiaGio AS DECIMAL(18,2));
END;
GO

-- 2. Function f_TimSlotTrong: Tự động dò tìm ô đỗ còn trống phù hợp loại xe tại bãi
CREATE OR ALTER FUNCTION dbo.f_TimSlotTrong
(
    @MaBai VARCHAR(10),
    @MaLoaiXe VARCHAR(10)
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @MaViTri VARCHAR(20);

    SELECT TOP 1 @MaViTri = MaViTri
    FROM dbo.VI_TRI_DO
    WHERE MaBai = @MaBai
      AND MaLoaiXe = @MaLoaiXe
      AND TrangThai = N'Trống'
    ORDER BY MaViTri ASC;

    RETURN @MaViTri;
END;
GO

-- 3. Function f_DanhSachXeTrongBai: Trích xuất danh sách phương tiện hiện diện tại bãi
CREATE OR ALTER FUNCTION dbo.f_DanhSachXeTrongBai
(
    @MaBai VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        lg.MaLuot,
        lg.MaThe,
        tx.LoaiThe,
        lg.BienSo,
        lg.ThoiGianVao,
        DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) AS SoPhutDaDo,
        lg.MaViTri,
        vt.KhuVuc,
        lx.TenLoai AS LoaiPhuongTien,
        lg.MaBai,
        bd.TenBai
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.THE_XE tx ON lg.MaThe = tx.MaThe
    INNER JOIN dbo.VI_TRI_DO vt ON lg.MaViTri = vt.MaViTri
    INNER JOIN dbo.LOAI_XE lx ON vt.MaLoaiXe = lx.MaLoaiXe AND vt.MaBai = lx.MaBai
    INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
    WHERE lg.MaBai = @MaBai AND lg.ThoiGianRa IS NULL
);
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- FUNCTIONS CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 6)
-- Chạy trước procedures (13), triggers (14), cursors (15), views (16) và RLS (17).
-- ====================================================================================

-- 1. Function f_BamMatKhau: Băm mật khẩu SHA2_512 có salt (dùng chung cho tài khoản khách hàng và nhân viên - N5).
-- Mật khẩu luôn là VARCHAR: cùng chuỗi nhưng kiểu NVARCHAR sẽ cho ra hash khác (seed và procedure phải khớp).
CREATE OR ALTER FUNCTION dbo.f_BamMatKhau
(
    @MatKhau VARCHAR(100),
    @Salt VARBINARY(16)
)
RETURNS VARBINARY(64)
AS
BEGIN
    RETURN HASHBYTES('SHA2_512', @Salt + CAST(@MatKhau AS VARBINARY(100)));
END;
GO

-- 2. Function f_KH_TinhPhiGiaHan: Phí gia hạn vé tháng theo quy tắc giá của nhóm (D12)
-- Vé gắn bãi: giá tại bãi áp dụng. Vé toàn chuỗi 'ALL': giá tại bãi phát hành thẻ (online không có bãi bán vé).
-- Trả NULL khi thiếu biểu phí hoặc số tháng không hợp lệ để procedure ném lỗi 50017 / 50045.
CREATE OR ALTER FUNCTION dbo.f_KH_TinhPhiGiaHan
(
    @MaVe VARCHAR(10),
    @SoThang INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    IF @SoThang IS NULL OR @SoThang <= 0
        RETURN NULL;

    DECLARE @GiaVeThang DECIMAL(18,2);

    SELECT @GiaVeThang = lx.GiaVeThang
    FROM dbo.VE_THANG vt
    INNER JOIN dbo.THE_XE tx ON vt.MaThe = tx.MaThe
    INNER JOIN dbo.LOAI_XE lx
        ON lx.MaLoaiXe = vt.MaLoaiXe
       AND lx.MaBai = CASE WHEN vt.MaBaiApDung = 'ALL' THEN tx.MaBai ELSE vt.MaBaiApDung END
    WHERE vt.MaVe = @MaVe;

    IF @GiaVeThang IS NULL
        RETURN NULL;

    RETURN CAST(@GiaVeThang * @SoThang AS DECIMAL(18,2));
END;
GO

-- 3. Function f_KH_TongNapTrongNgay: Tổng tiền nạp ví trong ngày (thành công + đang chờ cổng thanh toán)
-- Dùng để kiểm tra hạn mức VI_DIEN_TU.HanMucNapNgay; tính cả giao dịch chờ để không thể mở nhiều lệnh vượt hạn mức.
CREATE OR ALTER FUNCTION dbo.f_KH_TongNapTrongNgay
(
    @MaVi VARCHAR(12)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);

    SELECT @Tong = ISNULL(SUM(SoTien), 0)
    FROM dbo.GIAO_DICH
    WHERE MaVi = @MaVi
      AND LoaiGD = N'Nạp tiền'
      AND TrangThai IN (N'Thành công', N'Chờ xử lý')
      AND ThoiGianTao >= CAST(CAST(GETDATE() AS DATE) AS DATETIME);

    RETURN @Tong;
END;
GO

-- 4. Function f_KH_CoQuyen: Lõi phân quyền nghiệp vụ lớp 3 (UPGRADE_PLAN 4.3)
--    1) Tài khoản phải 'Hoạt động' (hoặc 'Tạm khóa' đã quá thời điểm KhoaDen).
--    2) Quyền ví / giao dịch (VI.*, GIAODICH.*) chỉ áp dụng trên ví của chính tài khoản -> luôn cho phép.
--    3) Vé của chính khách hàng -> vai trò CHU_SO_HUU; ngược lại lấy vai trò từ UY_QUYEN_VE còn hiệu lực.
--    4) Vai trò phải có quyền trong VAI_TRO_QUYEN.
CREATE OR ALTER FUNCTION dbo.f_KH_CoQuyen
(
    @MaTK VARCHAR(12),
    @MaQuyen VARCHAR(30),
    @MaVe VARCHAR(10)
)
RETURNS BIT
AS
BEGIN
    DECLARE @MaKH VARCHAR(10);
    DECLARE @TrangThai NVARCHAR(20);
    DECLARE @KhoaDen DATETIME;
    DECLARE @HomNay DATE = CAST(GETDATE() AS DATE);

    SELECT @MaKH = MaKH, @TrangThai = TrangThai, @KhoaDen = KhoaDen
    FROM dbo.TAI_KHOAN_KH
    WHERE MaTK = @MaTK;

    IF @MaKH IS NULL OR @TrangThai = N'Đã đóng'
        RETURN 0;

    IF @TrangThai = N'Tạm khóa' AND (@KhoaDen IS NULL OR @KhoaDen > GETDATE())
        RETURN 0;

    IF @MaQuyen LIKE 'VI.%' OR @MaQuyen LIKE 'GIAODICH.%'
        RETURN 1;

    IF @MaVe IS NULL
        RETURN 0;

    DECLARE @MaVaiTro VARCHAR(20);

    IF EXISTS (SELECT 1 FROM dbo.VE_THANG WHERE MaVe = @MaVe AND MaKH = @MaKH)
        SET @MaVaiTro = 'CHU_SO_HUU';
    ELSE
        SELECT TOP 1 @MaVaiTro = MaVaiTro
        FROM dbo.UY_QUYEN_VE
        WHERE MaVe = @MaVe
          AND MaTKDuocUyQuyen = @MaTK
          AND TrangThai = N'Hiệu lực'
          AND NgayBatDau <= @HomNay
          AND (NgayKetThuc IS NULL OR NgayKetThuc >= @HomNay);

    IF @MaVaiTro IS NULL
        RETURN 0;

    IF EXISTS (SELECT 1 FROM dbo.VAI_TRO_QUYEN WHERE MaVaiTro = @MaVaiTro AND MaQuyen = @MaQuyen)
        RETURN 1;

    RETURN 0;
END;
GO

-- 5. Function f_KH_LichSuDoXe: Lịch sử đỗ xe của một khách hàng (vé chính chủ + vé được ủy quyền còn hiệu lực)
CREATE OR ALTER FUNCTION dbo.f_KH_LichSuDoXe
(
    @MaKH VARCHAR(10),
    @TuNgay DATE,
    @DenNgay DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        lg.MaLuot,
        lg.MaVe,
        CASE WHEN vt.MaKH = @MaKH THEN 'CHU_SO_HUU' ELSE uq.MaVaiTro END AS MaVaiTro,
        vt.BienSo AS BienSoDangKy,
        lg.BienSo,
        lg.MaBai,
        bd.TenBai,
        lg.MaViTri,
        v.KhuVuc,
        lg.ThoiGianVao,
        lg.ThoiGianRa,
        DATEDIFF(MINUTE, lg.ThoiGianVao, ISNULL(lg.ThoiGianRa, GETDATE())) AS SoPhutGui,
        CASE WHEN lg.ThoiGianRa IS NULL THEN N'Đang đỗ' ELSE N'Đã ra' END AS TrangThai,
        lg.TienGui
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.VE_THANG vt ON lg.MaVe = vt.MaVe
    INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
    INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
    LEFT JOIN dbo.TAI_KHOAN_KH tk ON tk.MaKH = @MaKH
    LEFT JOIN dbo.UY_QUYEN_VE uq
        ON uq.MaVe = vt.MaVe
       AND uq.MaTKDuocUyQuyen = tk.MaTK
       AND uq.TrangThai = N'Hiệu lực'
       AND uq.NgayBatDau <= CAST(GETDATE() AS DATE)
       AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE))
    WHERE (vt.MaKH = @MaKH OR uq.MaUyQuyen IS NOT NULL)
      AND (@TuNgay IS NULL OR lg.ThoiGianVao >= @TuNgay)
      AND (@DenNgay IS NULL OR lg.ThoiGianVao < DATEADD(DAY, 1, @DenNgay))
);
GO

-- 6. Function f_KH_SaoKeVi: Sao kê ví có số dư lũy kế (window function)
-- Số dư lũy kế tính trên toàn bộ lịch sử rồi mới lọc theo ngày, để dòng đầu kỳ vẫn đúng số dư.
-- Giao dịch 'Đã hoàn' vẫn được tính: khoản tiền gốc đã trừ, khoản hoàn là một giao dịch 'Hoàn tiền' riêng.
-- Khi có SESSION_CONTEXT (cổng khách hàng) chỉ trả ví của chính khách; nhân viên (không có ngữ cảnh) xem được mọi ví.
CREATE OR ALTER FUNCTION dbo.f_KH_SaoKeVi
(
    @MaVi VARCHAR(12),
    @TuNgay DATE,
    @DenNgay DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT sk.*
    FROM (
        SELECT
            g.MaGD,
            g.ThoiGianTao,
            g.LoaiGD,
            g.HuongTien * g.SoTien AS SoTienCoDau,
            p.TenPTTT AS PhuongThucThanhToan,
            g.TrangThai,
            g.MaVe,
            g.GhiChu,
            SUM(CASE WHEN g.TrangThai IN (N'Thành công', N'Đã hoàn') THEN g.HuongTien * g.SoTien ELSE 0 END)
                OVER (ORDER BY g.ThoiGianTao, g.MaGD ROWS UNBOUNDED PRECEDING) AS SoDuLuyKe
        FROM dbo.GIAO_DICH g
        INNER JOIN dbo.VI_DIEN_TU vi ON g.MaVi = vi.MaVi
        INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON g.MaPTTT = p.MaPTTT
        WHERE g.MaVi = @MaVi
          AND (SESSION_CONTEXT(N'MaKH') IS NULL OR vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10)))
    ) sk
    WHERE (@TuNgay IS NULL OR sk.ThoiGianTao >= @TuNgay)
      AND (@DenNgay IS NULL OR sk.ThoiGianTao < DATEADD(DAY, 1, @DenNgay))
);
GO

-- 7. Function f_KH_MatKhauHopLe: Chính sách mật khẩu cổng khách hàng (UPGRADE_PLAN 4.4)
-- Tối thiểu 8 ký tự, có chữ hoa, chữ thường, chữ số và ký tự đặc biệt. Collation BIN để phân biệt hoa/thường.
CREATE OR ALTER FUNCTION dbo.f_KH_MatKhauHopLe
(
    @MatKhau VARCHAR(100)
)
RETURNS BIT
AS
BEGIN
    IF @MatKhau IS NULL OR LEN(@MatKhau) < 8
        RETURN 0;
    IF @MatKhau COLLATE Latin1_General_BIN NOT LIKE '%[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%'
        RETURN 0;
    IF @MatKhau COLLATE Latin1_General_BIN NOT LIKE '%[abcdefghijklmnopqrstuvwxyz]%'
        RETURN 0;
    IF @MatKhau NOT LIKE '%[0-9]%'
        RETURN 0;
    IF @MatKhau COLLATE Latin1_General_BIN NOT LIKE '%[^A-Za-z0-9]%'
        RETURN 0;
    RETURN 1;
END;
GO

-- 8. Function f_KH_MaTKPhien: Mã tài khoản khách hàng của phiên hiện tại (do sp_KH_DangNhap đặt, read-only)
CREATE OR ALTER FUNCTION dbo.f_KH_MaTKPhien()
RETURNS VARCHAR(12)
AS
BEGIN
    RETURN CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12));
END;
GO

-- 9. Function f_VeHienHanhCuaThe: Vé hiện hành của một thẻ (N4 - thẻ được cấp lại cho vé mới).
-- Ưu tiên vé còn dùng (Hoạt động / Tạm khóa; tối đa 1 vé nhờ UX_VeThang_MaThe_ConDung); nếu không có thì lấy vé
-- hết hạn gần nhất để trigger vẫn báo đúng "vé đã hết hạn" khi khách quẹt thẻ tháng chưa gia hạn.
-- Mọi nơi tra vé theo MaThe (trigger cổng, báo mất thẻ, check-in, view bốt cổng) dùng hàm này thay cho JOIN thẳng.
CREATE OR ALTER FUNCTION dbo.f_VeHienHanhCuaThe
(
    @MaThe VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        vt.MaVe, vt.MaThe, vt.MaKH, vt.BienSo, vt.MaLoaiXe, vt.NgayDangKy, vt.NgayHetHan,
        vt.TrangThai, vt.MaBaiApDung, vt.TuDongGiaHan, vt.SoThangTuDongGiaHan
    FROM dbo.VE_THANG vt
    WHERE vt.MaThe = @MaThe
    ORDER BY CASE WHEN vt.TrangThai <> N'Hết hạn' THEN 0 ELSE 1 END, vt.NgayHetHan DESC, vt.MaVe DESC
);
GO


-- ==================== BẮT ĐẦU: 04_triggers.sql (TRIGGERS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 4: DATABASE TRIGGERS (8 TRIGGERS NGHIỆP VỤ TỰ ĐỘNG)
-- ====================================================================================

-- 1. Trigger trg_KiemTraCheckIn: Chặn xe vào nếu thẻ bị khóa/mất, bãi xe đầy, thẻ/ô đỗ đang được dùng hoặc sai bãi
CREATE OR ALTER TRIGGER dbo.trg_KiemTraCheckIn
ON dbo.LUOT_GUI
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra thẻ xe có đang bị khóa hoặc mất không
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.THE_XE tx ON i.MaThe = tx.MaThe
        WHERE tx.TrangThai IN (N'Bị khóa', N'Mất')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, N'Lỗi: Thẻ xe đang bị khóa hoặc báo mất. Không thể check-in!', 1;
        RETURN;
    END;

    -- Kiểm tra bãi đỗ xe đã đầy công suất chưa: đếm trực tiếp số lượt chưa ra (đã gồm lượt vừa chèn),
    -- không đọc SoLuongHienTai để không phụ thuộc thứ tự chạy với trg_DongBoTrangThaiSlot
    IF EXISTS (
        SELECT 1
        FROM dbo.BAI_DO_XE b
        WHERE b.MaBai IN (SELECT MaBai FROM inserted)
          AND (SELECT COUNT(*) FROM dbo.LUOT_GUI lg WHERE lg.MaBai = b.MaBai AND lg.ThoiGianRa IS NULL) > b.SucChua
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Lỗi: Bãi đỗ xe đã đầy công suất! Vui lòng điều phối xe sang bãi khác.', 1;
        RETURN;
    END;

    -- Mỗi thẻ chỉ có tối đa 1 lượt đang đỗ
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE (SELECT COUNT(*) FROM dbo.LUOT_GUI lg WHERE lg.MaThe = i.MaThe AND lg.ThoiGianRa IS NULL) > 1
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50014, N'Lỗi: Thẻ xe đang có lượt gửi chưa check-out. Không thể check-in lần nữa!', 1;
        RETURN;
    END;

    -- Ô đỗ phải thuộc bãi của lượt gửi và chỉ chứa tối đa 1 xe
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.VI_TRI_DO vt ON i.MaViTri = vt.MaViTri
        WHERE vt.MaBai <> i.MaBai
           OR (SELECT COUNT(*) FROM dbo.LUOT_GUI lg WHERE lg.MaViTri = i.MaViTri AND lg.ThoiGianRa IS NULL) > 1
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50015, N'Lỗi: Ô đỗ không thuộc bãi này hoặc đang có xe khác đỗ!', 1;
        RETURN;
    END;

    -- Thẻ lượt chỉ dùng tại bãi phát hành thẻ
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.THE_XE tx ON i.MaThe = tx.MaThe
        WHERE tx.LoaiThe = N'Lượt' AND tx.MaBai <> i.MaBai
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50016, N'Lỗi: Thẻ lượt chỉ sử dụng được tại bãi đã phát hành thẻ!', 1;
        RETURN;
    END;
END;
GO

-- Chạy kiểm tra check-in trước các trigger AFTER INSERT khác (trg_DongBoTrangThaiSlot) để lỗi trả về luôn rõ ràng
EXEC sp_settriggerorder @triggername = N'dbo.trg_KiemTraCheckIn', @order = N'First', @stmttype = N'INSERT';
GO

-- 2. Trigger trg_ChanSuDungVeHetHan: Chặn quét thẻ tháng đã quá hạn đóng tiền
CREATE OR ALTER TRIGGER dbo.trg_ChanSuDungVeHetHan
ON dbo.LUOT_GUI
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.THE_XE tx ON i.MaThe = tx.MaThe
        CROSS APPLY dbo.f_VeHienHanhCuaThe(tx.MaThe) vt   -- chỉ vé hiện hành, bỏ qua vé cũ của thẻ đã cấp lại
        WHERE tx.LoaiThe = N'Tháng'
          AND (vt.NgayHetHan < CAST(GETDATE() AS DATE) OR vt.TrangThai = N'Hết hạn')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, N'Lỗi: Vé tháng này đã hết hạn sử dụng. Yêu cầu gia hạn đóng phí!', 1;
        RETURN;
    END;
END;
GO

-- 3. Trigger trg_DongBoTrangThaiSlot: Tự động đồng bộ trạng thái ô đỗ & số lượng xe bãi đỗ
CREATE OR ALTER TRIGGER dbo.trg_DongBoTrangThaiSlot
ON dbo.LUOT_GUI
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Trường hợp 1: Xe mới vào bãi (ThoiGianRa IS NULL và bản ghi mới được thêm)
    IF EXISTS (SELECT 1 FROM inserted WHERE ThoiGianRa IS NULL)
    BEGIN
        -- Cập nhật ô đỗ sang 'Đã đỗ'
        UPDATE vt
        SET vt.TrangThai = N'Đã đỗ'
        FROM dbo.VI_TRI_DO vt
        INNER JOIN inserted i ON vt.MaViTri = i.MaViTri
        WHERE i.ThoiGianRa IS NULL;

        -- Tăng số lượng xe hiện tại của bãi
        UPDATE bd
        SET bd.SoLuongHienTai = bd.SoLuongHienTai + sub.CountXe
        FROM dbo.BAI_DO_XE bd
        INNER JOIN (
            SELECT MaBai, COUNT(*) AS CountXe
            FROM inserted i
            WHERE i.ThoiGianRa IS NULL
              AND NOT EXISTS (SELECT 1 FROM deleted d WHERE d.MaLuot = i.MaLuot)
            GROUP BY MaBai
        ) sub ON bd.MaBai = sub.MaBai;
    END;

    -- Trường hợp 2: Xe check-out ra bãi (ThoiGianRa chuyển từ NULL sang có thời gian)
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.MaLuot = d.MaLuot
        WHERE d.ThoiGianRa IS NULL AND i.ThoiGianRa IS NOT NULL
    )
    BEGIN
        -- Giải phóng ô đỗ về 'Trống'
        UPDATE vt
        SET vt.TrangThai = N'Trống'
        FROM dbo.VI_TRI_DO vt
        INNER JOIN inserted i ON vt.MaViTri = i.MaViTri
        INNER JOIN deleted d ON i.MaLuot = d.MaLuot
        WHERE d.ThoiGianRa IS NULL AND i.ThoiGianRa IS NOT NULL;

        -- Giảm số lượng xe hiện tại của bãi
        UPDATE bd
        SET bd.SoLuongHienTai = CASE
            WHEN bd.SoLuongHienTai >= sub.CountXe THEN bd.SoLuongHienTai - sub.CountXe
            ELSE 0
        END
        FROM dbo.BAI_DO_XE bd
        INNER JOIN (
            SELECT i.MaBai, COUNT(*) AS CountXe
            FROM inserted i
            INNER JOIN deleted d ON i.MaLuot = d.MaLuot
            WHERE d.ThoiGianRa IS NULL AND i.ThoiGianRa IS NOT NULL
            GROUP BY i.MaBai
        ) sub ON bd.MaBai = sub.MaBai;
    END;
END;
GO

-- 4. Trigger trg_LogLichSuSuCo: Tự động ghi biên bản sự cố và phạt tiền khi báo mất thẻ
CREATE OR ALTER TRIGGER dbo.trg_LogLichSuSuCo
ON dbo.THE_XE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(TrangThai) RETURN;

    INSERT INTO dbo.LICHSU_SU_CO (MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai)
    SELECT
        i.MaThe,
        ISNULL(vt.BienSo, N'Chưa rõ biển số'),
        GETDATE(),
        CONCAT(N'Khách hàng báo mất thẻ chip ', i.MaThe, N' (Loại: ', i.LoaiThe, N'). Hệ thống tự động khóa thẻ và áp phí phạt đền bù thẻ vật lý.'),
        50000,
        N'Chờ xử lý',
        i.MaBai
    FROM inserted i
    INNER JOIN deleted d ON i.MaThe = d.MaThe
    OUTER APPLY dbo.f_VeHienHanhCuaThe(i.MaThe) vt   -- 1 biên bản / thẻ dù thẻ từng gắn nhiều vé
    WHERE i.TrangThai = N'Mất' AND d.TrangThai <> N'Mất';
END;
GO

-- 5. Trigger trg_ChanXoaDuLieuDangDung: Chặn xóa bãi xe hoặc thẻ đang vận hành
CREATE OR ALTER TRIGGER dbo.trg_ChanXoaBaiDoXe
ON dbo.BAI_DO_XE
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.SoLuongHienTai > 0
           OR EXISTS (SELECT 1 FROM dbo.VI_TRI_DO vt WHERE vt.MaBai = d.MaBai)
    )
    BEGIN
        THROW 50005, N'Lỗi: Bãi đỗ xe đang có xe gửi hoạt động hoặc đang chứa danh mục ô đỗ. Không thể xóa!', 1;
        RETURN;
    END;

    DELETE FROM dbo.BAI_DO_XE WHERE MaBai IN (SELECT MaBai FROM deleted);
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_ChanXoaTheXe
ON dbo.THE_XE
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN dbo.LUOT_GUI lg ON d.MaThe = lg.MaThe
        WHERE lg.ThoiGianRa IS NULL
    )
    BEGIN
        THROW 50006, N'Lỗi: Thẻ xe đang được sử dụng trong lượt gửi chưa check-out. Không thể xóa!', 1;
        RETURN;
    END;

    DELETE FROM dbo.THE_XE WHERE MaThe IN (SELECT MaThe FROM deleted);
END;
GO

-- 6. Trigger trg_KiemTraLoaiXe_VeThang: Đảm bảo toàn vẹn tham chiếu (MaLoaiXe, MaBaiApDung) -> LOAI_XE
-- Không dùng FOREIGN KEY thuần vì MaBaiApDung = 'ALL' là giá trị đặc biệt hợp lệ (vé áp dụng
-- toàn chuỗi, xem sp_DangKyThanhVien) không tồn tại trong LOAI_XE/BAI_DO_XE.
-- Vé gắn bãi: loại xe phải có tại bãi áp dụng và thẻ phải do chính bãi đó phát hành.
-- Vé 'ALL': loại xe phải có ở ít nhất một bãi trong chuỗi.
CREATE OR ALTER TRIGGER dbo.trg_KiemTraLoaiXe_VeThang
ON dbo.VE_THANG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE (i.MaBaiApDung <> 'ALL'
               AND NOT EXISTS (
                   SELECT 1 FROM dbo.LOAI_XE lx
                   WHERE lx.MaLoaiXe = i.MaLoaiXe AND lx.MaBai = i.MaBaiApDung
               ))
           OR (i.MaBaiApDung = 'ALL'
               AND NOT EXISTS (SELECT 1 FROM dbo.LOAI_XE lx WHERE lx.MaLoaiXe = i.MaLoaiXe))
           OR (i.MaBaiApDung <> 'ALL'
               AND EXISTS (SELECT 1 FROM dbo.THE_XE tx WHERE tx.MaThe = i.MaThe AND tx.MaBai <> i.MaBaiApDung))
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50009, N'Lỗi: Loại xe không tồn tại tại bãi áp dụng của vé tháng, mã bãi không hợp lệ hoặc thẻ không thuộc bãi áp dụng!', 1;
        RETURN;
    END;
END;
GO

-- 7. Trigger trg_KiemTraBaiApDungVeThang: Chặn thẻ tháng check-in tại bãi không thuộc phạm vi vé
-- Vé gắn một bãi cụ thể (MaBaiApDung = 'BAI_xx') chỉ gửi được tại bãi đó; vé toàn chuỗi ('ALL') gửi được mọi bãi.
CREATE OR ALTER TRIGGER dbo.trg_KiemTraBaiApDungVeThang
ON dbo.LUOT_GUI
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.THE_XE tx ON i.MaThe = tx.MaThe
        CROSS APPLY dbo.f_VeHienHanhCuaThe(tx.MaThe) vt
        WHERE tx.LoaiThe = N'Tháng'
          AND vt.MaBaiApDung <> 'ALL'
          AND vt.MaBaiApDung <> i.MaBai
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50004, N'Lỗi: Vé tháng chỉ áp dụng tại bãi đã đăng ký, không dùng được tại bãi này (vé toàn chuỗi phải đăng ký MaBaiApDung = ALL)!', 1;
        RETURN;
    END;
END;
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- TRIGGERS CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 7)
-- 8 triggers: sổ cái ví (cập nhật số dư, chặn xóa, chặn sửa), chặn sửa số dư trực tiếp, khóa tài khoản,
-- kiểm tra ủy quyền, thông báo hóa đơn, thu hồi ủy quyền khi vé đổi chủ.
-- Không thêm trigger trên LUOT_GUI (đã có 4 trigger AFTER INSERT); LUOT_GUI.MaVe do sp_XeVaoBai ghi.
-- ====================================================================================

-- 1. trg_GiaoDich_CapNhatSoDu: Nguồn sự thật duy nhất cập nhật số dư ví (D4).
-- Khi giao dịch chuyển sang 'Thành công' (INSERT trực tiếp hoặc UPDATE từ 'Chờ xử lý'): cộng / trừ ví,
-- ghi SoDuTruoc / SoDuSau theo thứ tự thời gian. Số dư âm hoặc ví đóng băng -> hủy toàn bộ giao dịch.
CREATE OR ALTER TRIGGER dbo.trg_GiaoDich_CapNhatSoDu
ON dbo.GIAO_DICH
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    DECLARE @Moi TABLE (
        MaGD VARCHAR(16) PRIMARY KEY,
        MaVi VARCHAR(12) NOT NULL,
        BienDong DECIMAL(18,2) NOT NULL,
        LuyKe DECIMAL(18,2) NOT NULL
    );

    INSERT INTO @Moi (MaGD, MaVi, BienDong, LuyKe)
    SELECT
        i.MaGD,
        i.MaVi,
        i.HuongTien * i.SoTien,
        SUM(i.HuongTien * i.SoTien) OVER (PARTITION BY i.MaVi ORDER BY i.ThoiGianTao, i.MaGD ROWS UNBOUNDED PRECEDING)
    FROM inserted i
    LEFT JOIN deleted d ON d.MaGD = i.MaGD
    WHERE i.TrangThai = N'Thành công'
      AND (d.MaGD IS NULL OR d.TrangThai <> N'Thành công');

    IF NOT EXISTS (SELECT 1 FROM @Moi)
        RETURN;

    IF EXISTS (
        SELECT 1
        FROM @Moi m
        INNER JOIN dbo.VI_DIEN_TU v ON v.MaVi = m.MaVi
        WHERE v.TrangThai <> N'Hoạt động'
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50033, N'Lỗi: Ví đang bị đóng băng, không thể ghi nhận biến động số dư!', 1;
    END;

    DECLARE @Vi TABLE (
        MaVi VARCHAR(12) PRIMARY KEY,
        SoDuCu DECIMAL(18,2) NOT NULL,
        TongBienDong DECIMAL(18,2) NOT NULL
    );

    INSERT INTO @Vi (MaVi, SoDuCu, TongBienDong)
    SELECT v.MaVi, v.SoDu, t.Tong
    FROM dbo.VI_DIEN_TU v WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN (SELECT MaVi, SUM(BienDong) AS Tong FROM @Moi GROUP BY MaVi) t ON t.MaVi = v.MaVi;

    -- Không cho số dư âm tại bất kỳ bước nào trong chuỗi giao dịch của câu lệnh này
    IF EXISTS (
        SELECT 1
        FROM @Moi m
        INNER JOIN @Vi v ON v.MaVi = m.MaVi
        WHERE v.SoDuCu + m.LuyKe < 0
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50031, N'Lỗi: Số dư ví không đủ để thực hiện giao dịch!', 1;
    END;

    -- trg_ViDienTu_ChanSuaTrucTiep cho phép vì lệnh UPDATE này chạy bên trong trigger sổ cái
    UPDATE v
    SET v.SoDu = v.SoDu + t.TongBienDong
    FROM dbo.VI_DIEN_TU v
    INNER JOIN @Vi t ON t.MaVi = v.MaVi;

    -- Ghi số dư trước / sau lần đầu (trg_GiaoDich_BatBien cho phép đổi từ NULL sang giá trị)
    UPDATE g
    SET g.SoDuTruoc = v.SoDuCu + m.LuyKe - m.BienDong,
        g.SoDuSau = v.SoDuCu + m.LuyKe,
        g.ThoiGianHoanTat = ISNULL(g.ThoiGianHoanTat, GETDATE())
    FROM dbo.GIAO_DICH g
    INNER JOIN @Moi m ON m.MaGD = g.MaGD
    INNER JOIN @Vi v ON v.MaVi = m.MaVi;
END;
GO

-- 2. trg_GiaoDich_ChanXoa: Sổ cái chỉ ghi thêm, không bao giờ xóa (D3)
CREATE OR ALTER TRIGGER dbo.trg_GiaoDich_ChanXoa
ON dbo.GIAO_DICH
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        -- ROLLBACK tường minh như các trigger khác: lỗi được bắt bằng TRY/CATCH không để lại transaction hỏng
        ROLLBACK TRANSACTION;
        THROW 50060, N'Lỗi: Không được xóa giao dịch khỏi sổ cái. Hãy dùng hoàn tiền (sp_NV_HoanTien) để tạo giao dịch đối ứng!', 1;
    END;
END;
GO

-- 3. trg_GiaoDich_BatBien: Chặn sửa trường tiền / tham chiếu sau khi đã ghi và chặn chuyển trạng thái sai.
-- Máy trạng thái hợp lệ: 'Chờ xử lý' -> 'Thành công' | 'Thất bại'; 'Thành công' -> 'Đã hoàn'.
-- Được phép: ghi SoDuTruoc / SoDuSau lần đầu (NULL -> giá trị), gán MaThamChieu lần đầu, ThoiGianHoanTat, GhiChu.
CREATE OR ALTER TRIGGER dbo.trg_GiaoDich_BatBien
ON dbo.GIAO_DICH
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(MaGD)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50061, N'Lỗi: Không được đổi mã giao dịch trong sổ cái!', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.MaGD = i.MaGD
        WHERE i.MaVi <> d.MaVi
           OR i.LoaiGD <> d.LoaiGD
           OR i.HuongTien <> d.HuongTien
           OR i.SoTien <> d.SoTien
           OR i.PhiGiaoDich <> d.PhiGiaoDich
           OR i.MaPTTT <> d.MaPTTT
           OR i.NguoiThucHien <> d.NguoiThucHien
           OR i.ThoiGianTao <> d.ThoiGianTao
           OR ISNULL(i.MaVe, '') <> ISNULL(d.MaVe, '')
           OR ISNULL(i.MaGDGoc, '') <> ISNULL(d.MaGDGoc, '')
           OR ISNULL(i.MaNV, '') <> ISNULL(d.MaNV, '')
           OR (d.MaThamChieu IS NOT NULL AND ISNULL(i.MaThamChieu, '') <> d.MaThamChieu)
           OR (d.SoDuTruoc IS NOT NULL AND (i.SoDuTruoc IS NULL OR i.SoDuTruoc <> d.SoDuTruoc))
           OR (d.SoDuSau IS NOT NULL AND (i.SoDuSau IS NULL OR i.SoDuSau <> d.SoDuSau))
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50061, N'Lỗi: Sổ cái bất biến - không được sửa số tiền, ví, loại, phương thức hoặc số dư của giao dịch đã ghi!', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.MaGD = i.MaGD
        WHERE i.TrangThai <> d.TrangThai
          AND NOT (
                (d.TrangThai = N'Chờ xử lý' AND i.TrangThai IN (N'Thành công', N'Thất bại'))
             OR (d.TrangThai = N'Thành công' AND i.TrangThai = N'Đã hoàn')
          )
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50061, N'Lỗi: Chuyển trạng thái giao dịch không hợp lệ (chỉ Chờ xử lý -> Thành công/Thất bại, Thành công -> Đã hoàn)!', 1;
    END;
END;
GO

-- Kiểm tra bất biến chạy trước trigger cập nhật số dư khi UPDATE
EXEC sp_settriggerorder @triggername = N'dbo.trg_GiaoDich_BatBien', @order = N'First', @stmttype = N'UPDATE';
GO

-- 4. trg_ViDienTu_ChanSuaTrucTiep: Lớp chặn thứ hai cho D4.
-- Ví mới phải có số dư 0; số dư chỉ được đổi bởi lệnh UPDATE bên trong trg_GiaoDich_CapNhatSoDu
-- (TRIGGER_NESTLEVEL của trigger sổ cái > 0), kể cả khi ai đó có quyền UPDATE trên bảng.
CREATE OR ALTER TRIGGER dbo.trg_ViDienTu_ChanSuaTrucTiep
ON dbo.VI_DIEN_TU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL(OBJECT_ID(N'dbo.trg_GiaoDich_CapNhatSoDu'), 'AFTER', 'DML') > 0
        RETURN;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN deleted d ON d.MaVi = i.MaVi
        WHERE (d.MaVi IS NULL AND i.SoDu <> 0)
           OR (d.MaVi IS NOT NULL AND i.SoDu <> d.SoDu)
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50062, N'Lỗi: Không được sửa trực tiếp số dư ví. Mọi biến động số dư phải đi qua sổ cái GIAO_DICH!', 1;
    END;
END;
GO

-- 5. trg_NhatKyDangNhap_KhoaTaiKhoan: Sai mật khẩu 5 lần trong 15 phút -> khóa tạm 15 phút và gửi thông báo bảo mật
-- (ngưỡng tương ứng tham số SoLanSaiToiDa / PhutKhoaTaiKhoan trong sheet ThamSo của Excel master)
CREATE OR ALTER TRIGGER dbo.trg_NhatKyDangNhap_KhoaTaiKhoan
ON dbo.NHAT_KY_DANG_NHAP
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted WHERE KetQua = N'Sai mật khẩu' AND MaTK IS NOT NULL)
        RETURN;

    DECLARE @Khoa TABLE (MaTK VARCHAR(12), MaKH VARCHAR(10), KhoaDen DATETIME);

    UPDATE tk
    SET tk.TrangThai = N'Tạm khóa',
        tk.KhoaDen = DATEADD(MINUTE, 15, GETDATE())
    OUTPUT inserted.MaTK, inserted.MaKH, inserted.KhoaDen INTO @Khoa (MaTK, MaKH, KhoaDen)
    FROM dbo.TAI_KHOAN_KH tk
    WHERE tk.MaTK IN (SELECT MaTK FROM inserted WHERE KetQua = N'Sai mật khẩu' AND MaTK IS NOT NULL)
      AND tk.TrangThai = N'Hoạt động'
      AND tk.SoLanSaiLienTiep >= 5
      AND (SELECT COUNT(*)
           FROM dbo.NHAT_KY_DANG_NHAP n
           WHERE n.MaTK = tk.MaTK
             AND n.KetQua = N'Sai mật khẩu'
             AND n.ThoiGian >= DATEADD(MINUTE, -15, GETDATE())) >= 5;

    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung)
    SELECT
        k.MaKH,
        N'Bảo mật',
        N'Tài khoản tạm khóa do đăng nhập sai nhiều lần',
        CONCAT(N'Phát hiện 5 lần nhập sai mật khẩu trong 15 phút. Tài khoản tạm khóa đến ',
               FORMAT(k.KhoaDen, 'HH:mm dd/MM/yyyy'), N'. Nếu không phải bạn, hãy đổi mật khẩu sau khi mở khóa.')
    FROM @Khoa k;
END;
GO

-- 6. trg_UyQuyen_KiemTra: Quy tắc chia sẻ vé (sp_KH_UyQuyenVe kiểm tra trước; trigger là chốt chặn cuối)
CREATE OR ALTER TRIGGER dbo.trg_UyQuyen_KiemTra
ON dbo.UY_QUYEN_VE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Không ủy quyền cho chính chủ vé
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.VE_THANG v ON v.MaVe = i.MaVe
        INNER JOIN dbo.TAI_KHOAN_KH tk ON tk.MaTK = i.MaTKDuocUyQuyen
        WHERE i.TrangThai = N'Hiệu lực' AND tk.MaKH = v.MaKH
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50051, N'Lỗi: Không thể ủy quyền vé cho chính chủ vé!', 1;
    END;

    -- Người cấp quyền phải là chủ vé
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.VE_THANG v ON v.MaVe = i.MaVe
        INNER JOIN dbo.TAI_KHOAN_KH c ON c.MaTK = i.MaTKCap
        WHERE i.TrangThai = N'Hiệu lực' AND c.MaKH <> v.MaKH
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50052, N'Lỗi: Chỉ chủ vé mới được chia sẻ vé!', 1;
    END;

    -- Vé hết hạn không được chia sẻ
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.VE_THANG v ON v.MaVe = i.MaVe
        WHERE i.TrangThai = N'Hiệu lực'
          AND (v.TrangThai = N'Hết hạn' OR v.NgayHetHan < CAST(GETDATE() AS DATE))
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50054, N'Lỗi: Vé đã hết hạn, không thể chia sẻ!', 1;
    END;

    -- Tối đa 3 ủy quyền còn hiệu lực trên một vé
    IF EXISTS (
        SELECT 1
        FROM (SELECT DISTINCT MaVe FROM inserted WHERE TrangThai = N'Hiệu lực') x
        WHERE (SELECT COUNT(*) FROM dbo.UY_QUYEN_VE u WHERE u.MaVe = x.MaVe AND u.TrangThai = N'Hiệu lực'
                 AND (u.NgayKetThuc IS NULL OR u.NgayKetThuc >= CAST(GETDATE() AS DATE))) > 3
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50053, N'Lỗi: Mỗi vé chỉ được chia sẻ tối đa 3 tài khoản cùng lúc!', 1;
    END;
END;
GO

-- 7. trg_HoaDon_ThongBaoKhachHang: Mọi hóa đơn vé tháng (quầy, online, tự động) đều tạo thông báo cho chủ vé
CREATE OR ALTER TRIGGER dbo.trg_HoaDon_ThongBaoKhachHang
ON dbo.HOA_DON_VE_THANG
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe, MaGD)
    SELECT
        v.MaKH,
        N'Giao dịch',
        CASE i.KenhThanhToan
            WHEN N'Tự động' THEN N'Vé tháng đã được tự động gia hạn'
            WHEN N'Online' THEN N'Gia hạn vé tháng online thành công'
            ELSE N'Đã thanh toán vé tháng tại quầy'
        END,
        CONCAT(N'Hóa đơn ', i.MaHD, N' - vé ', i.MaVe, N': ', i.SoThangGiaHan, N' tháng, ',
               FORMAT(i.SoTien, 'N0'), N' đồng qua ', p.TenPTTT, N'. Hạn dùng mới: ',
               FORMAT(v.NgayHetHan, 'dd/MM/yyyy'), N'.'),
        i.MaVe,
        i.MaGD
    FROM inserted i
    INNER JOIN dbo.VE_THANG v ON v.MaVe = i.MaVe
    INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON p.MaPTTT = i.MaPTTT;
END;
GO

-- 8. trg_VeThang_ThuHoiUyQuyenKhiDoiChu: Vé sang tên chủ khác -> thu hồi toàn bộ ủy quyền đang hiệu lực
CREATE OR ALTER TRIGGER dbo.trg_VeThang_ThuHoiUyQuyenKhiDoiChu
ON dbo.VE_THANG
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(MaKH)
        RETURN;

    UPDATE uq
    SET uq.TrangThai = N'Đã thu hồi'
    FROM dbo.UY_QUYEN_VE uq
    INNER JOIN inserted i ON i.MaVe = uq.MaVe
    INNER JOIN deleted d ON d.MaVe = i.MaVe
    WHERE i.MaKH <> d.MaKH
      AND uq.TrangThai = N'Hiệu lực';
END;
GO


-- ==================== BẮT ĐẦU: 03_procedures.sql (STORED PROCEDURES) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 5: STORED PROCEDURES (6 PROCEDURES NGHIỆP VỤ CỐT LÕI)
-- ====================================================================================

-- 2. Procedure sp_XeRaBai: Quản lý Check-Out xe ra cổng và tính phí
CREATE OR ALTER PROCEDURE dbo.sp_XeRaBai
(
    @MaThe VARCHAR(10),
    @BienSoRa VARCHAR(15) = NULL,
    @TienThu DECIMAL(18,2) = NULL OUTPUT,
    @MaLuot INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ThoiGianVao DATETIME;
    DECLARE @MaViTri VARCHAR(20);
    DECLARE @MaBai VARCHAR(10);
    DECLARE @MaLoaiXe VARCHAR(10);
    DECLARE @BienSoVao VARCHAR(15);
    DECLARE @LoaiThe NVARCHAR(10);

    -- Tìm lượt xe đang đỗ tương ứng với thẻ
    SELECT TOP 1 
        @MaLuot = lg.MaLuot,
        @ThoiGianVao = lg.ThoiGianVao,
        @MaViTri = lg.MaViTri,
        @MaBai = lg.MaBai,
        @BienSoVao = lg.BienSo,
        @LoaiThe = tx.LoaiThe,
        @MaLoaiXe = vt.MaLoaiXe
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.THE_XE tx ON lg.MaThe = tx.MaThe
    INNER JOIN dbo.VI_TRI_DO vt ON lg.MaViTri = vt.MaViTri
    WHERE lg.MaThe = @MaThe AND lg.ThoiGianRa IS NULL
    ORDER BY lg.ThoiGianVao DESC;

    IF @MaLuot IS NULL
    BEGIN
        THROW 50011, N'Lỗi: Không tìm thấy lượt xe vào tương ứng với thẻ này đang đỗ!', 1;
        RETURN;
    END;

    -- Kiểm tra cảnh báo nếu biển số ra khác biển số lúc vào
    IF @BienSoRa IS NOT NULL AND @BienSoRa <> '' AND @BienSoRa <> @BienSoVao
    BEGIN
        PRINT N'CẢNH BÁO AN NINH: Biển số lúc ra (' + @BienSoRa + N') khác biển số lúc vào (' + @BienSoVao + N')!';
    END;

    -- Tính tiền gửi xe
    IF @LoaiThe = N'Tháng'
    BEGIN
        -- Xe tháng được miễn phí lượt gửi
        SET @TienThu = 0;
    END
    ELSE
    BEGIN
        -- Xe lượt tính tiền qua Function lũy tiến
        SET @TienThu = dbo.f_TinhTienGuiXe(@ThoiGianVao, GETDATE(), @MaLoaiXe, @MaBai);
    END;

    -- Cập nhật lượt gửi xe ra (Trigger trg_DongBoTrangThaiSlot sẽ tự động giải phóng slot)
    UPDATE dbo.LUOT_GUI
    SET ThoiGianRa = GETDATE(),
        TienGui = @TienThu
    WHERE MaLuot = @MaLuot;

    SELECT 
        @MaLuot AS MaLuot,
        @MaThe AS MaThe,
        @BienSoVao AS BienSo,
        @ThoiGianVao AS ThoiGianVao,
        GETDATE() AS ThoiGianRa,
        @MaViTri AS ViTriGiaiPhong,
        @TienThu AS TienGuiThucThu,
        N'Check-Out thành công' AS ThongBao;
END;
GO

-- 5. Procedure sp_BaoMatThe: Xử lý nghiệp vụ báo mất thẻ của khách hàng
CREATE OR ALTER PROCEDURE dbo.sp_BaoMatThe
(
    @MaTheBaoMat VARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.THE_XE WHERE MaThe = @MaTheBaoMat)
    BEGIN
        THROW 50013, N'Lỗi: Mã thẻ cần báo mất không tồn tại!', 1;
        RETURN;
    END;

    -- Cập nhật trạng thái thẻ sang 'Mất' (Trigger trg_LogLichSuSuCo sẽ tự động tạo biên bản phạt)
    UPDATE dbo.THE_XE
    SET TrangThai = N'Mất'
    WHERE MaThe = @MaTheBaoMat;

    -- Khóa vé tháng còn dùng của thẻ (nếu có); vé cũ đã hết hạn của thẻ cấp lại giữ nguyên lịch sử
    UPDATE dbo.VE_THANG
    SET TrangThai = N'Tạm khóa'
    WHERE MaThe = @MaTheBaoMat AND TrangThai <> N'Hết hạn';

    SELECT 
        @MaTheBaoMat AS MaThe,
        N'Mất' AS TrangThaiTheMoi,
        50000 AS TienPhatDenBu,
        N'Đã khóa thẻ và tự động ghi nhận biên bản sự cố' AS KetQua;
END;
GO

-- 6. Procedure sp_DangNhap: Kiểm tra tài khoản, đối chiếu mật khẩu băm SHA2_512 có salt (f_BamMatKhau) và phân quyền
CREATE OR ALTER PROCEDURE dbo.sp_DangNhap
(
    @TenDangNhap VARCHAR(50),
    @MatKhauPlain VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra sự tồn tại của tên đăng nhập
    IF NOT EXISTS (SELECT 1 FROM dbo.TAI_KHOAN WHERE TenDangNhap = @TenDangNhap)
    BEGIN
        THROW 50020, N'Lỗi: Tên đăng nhập không tồn tại trên hệ thống!', 1;
        RETURN;
    END;

    -- Kiểm tra trạng thái tài khoản
    DECLARE @TrangThai NVARCHAR(20);
    DECLARE @MatKhauHashTrongDB VARBINARY(64);
    DECLARE @MatKhauSalt VARBINARY(16);
    DECLARE @MaNV VARCHAR(10);

    SELECT
        @TrangThai = TrangThai,
        @MatKhauHashTrongDB = MatKhauHash,
        @MatKhauSalt = MatKhauSalt,
        @MaNV = MaNV
    FROM dbo.TAI_KHOAN
    WHERE TenDangNhap = @TenDangNhap;

    IF @TrangThai = N'Bị khóa'
    BEGIN
        THROW 50021, N'Lỗi: Tài khoản hiện đang bị khóa! Vui lòng liên hệ Quản trị viên.', 1;
        RETURN;
    END;

    -- Băm mật khẩu người dùng nhập bằng SHA2_512 kèm salt của tài khoản rồi đối chiếu
    IF dbo.f_BamMatKhau(@MatKhauPlain, @MatKhauSalt) <> @MatKhauHashTrongDB
    BEGIN
        THROW 50022, N'Lỗi: Mật khẩu không chính xác! Vui lòng kiểm tra lại.', 1;
        RETURN;
    END;

    -- Trả về thông tin hồ sơ nhân viên và phạm vi quyền hạn
    SELECT 
        tk.TenDangNhap,
        nv.MaNV,
        nv.HoTen,
        nv.ChucVu,
        ISNULL(nv.MaBai, 'ALL') AS MaBaiPhuTrach,
        ISNULL(b.TenBai, N'Toàn bộ chuỗi hệ thống') AS TenBaiPhuTrach,
        tk.TrangThai AS TrangThaiTaiKhoan,
        N'Xác thực đăng nhập thành công' AS KetQua
    FROM dbo.TAI_KHOAN tk
    INNER JOIN dbo.NHAN_VIEN nv ON tk.MaNV = nv.MaNV
    LEFT JOIN dbo.BAI_DO_XE b ON nv.MaBai = b.MaBai
    WHERE tk.TenDangNhap = @TenDangNhap;
END;
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- STORED PROCEDURES CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 5)
--
-- A. Thủ tục hệ thống: sp_SinhMaGiaoDich, sp_GiaHanVe_Core (lõi gia hạn dùng chung mọi kênh)
-- B. Phiên bản mở rộng của 3 thủ tục vận hành (dùng các cột mới của phần cổng khách hàng):
--    sp_GiaHanTheThang, sp_DangKyThanhVien, sp_XeVaoBai. Giữ nguyên chữ ký cũ, chỉ thêm tham số tùy chọn.
-- C. 10 thủ tục khách hàng sp_KH_*: chạy WITH EXECUTE AS OWNER, danh tính lấy từ SESSION_CONTEXT('MaTK')
--    do sp_KH_DangNhap đặt ở chế độ read-only (không nhận @MaTK từ tham số nên không giả mạo được).
-- D. 3 thủ tục nhân viên sp_NV_* và callback cổng thanh toán sp_KH_NapTien_XacNhan (không cấp cho khách).
--
-- Mẫu transaction an toàn khi lồng nhau (N9): nếu đã có transaction bên ngoài (@@TRANCOUNT > 0) thì chỉ
-- SAVE TRANSACTION và khi lỗi chỉ ROLLBACK về savepoint, để không hủy transaction của thủ tục / cursor gọi nó.
-- Mã lỗi mới nằm trong dải 50030 - 50069 (D10).
-- ====================================================================================

-- ====================================================================================
-- A. THỦ TỤC HỆ THỐNG
-- ====================================================================================

-- A1. sp_SinhMaGiaoDich: Sinh mã giao dịch GD + yyMM + 8 chữ số từ SEQUENCE (NEXT VALUE FOR không dùng được trong function)
CREATE OR ALTER PROCEDURE dbo.sp_SinhMaGiaoDich
(
    @MaGD VARCHAR(16) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @So BIGINT;
    SELECT @So = NEXT VALUE FOR dbo.seq_GiaoDich;
    SET @MaGD = CONCAT('GD', FORMAT(GETDATE(), 'yyMM'), RIGHT(CONCAT('00000000', @So), 8));
END;
GO

-- A2. sp_GiaHanVe_Core: Lõi gia hạn vé tháng dùng chung cho quầy, online và tự động.
-- Logic tính giá / chặn giữ nguyên bản be9c15d của sp_GiaHanTheThang (50008, 50012, 50017, 50018, 50019),
-- bổ sung ghi phương thức, kênh thanh toán và giao dịch ví liên kết vào hóa đơn.
CREATE OR ALTER PROCEDURE dbo.sp_GiaHanVe_Core
(
    @MaVe VARCHAR(10),
    @SoThangGiaHan INT = 1,
    @MaBaiGiaHan VARCHAR(10) = NULL,          -- Bãi thu tiền: vé gắn bãi chỉ thu tại bãi áp dụng; vé 'ALL' mặc định bãi phát hành thẻ
    @MaPTTT VARCHAR(20) = 'TIEN_MAT',
    @KenhThanhToan NVARCHAR(20) = N'Tại quầy',
    @MaGD VARCHAR(16) = NULL,                  -- Giao dịch ví đã trừ tiền (bắt buộc khi @MaPTTT = 'SO_DU_VI')
    @MaNVThu VARCHAR(10) = NULL,
    @TraKetQua BIT = 1,                        -- 0: không trả result set (khi được gọi lồng trong thủ tục khác)
    @MaHDRa VARCHAR(15) = NULL OUTPUT,
    @HanMoiRa DATE = NULL OUTPUT,
    @SoTienRa DECIMAL(18,2) = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.VE_THANG WHERE MaVe = @MaVe)
    BEGIN
        THROW 50012, N'Lỗi: Không tìm thấy vé tháng cần gia hạn!', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PHUONG_THUC_THANH_TOAN WHERE MaPTTT = @MaPTTT AND TrangThai = N'Hoạt động')
    BEGIN
        THROW 50035, N'Lỗi: Phương thức thanh toán không tồn tại hoặc đang tạm ngưng!', 1;
    END;

    IF @MaPTTT = 'SO_DU_VI' AND @MaGD IS NULL
    BEGIN
        THROW 50064, N'Lỗi: Thanh toán bằng số dư ví phải đi kèm giao dịch ví (dùng sp_KH_GiaHanBangVi)!', 1;
    END;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_GiaHanVe_Core;

    BEGIN TRY
        DECLARE @NgayHetHanCu DATE;
        DECLARE @MaThe VARCHAR(10);
        DECLARE @MaLoaiXe VARCHAR(10);
        DECLARE @MaBaiApDung VARCHAR(10);
        DECLARE @MaBaiThe VARCHAR(10);
        DECLARE @TrangThaiThe NVARCHAR(20);

        SELECT
            @NgayHetHanCu = vt.NgayHetHan,
            @MaThe = vt.MaThe,
            @MaLoaiXe = vt.MaLoaiXe,
            @MaBaiApDung = vt.MaBaiApDung,
            @MaBaiThe = tx.MaBai,
            @TrangThaiThe = tx.TrangThai
        FROM dbo.VE_THANG vt WITH (UPDLOCK)
        INNER JOIN dbo.THE_XE tx ON vt.MaThe = tx.MaThe
        WHERE vt.MaVe = @MaVe;

        -- Thẻ đã báo mất: không gia hạn (không tự mở khóa thẻ mất)
        IF @TrangThaiThe = N'Mất'
        BEGIN
            THROW 50019, N'Lỗi: Thẻ của vé tháng đã báo mất. Cần cấp thẻ mới trước khi gia hạn!', 1;
        END;

        -- Thẻ đã được cấp lại cho vé khác (N4): vé cũ không mở lại được, khách gia hạn vé mới
        IF EXISTS (SELECT 1 FROM dbo.VE_THANG WHERE MaThe = @MaThe AND MaVe <> @MaVe AND TrangThai <> N'Hết hạn')
        BEGIN
            THROW 50066, N'Lỗi: Thẻ của vé này đã được cấp cho vé tháng khác, vé cũ không gia hạn được!', 1;
        END;

        -- Xác định bãi thu tiền / tính giá
        IF @MaBaiApDung <> 'ALL' AND @MaBaiGiaHan IS NOT NULL AND @MaBaiGiaHan <> @MaBaiApDung
        BEGIN
            THROW 50018, N'Lỗi: Vé tháng gắn một bãi chỉ được gia hạn và thu tiền tại bãi áp dụng của vé!', 1;
        END;

        DECLARE @MaBaiTinhGia VARCHAR(10) = CASE
            WHEN @MaBaiApDung = 'ALL' THEN COALESCE(@MaBaiGiaHan, @MaBaiThe)
            ELSE @MaBaiApDung
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.BAI_DO_XE WHERE MaBai = @MaBaiTinhGia)
        BEGIN
            THROW 50008, N'Lỗi: Bãi bán vé / bãi tính giá vé tháng không hợp lệ!', 1;
        END;

        DECLARE @DonGiaThang DECIMAL(18,2);
        SELECT @DonGiaThang = GiaVeThang
        FROM dbo.LOAI_XE
        WHERE MaLoaiXe = @MaLoaiXe AND MaBai = @MaBaiTinhGia;

        IF @DonGiaThang IS NULL
        BEGIN
            THROW 50017, N'Lỗi: Loại xe chưa có biểu phí vé tháng tại bãi tính giá!', 1;
        END;

        -- Nếu vé còn hạn thì cộng dồn tiếp, nếu đã quá hạn thì tính từ ngày hôm nay
        DECLARE @MocTinh DATE = CASE WHEN @NgayHetHanCu > CAST(GETDATE() AS DATE) THEN @NgayHetHanCu ELSE CAST(GETDATE() AS DATE) END;
        DECLARE @NgayHetHanMoi DATE = DATEADD(MONTH, @SoThangGiaHan, @MocTinh);

        -- Cập nhật vé tháng và mở khóa thẻ xe
        UPDATE dbo.VE_THANG
        SET NgayHetHan = @NgayHetHanMoi,
            TrangThai = N'Hoạt động'
        WHERE MaVe = @MaVe;

        UPDATE dbo.THE_XE
        SET TrangThai = N'Hoạt động'
        WHERE MaThe = @MaThe AND TrangThai <> N'Hoạt động';

        -- Tạo hóa đơn, mã HD + yyyyMMdd + số thứ tự (tối thiểu 3 chữ số)
        DECLARE @SoTien DECIMAL(18,2) = @DonGiaThang * @SoThangGiaHan;
        DECLARE @MaHD VARCHAR(15);
        SELECT @MaHD = CONCAT('HD', FORMAT(GETDATE(), 'yyyyMMdd'),
                              RIGHT(CONCAT('000', ISNULL(MAX(CAST(SUBSTRING(MaHD, 11, 5) AS INT)), 0) + 1), 3))
        FROM dbo.HOA_DON_VE_THANG WITH (UPDLOCK, HOLDLOCK)
        WHERE MaHD LIKE 'HD[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' AND SUBSTRING(MaHD, 3, 13) NOT LIKE '%[^0-9]%';

        INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai, MaPTTT, KenhThanhToan, MaGD, MaNVThu)
        VALUES (@MaHD, @MaVe, GETDATE(), @SoThangGiaHan, @SoTien, @MaBaiTinhGia, @MaPTTT, @KenhThanhToan, @MaGD, @MaNVThu);

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SET @MaHDRa = @MaHD;
        SET @HanMoiRa = @NgayHetHanMoi;
        SET @SoTienRa = @SoTien;

        IF @TraKetQua = 1
            SELECT
                @MaVe AS MaVe,
                @MaThe AS MaThe,
                @NgayHetHanCu AS HanCu,
                @NgayHetHanMoi AS HanMoi,
                @MaHD AS MaHoaDon,
                @MaBaiTinhGia AS MaBaiThuTien,
                @SoTien AS SoTienGiaHan,
                @MaPTTT AS MaPTTT,
                @KenhThanhToan AS KenhThanhToan,
                N'Gia hạn vé tháng thành công' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_GiaHanVe_Core;
        END;
        THROW;
    END CATCH;
END;
GO

-- ====================================================================================
-- B. PHIÊN BẢN MỞ RỘNG CỦA THỦ TỤC VẬN HÀNH
-- ====================================================================================

-- B1. sp_GiaHanTheThang: Gia hạn tại quầy. Giữ chữ ký be9c15d, thêm @MaPTTT / @MaNVThu tùy chọn, gọi lõi chung.
CREATE OR ALTER PROCEDURE dbo.sp_GiaHanTheThang
(
    @MaVe VARCHAR(10),
    @SoThangGiaHan INT = 1,
    @MaBaiGiaHan VARCHAR(10) = NULL, -- Bãi thu tiền: vé gắn bãi chỉ thu tại bãi áp dụng; vé 'ALL' mặc định là bãi phát hành thẻ
    @MaPTTT VARCHAR(20) = 'TIEN_MAT',
    @MaNVThu VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.sp_GiaHanVe_Core
        @MaVe = @MaVe,
        @SoThangGiaHan = @SoThangGiaHan,
        @MaBaiGiaHan = @MaBaiGiaHan,
        @MaPTTT = @MaPTTT,
        @KenhThanhToan = N'Tại quầy',
        @MaGD = NULL,
        @MaNVThu = @MaNVThu,
        @TraKetQua = 1;
END;
GO

-- B2. sp_DangKyThanhVien: Giữ nguyên logic be9c15d, thêm @MaPTTT / @MaNVThu tùy chọn và ghi vào hóa đơn.
CREATE OR ALTER PROCEDURE dbo.sp_DangKyThanhVien
(
    @MaKH VARCHAR(10) = NULL, -- NULL: tìm khách theo CMND/CCCD, chưa có thì sinh mã KH#### tiếp theo
    @HoTen NVARCHAR(100),
    @SDT VARCHAR(15),
    @CMND VARCHAR(12),
    @MaThe VARCHAR(10),
    @BienSo VARCHAR(15),
    @MaLoaiXe VARCHAR(10),
    @MaBaiApDung VARCHAR(10),
    @SoThangDongTruoc INT = 1,
    @Email VARCHAR(100) = NULL,
    @MaBaiBan VARCHAR(10) = NULL, -- Bãi bán vé / thu tiền (dùng cho vé toàn chuỗi 'ALL')
    @MaPTTT VARCHAR(20) = 'TIEN_MAT',
    @MaNVThu VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Email = NULLIF(LTRIM(RTRIM(@Email)), ''); -- Email rỗng lưu NULL (UQ_KhachHang_Email chỉ áp dụng khi có email)

    IF @MaPTTT = 'SO_DU_VI'
       OR NOT EXISTS (SELECT 1 FROM dbo.PHUONG_THUC_THANH_TOAN WHERE MaPTTT = @MaPTTT AND TrangThai = N'Hoạt động')
    BEGIN
        THROW 50035, N'Lỗi: Phương thức thanh toán không hợp lệ cho đăng ký vé tại quầy!', 1;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Lưu thông tin khách hàng (nếu chưa có thì thêm, có rồi thì cập nhật)
        IF @MaKH IS NULL
            SELECT @MaKH = MaKH FROM dbo.KHACH_HANG WITH (UPDLOCK, HOLDLOCK) WHERE CMND_CCCD = @CMND;

        IF @MaKH IS NULL
            SELECT @MaKH = CONCAT('KH', RIGHT(CONCAT('0000', ISNULL(MAX(CAST(SUBSTRING(MaKH, 3, 8) AS INT)), 0) + 1), 4))
            FROM dbo.KHACH_HANG WITH (UPDLOCK, HOLDLOCK)
            WHERE MaKH LIKE 'KH[0-9][0-9][0-9][0-9]%' AND SUBSTRING(MaKH, 3, 8) NOT LIKE '%[^0-9]%';

        IF NOT EXISTS (SELECT 1 FROM dbo.KHACH_HANG WHERE MaKH = @MaKH)
        BEGIN
            INSERT INTO dbo.KHACH_HANG (MaKH, HoTen, SDT, Email, CMND_CCCD)
            VALUES (@MaKH, @HoTen, @SDT, @Email, @CMND);
        END
        ELSE
        BEGIN
            UPDATE dbo.KHACH_HANG
            SET HoTen = @HoTen, SDT = @SDT, Email = @Email, CMND_CCCD = @CMND
            WHERE MaKH = @MaKH;
        END;

        -- 2. Xác định bãi tính giá và đơn giá trước khi ghi vé
        DECLARE @MaBaiTinhGia VARCHAR(10) = CASE
            WHEN @MaBaiApDung = 'ALL' THEN COALESCE(@MaBaiBan, (SELECT MaBai FROM dbo.THE_XE WHERE MaThe = @MaThe))
            ELSE @MaBaiApDung
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.BAI_DO_XE WHERE MaBai = @MaBaiTinhGia)
        BEGIN
            THROW 50008, N'Lỗi: Bãi bán vé / bãi tính giá vé tháng không hợp lệ!', 1;
        END;

        DECLARE @DonGiaThang DECIMAL(18,2);
        SELECT @DonGiaThang = GiaVeThang
        FROM dbo.LOAI_XE
        WHERE MaLoaiXe = @MaLoaiXe AND MaBai = @MaBaiTinhGia;

        IF @DonGiaThang IS NULL
        BEGIN
            THROW 50017, N'Lỗi: Loại xe chưa có biểu phí vé tháng tại bãi tính giá!', 1;
        END;

        -- 3. Cấp thẻ cho vé mới. Thẻ cấp lại (N4): vé cũ đã quá hạn của thẻ chuyển 'Hết hạn' và tắt tự động gia hạn
        --    (không còn giữ thẻ); thẻ đã báo mất hoặc còn gắn vé đang dùng thì không cấp cho vé mới.
        IF EXISTS (SELECT 1 FROM dbo.THE_XE WHERE MaThe = @MaThe AND TrangThai = N'Mất')
        BEGIN
            THROW 50019, N'Lỗi: Thẻ đã báo mất, không cấp cho vé tháng mới. Hãy dùng thẻ khác!', 1;
        END;

        UPDATE dbo.VE_THANG
        SET TrangThai = N'Hết hạn', TuDongGiaHan = 0
        WHERE MaThe = @MaThe
          AND (TrangThai = N'Hết hạn' OR (TrangThai = N'Hoạt động' AND NgayHetHan < CAST(GETDATE() AS DATE)));

        DECLARE @VeDangGiuThe VARCHAR(10) = (SELECT MaVe FROM dbo.VE_THANG WHERE MaThe = @MaThe AND TrangThai <> N'Hết hạn');
        IF @VeDangGiuThe IS NOT NULL
        BEGIN
            DECLARE @ThongBaoThe NVARCHAR(400) = CONCAT(N'Lỗi: Thẻ ', @MaThe, N' đang gắn với vé tháng ', @VeDangGiuThe,
                                                        N' còn hiệu lực. Hãy dùng thẻ khác hoặc gia hạn vé đó!');
            THROW 50065, @ThongBaoThe, 1;
        END;

        UPDATE dbo.THE_XE
        SET LoaiThe = N'Tháng', TrangThai = N'Hoạt động'
        WHERE MaThe = @MaThe;

        -- 4. Sinh mã vé tháng V#### tiếp theo và tính hạn dùng
        DECLARE @MaVe VARCHAR(10);
        SELECT @MaVe = CONCAT('V', RIGHT(CONCAT('0000', ISNULL(MAX(CAST(SUBSTRING(MaVe, 2, 9) AS INT)), 0) + 1), 4))
        FROM dbo.VE_THANG WITH (UPDLOCK, HOLDLOCK)
        WHERE MaVe LIKE 'V[0-9][0-9][0-9][0-9]%' AND SUBSTRING(MaVe, 2, 9) NOT LIKE '%[^0-9]%';

        DECLARE @NgayHetHan DATE = DATEADD(MONTH, @SoThangDongTruoc, CAST(GETDATE() AS DATE));

        INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung)
        VALUES (@MaVe, @MaThe, @MaKH, @BienSo, @MaLoaiXe, CAST(GETDATE() AS DATE), @NgayHetHan, N'Hoạt động', @MaBaiApDung);

        -- 5. Tính tiền và xuất hóa đơn, mã HD + yyyyMMdd + số thứ tự (tối thiểu 3 chữ số)
        DECLARE @TongTien DECIMAL(18,2) = @DonGiaThang * @SoThangDongTruoc;
        DECLARE @MaHD VARCHAR(15);
        SELECT @MaHD = CONCAT('HD', FORMAT(GETDATE(), 'yyyyMMdd'),
                              RIGHT(CONCAT('000', ISNULL(MAX(CAST(SUBSTRING(MaHD, 11, 5) AS INT)), 0) + 1), 3))
        FROM dbo.HOA_DON_VE_THANG WITH (UPDLOCK, HOLDLOCK)
        WHERE MaHD LIKE 'HD[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' AND SUBSTRING(MaHD, 3, 13) NOT LIKE '%[^0-9]%';

        INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai, MaPTTT, KenhThanhToan, MaNVThu)
        VALUES (@MaHD, @MaVe, GETDATE(), @SoThangDongTruoc, @TongTien, @MaBaiTinhGia, @MaPTTT, N'Tại quầy', @MaNVThu);

        COMMIT TRANSACTION;

        SELECT
            @MaVe AS MaVe,
            @MaKH AS MaKH,
            @HoTen AS HoTenKhachHang,
            @MaThe AS MaThe,
            @BienSo AS BienSo,
            @NgayHetHan AS NgayHetHan,
            @MaHD AS MaHoaDon,
            @TongTien AS TongTienThanhToan,
            @MaPTTT AS MaPTTT,
            N'Đăng ký vé tháng thành công' AS TrangThai;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- B3. sp_XeVaoBai: Giữ nguyên logic V6, ghi thêm LUOT_GUI.MaVe khi thẻ là thẻ tháng (lịch sử đỗ xe theo vé)
CREATE OR ALTER PROCEDURE dbo.sp_XeVaoBai
(
    @MaThe VARCHAR(10),
    @BienSo VARCHAR(15),
    @MaBai VARCHAR(10),
    @MaLoaiXe VARCHAR(10) = NULL,
    @MaViTri VARCHAR(20) = NULL OUTPUT,
    @MaLuot INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra thẻ xe tồn tại
    IF NOT EXISTS (SELECT 1 FROM dbo.THE_XE WHERE MaThe = @MaThe)
    BEGIN
        THROW 50007, N'Lỗi: Thẻ xe không tồn tại trên hệ thống!', 1;
        RETURN;
    END;

    -- Nếu xe tháng, lấy tự động loại xe đã đăng ký
    IF @MaLoaiXe IS NULL
    BEGIN
        SELECT @MaLoaiXe = vt.MaLoaiXe
        FROM dbo.VE_THANG vt
        WHERE vt.MaThe = @MaThe AND vt.TrangThai = N'Hoạt động';

        -- Nếu không phải xe tháng, mặc định xe máy 'XM'
        IF @MaLoaiXe IS NULL SET @MaLoaiXe = 'XM';
    END;

    -- Vé tháng hiện hành của thẻ (NULL nếu thẻ lượt); thẻ cấp lại có thể còn vé cũ đã hết hạn
    DECLARE @MaVe VARCHAR(10);
    SELECT @MaVe = vt.MaVe
    FROM dbo.THE_XE tx
    CROSS APPLY dbo.f_VeHienHanhCuaThe(tx.MaThe) vt
    WHERE tx.MaThe = @MaThe AND tx.LoaiThe = N'Tháng';

    -- Tìm ô đỗ trống khả dụng thông qua Function
    DECLARE @SlotTrong VARCHAR(20) = dbo.f_TimSlotTrong(@MaBai, @MaLoaiXe);
    IF @SlotTrong IS NULL
    BEGIN
        THROW 50010, N'Lỗi: Không còn ô đỗ trống phù hợp loại xe tại bãi này!', 1;
        RETURN;
    END;

    -- Tạo lượt gửi xe mới (Trigger trg_KiemTraCheckIn và trg_DongBoTrangThaiSlot sẽ tự động can thiệp)
    INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai, MaVe)
    VALUES (@MaThe, @BienSo, GETDATE(), NULL, @SlotTrong, 0, @MaBai, @MaVe);

    SET @MaLuot = SCOPE_IDENTITY();
    SET @MaViTri = @SlotTrong;

    SELECT
        @MaLuot AS MaLuot,
        @MaThe AS MaThe,
        @BienSo AS BienSo,
        @MaBai AS MaBai,
        @MaViTri AS ViTriDoDuocCap,
        @MaVe AS MaVe,
        N'Check-In thành công' AS ThongBao;
END;
GO

-- ====================================================================================
-- C. THỦ TỤC KHÁCH HÀNG (cấp EXECUTE cho r_KhachHang ở bước 17)
-- ====================================================================================

-- C1. sp_KH_DangKyTaiKhoan: Khách đã có hồ sơ tại quầy tự tạo tài khoản (D8), tạo kèm ví số dư 0
CREATE OR ALTER PROCEDURE dbo.sp_KH_DangKyTaiKhoan
(
    @SDT VARCHAR(15),
    @CMND VARCHAR(12),
    @MatKhau VARCHAR(100),
    @Email VARCHAR(100) = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET @SDT = LTRIM(RTRIM(@SDT));
    SET @CMND = LTRIM(RTRIM(@CMND));
    SET @Email = NULLIF(LTRIM(RTRIM(@Email)), '');

    IF dbo.f_KH_MatKhauHopLe(@MatKhau) = 0
    BEGIN
        THROW 50034, N'Lỗi: Mật khẩu phải có tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt!', 1;
    END;

    DECLARE @MaKH VARCHAR(10);
    SELECT @MaKH = MaKH FROM dbo.KHACH_HANG WHERE SDT = @SDT AND CMND_CCCD = @CMND;

    IF @MaKH IS NULL
    BEGIN
        THROW 50030, N'Lỗi: Số điện thoại và CCCD không khớp hồ sơ khách hàng nào. Vui lòng đăng ký vé tại quầy trước!', 1;
    END;

    IF EXISTS (SELECT 1 FROM dbo.TAI_KHOAN_KH WHERE MaKH = @MaKH OR TenDangNhap = @SDT)
    BEGIN
        THROW 50032, N'Lỗi: Khách hàng này đã có tài khoản cổng khách hàng!', 1;
    END;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_KH_DangKyTaiKhoan;

    BEGIN TRY
        DECLARE @MaTK VARCHAR(12);
        SELECT @MaTK = CONCAT('TK', RIGHT(CONCAT('0000', ISNULL(MAX(CAST(SUBSTRING(MaTK, 3, 9) AS INT)), 0) + 1), 4))
        FROM dbo.TAI_KHOAN_KH WITH (UPDLOCK, HOLDLOCK)
        WHERE MaTK LIKE 'TK[0-9][0-9][0-9][0-9]%' AND SUBSTRING(MaTK, 3, 9) NOT LIKE '%[^0-9]%';

        DECLARE @Salt VARBINARY(16) = CAST(CRYPT_GEN_RANDOM(16) AS VARBINARY(16));

        INSERT INTO dbo.TAI_KHOAN_KH (MaTK, MaKH, TenDangNhap, MatKhauHash, MatKhauSalt)
        VALUES (@MaTK, @MaKH, @SDT, dbo.f_BamMatKhau(@MatKhau, @Salt), @Salt);

        DECLARE @MaVi VARCHAR(12) = (SELECT MaVi FROM dbo.VI_DIEN_TU WHERE MaKH = @MaKH);
        IF @MaVi IS NULL
        BEGIN
            SELECT @MaVi = CONCAT('VI', RIGHT(CONCAT('0000', ISNULL(MAX(CAST(SUBSTRING(MaVi, 3, 9) AS INT)), 0) + 1), 4))
            FROM dbo.VI_DIEN_TU WITH (UPDLOCK, HOLDLOCK)
            WHERE MaVi LIKE 'VI[0-9][0-9][0-9][0-9]%' AND SUBSTRING(MaVi, 3, 9) NOT LIKE '%[^0-9]%';

            INSERT INTO dbo.VI_DIEN_TU (MaVi, MaKH) VALUES (@MaVi, @MaKH);
        END;

        IF @Email IS NOT NULL
            UPDATE dbo.KHACH_HANG SET Email = @Email WHERE MaKH = @MaKH AND Email IS NULL;

        INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung)
        VALUES (@MaKH, N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark',
                N'Tài khoản đã được tạo. Bạn có thể nạp tiền vào ví, tự gia hạn vé tháng và xem lịch sử đỗ xe ngay trên cổng khách hàng.');

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SELECT @MaTK AS MaTK, @MaKH AS MaKH, @SDT AS TenDangNhap, @MaVi AS MaVi,
               N'Tạo tài khoản cổng khách hàng thành công' AS KetQua;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_KH_DangKyTaiKhoan;
        END;
        THROW;
    END CATCH;
END;
GO

-- C2. sp_KH_DangNhap: Xác thực, ghi nhật ký, khóa khi sai nhiều lần (trigger), đặt SESSION_CONTEXT read-only.
-- Sai tên đăng nhập và sai mật khẩu trả về cùng một thông báo 50040 (chống dò tài khoản).
-- Nhật ký và bộ đếm sai được ghi trước khi THROW, không nằm trong transaction riêng: bên gọi phải COMMIT cả khi
-- nhận lỗi 50040 / 50041 (hoặc gọi ở chế độ autocommit), nếu ROLLBACK thì trigger khóa tài khoản không bao giờ kích hoạt.
CREATE OR ALTER PROCEDURE dbo.sp_KH_DangNhap
(
    @TenDangNhap VARCHAR(100),
    @MatKhau VARCHAR(100),
    @DiaChiIP VARCHAR(45) = NULL,
    @ThietBi NVARCHAR(200) = NULL,
    @KhoaNguCanh BIT = 1   -- 1: SESSION_CONTEXT read-only (bắt buộc cho cổng khách hàng thật)
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12);
    DECLARE @MaKH VARCHAR(10);
    DECLARE @TrangThai NVARCHAR(20);
    DECLARE @KhoaDen DATETIME;
    DECLARE @Hash VARBINARY(64);
    DECLARE @Salt VARBINARY(16);
    DECLARE @ThongBao NVARCHAR(2048);

    SELECT
        @MaTK = MaTK,
        @MaKH = MaKH,
        @TrangThai = TrangThai,
        @KhoaDen = KhoaDen,
        @Hash = MatKhauHash,
        @Salt = MatKhauSalt
    FROM dbo.TAI_KHOAN_KH
    WHERE TenDangNhap = @TenDangNhap;

    IF @MaTK IS NULL
    BEGIN
        INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, KetQua, DiaChiIP, ThietBi)
        VALUES (NULL, LEFT(ISNULL(@TenDangNhap, ''), 100), N'Không tồn tại', @DiaChiIP, @ThietBi);
        THROW 50040, N'Lỗi: Tên đăng nhập hoặc mật khẩu không đúng!', 1;
    END;

    -- Hết thời gian khóa tạm thì tự mở khóa
    IF @TrangThai = N'Tạm khóa' AND @KhoaDen IS NOT NULL AND @KhoaDen <= GETDATE()
    BEGIN
        UPDATE dbo.TAI_KHOAN_KH
        SET TrangThai = N'Hoạt động', KhoaDen = NULL, SoLanSaiLienTiep = 0
        WHERE MaTK = @MaTK;
        SET @TrangThai = N'Hoạt động';
    END;

    IF @TrangThai = N'Tạm khóa'
    BEGIN
        INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, KetQua, DiaChiIP, ThietBi)
        VALUES (@MaTK, @TenDangNhap, N'Bị khóa', @DiaChiIP, @ThietBi);
        SET @ThongBao = CONCAT(N'Lỗi: Tài khoản đang tạm khóa do đăng nhập sai nhiều lần. Vui lòng thử lại sau ',
                               ISNULL(FORMAT(@KhoaDen, 'HH:mm dd/MM/yyyy'), N'khi được nhân viên mở khóa'), N'.');
        THROW 50041, @ThongBao, 1;
    END;

    IF @TrangThai = N'Đã đóng'
    BEGIN
        INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, KetQua, DiaChiIP, ThietBi)
        VALUES (@MaTK, @TenDangNhap, N'Bị khóa', @DiaChiIP, @ThietBi);
        THROW 50043, N'Lỗi: Tài khoản đã đóng. Vui lòng liên hệ quầy để được hỗ trợ!', 1;
    END;

    IF dbo.f_BamMatKhau(@MatKhau, @Salt) <> @Hash
    BEGIN
        -- Tăng bộ đếm trước khi ghi nhật ký để trg_NhatKyDangNhap_KhoaTaiKhoan thấy số lần sai mới nhất
        UPDATE dbo.TAI_KHOAN_KH
        SET SoLanSaiLienTiep = CASE WHEN SoLanSaiLienTiep < 255 THEN SoLanSaiLienTiep + 1 ELSE 255 END
        WHERE MaTK = @MaTK;

        INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, KetQua, DiaChiIP, ThietBi)
        VALUES (@MaTK, @TenDangNhap, N'Sai mật khẩu', @DiaChiIP, @ThietBi);

        THROW 50040, N'Lỗi: Tên đăng nhập hoặc mật khẩu không đúng!', 1;
    END;

    UPDATE dbo.TAI_KHOAN_KH
    SET SoLanSaiLienTiep = 0, LanDangNhapCuoi = GETDATE()
    WHERE MaTK = @MaTK;

    INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, KetQua, DiaChiIP, ThietBi)
    VALUES (@MaTK, @TenDangNhap, N'Thành công', @DiaChiIP, @ThietBi);

    -- Ngữ cảnh phiên: các sp_KH_* và RLS dùng hai khóa này để xác định khách hàng
    EXEC sys.sp_set_session_context @key = N'MaTK', @value = @MaTK, @read_only = @KhoaNguCanh;
    EXEC sys.sp_set_session_context @key = N'MaKH', @value = @MaKH, @read_only = @KhoaNguCanh;

    SELECT
        tk.MaTK,
        tk.MaKH,
        kh.HoTen,
        tk.TenDangNhap,
        vi.MaVi,
        vi.SoDu,
        (SELECT COUNT(*) FROM dbo.VE_THANG v WHERE v.MaKH = tk.MaKH) AS SoVeSoHuu,
        (SELECT COUNT(*) FROM dbo.UY_QUYEN_VE uq
          WHERE uq.MaTKDuocUyQuyen = tk.MaTK AND uq.TrangThai = N'Hiệu lực'
            AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE))) AS SoVeDuocChiaSe,
        (SELECT COUNT(*) FROM dbo.THONG_BAO tb WHERE tb.MaKH = tk.MaKH AND tb.DaDoc = 0) AS SoThongBaoChuaDoc,
        N'Đăng nhập thành công' AS KetQua
    FROM dbo.TAI_KHOAN_KH tk
    INNER JOIN dbo.KHACH_HANG kh ON tk.MaKH = kh.MaKH
    LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = tk.MaKH
    WHERE tk.MaTK = @MaTK;
END;
GO

-- C3. sp_KH_DoiMatKhau: Đổi mật khẩu của tài khoản đang đăng nhập, sinh salt mới
CREATE OR ALTER PROCEDURE dbo.sp_KH_DoiMatKhau
(
    @MatKhauCu VARCHAR(100),
    @MatKhauMoi VARCHAR(100)
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @MaKH VARCHAR(10);
    DECLARE @Hash VARBINARY(64);
    DECLARE @Salt VARBINARY(16);
    SELECT @MaKH = MaKH, @Hash = MatKhauHash, @Salt = MatKhauSalt FROM dbo.TAI_KHOAN_KH WHERE MaTK = @MaTK;

    IF @MaKH IS NULL OR dbo.f_BamMatKhau(@MatKhauCu, @Salt) <> @Hash
    BEGIN
        THROW 50044, N'Lỗi: Mật khẩu hiện tại không đúng!', 1;
    END;

    IF dbo.f_KH_MatKhauHopLe(@MatKhauMoi) = 0
    BEGIN
        THROW 50034, N'Lỗi: Mật khẩu phải có tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt!', 1;
    END;

    DECLARE @SaltMoi VARBINARY(16) = CAST(CRYPT_GEN_RANDOM(16) AS VARBINARY(16));

    UPDATE dbo.TAI_KHOAN_KH
    SET MatKhauSalt = @SaltMoi, MatKhauHash = dbo.f_BamMatKhau(@MatKhauMoi, @SaltMoi)
    WHERE MaTK = @MaTK;

    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung)
    VALUES (@MaKH, N'Bảo mật', N'Mật khẩu đã được thay đổi',
            N'Mật khẩu cổng khách hàng vừa được thay đổi. Nếu không phải bạn thực hiện, hãy liên hệ quầy ngay.');

    SELECT @MaTK AS MaTK, N'Đổi mật khẩu thành công' AS KetQua;
END;
GO

-- C4. sp_KH_NapTien_KhoiTao: Pha 1 nạp tiền - tạo giao dịch 'Chờ xử lý' để chuyển sang cổng thanh toán (D5)
CREATE OR ALTER PROCEDURE dbo.sp_KH_NapTien_KhoiTao
(
    @SoTien DECIMAL(18,2),
    @MaPTTT VARCHAR(20),
    @MaGD VARCHAR(16) = NULL OUTPUT
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    IF dbo.f_KH_CoQuyen(@MaTK, 'VI.NAPTIEN', NULL) = 0
    BEGIN
        THROW 50050, N'Lỗi: Tài khoản không có quyền VI.NAPTIEN (tài khoản bị khóa hoặc đã đóng)!', 1;
    END;

    DECLARE @MaKH VARCHAR(10) = (SELECT MaKH FROM dbo.TAI_KHOAN_KH WHERE MaTK = @MaTK);
    DECLARE @MaVi VARCHAR(12);
    DECLARE @HanMuc DECIMAL(18,2);
    SELECT @MaVi = MaVi, @HanMuc = HanMucNapNgay
    FROM dbo.VI_DIEN_TU
    WHERE MaKH = @MaKH AND TrangThai = N'Hoạt động';

    IF @MaVi IS NULL
    BEGIN
        THROW 50033, N'Lỗi: Ví không tồn tại hoặc đang bị đóng băng!', 1;
    END;

    DECLARE @PhiPhanTram DECIMAL(5,2);
    DECLARE @ToiThieu DECIMAL(18,2);
    SELECT @PhiPhanTram = PhiPhanTram, @ToiThieu = SoTienToiThieu
    FROM dbo.PHUONG_THUC_THANH_TOAN
    WHERE MaPTTT = @MaPTTT AND TrangThai = N'Hoạt động' AND ChoPhepNapVi = 1
      AND LoaiKenh <> N'Tiền mặt';   -- tiền mặt chỉ nạp tại quầy qua sp_NV_NapTienTaiQuay, không có cổng thanh toán

    IF @PhiPhanTram IS NULL
    BEGIN
        THROW 50035, N'Lỗi: Phương thức thanh toán không tồn tại, đang tạm ngưng hoặc không dùng để nạp ví!', 1;
    END;

    DECLARE @ThongBao NVARCHAR(2048);
    IF @SoTien IS NULL OR @SoTien < @ToiThieu OR @SoTien <= 0
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Số tiền nạp tối thiểu qua phương thức này là ', FORMAT(@ToiThieu, 'N0'), N' đồng!');
        THROW 50036, @ThongBao, 1;
    END;

    IF dbo.f_KH_TongNapTrongNgay(@MaVi) + @SoTien > @HanMuc
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Vượt hạn mức nạp trong ngày (', FORMAT(@HanMuc, 'N0'), N' đồng)!');
        THROW 50037, @ThongBao, 1;
    END;

    EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGD OUTPUT;

    INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, PhiGiaoDich, MaPTTT, TrangThai, NguoiThucHien, GhiChu)
    VALUES (@MaGD, @MaVi, N'Nạp tiền', 1, @SoTien, ROUND(@SoTien * @PhiPhanTram / 100, 0), @MaPTTT, N'Chờ xử lý',
            N'Khách hàng', N'Chờ kết quả từ cổng thanh toán');

    SELECT
        g.MaGD,
        g.SoTien,
        g.PhiGiaoDich,
        p.TenPTTT AS PhuongThucThanhToan,
        g.TrangThai,
        N'Đã tạo lệnh nạp tiền, chuyển khách sang cổng thanh toán' AS KetQua
    FROM dbo.GIAO_DICH g
    INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON g.MaPTTT = p.MaPTTT
    WHERE g.MaGD = @MaGD;
END;
GO

-- C5. sp_KH_GiaHanBangVi: Khách tự gia hạn vé bằng số dư ví (trừ ví + gia hạn + hóa đơn trong cùng transaction)
CREATE OR ALTER PROCEDURE dbo.sp_KH_GiaHanBangVi
(
    @MaVe VARCHAR(10),
    @SoThang INT = 1
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @ThongBao NVARCHAR(2048);

    IF dbo.f_KH_CoQuyen(@MaTK, 'VE.GIAHAN', @MaVe) = 0
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Tài khoản không có quyền VE.GIAHAN trên vé ', @MaVe, N'!');
        THROW 50050, @ThongBao, 1;
    END;

    IF @SoThang IS NULL OR @SoThang < 1 OR @SoThang > 12
    BEGIN
        THROW 50045, N'Lỗi: Số tháng gia hạn phải từ 1 đến 12!', 1;
    END;

    DECLARE @SoTien DECIMAL(18,2) = dbo.f_KH_TinhPhiGiaHan(@MaVe, @SoThang);
    IF @SoTien IS NULL
    BEGIN
        THROW 50017, N'Lỗi: Loại xe chưa có biểu phí vé tháng tại bãi tính giá!', 1;
    END;

    DECLARE @MaKH VARCHAR(10) = (SELECT MaKH FROM dbo.TAI_KHOAN_KH WHERE MaTK = @MaTK);
    DECLARE @MaVi VARCHAR(12);
    DECLARE @SoDu DECIMAL(18,2);
    SELECT @MaVi = MaVi, @SoDu = SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = @MaKH AND TrangThai = N'Hoạt động';

    IF @MaVi IS NULL
    BEGIN
        THROW 50033, N'Lỗi: Ví không tồn tại hoặc đang bị đóng băng!', 1;
    END;

    -- Kiểm tra sớm để trả thông báo rõ số tiền thiếu; trigger sổ cái + CHECK SoDu >= 0 vẫn là chốt chặn cuối
    IF @SoDu < @SoTien
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Số dư ví không đủ. Cần ', FORMAT(@SoTien, 'N0'), N' đồng, hiện có ',
                               FORMAT(@SoDu, 'N0'), N' đồng (thiếu ', FORMAT(@SoTien - @SoDu, 'N0'), N' đồng)!');
        THROW 50031, @ThongBao, 1;
    END;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_KH_GiaHanBangVi;

    BEGIN TRY
        DECLARE @MaGD VARCHAR(16);
        EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGD OUTPUT;

        -- Trigger trg_GiaoDich_CapNhatSoDu trừ ví và ghi SoDuTruoc / SoDuSau
        INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, MaPTTT, TrangThai, MaVe, NguoiThucHien, GhiChu)
        VALUES (@MaGD, @MaVi, N'Thanh toán vé tháng', -1, @SoTien, 'SO_DU_VI', N'Thành công', @MaVe, N'Khách hàng',
                CONCAT(N'Gia hạn online ', @SoThang, N' tháng'));

        DECLARE @MaHD VARCHAR(15);
        DECLARE @HanMoi DATE;
        DECLARE @SoTienHD DECIMAL(18,2);

        EXEC dbo.sp_GiaHanVe_Core
            @MaVe = @MaVe,
            @SoThangGiaHan = @SoThang,
            @MaBaiGiaHan = NULL,
            @MaPTTT = 'SO_DU_VI',
            @KenhThanhToan = N'Online',
            @MaGD = @MaGD,
            @MaNVThu = NULL,
            @TraKetQua = 0,
            @MaHDRa = @MaHD OUTPUT,
            @HanMoiRa = @HanMoi OUTPUT,
            @SoTienRa = @SoTienHD OUTPUT;

        -- Giá trừ ví (function) phải khớp giá trên hóa đơn (lõi gia hạn): một quy tắc giá cho mọi kênh (D12)
        IF @SoTienHD <> @SoTien
        BEGIN
            THROW 50046, N'Lỗi: Lệch giá giữa số tiền trừ ví và hóa đơn gia hạn. Giao dịch đã được hủy!', 1;
        END;

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SELECT
            @MaVe AS MaVe,
            @MaGD AS MaGD,
            @MaHD AS MaHoaDon,
            @SoThang AS SoThangGiaHan,
            @SoTien AS SoTienThanhToan,
            g.SoDuTruoc,
            g.SoDuSau,
            @HanMoi AS HanMoi,
            N'Gia hạn online bằng số dư ví thành công' AS KetQua
        FROM dbo.GIAO_DICH g
        WHERE g.MaGD = @MaGD;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_KH_GiaHanBangVi;
        END;
        THROW;
    END CATCH;
END;
GO

-- C6. sp_KH_CaiDatTuDongGiaHan: Bật / tắt tự động gia hạn bằng số dư ví (cursor sp_DemoTuDongGiaHanVeThang)
CREATE OR ALTER PROCEDURE dbo.sp_KH_CaiDatTuDongGiaHan
(
    @MaVe VARCHAR(10),
    @BatTat BIT,
    @SoThang TINYINT = 1
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @ThongBao NVARCHAR(2048);
    IF dbo.f_KH_CoQuyen(@MaTK, 'VE.TUDONGGIAHAN', @MaVe) = 0
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Tài khoản không có quyền VE.TUDONGGIAHAN trên vé ', @MaVe, N'!');
        THROW 50050, @ThongBao, 1;
    END;

    IF @SoThang IS NULL OR @SoThang < 1 OR @SoThang > 12
    BEGIN
        THROW 50045, N'Lỗi: Số tháng gia hạn phải từ 1 đến 12!', 1;
    END;

    UPDATE dbo.VE_THANG
    SET TuDongGiaHan = @BatTat, SoThangTuDongGiaHan = @SoThang
    WHERE MaVe = @MaVe;

    SELECT MaVe, NgayHetHan, TuDongGiaHan, SoThangTuDongGiaHan,
           CASE WHEN TuDongGiaHan = 1 THEN N'Đã bật tự động gia hạn' ELSE N'Đã tắt tự động gia hạn' END AS KetQua
    FROM dbo.VE_THANG
    WHERE MaVe = @MaVe;
END;
GO

-- C7. sp_KH_UyQuyenVe: Chủ vé chia sẻ vé cho tài khoản khác (người nhà / kế toán) với vai trò hạn chế.
-- Kiểm tra trước các quy tắc của trg_UyQuyen_KiemTra để lỗi nghiệp vụ không hủy transaction của bên gọi.
CREATE OR ALTER PROCEDURE dbo.sp_KH_UyQuyenVe
(
    @MaVe VARCHAR(10),
    @TenDangNhapNguoiNhan VARCHAR(100),
    @MaVaiTro VARCHAR(20),
    @NgayKetThuc DATE = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @ThongBao NVARCHAR(2048);
    IF dbo.f_KH_CoQuyen(@MaTK, 'VE.UYQUYEN', @MaVe) = 0
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Tài khoản không có quyền VE.UYQUYEN trên vé ', @MaVe, N'!');
        THROW 50050, @ThongBao, 1;
    END;

    DECLARE @MaTKNhan VARCHAR(12);
    DECLARE @MaKHNhan VARCHAR(10);
    SELECT @MaTKNhan = MaTK, @MaKHNhan = MaKH FROM dbo.TAI_KHOAN_KH WHERE TenDangNhap = @TenDangNhapNguoiNhan;

    IF @MaTKNhan IS NULL
    BEGIN
        THROW 50047, N'Lỗi: Không tìm thấy tài khoản người nhận ủy quyền!', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.VAI_TRO_KH WHERE MaVaiTro = @MaVaiTro AND MaVaiTro <> 'CHU_SO_HUU')
    BEGIN
        THROW 50048, N'Lỗi: Vai trò ủy quyền không hợp lệ (chỉ THANH_VIEN hoặc XEM_LICH_SU)!', 1;
    END;

    DECLARE @MaKHChu VARCHAR(10);
    DECLARE @NgayHetHanVe DATE;
    DECLARE @TrangThaiVe NVARCHAR(20);
    SELECT @MaKHChu = MaKH, @NgayHetHanVe = NgayHetHan, @TrangThaiVe = TrangThai FROM dbo.VE_THANG WHERE MaVe = @MaVe;

    IF @MaKHNhan = @MaKHChu
    BEGIN
        THROW 50051, N'Lỗi: Không thể ủy quyền vé cho chính chủ vé!', 1;
    END;

    IF @TrangThaiVe = N'Hết hạn' OR @NgayHetHanVe < CAST(GETDATE() AS DATE)
    BEGIN
        THROW 50054, N'Lỗi: Vé đã hết hạn, không thể chia sẻ!', 1;
    END;

    -- Ủy quyền đã quá NgayKetThuc không còn tác dụng nên không tính (trạng thái vẫn là 'Hiệu lực')
    IF EXISTS (SELECT 1 FROM dbo.UY_QUYEN_VE WHERE MaVe = @MaVe AND MaTKDuocUyQuyen = @MaTKNhan AND TrangThai = N'Hiệu lực'
                 AND (NgayKetThuc IS NULL OR NgayKetThuc >= CAST(GETDATE() AS DATE)))
    BEGIN
        THROW 50049, N'Lỗi: Vé đã được chia sẻ cho tài khoản này và đang còn hiệu lực!', 1;
    END;

    IF (SELECT COUNT(*) FROM dbo.UY_QUYEN_VE WHERE MaVe = @MaVe AND TrangThai = N'Hiệu lực'
          AND (NgayKetThuc IS NULL OR NgayKetThuc >= CAST(GETDATE() AS DATE))) >= 3
    BEGIN
        THROW 50053, N'Lỗi: Mỗi vé chỉ được chia sẻ tối đa 3 tài khoản cùng lúc!', 1;
    END;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_KH_UyQuyenVe;

    BEGIN TRY
        INSERT INTO dbo.UY_QUYEN_VE (MaVe, MaTKDuocUyQuyen, MaVaiTro, NgayKetThuc, MaTKCap)
        VALUES (@MaVe, @MaTKNhan, @MaVaiTro, @NgayKetThuc, @MaTK);

        DECLARE @MaUyQuyen INT = SCOPE_IDENTITY();
        DECLARE @TenVaiTro NVARCHAR(100) = (SELECT TenVaiTro FROM dbo.VAI_TRO_KH WHERE MaVaiTro = @MaVaiTro);

        INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe)
        VALUES
            (@MaKHNhan, N'Ủy quyền', N'Bạn được chia sẻ một vé tháng',
             CONCAT(N'Vé ', @MaVe, N' đã được chia sẻ cho bạn với vai trò ', @TenVaiTro,
                    CASE WHEN @NgayKetThuc IS NULL THEN N' (không thời hạn).' ELSE CONCAT(N' đến ngày ', FORMAT(@NgayKetThuc, 'dd/MM/yyyy'), N'.') END), @MaVe),
            (@MaKHChu, N'Ủy quyền', N'Đã chia sẻ vé tháng',
             CONCAT(N'Bạn đã chia sẻ vé ', @MaVe, N' cho tài khoản ', @TenDangNhapNguoiNhan, N' với vai trò ', @TenVaiTro, N'.'), @MaVe);

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SELECT @MaUyQuyen AS MaUyQuyen, @MaVe AS MaVe, @TenDangNhapNguoiNhan AS NguoiNhan, @MaVaiTro AS MaVaiTro,
               @NgayKetThuc AS NgayKetThuc, N'Chia sẻ vé thành công' AS KetQua;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_KH_UyQuyenVe;
        END;
        THROW;
    END CATCH;
END;
GO

-- C8. sp_KH_ThuHoiUyQuyen: Chủ vé thu hồi chia sẻ (soft-delete, giữ lịch sử)
CREATE OR ALTER PROCEDURE dbo.sp_KH_ThuHoiUyQuyen
(
    @MaUyQuyen INT
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @MaVe VARCHAR(10);
    DECLARE @MaTKNhan VARCHAR(12);
    SELECT @MaVe = MaVe, @MaTKNhan = MaTKDuocUyQuyen
    FROM dbo.UY_QUYEN_VE
    WHERE MaUyQuyen = @MaUyQuyen AND TrangThai = N'Hiệu lực';

    IF @MaVe IS NULL
    BEGIN
        THROW 50049, N'Lỗi: Ủy quyền không tồn tại hoặc đã được thu hồi!', 1;
    END;

    DECLARE @ThongBao NVARCHAR(2048);
    IF dbo.f_KH_CoQuyen(@MaTK, 'VE.UYQUYEN', @MaVe) = 0
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Tài khoản không có quyền VE.UYQUYEN trên vé ', @MaVe, N'!');
        THROW 50050, @ThongBao, 1;
    END;

    UPDATE dbo.UY_QUYEN_VE SET TrangThai = N'Đã thu hồi' WHERE MaUyQuyen = @MaUyQuyen;

    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe)
    SELECT tk.MaKH, N'Ủy quyền', N'Quyền truy cập vé đã bị thu hồi',
           CONCAT(N'Chủ vé đã thu hồi quyền của bạn trên vé ', @MaVe, N'.'), @MaVe
    FROM dbo.TAI_KHOAN_KH tk
    WHERE tk.MaTK = @MaTKNhan;

    SELECT @MaUyQuyen AS MaUyQuyen, @MaVe AS MaVe, N'Đã thu hồi chia sẻ vé' AS KetQua;
END;
GO

-- C9. sp_KH_BaoMatThe: Báo mất thẻ của vé (chủ vé hoặc thành viên được ủy quyền), tái sử dụng sp_BaoMatThe
CREATE OR ALTER PROCEDURE dbo.sp_KH_BaoMatThe
(
    @MaVe VARCHAR(10)
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @ThongBao NVARCHAR(2048);
    IF dbo.f_KH_CoQuyen(@MaTK, 'VE.BAOMAT', @MaVe) = 0
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Tài khoản không có quyền VE.BAOMAT trên vé ', @MaVe, N'!');
        THROW 50050, @ThongBao, 1;
    END;

    DECLARE @MaThe VARCHAR(10);
    DECLARE @MaKHChu VARCHAR(10);
    SELECT @MaThe = MaThe, @MaKHChu = MaKH FROM dbo.VE_THANG WHERE MaVe = @MaVe;

    -- sp_BaoMatThe đổi trạng thái thẻ sang 'Mất' -> trigger trg_LogLichSuSuCo tự lập biên bản và phạt đền bù
    EXEC dbo.sp_BaoMatThe @MaTheBaoMat = @MaThe;

    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe)
    VALUES (@MaKHChu, N'Bảo mật', N'Thẻ xe đã được báo mất',
            CONCAT(N'Thẻ ', @MaThe, N' của vé ', @MaVe, N' đã bị khóa do báo mất. Vui lòng đến quầy để được cấp thẻ mới.'), @MaVe);
END;
GO

-- C10. sp_KH_DanhDauDaDoc: Đánh dấu đã đọc một thông báo (hoặc tất cả khi @MaTB = NULL)
CREATE OR ALTER PROCEDURE dbo.sp_KH_DanhDauDaDoc
(
    @MaTB BIGINT = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @MaKH VARCHAR(10) = (SELECT MaKH FROM dbo.TAI_KHOAN_KH WHERE MaTK = @MaTK);

    UPDATE dbo.THONG_BAO
    SET DaDoc = 1
    WHERE MaKH = @MaKH AND DaDoc = 0 AND (@MaTB IS NULL OR MaTB = @MaTB);

    SELECT @@ROWCOUNT AS SoThongBaoDaDanhDau;
END;
GO

-- C11. sp_KH_DanhSachUyQuyen: Ủy quyền trên vé tôi sở hữu và ủy quyền người khác cấp cho tôi.
-- Cần EXECUTE AS OWNER vì RLS trên TAI_KHOAN_KH ẩn tài khoản của người nhận / chủ vé khác.
CREATE OR ALTER PROCEDURE dbo.sp_KH_DanhSachUyQuyen
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaTK VARCHAR(12) = dbo.f_KH_MaTKPhien();
    IF @MaTK IS NULL
    BEGIN
        THROW 50042, N'Lỗi: Chưa đăng nhập cổng khách hàng hoặc phiên đã hết hạn!', 1;
    END;

    DECLARE @MaKH VARCHAR(10) = (SELECT MaKH FROM dbo.TAI_KHOAN_KH WHERE MaTK = @MaTK);
    DECLARE @HomNay DATE = CAST(GETDATE() AS DATE);

    SELECT
        uq.MaUyQuyen,
        uq.MaVe,
        vt.BienSo,
        CASE WHEN vt.MaKH = @MaKH THEN N'Tôi chia sẻ' ELSE N'Được chia sẻ cho tôi' END AS Chieu,
        CASE WHEN vt.MaKH = @MaKH THEN tkNhan.TenDangNhap ELSE NULL END AS TaiKhoanNguoiNhan,
        CASE WHEN vt.MaKH = @MaKH THEN khNhan.HoTen ELSE khChu.HoTen END AS NguoiLienQuan,
        uq.MaVaiTro,
        vtr.TenVaiTro,
        uq.NgayBatDau,
        uq.NgayKetThuc,
        CASE
            WHEN uq.TrangThai <> N'Hiệu lực' THEN uq.TrangThai
            WHEN uq.NgayKetThuc < @HomNay THEN N'Hết hạn'
            ELSE N'Hiệu lực'
        END AS TrangThai,
        uq.NgayTao
    FROM dbo.UY_QUYEN_VE uq
    INNER JOIN dbo.VE_THANG vt ON vt.MaVe = uq.MaVe
    INNER JOIN dbo.KHACH_HANG khChu ON khChu.MaKH = vt.MaKH
    INNER JOIN dbo.TAI_KHOAN_KH tkNhan ON tkNhan.MaTK = uq.MaTKDuocUyQuyen
    INNER JOIN dbo.KHACH_HANG khNhan ON khNhan.MaKH = tkNhan.MaKH
    INNER JOIN dbo.VAI_TRO_KH vtr ON vtr.MaVaiTro = uq.MaVaiTro
    WHERE vt.MaKH = @MaKH OR uq.MaTKDuocUyQuyen = @MaTK
    ORDER BY CASE WHEN uq.TrangThai = N'Hiệu lực' THEN 0 ELSE 1 END, uq.NgayTao DESC;
END;
GO

-- ====================================================================================
-- D. CALLBACK CỔNG THANH TOÁN VÀ THỦ TỤC NHÂN VIÊN (không cấp cho r_KhachHang)
-- ====================================================================================

-- D1. sp_KH_NapTien_XacNhan: Pha 2 nạp tiền - callback từ cổng thanh toán, idempotent theo MaGD / MaThamChieu.
-- Gọi lặp lại (cổng gửi callback nhiều lần) chỉ trả kết quả cũ, không cộng tiền lần nữa.
CREATE OR ALTER PROCEDURE dbo.sp_KH_NapTien_XacNhan
(
    @MaGD VARCHAR(16),
    @MaThamChieu VARCHAR(64),
    @ThanhCong BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_KH_NapTien_XacNhan;

    BEGIN TRY
        DECLARE @TrangThai NVARCHAR(20);
        DECLARE @ThamChieuCu VARCHAR(64);
        DECLARE @LoaiGD NVARCHAR(30);
        DECLARE @MaVi VARCHAR(12);
        DECLARE @SoTien DECIMAL(18,2);

        SELECT @TrangThai = TrangThai, @ThamChieuCu = MaThamChieu, @LoaiGD = LoaiGD, @MaVi = MaVi, @SoTien = SoTien
        FROM dbo.GIAO_DICH WITH (UPDLOCK, HOLDLOCK)
        WHERE MaGD = @MaGD;

        IF @TrangThai IS NULL OR @LoaiGD <> N'Nạp tiền'
        BEGIN
            THROW 50038, N'Lỗi: Giao dịch nạp tiền không tồn tại!', 1;
        END;

        DECLARE @KetQua NVARCHAR(200);

        IF @TrangThai <> N'Chờ xử lý'
        BEGIN
            -- Callback lặp lại: chỉ chấp nhận khi cùng mã tham chiếu
            IF @ThamChieuCu IS NOT NULL AND @ThamChieuCu <> @MaThamChieu
            BEGIN
                THROW 50039, N'Lỗi: Mã tham chiếu không khớp với giao dịch đã xử lý trước đó!', 1;
            END;
            SET @KetQua = N'Giao dịch đã được xử lý trước đó - bỏ qua callback lặp, không cộng tiền lần nữa';
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.GIAO_DICH WHERE MaThamChieu = @MaThamChieu AND MaGD <> @MaGD)
            BEGIN
                THROW 50039, N'Lỗi: Mã tham chiếu đã được dùng cho giao dịch khác!', 1;
            END;

            -- Chuyển trạng thái; khi 'Thành công' trigger trg_GiaoDich_CapNhatSoDu cộng tiền vào ví
            UPDATE dbo.GIAO_DICH
            SET TrangThai = CASE WHEN @ThanhCong = 1 THEN N'Thành công' ELSE N'Thất bại' END,
                MaThamChieu = @MaThamChieu,
                ThoiGianHoanTat = GETDATE(),
                GhiChu = CASE WHEN @ThanhCong = 1 THEN N'Cổng thanh toán xác nhận thành công'
                              ELSE N'Cổng thanh toán báo thất bại' END
            WHERE MaGD = @MaGD;

            INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaGD)
            SELECT vi.MaKH, N'Giao dịch',
                   CASE WHEN @ThanhCong = 1 THEN N'Nạp tiền thành công' ELSE N'Nạp tiền thất bại' END,
                   CASE WHEN @ThanhCong = 1
                        THEN CONCAT(N'Ví đã được cộng ', FORMAT(@SoTien, 'N0'), N' đồng (giao dịch ', @MaGD, N').')
                        ELSE CONCAT(N'Giao dịch nạp ', FORMAT(@SoTien, 'N0'), N' đồng (', @MaGD, N') không thành công, ví không bị trừ tiền.') END,
                   @MaGD
            FROM dbo.VI_DIEN_TU vi
            WHERE vi.MaVi = @MaVi;

            SET @KetQua = CASE WHEN @ThanhCong = 1 THEN N'Đã ghi nhận nạp tiền thành công' ELSE N'Đã ghi nhận giao dịch thất bại' END;
        END;

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SELECT g.MaGD, g.TrangThai, g.SoTien, g.MaThamChieu, g.SoDuTruoc, g.SoDuSau, vi.SoDu AS SoDuHienTai, @KetQua AS KetQua
        FROM dbo.GIAO_DICH g
        INNER JOIN dbo.VI_DIEN_TU vi ON g.MaVi = vi.MaVi
        WHERE g.MaGD = @MaGD;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_KH_NapTien_XacNhan;
        END;
        THROW;
    END CATCH;
END;
GO

-- D2. sp_NV_HoanTien: Hoàn tiền một giao dịch thanh toán vé tháng (ghi giao dịch đối ứng, không sửa sổ cái)
-- Chỉ hoàn khoản chưa gắn hóa đơn (trừ trùng / trừ nhầm): khoản đã xuất hóa đơn gia hạn thì vé đã được cộng hạn
-- và báo cáo doanh thu đã ghi nhận, hoàn tiền sẽ làm lệch cả hai.
CREATE OR ALTER PROCEDURE dbo.sp_NV_HoanTien
(
    @MaGDGoc VARCHAR(16),
    @LyDo NVARCHAR(255),
    @MaNV VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@LyDo)), N'') IS NULL
    BEGIN
        THROW 50063, N'Lỗi: Phải nhập lý do hoàn tiền!', 1;
    END;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_NV_HoanTien;

    BEGIN TRY
        DECLARE @MaVi VARCHAR(12);
        DECLARE @SoTien DECIMAL(18,2);
        DECLARE @TrangThai NVARCHAR(20);
        DECLARE @LoaiGD NVARCHAR(30);
        DECLARE @MaVe VARCHAR(10);

        SELECT @MaVi = MaVi, @SoTien = SoTien, @TrangThai = TrangThai, @LoaiGD = LoaiGD, @MaVe = MaVe
        FROM dbo.GIAO_DICH WITH (UPDLOCK, HOLDLOCK)
        WHERE MaGD = @MaGDGoc;

        IF @MaVi IS NULL
        BEGIN
            THROW 50038, N'Lỗi: Giao dịch cần hoàn tiền không tồn tại!', 1;
        END;

        IF @LoaiGD <> N'Thanh toán vé tháng' OR @TrangThai <> N'Thành công'
        BEGIN
            THROW 50063, N'Lỗi: Chỉ hoàn tiền cho giao dịch thanh toán vé tháng đang ở trạng thái Thành công!', 1;
        END;

        IF EXISTS (SELECT 1 FROM dbo.HOA_DON_VE_THANG WHERE MaGD = @MaGDGoc)
        BEGIN
            THROW 50063, N'Lỗi: Giao dịch đã xuất hóa đơn gia hạn vé nên không hoàn tiền được (chỉ hoàn khoản trừ trùng / trừ nhầm chưa gắn hóa đơn)!', 1;
        END;

        DECLARE @MaGDMoi VARCHAR(16);
        EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGDMoi OUTPUT;

        -- Giao dịch đối ứng +SoTien vào ví (trigger cập nhật số dư)
        INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, MaPTTT, TrangThai, MaVe, MaGDGoc, NguoiThucHien, MaNV, GhiChu)
        VALUES (@MaGDMoi, @MaVi, N'Hoàn tiền', 1, @SoTien, 'SO_DU_VI', N'Thành công', @MaVe, @MaGDGoc, N'Nhân viên', @MaNV, @LyDo);

        -- Giao dịch gốc chuyển 'Thành công' -> 'Đã hoàn' (bước chuyển hợp lệ duy nhất từ 'Thành công')
        UPDATE dbo.GIAO_DICH
        SET TrangThai = N'Đã hoàn',
            GhiChu = LEFT(CONCAT(ISNULL(GhiChu + N' | ', N''), N'Đã hoàn tiền bởi ', @MaGDMoi), 255)
        WHERE MaGD = @MaGDGoc;

        INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe, MaGD)
        SELECT vi.MaKH, N'Giao dịch', N'Hoàn tiền vào ví',
               CONCAT(N'Ví được hoàn ', FORMAT(@SoTien, 'N0'), N' đồng cho giao dịch ', @MaGDGoc, N'. Lý do: ', @LyDo),
               @MaVe, @MaGDMoi
        FROM dbo.VI_DIEN_TU vi
        WHERE vi.MaVi = @MaVi;

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SELECT g.MaGD, g.MaGDGoc, g.SoTien, g.SoDuTruoc, g.SoDuSau, N'Hoàn tiền thành công' AS KetQua
        FROM dbo.GIAO_DICH g
        WHERE g.MaGD = @MaGDMoi;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_NV_HoanTien;
        END;
        THROW;
    END CATCH;
END;
GO

-- D3. sp_NV_MoKhoaTaiKhoanKH: Nhân viên mở khóa tài khoản khách bị khóa do đăng nhập sai nhiều lần
CREATE OR ALTER PROCEDURE dbo.sp_NV_MoKhoaTaiKhoanKH
(
    @MaTK VARCHAR(12)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaKH VARCHAR(10);
    DECLARE @TrangThai NVARCHAR(20);
    SELECT @MaKH = MaKH, @TrangThai = TrangThai FROM dbo.TAI_KHOAN_KH WHERE MaTK = @MaTK;

    IF @MaKH IS NULL
    BEGIN
        THROW 50047, N'Lỗi: Không tìm thấy tài khoản khách hàng!', 1;
    END;

    IF @TrangThai <> N'Tạm khóa'
    BEGIN
        THROW 50047, N'Lỗi: Tài khoản không ở trạng thái Tạm khóa!', 1;
    END;

    UPDATE dbo.TAI_KHOAN_KH
    SET TrangThai = N'Hoạt động', KhoaDen = NULL, SoLanSaiLienTiep = 0
    WHERE MaTK = @MaTK;

    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung)
    VALUES (@MaKH, N'Bảo mật', N'Tài khoản đã được mở khóa',
            N'Nhân viên SmartPark đã mở khóa tài khoản của bạn. Hãy đổi mật khẩu nếu nghi ngờ có người dò mật khẩu.');

    SELECT MaTK, TenDangNhap, TrangThai, SoLanSaiLienTiep, N'Đã mở khóa tài khoản' AS KetQua
    FROM dbo.TAI_KHOAN_KH
    WHERE MaTK = @MaTK;
END;
GO

-- D4. sp_NV_NapTienTaiQuay: Nhân viên nhận tiền mặt và nạp vào ví khách (giao dịch thành công ngay)
CREATE OR ALTER PROCEDURE dbo.sp_NV_NapTienTaiQuay
(
    @MaKH VARCHAR(10),
    @SoTien DECIMAL(18,2),
    @MaNV VARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaVi VARCHAR(12);
    DECLARE @HanMuc DECIMAL(18,2);
    SELECT @MaVi = MaVi, @HanMuc = HanMucNapNgay FROM dbo.VI_DIEN_TU WHERE MaKH = @MaKH AND TrangThai = N'Hoạt động';

    IF @MaVi IS NULL
    BEGIN
        THROW 50033, N'Lỗi: Khách hàng chưa có ví hoặc ví đang bị đóng băng (khách cần tạo tài khoản cổng khách hàng trước)!', 1;
    END;

    DECLARE @ToiThieu DECIMAL(18,2) = (SELECT SoTienToiThieu FROM dbo.PHUONG_THUC_THANH_TOAN WHERE MaPTTT = 'TIEN_MAT');
    DECLARE @ThongBao NVARCHAR(2048);

    IF @SoTien IS NULL OR @SoTien <= 0 OR @SoTien < @ToiThieu
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Số tiền nạp tối thiểu tại quầy là ', FORMAT(@ToiThieu, 'N0'), N' đồng!');
        THROW 50036, @ThongBao, 1;
    END;

    IF dbo.f_KH_TongNapTrongNgay(@MaVi) + @SoTien > @HanMuc
    BEGIN
        SET @ThongBao = CONCAT(N'Lỗi: Vượt hạn mức nạp trong ngày (', FORMAT(@HanMuc, 'N0'), N' đồng)!');
        THROW 50037, @ThongBao, 1;
    END;

    DECLARE @TranNgoai INT = @@TRANCOUNT;
    IF @TranNgoai = 0
        BEGIN TRANSACTION;
    ELSE
        SAVE TRANSACTION sp_NV_NapTienTaiQuay;

    BEGIN TRY
        DECLARE @MaGD VARCHAR(16);
        EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGD OUTPUT;

        INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, MaPTTT, TrangThai, NguoiThucHien, MaNV, ThoiGianHoanTat, GhiChu)
        VALUES (@MaGD, @MaVi, N'Nạp tiền', 1, @SoTien, 'TIEN_MAT', N'Thành công', N'Nhân viên', @MaNV, GETDATE(), N'Nạp tiền mặt tại quầy');

        INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaGD)
        VALUES (@MaKH, N'Giao dịch', N'Nạp tiền tại quầy thành công',
                CONCAT(N'Ví đã được cộng ', FORMAT(@SoTien, 'N0'), N' đồng tiền mặt tại quầy (giao dịch ', @MaGD, N').'), @MaGD);

        IF @TranNgoai = 0
            COMMIT TRANSACTION;

        SELECT g.MaGD, g.SoTien, g.SoDuTruoc, g.SoDuSau, N'Nạp tiền tại quầy thành công' AS KetQua
        FROM dbo.GIAO_DICH g
        WHERE g.MaGD = @MaGD;
    END TRY
    BEGIN CATCH
        IF @TranNgoai = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION sp_NV_NapTienTaiQuay;
        END;
        THROW;
    END CATCH;
END;
GO


-- ==================== BẮT ĐẦU: 06_cursors.sql (CURSORS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 6: DATABASE CURSORS (2 CURSORS BỌC TRONG PROCEDURES ĐỂ DEMO)
-- ====================================================================================

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- CURSORS CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 8)
-- 2 cursor mới (tự động gia hạn, đối soát ví) và phiên bản mở rộng của 2 cursor vận hành
-- (ghi đè bản trong 06_cursors.sql vì cần cột / bảng mới của bước 10).
-- ====================================================================================

-- 1. sp_DemoTuDongGiaHanVeThang: Duyệt vé bật tự động gia hạn còn <= 3 ngày, gia hạn từng vé bằng số dư ví.
-- Mỗi vé chạy trong transaction riêng (hoặc SAVEPOINT riêng nếu đã có transaction bên ngoài):
-- một vé lỗi (thiếu số dư, thẻ mất, thiếu biểu phí...) chỉ hoàn tác phần của vé đó, các vé khác vẫn được gia hạn.
-- Số dư được kiểm tra trước khi ghi sổ cái để lỗi đến từ thủ tục (hoàn tác được về savepoint),
-- không phải từ trigger (trigger ROLLBACK sẽ hủy toàn bộ transaction).
CREATE OR ALTER PROCEDURE dbo.sp_DemoTuDongGiaHanVeThang
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #KetQua (
        STT INT IDENTITY(1,1) PRIMARY KEY,
        MaVe VARCHAR(10),
        MaKH VARCHAR(10),
        HoTen NVARCHAR(100),
        BienSo VARCHAR(15),
        HanCu DATE,
        SoThang INT,
        SoTien DECIMAL(18,2),
        SoDuTruoc DECIMAL(18,2),
        KetQua NVARCHAR(30),
        HanMoi DATE,
        MaGD VARCHAR(16),
        MaHoaDon VARCHAR(15),
        GhiChu NVARCHAR(400)
    );

    DECLARE @MaVe VARCHAR(10);
    DECLARE @MaKH VARCHAR(10);
    DECLARE @HoTen NVARCHAR(100);
    DECLARE @BienSo VARCHAR(15);
    DECLARE @HanCu DATE;
    DECLARE @SoThang INT;
    DECLARE @SoTien DECIMAL(18,2);
    DECLARE @MaVi VARCHAR(12);
    DECLARE @SoDu DECIMAL(18,2);
    DECLARE @MaGD VARCHAR(16);
    DECLARE @MaHD VARCHAR(15);
    DECLARE @HanMoi DATE;
    DECLARE @SoTienHD DECIMAL(18,2);
    DECLARE @ThongBao NVARCHAR(2048);
    DECLARE @TranNgoai INT;
    DECLARE @MaLoi INT;
    DECLARE @NoiDungLoi NVARCHAR(2048);

    DECLARE cur_TuDongGiaHan CURSOR LOCAL FAST_FORWARD FOR
    SELECT vt.MaVe, vt.MaKH, kh.HoTen, vt.BienSo, vt.NgayHetHan, vt.SoThangTuDongGiaHan
    FROM dbo.VE_THANG vt
    INNER JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
    WHERE vt.TuDongGiaHan = 1
      AND vt.TrangThai <> N'Tạm khóa'
      AND vt.NgayHetHan <= DATEADD(DAY, 3, CAST(GETDATE() AS DATE))
    ORDER BY vt.NgayHetHan, vt.MaVe;

    OPEN cur_TuDongGiaHan;
    FETCH NEXT FROM cur_TuDongGiaHan INTO @MaVe, @MaKH, @HoTen, @BienSo, @HanCu, @SoThang;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SoTien = dbo.f_KH_TinhPhiGiaHan(@MaVe, @SoThang);
        SET @MaVi = NULL;
        SET @SoDu = NULL;
        SET @MaGD = NULL;
        SET @MaHD = NULL;
        SET @HanMoi = NULL;

        SELECT @MaVi = MaVi, @SoDu = SoDu
        FROM dbo.VI_DIEN_TU
        WHERE MaKH = @MaKH AND TrangThai = N'Hoạt động';

        SET @TranNgoai = @@TRANCOUNT;
        IF @TranNgoai = 0
            BEGIN TRANSACTION;
        ELSE
            SAVE TRANSACTION sp_TuDongMotVe;

        BEGIN TRY
            IF @SoTien IS NULL
                THROW 50017, N'Loại xe chưa có biểu phí vé tháng tại bãi tính giá.', 1;

            IF @MaVi IS NULL
                THROW 50033, N'Khách chưa có ví hoặc ví đang bị đóng băng.', 1;

            IF @SoDu < @SoTien
            BEGIN
                SET @ThongBao = CONCAT(N'Số dư ', FORMAT(@SoDu, 'N0'), N' đồng không đủ, cần ', FORMAT(@SoTien, 'N0'), N' đồng.');
                THROW 50031, @ThongBao, 1;
            END;

            EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGD OUTPUT;

            INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, MaPTTT, TrangThai, MaVe, NguoiThucHien, GhiChu)
            VALUES (@MaGD, @MaVi, N'Thanh toán vé tháng', -1, @SoTien, 'SO_DU_VI', N'Thành công', @MaVe, N'Hệ thống',
                    CONCAT(N'Tự động gia hạn ', @SoThang, N' tháng'));

            EXEC dbo.sp_GiaHanVe_Core
                @MaVe = @MaVe,
                @SoThangGiaHan = @SoThang,
                @MaBaiGiaHan = NULL,
                @MaPTTT = 'SO_DU_VI',
                @KenhThanhToan = N'Tự động',
                @MaGD = @MaGD,
                @MaNVThu = NULL,
                @TraKetQua = 0,
                @MaHDRa = @MaHD OUTPUT,
                @HanMoiRa = @HanMoi OUTPUT,
                @SoTienRa = @SoTienHD OUTPUT;

            IF @TranNgoai = 0
                COMMIT TRANSACTION;

            INSERT INTO #KetQua (MaVe, MaKH, HoTen, BienSo, HanCu, SoThang, SoTien, SoDuTruoc, KetQua, HanMoi, MaGD, MaHoaDon, GhiChu)
            VALUES (@MaVe, @MaKH, @HoTen, @BienSo, @HanCu, @SoThang, @SoTien, @SoDu, N'Đã gia hạn', @HanMoi, @MaGD, @MaHD,
                    N'Trừ ví thành công, hóa đơn kênh Tự động (trigger đã gửi thông báo cho khách)');
        END TRY
        BEGIN CATCH
            SET @MaLoi = ERROR_NUMBER();
            SET @NoiDungLoi = ERROR_MESSAGE();

            IF @TranNgoai = 0
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            END
            ELSE IF XACT_STATE() = 1
            BEGIN
                -- Chỉ hoàn tác phần của vé đang xử lý, giữ nguyên các vé đã gia hạn trước đó
                ROLLBACK TRANSACTION sp_TuDongMotVe;
            END
            ELSE
            BEGIN
                -- Transaction bên ngoài đã hỏng: không thể tiếp tục xử lý các vé còn lại
                THROW;
            END;

            INSERT INTO #KetQua (MaVe, MaKH, HoTen, BienSo, HanCu, SoThang, SoTien, SoDuTruoc, KetQua, HanMoi, MaGD, MaHoaDon, GhiChu)
            VALUES (@MaVe, @MaKH, @HoTen, @BienSo, @HanCu, @SoThang, @SoTien, @SoDu,
                    CASE @MaLoi WHEN 50031 THEN N'Thiếu số dư' ELSE N'Lỗi' END, NULL, NULL, NULL,
                    CONCAT(N'Đã hoàn tác riêng vé này (', @MaLoi, N'): ', @NoiDungLoi));

            -- Mỗi vé tối đa 1 thông báo thất bại mỗi ngày, để chạy lại cursor không gửi trùng
            IF NOT EXISTS (
                SELECT 1 FROM dbo.THONG_BAO
                WHERE MaVe = @MaVe AND TieuDe = N'Không thể tự động gia hạn vé tháng'
                  AND ThoiGianTao >= CAST(CAST(GETDATE() AS DATE) AS DATETIME)
            )
                INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe)
                VALUES (@MaKH, N'Sắp hết hạn', N'Không thể tự động gia hạn vé tháng',
                        CONCAT(N'Vé ', @MaVe, N' (biển số ', @BienSo, N') hết hạn ngày ', FORMAT(@HanCu, 'dd/MM/yyyy'),
                               N' nhưng chưa thể tự động gia hạn: ', @NoiDungLoi, N' Vui lòng nạp thêm tiền vào ví hoặc gia hạn tại quầy.'),
                        @MaVe);
        END CATCH;

        FETCH NEXT FROM cur_TuDongGiaHan INTO @MaVe, @MaKH, @HoTen, @BienSo, @HanCu, @SoThang;
    END;

    CLOSE cur_TuDongGiaHan;
    DEALLOCATE cur_TuDongGiaHan;

    SELECT * FROM #KetQua ORDER BY STT;
    DROP TABLE #KetQua;
END;
GO

-- 2. sp_DemoDoiSoatViDienTu: Đối soát cuối ngày
--    Bước 1: chuyển giao dịch nạp tiền 'Chờ xử lý' quá 30 phút sang 'Thất bại' (cổng thanh toán không phản hồi).
--    Bước 2: cursor duyệt từng ví, so số dư với tổng sổ cái (giao dịch 'Thành công' và 'Đã hoàn').
CREATE OR ALTER PROCEDURE dbo.sp_DemoDoiSoatViDienTu
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #GiaoDichTreo (
        MaGD VARCHAR(16),
        MaVi VARCHAR(12),
        SoTien DECIMAL(18,2),
        ThoiGianTao DATETIME,
        SoPhutCho INT,
        KetQua NVARCHAR(50)
    );

    CREATE TABLE #DoiSoat (
        STT INT IDENTITY(1,1) PRIMARY KEY,
        MaVi VARCHAR(12),
        MaKH VARCHAR(10),
        HoTen NVARCHAR(100),
        SoDuHienTai DECIMAL(18,2),
        SoDuTheoSoCai DECIMAL(18,2),
        ChenhLech DECIMAL(18,2),
        SoGiaoDich INT,
        KetQua NVARCHAR(50)
    );

    UPDATE dbo.GIAO_DICH
    SET TrangThai = N'Thất bại',
        ThoiGianHoanTat = GETDATE(),
        GhiChu = N'Hết thời gian chờ cổng thanh toán (quá 30 phút)'
    OUTPUT inserted.MaGD, inserted.MaVi, inserted.SoTien, inserted.ThoiGianTao,
           DATEDIFF(MINUTE, inserted.ThoiGianTao, GETDATE()), N'Đã chuyển sang Thất bại'
    INTO #GiaoDichTreo (MaGD, MaVi, SoTien, ThoiGianTao, SoPhutCho, KetQua)
    WHERE LoaiGD = N'Nạp tiền'
      AND TrangThai = N'Chờ xử lý'
      AND ThoiGianTao < DATEADD(MINUTE, -30, GETDATE());

    DECLARE @MaVi VARCHAR(12);
    DECLARE @MaKH VARCHAR(10);
    DECLARE @HoTen NVARCHAR(100);
    DECLARE @SoDu DECIMAL(18,2);
    DECLARE @SoCai DECIMAL(18,2);
    DECLARE @SoGD INT;

    DECLARE cur_DoiSoatVi CURSOR LOCAL FAST_FORWARD FOR
    SELECT vi.MaVi, vi.MaKH, kh.HoTen, vi.SoDu
    FROM dbo.VI_DIEN_TU vi
    INNER JOIN dbo.KHACH_HANG kh ON vi.MaKH = kh.MaKH
    ORDER BY vi.MaVi;

    OPEN cur_DoiSoatVi;
    FETCH NEXT FROM cur_DoiSoatVi INTO @MaVi, @MaKH, @HoTen, @SoDu;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT
            @SoCai = ISNULL(SUM(CASE WHEN TrangThai IN (N'Thành công', N'Đã hoàn') THEN HuongTien * SoTien ELSE 0 END), 0),
            @SoGD = COUNT(*)
        FROM dbo.GIAO_DICH
        WHERE MaVi = @MaVi;

        INSERT INTO #DoiSoat (MaVi, MaKH, HoTen, SoDuHienTai, SoDuTheoSoCai, ChenhLech, SoGiaoDich, KetQua)
        VALUES (@MaVi, @MaKH, @HoTen, @SoDu, @SoCai, @SoDu - @SoCai, @SoGD,
                CASE WHEN @SoDu = @SoCai THEN N'Khớp' ELSE N'Lệch - cần kiểm tra' END);

        FETCH NEXT FROM cur_DoiSoatVi INTO @MaVi, @MaKH, @HoTen, @SoDu;
    END;

    CLOSE cur_DoiSoatVi;
    DEALLOCATE cur_DoiSoatVi;

    SELECT * FROM #DoiSoat ORDER BY STT;
    SELECT * FROM #GiaoDichTreo ORDER BY ThoiGianTao;

    DROP TABLE #DoiSoat;
    DROP TABLE #GiaoDichTreo;
END;
GO

-- 3. sp_DemoCanhBaoHanTheThang: Giữ nguyên logic gốc (khóa vé quá hạn, cảnh báo vé còn <= 3 ngày),
-- bổ sung: vé bật tự động gia hạn và ví đủ tiền -> báo "Sẽ tự động gia hạn"; ghi THONG_BAO cho khách
-- (mỗi vé tối đa 1 thông báo cùng loại mỗi ngày để chạy lại không nhân đôi).
CREATE OR ALTER PROCEDURE dbo.sp_DemoCanhBaoHanTheThang
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #KetQuaQuet (
        STT INT IDENTITY(1,1) PRIMARY KEY,
        MaVe VARCHAR(10),
        MaThe VARCHAR(10),
        BienSo VARCHAR(15),
        NgayHetHan DATE,
        SoNgayConLai INT,
        HanhDong NVARCHAR(200),
        TrangThaiVe NVARCHAR(20)
    );

    DECLARE @MaVe VARCHAR(10);
    DECLARE @MaThe VARCHAR(10);
    DECLARE @MaKH VARCHAR(10);
    DECLARE @BienSo VARCHAR(15);
    DECLARE @NgayHetHan DATE;
    DECLARE @TrangThai NVARCHAR(20);
    DECLARE @TuDongGiaHan BIT;
    DECLARE @SoThangTuDong INT;
    DECLARE @SoNgay INT;
    DECLARE @PhiGiaHan DECIMAL(18,2);
    DECLARE @SoDuVi DECIMAL(18,2);
    DECLARE @HomNay DATE = CAST(GETDATE() AS DATE);

    -- Khai báo Cursor duyệt qua toàn bộ vé tháng
    DECLARE cur_VeThang CURSOR LOCAL FAST_FORWARD FOR
    SELECT MaVe, MaThe, MaKH, BienSo, NgayHetHan, TrangThai, TuDongGiaHan, SoThangTuDongGiaHan
    FROM dbo.VE_THANG;

    OPEN cur_VeThang;
    FETCH NEXT FROM cur_VeThang INTO @MaVe, @MaThe, @MaKH, @BienSo, @NgayHetHan, @TrangThai, @TuDongGiaHan, @SoThangTuDong;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SoNgay = DATEDIFF(DAY, @HomNay, @NgayHetHan);

        IF @SoNgay < 0
        BEGIN
            -- Quá hạn: Khóa vé và khóa thẻ xe
            UPDATE dbo.VE_THANG SET TrangThai = N'Hết hạn' WHERE MaVe = @MaVe;
            UPDATE dbo.THE_XE SET TrangThai = N'Bị khóa' WHERE MaThe = @MaThe;

            INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
            VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay, N'ĐÃ QUÁ HẠN: Tự động khóa thẻ và đổi trạng thái hết hạn', N'Hết hạn');

            IF NOT EXISTS (SELECT 1 FROM dbo.THONG_BAO WHERE MaVe = @MaVe AND LoaiTB = N'Hết hạn' AND ThoiGianTao >= @HomNay)
                INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe)
                VALUES (@MaKH, N'Hết hạn', N'Vé tháng đã hết hạn',
                        CONCAT(N'Vé ', @MaVe, N' (biển số ', @BienSo, N') đã hết hạn ngày ', FORMAT(@NgayHetHan, 'dd/MM/yyyy'),
                               N'. Thẻ đã tạm khóa, vui lòng gia hạn để tiếp tục gửi xe.'), @MaVe);
        END
        ELSE IF @SoNgay <= 3
        BEGIN
            SET @PhiGiaHan = dbo.f_KH_TinhPhiGiaHan(@MaVe, @SoThangTuDong);
            SET @SoDuVi = (SELECT SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = @MaKH AND TrangThai = N'Hoạt động');

            IF @TuDongGiaHan = 1 AND @SoDuVi IS NOT NULL AND @PhiGiaHan IS NOT NULL AND @SoDuVi >= @PhiGiaHan
            BEGIN
                INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
                VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay,
                        CONCAT(N'Sẽ tự động gia hạn ', @SoThangTuDong, N' tháng bằng số dư ví (phí ', FORMAT(@PhiGiaHan, 'N0'), N' đồng)'), @TrangThai);
            END
            ELSE
            BEGIN
                -- Sắp hết hạn trong 3 ngày
                INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
                VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay, CONCAT(N'CẢNH BÁO: Sắp hết hạn trong ', @SoNgay, N' ngày. Gửi SMS/Email nhắc nộp phí.'), @TrangThai);

                IF NOT EXISTS (SELECT 1 FROM dbo.THONG_BAO WHERE MaVe = @MaVe AND LoaiTB = N'Sắp hết hạn' AND ThoiGianTao >= @HomNay)
                    INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe)
                    VALUES (@MaKH, N'Sắp hết hạn', N'Vé tháng sắp hết hạn',
                            CONCAT(N'Vé ', @MaVe, N' (biển số ', @BienSo, N') còn ', @SoNgay, N' ngày (hết hạn ',
                                   FORMAT(@NgayHetHan, 'dd/MM/yyyy'), N'). Bạn có thể gia hạn ngay trên cổng khách hàng.'), @MaVe);
            END;
        END
        ELSE
        BEGIN
            -- Hạn dùng an toàn
            INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
            VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay, N'Còn hạn an toàn', @TrangThai);
        END;

        FETCH NEXT FROM cur_VeThang INTO @MaVe, @MaThe, @MaKH, @BienSo, @NgayHetHan, @TrangThai, @TuDongGiaHan, @SoThangTuDong;
    END;

    CLOSE cur_VeThang;
    DEALLOCATE cur_VeThang;

    SELECT * FROM #KetQuaQuet ORDER BY SoNgayConLai ASC;
    DROP TABLE #KetQuaQuet;
END;
GO

-- 4. sp_DemoTongKetDoanhThuChuoi: Giữ nguyên logic gốc, tách doanh thu vé tháng theo kênh thanh toán
CREATE OR ALTER PROCEDURE dbo.sp_DemoTongKetDoanhThuChuoi
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #BaoCaoDoanhThu (
        STT INT IDENTITY(1,1) PRIMARY KEY,
        MaBai VARCHAR(10),
        TenBai NVARCHAR(100),
        DoanhThuLuot DECIMAL(18,2),
        DoanhThuThang DECIMAL(18,2),
        DoanhThuThangTaiQuay DECIMAL(18,2),
        DoanhThuThangOnline DECIMAL(18,2),
        DoanhThuThangTuDong DECIMAL(18,2),
        TongDoanhThu DECIMAL(18,2),
        DanhGiaHieuQua NVARCHAR(100)
    );

    DECLARE @MaBai VARCHAR(10);
    DECLARE @TenBai NVARCHAR(100);
    DECLARE @TienLuot DECIMAL(18,2);
    DECLARE @TienThang DECIMAL(18,2);
    DECLARE @TienQuay DECIMAL(18,2);
    DECLARE @TienOnline DECIMAL(18,2);
    DECLARE @TienTuDong DECIMAL(18,2);
    DECLARE @Tong DECIMAL(18,2);
    DECLARE @DanhGia NVARCHAR(100);

    -- Cursor duyệt qua từng bãi đỗ xe
    DECLARE cur_BaiDo CURSOR LOCAL FAST_FORWARD FOR
    SELECT MaBai, TenBai FROM dbo.BAI_DO_XE ORDER BY MaBai;

    OPEN cur_BaiDo;
    FETCH NEXT FROM cur_BaiDo INTO @MaBai, @TenBai;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @TienLuot = ISNULL(SUM(TienGui), 0)
        FROM dbo.LUOT_GUI
        WHERE MaBai = @MaBai;

        SELECT
            @TienThang = ISNULL(SUM(SoTien), 0),
            @TienQuay = ISNULL(SUM(CASE WHEN KenhThanhToan = N'Tại quầy' THEN SoTien ELSE 0 END), 0),
            @TienOnline = ISNULL(SUM(CASE WHEN KenhThanhToan = N'Online' THEN SoTien ELSE 0 END), 0),
            @TienTuDong = ISNULL(SUM(CASE WHEN KenhThanhToan = N'Tự động' THEN SoTien ELSE 0 END), 0)
        FROM dbo.HOA_DON_VE_THANG
        WHERE MaBai = @MaBai;

        SET @Tong = @TienLuot + @TienThang;

        IF @Tong >= 10000000
            SET @DanhGia = N'Hiệu quả rất cao (Doanh thu > 10 triệu)';
        ELSE IF @Tong >= 2000000
            SET @DanhGia = N'Hiệu quả tốt';
        ELSE
            SET @DanhGia = N'Cần đẩy mạnh khai thác thêm lượt gửi';

        INSERT INTO #BaoCaoDoanhThu (MaBai, TenBai, DoanhThuLuot, DoanhThuThang, DoanhThuThangTaiQuay, DoanhThuThangOnline, DoanhThuThangTuDong, TongDoanhThu, DanhGiaHieuQua)
        VALUES (@MaBai, @TenBai, @TienLuot, @TienThang, @TienQuay, @TienOnline, @TienTuDong, @Tong, @DanhGia);

        FETCH NEXT FROM cur_BaiDo INTO @MaBai, @TenBai;
    END;

    CLOSE cur_BaiDo;
    DEALLOCATE cur_BaiDo;

    SELECT * FROM #BaoCaoDoanhThu ORDER BY TongDoanhThu DESC;
    DROP TABLE #BaoCaoDoanhThu;
END;
GO


-- ==================== BẮT ĐẦU: 07_views.sql (VIEWS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 7: DATABASE VIEWS (21 VIEWS)
-- PHẦN A: 3 views vận hành Blueprint V6 | PHẦN B: 5 views báo cáo BI
-- PHẦN C: 4 views bốt kiểm soát cổng vào/ra | PHẦN D: 3 views sơ đồ bãi xe realtime
-- PHẦN E: 6 views tổng hợp cho quản lý chuỗi bãi xe
-- ====================================================================================

-- ====================================================================================
-- PHẦN A: 3 VIEWS VẬN HÀNH THỜI GIAN THỰC (THEO THIẾT KẾ BLUEPRINT V6)
-- ====================================================================================

-- 1. View v_SodoOdoRealtime: Sơ đồ ô đỗ xe thời gian thực kèm thông tin xe đang chiếm chỗ
CREATE OR ALTER VIEW dbo.v_SodoOdoRealtime
AS
SELECT 
    v.MaBai,
    b.TenBai,
    v.MaViTri,
    v.KhuVuc,
    v.TrangThai,
    l.TenLoai,
    lg.BienSo,
    lg.ThoiGianVao
FROM dbo.VI_TRI_DO v
INNER JOIN dbo.BAI_DO_XE b ON v.MaBai = b.MaBai
INNER JOIN dbo.LOAI_XE l ON v.MaLoaiXe = l.MaLoaiXe AND v.MaBai = l.MaBai
LEFT JOIN dbo.LUOT_GUI lg ON v.MaViTri = lg.MaViTri AND lg.ThoiGianRa IS NULL;
GO

-- 2. View v_Xedangtrongbai: Danh sách các xe hiện diện trong bãi chưa làm thủ tục Check-Out
CREATE OR ALTER VIEW dbo.v_Xedangtrongbai
AS
SELECT 
    lg.MaLuot,
    lg.MaBai,
    b.TenBai,
    lg.MaThe,
    lg.BienSo,
    lg.MaViTri,
    lg.ThoiGianVao,
    t.LoaiThe
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
WHERE lg.ThoiGianRa IS NULL;
GO

-- 3. View v_DanhsachveThangsaphethan: Danh sách vé tháng còn dưới hoặc bằng 3 ngày sử dụng
CREATE OR ALTER VIEW dbo.v_DanhsachveThangsaphethan
AS
SELECT 
    vt.MaVe,
    vt.MaThe,
    kh.HoTen,
    kh.SDT,
    vt.BienSo,
    vt.NgayHetHan,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) AS SongayConLai,
    vt.MaBaiApDung
FROM dbo.VE_THANG vt
INNER JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) BETWEEN 0 AND 3
  AND vt.TrangThai = N'Hoạt động';
GO


-- ====================================================================================
-- PHẦN B: 5 VIEWS BÁO CÁO THỐNG KÊ QUẢN TRỊ & KINH DOANH (BI ANALYTICS)
-- ====================================================================================

-- 4. View vw_Report_CongSuatBaiDo: Giám sát tỷ lệ lấp đầy và chỗ trống theo từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_CongSuatBaiDo
AS
SELECT 
    bd.MaBai,
    bd.TenBai,
    bd.SucChua,
    bd.SoLuongHienTai,
    (bd.SucChua - bd.SoLuongHienTai) AS SoChoTrong,
    CAST(ROUND(CAST(bd.SoLuongHienTai AS FLOAT) * 100.0 / CAST(bd.SucChua AS FLOAT), 2) AS DECIMAL(5,2)) AS TyLeLapDayPercent
FROM dbo.BAI_DO_XE bd;
GO

-- 5. vw_Report_DoanhThuTheoBai: thêm DoanhThuThangTaiQuay, DoanhThuThangOnline (online + tự động)
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoBai
AS
SELECT 
    bd.MaBai,
    bd.TenBai,
    ISNULL(sub_luot.TienLuot, 0) AS DoanhThuLuot,
    ISNULL(sub_thang.TienThang, 0) AS DoanhThuThang,
    (ISNULL(sub_luot.TienLuot, 0) + ISNULL(sub_thang.TienThang, 0)) AS TongDoanhThu,
    -- Tách doanh thu vé tháng theo kênh thanh toán
    ISNULL(sub_thang.TienThangTaiQuay, 0) AS DoanhThuThangTaiQuay,
    ISNULL(sub_thang.TienThangOnline, 0) AS DoanhThuThangOnline
FROM dbo.BAI_DO_XE bd
LEFT JOIN (
    SELECT MaBai, SUM(TienGui) AS TienLuot
    FROM dbo.LUOT_GUI
    GROUP BY MaBai
) sub_luot ON bd.MaBai = sub_luot.MaBai
LEFT JOIN (
    SELECT MaBai,
           SUM(SoTien) AS TienThang,
           SUM(CASE WHEN KenhThanhToan = N'Tại quầy' THEN SoTien ELSE 0 END) AS TienThangTaiQuay,
           SUM(CASE WHEN KenhThanhToan IN (N'Online', N'Tự động') THEN SoTien ELSE 0 END) AS TienThangOnline
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaBai
) sub_thang ON bd.MaBai = sub_thang.MaBai;
GO

-- 6. View vw_Report_XeDangDoHienTai: Danh sách phương tiện đang hiện diện trong toàn chuỗi
CREATE OR ALTER VIEW dbo.vw_Report_XeDangDoHienTai
AS
SELECT 
    lg.MaLuot,
    lg.MaThe,
    tx.LoaiThe,
    lg.BienSo,
    lg.ThoiGianVao,
    DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) AS SoPhutDaDo,
    lg.MaViTri,
    vt.KhuVuc,
    lx.TenLoai AS LoaiPhuongTien,
    bd.TenBai
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.THE_XE tx ON lg.MaThe = tx.MaThe
INNER JOIN dbo.VI_TRI_DO vt ON lg.MaViTri = vt.MaViTri
INNER JOIN dbo.LOAI_XE lx ON vt.MaLoaiXe = lx.MaLoaiXe AND vt.MaBai = lx.MaBai
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
WHERE lg.ThoiGianRa IS NULL;
GO

-- 7. View vw_Report_VeThangSapHetHan: Danh sách vé tháng sắp hoặc đã hết hạn
CREATE OR ALTER VIEW dbo.vw_Report_VeThangSapHetHan
AS
SELECT 
    vt.MaVe,
    kh.HoTen AS HoTenKhachHang,
    kh.SDT,
    vt.BienSo,
    vt.MaLoaiXe,
    vt.NgayHetHan,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) AS SoNgayConLai,
    vt.TrangThai AS TrangThaiVe,
    vt.MaBaiApDung
FROM dbo.VE_THANG vt
INNER JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) <= 7;
GO

-- 8. View vw_Report_NhatKySuCo: Thống kê các sự cố an ninh và tiền phạt
CREATE OR ALTER VIEW dbo.vw_Report_NhatKySuCo
AS
SELECT 
    sc.MaSuCo,
    sc.MaThe,
    sc.BienSo,
    sc.ThoiGianSuCo,
    sc.MoTa,
    sc.TienPhat,
    sc.TrangThaiXuLy,
    bd.TenBai
FROM dbo.LICHSU_SU_CO sc
INNER JOIN dbo.BAI_DO_XE bd ON sc.MaBai = bd.MaBai;
GO


-- ====================================================================================
-- PHẦN C: 4 VIEWS PHỤC VỤ BỐT KIỂM SOÁT CỔNG VÀO / RA (GATE CONTROL KIOSK)
-- Mục tiêu: Bảo vệ trực cổng chỉ cần quét mã thẻ là có đủ dữ liệu quyết định
-- mở barrier (cho vào / cho ra), số tiền tạm tính và cảnh báo nghiệp vụ kèm theo.
-- ====================================================================================

-- 9. v_BotCong_TraCuuThe: thêm CoTaiKhoanOnline, TuDongGiaHan; gợi ý tự gia hạn online khi vé sắp hết hạn
CREATE OR ALTER VIEW dbo.v_BotCong_TraCuuThe
AS
WITH TheHienTai AS (
    SELECT
        t.MaThe,
        t.LoaiThe,
        t.TrangThai AS TrangThaiThe,
        t.NgayCap,
        t.MaBai AS MaBaiSoHuuThe,
        vt.MaVe,
        vt.MaKH,
        vt.BienSo AS BienSoDangKy,
        vt.MaLoaiXe AS MaLoaiXeDangKy,
        vt.NgayHetHan,
        vt.TrangThai AS TrangThaiVeThang,
        vt.MaBaiApDung,
        vt.TuDongGiaHan,
        -- Khách có tài khoản cổng khách hàng thì bảo vệ có thể hướng dẫn tự gia hạn online
        CAST(CASE WHEN tkkh.MaTK IS NULL THEN 0 ELSE 1 END AS BIT) AS CoTaiKhoanOnline,
        -- Vé tháng có MaBaiApDung không trỏ tới một bãi cụ thể (ví dụ 'ALL') là vé dùng chung toàn chuỗi
        CAST(CASE WHEN vt.MaVe IS NOT NULL AND bva.MaBai IS NULL THEN 1 ELSE 0 END AS BIT) AS VeApDungToanChuoi,
        kh.HoTen AS HoTenKhachHang,
        kh.SDT AS SDTKhachHang,
        lg.MaLuot AS MaLuotDangMo,
        lg.BienSo AS BienSoDangGui,
        lg.MaViTri AS MaViTriDangDo,
        lg.ThoiGianVao,
        -- Bãi kiểm soát lượt quét kế tiếp: ưu tiên bãi xe đang đỗ, kế đến bãi áp dụng vé tháng
        -- (chỉ khi trỏ tới một bãi cụ thể, nên vé toàn chuỗi 'ALL' sẽ rơi về bãi sở hữu thẻ)
        COALESCE(lg.MaBai, bva.MaBai, t.MaBai) AS MaBaiKiemSoat
    FROM dbo.THE_XE t
    OUTER APPLY dbo.f_VeHienHanhCuaThe(t.MaThe) vt   -- 1 dòng / thẻ kể cả thẻ đã cấp lại cho vé mới
    LEFT JOIN dbo.BAI_DO_XE bva ON vt.MaBaiApDung = bva.MaBai
    LEFT JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
    LEFT JOIN dbo.TAI_KHOAN_KH tkkh ON vt.MaKH = tkkh.MaKH
    OUTER APPLY (
        SELECT TOP 1 l.MaLuot, l.BienSo, l.MaViTri, l.ThoiGianVao, l.MaBai
        FROM dbo.LUOT_GUI l
        WHERE l.MaThe = t.MaThe AND l.ThoiGianRa IS NULL
        ORDER BY l.ThoiGianVao DESC, l.MaLuot DESC
    ) lg
)
SELECT
    th.MaThe,
    th.LoaiThe,
    th.TrangThaiThe,
    th.NgayCap,
    th.MaBaiSoHuuThe,
    th.MaBaiKiemSoat,
    b.TenBai AS TenBaiKiemSoat,
    b.SucChua,
    b.SoLuongHienTai,
    (b.SucChua - b.SoLuongHienTai) AS SoChoTrong,
    -- Hồ sơ vé tháng gắn với thẻ (NULL nếu là thẻ lượt vãng lai)
    th.MaVe,
    th.MaKH,
    th.HoTenKhachHang,
    th.SDTKhachHang,
    th.BienSoDangKy,
    th.MaLoaiXeDangKy,
    th.NgayHetHan,
    th.TrangThaiVeThang,
    th.MaBaiApDung,
    th.VeApDungToanChuoi,
    CASE WHEN th.MaVe IS NULL THEN NULL
         ELSE DATEDIFF(DAY, CAST(GETDATE() AS DATE), th.NgayHetHan) END AS SoNgayConLaiVe,
    -- Lượt gửi đang mở (xe còn trong bãi, chưa check-out)
    th.MaLuotDangMo,
    th.BienSoDangGui,
    th.MaViTriDangDo,
    th.ThoiGianVao,
    CAST(CASE WHEN th.MaLuotDangMo IS NULL THEN 0 ELSE 1 END AS BIT) AS DangTrongBai,
    CASE WHEN th.MaLuotDangMo IS NULL THEN NULL
         ELSE DATEDIFF(MINUTE, th.ThoiGianVao, GETDATE()) END AS SoPhutDaDo,
    -- Quyết định vận hành barrier tại bốt cổng
    CASE WHEN th.MaLuotDangMo IS NULL THEN N'Vào' ELSE N'Ra' END AS ChieuQuetKeTiep,
    CAST(CASE
        WHEN th.MaLuotDangMo IS NOT NULL THEN 1
        WHEN th.TrangThaiThe <> N'Hoạt động' THEN 0
        WHEN th.LoaiThe = N'Tháng' AND th.MaVe IS NULL THEN 0
        WHEN th.LoaiThe = N'Tháng' AND (th.TrangThaiVeThang <> N'Hoạt động' OR th.NgayHetHan < CAST(GETDATE() AS DATE)) THEN 0
        WHEN b.SoLuongHienTai >= b.SucChua THEN 0
        ELSE 1
    END AS BIT) AS ChoPhepQuet,
    CASE
        WHEN th.MaLuotDangMo IS NOT NULL THEN NULL
        WHEN th.TrangThaiThe = N'Mất' THEN N'Thẻ đã được báo mất - trigger trg_KiemTraCheckIn sẽ chặn check-in (lỗi 50002)'
        WHEN th.TrangThaiThe = N'Bị khóa' THEN N'Thẻ đang bị khóa - trigger trg_KiemTraCheckIn sẽ chặn check-in (lỗi 50002)'
        WHEN th.LoaiThe = N'Tháng' AND th.MaVe IS NULL THEN N'Thẻ tháng chưa gắn hợp đồng vé tháng nào - yêu cầu về quầy đăng ký'
        WHEN th.LoaiThe = N'Tháng' AND th.NgayHetHan < CAST(GETDATE() AS DATE) THEN N'Vé tháng đã hết hạn - trigger trg_ChanSuDungVeHetHan sẽ chặn check-in (lỗi 50003)'
        WHEN th.LoaiThe = N'Tháng' AND th.TrangThaiVeThang <> N'Hoạt động' THEN N'Vé tháng đang ở trạng thái ' + th.TrangThaiVeThang + N' - yêu cầu về quầy xử lý'
        WHEN b.SoLuongHienTai >= b.SucChua THEN N'Bãi đã đầy công suất - trigger trg_KiemTraCheckIn sẽ chặn check-in (lỗi 50001)'
        ELSE NULL
    END AS LyDoTuChoi,
    CASE
        WHEN th.MaLuotDangMo IS NOT NULL AND th.TrangThaiThe <> N'Hoạt động'
            THEN N'Thẻ không còn hiệu lực nhưng xe vẫn trong bãi - xác minh giấy tờ và lập biên bản sự cố trước khi cho ra'
        WHEN th.MaLuotDangMo IS NOT NULL AND th.LoaiThe = N'Tháng' AND th.NgayHetHan < CAST(GETDATE() AS DATE)
            THEN N'Vé tháng hết hạn trong lúc xe đang đỗ - nhắc khách gia hạn ngay khi ra cổng'
        WHEN th.MaLuotDangMo IS NOT NULL AND DATEDIFF(HOUR, th.ThoiGianVao, GETDATE()) >= 24
            THEN N'Xe đã đỗ quá 24 giờ - kiểm tra phương tiện bỏ quên'
        WHEN th.MaLuotDangMo IS NULL AND th.MaVe IS NOT NULL
             AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), th.NgayHetHan) BETWEEN 0 AND 3
            THEN CASE WHEN th.CoTaiKhoanOnline = 1
                      THEN N'Vé tháng sắp hết hạn - khách có tài khoản online, hướng dẫn tự gia hạn trên cổng khách hàng'
                      ELSE N'Vé tháng sắp hết hạn - nhắc khách đóng phí gia hạn' END
        ELSE NULL
    END AS GhiChuCanhBao,
    -- Cờ phục vụ thẻ "Hồ sơ thẻ quét" trên màn hình bốt cổng
    th.CoTaiKhoanOnline,
    CAST(ISNULL(th.TuDongGiaHan, 0) AS BIT) AS TuDongGiaHan
FROM TheHienTai th
LEFT JOIN dbo.BAI_DO_XE b ON th.MaBaiKiemSoat = b.MaBai;
GO
-- 10. View v_BotCong_XeChoRa: Màn hình check-out tại bốt cổng ra
--     Liệt kê toàn bộ xe đang trong bãi kèm số phút đỗ, số block giờ tính phí và tiền tạm tính
--     theo đúng công thức của f_TinhTienGuiXe (miễn phí 15 phút đầu, làm tròn lên block giờ)
--     và đúng chính sách của sp_XeRaBai (xe thẻ tháng miễn phí lượt gửi).
CREATE OR ALTER VIEW dbo.v_BotCong_XeChoRa
AS
SELECT
    lg.MaLuot,
    lg.MaBai,
    b.TenBai,
    lg.MaThe,
    t.LoaiThe,
    t.TrangThai AS TrangThaiThe,
    lg.BienSo AS BienSoLucVao,
    lg.MaViTri,
    v.KhuVuc,
    v.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    lx.DonGiaGio,
    lg.ThoiGianVao,
    GETDATE() AS ThoiGianQuetRa,
    DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) AS SoPhutDaDo,
    CAST(ROUND(DATEDIFF(SECOND, lg.ThoiGianVao, GETDATE()) / 3600.0, 2) AS DECIMAL(10,2)) AS SoGioDaDo,
    CAST(CASE WHEN DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) <= 15 THEN 0
              ELSE CEILING(CAST(DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) AS FLOAT) / 60.0)
         END AS INT) AS SoBlockGioTinhPhi,
    CASE WHEN t.LoaiThe = N'Tháng' THEN CAST(0 AS DECIMAL(18,2))
         ELSE dbo.f_TinhTienGuiXe(lg.ThoiGianVao, GETDATE(), v.MaLoaiXe, lg.MaBai)
    END AS TienTamTinh,
    CASE WHEN t.LoaiThe = N'Tháng' THEN N'Miễn phí - xe vé tháng'
         WHEN DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) <= 15 THEN N'Miễn phí - đỗ dưới 15 phút'
         ELSE N'Thu phí gửi lượt'
    END AS ChinhSachThanhToan,
    -- Hồ sơ vé tháng để bốt cổng đối chiếu chủ xe
    vt.MaVe,
    kh.HoTen AS HoTenKhachHang,
    kh.SDT AS SDTKhachHang,
    vt.BienSoDangKy,
    vt.NgayHetHan,
    vt.TrangThaiVeThang,
    CAST(CASE WHEN vt.MaVe IS NOT NULL AND vt.BienSoDangKy <> lg.BienSo THEN 1 ELSE 0 END AS BIT) AS CanhBaoLechBienSo,
    CASE
        WHEN t.TrangThai <> N'Hoạt động'
            THEN N'Thẻ đang ở trạng thái ' + t.TrangThai + N' - xác minh giấy tờ và lập biên bản sự cố trước khi mở barrier'
        WHEN vt.MaVe IS NOT NULL AND vt.BienSoDangKy <> lg.BienSo
            THEN N'Biển số lúc vào khác biển số đăng ký vé tháng (' + vt.BienSoDangKy + N') - kiểm tra an ninh'
        WHEN vt.MaVe IS NOT NULL AND vt.NgayHetHan < CAST(GETDATE() AS DATE)
            THEN N'Vé tháng đã hết hạn - nhắc khách gia hạn trước lượt gửi kế tiếp'
        WHEN DATEDIFF(HOUR, lg.ThoiGianVao, GETDATE()) >= 24
            THEN N'Xe đỗ quá 24 giờ - kiểm tra phương tiện bỏ quên và báo quản lý bãi'
        ELSE NULL
    END AS GhiChuCanhBao
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
OUTER APPLY (
    SELECT x.MaVe, x.MaKH, x.BienSo AS BienSoDangKy, x.NgayHetHan, x.TrangThai AS TrangThaiVeThang
    FROM dbo.VE_THANG x
    WHERE x.MaThe = lg.MaThe AND t.LoaiThe = N'Tháng'
) vt
LEFT JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE lg.ThoiGianRa IS NULL;
GO

-- 11. View v_BotCong_NhatKyVaoRa: Bảng điện tử nhật ký 200 sự kiện vào/ra mới nhất
--     Mỗi lượt gửi được trải thành 2 dòng sự kiện (Vào và Ra) để bốt cổng và phòng bảo vệ
--     theo dõi dòng xe qua barrier theo trục thời gian giống màn hình camera giám sát.
CREATE OR ALTER VIEW dbo.v_BotCong_NhatKyVaoRa
AS
SELECT TOP (200)
    sk.MaLuot,
    sk.MaBai,
    sk.TenBai,
    sk.ChieuDiChuyen,
    sk.ThoiGianSuKien,
    sk.MaThe,
    sk.LoaiThe,
    sk.BienSo,
    sk.MaViTri,
    sk.KhuVuc,
    sk.LoaiPhuongTien,
    sk.SoPhutLuuBai,
    sk.SoTienThu,
    sk.TrangThaiLuot
FROM (
    -- Sự kiện xe qua cổng vào
    SELECT
        lg.MaLuot,
        lg.MaBai,
        b.TenBai,
        N'Vào' AS ChieuDiChuyen,
        lg.ThoiGianVao AS ThoiGianSuKien,
        lg.MaThe,
        t.LoaiThe,
        lg.BienSo,
        lg.MaViTri,
        v.KhuVuc,
        lx.TenLoai AS LoaiPhuongTien,
        CAST(NULL AS INT) AS SoPhutLuuBai,
        CAST(NULL AS DECIMAL(18,2)) AS SoTienThu,
        CASE WHEN lg.ThoiGianRa IS NULL THEN N'Đang trong bãi' ELSE N'Đã ra khỏi bãi' END AS TrangThaiLuot
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
    INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
    INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
    INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai

    UNION ALL

    -- Sự kiện xe qua cổng ra kèm số tiền thực thu
    SELECT
        lg.MaLuot,
        lg.MaBai,
        b.TenBai,
        N'Ra' AS ChieuDiChuyen,
        lg.ThoiGianRa AS ThoiGianSuKien,
        lg.MaThe,
        t.LoaiThe,
        lg.BienSo,
        lg.MaViTri,
        v.KhuVuc,
        lx.TenLoai AS LoaiPhuongTien,
        DATEDIFF(MINUTE, lg.ThoiGianVao, lg.ThoiGianRa) AS SoPhutLuuBai,
        lg.TienGui AS SoTienThu,
        N'Đã ra khỏi bãi' AS TrangThaiLuot
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
    INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
    INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
    INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
    WHERE lg.ThoiGianRa IS NOT NULL
) sk
ORDER BY sk.ThoiGianSuKien DESC, sk.MaLuot DESC;
GO

-- 12. View v_BotCong_BangDenCong: Bảng đèn tín hiệu CÒN CHỖ / HẾT CHỖ đặt tại cổng vào
--     Mỗi dòng là một cặp (bãi đỗ x loại phương tiện): số ô trống thực tế, ô đỗ gợi ý sẽ
--     được f_TimSlotTrong cấp phát, biểu phí niêm yết và màu đèn barrier tương ứng.
CREATE OR ALTER VIEW dbo.v_BotCong_BangDenCong
AS
SELECT
    b.MaBai,
    b.TenBai,
    b.SucChua,
    b.SoLuongHienTai,
    (b.SucChua - b.SoLuongHienTai) AS SoChoTrongBai,
    lx.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    lx.DonGiaGio,
    lx.GiaVeThang,
    ISNULL(o.TongODo, 0) AS TongODoTheoLoai,
    ISNULL(o.SoODoDaDo, 0) AS SoODoDaDo,
    ISNULL(o.SoODoTrong, 0) AS SoODoTrong,
    CASE WHEN ISNULL(o.TongODo, 0) = 0 THEN CAST(0 AS DECIMAL(5,2))
         ELSE CAST(ROUND(o.SoODoDaDo * 100.0 / o.TongODo, 2) AS DECIMAL(5,2))
    END AS TyLeLapDayTheoLoai,
    dbo.f_TimSlotTrong(b.MaBai, lx.MaLoaiXe) AS MaViTriGoiY,
    CAST(CASE WHEN b.SoLuongHienTai >= b.SucChua THEN 0
              WHEN ISNULL(o.SoODoTrong, 0) = 0 THEN 0
              ELSE 1
         END AS BIT) AS ChoPhepVaoCong,
    CASE WHEN b.SoLuongHienTai >= b.SucChua THEN N'ĐỎ - BÃI ĐẦY, ĐIỀU PHỐI SANG BÃI KHÁC'
         WHEN ISNULL(o.SoODoTrong, 0) = 0 THEN N'ĐỎ - HẾT Ô ĐỖ DÀNH CHO LOẠI XE NÀY'
         WHEN ISNULL(o.SoODoTrong, 0) <= 2 THEN N'VÀNG - CÒN ÍT Ô ĐỖ'
         ELSE N'XANH - CÒN CHỖ, MỜI XE VÀO'
    END AS DenTinHieuCong
FROM dbo.BAI_DO_XE b
INNER JOIN dbo.LOAI_XE lx ON b.MaBai = lx.MaBai
OUTER APPLY (
    SELECT
        COUNT(*) AS TongODo,
        SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1 ELSE 0 END) AS SoODoDaDo,
        SUM(CASE WHEN v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoTrong
    FROM dbo.VI_TRI_DO v
    WHERE v.MaBai = lx.MaBai AND v.MaLoaiXe = lx.MaLoaiXe
) o;
GO


-- ====================================================================================
-- PHẦN D: 3 VIEWS PHỤC VỤ SƠ ĐỒ BÃI XE THỜI GIAN THỰC (REALTIME PARKING MAP)
-- Mục tiêu: Màn hình /map chỉ cần SELECT từ 3 view dưới đây là vẽ được đầy đủ
-- lưới ô đỗ, thanh tổng hợp theo khu vực và thẻ tổng quan công suất từng bãi.
-- ====================================================================================

-- 13. View v_SodoBai_ODoChiTiet: Chi tiết từng ô đỗ trên sơ đồ mặt bằng thời gian thực
--     Bảo đảm đúng 1 dòng / 1 ô đỗ (dùng OUTER APPLY TOP 1 nên không nhân dòng khi dữ liệu lỗi),
--     kèm phương tiện đang chiếm chỗ, thời gian lưu bãi, tiền tạm tính, hồ sơ chủ xe vé tháng
--     và cờ CanhBaoLechDuLieu khi trạng thái ô đỗ không khớp với lượt gửi đang mở.
CREATE OR ALTER VIEW dbo.v_SodoBai_ODoChiTiet
AS
SELECT
    v.MaBai,
    b.TenBai,
    v.KhuVuc,
    v.MaViTri,
    v.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    lx.DonGiaGio,
    v.TrangThai AS TrangThaiODo,
    ROW_NUMBER() OVER (PARTITION BY v.MaBai ORDER BY v.KhuVuc, v.MaViTri) AS ThuTuHienThi,
    lg.MaLuot,
    lg.MaThe,
    t.LoaiThe,
    lg.BienSo,
    lg.ThoiGianVao,
    CASE WHEN lg.MaLuot IS NULL THEN NULL
         ELSE DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) END AS SoPhutDaDo,
    CASE WHEN lg.MaLuot IS NULL THEN NULL
         ELSE CAST(ROUND(DATEDIFF(SECOND, lg.ThoiGianVao, GETDATE()) / 3600.0, 2) AS DECIMAL(10,2)) END AS SoGioDaDo,
    CASE WHEN lg.MaLuot IS NULL THEN NULL
         WHEN t.LoaiThe = N'Tháng' THEN CAST(0 AS DECIMAL(18,2))
         ELSE dbo.f_TinhTienGuiXe(lg.ThoiGianVao, GETDATE(), v.MaLoaiXe, v.MaBai)
    END AS TienTamTinh,
    vt.MaVe,
    kh.HoTen AS HoTenKhachHang,
    kh.SDT AS SDTKhachHang,
    vt.NgayHetHan,
    CASE WHEN v.TrangThai = N'Đã đỗ' AND lg.MaLuot IS NOT NULL THEN N'Đã đỗ'
         WHEN v.TrangThai = N'Trống' AND lg.MaLuot IS NULL THEN N'Trống'
         ELSE N'Lệch dữ liệu'
    END AS TrangThaiHienThi,
    CAST(CASE WHEN (v.TrangThai = N'Đã đỗ' AND lg.MaLuot IS NULL)
                OR (v.TrangThai = N'Trống' AND lg.MaLuot IS NOT NULL)
              THEN 1 ELSE 0 END AS BIT) AS CanhBaoLechDuLieu
FROM dbo.VI_TRI_DO v
INNER JOIN dbo.BAI_DO_XE b ON v.MaBai = b.MaBai
INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
OUTER APPLY (
    SELECT TOP 1 l.MaLuot, l.MaThe, l.BienSo, l.ThoiGianVao
    FROM dbo.LUOT_GUI l
    WHERE l.MaViTri = v.MaViTri AND l.ThoiGianRa IS NULL
    ORDER BY l.ThoiGianVao DESC, l.MaLuot DESC
) lg
LEFT JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
OUTER APPLY (SELECT h.* FROM dbo.f_VeHienHanhCuaThe(t.MaThe) h WHERE t.LoaiThe = N'Tháng') vt
LEFT JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH;
GO

-- 14. View v_SodoBai_TongHopKhuVuc: Thanh tổng hợp theo từng khu vực / tầng trên sơ đồ
--     Cho biết mỗi khu vực còn bao nhiêu ô trống, chia theo từng loại phương tiện,
--     giúp bảo vệ hướng dẫn khách đi đúng tầng thay vì chạy vòng quanh bãi.
CREATE OR ALTER VIEW dbo.v_SodoBai_TongHopKhuVuc
AS
SELECT
    v.MaBai,
    b.TenBai,
    v.KhuVuc,
    COUNT(*) AS TongODo,
    SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1 ELSE 0 END) AS SoODoDaDo,
    SUM(CASE WHEN v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoTrong,
    CAST(ROUND(SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS TyLeLapDayPercent,
    SUM(CASE WHEN v.MaLoaiXe = 'XM' THEN 1 ELSE 0 END) AS SoODoXeMay,
    SUM(CASE WHEN v.MaLoaiXe = 'XM' AND v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoXeMayTrong,
    SUM(CASE WHEN v.MaLoaiXe = 'OT' THEN 1 ELSE 0 END) AS SoODoOTo,
    SUM(CASE WHEN v.MaLoaiXe = 'OT' AND v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoOToTrong,
    SUM(CASE WHEN v.MaLoaiXe = 'XD' THEN 1 ELSE 0 END) AS SoODoXeDap,
    SUM(CASE WHEN v.MaLoaiXe = 'XD' AND v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoXeDapTrong,
    MIN(v.MaViTri) AS ODoDauKhuVuc,
    MAX(v.MaViTri) AS ODoCuoiKhuVuc
FROM dbo.VI_TRI_DO v
INNER JOIN dbo.BAI_DO_XE b ON v.MaBai = b.MaBai
GROUP BY v.MaBai, b.TenBai, v.KhuVuc;
GO

-- 15. View v_SodoBai_TongQuanBai: Thẻ tổng quan công suất đặt trên đầu trang sơ đồ
--     Đối chiếu bộ đếm BAI_DO_XE.SoLuongHienTai (do trigger trg_DongBoTrangThaiSlot duy trì)
--     với số lượt gửi đang mở thực tế trong LUOT_GUI, kèm nhịp xe vào/ra và doanh thu lượt trong ngày.
CREATE OR ALTER VIEW dbo.v_SodoBai_TongQuanBai
AS
SELECT
    b.MaBai,
    b.TenBai,
    b.DiaChi,
    b.SucChua,
    b.SoLuongHienTai,
    (b.SucChua - b.SoLuongHienTai) AS SoChoTrong,
    CAST(ROUND(b.SoLuongHienTai * 100.0 / b.SucChua, 2) AS DECIMAL(5,2)) AS TyLeLapDayPercent,
    ISNULL(od.TongODoVatLy, 0) AS TongODoVatLy,
    ISNULL(od.SoODoDaDo, 0) AS SoODoDaDo,
    ISNULL(od.SoODoTrong, 0) AS SoODoTrong,
    ISNULL(od.SoKhuVuc, 0) AS SoKhuVuc,
    ISNULL(dd.SoXeThucTeTrongBai, 0) AS SoXeThucTeTrongBai,
    ISNULL(dd.SoXeTheThang, 0) AS SoXeTheThang,
    ISNULL(dd.SoXeTheLuot, 0) AS SoXeTheLuot,
    dd.ThoiGianXeVaoGanNhat,
    ra.ThoiGianXeRaGanNhat,
    ISNULL(hn.SoLuotVaoHomNay, 0) AS SoLuotVaoHomNay,
    ISNULL(hn.SoLuotRaHomNay, 0) AS SoLuotRaHomNay,
    ISNULL(hn.DoanhThuLuotHomNay, 0) AS DoanhThuLuotHomNay,
    -- Cờ đối soát: bộ đếm của bãi lệch so với số lượt gửi đang mở thực tế
    CAST(CASE WHEN b.SoLuongHienTai <> ISNULL(dd.SoXeThucTeTrongBai, 0) THEN 1 ELSE 0 END AS BIT) AS CanhBaoLechBoDem,
    CASE WHEN b.SoLuongHienTai >= b.SucChua THEN N'ĐỎ - BÃI ĐẦY'
         WHEN b.SoLuongHienTai * 100.0 / b.SucChua >= 80 THEN N'VÀNG - GẦN ĐẦY'
         ELSE N'XANH - CÒN NHIỀU CHỖ'
    END AS MucDoCanhBao
FROM dbo.BAI_DO_XE b
OUTER APPLY (
    SELECT
        COUNT(*) AS TongODoVatLy,
        SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1 ELSE 0 END) AS SoODoDaDo,
        SUM(CASE WHEN v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoTrong,
        COUNT(DISTINCT v.KhuVuc) AS SoKhuVuc
    FROM dbo.VI_TRI_DO v
    WHERE v.MaBai = b.MaBai
) od
OUTER APPLY (
    SELECT
        COUNT(*) AS SoXeThucTeTrongBai,
        SUM(CASE WHEN t.LoaiThe = N'Tháng' THEN 1 ELSE 0 END) AS SoXeTheThang,
        SUM(CASE WHEN t.LoaiThe = N'Lượt' THEN 1 ELSE 0 END) AS SoXeTheLuot,
        MAX(l.ThoiGianVao) AS ThoiGianXeVaoGanNhat
    FROM dbo.LUOT_GUI l
    INNER JOIN dbo.THE_XE t ON l.MaThe = t.MaThe
    WHERE l.MaBai = b.MaBai AND l.ThoiGianRa IS NULL
) dd
OUTER APPLY (
    SELECT MAX(l.ThoiGianRa) AS ThoiGianXeRaGanNhat
    FROM dbo.LUOT_GUI l
    WHERE l.MaBai = b.MaBai AND l.ThoiGianRa IS NOT NULL
) ra
OUTER APPLY (
    SELECT
        SUM(CASE WHEN CAST(l.ThoiGianVao AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS SoLuotVaoHomNay,
        SUM(CASE WHEN CAST(l.ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS SoLuotRaHomNay,
        SUM(CASE WHEN CAST(l.ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE) THEN l.TienGui ELSE 0 END) AS DoanhThuLuotHomNay
    FROM dbo.LUOT_GUI l
    WHERE l.MaBai = b.MaBai
      AND (CAST(l.ThoiGianVao AS DATE) = CAST(GETDATE() AS DATE)
           OR CAST(l.ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE))
) hn;
GO

-- ====================================================================================
-- PHẦN E: 6 VIEWS TỔNG HỢP PHỤC VỤ NHÀ QUẢN LÝ CHUỖI BÃI XE (ISSUE #12)
-- Mục tiêu: Ban quản lý nhìn được doanh thu theo thời gian, giờ cao điểm, cơ cấu loại xe,
-- xếp hạng các bãi và một bảng tổng quan toàn chuỗi. Chỉ đọc dữ liệu (SELECT), không sửa bảng.
-- ====================================================================================

-- 16. View vw_Report_DoanhThuTheoNgay: Doanh thu (lượt + vé tháng) theo từng ngày, từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoNgay
AS
WITH Nguon AS (
    SELECT
        MaBai,
        CAST(ThoiGianRa AS DATE) AS Ngay,
        COUNT(*) AS SoLuotXe,
        SUM(ISNULL(TienGui, 0)) AS DoanhThuLuot,
        0 AS SoHoaDonVeThang,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuVeThang
    FROM dbo.LUOT_GUI
    WHERE ThoiGianRa IS NOT NULL
    GROUP BY MaBai, CAST(ThoiGianRa AS DATE)

    UNION ALL

    SELECT
        MaBai,
        CAST(NgayThanhToan AS DATE) AS Ngay,
        0 AS SoLuotXe,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuLuot,
        COUNT(*) AS SoHoaDonVeThang,
        SUM(ISNULL(SoTien, 0)) AS DoanhThuVeThang
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaBai, CAST(NgayThanhToan AS DATE)
)
SELECT
    bd.MaBai,
    bd.TenBai,
    n.Ngay,
    SUM(n.SoLuotXe) AS SoLuotXe,
    SUM(n.DoanhThuLuot) AS DoanhThuLuot,
    SUM(n.SoHoaDonVeThang) AS SoHoaDonVeThang,
    SUM(n.DoanhThuVeThang) AS DoanhThuVeThang,
    SUM(n.DoanhThuLuot) + SUM(n.DoanhThuVeThang) AS TongDoanhThu
FROM Nguon n
INNER JOIN dbo.BAI_DO_XE bd ON n.MaBai = bd.MaBai
GROUP BY bd.MaBai, bd.TenBai, n.Ngay;
GO

-- 17. View vw_Report_DoanhThuTheoThang: Doanh thu (lượt + vé tháng) theo từng tháng, từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoThang
AS
WITH Nguon AS (
    SELECT
        MaBai,
        YEAR(ThoiGianRa) AS Nam,
        MONTH(ThoiGianRa) AS Thang,
        COUNT(*) AS SoLuotXe,
        SUM(ISNULL(TienGui, 0)) AS DoanhThuLuot,
        0 AS SoHoaDonVeThang,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuVeThang
    FROM dbo.LUOT_GUI
    WHERE ThoiGianRa IS NOT NULL
    GROUP BY MaBai, YEAR(ThoiGianRa), MONTH(ThoiGianRa)

    UNION ALL

    SELECT
        MaBai,
        YEAR(NgayThanhToan) AS Nam,
        MONTH(NgayThanhToan) AS Thang,
        0 AS SoLuotXe,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuLuot,
        COUNT(*) AS SoHoaDonVeThang,
        SUM(ISNULL(SoTien, 0)) AS DoanhThuVeThang
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaBai, YEAR(NgayThanhToan), MONTH(NgayThanhToan)
)
SELECT
    bd.MaBai,
    bd.TenBai,
    n.Nam,
    n.Thang,
    SUM(n.SoLuotXe) AS SoLuotXe,
    SUM(n.DoanhThuLuot) AS DoanhThuLuot,
    SUM(n.SoHoaDonVeThang) AS SoHoaDonVeThang,
    SUM(n.DoanhThuVeThang) AS DoanhThuVeThang,
    SUM(n.DoanhThuLuot) + SUM(n.DoanhThuVeThang) AS TongDoanhThu
FROM Nguon n
INNER JOIN dbo.BAI_DO_XE bd ON n.MaBai = bd.MaBai
GROUP BY bd.MaBai, bd.TenBai, n.Nam, n.Thang;
GO

-- 18. View vw_Report_LuuLuongTheoGio: Số lượt xe vào theo khung giờ, để tìm giờ cao điểm
CREATE OR ALTER VIEW dbo.vw_Report_LuuLuongTheoGio
AS
SELECT
    bd.MaBai,
    bd.TenBai,
    DATEPART(HOUR, lg.ThoiGianVao) AS GioTrongNgay,
    COUNT(*) AS SoLuotVao,
    COUNT(DISTINCT CAST(lg.ThoiGianVao AS DATE)) AS SoNgayCoDuLieu,
    CAST(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT CAST(lg.ThoiGianVao AS DATE)), 0) AS DECIMAL(10,2)) AS SoLuotVaoTBMoiNgay
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
GROUP BY bd.MaBai, bd.TenBai, DATEPART(HOUR, lg.ThoiGianVao);
GO

-- 19. View vw_Report_ThongKeTheoLoaiXe: Cơ cấu lượt gửi và doanh thu theo loại phương tiện
CREATE OR ALTER VIEW dbo.vw_Report_ThongKeTheoLoaiXe
AS
SELECT
    bd.MaBai,
    bd.TenBai,
    lx.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    COUNT(*) AS SoLuotXe,
    SUM(ISNULL(lg.TienGui, 0)) AS DoanhThuLuot,
    CAST(AVG(CAST(DATEDIFF(MINUTE, lg.ThoiGianVao, lg.ThoiGianRa) AS FLOAT)) / 60.0 AS DECIMAL(10,2)) AS SoGioGuiTB
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
WHERE lg.ThoiGianRa IS NOT NULL
GROUP BY bd.MaBai, bd.TenBai, lx.MaLoaiXe, lx.TenLoai;
GO

-- 20. View vw_Report_XepHangBai: Xếp hạng các bãi theo tổng doanh thu, kèm tỉ lệ lấp đầy hiện tại
--     Tận dụng lại 2 view báo cáo có sẵn ở PHẦN B nên số liệu luôn đồng nhất.
CREATE OR ALTER VIEW dbo.vw_Report_XepHangBai
AS
SELECT
    RANK() OVER (ORDER BY dt.TongDoanhThu DESC) AS HangDoanhThu,
    dt.MaBai,
    dt.TenBai,
    dt.DoanhThuLuot,
    dt.DoanhThuThang,
    dt.TongDoanhThu,
    cs.SucChua,
    cs.SoLuongHienTai,
    cs.TyLeLapDayPercent
FROM dbo.vw_Report_DoanhThuTheoBai dt
INNER JOIN dbo.vw_Report_CongSuatBaiDo cs ON dt.MaBai = cs.MaBai;
GO

-- 21. View vw_Report_TongQuanChuoi: Bảng tổng quan toàn chuỗi, luôn trả về đúng 1 dòng
CREATE OR ALTER VIEW dbo.vw_Report_TongQuanChuoi
AS
SELECT
    (SELECT COUNT(*) FROM dbo.BAI_DO_XE) AS TongSoBai,
    (SELECT ISNULL(SUM(SucChua), 0) FROM dbo.BAI_DO_XE) AS TongSucChua,
    (SELECT ISNULL(SUM(SoLuongHienTai), 0) FROM dbo.BAI_DO_XE) AS TongXeDangGui,
    CAST((SELECT ISNULL(SUM(SoLuongHienTai), 0) * 100.0 / NULLIF(SUM(SucChua), 0)
          FROM dbo.BAI_DO_XE) AS DECIMAL(5,2)) AS TyLeLapDayToanChuoiPercent,
    (SELECT ISNULL(SUM(TienGui), 0) FROM dbo.LUOT_GUI
      WHERE CAST(ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE)) AS DoanhThuLuotHomNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.HOA_DON_VE_THANG
      WHERE CAST(NgayThanhToan AS DATE) = CAST(GETDATE() AS DATE)) AS DoanhThuVeThangHomNay,
    (SELECT ISNULL(SUM(TienGui), 0) FROM dbo.LUOT_GUI
      WHERE ThoiGianRa >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS DoanhThuLuotThangNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.HOA_DON_VE_THANG
      WHERE NgayThanhToan >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS DoanhThuVeThangThangNay,
    (SELECT COUNT(*) FROM dbo.VE_THANG
      WHERE TrangThai = N'Hoạt động' AND NgayHetHan >= CAST(GETDATE() AS DATE)) AS SoVeThangConHieuLuc,
    (SELECT COUNT(*) FROM dbo.VE_THANG
      WHERE TrangThai = N'Hoạt động'
        AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), NgayHetHan) BETWEEN 0 AND 7) AS SoVeThangSapHetHan7Ngay,
    (SELECT COUNT(*) FROM dbo.LICHSU_SU_CO
      WHERE CAST(ThoiGianSuCo AS DATE) = CAST(GETDATE() AS DATE)) AS SoSuCoHomNay;
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- VIEWS CỔNG KHÁCH HÀNG & BÁO CÁO THANH TOÁN (UPGRADE_PLAN.md MỤC 9)
-- PHẦN F: 6 views cổng khách hàng (vw_KH_*), lọc theo SESSION_CONTEXT do sp_KH_DangNhap đặt.
--         Không có ngữ cảnh khách hàng (nhân viên, trang quản trị) thì các view này trả về rỗng.
-- PHẦN G: 5 views báo cáo quản trị thanh toán / bảo mật tài khoản.
-- PHẦN H: Phiên bản mở rộng của vw_Report_DoanhThuTheoBai và v_BotCong_TraCuuThe (thêm cột ở cuối, giữ cột cũ).
-- ====================================================================================

-- ====================================================================================
-- PHẦN F: VIEWS CỔNG KHÁCH HÀNG
-- ====================================================================================

-- 22. vw_KH_HoSoCuaToi: Hồ sơ, số dư ví và số thông báo chưa đọc của khách đang đăng nhập
CREATE OR ALTER VIEW dbo.vw_KH_HoSoCuaToi
AS
SELECT
    tk.MaTK,
    kh.MaKH,
    kh.HoTen,
    kh.SDT,
    kh.Email,
    tk.TenDangNhap,
    tk.TrangThai AS TrangThaiTaiKhoan,
    tk.LanDangNhapCuoi,
    vi.MaVi,
    vi.SoDu,
    vi.TrangThai AS TrangThaiVi,
    (SELECT COUNT(*) FROM dbo.THONG_BAO tb WHERE tb.MaKH = kh.MaKH AND tb.DaDoc = 0) AS SoThongBaoChuaDoc
FROM dbo.TAI_KHOAN_KH tk
INNER JOIN dbo.KHACH_HANG kh ON tk.MaKH = kh.MaKH
LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = kh.MaKH
WHERE tk.MaTK = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12));
GO

-- 23. vw_KH_VeThangCuaToi: Vé chính chủ + vé được ủy quyền còn hiệu lực, kèm vai trò của tôi trên từng vé
CREATE OR ALTER VIEW dbo.vw_KH_VeThangCuaToi
AS
WITH Phien AS (
    SELECT
        CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12)) AS MaTK,
        CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10)) AS MaKH
)
SELECT
    vt.MaVe,
    vt.MaThe,
    vt.BienSo,
    vt.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    vt.MaBaiApDung,
    CASE WHEN vt.MaBaiApDung = 'ALL' THEN N'Toàn chuỗi' ELSE bd.TenBai END AS PhamViApDung,
    vt.NgayDangKy,
    vt.NgayHetHan,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) AS SoNgayConLai,
    vt.TrangThai,
    CASE WHEN vt.MaKH = p.MaKH THEN 'CHU_SO_HUU' ELSE uq.MaVaiTro END AS MaVaiTroCuaToi,
    vtr.TenVaiTro AS VaiTroCuaToi,
    chu.HoTen AS ChuVe,
    uq.NgayKetThuc AS HanUyQuyen,
    vt.TuDongGiaHan,
    vt.SoThangTuDongGiaHan,
    dbo.f_KH_TinhPhiGiaHan(vt.MaVe, 1) AS PhiGiaHan1Thang
FROM dbo.VE_THANG vt
CROSS JOIN Phien p
INNER JOIN dbo.THE_XE tx ON vt.MaThe = tx.MaThe
INNER JOIN dbo.KHACH_HANG chu ON vt.MaKH = chu.MaKH
LEFT JOIN dbo.BAI_DO_XE bd ON vt.MaBaiApDung = bd.MaBai
LEFT JOIN dbo.LOAI_XE lx
    ON lx.MaLoaiXe = vt.MaLoaiXe
   AND lx.MaBai = CASE WHEN vt.MaBaiApDung = 'ALL' THEN tx.MaBai ELSE vt.MaBaiApDung END
LEFT JOIN dbo.UY_QUYEN_VE uq
    ON uq.MaVe = vt.MaVe
   AND uq.MaTKDuocUyQuyen = p.MaTK
   AND uq.TrangThai = N'Hiệu lực'
   AND uq.NgayBatDau <= CAST(GETDATE() AS DATE)
   AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE))
LEFT JOIN dbo.VAI_TRO_KH vtr
    ON vtr.MaVaiTro = CASE WHEN vt.MaKH = p.MaKH THEN 'CHU_SO_HUU' ELSE uq.MaVaiTro END
WHERE vt.MaKH = p.MaKH OR uq.MaUyQuyen IS NOT NULL;
GO

-- 24. vw_KH_LichSuDoXe: Lịch sử đỗ xe của các vé tôi xem được (vai trò nào cũng có quyền LICHSU.XEM)
CREATE OR ALTER VIEW dbo.vw_KH_LichSuDoXe
AS
SELECT
    lg.MaLuot,
    lg.MaVe,
    ve.MaVaiTroCuaToi,
    ve.BienSo AS BienSoDangKy,
    lg.BienSo,
    lg.MaBai,
    bd.TenBai,
    lg.MaViTri,
    v.KhuVuc,
    lg.ThoiGianVao,
    lg.ThoiGianRa,
    DATEDIFF(MINUTE, lg.ThoiGianVao, ISNULL(lg.ThoiGianRa, GETDATE())) AS SoPhutGui,
    CASE WHEN lg.ThoiGianRa IS NULL THEN N'Đang đỗ' ELSE N'Đã ra' END AS TrangThai,
    lg.TienGui
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.vw_KH_VeThangCuaToi ve ON lg.MaVe = ve.MaVe
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri;
GO

-- 25. vw_KH_LichSuGiaoDich: Sổ cái ví của chính tôi - số tiền có dấu, phương thức thanh toán, trạng thái, số dư sau
CREATE OR ALTER VIEW dbo.vw_KH_LichSuGiaoDich
AS
SELECT
    g.MaGD,
    g.ThoiGianTao,
    g.LoaiGD,
    g.HuongTien * g.SoTien AS SoTienCoDau,
    g.PhiGiaoDich,
    p.TenPTTT AS PhuongThucThanhToan,
    g.MaPTTT,
    g.MaThamChieu,
    g.TrangThai,
    g.SoDuTruoc,
    g.SoDuSau,
    g.MaVe,
    g.MaGDGoc,
    g.ThoiGianHoanTat,
    g.GhiChu
FROM dbo.GIAO_DICH g
INNER JOIN dbo.VI_DIEN_TU vi ON g.MaVi = vi.MaVi
INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON g.MaPTTT = p.MaPTTT
WHERE vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- 26. vw_KH_HoaDonCuaToi: Hóa đơn vé tháng của các vé tôi đứng tên (mọi kênh: quầy, online, tự động)
CREATE OR ALTER VIEW dbo.vw_KH_HoaDonCuaToi
AS
SELECT
    hd.MaHD,
    hd.MaVe,
    vt.BienSo,
    hd.NgayThanhToan,
    hd.SoThangGiaHan,
    hd.SoTien,
    p.TenPTTT AS PhuongThucThanhToan,
    hd.KenhThanhToan,
    hd.MaBai,
    bd.TenBai,
    hd.MaGD
FROM dbo.HOA_DON_VE_THANG hd
INNER JOIN dbo.VE_THANG vt ON hd.MaVe = vt.MaVe
INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON hd.MaPTTT = p.MaPTTT
INNER JOIN dbo.BAI_DO_XE bd ON hd.MaBai = bd.MaBai
WHERE vt.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- 27. vw_KH_ThongBao: Hộp thư thông báo của tôi (sắp xếp chưa đọc lên đầu thực hiện ở truy vấn / UI)
CREATE OR ALTER VIEW dbo.vw_KH_ThongBao
AS
SELECT
    tb.MaTB,
    tb.LoaiTB,
    tb.TieuDe,
    tb.NoiDung,
    tb.MaVe,
    tb.MaGD,
    tb.DaDoc,
    tb.ThoiGianTao
FROM dbo.THONG_BAO tb
WHERE tb.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- ====================================================================================
-- PHẦN G: VIEWS BÁO CÁO THANH TOÁN & BẢO MẬT TÀI KHOẢN (QUẢN TRỊ)
-- ====================================================================================

-- 28. vw_Report_DoanhThuTheoPhuongThuc: Doanh thu vé tháng theo phương thức / kênh và tiền nạp ví qua từng cổng
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoPhuongThuc
AS
SELECT
    p.MaPTTT,
    p.TenPTTT AS PhuongThucThanhToan,
    p.LoaiKenh,
    p.TrangThai,
    ISNULL(hd.SoHoaDon, 0) AS SoHoaDonVeThang,
    ISNULL(hd.DoanhThuTaiQuay, 0) AS DoanhThuTaiQuay,
    ISNULL(hd.DoanhThuOnline, 0) AS DoanhThuOnline,
    ISNULL(hd.DoanhThuTuDong, 0) AS DoanhThuTuDong,
    ISNULL(hd.TongDoanhThu, 0) AS TongDoanhThuVeThang,
    ISNULL(nap.SoLanNap, 0) AS SoLanNapVi,
    ISNULL(nap.TongNap, 0) AS TongTienNapVi,
    ISNULL(nap.PhiCong, 0) AS PhiCongThanhToan,
    ISNULL(nap.TongNap, 0) - ISNULL(nap.PhiCong, 0) AS TienNapThucNhan
FROM dbo.PHUONG_THUC_THANH_TOAN p
LEFT JOIN (
    SELECT
        MaPTTT,
        COUNT(*) AS SoHoaDon,
        SUM(CASE WHEN KenhThanhToan = N'Tại quầy' THEN SoTien ELSE 0 END) AS DoanhThuTaiQuay,
        SUM(CASE WHEN KenhThanhToan = N'Online' THEN SoTien ELSE 0 END) AS DoanhThuOnline,
        SUM(CASE WHEN KenhThanhToan = N'Tự động' THEN SoTien ELSE 0 END) AS DoanhThuTuDong,
        SUM(SoTien) AS TongDoanhThu
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaPTTT
) hd ON hd.MaPTTT = p.MaPTTT
LEFT JOIN (
    SELECT
        MaPTTT,
        COUNT(*) AS SoLanNap,
        SUM(SoTien) AS TongNap,
        SUM(PhiGiaoDich) AS PhiCong
    FROM dbo.GIAO_DICH
    WHERE LoaiGD = N'Nạp tiền' AND TrangThai IN (N'Thành công', N'Đã hoàn')
    GROUP BY MaPTTT
) nap ON nap.MaPTTT = p.MaPTTT;
GO

-- 29. vw_Report_TongQuanViDienTu: Tổng quan ví toàn chuỗi, luôn trả về đúng 1 dòng
-- TongSoDuDangGiu là nợ phải trả khách hàng (tiền khách đã nạp nhưng chưa dùng).
CREATE OR ALTER VIEW dbo.vw_Report_TongQuanViDienTu
AS
SELECT
    (SELECT COUNT(*) FROM dbo.VI_DIEN_TU) AS TongSoVi,
    (SELECT COUNT(*) FROM dbo.VI_DIEN_TU WHERE SoDu > 0) AS SoViCoSoDu,
    (SELECT ISNULL(SUM(SoDu), 0) FROM dbo.VI_DIEN_TU) AS TongSoDuDangGiu,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.GIAO_DICH
      WHERE LoaiGD = N'Nạp tiền' AND TrangThai IN (N'Thành công', N'Đã hoàn')
        AND ThoiGianTao >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS TongNapThangNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.GIAO_DICH
      WHERE LoaiGD = N'Thanh toán vé tháng' AND TrangThai IN (N'Thành công', N'Đã hoàn')
        AND ThoiGianTao >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS TongChiVeThangThangNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.HOA_DON_VE_THANG
      WHERE KenhThanhToan IN (N'Online', N'Tự động')
        AND NgayThanhToan >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS DoanhThuGiaHanOnlineThangNay,
    (SELECT COUNT(*) FROM dbo.GIAO_DICH WHERE TrangThai = N'Chờ xử lý') AS SoGiaoDichChoXuLy,
    (SELECT COUNT(*) FROM dbo.TAI_KHOAN_KH) AS SoTaiKhoanKhachHang,
    (SELECT COUNT(*) FROM dbo.TAI_KHOAN_KH WHERE TrangThai = N'Tạm khóa') AS SoTaiKhoanTamKhoa;
GO

-- 30. vw_Report_GiaoDichCanXuLy: Hàng đợi xử lý của nhân viên - giao dịch treo, thất bại 7 ngày gần nhất
CREATE OR ALTER VIEW dbo.vw_Report_GiaoDichCanXuLy
AS
SELECT
    g.MaGD,
    g.ThoiGianTao,
    vi.MaKH,
    kh.HoTen,
    g.LoaiGD,
    g.SoTien,
    p.TenPTTT AS PhuongThucThanhToan,
    g.TrangThai,
    DATEDIFF(MINUTE, g.ThoiGianTao, GETDATE()) AS SoPhutTuKhiTao,
    CASE
        WHEN g.TrangThai = N'Chờ xử lý' AND g.ThoiGianTao < DATEADD(MINUTE, -30, GETDATE()) THEN N'Treo quá 30 phút'
        WHEN g.TrangThai = N'Chờ xử lý' THEN N'Đang chờ cổng thanh toán'
        ELSE N'Thất bại'
    END AS PhanLoai,
    g.GhiChu
FROM dbo.GIAO_DICH g
INNER JOIN dbo.VI_DIEN_TU vi ON g.MaVi = vi.MaVi
INNER JOIN dbo.KHACH_HANG kh ON vi.MaKH = kh.MaKH
INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON g.MaPTTT = p.MaPTTT
WHERE g.TrangThai = N'Chờ xử lý'
   OR (g.TrangThai = N'Thất bại' AND g.ThoiGianTao >= DATEADD(DAY, -7, GETDATE()));
GO

-- 31. vw_Report_BaoMatTaiKhoanKH: Giám sát bảo mật tài khoản khách hàng (24 giờ gần nhất)
CREATE OR ALTER VIEW dbo.vw_Report_BaoMatTaiKhoanKH
AS
SELECT
    tk.MaTK,
    tk.TenDangNhap,
    kh.HoTen,
    tk.TrangThai,
    tk.KhoaDen,
    tk.SoLanSaiLienTiep,
    tk.LanDangNhapCuoi,
    ISNULL(nk.SoLanSai24h, 0) AS SoLanSai24h,
    ISNULL(nk.SoLanThanhCong24h, 0) AS SoLanThanhCong24h,
    ISNULL(nk.SoDiaChiIP24h, 0) AS SoDiaChiIP24h,
    CASE
        WHEN tk.TrangThai = N'Tạm khóa' THEN N'Đang tạm khóa'
        WHEN ISNULL(nk.SoLanSai24h, 0) >= 3 THEN N'Nhiều lần sai mật khẩu'
        WHEN ISNULL(nk.SoDiaChiIP24h, 0) >= 3 THEN N'Đăng nhập từ nhiều địa chỉ IP'
        ELSE N'Bình thường'
    END AS CanhBao
FROM dbo.TAI_KHOAN_KH tk
INNER JOIN dbo.KHACH_HANG kh ON tk.MaKH = kh.MaKH
LEFT JOIN (
    SELECT
        MaTK,
        SUM(CASE WHEN KetQua = N'Sai mật khẩu' THEN 1 ELSE 0 END) AS SoLanSai24h,
        SUM(CASE WHEN KetQua = N'Thành công' THEN 1 ELSE 0 END) AS SoLanThanhCong24h,
        COUNT(DISTINCT DiaChiIP) AS SoDiaChiIP24h
    FROM dbo.NHAT_KY_DANG_NHAP
    WHERE ThoiGian >= DATEADD(HOUR, -24, GETDATE()) AND MaTK IS NOT NULL
    GROUP BY MaTK
) nk ON nk.MaTK = tk.MaTK;
GO

-- 32. vw_Report_TyLeChuyenDoiOnline: Tỷ lệ gia hạn online / tự động so với tại quầy theo tháng
CREATE OR ALTER VIEW dbo.vw_Report_TyLeChuyenDoiOnline
AS
SELECT
    YEAR(hd.NgayThanhToan) AS Nam,
    MONTH(hd.NgayThanhToan) AS Thang,
    COUNT(*) AS SoHoaDon,
    SUM(CASE WHEN hd.KenhThanhToan = N'Tại quầy' THEN 1 ELSE 0 END) AS SoHoaDonTaiQuay,
    SUM(CASE WHEN hd.KenhThanhToan IN (N'Online', N'Tự động') THEN 1 ELSE 0 END) AS SoHoaDonOnline,
    CAST(SUM(CASE WHEN hd.KenhThanhToan IN (N'Online', N'Tự động') THEN 1 ELSE 0 END) * 100.0
         / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS TyLeOnlinePercent,
    CAST((SELECT COUNT(*) FROM dbo.TAI_KHOAN_KH) * 100.0
         / NULLIF((SELECT COUNT(*) FROM dbo.KHACH_HANG), 0) AS DECIMAL(5,2)) AS TyLeKhachCoTaiKhoanPercent
FROM dbo.HOA_DON_VE_THANG hd
GROUP BY YEAR(hd.NgayThanhToan), MONTH(hd.NgayThanhToan);
GO

-- ====================================================================================
-- PHẦN H: Bản mở rộng của vw_Report_DoanhThuTheoBai và v_BotCong_TraCuuThe nằm ngay tại vị trí bản gốc
-- ở đầu file (view phía sau phụ thuộc chúng).
-- PHẦN I: VIEWS PHỤ TRỢ CỔNG KHÁCH HÀNG /kh (lọc theo SESSION_CONTEXT như PHẦN F)
-- ====================================================================================

-- 12. vw_KH_NhatKyDangNhap: Nhật ký đăng nhập của tài khoản đang đăng nhập (màn hình Bảo mật)
CREATE OR ALTER VIEW dbo.vw_KH_NhatKyDangNhap
AS
SELECT n.MaNK, n.ThoiGian, n.KetQua, n.DiaChiIP, n.ThietBi
FROM dbo.NHAT_KY_DANG_NHAP n
WHERE n.MaTK = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12));
GO

-- 13. vw_KH_PhuongThucNapVi: Phương thức khách được chọn khi nạp ví online (không gồm tiền mặt tại quầy)
CREATE OR ALTER VIEW dbo.vw_KH_PhuongThucNapVi
AS
SELECT MaPTTT, TenPTTT, LoaiKenh, PhiPhanTram, SoTienToiThieu, TrangThai
FROM dbo.PHUONG_THUC_THANH_TOAN
WHERE ChoPhepNapVi = 1 AND LoaiKenh <> N'Tiền mặt';
GO

-- 14. vw_KH_HanMucNap: Hạn mức nạp trong ngày còn lại của ví (tính cả lệnh nạp đang chờ cổng thanh toán)
CREATE OR ALTER VIEW dbo.vw_KH_HanMucNap
AS
SELECT
    vi.MaVi,
    vi.HanMucNapNgay,
    dbo.f_KH_TongNapTrongNgay(vi.MaVi) AS DaNapHomNay,
    vi.HanMucNapNgay - dbo.f_KH_TongNapTrongNgay(vi.MaVi) AS HanMucConLai
FROM dbo.VI_DIEN_TU vi
WHERE vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- 15. vw_KH_QuyenTrenVe: Quyền nghiệp vụ của tôi trên từng vé (để ẩn nút không có quyền; server vẫn kiểm tra lại)
CREATE OR ALTER VIEW dbo.vw_KH_QuyenTrenVe
AS
SELECT v.MaVe, q.MaQuyen
FROM dbo.vw_KH_VeThangCuaToi v
INNER JOIN dbo.VAI_TRO_QUYEN q ON q.MaVaiTro = v.MaVaiTroCuaToi;
GO

-- 16. vw_KH_VaiTroUyQuyen: Vai trò được phép chia sẻ kèm danh sách quyền (form chia sẻ vé)
CREATE OR ALTER VIEW dbo.vw_KH_VaiTroUyQuyen
AS
SELECT
    vt.MaVaiTro,
    vt.TenVaiTro,
    vt.MoTa,
    STRING_AGG(qk.MoTa, N'; ') AS DanhSachQuyen
FROM dbo.VAI_TRO_KH vt
INNER JOIN dbo.VAI_TRO_QUYEN vq ON vq.MaVaiTro = vt.MaVaiTro
INNER JOIN dbo.QUYEN_KH qk ON qk.MaQuyen = vq.MaQuyen
WHERE vt.MaVaiTro <> 'CHU_SO_HUU'
GROUP BY vt.MaVaiTro, vt.TenVaiTro, vt.MoTa;
GO


-- ==================== BẮT ĐẦU: 08_security_rbac.sql (PHÂN QUYỀN RBAC, ROLE r_KhachHang, ROW-LEVEL SECURITY) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 8: AN TOÀN THÔNG TIN & PHÂN QUYỀN TRUY CẬP (ROLE-BASED ACCESS CONTROL - RBAC)
-- ====================================================================================

-- 1. Khởi tạo 3 Nhóm quyền (Database Roles)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_Admin' AND type = 'R')
    CREATE ROLE r_Admin;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_QuanLyBai' AND type = 'R')
    CREATE ROLE r_QuanLyBai;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_BaoVe' AND type = 'R')
    CREATE ROLE r_BaoVe;
GO

-- ====================================================================================
-- 2. CẤP QUYỀN CHI TIẾT THEO TỪNG VAI TRÒ
-- ====================================================================================

-- A. Quyền r_Admin: Quản trị viên tối cao (Full Control trên toàn bộ cơ sở dữ liệu)
GRANT CONTROL TO r_Admin;
GO

-- B. Quyền r_QuanLyBai: Quản lý chi nhánh bãi đỗ xe
-- Được xem, thêm, sửa trên các danh mục quản trị và dữ liệu nghiệp vụ
GRANT SELECT, INSERT, UPDATE ON dbo.BAI_DO_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.LOAI_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.VI_TRI_DO TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.THE_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.KHACH_HANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.VE_THANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.NHAN_VIEN TO r_QuanLyBai;
GRANT SELECT ON dbo.TAI_KHOAN TO r_QuanLyBai;
DENY SELECT ON dbo.TAI_KHOAN (MatKhauHash, MatKhauSalt) TO r_QuanLyBai;   -- xem tài khoản, không xem hash / salt (N5)
GRANT SELECT ON dbo.LUOT_GUI TO r_QuanLyBai;
GRANT SELECT ON dbo.HOA_DON_VE_THANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.LICHSU_SU_CO TO r_QuanLyBai;

-- Được thực thi các Stored Procedures quản trị vé và nhân sự
GRANT EXECUTE ON dbo.sp_DangKyThanhVien TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_GiaHanTheThang TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_BaoMatThe TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoCanhBaoHanTheThang TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoTongKetDoanhThuChuoi TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DangNhap TO r_QuanLyBai;

-- Được xem tất cả các Views báo cáo
GRANT SELECT ON dbo.v_SodoOdoRealtime TO r_QuanLyBai;
GRANT SELECT ON dbo.v_Xedangtrongbai TO r_QuanLyBai;
GRANT SELECT ON dbo.v_DanhsachveThangsaphethan TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_CongSuatBaiDo TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_DoanhThuTheoBai TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_XeDangDoHienTai TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_VeThangSapHetHan TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_NhatKySuCo TO r_QuanLyBai;
GO

-- C. Quyền r_BaoVe: Nhân viên bảo vệ trực cổng bãi xe
-- Chỉ có quyền quét xe vào/ra qua Procedure và tra cứu sơ đồ ô đỗ
GRANT EXECUTE ON dbo.sp_XeVaoBai TO r_BaoVe;
GRANT EXECUTE ON dbo.sp_XeRaBai TO r_BaoVe;
GRANT EXECUTE ON dbo.sp_BaoMatThe TO r_BaoVe;
GRANT EXECUTE ON dbo.sp_DangNhap TO r_BaoVe;

-- Cho phép xem sơ đồ ô đỗ thời gian thực để hướng dẫn khách
GRANT SELECT ON dbo.v_SodoOdoRealtime TO r_BaoVe;
GRANT SELECT ON dbo.v_Xedangtrongbai TO r_BaoVe;

-- Chặn nghiêm ngặt: Nhân viên bảo vệ tuyệt đối KHÔNG ĐƯỢC sửa hoặc xóa dữ liệu tài chính/lượt xe
DENY UPDATE, DELETE ON dbo.LUOT_GUI TO r_BaoVe;
DENY UPDATE, DELETE ON dbo.HOA_DON_VE_THANG TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN TO r_BaoVe;
GO

-- ====================================================================================
-- 3. PHÂN QUYỀN BỔ SUNG CHO 7 VIEWS BỐT KIỂM SOÁT CỔNG & SƠ ĐỒ BÃI XE REALTIME
-- ====================================================================================

-- A. Nhân viên bảo vệ trực bốt cổng: được tra cứu thẻ, xem xe chờ ra, nhật ký vào/ra và bảng đèn cổng
GRANT SELECT ON dbo.v_BotCong_TraCuuThe TO r_BaoVe;
GRANT SELECT ON dbo.v_BotCong_XeChoRa TO r_BaoVe;
GRANT SELECT ON dbo.v_BotCong_NhatKyVaoRa TO r_BaoVe;
GRANT SELECT ON dbo.v_BotCong_BangDenCong TO r_BaoVe;

-- Được xem sơ đồ bãi xe thời gian thực để hướng dẫn khách vào đúng khu vực còn chỗ
GRANT SELECT ON dbo.v_SodoBai_ODoChiTiet TO r_BaoVe;
GRANT SELECT ON dbo.v_SodoBai_TongHopKhuVuc TO r_BaoVe;
GRANT SELECT ON dbo.v_SodoBai_TongQuanBai TO r_BaoVe;
GO

-- B. Quản lý bãi: xem toàn bộ 7 views vận hành bốt cổng và sơ đồ realtime
GRANT SELECT ON dbo.v_BotCong_TraCuuThe TO r_QuanLyBai;
GRANT SELECT ON dbo.v_BotCong_XeChoRa TO r_QuanLyBai;
GRANT SELECT ON dbo.v_BotCong_NhatKyVaoRa TO r_QuanLyBai;
GRANT SELECT ON dbo.v_BotCong_BangDenCong TO r_QuanLyBai;
GRANT SELECT ON dbo.v_SodoBai_ODoChiTiet TO r_QuanLyBai;
GRANT SELECT ON dbo.v_SodoBai_TongHopKhuVuc TO r_QuanLyBai;
GRANT SELECT ON dbo.v_SodoBai_TongQuanBai TO r_QuanLyBai;
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- PHÂN QUYỀN TÀI KHOẢN KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 4)
--
-- LỚP 1 · Role r_KhachHang: chỉ EXECUTE sp_KH_* và SELECT vw_KH_*, DENY mọi bảng gốc.
--         Procedure / view thuộc dbo nên ownership chaining cho phép chúng đọc / ghi bảng dù bảng bị DENY.
-- LỚP 2 · Row-Level Security (policy bao_mat.rls_KhachHang): user thuộc r_KhachHang chỉ thấy dòng của
--         khách trong SESSION_CONTEXT('MaKH') (và vé được ủy quyền). dbo / nhân viên không bị lọc.
-- LỚP 3 · Quyền nghiệp vụ: f_KH_CoQuyen trong từng sp_KH_* (bước 12, 13).
--
-- Giả định bảo mật: người dùng cuối không kết nối thẳng vào CSDL; chỉ máy chủ web giữ thông tin đăng nhập
-- của login cổng khách hàng và đặt SESSION_CONTEXT (read-only) qua sp_KH_DangNhap.
-- Script idempotent. Policy RLS bật sau cùng.
-- ====================================================================================

-- 1. Role và user dùng cho cổng khách hàng
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_KhachHang' AND type = 'R')
    CREATE ROLE r_KhachHang;
GO

-- User không gắn login dùng để demo bằng EXECUTE AS USER; khi triển khai thật, tạo login riêng
-- (ví dụ login_WebKhachHang) và CREATE USER ... FOR LOGIN rồi thêm vào r_KhachHang.
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'u_WebKhachHang')
    CREATE USER u_WebKhachHang WITHOUT LOGIN;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    INNER JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    INNER JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id
    WHERE r.name = 'r_KhachHang' AND u.name = 'u_WebKhachHang'
)
    ALTER ROLE r_KhachHang ADD MEMBER u_WebKhachHang;
GO

-- ====================================================================================
-- 2. LỚP 1: QUYỀN CỦA r_KhachHang
-- ====================================================================================
GRANT EXECUTE ON dbo.sp_KH_DangKyTaiKhoan TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DangNhap TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DoiMatKhau TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_NapTien_KhoiTao TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_GiaHanBangVi TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_CaiDatTuDongGiaHan TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_UyQuyenVe TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_ThuHoiUyQuyen TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_BaoMatThe TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DanhDauDaDoc TO r_KhachHang;

GRANT SELECT ON dbo.vw_KH_HoSoCuaToi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_VeThangCuaToi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_LichSuDoXe TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_LichSuGiaoDich TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_HoaDonCuaToi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_ThongBao TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_NhatKyDangNhap TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_PhuongThucNapVi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_HanMucNap TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_QuyenTrenVe TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_VaiTroUyQuyen TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DanhSachUyQuyen TO r_KhachHang;
GRANT SELECT ON dbo.f_KH_SaoKeVi TO r_KhachHang;
GRANT EXECUTE ON dbo.f_KH_TinhPhiGiaHan TO r_KhachHang;   -- xem trước giá gia hạn trên UI
GO

-- Callback cổng thanh toán, thủ tục nhân viên và lõi gia hạn: tuyệt đối không cho khách gọi trực tiếp
DENY EXECUTE ON dbo.sp_KH_NapTien_XacNhan TO r_KhachHang;
DENY EXECUTE ON dbo.sp_NV_HoanTien TO r_KhachHang;
DENY EXECUTE ON dbo.sp_NV_MoKhoaTaiKhoanKH TO r_KhachHang;
DENY EXECUTE ON dbo.sp_NV_NapTienTaiQuay TO r_KhachHang;
DENY EXECUTE ON dbo.sp_GiaHanVe_Core TO r_KhachHang;
DENY EXECUTE ON dbo.sp_GiaHanTheThang TO r_KhachHang;
DENY EXECUTE ON dbo.sp_SinhMaGiaoDich TO r_KhachHang;
GO

-- DENY từng bảng (không DENY trên cả schema dbo vì DENY schema sẽ thắng cả GRANT trên procedure / view)
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.BAI_DO_XE TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.NHAN_VIEN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.LOAI_XE TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VI_TRI_DO TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.THE_XE TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.KHACH_HANG TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VE_THANG TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.LUOT_GUI TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.HOA_DON_VE_THANG TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.LICHSU_SU_CO TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.PHUONG_THUC_THANH_TOAN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN_KH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.NHAT_KY_DANG_NHAP TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VI_DIEN_TU TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.GIAO_DICH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.THONG_BAO TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.QUYEN_KH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VAI_TRO_KH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VAI_TRO_QUYEN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.UY_QUYEN_VE TO r_KhachHang;
GO

-- ====================================================================================
-- 3. BỔ SUNG QUYỀN CHO VAI TRÒ NHÂN VIÊN HIỆN CÓ
-- ====================================================================================

-- Quản lý bãi: xem tài chính / tài khoản khách (trừ cột mật khẩu), thao tác qua thủ tục nhân viên
GRANT SELECT ON dbo.PHUONG_THUC_THANH_TOAN TO r_QuanLyBai;
GRANT SELECT ON dbo.TAI_KHOAN_KH TO r_QuanLyBai;
DENY SELECT ON dbo.TAI_KHOAN_KH (MatKhauHash, MatKhauSalt) TO r_QuanLyBai;
GRANT SELECT ON dbo.NHAT_KY_DANG_NHAP TO r_QuanLyBai;
GRANT SELECT ON dbo.VI_DIEN_TU TO r_QuanLyBai;
GRANT SELECT ON dbo.GIAO_DICH TO r_QuanLyBai;
GRANT SELECT ON dbo.THONG_BAO TO r_QuanLyBai;
GRANT SELECT ON dbo.UY_QUYEN_VE TO r_QuanLyBai;
GRANT SELECT ON dbo.QUYEN_KH TO r_QuanLyBai;
GRANT SELECT ON dbo.VAI_TRO_KH TO r_QuanLyBai;
GRANT SELECT ON dbo.VAI_TRO_QUYEN TO r_QuanLyBai;

GRANT EXECUTE ON dbo.sp_NV_HoanTien TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_NV_MoKhoaTaiKhoanKH TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_NV_NapTienTaiQuay TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoTuDongGiaHanVeThang TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoDoiSoatViDienTu TO r_QuanLyBai;

GRANT SELECT ON dbo.vw_Report_DoanhThuTheoPhuongThuc TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_TongQuanViDienTu TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_GiaoDichCanXuLy TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_BaoMatTaiKhoanKH TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_TyLeChuyenDoiOnline TO r_QuanLyBai;

-- Không vai trò nhân viên nào được sửa số dư hay sửa / xóa sổ cái (trigger vẫn chặn cả r_Admin)
DENY UPDATE ON dbo.VI_DIEN_TU TO r_QuanLyBai;
DENY INSERT, UPDATE, DELETE ON dbo.GIAO_DICH TO r_QuanLyBai;
GO

-- Bảo vệ: không truy cập dữ liệu tài chính và tài khoản khách hàng
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN_KH TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.NHAT_KY_DANG_NHAP TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VI_DIEN_TU TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.GIAO_DICH TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.THONG_BAO TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.UY_QUYEN_VE TO r_BaoVe;
GO

-- ====================================================================================
-- 4. LỚP 2: ROW-LEVEL SECURITY
-- ====================================================================================
IF SCHEMA_ID('bao_mat') IS NULL
    EXEC('CREATE SCHEMA bao_mat AUTHORIZATION dbo');
GO

-- Hàm predicate gắn SCHEMABINDING vào bảng: phải gỡ policy trước khi sửa hàm
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'rls_KhachHang')
    DROP SECURITY POLICY bao_mat.rls_KhachHang;
GO

-- Quy tắc chung của mọi predicate:
--   USER_NAME() = 'dbo'                -> chủ CSDL / sa (ứng dụng demo hiện tại) và thủ tục WITH EXECUTE AS OWNER
--   IS_ROLEMEMBER('r_KhachHang') = 0   -> nhân viên (r_Admin, r_QuanLyBai, r_BaoVe)
--   còn lại                            -> khách hàng: chỉ dòng của khách trong SESSION_CONTEXT

-- Bảng có cột MaKH: VI_DIEN_TU, THONG_BAO, TAI_KHOAN_KH
CREATE OR ALTER FUNCTION bao_mat.fn_rls_KhachHang (@MaKH VARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR @MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- VE_THANG: vé của tôi + vé được ủy quyền còn hiệu lực cho tài khoản của tôi
CREATE OR ALTER FUNCTION bao_mat.fn_rls_VeThang (@MaVe VARCHAR(10), @MaKH VARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR @MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10))
       OR EXISTS (
            SELECT 1
            FROM dbo.UY_QUYEN_VE uq
            WHERE uq.MaVe = @MaVe
              AND uq.MaTKDuocUyQuyen = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12))
              AND uq.TrangThai = N'Hiệu lực'
              AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE)));
GO

-- GIAO_DICH: không có cột MaKH, tra chủ ví
CREATE OR ALTER FUNCTION bao_mat.fn_rls_GiaoDich (@MaVi VARCHAR(12))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR EXISTS (
            SELECT 1
            FROM dbo.VI_DIEN_TU vi
            WHERE vi.MaVi = @MaVi
              AND vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10)));
GO

-- LUOT_GUI, HOA_DON_VE_THANG: theo vé (lượt gửi thẻ lượt có MaVe NULL -> khách không thấy)
CREATE OR ALTER FUNCTION bao_mat.fn_rls_TheoVe (@MaVe VARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR EXISTS (
            SELECT 1
            FROM dbo.VE_THANG v
            WHERE v.MaVe = @MaVe
              AND (v.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10))
                   OR EXISTS (
                        SELECT 1
                        FROM dbo.UY_QUYEN_VE uq
                        WHERE uq.MaVe = v.MaVe
                          AND uq.MaTKDuocUyQuyen = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12))
                          AND uq.TrangThai = N'Hiệu lực'
                          AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE)))));
GO

CREATE SECURITY POLICY bao_mat.rls_KhachHang
    ADD FILTER PREDICATE bao_mat.fn_rls_KhachHang(MaKH) ON dbo.VI_DIEN_TU,
    ADD FILTER PREDICATE bao_mat.fn_rls_KhachHang(MaKH) ON dbo.THONG_BAO,
    ADD FILTER PREDICATE bao_mat.fn_rls_KhachHang(MaKH) ON dbo.TAI_KHOAN_KH,
    ADD FILTER PREDICATE bao_mat.fn_rls_VeThang(MaVe, MaKH) ON dbo.VE_THANG,
    ADD FILTER PREDICATE bao_mat.fn_rls_GiaoDich(MaVi) ON dbo.GIAO_DICH,
    ADD FILTER PREDICATE bao_mat.fn_rls_TheoVe(MaVe) ON dbo.LUOT_GUI,
    ADD FILTER PREDICATE bao_mat.fn_rls_TheoVe(MaVe) ON dbo.HOA_DON_VE_THANG
WITH (STATE = ON);
GO
