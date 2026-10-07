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

-- 3. Tài Khoản Truy Cập (mật khẩu mẫu từ cột MatKhauMau của Excel)
--    Băm SHA2_512(salt + mật khẩu) giống dbo.f_BamMatKhau (N5). Salt cố định = 16 byte đầu SHA-256(TenDangNhap)
--    để seed tái lập được; tài khoản tạo mới sau này dùng salt ngẫu nhiên CRYPT_GEN_RANDOM(16).
INSERT INTO dbo.TAI_KHOAN (TenDangNhap, MatKhauHash, MatKhauSalt, MaNV, TrangThai) VALUES
('admin', HASHBYTES('SHA2_512', 0x8C6976E5B5410415BDE908BD4DEE15DF + CAST('Admin@2026' AS VARBINARY(100))), 0x8C6976E5B5410415BDE908BD4DEE15DF, 'NV001', N'Hoạt động'),
('quanly_q1', HASHBYTES('SHA2_512', 0xA96A1945520B26CBAAE8A493E34ACFB9 + CAST('123456' AS VARBINARY(100))), 0xA96A1945520B26CBAAE8A493E34ACFB9, 'NV002', N'Hoạt động'),
('quanly_q3', HASHBYTES('SHA2_512', 0xF653957CF726492E0F2E5258DB1CC602 + CAST('123456' AS VARBINARY(100))), 0xF653957CF726492E0F2E5258DB1CC602, 'NV003', N'Hoạt động'),
('quanly_bt', HASHBYTES('SHA2_512', 0x8105CD0384432837517622656FE8AE3A + CAST('123456' AS VARBINARY(100))), 0x8105CD0384432837517622656FE8AE3A, 'NV004', N'Hoạt động'),
('baove_khoa', HASHBYTES('SHA2_512', 0xC9DA96BE9B174D7E3ADB8BC19C056135 + CAST('123456' AS VARBINARY(100))), 0xC9DA96BE9B174D7E3ADB8BC19C056135, 'NV005', N'Bị khóa'),
('baove_q1', HASHBYTES('SHA2_512', 0xF2681DF9DA242214531CB15BCB0D0EB8 + CAST('123456' AS VARBINARY(100))), 0xF2681DF9DA242214531CB15BCB0D0EB8, 'NV005', N'Hoạt động'),
('baove_q3', HASHBYTES('SHA2_512', 0x4E141F23D8E2E4B9F45924CE23AB94E2 + CAST('123456' AS VARBINARY(100))), 0x4E141F23D8E2E4B9F45924CE23AB94E2, 'NV006', N'Hoạt động'),
('baove_bt', HASHBYTES('SHA2_512', 0xB41CF81A62EBB47CA02AB86856BFC382 + CAST('123456' AS VARBINARY(100))), 0xB41CF81A62EBB47CA02AB86856BFC382, 'NV007', N'Hoạt động'),
('quanly_tb', HASHBYTES('SHA2_512', 0xAE05E863F787058E47BAC04DDD713846 + CAST('123456' AS VARBINARY(100))), 0xAE05E863F787058E47BAC04DDD713846, 'NV008', N'Hoạt động'),
('quanly_q7', HASHBYTES('SHA2_512', 0x2C5A92CBA8CC97544F324DB0B6AF48FF + CAST('123456' AS VARBINARY(100))), 0x2C5A92CBA8CC97544F324DB0B6AF48FF, 'NV009', N'Hoạt động'),
('baove_tb', HASHBYTES('SHA2_512', 0xE3E16ADEA5EE497E9A25D94990CC8B7C + CAST('123456' AS VARBINARY(100))), 0xE3E16ADEA5EE497E9A25D94990CC8B7C, 'NV010', N'Hoạt động'),
('baove_q7', HASHBYTES('SHA2_512', 0x3CBFAFBA0CF795F7640B45765C5639D9 + CAST('123456' AS VARBINARY(100))), 0x3CBFAFBA0CF795F7640B45765C5639D9, 'NV011', N'Hoạt động');
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

