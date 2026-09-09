-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 2: NẠP DỮ LIỆU KHỞI TẠO MẪU (SAMPLE DATA CHO 11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

-- 1. Nạp danh sách Bãi Đỗ Xe (3 chi nhánh)
INSERT INTO dbo.BAI_DO_XE (MaBai, TenBai, DiaChi, SucChua, SoLuongHienTai) VALUES
('BAI_Q1', N'Bãi xe Lê Lai - Bến Thành', N'Số 26 Lê Lai, Phường Bến Thành, Quận 1, TP.HCM', 15, 0),
('BAI_Q3', N'Bãi xe Hai Bà Trưng', N'Số 180 Hai Bà Trưng, Phường Đa Kao, Quận 3, TP.HCM', 15, 0),
('BAI_BT', N'Bãi xe Landmark 81', N'Số 208 Nguyễn Hữu Cảnh, Phường 22, Bình Thạnh, TP.HCM', 20, 0);
GO

-- 2. Nạp Hồ sơ Nhân Viên (NHAN_VIEN: Ban giám đốc, Quản lý bãi, Bảo vệ ca trực)
INSERT INTO dbo.NHAN_VIEN (MaNV, HoTen, ChucVu, SDT, Email, MaBai) VALUES
('NV001', N'Nguyễn Hữu Trí', N'Giám đốc điều hành', '0901000001', 'tri.nguyen@smartparking.vn', NULL),
('NV002', N'Trần Văn Hùng', N'Quản lý bãi', '0901000002', 'hung.tran@smartparking.vn', 'BAI_Q1'),
('NV003', N'Lê Thị Bích Ngọc', N'Quản lý bãi', '0901000003', 'ngoc.le@smartparking.vn', 'BAI_Q3'),
('NV004', N'Hoàng Đình Nam', N'Quản lý bãi', '0901000004', 'nam.hoang@smartparking.vn', 'BAI_BT'),
('NV005', N'Phạm Văn Cường', N'Bảo vệ', '0901000005', 'cuong.pham@smartparking.vn', 'BAI_Q1'),
('NV006', N'Đặng Minh Tuấn', N'Bảo vệ', '0901000006', 'tuan.dang@smartparking.vn', 'BAI_Q3'),
('NV007', N'Vũ Đức Thắng', N'Bảo vệ', '0901000007', 'thang.vu@smartparking.vn', 'BAI_BT');
GO

-- 3. Nạp Tài Khoản Truy Cập & Mật khẩu mã hóa HASH SHA-256 (TAI_KHOAN)
-- Mật khẩu mặc định:
-- 'Admin@2026' cho admin -> HASH: CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin@2026'), 2)
-- '123456' cho các tài khoản còn lại -> HASH: CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2)
INSERT INTO dbo.TAI_KHOAN (TenDangNhap, MatKhauHash, MaNV, TrangThai) VALUES
('admin', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'Admin@2026'), 2), 'NV001', N'Hoạt động'),
('quanly_q1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV002', N'Hoạt động'),
('quanly_q3', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV003', N'Hoạt động'),
('quanly_bt', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV004', N'Hoạt động'),
('baove_q1', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV005', N'Hoạt động'),
('baove_q3', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV006', N'Hoạt động'),
('baove_bt', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV007', N'Hoạt động'),
('baove_khoa', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123456'), 2), 'NV005', N'Bị khóa');
GO

-- 4. Nạp Phân Loại Phương Tiện & Biểu Phí theo từng Bãi Đỗ
INSERT INTO dbo.LOAI_XE (MaLoaiXe, MaBai, TenLoai, DonGiaGio, GiaVeThang) VALUES
('XM', 'BAI_Q1', N'Xe máy', 6000, 180000),
('OT', 'BAI_Q1', N'Ô tô 4-7 chỗ', 25000, 1800000),
('XD', 'BAI_Q1', N'Xe đạp / Xe điện', 3000, 80000),

('XM', 'BAI_Q3', N'Xe máy', 5000, 150000),
('OT', 'BAI_Q3', N'Ô tô 4-7 chỗ', 20000, 1500000),
('XD', 'BAI_Q3', N'Xe đạp / Xe điện', 2000, 60000),

('XM', 'BAI_BT', N'Xe máy', 7000, 200000),
('OT', 'BAI_BT', N'Ô tô 4-7 chỗ', 30000, 2200000),
('XD', 'BAI_BT', N'Xe đạp / Xe điện', 4000, 90000);
GO

-- 5. Nạp danh mục Vị Trí Ô Đỗ Xe Vật Lý (34 vị trí trên 3 bãi)
INSERT INTO dbo.VI_TRI_DO (MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai) VALUES
-- Bãi Quận 1 (12 vị trí)
('Q1_XM_01', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_02', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_03', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_04', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_05', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_06', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_OT_01', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_02', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_03', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_04', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_XD_01', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XD_02', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),

-- Bãi Quận 3 (10 vị trí)
('Q3_XM_01', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_02', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_03', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_04', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_05', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_OT_01', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_02', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_03', N'Khu Ô tô Sân 2', N'Trống', 'OT', 'BAI_Q3'),
('Q3_XD_01', N'Khu Xe đạp 1', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XD_02', N'Khu Xe đạp 2', N'Trống', 'XD', 'BAI_Q3'),

-- Bãi Bình Thạnh (12 vị trí)
('BT_XM_01', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_02', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_03', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_04', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_05', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_06', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_OT_01', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_03', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_XD_01', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XD_02', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT');
GO

-- 6. Nạp Kho Thẻ Xe (THE_XE)
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
-- Thẻ Quận 1
('THE0001', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0002', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-01'),
('THE0003', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0004', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-10'),
('THE0005', 'BAI_Q1', N'Lượt', N'Bị khóa', '2026-01-12'),
('THE0006', 'BAI_Q1', N'Lượt', N'Mất', '2026-01-15'),

-- Thẻ Quận 3
('THE0007', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0008', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-03'),
('THE0009', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0010', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-08'),

-- Thẻ Bình Thạnh
('THE0011', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0012', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-02'),
('THE0013', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0014', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-06'),
('THE0015', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-10');
GO

-- 7. Nạp Hồ sơ Khách Hàng (KHACH_HANG)
INSERT INTO dbo.KHACH_HANG (MaKH, HoTen, SDT, Email, CMND_CCCD) VALUES
('KH0001', N'Nguyễn Văn An', '0903112233', 'nguyenvanan@gmail.com', '079090001111'),
('KH0002', N'Trần Thị Mai', '0912445566', 'tranmai.hcm@gmail.com', '079090002222'),
('KH0003', N'Lê Hoàng Long', '0988776655', 'long.lehoang@yahoo.com', '079090003333'),
('KH0004', N'Phạm Thu Trang', '0934556677', 'trangpham@outlook.com', '079090004444'),
('KH0005', N'Võ Minh Quân', '0977112244', 'quan.vominh@gmail.com', '079090005555');
GO

-- 8. Nạp Đăng Ký Vé Tháng (VE_THANG)
INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung) VALUES
('V0001', 'THE0002', 'KH0001', '59A-123.45', 'XM', '2026-01-01', '2026-12-31', N'Hoạt động', 'BAI_Q1'),
('V0002', 'THE0004', 'KH0002', '51G-888.99', 'OT', '2026-01-10', '2026-10-10', N'Hoạt động', 'BAI_Q1'),
('V0003', 'THE0008', 'KH0003', '59B-456.78', 'XM', '2026-01-03', '2026-02-03', N'Hết hạn', 'BAI_Q3'),
('V0004', 'THE0010', 'KH0004', '51H-999.11', 'OT', '2026-01-08', '2026-11-08', N'Hoạt động', 'ALL'),
('V0005', 'THE0012', 'KH0005', '59C-678.90', 'XM', '2026-01-02', '2026-12-31', N'Hoạt động', 'BAI_BT');
GO

-- 9. Nạp Lịch Sử Thu Tiền Vé Tháng (HOA_DON_VE_THANG)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai) VALUES
('HD20260101001', 'V0001', '2026-01-01 08:30:00', 12, 2160000, 'BAI_Q1'),
('HD20260110002', 'V0002', '2026-01-10 09:15:00', 9, 16200000, 'BAI_Q1'),
('HD20260103003', 'V0003', '2026-01-03 14:00:00', 1, 150000, 'BAI_Q3'),
('HD20260108004', 'V0004', '2026-01-08 10:20:00', 10, 15000000, 'BAI_Q3'),
('HD20260102005', 'V0005', '2026-01-02 16:45:00', 12, 2400000, 'BAI_BT');
GO

-- 10. Nạp Nhật Ký Lượt Gửi Xe (LUOT_GUI)
-- Một số lượt đã check-out
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59A-111.22', '2026-09-07 07:15:00', '2026-09-07 11:15:00', 'Q1_XM_01', 24000, 'BAI_Q1'),
('THE0003', '51G-222.33', '2026-09-07 08:00:00', '2026-09-07 14:00:00', 'Q1_OT_01', 150000, 'BAI_Q1'),
('THE0007', '59B-333.44', '2026-09-07 09:30:00', '2026-09-07 12:30:00', 'Q3_XM_01', 15000, 'BAI_Q3'),
('THE0011', '59C-444.55', '2026-09-07 06:45:00', '2026-09-07 17:45:00', 'BT_XM_01', 77000, 'BAI_BT');

-- Một số lượt hiện đang đỗ (ThoiGianRa IS NULL)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59K-987.65', DATEADD(HOUR, -2, GETDATE()), NULL, 'Q1_XM_02', 0, 'BAI_Q1'),
('THE0002', '59A-123.45', DATEADD(HOUR, -4, GETDATE()), NULL, 'Q1_XM_03', 0, 'BAI_Q1'),
('THE0007', '59E-555.66', DATEADD(HOUR, -1, GETDATE()), NULL, 'Q3_XM_02', 0, 'BAI_Q3'),
('THE0013', '51A-777.88', DATEADD(HOUR, -3, GETDATE()), NULL, 'BT_OT_01', 0, 'BAI_BT');

-- Cập nhật đồng bộ ô đỗ tương ứng sang 'Đã đỗ' và bãi đỗ tăng xe
UPDATE dbo.VI_TRI_DO SET TrangThai = N'Đã đỗ' WHERE MaViTri IN ('Q1_XM_02', 'Q1_XM_03', 'Q3_XM_02', 'BT_OT_01');
UPDATE dbo.BAI_DO_XE SET SoLuongHienTai = 2 WHERE MaBai = 'BAI_Q1';
UPDATE dbo.BAI_DO_XE SET SoLuongHienTai = 1 WHERE MaBai = 'BAI_Q3';
UPDATE dbo.BAI_DO_XE SET SoLuongHienTai = 1 WHERE MaBai = 'BAI_BT';
GO

-- 11. Nạp Nhật Ký Sự Cố (LICHSU_SU_CO)
INSERT INTO dbo.LICHSU_SU_CO (MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai) VALUES
('THE0006', '59X-999.01', '2026-01-15 11:00:00', N'Khách hàng làm rơi thẻ xe tại quầy nước, lập biên bản báo mất thẻ chip', 50000, N'Đã giải quyết', 'BAI_Q1'),
(NULL, '51B-123.45', '2026-02-10 18:30:00', N'Va quẹt nhẹ gương chiếu hậu khi lùi xe vào ô đỗ Q3_OT_01', 200000, N'Đã giải quyết', 'BAI_Q3');
GO
