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
DENY SELECT ON dbo.TAI_KHOAN (MatKhauHash, MatKhauSalt) TO r_QuanLyBai;   -- xem tài khoản, không xem hash / salt (N5)
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

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- PHÂN QUYỀN TÀI KHOẢN KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 4)
--
-- LỚP 1 · Role r_KhachHang: chỉ EXECUTE sp_KH_* và SELECT vw_KH_*, DENY mọi bảng gốc.
--         Procedure / view thuộc dbo nên ownership chaining cho phép chúng đọc / ghi bảng dù bảng bị DENY.
-- LỚP 2 · Row-Level Security (policy bao_mat.rls_KhachHang): user thuộc r_KhachHang chỉ thấy dòng của
--         khách trong SESSION_CONTEXT('MaKH') (và vé được ủy quyền). dbo / nhân viên không bị lọc.
-- LỚP 3 · Quyền nghiệp vụ: f_KH_CoQuyen trong từng sp_KH_* (bước 12, 13).
--
-- Giả định bảo mật: người dùng cuối không kết nối thẳng vào CSDL; chỉ máy chủ web giữ thông tin đăng nhập
-- của login cổng khách hàng và đặt SESSION_CONTEXT (read-only) qua sp_KH_DangNhap.
-- Script idempotent. Policy RLS bật sau cùng.
-- ====================================================================================

-- 1. Role và user dùng cho cổng khách hàng
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'r_KhachHang' AND type = 'R')
    CREATE ROLE r_KhachHang;
GO

-- User không gắn login dùng để demo bằng EXECUTE AS USER; khi triển khai thật, tạo login riêng
-- (ví dụ login_WebKhachHang) và CREATE USER ... FOR LOGIN rồi thêm vào r_KhachHang.
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'u_WebKhachHang')
    CREATE USER u_WebKhachHang WITHOUT LOGIN;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    INNER JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    INNER JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id
    WHERE r.name = 'r_KhachHang' AND u.name = 'u_WebKhachHang'
)
    ALTER ROLE r_KhachHang ADD MEMBER u_WebKhachHang;
GO

-- ====================================================================================
-- 2. LỚP 1: QUYỀN CỦA r_KhachHang
-- ====================================================================================
GRANT EXECUTE ON dbo.sp_KH_DangKyTaiKhoan TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DangNhap TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DoiMatKhau TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_NapTien_KhoiTao TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_GiaHanBangVi TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_CaiDatTuDongGiaHan TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_UyQuyenVe TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_ThuHoiUyQuyen TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_BaoMatThe TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DanhDauDaDoc TO r_KhachHang;

GRANT SELECT ON dbo.vw_KH_HoSoCuaToi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_VeThangCuaToi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_LichSuDoXe TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_LichSuGiaoDich TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_HoaDonCuaToi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_ThongBao TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_NhatKyDangNhap TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_PhuongThucNapVi TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_HanMucNap TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_QuyenTrenVe TO r_KhachHang;
GRANT SELECT ON dbo.vw_KH_VaiTroUyQuyen TO r_KhachHang;
GRANT EXECUTE ON dbo.sp_KH_DanhSachUyQuyen TO r_KhachHang;
GRANT SELECT ON dbo.f_KH_SaoKeVi TO r_KhachHang;
GRANT EXECUTE ON dbo.f_KH_TinhPhiGiaHan TO r_KhachHang;   -- xem trước giá gia hạn trên UI
GO

-- Callback cổng thanh toán, thủ tục nhân viên và lõi gia hạn: tuyệt đối không cho khách gọi trực tiếp
DENY EXECUTE ON dbo.sp_KH_NapTien_XacNhan TO r_KhachHang;
DENY EXECUTE ON dbo.sp_NV_HoanTien TO r_KhachHang;
DENY EXECUTE ON dbo.sp_NV_MoKhoaTaiKhoanKH TO r_KhachHang;
DENY EXECUTE ON dbo.sp_NV_NapTienTaiQuay TO r_KhachHang;
DENY EXECUTE ON dbo.sp_GiaHanVe_Core TO r_KhachHang;
DENY EXECUTE ON dbo.sp_GiaHanTheThang TO r_KhachHang;
DENY EXECUTE ON dbo.sp_SinhMaGiaoDich TO r_KhachHang;
GO

