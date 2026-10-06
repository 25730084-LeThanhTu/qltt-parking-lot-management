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
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- NÂNG CẤP V7 - BƯỚC 12: FUNCTIONS CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 6)
-- Chạy trước procedures (13), triggers (14), cursors (15), views (16) và RLS (17).
-- ====================================================================================

-- 1. Function f_BamMatKhau: Băm mật khẩu SHA2_512 có salt.
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
