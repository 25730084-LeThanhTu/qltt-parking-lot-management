-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 7: DATABASE VIEWS (21 VIEWS)
-- PHẦN A: 3 views vận hành Blueprint V6 | PHẦN B: 5 views báo cáo BI
-- PHẦN C: 4 views bốt kiểm soát cổng vào/ra | PHẦN D: 3 views sơ đồ bãi xe realtime
-- PHẦN E: 6 views tổng hợp cho quản lý chuỗi bãi xe
-- ====================================================================================

-- ====================================================================================
-- PHẦN A: 3 VIEWS VẬN HÀNH THỜI GIAN THỰC (THEO THIẾT KẾ BLUEPRINT V6)
-- ====================================================================================

-- 1. View v_SodoOdoRealtime: Sơ đồ ô đỗ xe thời gian thực kèm thông tin xe đang chiếm chỗ
CREATE OR ALTER VIEW dbo.v_SodoOdoRealtime
AS
SELECT 
    v.MaBai,
    b.TenBai,
    v.MaViTri,
    v.KhuVuc,
    v.TrangThai,
    l.TenLoai,
    lg.BienSo,
    lg.ThoiGianVao
FROM dbo.VI_TRI_DO v
INNER JOIN dbo.BAI_DO_XE b ON v.MaBai = b.MaBai
INNER JOIN dbo.LOAI_XE l ON v.MaLoaiXe = l.MaLoaiXe AND v.MaBai = l.MaBai
LEFT JOIN dbo.LUOT_GUI lg ON v.MaViTri = lg.MaViTri AND lg.ThoiGianRa IS NULL;
GO

-- 2. View v_Xedangtrongbai: Danh sách các xe hiện diện trong bãi chưa làm thủ tục Check-Out
CREATE OR ALTER VIEW dbo.v_Xedangtrongbai
AS
SELECT 
    lg.MaLuot,
    lg.MaBai,
    b.TenBai,
    lg.MaThe,
    lg.BienSo,
    lg.MaViTri,
    lg.ThoiGianVao,
    t.LoaiThe
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
WHERE lg.ThoiGianRa IS NULL;
GO

-- 3. View v_DanhsachveThangsaphethan: Danh sách vé tháng còn dưới hoặc bằng 3 ngày sử dụng
CREATE OR ALTER VIEW dbo.v_DanhsachveThangsaphethan
AS
SELECT 
    vt.MaVe,
    vt.MaThe,
    kh.HoTen,
    kh.SDT,
    vt.BienSo,
    vt.NgayHetHan,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) AS SongayConLai,
    vt.MaBaiApDung
FROM dbo.VE_THANG vt
INNER JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) BETWEEN 0 AND 3
  AND vt.TrangThai = N'Hoạt động';
GO


-- ====================================================================================
-- PHẦN B: 5 VIEWS BÁO CÁO THỐNG KÊ QUẢN TRỊ & KINH DOANH (BI ANALYTICS)
-- ====================================================================================

-- 4. View vw_Report_CongSuatBaiDo: Giám sát tỷ lệ lấp đầy và chỗ trống theo từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_CongSuatBaiDo
AS
SELECT 
    bd.MaBai,
    bd.TenBai,
    bd.SucChua,
    bd.SoLuongHienTai,
    (bd.SucChua - bd.SoLuongHienTai) AS SoChoTrong,
    CAST(ROUND(CAST(bd.SoLuongHienTai AS FLOAT) * 100.0 / CAST(bd.SucChua AS FLOAT), 2) AS DECIMAL(5,2)) AS TyLeLapDayPercent
FROM dbo.BAI_DO_XE bd;
GO

-- 5. vw_Report_DoanhThuTheoBai: thêm DoanhThuThangTaiQuay, DoanhThuThangOnline (online + tự động)
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoBai
AS
SELECT 
    bd.MaBai,
    bd.TenBai,
    ISNULL(sub_luot.TienLuot, 0) AS DoanhThuLuot,
    ISNULL(sub_thang.TienThang, 0) AS DoanhThuThang,
    (ISNULL(sub_luot.TienLuot, 0) + ISNULL(sub_thang.TienThang, 0)) AS TongDoanhThu,
    -- Tách doanh thu vé tháng theo kênh thanh toán
    ISNULL(sub_thang.TienThangTaiQuay, 0) AS DoanhThuThangTaiQuay,
    ISNULL(sub_thang.TienThangOnline, 0) AS DoanhThuThangOnline
FROM dbo.BAI_DO_XE bd
LEFT JOIN (
    SELECT MaBai, SUM(TienGui) AS TienLuot
    FROM dbo.LUOT_GUI
    GROUP BY MaBai
) sub_luot ON bd.MaBai = sub_luot.MaBai
LEFT JOIN (
    SELECT MaBai,
           SUM(SoTien) AS TienThang,
           SUM(CASE WHEN KenhThanhToan = N'Tại quầy' THEN SoTien ELSE 0 END) AS TienThangTaiQuay,
           SUM(CASE WHEN KenhThanhToan IN (N'Online', N'Tự động') THEN SoTien ELSE 0 END) AS TienThangOnline
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaBai
) sub_thang ON bd.MaBai = sub_thang.MaBai;
GO

-- 6. View vw_Report_XeDangDoHienTai: Danh sách phương tiện đang hiện diện trong toàn chuỗi
CREATE OR ALTER VIEW dbo.vw_Report_XeDangDoHienTai
AS
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
    bd.TenBai
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.THE_XE tx ON lg.MaThe = tx.MaThe
INNER JOIN dbo.VI_TRI_DO vt ON lg.MaViTri = vt.MaViTri
INNER JOIN dbo.LOAI_XE lx ON vt.MaLoaiXe = lx.MaLoaiXe AND vt.MaBai = lx.MaBai
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
WHERE lg.ThoiGianRa IS NULL;
GO

-- 7. View vw_Report_VeThangSapHetHan: Danh sách vé tháng sắp hoặc đã hết hạn
CREATE OR ALTER VIEW dbo.vw_Report_VeThangSapHetHan
AS
SELECT 
    vt.MaVe,
    kh.HoTen AS HoTenKhachHang,
    kh.SDT,
    vt.BienSo,
    vt.MaLoaiXe,
    vt.NgayHetHan,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) AS SoNgayConLai,
    vt.TrangThai AS TrangThaiVe,
    vt.MaBaiApDung
FROM dbo.VE_THANG vt
INNER JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) <= 7;
GO

-- 8. View vw_Report_NhatKySuCo: Thống kê các sự cố an ninh và tiền phạt
CREATE OR ALTER VIEW dbo.vw_Report_NhatKySuCo
AS
SELECT 
    sc.MaSuCo,
    sc.MaThe,
    sc.BienSo,
    sc.ThoiGianSuCo,
    sc.MoTa,
    sc.TienPhat,
    sc.TrangThaiXuLy,
    bd.TenBai
FROM dbo.LICHSU_SU_CO sc
INNER JOIN dbo.BAI_DO_XE bd ON sc.MaBai = bd.MaBai;
GO


-- ====================================================================================
-- PHẦN C: 4 VIEWS PHỤC VỤ BỐT KIỂM SOÁT CỔNG VÀO / RA (GATE CONTROL KIOSK)
-- Mục tiêu: Bảo vệ trực cổng chỉ cần quét mã thẻ là có đủ dữ liệu quyết định
-- mở barrier (cho vào / cho ra), số tiền tạm tính và cảnh báo nghiệp vụ kèm theo.
-- ====================================================================================

