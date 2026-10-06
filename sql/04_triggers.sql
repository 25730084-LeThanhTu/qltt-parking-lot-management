-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- TRIGGERS V6 + V7 MERGED (2026-10-06)
-- V6: 4 triggers (check-in, check-out, slot status, log history)
-- V7: 8 triggers (sổ cái ví, ủy quyền, tài khoản, vé, thông báo) + edits
-- ====================================================================================

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
        INNER JOIN dbo.VE_THANG vt ON tx.MaThe = vt.MaThe
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
-- ==================== V7 TRIGGERS ADDITIONS ====================


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

    -- Safeguard cuối: Kiểm tra lại SoDu >= 0 sau UPDATE (phòng trường hợp bypass)
    IF EXISTS (SELECT 1 FROM dbo.VI_DIEN_TU WHERE MaVi IN (SELECT MaVi FROM @Vi) AND SoDu < 0)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50031, N'Lỗi: Số dư ví không thể âm. Giao dịch bị từ chối!', 1;
    END;

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
        WHERE (SELECT COUNT(*) FROM dbo.UY_QUYEN_VE u WHERE u.MaVe = x.MaVe AND u.TrangThai = N'Hiệu lực') > 3
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

-- 7.5. trg_VeThang_CapNhatTrangThai: Tự động cập nhật trạng thái vé dựa trên NgayHetHan (State Machine)
-- Khi NgayHetHan được cập nhật, trigger kiểm tra:
-- - Nếu NgayHetHan >= hôm nay -> TrangThai = 'Hoạt động'
-- - Nếu NgayHetHan < hôm nay -> TrangThai = 'Hết hạn'
CREATE OR ALTER TRIGGER dbo.trg_VeThang_CapNhatTrangThai
ON dbo.VE_THANG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(NgayHetHan) AND @@NESTLEVEL > 1
        RETURN;

    UPDATE v
    SET v.TrangThai = CASE
        WHEN i.NgayHetHan >= CAST(GETDATE() AS DATE) THEN N'Hoạt động'
        ELSE N'Hết hạn'
    END
    FROM dbo.VE_THANG v
    INNER JOIN inserted i ON i.MaVe = v.MaVe
    WHERE v.TrangThai <> CASE
        WHEN i.NgayHetHan >= CAST(GETDATE() AS DATE) THEN N'Hoạt động'
        ELSE N'Hết hạn'
    END;
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