-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- DỮ LIỆU MẪU CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 11)
--
-- TẠM THỜI VIẾT TAY: script sinh seed từ docs/QuanLyBaiDoXe_DuLieuMau.xlsx chưa có trong repo (N8).
-- Khi có script, chuyển dữ liệu dưới đây vào các sheet tương ứng của Excel master (D11) và sinh lại file này.
--
-- Quy ước giống 02_sample_data.sql:
-- - Chạy một lần trên CSDL vừa nạp 01 -> 10 (không idempotent, giống 02).
-- - Cột dẫn xuất ghi giá trị đã tính sẵn: VI_DIEN_TU.SoDu, GIAO_DICH.SoDuTruoc / SoDuSau (file này chạy TRƯỚC
--   khi trigger sổ cái ở bước 14 được tạo, nên không dựa vào trigger để tính số dư).
-- - Mốc thời gian tương đối dùng DATEADD(..., GETDATE()) để luôn đúng khi nạp lại.
-- - Mật khẩu mẫu của mọi tài khoản khách: 'Khach@2026', salt cố định (giá trị tổng hợp cho demo) để seed tái lập được.
--   Biểu thức hash trùng với dbo.f_BamMatKhau: HASHBYTES('SHA2_512', salt + CAST(<mật khẩu VARCHAR> AS VARBINARY(100))).
-- - Các lượt gửi lịch sử chèn ở đây đi qua trigger V6 của LUOT_GUI nên chỉ dùng vé còn hạn, đúng bãi, thẻ hoạt động.
-- ====================================================================================

-- 1. Tài khoản cổng khách hàng (8 tài khoản; KH0005 và KH0008 chưa có tài khoản - dùng cho demo đăng ký)
-- TK0005 (KH0006) đang tạm khóa để màn hình nhân viên có dữ liệu "Mở khóa".
INSERT INTO dbo.TAI_KHOAN_KH (MaTK, MaKH, TenDangNhap, MatKhauHash, MatKhauSalt, TrangThai, SoLanSaiLienTiep, KhoaDen, NgayTao, LanDangNhapCuoi) VALUES
('TK0001', 'KH0001', '0903112233', HASHBYTES('SHA2_512', 0x1F8A3C5E7B9D2F4061A3C5E7092B4D6F + CAST('Khach@2026' AS VARBINARY(100))), 0x1F8A3C5E7B9D2F4061A3C5E7092B4D6F, N'Hoạt động', 0, NULL, DATEADD(DAY, -60, GETDATE()), DATEADD(HOUR, -20, GETDATE())),
('TK0002', 'KH0002', '0912445566', HASHBYTES('SHA2_512', 0x2E9B4D6F8CAE3051728495A6B7C8D9E0 + CAST('Khach@2026' AS VARBINARY(100))), 0x2E9B4D6F8CAE3051728495A6B7C8D9E0, N'Hoạt động', 0, NULL, DATEADD(DAY, -45, GETDATE()), DATEADD(HOUR, -5, GETDATE())),
('TK0003', 'KH0003', '0988776655', HASHBYTES('SHA2_512', 0x3DAC5E7091BF416283A5C7E90B2D4F61 + CAST('Khach@2026' AS VARBINARY(100))), 0x3DAC5E7091BF416283A5C7E90B2D4F61, N'Hoạt động', 0, NULL, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -12, GETDATE())),
('TK0004', 'KH0004', '0934556677', HASHBYTES('SHA2_512', 0x4CBD6F81A2C05273940B6D8FA1C3E507 + CAST('Khach@2026' AS VARBINARY(100))), 0x4CBD6F81A2C05273940B6D8FA1C3E507, N'Hoạt động', 0, NULL, DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -2, GETDATE())),
('TK0005', 'KH0006', '0908246810', HASHBYTES('SHA2_512', 0x5BCE7092B3D16384A51C7E90B2D4F618 + CAST('Khach@2026' AS VARBINARY(100))), 0x5BCE7092B3D16384A51C7E90B2D4F618, N'Tạm khóa', 5, DATEADD(MINUTE, 10, GETDATE()), DATEADD(DAY, -62, GETDATE()), DATEADD(DAY, -3, GETDATE())),
('TK0006', 'KH0007', '0938135790', HASHBYTES('SHA2_512', 0x6ADF81A3C4E27495B62D8FA1C3E50729 + CAST('Khach@2026' AS VARBINARY(100))), 0x6ADF81A3C4E27495B62D8FA1C3E50729, N'Hoạt động', 0, NULL, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -1, GETDATE())),
('TK0007', 'KH0009', '0966369147', HASHBYTES('SHA2_512', 0x79E092B4D5F385A6C73E90B2D4F6183A + CAST('Khach@2026' AS VARBINARY(100))), 0x79E092B4D5F385A6C73E90B2D4F6183A, N'Hoạt động', 0, NULL, DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -4, GETDATE())),
('TK0008', 'KH0010', '0945112233', HASHBYTES('SHA2_512', 0x88F1A3C5E60496B7D84FA1C3E507294B + CAST('Khach@2026' AS VARBINARY(100))), 0x88F1A3C5E60496B7D84FA1C3E507294B, N'Hoạt động', 0, NULL, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -5, GETDATE()));
GO

