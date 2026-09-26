-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- CÁC CÂU LỆNH SQL DEMO TRỰC TIẾP TRÊN SSMS HOẶC ROUTE /sql CỦA WEBSITE
-- ====================================================================================

-- 1. Xem công suất và tỷ lệ lấp đầy các bãi đỗ xe
SELECT * FROM dbo.vw_Report_CongSuatBaiDo;

-- 2. Xem sơ đồ trạng thái các ô đỗ xe của bãi Quận 1
SELECT MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai
FROM dbo.VI_TRI_DO
WHERE MaBai = 'BAI_Q1'
ORDER BY MaViTri;

-- 3. Demo Function tìm ô đỗ xe máy trống tại bãi Quận 1
SELECT dbo.f_TimSlotTrong('BAI_Q1', 'XM') AS SlotTrongKhaDung_Q1;

-- 4. Demo Function tính tiền gửi ô tô đỗ 5 tiếng tại Landmark 81
SELECT dbo.f_TinhTienGuiXe('2026-09-08 08:00:00', '2026-09-08 13:00:00', 'OT', 'BAI_BT') AS TienGuiOTo_5Gio;

-- 5. Demo Function xem danh sách xe đang trong bãi Quận 1
SELECT * FROM dbo.f_DanhSachXeTrongBai('BAI_Q1');

-- 6. Demo Procedure Check-In xe máy vào bãi Quận 1
DECLARE @MaViTri VARCHAR(20);
DECLARE @MaLuot INT;
EXEC dbo.sp_XeVaoBai 
    @MaThe = 'THE0003', 
    @BienSo = '59T1-888.88', 
    @MaBai = 'BAI_Q1', 
    @MaViTri = @MaViTri OUTPUT, 
    @MaLuot = @MaLuot OUTPUT;

-- Kiểm tra ô đỗ đã được cấp và bãi xe tăng số lượng
SELECT MaViTri, TrangThai FROM dbo.VI_TRI_DO WHERE MaViTri = @MaViTri;
SELECT TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';

-- 7. Demo Procedure Check-Out xe và tính tiền
DECLARE @TienThu DECIMAL(18,2);
EXEC dbo.sp_XeRaBai 
    @MaThe = 'THE0003', 
    @BienSoRa = '59T1-888.88', 
    @TienThu = @TienThu OUTPUT;

-- 8. Demo Cursor quét cảnh báo hạn vé tháng và tự động khóa thẻ
EXEC dbo.sp_DemoCanhBaoHanTheThang;

-- 9. Demo Cursor tổng kết so sánh doanh thu các bãi trong chuỗi
EXEC dbo.sp_DemoTongKetDoanhThuChuoi;

-- 10. Demo bẫy lỗi Trigger: Cố tình Check-In bằng thẻ đã mất hoặc thẻ bị khóa
-- Lệnh dưới đây sẽ bị Trigger trg_KiemTraCheckIn chặn lại và ném lỗi 50002
-- INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, MaViTri, TienGui, MaBai)
-- VALUES ('THE0006', '59X-999.99', GETDATE(), 'Q1_XM_01', 0, 'BAI_Q1');

-- ====================================================================================
-- 11. DEMO 4 VIEWS BỐT KIỂM SOÁT CỔNG VÀO / RA
-- ====================================================================================

-- 11.1. Bốt cổng quét thẻ: xem quyết định mở barrier cho từng mã thẻ
-- (Thẻ THE0005 bị khóa, THE0006 báo mất, THE0008 vé tháng hết hạn đều bị ChoPhepQuet = 0)
SELECT MaThe, LoaiThe, TrangThaiThe, TenBaiKiemSoat, SoChoTrong, MaVe, SoNgayConLaiVe,
       DangTrongBai, ChieuQuetKeTiep, ChoPhepQuet, LyDoTuChoi, GhiChuCanhBao