-- DENY từng bảng (không DENY trên cả schema dbo vì DENY schema sẽ thắng cả GRANT trên procedure / view)
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.BAI_DO_XE TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.NHAN_VIEN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.LOAI_XE TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VI_TRI_DO TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.THE_XE TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.KHACH_HANG TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VE_THANG TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.LUOT_GUI TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.HOA_DON_VE_THANG TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.LICHSU_SU_CO TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.PHUONG_THUC_THANH_TOAN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN_KH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.NHAT_KY_DANG_NHAP TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VI_DIEN_TU TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.GIAO_DICH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.THONG_BAO TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.QUYEN_KH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VAI_TRO_KH TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VAI_TRO_QUYEN TO r_KhachHang;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.UY_QUYEN_VE TO r_KhachHang;
GO

-- ====================================================================================
-- 3. BỔ SUNG QUYỀN CHO VAI TRÒ NHÂN VIÊN HIỆN CÓ
-- ====================================================================================

-- Quản lý bãi: xem tài chính / tài khoản khách (trừ cột mật khẩu), thao tác qua thủ tục nhân viên
GRANT SELECT ON dbo.PHUONG_THUC_THANH_TOAN TO r_QuanLyBai;
GRANT SELECT ON dbo.TAI_KHOAN_KH TO r_QuanLyBai;
DENY SELECT ON dbo.TAI_KHOAN_KH (MatKhauHash, MatKhauSalt) TO r_QuanLyBai;
GRANT SELECT ON dbo.NHAT_KY_DANG_NHAP TO r_QuanLyBai;
GRANT SELECT ON dbo.VI_DIEN_TU TO r_QuanLyBai;
GRANT SELECT ON dbo.GIAO_DICH TO r_QuanLyBai;
GRANT SELECT ON dbo.THONG_BAO TO r_QuanLyBai;
GRANT SELECT ON dbo.UY_QUYEN_VE TO r_QuanLyBai;
GRANT SELECT ON dbo.QUYEN_KH TO r_QuanLyBai;
GRANT SELECT ON dbo.VAI_TRO_KH TO r_QuanLyBai;
GRANT SELECT ON dbo.VAI_TRO_QUYEN TO r_QuanLyBai;

GRANT EXECUTE ON dbo.sp_NV_HoanTien TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_NV_MoKhoaTaiKhoanKH TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_NV_NapTienTaiQuay TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoTuDongGiaHanVeThang TO r_QuanLyBai;
GRANT EXECUTE ON dbo.sp_DemoDoiSoatViDienTu TO r_QuanLyBai;

GRANT SELECT ON dbo.vw_Report_DoanhThuTheoPhuongThuc TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_TongQuanViDienTu TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_GiaoDichCanXuLy TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_BaoMatTaiKhoanKH TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_TyLeChuyenDoiOnline TO r_QuanLyBai;

-- Không vai trò nhân viên nào được sửa số dư hay sửa / xóa sổ cái (trigger vẫn chặn cả r_Admin)
DENY UPDATE ON dbo.VI_DIEN_TU TO r_QuanLyBai;
DENY INSERT, UPDATE, DELETE ON dbo.GIAO_DICH TO r_QuanLyBai;
GO

-- Bảo vệ: không truy cập dữ liệu tài chính và tài khoản khách hàng
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.TAI_KHOAN_KH TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.NHAT_KY_DANG_NHAP TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.VI_DIEN_TU TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.GIAO_DICH TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.THONG_BAO TO r_BaoVe;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.UY_QUYEN_VE TO r_BaoVe;
GO

-- ====================================================================================
-- 4. LỚP 2: ROW-LEVEL SECURITY
-- ====================================================================================
IF SCHEMA_ID('bao_mat') IS NULL
    EXEC('CREATE SCHEMA bao_mat AUTHORIZATION dbo');
GO