-- 9. v_BotCong_TraCuuThe: thêm CoTaiKhoanOnline, TuDongGiaHan; gợi ý tự gia hạn online khi vé sắp hết hạn
CREATE OR ALTER VIEW dbo.v_BotCong_TraCuuThe
AS
WITH TheHienTai AS (
    SELECT
        t.MaThe,
        t.LoaiThe,
        t.TrangThai AS TrangThaiThe,
        t.NgayCap,
        t.MaBai AS MaBaiSoHuuThe,
        vt.MaVe,
        vt.MaKH,
        vt.BienSo AS BienSoDangKy,
        vt.MaLoaiXe AS MaLoaiXeDangKy,
        vt.NgayHetHan,
        vt.TrangThai AS TrangThaiVeThang,
        vt.MaBaiApDung,
        vt.TuDongGiaHan,
        -- Khách có tài khoản cổng khách hàng thì bảo vệ có thể hướng dẫn tự gia hạn online
        CAST(CASE WHEN tkkh.MaTK IS NULL THEN 0 ELSE 1 END AS BIT) AS CoTaiKhoanOnline,
        -- Vé tháng có MaBaiApDung không trỏ tới một bãi cụ thể (ví dụ 'ALL') là vé dùng chung toàn chuỗi
        CAST(CASE WHEN vt.MaVe IS NOT NULL AND bva.MaBai IS NULL THEN 1 ELSE 0 END AS BIT) AS VeApDungToanChuoi,
        kh.HoTen AS HoTenKhachHang,
        kh.SDT AS SDTKhachHang,
        lg.MaLuot AS MaLuotDangMo,
        lg.BienSo AS BienSoDangGui,
        lg.MaViTri AS MaViTriDangDo,
        lg.ThoiGianVao,
        -- Bãi kiểm soát lượt quét kế tiếp: ưu tiên bãi xe đang đỗ, kế đến bãi áp dụng vé tháng
        -- (chỉ khi trỏ tới một bãi cụ thể, nên vé toàn chuỗi 'ALL' sẽ rơi về bãi sở hữu thẻ)
        COALESCE(lg.MaBai, bva.MaBai, t.MaBai) AS MaBaiKiemSoat
    FROM dbo.THE_XE t
    OUTER APPLY dbo.f_VeHienHanhCuaThe(t.MaThe) vt   -- 1 dòng / thẻ kể cả thẻ đã cấp lại cho vé mới
    LEFT JOIN dbo.BAI_DO_XE bva ON vt.MaBaiApDung = bva.MaBai
    LEFT JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
    LEFT JOIN dbo.TAI_KHOAN_KH tkkh ON vt.MaKH = tkkh.MaKH
    OUTER APPLY (
        SELECT TOP 1 l.MaLuot, l.BienSo, l.MaViTri, l.ThoiGianVao, l.MaBai
        FROM dbo.LUOT_GUI l
        WHERE l.MaThe = t.MaThe AND l.ThoiGianRa IS NULL
        ORDER BY l.ThoiGianVao DESC, l.MaLuot DESC
    ) lg
)
SELECT
    th.MaThe,
    th.LoaiThe,
    th.TrangThaiThe,
    th.NgayCap,
    th.MaBaiSoHuuThe,
    th.MaBaiKiemSoat,
    b.TenBai AS TenBaiKiemSoat,
    b.SucChua,
    b.SoLuongHienTai,
    (b.SucChua - b.SoLuongHienTai) AS SoChoTrong,
    -- Hồ sơ vé tháng gắn với thẻ (NULL nếu là thẻ lượt vãng lai)
    th.MaVe,
    th.MaKH,
    th.HoTenKhachHang,
    th.SDTKhachHang,
    th.BienSoDangKy,
    th.MaLoaiXeDangKy,
    th.NgayHetHan,
    th.TrangThaiVeThang,
    th.MaBaiApDung,
    th.VeApDungToanChuoi,
    CASE WHEN th.MaVe IS NULL THEN NULL
         ELSE DATEDIFF(DAY, CAST(GETDATE() AS DATE), th.NgayHetHan) END AS SoNgayConLaiVe,
    -- Lượt gửi đang mở (xe còn trong bãi, chưa check-out)
    th.MaLuotDangMo,
    th.BienSoDangGui,
    th.MaViTriDangDo,
    th.ThoiGianVao,
    CAST(CASE WHEN th.MaLuotDangMo IS NULL THEN 0 ELSE 1 END AS BIT) AS DangTrongBai,
    CASE WHEN th.MaLuotDangMo IS NULL THEN NULL
         ELSE DATEDIFF(MINUTE, th.ThoiGianVao, GETDATE()) END AS SoPhutDaDo,
    -- Quyết định vận hành barrier tại bốt cổng
    CASE WHEN th.MaLuotDangMo IS NULL THEN N'Vào' ELSE N'Ra' END AS ChieuQuetKeTiep,
    CAST(CASE
        WHEN th.MaLuotDangMo IS NOT NULL THEN 1
        WHEN th.TrangThaiThe <> N'Hoạt động' THEN 0
        WHEN th.LoaiThe = N'Tháng' AND th.MaVe IS NULL THEN 0
        WHEN th.LoaiThe = N'Tháng' AND (th.TrangThaiVeThang <> N'Hoạt động' OR th.NgayHetHan < CAST(GETDATE() AS DATE)) THEN 0
        WHEN b.SoLuongHienTai >= b.SucChua THEN 0
        ELSE 1
    END AS BIT) AS ChoPhepQuet,
    CASE
        WHEN th.MaLuotDangMo IS NOT NULL THEN NULL
        WHEN th.TrangThaiThe = N'Mất' THEN N'Thẻ đã được báo mất - trigger trg_KiemTraCheckIn sẽ chặn check-in (lỗi 50002)'
        WHEN th.TrangThaiThe = N'Bị khóa' THEN N'Thẻ đang bị khóa - trigger trg_KiemTraCheckIn sẽ chặn check-in (lỗi 50002)'
        WHEN th.LoaiThe = N'Tháng' AND th.MaVe IS NULL THEN N'Thẻ tháng chưa gắn hợp đồng vé tháng nào - yêu cầu về quầy đăng ký'
        WHEN th.LoaiThe = N'Tháng' AND th.NgayHetHan < CAST(GETDATE() AS DATE) THEN N'Vé tháng đã hết hạn - trigger trg_ChanSuDungVeHetHan sẽ chặn check-in (lỗi 50003)'
        WHEN th.LoaiThe = N'Tháng' AND th.TrangThaiVeThang <> N'Hoạt động' THEN N'Vé tháng đang ở trạng thái ' + th.TrangThaiVeThang + N' - yêu cầu về quầy xử lý'
        WHEN b.SoLuongHienTai >= b.SucChua THEN N'Bãi đã đầy công suất - trigger trg_KiemTraCheckIn sẽ chặn check-in (lỗi 50001)'
        ELSE NULL
    END AS LyDoTuChoi,
    CASE
        WHEN th.MaLuotDangMo IS NOT NULL AND th.TrangThaiThe <> N'Hoạt động'
            THEN N'Thẻ không còn hiệu lực nhưng xe vẫn trong bãi - xác minh giấy tờ và lập biên bản sự cố trước khi cho ra'
        WHEN th.MaLuotDangMo IS NOT NULL AND th.LoaiThe = N'Tháng' AND th.NgayHetHan < CAST(GETDATE() AS DATE)
            THEN N'Vé tháng hết hạn trong lúc xe đang đỗ - nhắc khách gia hạn ngay khi ra cổng'
        WHEN th.MaLuotDangMo IS NOT NULL AND DATEDIFF(HOUR, th.ThoiGianVao, GETDATE()) >= 24
            THEN N'Xe đã đỗ quá 24 giờ - kiểm tra phương tiện bỏ quên'
        WHEN th.MaLuotDangMo IS NULL AND th.MaVe IS NOT NULL
             AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), th.NgayHetHan) BETWEEN 0 AND 3
            THEN CASE WHEN th.CoTaiKhoanOnline = 1
                      THEN N'Vé tháng sắp hết hạn - khách có tài khoản online, hướng dẫn tự gia hạn trên cổng khách hàng'
                      ELSE N'Vé tháng sắp hết hạn - nhắc khách đóng phí gia hạn' END
        ELSE NULL
    END AS GhiChuCanhBao,
    -- Cờ phục vụ thẻ "Hồ sơ thẻ quét" trên màn hình bốt cổng
    th.CoTaiKhoanOnline,
    CAST(ISNULL(th.TuDongGiaHan, 0) AS BIT) AS TuDongGiaHan
