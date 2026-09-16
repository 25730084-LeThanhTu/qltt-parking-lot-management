-- ====================================================================================
-- DỰ ÁN HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BẢN SCRIPT ĐỒNG BỘ TOÀN DIỆN V6 (FULL AUTOMATED SCRIPT: 11 BẢNG, PROCEDURES, RBAC)
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


-- ==================== BẮT ĐẦU: 01_schema.sql (11 BẢNG VẬT LÝ) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 1: TẠO CẤU TRÚC BẢNG CƠ SỞ DỮ LIỆU VẬT LÝ (11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

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
    CONSTRAINT UQ_NhanVien_Email UNIQUE (Email),
    CONSTRAINT FK_NhanVien_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)
);
GO

-- 3. Bảng TAI_KHOAN: Tài khoản truy cập & Xác thực nhân viên (Phân hệ An toàn thông tin)
CREATE TABLE dbo.TAI_KHOAN (
    TenDangNhap VARCHAR(50) NOT NULL,
    MatKhauHash VARCHAR(255) NOT NULL,
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
    CONSTRAINT UQ_KhachHang_Email UNIQUE (Email),
    CONSTRAINT UQ_KhachHang_CMND UNIQUE (CMND_CCCD)
);
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
    CONSTRAINT UQ_VeThang_MaThe UNIQUE (MaThe),
    CONSTRAINT FK_VeThang_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe),
    CONSTRAINT FK_VeThang_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH),
    CONSTRAINT CK_VeThang_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Hết hạn')),
    CONSTRAINT CK_VeThang_Han CHECK (NgayHetHan >= NgayDangKy)
);
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


