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