FROM TheHienTai th
LEFT JOIN dbo.BAI_DO_XE b ON th.MaBaiKiemSoat = b.MaBai;
GO
-- 10. View v_BotCong_XeChoRa: Màn hình check-out tại bốt cổng ra
--     Liệt kê toàn bộ xe đang trong bãi kèm số phút đỗ, số block giờ tính phí và tiền tạm tính
--     theo đúng công thức của f_TinhTienGuiXe (miễn phí 15 phút đầu, làm tròn lên block giờ)
--     và đúng chính sách của sp_XeRaBai (xe thẻ tháng miễn phí lượt gửi).
CREATE OR ALTER VIEW dbo.v_BotCong_XeChoRa
AS
SELECT
    lg.MaLuot,
    lg.MaBai,
    b.TenBai,
    lg.MaThe,
    t.LoaiThe,
    t.TrangThai AS TrangThaiThe,
    lg.BienSo AS BienSoLucVao,
    lg.MaViTri,
    v.KhuVuc,
    v.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    lx.DonGiaGio,
    lg.ThoiGianVao,
    GETDATE() AS ThoiGianQuetRa,
    DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) AS SoPhutDaDo,
    CAST(ROUND(DATEDIFF(SECOND, lg.ThoiGianVao, GETDATE()) / 3600.0, 2) AS DECIMAL(10,2)) AS SoGioDaDo,
    CAST(CASE WHEN DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) <= 15 THEN 0
              ELSE CEILING(CAST(DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) AS FLOAT) / 60.0)
         END AS INT) AS SoBlockGioTinhPhi,
    CASE WHEN t.LoaiThe = N'Tháng' THEN CAST(0 AS DECIMAL(18,2))
         ELSE dbo.f_TinhTienGuiXe(lg.ThoiGianVao, GETDATE(), v.MaLoaiXe, lg.MaBai)
    END AS TienTamTinh,
    CASE WHEN t.LoaiThe = N'Tháng' THEN N'Miễn phí - xe vé tháng'
         WHEN DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) <= 15 THEN N'Miễn phí - đỗ dưới 15 phút'
         ELSE N'Thu phí gửi lượt'
    END AS ChinhSachThanhToan,
    -- Hồ sơ vé tháng để bốt cổng đối chiếu chủ xe
    vt.MaVe,
    kh.HoTen AS HoTenKhachHang,
    kh.SDT AS SDTKhachHang,
    vt.BienSoDangKy,
    vt.NgayHetHan,
    vt.TrangThaiVeThang,
    CAST(CASE WHEN vt.MaVe IS NOT NULL AND vt.BienSoDangKy <> lg.BienSo THEN 1 ELSE 0 END AS BIT) AS CanhBaoLechBienSo,
    CASE
        WHEN t.TrangThai <> N'Hoạt động'
            THEN N'Thẻ đang ở trạng thái ' + t.TrangThai + N' - xác minh giấy tờ và lập biên bản sự cố trước khi mở barrier'
        WHEN vt.MaVe IS NOT NULL AND vt.BienSoDangKy <> lg.BienSo
            THEN N'Biển số lúc vào khác biển số đăng ký vé tháng (' + vt.BienSoDangKy + N') - kiểm tra an ninh'
        WHEN vt.MaVe IS NOT NULL AND vt.NgayHetHan < CAST(GETDATE() AS DATE)
            THEN N'Vé tháng đã hết hạn - nhắc khách gia hạn trước lượt gửi kế tiếp'
        WHEN DATEDIFF(HOUR, lg.ThoiGianVao, GETDATE()) >= 24
            THEN N'Xe đỗ quá 24 giờ - kiểm tra phương tiện bỏ quên và báo quản lý bãi'
        ELSE NULL
    END AS GhiChuCanhBao
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
OUTER APPLY (
    SELECT x.MaVe, x.MaKH, x.BienSo AS BienSoDangKy, x.NgayHetHan, x.TrangThai AS TrangThaiVeThang
    FROM dbo.VE_THANG x
    WHERE x.MaThe = lg.MaThe AND t.LoaiThe = N'Tháng'
) vt
LEFT JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH
WHERE lg.ThoiGianRa IS NULL;
GO

-- 11. View v_BotCong_NhatKyVaoRa: Bảng điện tử nhật ký 200 sự kiện vào/ra mới nhất
--     Mỗi lượt gửi được trải thành 2 dòng sự kiện (Vào và Ra) để bốt cổng và phòng bảo vệ
--     theo dõi dòng xe qua barrier theo trục thời gian giống màn hình camera giám sát.
CREATE OR ALTER VIEW dbo.v_BotCong_NhatKyVaoRa
AS
SELECT TOP (200)
    sk.MaLuot,
    sk.MaBai,
    sk.TenBai,
    sk.ChieuDiChuyen,
    sk.ThoiGianSuKien,
    sk.MaThe,
    sk.LoaiThe,
    sk.BienSo,
    sk.MaViTri,
    sk.KhuVuc,
    sk.LoaiPhuongTien,
    sk.SoPhutLuuBai,
    sk.SoTienThu,
    sk.TrangThaiLuot
FROM (
    -- Sự kiện xe qua cổng vào
    SELECT
        lg.MaLuot,
        lg.MaBai,
        b.TenBai,
        N'Vào' AS ChieuDiChuyen,
        lg.ThoiGianVao AS ThoiGianSuKien,
        lg.MaThe,
        t.LoaiThe,
        lg.BienSo,
        lg.MaViTri,
        v.KhuVuc,
        lx.TenLoai AS LoaiPhuongTien,
        CAST(NULL AS INT) AS SoPhutLuuBai,
        CAST(NULL AS DECIMAL(18,2)) AS SoTienThu,
        CASE WHEN lg.ThoiGianRa IS NULL THEN N'Đang trong bãi' ELSE N'Đã ra khỏi bãi' END AS TrangThaiLuot
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
    INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
    INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
    INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai

    UNION ALL

    -- Sự kiện xe qua cổng ra kèm số tiền thực thu
    SELECT
        lg.MaLuot,
        lg.MaBai,
        b.TenBai,
        N'Ra' AS ChieuDiChuyen,
        lg.ThoiGianRa AS ThoiGianSuKien,
        lg.MaThe,
        t.LoaiThe,
        lg.BienSo,
        lg.MaViTri,
        v.KhuVuc,
        lx.TenLoai AS LoaiPhuongTien,
        DATEDIFF(MINUTE, lg.ThoiGianVao, lg.ThoiGianRa) AS SoPhutLuuBai,
        lg.TienGui AS SoTienThu,
        N'Đã ra khỏi bãi' AS TrangThaiLuot
    FROM dbo.LUOT_GUI lg
    INNER JOIN dbo.BAI_DO_XE b ON lg.MaBai = b.MaBai
    INNER JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
    INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
    INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
    WHERE lg.ThoiGianRa IS NOT NULL
) sk
ORDER BY sk.ThoiGianSuKien DESC, sk.MaLuot DESC;
GO

-- 12. View v_BotCong_BangDenCong: Bảng đèn tín hiệu CÒN CHỖ / HẾT CHỖ đặt tại cổng vào
--     Mỗi dòng là một cặp (bãi đỗ x loại phương tiện): số ô trống thực tế, ô đỗ gợi ý sẽ
--     được f_TimSlotTrong cấp phát, biểu phí niêm yết và màu đèn barrier tương ứng.
CREATE OR ALTER VIEW dbo.v_BotCong_BangDenCong
AS
SELECT
    b.MaBai,
    b.TenBai,
    b.SucChua,
    b.SoLuongHienTai,
    (b.SucChua - b.SoLuongHienTai) AS SoChoTrongBai,
    lx.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    lx.DonGiaGio,
    lx.GiaVeThang,
    ISNULL(o.TongODo, 0) AS TongODoTheoLoai,
    ISNULL(o.SoODoDaDo, 0) AS SoODoDaDo,
    ISNULL(o.SoODoTrong, 0) AS SoODoTrong,
    CASE WHEN ISNULL(o.TongODo, 0) = 0 THEN CAST(0 AS DECIMAL(5,2))
         ELSE CAST(ROUND(o.SoODoDaDo * 100.0 / o.TongODo, 2) AS DECIMAL(5,2))
    END AS TyLeLapDayTheoLoai,
    dbo.f_TimSlotTrong(b.MaBai, lx.MaLoaiXe) AS MaViTriGoiY,
    CAST(CASE WHEN b.SoLuongHienTai >= b.SucChua THEN 0
              WHEN ISNULL(o.SoODoTrong, 0) = 0 THEN 0
              ELSE 1
         END AS BIT) AS ChoPhepVaoCong,
    CASE WHEN b.SoLuongHienTai >= b.SucChua THEN N'ĐỎ - BÃI ĐẦY, ĐIỀU PHỐI SANG BÃI KHÁC'
         WHEN ISNULL(o.SoODoTrong, 0) = 0 THEN N'ĐỎ - HẾT Ô ĐỖ DÀNH CHO LOẠI XE NÀY'
         WHEN ISNULL(o.SoODoTrong, 0) <= 2 THEN N'VÀNG - CÒN ÍT Ô ĐỖ'
         ELSE N'XANH - CÒN CHỖ, MỜI XE VÀO'
    END AS DenTinHieuCong
