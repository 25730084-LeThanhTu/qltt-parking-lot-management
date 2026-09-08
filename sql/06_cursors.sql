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
