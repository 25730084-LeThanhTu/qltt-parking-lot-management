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
    @MaBaiBan VARCHAR(10) = NULL -- Bãi bán vé / thu tiền (dùng cho vé toàn chuỗi 'ALL')
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Email = NULLIF(LTRIM(RTRIM(@Email)), ''); -- Email rỗng lưu NULL (UQ_KhachHang_Email chỉ áp dụng khi có email)
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
        -- Vé gắn một bãi: tính giá và ghi doanh thu tại bãi đó.
        -- Vé toàn chuỗi 'ALL': tính giá và ghi doanh thu tại bãi bán vé (@MaBaiBan), mặc định là bãi phát hành thẻ.
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

        -- 3. Chuyển đổi trạng thái thẻ sang Thẻ Tháng
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
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 4. Procedure sp_GiaHanTheThang: Gia hạn thời hạn sử dụng vé tháng và xuất biên lai
CREATE OR ALTER PROCEDURE dbo.sp_GiaHanTheThang
(
    @MaVe VARCHAR(10),
    @SoThangGiaHan INT = 1,
    @MaBaiGiaHan VARCHAR(10) = NULL -- Bãi thu tiền: vé gắn bãi chỉ thu tại bãi áp dụng; vé 'ALL' mặc định là bãi phát hành thẻ
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.VE_THANG WHERE MaVe = @MaVe)
    BEGIN
        THROW 50012, N'Lỗi: Không tìm thấy vé tháng cần gia hạn!', 1;
        RETURN;
    END;

    BEGIN TRANSACTION;

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

        INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai)
        VALUES (@MaHD, @MaVe, GETDATE(), @SoThangGiaHan, @SoTien, @MaBaiTinhGia);

        COMMIT TRANSACTION;

        SELECT
            @MaVe AS MaVe,
            @MaThe AS MaThe,
            @NgayHetHanCu AS HanCu,
            @NgayHetHanMoi AS HanMoi,
            @MaHD AS MaHoaDon,
            @MaBaiTinhGia AS MaBaiThuTien,
            @SoTien AS SoTienGiaHan,
            N'Gia hạn vé tháng thành công' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
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