FROM dbo.BAI_DO_XE b
INNER JOIN dbo.LOAI_XE lx ON b.MaBai = lx.MaBai
OUTER APPLY (
    SELECT
        COUNT(*) AS TongODo,
        SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1 ELSE 0 END) AS SoODoDaDo,
        SUM(CASE WHEN v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoTrong
    FROM dbo.VI_TRI_DO v
    WHERE v.MaBai = lx.MaBai AND v.MaLoaiXe = lx.MaLoaiXe
) o;
GO


-- ====================================================================================
-- PHẦN D: 3 VIEWS PHỤC VỤ SƠ ĐỒ BÃI XE THỜI GIAN THỰC (REALTIME PARKING MAP)
-- Mục tiêu: Màn hình /map chỉ cần SELECT từ 3 view dưới đây là vẽ được đầy đủ
-- lưới ô đỗ, thanh tổng hợp theo khu vực và thẻ tổng quan công suất từng bãi.
-- ====================================================================================

-- 13. View v_SodoBai_ODoChiTiet: Chi tiết từng ô đỗ trên sơ đồ mặt bằng thời gian thực
--     Bảo đảm đúng 1 dòng / 1 ô đỗ (dùng OUTER APPLY TOP 1 nên không nhân dòng khi dữ liệu lỗi),
--     kèm phương tiện đang chiếm chỗ, thời gian lưu bãi, tiền tạm tính, hồ sơ chủ xe vé tháng
--     và cờ CanhBaoLechDuLieu khi trạng thái ô đỗ không khớp với lượt gửi đang mở.
CREATE OR ALTER VIEW dbo.v_SodoBai_ODoChiTiet
AS
SELECT
    v.MaBai,
    b.TenBai,
    v.KhuVuc,
    v.MaViTri,
    v.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    lx.DonGiaGio,
    v.TrangThai AS TrangThaiODo,
    ROW_NUMBER() OVER (PARTITION BY v.MaBai ORDER BY v.KhuVuc, v.MaViTri) AS ThuTuHienThi,
    lg.MaLuot,
    lg.MaThe,
    t.LoaiThe,
    lg.BienSo,
    lg.ThoiGianVao,
    CASE WHEN lg.MaLuot IS NULL THEN NULL
         ELSE DATEDIFF(MINUTE, lg.ThoiGianVao, GETDATE()) END AS SoPhutDaDo,
    CASE WHEN lg.MaLuot IS NULL THEN NULL
         ELSE CAST(ROUND(DATEDIFF(SECOND, lg.ThoiGianVao, GETDATE()) / 3600.0, 2) AS DECIMAL(10,2)) END AS SoGioDaDo,
    CASE WHEN lg.MaLuot IS NULL THEN NULL
         WHEN t.LoaiThe = N'Tháng' THEN CAST(0 AS DECIMAL(18,2))
         ELSE dbo.f_TinhTienGuiXe(lg.ThoiGianVao, GETDATE(), v.MaLoaiXe, v.MaBai)
    END AS TienTamTinh,
    vt.MaVe,
    kh.HoTen AS HoTenKhachHang,
    kh.SDT AS SDTKhachHang,
    vt.NgayHetHan,
    CASE WHEN v.TrangThai = N'Đã đỗ' AND lg.MaLuot IS NOT NULL THEN N'Đã đỗ'
         WHEN v.TrangThai = N'Trống' AND lg.MaLuot IS NULL THEN N'Trống'
         ELSE N'Lệch dữ liệu'
    END AS TrangThaiHienThi,
    CAST(CASE WHEN (v.TrangThai = N'Đã đỗ' AND lg.MaLuot IS NULL)
                OR (v.TrangThai = N'Trống' AND lg.MaLuot IS NOT NULL)
              THEN 1 ELSE 0 END AS BIT) AS CanhBaoLechDuLieu
FROM dbo.VI_TRI_DO v
INNER JOIN dbo.BAI_DO_XE b ON v.MaBai = b.MaBai
INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
OUTER APPLY (
    SELECT TOP 1 l.MaLuot, l.MaThe, l.BienSo, l.ThoiGianVao
    FROM dbo.LUOT_GUI l
    WHERE l.MaViTri = v.MaViTri AND l.ThoiGianRa IS NULL
    ORDER BY l.ThoiGianVao DESC, l.MaLuot DESC
) lg
LEFT JOIN dbo.THE_XE t ON lg.MaThe = t.MaThe
OUTER APPLY (SELECT h.* FROM dbo.f_VeHienHanhCuaThe(t.MaThe) h WHERE t.LoaiThe = N'Tháng') vt
LEFT JOIN dbo.KHACH_HANG kh ON vt.MaKH = kh.MaKH;
GO

