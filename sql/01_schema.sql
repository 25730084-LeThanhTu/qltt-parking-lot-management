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
