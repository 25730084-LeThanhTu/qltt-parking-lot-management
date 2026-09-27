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
SELECT v.MaBai,
       b.TenBai,
       v.MaViTri,
       v.KhuVuc,
       v.TrangThai,
       l.TenLoai,
       lg.BienSo,
       lg.ThoiGianVao
FROM   dbo.VI_TRI_DO AS v
       INNER JOIN
       dbo.BAI_DO_XE AS b
       ON v.MaBai = b.MaBai
       INNER JOIN
       dbo.LOAI_XE AS l
       ON v.MaLoaiXe = l.MaLoaiXe
          AND v.MaBai = l.MaBai
       LEFT OUTER JOIN
       dbo.LUOT_GUI AS lg
       ON v.MaViTri = lg.MaViTri
          AND lg.ThoiGianRa IS NULL;


GO
-- 2. View v_Xedangtrongbai: Danh sách các xe hiện diện trong bãi chưa làm thủ tục Check-Out
CREATE OR ALTER VIEW dbo.v_Xedangtrongbai
AS
SELECT lg.MaLuot,
       lg.MaBai,
       b.TenBai,
       lg.MaThe,
       lg.BienSo,
       lg.MaViTri,
       lg.ThoiGianVao,
       t.LoaiThe
FROM   dbo.LUOT_GUI AS lg
       INNER JOIN
       dbo.BAI_DO_XE AS b
       ON lg.MaBai = b.MaBai
       INNER JOIN
       dbo.THE_XE AS t
       ON lg.MaThe = t.MaThe
WHERE  lg.ThoiGianRa IS NULL;


GO
-- 3. View v_DanhsachveThangsaphethan: Danh sách vé tháng còn dưới hoặc bằng 3 ngày sử dụng
CREATE OR ALTER VIEW dbo.v_DanhsachveThangsaphethan
AS
SELECT vt.MaVe,
       vt.MaThe,
       kh.HoTen,
       kh.SDT,
       vt.BienSo,
       vt.NgayHetHan,
       DATEDIFF(DAY, CAST (GETDATE() AS DATE), vt.NgayHetHan) AS SongayConLai,
       vt.MaBaiApDung
FROM   dbo.VE_THANG AS vt
       INNER JOIN
       dbo.KHACH_HANG AS kh
       ON vt.MaKH = kh.MaKH
WHERE  DATEDIFF(DAY, CAST (GETDATE() AS DATE), vt.NgayHetHan) BETWEEN 0 AND 3
       AND vt.TrangThai = N'Hoạt động';


GO
-- ====================================================================================
-- PHẦN B: 5 VIEWS BÁO CÁO THỐNG KÊ QUẢN TRỊ & KINH DOANH (BI ANALYTICS)
-- ====================================================================================
-- 4. View vw_Report_CongSuatBaiDo: Giám sát tỷ lệ lấp đầy và chỗ trống theo từng bãi
CREATE OR ALTER VIEW dbo.vw_Report_CongSuatBaiDo
AS
SELECT bd.MaBai,
       bd.TenBai,
       bd.SucChua,
       bd.SoLuongHienTai,
       (bd.SucChua - bd.SoLuongHienTai) AS SoChoTrong,
       -- Tối ưu: Dùng NULLIF để tránh lỗi chia 0 (Divide by zero) nếu sức chứa chưa được thiết lập
       CAST (ROUND(CAST (bd.SoLuongHienTai AS FLOAT) * 100.0 / NULLIF (CAST (bd.SucChua AS FLOAT), 0), 2) AS DECIMAL (5, 2)) AS TyLeLapDayPercent
FROM   dbo.BAI_DO_XE AS bd;


GO
-- 5. View vw_Report_DoanhThuTheoBai: Báo cáo tài chính tổng hợp phân bổ theo bãi
CREATE OR ALTER VIEW dbo.vw_Report_DoanhThuTheoBai
AS
SELECT bd.MaBai,
       bd.TenBai,
       ISNULL(sub_luot.TienLuot, 0) AS DoanhThuLuot,
       ISNULL(sub_thang.TienThang, 0) AS DoanhThuThang,
       (ISNULL(sub_luot.TienLuot, 0) + ISNULL(sub_thang.TienThang, 0)) AS TongDoanhThu
FROM   dbo.BAI_DO_XE AS bd
       LEFT OUTER JOIN
       (SELECT   MaBai,
                 SUM(TienGui) AS TienLuot
        FROM     dbo.LUOT_GUI
        GROUP BY MaBai) AS sub_luot
       ON bd.MaBai = sub_luot.MaBai
       LEFT OUTER JOIN
       (SELECT   MaBai,
                 SUM(SoTien) AS TienThang
        FROM     dbo.HOA_DON_VE_THANG
        GROUP BY MaBai) AS sub_thang
       ON bd.MaBai = sub_thang.MaBai;
GO