-- 14. View v_SodoBai_TongHopKhuVuc: Thanh tổng hợp theo từng khu vực / tầng trên sơ đồ
--     Cho biết mỗi khu vực còn bao nhiêu ô trống, chia theo từng loại phương tiện,
--     giúp bảo vệ hướng dẫn khách đi đúng tầng thay vì chạy vòng quanh bãi.
CREATE OR ALTER VIEW dbo.v_SodoBai_TongHopKhuVuc
AS
SELECT
    v.MaBai,
    b.TenBai,
    v.KhuVuc,
    COUNT(*) AS TongODo,
    SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1 ELSE 0 END) AS SoODoDaDo,
    SUM(CASE WHEN v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoTrong,
    CAST(ROUND(SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS TyLeLapDayPercent,
    SUM(CASE WHEN v.MaLoaiXe = 'XM' THEN 1 ELSE 0 END) AS SoODoXeMay,
    SUM(CASE WHEN v.MaLoaiXe = 'XM' AND v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoXeMayTrong,
    SUM(CASE WHEN v.MaLoaiXe = 'OT' THEN 1 ELSE 0 END) AS SoODoOTo,
    SUM(CASE WHEN v.MaLoaiXe = 'OT' AND v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoOToTrong,
    SUM(CASE WHEN v.MaLoaiXe = 'XD' THEN 1 ELSE 0 END) AS SoODoXeDap,
    SUM(CASE WHEN v.MaLoaiXe = 'XD' AND v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoXeDapTrong,
    MIN(v.MaViTri) AS ODoDauKhuVuc,
    MAX(v.MaViTri) AS ODoCuoiKhuVuc
FROM dbo.VI_TRI_DO v
INNER JOIN dbo.BAI_DO_XE b ON v.MaBai = b.MaBai
GROUP BY v.MaBai, b.TenBai, v.KhuVuc;
GO

-- 15. View v_SodoBai_TongQuanBai: Thẻ tổng quan công suất đặt trên đầu trang sơ đồ
--     Đối chiếu bộ đếm BAI_DO_XE.SoLuongHienTai (do trigger trg_DongBoTrangThaiSlot duy trì)
--     với số lượt gửi đang mở thực tế trong LUOT_GUI, kèm nhịp xe vào/ra và doanh thu lượt trong ngày.
CREATE OR ALTER VIEW dbo.v_SodoBai_TongQuanBai
AS
SELECT
    b.MaBai,
    b.TenBai,
    b.DiaChi,
    b.SucChua,
    b.SoLuongHienTai,
    (b.SucChua - b.SoLuongHienTai) AS SoChoTrong,
    CAST(ROUND(b.SoLuongHienTai * 100.0 / b.SucChua, 2) AS DECIMAL(5,2)) AS TyLeLapDayPercent,
    ISNULL(od.TongODoVatLy, 0) AS TongODoVatLy,
    ISNULL(od.SoODoDaDo, 0) AS SoODoDaDo,
    ISNULL(od.SoODoTrong, 0) AS SoODoTrong,
    ISNULL(od.SoKhuVuc, 0) AS SoKhuVuc,
    ISNULL(dd.SoXeThucTeTrongBai, 0) AS SoXeThucTeTrongBai,
    ISNULL(dd.SoXeTheThang, 0) AS SoXeTheThang,
    ISNULL(dd.SoXeTheLuot, 0) AS SoXeTheLuot,
    dd.ThoiGianXeVaoGanNhat,
    ra.ThoiGianXeRaGanNhat,
    ISNULL(hn.SoLuotVaoHomNay, 0) AS SoLuotVaoHomNay,
    ISNULL(hn.SoLuotRaHomNay, 0) AS SoLuotRaHomNay,
    ISNULL(hn.DoanhThuLuotHomNay, 0) AS DoanhThuLuotHomNay,
    -- Cờ đối soát: bộ đếm của bãi lệch so với số lượt gửi đang mở thực tế
    CAST(CASE WHEN b.SoLuongHienTai <> ISNULL(dd.SoXeThucTeTrongBai, 0) THEN 1 ELSE 0 END AS BIT) AS CanhBaoLechBoDem,
    CASE WHEN b.SoLuongHienTai >= b.SucChua THEN N'ĐỎ - BÃI ĐẦY'
         WHEN b.SoLuongHienTai * 100.0 / b.SucChua >= 80 THEN N'VÀNG - GẦN ĐẦY'
         ELSE N'XANH - CÒN NHIỀU CHỖ'
    END AS MucDoCanhBao
FROM dbo.BAI_DO_XE b
OUTER APPLY (
    SELECT
        COUNT(*) AS TongODoVatLy,
        SUM(CASE WHEN v.TrangThai = N'Đã đỗ' THEN 1 ELSE 0 END) AS SoODoDaDo,
        SUM(CASE WHEN v.TrangThai = N'Trống' THEN 1 ELSE 0 END) AS SoODoTrong,
        COUNT(DISTINCT v.KhuVuc) AS SoKhuVuc
    FROM dbo.VI_TRI_DO v
    WHERE v.MaBai = b.MaBai
) od
OUTER APPLY (
    SELECT
        COUNT(*) AS SoXeThucTeTrongBai,
        SUM(CASE WHEN t.LoaiThe = N'Tháng' THEN 1 ELSE 0 END) AS SoXeTheThang,
        SUM(CASE WHEN t.LoaiThe = N'Lượt' THEN 1 ELSE 0 END) AS SoXeTheLuot,
        MAX(l.ThoiGianVao) AS ThoiGianXeVaoGanNhat
    FROM dbo.LUOT_GUI l
    INNER JOIN dbo.THE_XE t ON l.MaThe = t.MaThe
    WHERE l.MaBai = b.MaBai AND l.ThoiGianRa IS NULL
) dd
OUTER APPLY (
    SELECT MAX(l.ThoiGianRa) AS ThoiGianXeRaGanNhat
    FROM dbo.LUOT_GUI l
    WHERE l.MaBai = b.MaBai AND l.ThoiGianRa IS NOT NULL
) ra
OUTER APPLY (
    SELECT
        SUM(CASE WHEN CAST(l.ThoiGianVao AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS SoLuotVaoHomNay,
        SUM(CASE WHEN CAST(l.ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END) AS SoLuotRaHomNay,
        SUM(CASE WHEN CAST(l.ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE) THEN l.TienGui ELSE 0 END) AS DoanhThuLuotHomNay
    FROM dbo.LUOT_GUI l
    WHERE l.MaBai = b.MaBai
      AND (CAST(l.ThoiGianVao AS DATE) = CAST(GETDATE() AS DATE)
           OR CAST(l.ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE))
) hn;
GO

-- ====================================================================================
-- PHẦN E: 6 VIEWS TỔNG HỢP PHỤC VỤ NHÀ QUẢN LÝ CHUỖI BÃI XE (ISSUE #12)
-- Mục tiêu: Ban quản lý nhìn được doanh thu theo thời gian, giờ cao điểm, cơ cấu loại xe,
-- xếp hạng các bãi và một bảng tổng quan toàn chuỗi. Chỉ đọc dữ liệu (SELECT), không sửa bảng.
-- ====================================================================================

-- 16. View vw_Report_DoanhThuTheoNgay: Doanh thu (lượt + vé tháng) theo từng ngày, từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoNgay
AS
WITH Nguon AS (
    SELECT
        MaBai,
        CAST(ThoiGianRa AS DATE) AS Ngay,
        COUNT(*) AS SoLuotXe,
        SUM(ISNULL(TienGui, 0)) AS DoanhThuLuot,
        0 AS SoHoaDonVeThang,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuVeThang
    FROM dbo.LUOT_GUI
    WHERE ThoiGianRa IS NOT NULL
    GROUP BY MaBai, CAST(ThoiGianRa AS DATE)

    UNION ALL

    SELECT
        MaBai,
        CAST(NgayThanhToan AS DATE) AS Ngay,
        0 AS SoLuotXe,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuLuot,
        COUNT(*) AS SoHoaDonVeThang,
        SUM(ISNULL(SoTien, 0)) AS DoanhThuVeThang
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaBai, CAST(NgayThanhToan AS DATE)
)
SELECT
    bd.MaBai,
    bd.TenBai,
    n.Ngay,
    SUM(n.SoLuotXe) AS SoLuotXe,
    SUM(n.DoanhThuLuot) AS DoanhThuLuot,
    SUM(n.SoHoaDonVeThang) AS SoHoaDonVeThang,
    SUM(n.DoanhThuVeThang) AS DoanhThuVeThang,
    SUM(n.DoanhThuLuot) + SUM(n.DoanhThuVeThang) AS TongDoanhThu
FROM Nguon n
INNER JOIN dbo.BAI_DO_XE bd ON n.MaBai = bd.MaBai
GROUP BY bd.MaBai, bd.TenBai, n.Ngay;
GO

-- 17. View vw_Report_DoanhThuTheoThang: Doanh thu (lượt + vé tháng) theo từng tháng, từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoThang
AS
WITH Nguon AS (
    SELECT
        MaBai,
        YEAR(ThoiGianRa) AS Nam,
        MONTH(ThoiGianRa) AS Thang,
        COUNT(*) AS SoLuotXe,
        SUM(ISNULL(TienGui, 0)) AS DoanhThuLuot,
        0 AS SoHoaDonVeThang,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuVeThang
    FROM dbo.LUOT_GUI
    WHERE ThoiGianRa IS NOT NULL
    GROUP BY MaBai, YEAR(ThoiGianRa), MONTH(ThoiGianRa)

    UNION ALL

    SELECT
        MaBai,
        YEAR(NgayThanhToan) AS Nam,
        MONTH(NgayThanhToan) AS Thang,
        0 AS SoLuotXe,
        CAST(0 AS DECIMAL(18,2)) AS DoanhThuLuot,
        COUNT(*) AS SoHoaDonVeThang,
        SUM(ISNULL(SoTien, 0)) AS DoanhThuVeThang
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaBai, YEAR(NgayThanhToan), MONTH(NgayThanhToan)
)
SELECT
    bd.MaBai,
    bd.TenBai,
    n.Nam,
    n.Thang,
    SUM(n.SoLuotXe) AS SoLuotXe,
    SUM(n.DoanhThuLuot) AS DoanhThuLuot,
    SUM(n.SoHoaDonVeThang) AS SoHoaDonVeThang,
    SUM(n.DoanhThuVeThang) AS DoanhThuVeThang,
    SUM(n.DoanhThuLuot) + SUM(n.DoanhThuVeThang) AS TongDoanhThu
FROM Nguon n
INNER JOIN dbo.BAI_DO_XE bd ON n.MaBai = bd.MaBai
GROUP BY bd.MaBai, bd.TenBai, n.Nam, n.Thang;
GO

-- 18. View vw_Report_LuuLuongTheoGio: Số lượt xe vào theo khung giờ, để tìm giờ cao điểm
CREATE OR ALTER VIEW dbo.vw_Report_LuuLuongTheoGio
AS
SELECT
    bd.MaBai,
    bd.TenBai,
    DATEPART(HOUR, lg.ThoiGianVao) AS GioTrongNgay,
    COUNT(*) AS SoLuotVao,
    COUNT(DISTINCT CAST(lg.ThoiGianVao AS DATE)) AS SoNgayCoDuLieu,
    CAST(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT CAST(lg.ThoiGianVao AS DATE)), 0) AS DECIMAL(10,2)) AS SoLuotVaoTBMoiNgay
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
GROUP BY bd.MaBai, bd.TenBai, DATEPART(HOUR, lg.ThoiGianVao);
GO

-- 19. View vw_Report_ThongKeTheoLoaiXe: Cơ cấu lượt gửi và doanh thu theo loại phương tiện
CREATE OR ALTER VIEW dbo.vw_Report_ThongKeTheoLoaiXe
AS
SELECT
    bd.MaBai,
    bd.TenBai,
    lx.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    COUNT(*) AS SoLuotXe,
    SUM(ISNULL(lg.TienGui, 0)) AS DoanhThuLuot,
    CAST(AVG(CAST(DATEDIFF(MINUTE, lg.ThoiGianVao, lg.ThoiGianRa) AS FLOAT)) / 60.0 AS DECIMAL(10,2)) AS SoGioGuiTB
FROM dbo.LUOT_GUI lg
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri
INNER JOIN dbo.LOAI_XE lx ON v.MaLoaiXe = lx.MaLoaiXe AND v.MaBai = lx.MaBai
WHERE lg.ThoiGianRa IS NOT NULL
GROUP BY bd.MaBai, bd.TenBai, lx.MaLoaiXe, lx.TenLoai;
GO

-- 20. View vw_Report_XepHangBai: Xếp hạng các bãi theo tổng doanh thu, kèm tỉ lệ lấp đầy hiện tại
--     Tận dụng lại 2 view báo cáo có sẵn ở PHẦN B nên số liệu luôn đồng nhất.
CREATE OR ALTER VIEW dbo.vw_Report_XepHangBai
AS
SELECT
    RANK() OVER (ORDER BY dt.TongDoanhThu DESC) AS HangDoanhThu,
    dt.MaBai,
    dt.TenBai,
    dt.DoanhThuLuot,
    dt.DoanhThuThang,
    dt.TongDoanhThu,
    cs.SucChua,
    cs.SoLuongHienTai,
    cs.TyLeLapDayPercent
FROM dbo.vw_Report_DoanhThuTheoBai dt
INNER JOIN dbo.vw_Report_CongSuatBaiDo cs ON dt.MaBai = cs.MaBai;
GO

-- 21. View vw_Report_TongQuanChuoi: Bảng tổng quan toàn chuỗi, luôn trả về đúng 1 dòng
CREATE OR ALTER VIEW dbo.vw_Report_TongQuanChuoi
AS
SELECT
    (SELECT COUNT(*) FROM dbo.BAI_DO_XE) AS TongSoBai,
    (SELECT ISNULL(SUM(SucChua), 0) FROM dbo.BAI_DO_XE) AS TongSucChua,
    (SELECT ISNULL(SUM(SoLuongHienTai), 0) FROM dbo.BAI_DO_XE) AS TongXeDangGui,
    CAST((SELECT ISNULL(SUM(SoLuongHienTai), 0) * 100.0 / NULLIF(SUM(SucChua), 0)
          FROM dbo.BAI_DO_XE) AS DECIMAL(5,2)) AS TyLeLapDayToanChuoiPercent,
    (SELECT ISNULL(SUM(TienGui), 0) FROM dbo.LUOT_GUI
      WHERE CAST(ThoiGianRa AS DATE) = CAST(GETDATE() AS DATE)) AS DoanhThuLuotHomNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.HOA_DON_VE_THANG
      WHERE CAST(NgayThanhToan AS DATE) = CAST(GETDATE() AS DATE)) AS DoanhThuVeThangHomNay,
    (SELECT ISNULL(SUM(TienGui), 0) FROM dbo.LUOT_GUI
      WHERE ThoiGianRa >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS DoanhThuLuotThangNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.HOA_DON_VE_THANG
      WHERE NgayThanhToan >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS DoanhThuVeThangThangNay,
    (SELECT COUNT(*) FROM dbo.VE_THANG
      WHERE TrangThai = N'Hoạt động' AND NgayHetHan >= CAST(GETDATE() AS DATE)) AS SoVeThangConHieuLuc,
    (SELECT COUNT(*) FROM dbo.VE_THANG
      WHERE TrangThai = N'Hoạt động'
        AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), NgayHetHan) BETWEEN 0 AND 7) AS SoVeThangSapHetHan7Ngay,
    (SELECT COUNT(*) FROM dbo.LICHSU_SU_CO
      WHERE CAST(ThoiGianSuCo AS DATE) = CAST(GETDATE() AS DATE)) AS SoSuCoHomNay;
GO

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- VIEWS CỔNG KHÁCH HÀNG & BÁO CÁO THANH TOÁN (UPGRADE_PLAN.md MỤC 9)
-- PHẦN F: 6 views cổng khách hàng (vw_KH_*), lọc theo SESSION_CONTEXT do sp_KH_DangNhap đặt.
--         Không có ngữ cảnh khách hàng (nhân viên, trang quản trị) thì các view này trả về rỗng.
-- PHẦN G: 5 views báo cáo quản trị thanh toán / bảo mật tài khoản.
-- PHẦN H: Phiên bản mở rộng của vw_Report_DoanhThuTheoBai và v_BotCong_TraCuuThe (thêm cột ở cuối, giữ cột cũ).
-- ====================================================================================

-- ====================================================================================
-- PHẦN F: VIEWS CỔNG KHÁCH HÀNG
-- ====================================================================================

-- 22. vw_KH_HoSoCuaToi: Hồ sơ, số dư ví và số thông báo chưa đọc của khách đang đăng nhập
CREATE OR ALTER VIEW dbo.vw_KH_HoSoCuaToi
AS
SELECT
    tk.MaTK,
    kh.MaKH,
    kh.HoTen,
    kh.SDT,
    kh.Email,
    tk.TenDangNhap,
    tk.TrangThai AS TrangThaiTaiKhoan,
    tk.LanDangNhapCuoi,
    vi.MaVi,
    vi.SoDu,
    vi.TrangThai AS TrangThaiVi,
    (SELECT COUNT(*) FROM dbo.THONG_BAO tb WHERE tb.MaKH = kh.MaKH AND tb.DaDoc = 0) AS SoThongBaoChuaDoc
FROM dbo.TAI_KHOAN_KH tk
INNER JOIN dbo.KHACH_HANG kh ON tk.MaKH = kh.MaKH
LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = kh.MaKH
WHERE tk.MaTK = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12));
GO

-- 23. vw_KH_VeThangCuaToi: Vé chính chủ + vé được ủy quyền còn hiệu lực, kèm vai trò của tôi trên từng vé
CREATE OR ALTER VIEW dbo.vw_KH_VeThangCuaToi
AS
WITH Phien AS (
    SELECT
        CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12)) AS MaTK,
        CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10)) AS MaKH
)
SELECT
    vt.MaVe,
    vt.MaThe,
    vt.BienSo,
    vt.MaLoaiXe,
    lx.TenLoai AS LoaiPhuongTien,
    vt.MaBaiApDung,
    CASE WHEN vt.MaBaiApDung = 'ALL' THEN N'Toàn chuỗi' ELSE bd.TenBai END AS PhamViApDung,
    vt.NgayDangKy,
    vt.NgayHetHan,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), vt.NgayHetHan) AS SoNgayConLai,
    vt.TrangThai,
    CASE WHEN vt.MaKH = p.MaKH THEN 'CHU_SO_HUU' ELSE uq.MaVaiTro END AS MaVaiTroCuaToi,
    vtr.TenVaiTro AS VaiTroCuaToi,
    chu.HoTen AS ChuVe,
    uq.NgayKetThuc AS HanUyQuyen,
    vt.TuDongGiaHan,
    vt.SoThangTuDongGiaHan,
    dbo.f_KH_TinhPhiGiaHan(vt.MaVe, 1) AS PhiGiaHan1Thang