-- 2. Nhật ký đăng nhập (TK0005 sai 5 lần trong 15 phút gần nhất -> đang tạm khóa)
INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP, ThietBi) VALUES
('TK0001', '0903112233', DATEADD(HOUR, -20, GETDATE()), N'Thành công', '113.161.45.10', N'Chrome / Windows'),
('TK0002', '0912445566', DATEADD(HOUR, -5, GETDATE()), N'Thành công', '14.169.22.81', N'Safari / iOS'),
('TK0004', '0934556677', DATEADD(DAY, -2, GETDATE()), N'Thành công', '27.72.98.140', N'Chrome / Android'),
('TK0006', '0938135790', DATEADD(DAY, -1, GETDATE()), N'Thành công', '171.244.10.55', N'Chrome / macOS'),
(NULL, '0900000000', DATEADD(HOUR, -3, GETDATE()), N'Không tồn tại', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -9, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -8, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -7, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -6, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -5, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4');
GO

-- 3. Ví điện tử (SoDu = tổng sổ cái các giao dịch 'Thành công' / 'Đã hoàn' ở mục 4)
INSERT INTO dbo.VI_DIEN_TU (MaVi, MaKH, SoDu, NgayTao) VALUES
('VI0001', 'KH0001', 300000, DATEADD(DAY, -60, GETDATE())),
('VI0002', 'KH0002', 3000000, DATEADD(DAY, -45, GETDATE())),
('VI0003', 'KH0003', 0, DATEADD(DAY, -40, GETDATE())),
('VI0004', 'KH0004', 50000, DATEADD(DAY, -42, GETDATE())),
('VI0005', 'KH0006', 2600000, DATEADD(DAY, -62, GETDATE())),
('VI0006', 'KH0007', 300000, DATEADD(DAY, -27, GETDATE())),
('VI0007', 'KH0009', 5000000, DATEADD(DAY, -21, GETDATE())),
('VI0008', 'KH0010', 100000, DATEADD(DAY, -6, GETDATE()));
GO

-- 4. Sổ cái giao dịch (theo thứ tự thời gian trong từng ví; SoDuTruoc / SoDuSau liên tục)
-- VI0001: 0 -> +480.000 (MoMo) -> -180.000 (gia hạn V0001 online) = 300.000; 1 lệnh VNPay thất bại
-- VI0002: 0 -> +3.000.000 (tiền mặt tại quầy) = 3.000.000; 1 lệnh chuyển khoản treo 2 giờ (cursor đối soát sẽ chuyển Thất bại)
-- VI0004: 0 -> +1.550.000 (thẻ) -> -1.500.000 (gia hạn V0004 online, giá bãi phát hành thẻ BAI_Q3) = 50.000
-- VI0005: 0 -> +2.600.000 -> -1.600.000 (gia hạn V0006) -> +1.600.000 -> -1.600.000 (trừ trùng, đã hoàn) -> +1.600.000 (hoàn) = 2.600.000
-- VI0006: +300.000 (ZaloPay, trước khi cổng tạm ngưng) | VI0007: +5.000.000 | VI0008: +100.000
INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, PhiGiaoDich, SoDuTruoc, SoDuSau, MaPTTT, MaThamChieu, TrangThai, MaVe, MaGDGoc, NguoiThucHien, MaNV, ThoiGianTao, ThoiGianHoanTat, GhiChu) VALUES
('GD260900000001', 'VI0001', N'Nạp tiền', 1, 480000, 7200, 0, 480000, 'MOMO', 'MOMO-SEED-0001', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000002', 'VI0001', N'Thanh toán vé tháng', -1, 180000, 0, 480000, 300000, 'SO_DU_VI', NULL, N'Thành công', 'V0001', NULL, N'Khách hàng', NULL, DATEADD(DAY, -24, GETDATE()), DATEADD(DAY, -24, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000003', 'VI0001', N'Nạp tiền', 1, 200000, 2200, NULL, NULL, 'VNPAY', 'VNPAY-SEED-0003', N'Thất bại', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -10, GETDATE()), N'Cổng thanh toán báo thất bại'),
('GD260900000004', 'VI0002', N'Nạp tiền', 1, 3000000, 0, 0, 3000000, 'TIEN_MAT', NULL, N'Thành công', NULL, NULL, N'Nhân viên', 'NV002', DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -30, GETDATE()), N'Nạp tiền mặt tại quầy'),
('GD260900000005', 'VI0002', N'Nạp tiền', 1, 1000000, 0, NULL, NULL, 'CHUYEN_KHOAN', NULL, N'Chờ xử lý', NULL, NULL, N'Khách hàng', NULL, DATEADD(MINUTE, -120, GETDATE()), NULL, N'Chờ kết quả từ cổng thanh toán'),
('GD260900000006', 'VI0004', N'Nạp tiền', 1, 1550000, 31000, 0, 1550000, 'THE_NH', 'THENH-SEED-0006', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -40, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000007', 'VI0004', N'Thanh toán vé tháng', -1, 1500000, 0, 1550000, 50000, 'SO_DU_VI', NULL, N'Thành công', 'V0004', NULL, N'Khách hàng', NULL, DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -39, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000008', 'VI0005', N'Nạp tiền', 1, 2600000, 28600, 0, 2600000, 'VNPAY', 'VNPAY-SEED-0008', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -60, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000009', 'VI0005', N'Thanh toán vé tháng', -1, 1600000, 0, 2600000, 1000000, 'SO_DU_VI', NULL, N'Thành công', 'V0006', NULL, N'Khách hàng', NULL, DATEADD(DAY, -59, GETDATE()), DATEADD(DAY, -59, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000010', 'VI0005', N'Nạp tiền', 1, 1600000, 24000, 1000000, 2600000, 'MOMO', 'MOMO-SEED-0010', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -31, GETDATE()), DATEADD(DAY, -31, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000011', 'VI0005', N'Thanh toán vé tháng', -1, 1600000, 0, 2600000, 1000000, 'SO_DU_VI', NULL, N'Đã hoàn', 'V0006', NULL, N'Khách hàng', NULL, DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -30, GETDATE()), N'Trừ trùng do lỗi kết nối | Đã hoàn tiền bởi GD260900000012'),
('GD260900000012', 'VI0005', N'Hoàn tiền', 1, 1600000, 0, 1000000, 2600000, 'SO_DU_VI', NULL, N'Thành công', 'V0006', 'GD260900000011', N'Nhân viên', 'NV008', DATEADD(DAY, -29, GETDATE()), DATEADD(DAY, -29, GETDATE()), N'Hoàn tiền giao dịch trừ trùng'),
('GD260900000013', 'VI0006', N'Nạp tiền', 1, 300000, 3600, 0, 300000, 'ZALOPAY', 'ZALO-SEED-0013', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -27, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000014', 'VI0007', N'Nạp tiền', 1, 5000000, 0, 0, 5000000, 'CHUYEN_KHOAN', 'BANK-SEED-0014', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -20, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000015', 'VI0008', N'Nạp tiền', 1, 100000, 1500, 0, 100000, 'MOMO', 'MOMO-SEED-0015', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, GETDATE()), N'Cổng thanh toán xác nhận thành công');
GO

