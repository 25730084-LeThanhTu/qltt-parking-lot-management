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