FROM dbo.VE_THANG vt
CROSS JOIN Phien p
INNER JOIN dbo.THE_XE tx ON vt.MaThe = tx.MaThe
INNER JOIN dbo.KHACH_HANG chu ON vt.MaKH = chu.MaKH
LEFT JOIN dbo.BAI_DO_XE bd ON vt.MaBaiApDung = bd.MaBai
LEFT JOIN dbo.LOAI_XE lx
    ON lx.MaLoaiXe = vt.MaLoaiXe
   AND lx.MaBai = CASE WHEN vt.MaBaiApDung = 'ALL' THEN tx.MaBai ELSE vt.MaBaiApDung END
LEFT JOIN dbo.UY_QUYEN_VE uq
    ON uq.MaVe = vt.MaVe
   AND uq.MaTKDuocUyQuyen = p.MaTK
   AND uq.TrangThai = N'Hiệu lực'
   AND uq.NgayBatDau <= CAST(GETDATE() AS DATE)
   AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE))
LEFT JOIN dbo.VAI_TRO_KH vtr
    ON vtr.MaVaiTro = CASE WHEN vt.MaKH = p.MaKH THEN 'CHU_SO_HUU' ELSE uq.MaVaiTro END
WHERE vt.MaKH = p.MaKH OR uq.MaUyQuyen IS NOT NULL;
GO