-- Hàm predicate gắn SCHEMABINDING vào bảng: phải gỡ policy trước khi sửa hàm
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'rls_KhachHang')
    DROP SECURITY POLICY bao_mat.rls_KhachHang;
GO

-- Quy tắc chung của mọi predicate:
--   USER_NAME() = 'dbo'                -> chủ CSDL / sa (ứng dụng demo hiện tại) và thủ tục WITH EXECUTE AS OWNER
--   IS_ROLEMEMBER('r_KhachHang') = 0   -> nhân viên (r_Admin, r_QuanLyBai, r_BaoVe)
--   còn lại                            -> khách hàng: chỉ dòng của khách trong SESSION_CONTEXT

-- Bảng có cột MaKH: VI_DIEN_TU, THONG_BAO, TAI_KHOAN_KH
CREATE OR ALTER FUNCTION bao_mat.fn_rls_KhachHang (@MaKH VARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR @MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10));
GO

-- VE_THANG: vé của tôi + vé được ủy quyền còn hiệu lực cho tài khoản của tôi
CREATE OR ALTER FUNCTION bao_mat.fn_rls_VeThang (@MaVe VARCHAR(10), @MaKH VARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR @MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10))
       OR EXISTS (
            SELECT 1
            FROM dbo.UY_QUYEN_VE uq
            WHERE uq.MaVe = @MaVe
              AND uq.MaTKDuocUyQuyen = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12))
              AND uq.TrangThai = N'Hiệu lực'
              AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE)));
GO

-- GIAO_DICH: không có cột MaKH, tra chủ ví
CREATE OR ALTER FUNCTION bao_mat.fn_rls_GiaoDich (@MaVi VARCHAR(12))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR EXISTS (
            SELECT 1
            FROM dbo.VI_DIEN_TU vi
            WHERE vi.MaVi = @MaVi
              AND vi.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10)));
GO

-- LUOT_GUI, HOA_DON_VE_THANG: theo vé (lượt gửi thẻ lượt có MaVe NULL -> khách không thấy)
CREATE OR ALTER FUNCTION bao_mat.fn_rls_TheoVe (@MaVe VARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS ChoPhep
    WHERE USER_NAME() = N'dbo'
       OR IS_ROLEMEMBER(N'r_KhachHang') = 0
       OR EXISTS (
            SELECT 1
            FROM dbo.VE_THANG v
            WHERE v.MaVe = @MaVe
              AND (v.MaKH = CAST(SESSION_CONTEXT(N'MaKH') AS VARCHAR(10))
                   OR EXISTS (
                        SELECT 1
                        FROM dbo.UY_QUYEN_VE uq
                        WHERE uq.MaVe = v.MaVe
                          AND uq.MaTKDuocUyQuyen = CAST(SESSION_CONTEXT(N'MaTK') AS VARCHAR(12))
                          AND uq.TrangThai = N'Hiệu lực'
                          AND (uq.NgayKetThuc IS NULL OR uq.NgayKetThuc >= CAST(GETDATE() AS DATE)))));
GO

CREATE SECURITY POLICY bao_mat.rls_KhachHang
    ADD FILTER PREDICATE bao_mat.fn_rls_KhachHang(MaKH) ON dbo.VI_DIEN_TU,
    ADD FILTER PREDICATE bao_mat.fn_rls_KhachHang(MaKH) ON dbo.THONG_BAO,
    ADD FILTER PREDICATE bao_mat.fn_rls_KhachHang(MaKH) ON dbo.TAI_KHOAN_KH,
    ADD FILTER PREDICATE bao_mat.fn_rls_VeThang(MaVe, MaKH) ON dbo.VE_THANG,
    ADD FILTER PREDICATE bao_mat.fn_rls_GiaoDich(MaVi) ON dbo.GIAO_DICH,
    ADD FILTER PREDICATE bao_mat.fn_rls_TheoVe(MaVe) ON dbo.LUOT_GUI,
    ADD FILTER PREDICATE bao_mat.fn_rls_TheoVe(MaVe) ON dbo.HOA_DON_VE_THANG
WITH (STATE = ON);
GO
