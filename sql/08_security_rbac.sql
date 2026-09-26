-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 8: AN TOÀN THÔNG TIN & PHÂN QUYỀN TRUY CẬP (ROLE-BASED ACCESS CONTROL - RBAC)
-- ====================================================================================

-- 1. Khởi tạo 3 Nhóm quyền (Database Roles)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_Admin' AND type = 'R')
    CREATE ROLE r_Admin;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_QuanLyBai' AND type = 'R')
    CREATE ROLE r_QuanLyBai;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_BaoVe' AND type = 'R')
    CREATE ROLE r_BaoVe;
GO

-- ====================================================================================
-- 2. CẤP QUYỀN CHI TIẾT THEO TỪNG VAI TRÒ
-- ====================================================================================

-- A. Quyền r_Admin: Quản trị viên tối cao (Full Control trên toàn bộ cơ sở dữ liệu)
GRANT CONTROL TO r_Admin;
GO

-- B. Quyền r_QuanLyBai: Quản lý chi nhánh bãi đỗ xe
-- Được xem, thêm, sửa trên các danh mục quản trị và dữ liệu nghiệp vụ
GRANT SELECT, INSERT, UPDATE ON dbo.BAI_DO_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.LOAI_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.VI_TRI_DO TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.THE_XE TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.KHACH_HANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.VE_THANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.NHAN_VIEN TO r_QuanLyBai;
GRANT SELECT ON dbo.TAI_KHOAN TO r_QuanLyBai;
GRANT SELECT ON dbo.LUOT_GUI TO r_QuanLyBai;
GRANT SELECT ON dbo.HOA_DON_VE_THANG TO r_QuanLyBai;
GRANT SELECT, INSERT, UPDATE ON dbo.LICHSU_SU_CO TO r_QuanLyBai;

-- Được thực thi các Stored Procedures quản trị vé và nhân sự
GRANT EXECUTE ON dbo.sp_DangKyThanhVien TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_GiaHanTheThang TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_BaoMatThe TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoCanhBaoHanTheThang TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoTongKetDoanhThuChuoi TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DangNhap TO r_QuanLyBai;

-- Được xem tất cả các Views báo cáo
GRANT SELECT ON dbo.v_SodoOdoRealtime TO r_QuanLyBai;
GRANT SELECT ON dbo.v_Xedangtrongbai TO r_QuanLyBai;
GRANT SELECT ON dbo.v_DanhsachveThangsaphethan TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_CongSuatBaiDo TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_DoanhThuTheoBai TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_XeDangDoHienTai TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_VeThangSapHetHan TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_NhatKySuCo TO r_QuanLyBai;
GO

-- C. Quyền r_BaoVe: Nhân viên bảo vệ trực cổng bãi xe
-- Chỉ có quyền quét xe vào/ra qua Procedure và tra cứu sơ đồ ô đỗ
GRANT EXECUTE ON dbo.sp_XeVaoBai TO r_BaoVe;
GRANT EXECUTE ON dbo.sp_XeRaBai TO r_BaoVe;
GRANT EXECUTE ON dbo.sp_BaoMatThe TO r_BaoVe;
GRANT EXECUTE ON dbo.sp_DangNhap TO r_BaoVe;

-- Cho phép xem sơ đồ ô đỗ thời gian thực để hướng dẫn khách
GRANT SELECT ON dbo.v_SodoOdoRealtime TO r_BaoVe;
GRANT SELECT ON dbo.v_Xedangtrongbai TO r_BaoVe;

-- Chặn nghiêm ngặt: Nhân viên bảo vệ tuyệt đối KHÔNG ĐƯỢC sửa hoặc xóa dữ liệu tài chính/lượt xe
DENY UPDATE, DELETE ON dbo.LUOT_GUI TO r_BaoVe;
DENY UPDATE, DELETE ON dbo.HOA_DON_VE_THANG TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN TO r_BaoVe;
GO

-- ====================================================================================
-- 3. PHÂN QUYỀN BỔ SUNG CHO 7 VIEWS BỐT KIỂM SOÁT CỔNG & SƠ ĐỒ BÃI XE REALTIME
-- ====================================================================================

-- A. Nhân viên bảo vệ trực bốt cổng: được tra cứu thẻ, xem xe chờ ra, nhật ký vào/ra và bảng đèn cổng
GRANT SELECT ON dbo.v_BotCong_TraCuuThe TO r_BaoVe;
GRANT SELECT ON dbo.v_BotCong_XeChoRa TO r_BaoVe;
GRANT SELECT ON dbo.v_BotCong_NhatKyVaoRa TO r_BaoVe;
GRANT SELECT ON dbo.v_BotCong_BangDenCong TO r_BaoVe;

-- Được xem sơ đồ bãi xe thời gian thực để hướng dẫn khách vào đúng khu vực còn chỗ
GRANT SELECT ON dbo.v_SodoBai_ODoChiTiet TO r_BaoVe;
GRANT SELECT ON dbo.v_SodoBai_TongHopKhuVuc TO r_BaoVe;
GRANT SELECT ON dbo.v_SodoBai_TongQuanBai TO r_BaoVe;
GO

-- B. Quản lý bãi: xem toàn bộ 7 views vận hành bốt cổng và sơ đồ realtime
GRANT SELECT ON dbo.v_BotCong_TraCuuThe TO r_QuanLyBai;
GRANT SELECT ON dbo.v_BotCong_XeChoRa TO r_QuanLyBai;
GRANT SELECT ON dbo.v_BotCong_NhatKyVaoRa TO r_QuanLyBai;
GRANT SELECT ON dbo.v_BotCong_BangDenCong TO r_QuanLyBai;
GRANT SELECT ON dbo.v_SodoBai_ODoChiTiet TO r_QuanLyBai;
GRANT SELECT ON dbo.v_SodoBai_TongHopKhuVuc TO r_QuanLyBai;
GRANT SELECT ON dbo.v_SodoBai_TongQuanBai TO r_QuanLyBai;
GO