-- Mã giao dịch sinh mới bắt đầu sau dải mã seed
ALTER SEQUENCE dbo.seq_GiaoDich RESTART WITH 1000;
GO

-- 5. Hai vé tháng mới có mốc tương đối (giống V0007): đăng ký 1 tháng cách thời điểm nạp 29 ngày,
--    nên luôn còn <= 3 ngày khi demo cursor tự động gia hạn.
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
('THE0026', 'BAI_Q7', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)),
('THE0027', 'BAI_BT', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE));
GO

INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung, TuDongGiaHan, SoThangTuDongGiaHan) VALUES
('V0011', 'THE0026', 'KH0009', '51L-913.57', 'OT', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_Q7', 1, 1),
('V0012', 'THE0027', 'KH0010', '51M-468.20', 'OT', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_BT', 1, 1);
GO

-- Bật tự động gia hạn cho V0007 (mốc tương đối sẵn có trong seed V6)
UPDATE dbo.VE_THANG SET TuDongGiaHan = 1, SoThangTuDongGiaHan = 1 WHERE MaVe = 'V0007';
GO

-- 6. Hóa đơn: 2 hóa đơn tại quầy của V0011 / V0012 và 3 hóa đơn online gắn giao dịch ví
-- (10 hóa đơn V6 tự nhận MaPTTT = 'TIEN_MAT', KenhThanhToan = 'Tại quầy' từ DEFAULT ở bước 10)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai, MaPTTT, KenhThanhToan, MaGD, MaNVThu) VALUES
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 'yyyyMMdd'), '011'), 'V0011', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 1, 1700000, 'BAI_Q7', 'TIEN_MAT', N'Tại quầy', NULL, 'NV009'),
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 'yyyyMMdd'), '012'), 'V0012', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 1, 2200000, 'BAI_BT', 'TIEN_MAT', N'Tại quầy', NULL, 'NV004'),
(CONCAT('HD', FORMAT(DATEADD(DAY, -24, GETDATE()), 'yyyyMMdd'), '013'), 'V0001', DATEADD(DAY, -24, GETDATE()), 1, 180000, 'BAI_Q1', 'SO_DU_VI', N'Online', 'GD260900000002', NULL),
(CONCAT('HD', FORMAT(DATEADD(DAY, -39, GETDATE()), 'yyyyMMdd'), '014'), 'V0004', DATEADD(DAY, -39, GETDATE()), 1, 1500000, 'BAI_Q3', 'SO_DU_VI', N'Online', 'GD260900000007', NULL),
(CONCAT('HD', FORMAT(DATEADD(DAY, -59, GETDATE()), 'yyyyMMdd'), '015'), 'V0006', DATEADD(DAY, -59, GETDATE()), 1, 1600000, 'BAI_TB', 'SO_DU_VI', N'Online', 'GD260900000009', NULL);
GO

