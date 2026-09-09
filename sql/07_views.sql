-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 7: DATABASE VIEWS (8 VIEWS: 3 VIEWS VẬN HÀNH BLUEPRINT V6 + 5 VIEWS BÁO CÁO BI)
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

-- 5. View vw_Report_DoanhThuTheoBai: Báo cáo tài chính tổng hợp phân bổ theo bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoBai
AS
SELECT 
    bd.MaBai,
    bd.TenBai,
    ISNULL(sub_luot.TienLuot, 0) AS DoanhThuLuot,
    ISNULL(sub_thang.TienThang, 0) AS DoanhThuThang,
    (ISNULL(sub_luot.TienLuot, 0) + ISNULL(sub_thang.TienThang, 0)) AS TongDoanhThu
FROM dbo.BAI_DO_XE bd
LEFT JOIN (
    SELECT MaBai, SUM(TienGui) AS TienLuot
    FROM dbo.LUOT_GUI
    GROUP BY MaBai
) sub_luot ON bd.MaBai = sub_luot.MaBai
LEFT JOIN (
    SELECT MaBai, SUM(SoTien) AS TienThang
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
