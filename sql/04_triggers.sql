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
        THROW 50007, N'Lỗi: Loại xe không tồn tại tại bãi áp dụng của vé tháng, mã bãi không hợp lệ hoặc thẻ không thuộc bãi áp dụng!', 1;
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