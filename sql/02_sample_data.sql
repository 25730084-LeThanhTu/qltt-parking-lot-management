-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 2: NẠP DỮ LIỆU KHỞI TẠO MẪU (SAMPLE DATA CHO 11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

-- SINH TỰ ĐỘNG TỪ docs/QuanLyBaiDoXe_DuLieuMau.xlsx (NGUỒN CHUẨN CỦA DỮ LIỆU MẪU).
-- Không sửa tay file này: sửa dữ liệu trong Excel (sheet KiemTra phải ĐẠT hết) rồi sinh lại.
-- Các cột dẫn xuất (SucChua, SoLuongHienTai, VI_TRI_DO.TrangThai, TienGui, SoTien, NgayHetHan, MaHD...)
-- được ghi đúng giá trị Excel đã tính, nên không cần UPDATE đồng bộ sau khi nạp.
-- Dòng có mốc tương đối (xe đang đỗ, vé V0007) dùng DATEADD(..., GETDATE()) để luôn đúng tại thời điểm nạp.

-- 1. Bãi Đỗ Xe (5 chi nhánh; SucChua = số ô đỗ, SoLuongHienTai = số xe đang đỗ)
INSERT INTO dbo.BAI_DO_XE (MaBai, TenBai, DiaChi, SucChua, SoLuongHienTai) VALUES
('BAI_Q1', N'Bãi xe Lê Lai - Bến Thành', N'Số 26 Lê Lai, Phường Bến Thành, Quận 1, TP.HCM', 12, 2),
('BAI_Q3', N'Bãi xe Hai Bà Trưng', N'Số 180 Hai Bà Trưng, Phường Đa Kao, Quận 3, TP.HCM', 10, 1),
('BAI_BT', N'Bãi xe Landmark 81', N'Số 208 Nguyễn Hữu Cảnh, Phường 22, Bình Thạnh, TP.HCM', 12, 1),
('BAI_TB', N'Bãi xe TCP Park - Sân bay Tân Sơn Nhất', N'Cạnh nhà ga quốc nội, Cảng HKQT Tân Sơn Nhất, Phường 2, Quận Tân Bình, TP.HCM', 14, 3),
('BAI_Q7', N'Bãi xe SC VivoCity', N'Số 1058 Nguyễn Văn Linh, Phường Tân Phong, Quận 7, TP.HCM', 12, 2);
GO

-- 2. Hồ sơ Nhân Viên (Ban giám đốc, Quản lý bãi, Bảo vệ ca trực)
INSERT INTO dbo.NHAN_VIEN (MaNV, HoTen, ChucVu, SDT, Email, MaBai) VALUES
('NV001', N'Nguyễn Hữu Trí', N'Giám đốc điều hành', '0901000001', 'tri.nguyen@smartparking.vn', NULL),
('NV002', N'Trần Văn Hùng', N'Quản lý bãi', '0901000002', 'hung.tran@smartparking.vn', 'BAI_Q1'),
('NV003', N'Lê Thị Bích Ngọc', N'Quản lý bãi', '0901000003', 'ngoc.le@smartparking.vn', 'BAI_Q3'),
('NV004', N'Hoàng Đình Nam', N'Quản lý bãi', '0901000004', 'nam.hoang@smartparking.vn', 'BAI_BT'),
('NV005', N'Phạm Văn Cường', N'Bảo vệ', '0901000005', 'cuong.pham@smartparking.vn', 'BAI_Q1'),
('NV006', N'Đặng Minh Tuấn', N'Bảo vệ', '0901000006', 'tuan.dang@smartparking.vn', 'BAI_Q3'),
('NV007', N'Vũ Đức Thắng', N'Bảo vệ', '0901000007', 'thang.vu@smartparking.vn', 'BAI_BT'),
('NV008', N'Huỳnh Quốc Bảo', N'Quản lý bãi', '0901000008', 'bao.huynh@smartparking.vn', 'BAI_TB'),
('NV009', N'Ngô Thị Thanh Hà', N'Quản lý bãi', '0901000009', 'ha.ngo@smartparking.vn', 'BAI_Q7'),
('NV010', N'Trương Văn Lộc', N'Bảo vệ', '0901000010', 'loc.truong@smartparking.vn', 'BAI_TB'),
('NV011', N'Bùi Thành Đạt', N'Bảo vệ', '0901000011', 'dat.bui@smartparking.vn', 'BAI_Q7');
GO

-- 3. Tài Khoản Truy Cập (mật khẩu băm SHA-256 từ cột MatKhauMau của Excel)
INSERT INTO dbo.TAI_KHOAN (TenDangNhap, MatKhauHash, MaNV, TrangThai) VALUES
('admin', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin@2026'), 2), 'NV001', N'Hoạt động'),
('quanly_q1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV002', N'Hoạt động'),
('quanly_q3', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV003', N'Hoạt động'),
('quanly_bt', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV004', N'Hoạt động'),
('baove_khoa', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV005', N'Bị khóa'),
('baove_q1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV005', N'Hoạt động'),
('baove_q3', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV006', N'Hoạt động'),
('baove_bt', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV007', N'Hoạt động'),
('quanly_tb', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV008', N'Hoạt động'),
('quanly_q7', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV009', N'Hoạt động'),
('baove_tb', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV010', N'Hoạt động'),
('baove_q7', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV011', N'Hoạt động');
GO

-- 4. Phân Loại Phương Tiện & Biểu Phí theo từng Bãi Đỗ
INSERT INTO dbo.LOAI_XE (MaLoaiXe, MaBai, TenLoai, DonGiaGio, GiaVeThang) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 3 loại xe
('OT', 'BAI_Q1', N'Ô tô 4-7 chỗ', 25000, 1800000),
('XD', 'BAI_Q1', N'Xe đạp / Xe điện', 3000, 80000),
('XM', 'BAI_Q1', N'Xe máy', 6000, 180000),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 3 loại xe
('OT', 'BAI_Q3', N'Ô tô 4-7 chỗ', 20000, 1500000),
('XD', 'BAI_Q3', N'Xe đạp / Xe điện', 2000, 60000),
('XM', 'BAI_Q3', N'Xe máy', 5000, 150000),

-- Bãi xe Landmark 81 (BAI_BT) - 3 loại xe
('OT', 'BAI_BT', N'Ô tô 4-7 chỗ', 30000, 2200000),
('XD', 'BAI_BT', N'Xe đạp / Xe điện', 4000, 90000),
('XM', 'BAI_BT', N'Xe máy', 7000, 200000),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 3 loại xe
('OT', 'BAI_TB', N'Ô tô 4-7 chỗ', 25000, 1600000),
('XD', 'BAI_TB', N'Xe đạp / Xe điện', 3000, 80000),
('XM', 'BAI_TB', N'Xe máy', 5000, 200000),

-- Bãi xe SC VivoCity (BAI_Q7) - 3 loại xe
('OT', 'BAI_Q7', N'Ô tô 4-7 chỗ', 20000, 1700000),
('XD', 'BAI_Q7', N'Xe đạp / Xe điện', 2000, 70000),
('XM', 'BAI_Q7', N'Xe máy', 5000, 170000);
GO

-- 5. Vị Trí Ô Đỗ Xe (60 vị trí; TrangThai = 'Đã đỗ' khi có lượt đang mở)
INSERT INTO dbo.VI_TRI_DO (MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 12 vị trí
('Q1_OT_01', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_02', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_03', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_04', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_XD_01', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XD_02', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XM_01', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_02', N'Khu A - Tầng 1', N'Đã đỗ', 'XM', 'BAI_Q1'),
('Q1_XM_03', N'Khu A - Tầng 1', N'Đã đỗ', 'XM', 'BAI_Q1'),
('Q1_XM_04', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_05', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_06', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 10 vị trí
('Q3_OT_01', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_02', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_03', N'Khu Ô tô Sân 2', N'Trống', 'OT', 'BAI_Q3'),
('Q3_XD_01', N'Khu Xe đạp 1', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XD_02', N'Khu Xe đạp 2', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XM_01', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_02', N'Khu Máy A', N'Đã đỗ', 'XM', 'BAI_Q3'),
('Q3_XM_03', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_04', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_05', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),

-- Bãi xe Landmark 81 (BAI_BT) - 12 vị trí
('BT_OT_01', N'Hầm B2 - Zone A', N'Đã đỗ', 'OT', 'BAI_BT'),
('BT_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_03', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_XD_01', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XD_02', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XM_01', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_02', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_03', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_04', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_05', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_06', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 14 vị trí
('TB_OT_01', N'Tầng 2 - Khu ô tô', N'Đã đỗ', 'OT', 'BAI_TB'),
('TB_OT_02', N'Tầng 2 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_03', N'Tầng 2 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_04', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_05', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_06', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_XD_01', N'Tầng 1 - Cổng vào', N'Trống', 'XD', 'BAI_TB'),
('TB_XD_02', N'Tầng 1 - Cổng vào', N'Trống', 'XD', 'BAI_TB'),
('TB_XM_01', N'Tầng 1 - Khu xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_02', N'Tầng 1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_TB'),
('TB_XM_03', N'Tầng 1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_TB'),
('TB_XM_04', N'Tầng 1 - Khu xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_05', N'Tầng lửng - Xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_06', N'Tầng lửng - Xe máy', N'Trống', 'XM', 'BAI_TB'),

-- Bãi xe SC VivoCity (BAI_Q7) - 12 vị trí
('Q7_OT_01', N'Hầm B2 - Zone A', N'Đã đỗ', 'OT', 'BAI_Q7'),
('Q7_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_03', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_05', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_Q7'),
('Q7_XD_01', N'Hầm B1 - Khu xe đạp', N'Trống', 'XD', 'BAI_Q7'),
('Q7_XD_02', N'Hầm B1 - Khu xe đạp', N'Trống', 'XD', 'BAI_Q7'),
('Q7_XM_01', N'Hầm B1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_Q7'),
('Q7_XM_02', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_03', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_04', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_05', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7');
GO

-- 6. Kho Thẻ Xe theo bãi phát hành
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 6 thẻ
('THE0001', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0002', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-01'),
('THE0003', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0004', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-10'),
('THE0005', 'BAI_Q1', N'Lượt', N'Bị khóa', '2026-01-12'),
('THE0006', 'BAI_Q1', N'Lượt', N'Mất', '2026-01-15'),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 4 thẻ
('THE0007', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0008', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-03'),
('THE0009', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0010', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-08'),

-- Bãi xe Landmark 81 (BAI_BT) - 5 thẻ
('THE0011', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0012', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-02'),
('THE0013', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0014', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-06'),
('THE0015', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-10'),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 5 thẻ
('THE0016', 'BAI_TB', N'Lượt', N'Hoạt động', '2026-02-01'),
('THE0017', 'BAI_TB', N'Tháng', N'Hoạt động', '2026-03-01'),
('THE0018', 'BAI_TB', N'Lượt', N'Hoạt động', '2026-02-01'),
('THE0019', 'BAI_TB', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE)),
('THE0020', 'BAI_TB', N'Lượt', N'Bị khóa', '2026-02-10'),

-- Bãi xe SC VivoCity (BAI_Q7) - 5 thẻ
('THE0021', 'BAI_Q7', N'Lượt', N'Hoạt động', '2026-01-15'),
('THE0022', 'BAI_Q7', N'Tháng', N'Hoạt động', '2026-01-15'),
('THE0023', 'BAI_Q7', N'Lượt', N'Hoạt động', '2026-01-15'),
('THE0024', 'BAI_Q7', N'Tháng', N'Hoạt động', '2026-06-01'),
('THE0025', 'BAI_Q7', N'Lượt', N'Mất', '2026-01-20');
GO

-- 7. Hồ sơ Khách Hàng
INSERT INTO dbo.KHACH_HANG (MaKH, HoTen, SDT, Email, CMND_CCCD) VALUES
('KH0001', N'Nguyễn Văn An', '0903112233', 'nguyenvanan@gmail.com', '079090001111'),
('KH0002', N'Trần Thị Mai', '0912445566', 'tranmai.hcm@gmail.com', '079090002222'),
('KH0003', N'Lê Hoàng Long', '0988776655', 'long.lehoang@yahoo.com', '079090003333'),
('KH0004', N'Phạm Thu Trang', '0934556677', 'trangpham@outlook.com', '079090004444'),
('KH0005', N'Võ Minh Quân', '0977112244', 'quan.vominh@gmail.com', '079090005555'),
('KH0006', N'Đỗ Thanh Phong', '0908246810', 'phong.dothanh@gmail.com', '079090006666'),
('KH0007', N'Lý Ngọc Hân', '0938135790', 'han.lyngoc@gmail.com', '079090007777'),
('KH0008', N'Châu Minh Khang', '0917258036', 'khang.chau@outlook.com', '079090018888'),
('KH0009', N'Tạ Thị Kim Oanh', '0966369147', 'oanh.takim@yahoo.com', '079090009999'),
('KH0010', N'Phan Gia Huy', '0945112233', 'huy.phangia@gmail.com', '079090010101');
GO

-- 8. Vé Tháng (NgayHetHan = NgayDangKy + tổng số tháng trên hóa đơn)
INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung) VALUES
('V0001', 'THE0002', 'KH0001', '59A-123.45', 'XM', '2026-01-01', '2027-01-01', N'Hoạt động', 'BAI_Q1'),
('V0002', 'THE0004', 'KH0002', '51G-888.99', 'OT', '2026-01-10', '2026-10-10', N'Hoạt động', 'BAI_Q1'),
('V0003', 'THE0008', 'KH0003', '59B-456.78', 'XM', '2026-01-03', '2026-02-03', N'Hết hạn', 'BAI_Q3'),
('V0004', 'THE0010', 'KH0004', '51H-999.11', 'OT', '2026-01-08', '2026-11-08', N'Hoạt động', 'ALL'),
('V0005', 'THE0012', 'KH0005', '59C-678.90', 'XM', '2026-01-02', '2027-01-02', N'Hoạt động', 'BAI_BT'),
('V0006', 'THE0017', 'KH0006', '51K-246.80', 'OT', '2026-03-01', '2027-03-01', N'Hoạt động', 'BAI_TB'),
('V0007', 'THE0019', 'KH0007', '59P-357.91', 'XM', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -28, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_TB'),
('V0008', 'THE0022', 'KH0008', '59N-147.25', 'XM', '2026-01-15', '2026-07-15', N'Hết hạn', 'BAI_Q7'),
('V0009', 'THE0024', 'KH0009', '51L-802.46', 'OT', '2026-06-01', '2026-12-01', N'Hoạt động', 'BAI_Q7'),
('V0010', 'THE0014', 'KH0010', '51M-135.24', 'OT', '2026-01-06', '2027-01-06', N'Hoạt động', 'BAI_BT');
GO

-- 9. Hóa Đơn Vé Tháng (SoTien = số tháng x giá vé tháng tại bãi tính giá)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai) VALUES
('HD20260101001', 'V0001', '2026-01-01 00:00:00', 12, 2160000, 'BAI_Q1'),
('HD20260110002', 'V0002', '2026-01-10 00:00:00', 9, 16200000, 'BAI_Q1'),
('HD20260103003', 'V0003', '2026-01-03 00:00:00', 1, 150000, 'BAI_Q3'),
('HD20260108004', 'V0004', '2026-01-08 00:00:00', 10, 15000000, 'BAI_Q3'),
('HD20260102005', 'V0005', '2026-01-02 00:00:00', 12, 2400000, 'BAI_BT'),
('HD20260301006', 'V0006', '2026-03-01 00:00:00', 12, 19200000, 'BAI_TB'),
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), 'yyyyMMdd'), '007'), 'V0007', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), 1, 200000, 'BAI_TB'),
('HD20260115008', 'V0008', '2026-01-15 00:00:00', 6, 1020000, 'BAI_Q7'),
('HD20260601009', 'V0009', '2026-06-01 00:00:00', 6, 10200000, 'BAI_Q7'),
('HD20260106010', 'V0010', '2026-01-06 00:00:00', 12, 26400000, 'BAI_BT');
GO

-- 10. Nhật Ký Lượt Gửi Xe (MaLuot IDENTITY theo thứ tự dòng; TienGui theo f_TinhTienGuiXe, thẻ tháng = 0)
-- Lượt đã check-out
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59A-111.22', '2026-09-07 07:15:00', '2026-09-07 11:15:00', 'Q1_XM_01', 24000, 'BAI_Q1'),
('THE0003', '51G-222.33', '2026-09-07 08:00:00', '2026-09-07 14:00:00', 'Q1_OT_01', 150000, 'BAI_Q1'),
('THE0007', '59B-333.44', '2026-09-07 09:30:00', '2026-09-07 12:30:00', 'Q3_XM_01', 15000, 'BAI_Q3'),
('THE0011', '59C-444.55', '2026-09-07 06:45:00', '2026-09-07 17:45:00', 'BT_XM_01', 77000, 'BAI_BT'),
('THE0016', '59D-234.56', '2026-09-07 05:30:00', '2026-09-07 08:10:00', 'TB_XM_01', 15000, 'BAI_TB'),
('THE0018', '51F-135.79', '2026-09-07 10:00:00', '2026-09-07 15:20:00', 'TB_OT_04', 150000, 'BAI_TB'),
('THE0017', '51K-246.80', '2026-09-08 06:00:00', '2026-09-08 18:00:00', 'TB_OT_02', 0, 'BAI_TB'),
('THE0021', '59T-111.22', '2026-09-07 18:00:00', '2026-09-07 21:45:00', 'Q7_XM_02', 20000, 'BAI_Q7'),
('THE0023', '51H-246.13', '2026-09-07 11:00:00', '2026-09-07 11:10:00', 'Q7_OT_03', 0, 'BAI_Q7');

-- Lượt hiện đang đỗ (ThoiGianRa IS NULL)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59K-987.65', DATEADD(MINUTE, -120, GETDATE()), NULL, 'Q1_XM_02', 0, 'BAI_Q1'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -240, GETDATE()), NULL, 'Q1_XM_03', 0, 'BAI_Q1'),
('THE0007', '59E-555.66', DATEADD(MINUTE, -60, GETDATE()), NULL, 'Q3_XM_02', 0, 'BAI_Q3'),
('THE0013', '51A-777.88', DATEADD(MINUTE, -180, GETDATE()), NULL, 'BT_OT_01', 0, 'BAI_BT'),
('THE0016', '59D-678.12', DATEADD(MINUTE, -90, GETDATE()), NULL, 'TB_XM_02', 0, 'BAI_TB'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -300, GETDATE()), NULL, 'TB_XM_03', 0, 'BAI_TB'),
('THE0018', '51G-468.02', DATEADD(MINUTE, -120, GETDATE()), NULL, 'TB_OT_01', 0, 'BAI_TB'),
('THE0024', '51L-802.46', DATEADD(MINUTE, -360, GETDATE()), NULL, 'Q7_OT_01', 0, 'BAI_Q7'),
('THE0021', '59T-579.13', DATEADD(MINUTE, -60, GETDATE()), NULL, 'Q7_XM_01', 0, 'BAI_Q7');
GO

-- 11. Nhật Ký Sự Cố (sự cố mất thẻ áp phí phạt PhatMatThe)
INSERT INTO dbo.LICHSU_SU_CO (MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai) VALUES
('THE0006', '59X-999.01', '2026-01-15 11:00:00', N'Khách hàng làm rơi thẻ xe tại quầy nước, lập biên bản báo mất thẻ chip', 50000, N'Đã giải quyết', 'BAI_Q1'),
(NULL, '51B-123.45', '2026-02-10 18:30:00', N'Va quẹt nhẹ gương chiếu hậu khi lùi xe vào ô đỗ Q3_OT_01', 200000, N'Đã giải quyết', 'BAI_Q3'),
(NULL, '51F-135.79', '2026-09-07 10:05:00', N'Ô tô cọ quẹt trụ bê tông tại dốc lên Tầng 3, trầy sơn hông xe, đang chờ đối chiếu camera', 300000, N'Đang giải quyết', 'BAI_TB'),
('THE0025', NULL, '2026-08-20 20:15:00', N'Khách hàng báo mất thẻ chip THE0025 (Loại: Lượt). Hệ thống tự động khóa thẻ và áp phí phạt đền bù thẻ vật lý.', 50000, N'Đã giải quyết', 'BAI_Q7');
GO