-- 24. vw_KH_LichSuDoXe: Lịch sử đỗ xe của các vé tôi xem được (vai trò nào cũng có quyền LICHSU.XEM)
CREATE OR ALTER VIEW dbo.vw_KH_LichSuDoXe
AS
SELECT
    lg.MaLuot,
    lg.MaVe,
    ve.MaVaiTroCuaToi,
    ve.BienSo AS BienSoDangKy,
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
INNER JOIN dbo.vw_KH_VeThangCuaToi ve ON lg.MaVe = ve.MaVe
INNER JOIN dbo.BAI_DO_XE bd ON lg.MaBai = bd.MaBai
INNER JOIN dbo.VI_TRI_DO v ON lg.MaViTri = v.MaViTri;
GO

-- 25. vw_KH_LichSuGiaoDich: Sổ cái ví của chính tôi - số tiền có dấu, phương thức thanh toán, trạng thái, số dư sau
CREATE OR ALTER VIEW dbo.vw_KH_LichSuGiaoDich
AS
SELECT
    g.MaGD,
    g.ThoiGianTao,
    g.LoaiGD,
    g.HuongTien * g.SoTien AS SoTienCoDau,
    g.PhiGiaoDich,
    p.TenPTTT AS PhuongThucThanhToan,
    g.MaPTTT,
    g.MaThamChieu,
    g.TrangThai,
    g.SoDuTruoc,
    g.SoDuSau,
    g.MaVe,
    g.MaGDGoc,
    g.ThoiGianHoanTat,
    g.GhiChu
FROM dbo.GIAO_DICH g
INNER JOIN dbo.VI_DIEN_TU vi ON g.MaVi = vi.MaVi
INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON g.MaPTTT = p.MaPTTT
WHERE vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- 26. vw_KH_HoaDonCuaToi: Hóa đơn vé tháng của các vé tôi đứng tên (mọi kênh: quầy, online, tự động)
CREATE OR ALTER VIEW dbo.vw_KH_HoaDonCuaToi
AS
SELECT
    hd.MaHD,
    hd.MaVe,
    vt.BienSo,
    hd.NgayThanhToan,
    hd.SoThangGiaHan,
    hd.SoTien,
    p.TenPTTT AS PhuongThucThanhToan,
    hd.KenhThanhToan,
    hd.MaBai,
    bd.TenBai,
    hd.MaGD
FROM dbo.HOA_DON_VE_THANG hd
INNER JOIN dbo.VE_THANG vt ON hd.MaVe = vt.MaVe
INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON hd.MaPTTT = p.MaPTTT
INNER JOIN dbo.BAI_DO_XE bd ON hd.MaBai = bd.MaBai
WHERE vt.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- 27. vw_KH_ThongBao: Hộp thư thông báo của tôi (sắp xếp chưa đọc lên đầu thực hiện ở truy vấn / UI)
CREATE OR ALTER VIEW dbo.vw_KH_ThongBao
AS
SELECT
    tb.MaTB,
    tb.LoaiTB,
    tb.TieuDe,
    tb.NoiDung,
    tb.MaVe,
    tb.MaGD,
    tb.DaDoc,
    tb.ThoiGianTao
FROM dbo.THONG_BAO tb
WHERE tb.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- ====================================================================================
-- PHẦN G: VIEWS BÁO CÁO THANH TOÁN & BẢO MẬT TÀI KHOẢN (QUẢN TRỊ)
-- ====================================================================================

-- 28. vw_Report_DoanhThuTheoPhuongThuc: Doanh thu vé tháng theo phương thức / kênh và tiền nạp ví qua từng cổng
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoPhuongThuc
AS
SELECT
    p.MaPTTT,
    p.TenPTTT AS PhuongThucThanhToan,
    p.LoaiKenh,
    p.TrangThai,
    ISNULL(hd.SoHoaDon, 0) AS SoHoaDonVeThang,
    ISNULL(hd.DoanhThuTaiQuay, 0) AS DoanhThuTaiQuay,
    ISNULL(hd.DoanhThuOnline, 0) AS DoanhThuOnline,
    ISNULL(hd.DoanhThuTuDong, 0) AS DoanhThuTuDong,
    ISNULL(hd.TongDoanhThu, 0) AS TongDoanhThuVeThang,
    ISNULL(nap.SoLanNap, 0) AS SoLanNapVi,
    ISNULL(nap.TongNap, 0) AS TongTienNapVi,
    ISNULL(nap.PhiCong, 0) AS PhiCongThanhToan,
    ISNULL(nap.TongNap, 0) - ISNULL(nap.PhiCong, 0) AS TienNapThucNhan
FROM dbo.PHUONG_THUC_THANH_TOAN p
LEFT JOIN (
    SELECT
        MaPTTT,
        COUNT(*) AS SoHoaDon,
        SUM(CASE WHEN KenhThanhToan = N'Tại quầy' THEN SoTien ELSE 0 END) AS DoanhThuTaiQuay,
        SUM(CASE WHEN KenhThanhToan = N'Online' THEN SoTien ELSE 0 END) AS DoanhThuOnline,
        SUM(CASE WHEN KenhThanhToan = N'Tự động' THEN SoTien ELSE 0 END) AS DoanhThuTuDong,
        SUM(SoTien) AS TongDoanhThu
    FROM dbo.HOA_DON_VE_THANG
    GROUP BY MaPTTT
) hd ON hd.MaPTTT = p.MaPTTT
LEFT JOIN (
    SELECT
        MaPTTT,
        COUNT(*) AS SoLanNap,
        SUM(SoTien) AS TongNap,
        SUM(PhiGiaoDich) AS PhiCong
    FROM dbo.GIAO_DICH
    WHERE LoaiGD = N'Nạp tiền' AND TrangThai IN (N'Thành công', N'Đã hoàn')
    GROUP BY MaPTTT
) nap ON nap.MaPTTT = p.MaPTTT;
GO

