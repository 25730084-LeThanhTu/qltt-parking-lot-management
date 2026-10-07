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