-- Hạn dùng của 3 vé được gia hạn online tăng thêm 1 tháng (chuỗi hạn dùng nối theo hóa đơn, giống Excel master)
UPDATE dbo.VE_THANG
SET NgayHetHan = DATEADD(MONTH, 1, NgayHetHan)
WHERE MaVe IN ('V0001', 'V0004', 'V0006');
GO

-- 7. Ủy quyền: KH0001 chia sẻ V0001 cho tài khoản KH0002 với vai trò chỉ xem lịch sử
INSERT INTO dbo.UY_QUYEN_VE (MaVe, MaTKDuocUyQuyen, MaVaiTro, NgayBatDau, NgayKetThuc, TrangThai, MaTKCap, NgayTao) VALUES
('V0001', 'TK0002', 'XEM_LICH_SU', CAST(DATEADD(DAY, -10, GETDATE()) AS DATE), NULL, N'Hiệu lực', 'TK0001', DATEADD(DAY, -10, GETDATE()));
GO

-- 8. Thông báo mẫu (mỗi khách có tài khoản có ít nhất 1 thông báo chưa đọc)
INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe, MaGD, DaDoc, ThoiGianTao) VALUES
('KH0001', N'Giao dịch', N'Gia hạn vé tháng online thành công', N'Vé V0001 đã được gia hạn thêm 1 tháng bằng số dư ví (180.000 đồng).', 'V0001', 'GD260900000002', 1, DATEADD(DAY, -24, GETDATE())),
('KH0001', N'Ủy quyền', N'Đã chia sẻ vé tháng', N'Bạn đã chia sẻ vé V0001 cho tài khoản 0912445566 với vai trò Chỉ xem lịch sử.', 'V0001', NULL, 0, DATEADD(DAY, -10, GETDATE())),
('KH0002', N'Giao dịch', N'Nạp tiền tại quầy thành công', N'Ví đã được cộng 3.000.000 đồng tiền mặt tại quầy (giao dịch GD260900000004).', NULL, 'GD260900000004', 1, DATEADD(DAY, -30, GETDATE())),
('KH0002', N'Ủy quyền', N'Bạn được chia sẻ một vé tháng', N'Vé V0001 đã được chia sẻ cho bạn với vai trò Chỉ xem lịch sử (không thời hạn).', 'V0001', NULL, 0, DATEADD(DAY, -10, GETDATE())),
('KH0003', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Bạn có thể nạp tiền vào ví, tự gia hạn vé tháng và xem lịch sử đỗ xe.', NULL, NULL, 0, DATEADD(DAY, -40, GETDATE())),
('KH0004', N'Giao dịch', N'Gia hạn vé tháng online thành công', N'Vé V0004 đã được gia hạn thêm 1 tháng bằng số dư ví (1.500.000 đồng).', 'V0004', 'GD260900000007', 0, DATEADD(DAY, -39, GETDATE())),
('KH0006', N'Giao dịch', N'Hoàn tiền vào ví', N'Ví được hoàn 1.600.000 đồng cho giao dịch GD260900000011. Lý do: Hoàn tiền giao dịch trừ trùng.', 'V0006', 'GD260900000012', 1, DATEADD(DAY, -29, GETDATE())),
('KH0006', N'Bảo mật', N'Tài khoản tạm khóa do đăng nhập sai nhiều lần', N'Phát hiện 5 lần nhập sai mật khẩu trong 15 phút. Tài khoản đang tạm khóa.', NULL, NULL, 0, DATEADD(MINUTE, -5, GETDATE())),
('KH0007', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Hãy bật tự động gia hạn để không bị gián đoạn khi gửi xe.', NULL, NULL, 0, DATEADD(DAY, -27, GETDATE())),
('KH0009', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Ví đã sẵn sàng để gia hạn vé tháng online.', NULL, NULL, 0, DATEADD(DAY, -21, GETDATE())),
('KH0010', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Ví đã sẵn sàng để gia hạn vé tháng online.', NULL, NULL, 0, DATEADD(DAY, -6, GETDATE()));
GO

-- 9. Lượt gửi lịch sử của xe vé tháng trong 30 ngày gần nhất (đã ra bãi, xe tháng miễn phí lượt gửi)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai, MaVe) VALUES
('THE0002', '59A-123.45', DATEADD(MINUTE, -(3 * 1440 + 620), GETDATE()), DATEADD(MINUTE, -(3 * 1440 + 80), GETDATE()), 'Q1_XM_01', 0, 'BAI_Q1', 'V0001'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -(6 * 1440 + 610), GETDATE()), DATEADD(MINUTE, -(6 * 1440 + 95), GETDATE()), 'Q1_XM_04', 0, 'BAI_Q1', 'V0001'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -(9 * 1440 + 600), GETDATE()), DATEADD(MINUTE, -(9 * 1440 + 70), GETDATE()), 'Q1_XM_05', 0, 'BAI_Q1', 'V0001'),
('THE0012', '59C-678.90', DATEADD(MINUTE, -(2 * 1440 + 540), GETDATE()), DATEADD(MINUTE, -(2 * 1440 + 30), GETDATE()), 'BT_XM_02', 0, 'BAI_BT', 'V0005'),
('THE0012', '59C-678.90', DATEADD(MINUTE, -(7 * 1440 + 560), GETDATE()), DATEADD(MINUTE, -(7 * 1440 + 45), GETDATE()), 'BT_XM_02', 0, 'BAI_BT', 'V0005'),
('THE0017', '51K-246.80', DATEADD(MINUTE, -(4 * 1440 + 480), GETDATE()), DATEADD(MINUTE, -(4 * 1440 + 120), GETDATE()), 'TB_OT_03', 0, 'BAI_TB', 'V0006'),
('THE0017', '51K-246.80', DATEADD(MINUTE, -(12 * 1440 + 500), GETDATE()), DATEADD(MINUTE, -(12 * 1440 + 60), GETDATE()), 'TB_OT_03', 0, 'BAI_TB', 'V0006'),
('THE0014', '51M-135.24', DATEADD(MINUTE, -(1 * 1440 + 600), GETDATE()), DATEADD(MINUTE, -(1 * 1440 + 50), GETDATE()), 'BT_OT_02', 0, 'BAI_BT', 'V0010'),
('THE0014', '51M-135.24', DATEADD(MINUTE, -(5 * 1440 + 620), GETDATE()), DATEADD(MINUTE, -(5 * 1440 + 40), GETDATE()), 'BT_OT_02', 0, 'BAI_BT', 'V0010'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -(3 * 1440 + 400), GETDATE()), DATEADD(MINUTE, -(3 * 1440 + 100), GETDATE()), 'TB_XM_04', 0, 'BAI_TB', 'V0007'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -(10 * 1440 + 420), GETDATE()), DATEADD(MINUTE, -(10 * 1440 + 90), GETDATE()), 'TB_XM_04', 0, 'BAI_TB', 'V0007'),
('THE0010', '51H-999.11', DATEADD(MINUTE, -(2 * 1440 + 500), GETDATE()), DATEADD(MINUTE, -(2 * 1440 + 100), GETDATE()), 'Q1_OT_02', 0, 'BAI_Q1', 'V0004'),
('THE0010', '51H-999.11', DATEADD(MINUTE, -(9 * 1440 + 480), GETDATE()), DATEADD(MINUTE, -(9 * 1440 + 60), GETDATE()), 'Q3_OT_02', 0, 'BAI_Q3', 'V0004'),
('THE0026', '51L-913.57', DATEADD(MINUTE, -(6 * 1440 + 300), GETDATE()), DATEADD(MINUTE, -(6 * 1440 + 60), GETDATE()), 'Q7_OT_02', 0, 'BAI_Q7', 'V0011'),
('THE0027', '51M-468.20', DATEADD(MINUTE, -(8 * 1440 + 360), GETDATE()), DATEADD(MINUTE, -(8 * 1440 + 30), GETDATE()), 'BT_OT_03', 0, 'BAI_BT', 'V0012');
GO
