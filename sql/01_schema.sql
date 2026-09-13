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