-- ==================== BẮT ĐẦU: 02_sample_data.sql (DỮ LIỆU MẪU KHỞI TẠO 11 BẢNG) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 2: NẠP DỮ LIỆU KHỞI TẠO MẪU (SAMPLE DATA CHO 11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

-- 1. Nạp danh sách Bãi Đỗ Xe (3 chi nhánh)
INSERT INTO dbo.BAI_DO_XE (MaBai, TenBai, DiaChi, SucChua, SoLuongHienTai) VALUES
('BAI_Q1', N'Bãi xe Lê Lai - Bến Thành', N'Số 26 Lê Lai, Phường Bến Thành, Quận 1, TP.HCM', 15, 0),
('BAI_Q3', N'Bãi xe Hai Bà Trưng', N'Số 180 Hai Bà Trưng, Phường Đa Kao, Quận 3, TP.HCM', 15, 0),
('BAI_BT', N'Bãi xe Landmark 81', N'Số 208 Nguyễn Hữu Cảnh, Phường 22, Bình Thạnh, TP.HCM', 20, 0);
GO

-- 2. Nạp Hồ sơ Nhân Viên (NHAN_VIEN: Ban giám đốc, Quản lý bãi, Bảo vệ ca trực)
INSERT INTO dbo.NHAN_VIEN (MaNV, HoTen, ChucVu, SDT, Email, MaBai) VALUES
('NV001', N'Nguyễn Hữu Trí', N'Giám đốc điều hành', '0901000001', 'tri.nguyen@smartparking.vn', NULL),
('NV002', N'Trần Văn Hùng', N'Quản lý bãi', '0901000002', 'hung.tran@smartparking.vn', 'BAI_Q1'),
('NV003', N'Lê Thị Bích Ngọc', N'Quản lý bãi', '0901000003', 'ngoc.le@smartparking.vn', 'BAI_Q3'),
('NV004', N'Hoàng Đình Nam', N'Quản lý bãi', '0901000004', 'nam.hoang@smartparking.vn', 'BAI_BT'),
('NV005', N'Phạm Văn Cường', N'Bảo vệ', '0901000005', 'cuong.pham@smartparking.vn', 'BAI_Q1'),
('NV006', N'Đặng Minh Tuấn', N'Bảo vệ', '0901000006', 'tuan.dang@smartparking.vn', 'BAI_Q3'),
('NV007', N'Vũ Đức Thắng', N'Bảo vệ', '0901000007', 'thang.vu@smartparking.vn', 'BAI_BT');
GO

-- 3. Nạp Tài Khoản Truy Cập & Mật khẩu mã hóa HASH SHA-256 (TAI_KHOAN)
-- Mật khẩu mặc định:
-- 'Admin@2026' cho admin -> HASH: CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin@2026'), 2)
-- '123456' cho các tài khoản còn lại -> HASH: CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2)
INSERT INTO dbo.TAI_KHOAN (TenDangNhap, MatKhauHash, MaNV, TrangThai) VALUES
('admin', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin@2026'), 2), 'NV001', N'Hoạt động'),
('quanly_q1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV002', N'Hoạt động'),
('quanly_q3', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV003', N'Hoạt động'),
('quanly_bt', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV004', N'Hoạt động'),
('baove_q1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV005', N'Hoạt động'),
('baove_q3', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV006', N'Hoạt động'),
('baove_bt', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV007', N'Hoạt động'),
('baove_khoa', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV005', N'Bị khóa');
GO

-- 4. Nạp Phân Loại Phương Tiện & Biểu Phí theo từng Bãi Đỗ
INSERT INTO dbo.LOAI_XE (MaLoaiXe, MaBai, TenLoai, DonGiaGio, GiaVeThang) VALUES
('XM', 'BAI_Q1', N'Xe máy', 6000, 180000),
('OT', 'BAI_Q1', N'Ô tô 4-7 chỗ', 25000, 1800000),
('XD', 'BAI_Q1', N'Xe đạp / Xe điện', 3000, 80000),

('XM', 'BAI_Q3', N'Xe máy', 5000, 150000),
('OT', 'BAI_Q3', N'Ô tô 4-7 chỗ', 20000, 1500000),
('XD', 'BAI_Q3', N'Xe đạp / Xe điện', 2000, 60000),

('XM', 'BAI_BT', N'Xe máy', 7000, 200000),
('OT', 'BAI_BT', N'Ô tô 4-7 chỗ', 30000, 2200000),
('XD', 'BAI_BT', N'Xe đạp / Xe điện', 4000, 90000);
GO

-- 5. Nạp danh mục Vị Trí Ô Đỗ Xe Vật Lý (34 vị trí trên 3 bãi)
INSERT INTO dbo.VI_TRI_DO (MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai) VALUES
-- Bãi Quận 1 (12 vị trí)
('Q1_XM_01', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_02', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_03', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_04', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_05', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_06', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_OT_01', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_02', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_03', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_04', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_XD_01', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XD_02', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),

-- Bãi Quận 3 (10 vị trí)
('Q3_XM_01', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_02', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_03', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_04', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_05', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_OT_01', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_02', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_03', N'Khu Ô tô Sân 2', N'Trống', 'OT', 'BAI_Q3'),
('Q3_XD_01', N'Khu Xe đạp 1', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XD_02', N'Khu Xe đạp 2', N'Trống', 'XD', 'BAI_Q3'),

-- Bãi Bình Thạnh (12 vị trí)
('BT_XM_01', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_02', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_03', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_04', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_05', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_06', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_OT_01', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_03', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_XD_01', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XD_02', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT');
GO

-- 6. Nạp Kho Thẻ Xe (THE_XE)
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
-- Thẻ Quận 1
('THE0001', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0002', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-01'),
('THE0003', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0004', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-10'),
('THE0005', 'BAI_Q1', N'Lượt', N'Bị khóa', '2026-01-12'),
('THE0006', 'BAI_Q1', N'Lượt', N'Mất', '2026-01-15'),

-- Thẻ Quận 3
('THE0007', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0008', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-03'),
('THE0009', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0010', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-08'),

-- Thẻ Bình Thạnh
('THE0011', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0012', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-02'),
('THE0013', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0014', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-06'),
('THE0015', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-10');
GO

-- 7. Nạp Hồ sơ Khách Hàng (KHACH_HANG)
INSERT INTO dbo.KHACH_HANG (MaKH, HoTen, SDT, Email, CMND_CCCD) VALUES
('KH0001', N'Nguyễn Văn An', '0903112233', 'nguyenvanan@gmail.com', '079090001111'),
('KH0002', N'Trần Thị Mai', '0912445566', 'tranmai.hcm@gmail.com', '079090002222'),
('KH0003', N'Lê Hoàng Long', '0988776655', 'long.lehoang@yahoo.com', '079090003333'),
('KH0004', N'Phạm Thu Trang', '0934556677', 'trangpham@outlook.com', '079090004444'),
('KH0005', N'Võ Minh Quân', '0977112244', 'quan.vominh@gmail.com', '079090005555');
GO

-- 8. Nạp Đăng Ký Vé Tháng (VE_THANG)
INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung) VALUES
('V0001', 'THE0002', 'KH0001', '59A-123.45', 'XM', '2026-01-01', '2026-12-31', N'Hoạt động', 'BAI_Q1'),
('V0002', 'THE0004', 'KH0002', '51G-888.99', 'OT', '2026-01-10', '2026-10-10', N'Hoạt động', 'BAI_Q1'),
('V0003', 'THE0008', 'KH0003', '59B-456.78', 'XM', '2026-01-03', '2026-02-03', N'Hết hạn', 'BAI_Q3'),
('V0004', 'THE0010', 'KH0004', '51H-999.11', 'OT', '2026-01-08', '2026-11-08', N'Hoạt động', 'ALL'),
('V0005', 'THE0012', 'KH0005', '59C-678.90', 'XM', '2026-01-02', '2026-12-31', N'Hoạt động', 'BAI_BT');
GO

-- 9. Nạp Lịch Sử Thu Tiền Vé Tháng (HOA_DON_VE_THANG)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai) VALUES
('HD20260101001', 'V0001', '2026-01-01 08:30:00', 12, 2160000, 'BAI_Q1'),
('HD20260110002', 'V0002', '2026-01-10 09:15:00', 9, 16200000, 'BAI_Q1'),
('HD20260103003', 'V0003', '2026-01-03 14:00:00', 1, 150000, 'BAI_Q3'),
('HD20260108004', 'V0004', '2026-01-08 10:20:00', 10, 15000000, 'BAI_Q3'),
('HD20260102005', 'V0005', '2026-01-02 16:45:00', 12, 2400000, 'BAI_BT');
GO

-- 10. Nạp Nhật Ký Lượt Gửi Xe (LUOT_GUI)
-- Một số lượt đã check-out
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59A-111.22', '2026-09-07 07:15:00', '2026-09-07 11:15:00', 'Q1_XM_01', 24000, 'BAI_Q1'),
('THE0003', '51G-222.33', '2026-09-07 08:00:00', '2026-09-07 14:00:00', 'Q1_OT_01', 150000, 'BAI_Q1'),
('THE0007', '59B-333.44', '2026-09-07 09:30:00', '2026-09-07 12:30:00', 'Q3_XM_01', 15000, 'BAI_Q3'),
('THE0011', '59C-444.55', '2026-09-07 06:45:00', '2026-09-07 17:45:00', 'BT_XM_01', 77000, 'BAI_BT');

-- Một số lượt hiện đang đỗ (ThoiGianRa IS NULL)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59K-987.65', DATEADD(HOUR, -2, GETDATE()), NULL, 'Q1_XM_02', 0, 'BAI_Q1'),
('THE0002', '59A-123.45', DATEADD(HOUR, -4, GETDATE()), NULL, 'Q1_XM_03', 0, 'BAI_Q1'),
('THE0007', '59E-555.66', DATEADD(HOUR, -1, GETDATE()), NULL, 'Q3_XM_02', 0, 'BAI_Q3'),
('THE0013', '51A-777.88', DATEADD(HOUR, -3, GETDATE()), NULL, 'BT_OT_01', 0, 'BAI_BT');

-- Cập nhật đồng bộ ô đỗ tương ứng sang 'Đã đỗ' và bãi đỗ tăng xe
UPDATE dbo.VI_TRI_DO SET TrangThai = N'Đã đỗ' WHERE MaViTri IN ('Q1_XM_02', 'Q1_XM_03', 'Q3_XM_02', 'BT_OT_01');
UPDATE dbo.BAI_DO_XE SET SoLuongHienTai = 2 WHERE MaBai = 'BAI_Q1';
UPDATE dbo.BAI_DO_XE SET SoLuongHienTai = 1 WHERE MaBai = 'BAI_Q3';
UPDATE dbo.BAI_DO_XE SET SoLuongHienTai = 1 WHERE MaBai = 'BAI_BT';
GO

-- 11. Nạp Nhật Ký Sự Cố (LICHSU_SU_CO)
INSERT INTO dbo.LICHSU_SU_CO (MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai) VALUES
('THE0006', '59X-999.01', '2026-01-15 11:00:00', N'Khách hàng làm rơi thẻ xe tại quầy nước, lập biên bản báo mất thẻ chip', 50000, N'Đã giải quyết', 'BAI_Q1'),
(NULL, '51B-123.45', '2026-02-10 18:30:00', N'Va quẹt nhẹ gương chiếu hậu khi lùi xe vào ô đỗ Q3_OT_01', 200000, N'Đã giải quyết', 'BAI_Q3');
GO


-- ==================== BẮT ĐẦU: 05_functions.sql (3 DATABASE FUNCTIONS) ====================
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


-- ==================== BẮT ĐẦU: 04_triggers.sql (5 DATABASE TRIGGERS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 4: DATABASE TRIGGERS (5 TRIGGERS NGHIỆP VỤ TỰ ĐỘNG)
-- ====================================================================================

-- 1. Trigger trg_KiemTraCheckIn: Chặn xe vào nếu thẻ bị khóa/mất hoặc bãi xe đầy
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

    -- Kiểm tra bãi đỗ xe đã đầy công suất chưa
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN dbo.BAI_DO_XE b ON i.MaBai = b.MaBai
        WHERE b.SoLuongHienTai >= b.SucChua
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Lỗi: Bãi đỗ xe đã đầy công suất! Vui lòng điều phối xe sang bãi khác.', 1;
        RETURN;
    END;
END;
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
        INNER JOIN dbo.VE_THANG vt ON tx.MaThe = vt.MaThe
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
    LEFT JOIN dbo.VE_THANG vt ON i.MaThe = vt.MaThe
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


-- ==================== BẮT ĐẦU: 03_procedures.sql (6 STORED PROCEDURES) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 5: STORED PROCEDURES (6 PROCEDURES NGHIỆP VỤ CỐT LÕI)
-- ====================================================================================

-- 1. Procedure sp_XeVaoBai: Quản lý Check-In xe vào cổng bãi
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

    -- Tìm ô đỗ trống khả dụng thông qua Function
    DECLARE @SlotTrong VARCHAR(20) = dbo.f_TimSlotTrong(@MaBai, @MaLoaiXe);
    IF @SlotTrong IS NULL
    BEGIN
        THROW 50010, N'Lỗi: Không còn ô đỗ trống phù hợp loại xe tại bãi này!', 1;
        RETURN;
    END;

    -- Tạo lượt gửi xe mới (Trigger trg_KiemTraCheckIn và trg_DongBoTrangThaiSlot sẽ tự động can thiệp)
    INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai)
    VALUES (@MaThe, @BienSo, GETDATE(), NULL, @SlotTrong, 0, @MaBai);

    SET @MaLuot = SCOPE_IDENTITY();
    SET @MaViTri = @SlotTrong;

    SELECT 
        @MaLuot AS MaLuot,
        @MaThe AS MaThe,
        @BienSo AS BienSo,
        @MaBai AS MaBai,
        @MaViTri AS ViTriDoDuocCap,
        N'Check-In thành công' AS ThongBao;
END;
GO

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

-- 3. Procedure sp_DangKyThanhVien: Đăng ký vé tháng an toàn trong TRANSACTION
CREATE OR ALTER PROCEDURE dbo.sp_DangKyThanhVien
(
    @MaKH VARCHAR(10),
    @HoTen NVARCHAR(100),
    @SDT VARCHAR(15),
    @CMND VARCHAR(12),
    @MaThe VARCHAR(10),
    @BienSo VARCHAR(15),
    @MaLoaiXe VARCHAR(10),
    @MaBaiApDung VARCHAR(10),
    @SoThangDongTruoc INT = 1,
    @Email VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Lưu thông tin khách hàng (nếu chưa có thì thêm, có rồi thì cập nhật)
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

        -- 2. Chuyển đổi trạng thái thẻ sang Thẻ Tháng
        UPDATE dbo.THE_XE
        SET LoaiThe = N'Tháng', TrangThai = N'Hoạt động'
        WHERE MaThe = @MaThe;

        -- 3. Sinh mã vé tháng mới và tính hạn dùng
        DECLARE @MaVe VARCHAR(10) = CONCAT('V', FORMAT(GETDATE(), 'yyMMddHHmm'));
        DECLARE @NgayHetHan DATE = DATEADD(MONTH, @SoThangDongTruoc, CAST(GETDATE() AS DATE));

        INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung)
        VALUES (@MaVe, @MaThe, @MaKH, @BienSo, @MaLoaiXe, CAST(GETDATE() AS DATE), @NgayHetHan, N'Hoạt động', @MaBaiApDung);

        -- 4. Tính tiền và xuất hóa đơn
        DECLARE @DonGiaThang DECIMAL(18,2);
        DECLARE @MaBaiTinhGia VARCHAR(10) = CASE WHEN @MaBaiApDung = 'ALL' THEN (SELECT TOP 1 MaBai FROM dbo.BAI_DO_XE ORDER BY MaBai) ELSE @MaBaiApDung END;

        SELECT @DonGiaThang = GiaVeThang
        FROM dbo.LOAI_XE
        WHERE MaLoaiXe = @MaLoaiXe AND MaBai = @MaBaiTinhGia;

        IF @DonGiaThang IS NULL SET @DonGiaThang = 180000;
        DECLARE @TongTien DECIMAL(18,2) = @DonGiaThang * @SoThangDongTruoc;
        DECLARE @MaHD VARCHAR(15) = CONCAT('HD', FORMAT(GETDATE(), 'yyyyMMddHHmmss'));

        INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai)
        VALUES (@MaHD, @MaVe, GETDATE(), @SoThangDongTruoc, @TongTien, @MaBaiTinhGia);

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
            N'Đăng ký vé tháng thành công' AS TrangThai;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 4. Procedure sp_GiaHanTheThang: Gia hạn thời hạn sử dụng vé tháng và xuất biên lai
CREATE OR ALTER PROCEDURE dbo.sp_GiaHanTheThang
(
    @MaVe VARCHAR(10),
    @SoThangGiaHan INT = 1,
    @MaBaiGiaHan VARCHAR(10) = 'BAI_Q1'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.VE_THANG WHERE MaVe = @MaVe)
    BEGIN
        THROW 50012, N'Lỗi: Không tìm thấy vé tháng cần gia hạn!', 1;
        RETURN;
    END;

    DECLARE @NgayHetHanCu DATE;
    DECLARE @MaThe VARCHAR(10);
    DECLARE @MaLoaiXe VARCHAR(10);

    SELECT 
        @NgayHetHanCu = NgayHetHan,
        @MaThe = MaThe,
        @MaLoaiXe = MaLoaiXe
    FROM dbo.VE_THANG
    WHERE MaVe = @MaVe;

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
    WHERE MaThe = @MaThe;

    -- Tính tiền và tạo hóa đơn
    DECLARE @DonGiaThang DECIMAL(18,2);
    SELECT @DonGiaThang = GiaVeThang
    FROM dbo.LOAI_XE
    WHERE MaLoaiXe = @MaLoaiXe AND MaBai = @MaBaiGiaHan;

    IF @DonGiaThang IS NULL SET @DonGiaThang = 180000;
    DECLARE @SoTien DECIMAL(18,2) = @DonGiaThang * @SoThangGiaHan;
    DECLARE @MaHD VARCHAR(15) = CONCAT('HDGH', FORMAT(GETDATE(), 'yyMMddHHmmss'));

    INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai)
    VALUES (@MaHD, @MaVe, GETDATE(), @SoThangGiaHan, @SoTien, @MaBaiGiaHan);

    SELECT 
        @MaVe AS MaVe,
        @MaThe AS MaThe,
        @NgayHetHanCu AS HanCu,
        @NgayHetHanMoi AS HanMoi,
        @MaHD AS MaHoaDon,
        @SoTien AS SoTienGiaHan,
        N'Gia hạn vé tháng thành công' AS ThongBao;
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

    -- Khóa vé tháng liên kết (nếu có)
    UPDATE dbo.VE_THANG
    SET TrangThai = N'Tạm khóa'
    WHERE MaThe = @MaTheBaoMat;

    SELECT 
        @MaTheBaoMat AS MaThe,
        N'Mất' AS TrangThaiTheMoi,
        50000 AS TienPhatDenBu,
        N'Đã khóa thẻ và tự động ghi nhận biên bản sự cố' AS KetQua;
END;
GO

-- 6. Procedure sp_DangNhap: Kiểm tra tài khoản, đối chiếu mật khẩu băm SHA-256 và phân quyền
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
    DECLARE @MatKhauHashTrongDB VARCHAR(255);
    DECLARE @MaNV VARCHAR(10);

    SELECT 
        @TrangThai = TrangThai,
        @MatKhauHashTrongDB = MatKhauHash,
        @MaNV = MaNV
    FROM dbo.TAI_KHOAN
    WHERE TenDangNhap = @TenDangNhap;

    IF @TrangThai = N'Bị khóa'
    BEGIN
        THROW 50021, N'Lỗi: Tài khoản hiện đang bị khóa! Vui lòng liên hệ Quản trị viên.', 1;
        RETURN;
    END;

    -- Băm mật khẩu người dùng nhập bằng SHA-256
    DECLARE @InputHash VARCHAR(64) = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @MatKhauPlain), 2);

    -- Đối chiếu chuỗi Hash
    IF @InputHash <> @MatKhauHashTrongDB
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


-- ==================== BẮT ĐẦU: 06_cursors.sql (2 DATABASE CURSORS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 6: DATABASE CURSORS (2 CURSORS BỌC TRONG PROCEDURES ĐỂ DEMO)
-- ====================================================================================

-- 1. Procedure sp_DemoCanhBaoHanTheThang: Quét kiểm tra và tự động xử lý vé tháng hết hạn
CREATE OR ALTER PROCEDURE dbo.sp_DemoCanhBaoHanTheThang
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm để lưu danh sách xử lý và hiển thị ra màn hình
    CREATE TABLE #KetQuaQuet (
        STT INT IDENTITY(1,1) PRIMARY KEY,
        MaVe VARCHAR(10),
        MaThe VARCHAR(10),
        BienSo VARCHAR(15),
        NgayHetHan DATE,
        SoNgayConLai INT,
        HanhDong NVARCHAR(150),
        TrangThaiVe NVARCHAR(20)
    );

    DECLARE @MaVe VARCHAR(10);
    DECLARE @MaThe VARCHAR(10);
    DECLARE @BienSo VARCHAR(15);
    DECLARE @NgayHetHan DATE;
    DECLARE @TrangThai NVARCHAR(20);

    -- Khai báo Cursor duyệt qua toàn bộ vé tháng
    DECLARE cur_VeThang CURSOR FOR
    SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai
    FROM dbo.VE_THANG;

    OPEN cur_VeThang;
    FETCH NEXT FROM cur_VeThang INTO @MaVe, @MaThe, @BienSo, @NgayHetHan, @TrangThai;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @SoNgay INT = DATEDIFF(DAY, CAST(GETDATE() AS DATE), @NgayHetHan);

        IF @SoNgay < 0
        BEGIN
            -- Quá hạn: Khóa vé và khóa thẻ xe
            UPDATE dbo.VE_THANG SET TrangThai = N'Hết hạn' WHERE MaVe = @MaVe;
            UPDATE dbo.THE_XE SET TrangThai = N'Bị khóa' WHERE MaThe = @MaThe;

            INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
            VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay, N'ĐÃ QUÁ HẠN: Tự động khóa thẻ và đổi trạng thái hết hạn', N'Hết hạn');
        END
        ELSE IF @SoNgay <= 3
        BEGIN
            -- Sắp hết hạn trong 3 ngày
            INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
            VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay, CONCAT(N'CẢNH BÁO: Sắp hết hạn trong ', @SoNgay, N' ngày. Gửi SMS/Email nhắc nộp phí.'), @TrangThai);
        END
        ELSE
        BEGIN
            -- Hạn dùng an toàn
            INSERT INTO #KetQuaQuet (MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe)
            VALUES (@MaVe, @MaThe, @BienSo, @NgayHetHan, @SoNgay, N'Còn hạn an toàn', @TrangThai);
        END;

        FETCH NEXT FROM cur_VeThang INTO @MaVe, @MaThe, @BienSo, @NgayHetHan, @TrangThai;
    END;

    CLOSE cur_VeThang;
    DEALLOCATE cur_VeThang;

    SELECT * FROM #KetQuaQuet ORDER BY SoNgayConLai ASC;
    DROP TABLE #KetQuaQuet;
END;
GO

-- 2. Procedure sp_DemoTongKetDoanhThuChuoi: Thống kê doanh thu từng bãi bằng CURSOR
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
        TongDoanhThu DECIMAL(18,2),
        DanhGiaHieuQua NVARCHAR(100)
    );

    DECLARE @MaBai VARCHAR(10);
    DECLARE @TenBai NVARCHAR(100);

    -- Cursor duyệt qua từng bãi đỗ xe
    DECLARE cur_BaiDo CURSOR FOR
    SELECT MaBai, TenBai FROM dbo.BAI_DO_XE ORDER BY MaBai;

    OPEN cur_BaiDo;
    FETCH NEXT FROM cur_BaiDo INTO @MaBai, @TenBai;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @TienLuot DECIMAL(18,2) = 0;
        DECLARE @TienThang DECIMAL(18,2) = 0;

        SELECT @TienLuot = ISNULL(SUM(TienGui), 0)
        FROM dbo.LUOT_GUI
        WHERE MaBai = @MaBai;

        SELECT @TienThang = ISNULL(SUM(SoTien), 0)
        FROM dbo.HOA_DON_VE_THANG
        WHERE MaBai = @MaBai;

        DECLARE @Tong DECIMAL(18,2) = @TienLuot + @TienThang;
        DECLARE @DanhGia NVARCHAR(100);

        IF @Tong >= 10000000
            SET @DanhGia = N'Hiệu quả rất cao (Doanh thu > 10 triệu)';
        ELSE IF @Tong >= 2000000
            SET @DanhGia = N'Hiệu quả tốt';
        ELSE
            SET @DanhGia = N'Cần đẩy mạnh khai thác thêm lượt gửi';

        INSERT INTO #BaoCaoDoanhThu (MaBai, TenBai, DoanhThuLuot, DoanhThuThang, TongDoanhThu, DanhGiaHieuQua)
        VALUES (@MaBai, @TenBai, @TienLuot, @TienThang, @Tong, @DanhGia);

        FETCH NEXT FROM cur_BaiDo INTO @MaBai, @TenBai;
    END;

    CLOSE cur_BaiDo;
    DEALLOCATE cur_BaiDo;

    SELECT * FROM #BaoCaoDoanhThu ORDER BY TongDoanhThu DESC;
    DROP TABLE #BaoCaoDoanhThu;
END;
GO


-- ==================== BẮT ĐẦU: 07_views.sql (8 DATABASE VIEWS) ====================
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 7: DATABASE VIEWS (8 VIEWS: 3 VIEWS VẬN HÀNH BLUEPRINT V6 + 5 VIEWS BÁO CÁO BI)
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

-- 5. View vw_Report_DoanhThuTheoBai: Báo cáo tài chính tổng hợp phân bổ theo bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoBai
AS
SELECT 
    bd.MaBai,
    bd.TenBai,
    ISNULL(sub_luot.TienLuot, 0) AS DoanhThuLuot,
    ISNULL(sub_thang.TienThang, 0) AS DoanhThuThang,
    (ISNULL(sub_luot.TienLuot, 0) + ISNULL(sub_thang.TienThang, 0)) AS TongDoanhThu
FROM dbo.BAI_DO_XE bd
LEFT JOIN (
    SELECT MaBai, SUM(TienGui) AS TienLuot
    FROM dbo.LUOT_GUI
    GROUP BY MaBai
) sub_luot ON bd.MaBai = sub_luot.MaBai
LEFT JOIN (
    SELECT MaBai, SUM(SoTien) AS TienThang
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


-- ==================== BẮT ĐẦU: 08_security_rbac.sql (PHÂN QUYỀN RBAC 3 ROLES) ====================
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