-- 29. vw_Report_TongQuanViDienTu: Tổng quan ví toàn chuỗi, luôn trả về đúng 1 dòng
-- TongSoDuDangGiu là nợ phải trả khách hàng (tiền khách đã nạp nhưng chưa dùng).
CREATE OR ALTER VIEW dbo.vw_Report_TongQuanViDienTu
AS
SELECT
    (SELECT COUNT(*) FROM dbo.VI_DIEN_TU) AS TongSoVi,
    (SELECT COUNT(*) FROM dbo.VI_DIEN_TU WHERE SoDu > 0) AS SoViCoSoDu,
    (SELECT ISNULL(SUM(SoDu), 0) FROM dbo.VI_DIEN_TU) AS TongSoDuDangGiu,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.GIAO_DICH
      WHERE LoaiGD = N'Nạp tiền' AND TrangThai IN (N'Thành công', N'Đã hoàn')
        AND ThoiGianTao >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS TongNapThangNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.GIAO_DICH
      WHERE LoaiGD = N'Thanh toán vé tháng' AND TrangThai IN (N'Thành công', N'Đã hoàn')
        AND ThoiGianTao >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS TongChiVeThangThangNay,
    (SELECT ISNULL(SUM(SoTien), 0) FROM dbo.HOA_DON_VE_THANG
      WHERE KenhThanhToan IN (N'Online', N'Tự động')
        AND NgayThanhToan >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS DoanhThuGiaHanOnlineThangNay,
    (SELECT COUNT(*) FROM dbo.GIAO_DICH WHERE TrangThai = N'Chờ xử lý') AS SoGiaoDichChoXuLy,
    (SELECT COUNT(*) FROM dbo.TAI_KHOAN_KH) AS SoTaiKhoanKhachHang,
    (SELECT COUNT(*) FROM dbo.TAI_KHOAN_KH WHERE TrangThai = N'Tạm khóa') AS SoTaiKhoanTamKhoa;
GO

-- 30. vw_Report_GiaoDichCanXuLy: Hàng đợi xử lý của nhân viên - giao dịch treo, thất bại 7 ngày gần nhất
CREATE OR ALTER VIEW dbo.vw_Report_GiaoDichCanXuLy
AS
SELECT
    g.MaGD,
    g.ThoiGianTao,
    vi.MaKH,
    kh.HoTen,
    g.LoaiGD,
    g.SoTien,
    p.TenPTTT AS PhuongThucThanhToan,
    g.TrangThai,
    DATEDIFF(MINUTE, g.ThoiGianTao, GETDATE()) AS SoPhutTuKhiTao,
    CASE
        WHEN g.TrangThai = N'Chờ xử lý' AND g.ThoiGianTao < DATEADD(MINUTE, -30, GETDATE()) THEN N'Treo quá 30 phút'
        WHEN g.TrangThai = N'Chờ xử lý' THEN N'Đang chờ cổng thanh toán'
        ELSE N'Thất bại'
    END AS PhanLoai,
    g.GhiChu
FROM dbo.GIAO_DICH g
INNER JOIN dbo.VI_DIEN_TU vi ON g.MaVi = vi.MaVi
INNER JOIN dbo.KHACH_HANG kh ON vi.MaKH = kh.MaKH
INNER JOIN dbo.PHUONG_THUC_THANH_TOAN p ON g.MaPTTT = p.MaPTTT
WHERE g.TrangThai = N'Chờ xử lý'
   OR (g.TrangThai = N'Thất bại' AND g.ThoiGianTao >= DATEADD(DAY, -7, GETDATE()));
GO

-- 31. vw_Report_BaoMatTaiKhoanKH: Giám sát bảo mật tài khoản khách hàng (24 giờ gần nhất)
CREATE OR ALTER VIEW dbo.vw_Report_BaoMatTaiKhoanKH
AS
SELECT
    tk.MaTK,
    tk.TenDangNhap,
    kh.HoTen,
    tk.TrangThai,
    tk.KhoaDen,
    tk.SoLanSaiLienTiep,
    tk.LanDangNhapCuoi,
    ISNULL(nk.SoLanSai24h, 0) AS SoLanSai24h,
    ISNULL(nk.SoLanThanhCong24h, 0) AS SoLanThanhCong24h,
    ISNULL(nk.SoDiaChiIP24h, 0) AS SoDiaChiIP24h,
    CASE
        WHEN tk.TrangThai = N'Tạm khóa' THEN N'Đang tạm khóa'
        WHEN ISNULL(nk.SoLanSai24h, 0) >= 3 THEN N'Nhiều lần sai mật khẩu'
        WHEN ISNULL(nk.SoDiaChiIP24h, 0) >= 3 THEN N'Đăng nhập từ nhiều địa chỉ IP'
        ELSE N'Bình thường'
    END AS CanhBao
FROM dbo.TAI_KHOAN_KH tk
INNER JOIN dbo.KHACH_HANG kh ON tk.MaKH = kh.MaKH
LEFT JOIN (
    SELECT
        MaTK,
        SUM(CASE WHEN KetQua = N'Sai mật khẩu' THEN 1 ELSE 0 END) AS SoLanSai24h,
        SUM(CASE WHEN KetQua = N'Thành công' THEN 1 ELSE 0 END) AS SoLanThanhCong24h,
        COUNT(DISTINCT DiaChiIP) AS SoDiaChiIP24h
    FROM dbo.NHAT_KY_DANG_NHAP
    WHERE ThoiGian >= DATEADD(HOUR, -24, GETDATE()) AND MaTK IS NOT NULL
    GROUP BY MaTK
) nk ON nk.MaTK = tk.MaTK;
GO

-- 32. vw_Report_TyLeChuyenDoiOnline: Tỷ lệ gia hạn online / tự động so với tại quầy theo tháng
CREATE OR ALTER VIEW dbo.vw_Report_TyLeChuyenDoiOnline
AS
SELECT
    YEAR(hd.NgayThanhToan) AS Nam,
    MONTH(hd.NgayThanhToan) AS Thang,
    COUNT(*) AS SoHoaDon,
    SUM(CASE WHEN hd.KenhThanhToan = N'Tại quầy' THEN 1 ELSE 0 END) AS SoHoaDonTaiQuay,
    SUM(CASE WHEN hd.KenhThanhToan IN (N'Online', N'Tự động') THEN 1 ELSE 0 END) AS SoHoaDonOnline,
    CAST(SUM(CASE WHEN hd.KenhThanhToan IN (N'Online', N'Tự động') THEN 1 ELSE 0 END) * 100.0
         / NULLIF(COUNT(*), 0) AS DECIMAL(5,2)) AS TyLeOnlinePercent,
    CAST((SELECT COUNT(*) FROM dbo.TAI_KHOAN_KH) * 100.0
         / NULLIF((SELECT COUNT(*) FROM dbo.KHACH_HANG), 0) AS DECIMAL(5,2)) AS TyLeKhachCoTaiKhoanPercent
FROM dbo.HOA_DON_VE_THANG hd
GROUP BY YEAR(hd.NgayThanhToan), MONTH(hd.NgayThanhToan);
GO

-- ====================================================================================
-- PHẦN H: Bản mở rộng của vw_Report_DoanhThuTheoBai và v_BotCong_TraCuuThe nằm ngay tại vị trí bản gốc
-- ở đầu file (view phía sau phụ thuộc chúng).
-- PHẦN I: VIEWS PHỤ TRỢ CỔNG KHÁCH HÀNG /kh (lọc theo SESSION_CONTEXT như PHẦN F)
-- ====================================================================================

-- 12. vw_KH_NhatKyDangNhap: Nhật ký đăng nhập của tài khoản đang đăng nhập (màn hình Bảo mật)
CREATE OR ALTER VIEW dbo.vw_KH_NhatKyDangNhap
AS
SELECT n.MaNK, n.ThoiGian, n.KetQua, n.DiaChiIP, n.ThietBi
FROM dbo.NHAT_KY_DANG_NHAP n
WHERE n.MaTK = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12));
GO

-- 13. vw_KH_PhuongThucNapVi: Phương thức khách được chọn khi nạp ví online (không gồm tiền mặt tại quầy)
CREATE OR ALTER VIEW dbo.vw_KH_PhuongThucNapVi
AS
SELECT MaPTTT, TenPTTT, LoaiKenh, PhiPhanTram, SoTienToiThieu, TrangThai
FROM dbo.PHUONG_THUC_THANH_TOAN
WHERE ChoPhepNapVi = 1 AND LoaiKenh <> N'Tiền mặt';
GO

-- 14. vw_KH_HanMucNap: Hạn mức nạp trong ngày còn lại của ví (tính cả lệnh nạp đang chờ cổng thanh toán)
CREATE OR ALTER VIEW dbo.vw_KH_HanMucNap
AS
SELECT
    vi.MaVi,
    vi.HanMucNapNgay,
    dbo.f_KH_TongNapTrongNgay(vi.MaVi) AS DaNapHomNay,
    vi.HanMucNapNgay - dbo.f_KH_TongNapTrongNgay(vi.MaVi) AS HanMucConLai
FROM dbo.VI_DIEN_TU vi
WHERE vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- 15. vw_KH_QuyenTrenVe: Quyền nghiệp vụ của tôi trên từng vé (để ẩn nút không có quyền; server vẫn kiểm tra lại)
CREATE OR ALTER VIEW dbo.vw_KH_QuyenTrenVe
AS
SELECT v.MaVe, q.MaQuyen
FROM dbo.vw_KH_VeThangCuaToi v
INNER JOIN dbo.VAI_TRO_QUYEN q ON q.MaVaiTro = v.MaVaiTroCuaToi;
GO

-- 16. vw_KH_VaiTroUyQuyen: Vai trò được phép chia sẻ kèm danh sách quyền (form chia sẻ vé)
CREATE OR ALTER VIEW dbo.vw_KH_VaiTroUyQuyen
AS
SELECT
    vt.MaVaiTro,
    vt.TenVaiTro,
    vt.MoTa,
    STRING_AGG(qk.MoTa, N'; ') AS DanhSachQuyen
FROM dbo.VAI_TRO_KH vt
INNER JOIN dbo.VAI_TRO_QUYEN vq ON vq.MaVaiTro = vt.MaVaiTro
INNER JOIN dbo.QUYEN_KH qk ON qk.MaQuyen = vq.MaQuyen
WHERE vt.MaVaiTro <> 'CHU_SO_HUU'
GROUP BY vt.MaVaiTro, vt.TenVaiTro, vt.MoTa;
GO