FROM dbo.v_BotCong_TraCuuThe
ORDER BY ChoPhepQuet, MaThe;

-- 11.2. Bốt cổng quét 1 thẻ cụ thể (thao tác thực tế của nhân viên bảo vệ)
SELECT * FROM dbo.v_BotCong_TraCuuThe WHERE MaThe = 'THE0001';

-- 11.3. Màn hình cổng ra: danh sách xe chờ ra kèm tiền tạm tính theo block giờ
SELECT MaLuot, TenBai, MaThe, LoaiThe, BienSoLucVao, MaViTri, LoaiPhuongTien, DonGiaGio,
       SoPhutDaDo, SoBlockGioTinhPhi, TienTamTinh, ChinhSachThanhToan, CanhBaoLechBienSo, GhiChuCanhBao
FROM dbo.v_BotCong_XeChoRa
ORDER BY ThoiGianVao;

-- 11.4. Bảng điện tử nhật ký 200 sự kiện xe qua barrier mới nhất
SELECT MaLuot, TenBai, ChieuDiChuyen, ThoiGianSuKien, MaThe, LoaiThe, BienSo, MaViTri,
       SoPhutLuuBai, SoTienThu, TrangThaiLuot
FROM dbo.v_BotCong_NhatKyVaoRa;

-- 11.5. Bảng đèn tín hiệu CÒN CHỖ / HẾT CHỖ tại cổng vào từng bãi
SELECT MaBai, TenBai, LoaiPhuongTien, DonGiaGio, TongODoTheoLoai, SoODoTrong,
       TyLeLapDayTheoLoai, MaViTriGoiY, ChoPhepVaoCong, DenTinHieuCong
FROM dbo.v_BotCong_BangDenCong
ORDER BY MaBai, MaLoaiXe;

-- ====================================================================================
-- 12. DEMO 3 VIEWS SƠ ĐỒ BÃI XE THỜI GIAN THỰC
-- ====================================================================================

-- 12.1. Lưới ô đỗ chi tiết của bãi Lê Lai (đúng 1 dòng cho 1 ô đỗ)
SELECT ThuTuHienThi, MaViTri, KhuVuc, LoaiPhuongTien, TrangThaiHienThi, BienSo, LoaiThe,
       SoPhutDaDo, TienTamTinh, HoTenKhachHang, NgayHetHan, CanhBaoLechDuLieu
FROM dbo.v_SodoBai_ODoChiTiet
WHERE MaBai = 'BAI_Q1'
ORDER BY ThuTuHienThi;

-- 12.2. Thanh tổng hợp số ô trống theo từng khu vực / tầng
SELECT MaBai, KhuVuc, TongODo, SoODoDaDo, SoODoTrong, TyLeLapDayPercent,
       SoODoXeMayTrong, SoODoOToTrong, SoODoXeDapTrong
FROM dbo.v_SodoBai_TongHopKhuVuc
ORDER BY MaBai, KhuVuc;

-- 12.3. Thẻ tổng quan công suất từng bãi kèm cờ đối soát bộ đếm
SELECT MaBai, TenBai, SucChua, SoLuongHienTai, SoXeThucTeTrongBai, CanhBaoLechBoDem,
       SoChoTrong, TyLeLapDayPercent, SoXeTheThang, SoXeTheLuot,
       SoLuotVaoHomNay, SoLuotRaHomNay, DoanhThuLuotHomNay, MucDoCanhBao
FROM dbo.v_SodoBai_TongQuanBai
ORDER BY MaBai;

-- 12.4. Dò tìm ô đỗ có dữ liệu lệch giữa VI_TRI_DO và LUOT_GUI (đối soát vận hành)
SELECT MaBai, MaViTri, KhuVuc, TrangThaiODo, TrangThaiHienThi, MaLuot, BienSo
FROM dbo.v_SodoBai_ODoChiTiet
WHERE CanhBaoLechDuLieu = 1
ORDER BY MaBai, MaViTri;
