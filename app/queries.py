# ====================================================================================
# DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
# DANH MỤC BẢNG, VIEW BÁO CÁO VÀ KỊCH BẢN DEMO 5 BƯỚC CHUẨN HÓA
# ====================================================================================

TABLES_TO_SHOW = [
    "BAI_DO_XE",
    "NHAN_VIEN",
    "TAI_KHOAN",
    "LOAI_XE",
    "VI_TRI_DO",
    "THE_XE",
    "KHACH_HANG",
    "VE_THANG",
    "LUOT_GUI",
    "HOA_DON_VE_THANG",
    "LICHSU_SU_CO",
]

REPORT_VIEWS = [
    "vw_Report_CongSuatBaiDo",
    "vw_Report_DoanhThuTheoBai",
    "vw_Report_XeDangDoHienTai",
    "vw_Report_VeThangSapHetHan",
    "vw_Report_NhatKySuCo",
]

DEMO_CASES = {
    # --------------------------------------------------------------------------------
    # CASE 1: sp_XeVaoBai
    # --------------------------------------------------------------------------------
    "sp-xe-vao-bai": {
        "title": "Demo Stored Procedure: Check-In xe vào cổng bãi (sp_XeVaoBai)",
        "problem": "Xe máy quét thẻ THE0001 vào bãi xe Lê Lai (BAI_Q1). Thủ tục tự động gọi Function f_TimSlotTrong tìm ô trống khả dụng, ghi nhận lượt gửi mới và kích hoạt Trigger chuyển trạng thái ô đỗ sang 'Đã đỗ' đồng thời tăng số lượng xe trong bãi.",
        "before_sql": """
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 10 MaViTri, KhuVuc, TrangThai, MaLoaiXe FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' ORDER BY TrangThai DESC, MaViTri ASC;
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, MaViTri FROM dbo.LUOT_GUI WHERE MaBai = 'BAI_Q1' ORDER BY MaLuot DESC;
""",
        "before_labels": [
            {"name": "Công suất bãi Quận 1 trước khi check-in", "description": "Số lượng xe hiện tại và sức chứa tối đa của bãi Lê Lai."},
            {"name": "Sơ đồ ô đỗ bãi Quận 1 trước khi check-in", "description": "Trạng thái các ô đỗ 'Trống' và 'Đã đỗ'."},
            {"name": "Lượt gửi gần nhất trước khi check-in", "description": "Nhật ký các lượt xe vào gần nhất."},
        ],
        "execute_sql": """
DECLARE @MaViTri VARCHAR(20);
DECLARE @MaLuot INT;
EXEC dbo.sp_XeVaoBai 
    @MaThe = 'THE0001', 
    @BienSo = '59A-123.45', 
    @MaBai = 'BAI_Q1',
    @MaLoaiXe = 'XM', 
    @MaViTri = @MaViTri OUTPUT, 
    @MaLuot = @MaLuot OUTPUT;
""",
        "execute_labels": [
            {"name": "Kết quả thực thi Stored Procedure", "description": "Mã lượt gửi và vị trí ô đỗ được tự động cấp phát cho xe."}
        ],
        "after_sql": """
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 10 MaViTri, KhuVuc, TrangThai, MaLoaiXe FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' ORDER BY TrangThai DESC, MaViTri ASC;
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, MaViTri FROM dbo.LUOT_GUI WHERE MaBai = 'BAI_Q1' ORDER BY MaLuot DESC;
""",
        "after_labels": [
            {"name": "Công suất bãi Quận 1 sau khi check-in", "description": "Số lượng xe tăng thêm 1 do Trigger trg_DongBoTrangThaiSlot tự động cập nhật."},
            {"name": "Sơ đồ ô đỗ bãi Quận 1 sau khi check-in", "description": "Ô đỗ vừa được cấp đã tự động chuyển sang trạng thái 'Đã đỗ'."},
            {"name": "Lượt gửi mới được tạo thành công", "description": "Dòng bản ghi mới xuất hiện trong bảng LUOT_GUI."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 2: sp_XeRaBai
    # --------------------------------------------------------------------------------
    "sp-xe-ra-bai": {
        "title": "Demo Stored Procedure: Check-Out xe ra cổng & Tính phí (sp_XeRaBai)",
        "problem": "Xe đang đỗ quét thẻ ra cổng. Thủ tục đối chiếu thời gian vào, gọi Function f_TinhTienGuiXe tính tiền theo block giờ, cập nhật ThoiGianRa, kích hoạt Trigger giải phóng ô đỗ về 'Trống' và giảm số xe trong bãi.",
        "before_sql": """
SELECT TOP 5 lg.MaLuot, lg.MaThe, lg.BienSo, lg.ThoiGianVao, lg.MaViTri, lg.MaBai 
FROM dbo.LUOT_GUI lg 
WHERE lg.ThoiGianRa IS NULL 
ORDER BY lg.MaLuot DESC;
SELECT MaViTri, TrangThai, MaBai FROM dbo.VI_TRI_DO WHERE TrangThai = N'Đã đỗ';
SELECT MaBai, TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE;
""",
        "before_labels": [
            {"name": "Danh sách xe đang đỗ trong các bãi", "description": "Các lượt gửi chưa có ThoiGianRa."},
            {"name": "Các ô đỗ đang có xe chiếm chỗ", "description": "Trạng thái 'Đã đỗ' của các slot."},
            {"name": "Số lượng xe hiện tại các bãi", "description": "Số xe đang đỗ trước khi check-out."},
        ],
        "execute_sql": """
DECLARE @MaTheRa VARCHAR(10) = (SELECT TOP 1 MaThe FROM dbo.LUOT_GUI WHERE ThoiGianRa IS NULL ORDER BY MaLuot DESC);
DECLARE @TienThu DECIMAL(18,2);
DECLARE @MaLuot INT;
EXEC dbo.sp_XeRaBai 
    @MaThe = @MaTheRa, 
    @TienThu = @TienThu OUTPUT,
    @MaLuot = @MaLuot OUTPUT;
""",
        "execute_labels": [
            {"name": "Hóa đơn thanh toán khi Check-Out", "description": "Số tiền gửi xe thực thu tính toán tự động dựa trên thời gian đỗ và loại xe."}
        ],
        "after_sql": """
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, ThoiGianRa, TienGui, MaViTri, MaBai 
FROM dbo.LUOT_GUI 
ORDER BY ThoiGianRa DESC, MaLuot DESC;
SELECT MaViTri, TrangThai, MaBai FROM dbo.VI_TRI_DO WHERE TrangThai = N'Đã đỗ';
SELECT MaBai, TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE;
""",
        "after_labels": [
            {"name": "Lượt gửi vừa check-out", "description": "Đã cập nhật ThoiGianRa và TienGui."},
            {"name": "Ô đỗ đã được giải phóng", "description": "Trigger trg_DongBoTrangThaiSlot tự động chuyển ô đỗ về 'Trống'."},
            {"name": "Số lượng xe bãi đỗ sau khi check-out", "description": "Số xe giảm đi 1 tương ứng."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 3: sp_DangKyThanhVien
    # --------------------------------------------------------------------------------
    "sp-dang-ky-thanh-vien": {
        "title": "Demo Stored Procedure + Transaction: Đăng ký vé tháng mới (sp_DangKyThanhVien)",
        "problem": "Quy trình đăng ký vé tháng cho khách hàng mới: Tạo hồ sơ khách hàng -> Chuyển đổi thẻ chip sang Thẻ Tháng -> Sinh vé tháng mới -> Xuất hóa đơn tài chính. Toàn bộ chuỗi thao tác được bảo vệ trong TRANSACTION an toàn tuyệt đối.",
        "before_sql": """
SELECT TOP 5 MaKH, HoTen, SDT, CMND_CCCD FROM dbo.KHACH_HANG ORDER BY MaKH DESC;
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0003';
SELECT TOP 5 MaVe, MaThe, BienSo, NgayDangKy, NgayHetHan, TrangThai FROM dbo.VE_THANG ORDER BY MaVe DESC;
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG ORDER BY NgayThanhToan DESC;
""",
        "before_labels": [
            {"name": "Danh sách khách hàng trước đăng ký", "description": "Hồ sơ khách hàng hiện có."},
            {"name": "Thẻ xe dự kiến đăng ký", "description": "Hiện là thẻ lượt THE0003."},
            {"name": "Danh sách vé tháng gần nhất", "description": "Các vé tháng đã phát hành."},
            {"name": "Hóa đơn thu tiền vé tháng", "description": "Lịch sử thu tiền trước thao tác."},
        ],
        "execute_sql": """
DECLARE @MaKH VARCHAR(10) = CONCAT('KH', FORMAT(GETDATE(), 'ssfff'));
EXEC dbo.sp_DangKyThanhVien 
    @MaKH = @MaKH, 
    @HoTen = N'Trần Đình Trọng', 
    @SDT = '0908889999', 
    @CMND = '079090008888', 
    @MaThe = 'THE0003', 
    @BienSo = '59X1-678.99', 
    @MaLoaiXe = 'XM', 
    @MaBaiApDung = 'BAI_Q1', 
    @SoThangDongTruoc = 3;
""",
        "execute_labels": [
            {"name": "Kết quả đăng ký thành viên và xuất hóa đơn", "description": "Thông tin hợp đồng vé tháng và số tiền đã thanh toán trong Transaction."}
        ],
        "after_sql": """
SELECT TOP 5 MaKH, HoTen, SDT, CMND_CCCD FROM dbo.KHACH_HANG ORDER BY MaKH DESC;
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0003';
SELECT TOP 5 MaVe, MaThe, BienSo, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung FROM dbo.VE_THANG ORDER BY MaVe DESC;
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG ORDER BY NgayThanhToan DESC;
""",
        "after_labels": [
            {"name": "Khách hàng mới được tạo", "description": "Hồ sơ khách hàng Trần Đình Trọng."},
            {"name": "Thẻ xe được chuyển sang Thẻ Tháng", "description": "Thẻ THE0003 đã đổi LoaiThe thành 'Tháng'."},
            {"name": "Vé tháng mới có hiệu lực 3 tháng", "description": "Hạn sử dụng được cộng thêm 90 ngày."},
            {"name": "Hóa đơn đóng tiền được lưu tự động", "description": "Ghi nhận doanh thu vé tháng trong HOA_DON_VE_THANG."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 4: sp_GiaHanTheThang
    # --------------------------------------------------------------------------------
    "sp-gia-han-ve-thang": {
        "title": "Demo Stored Procedure: Gia hạn hạn dùng vé tháng (sp_GiaHanTheThang)",
        "problem": "Khách hàng sở hữu vé tháng V0001 đến nộp tiền gia hạn thêm 2 tháng. Thủ tục tự động tính ngày hết hạn mới và xuất hóa đơn thu phí gia hạn.",
        "before_sql": """
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0001';
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0001' ORDER BY NgayThanhToan DESC;
""",
        "before_labels": [
            {"name": "Thông tin vé tháng V0001 trước khi gia hạn", "description": "Ngày hết hạn hiện tại của vé."},
            {"name": "Lịch sử hóa đơn cũ của vé V0001", "description": "Các lần nộp tiền trước đó."},
        ],
        "execute_sql": """
EXEC dbo.sp_GiaHanTheThang 
    @MaVe = 'V0001', 
    @SoThangGiaHan = 2, 
    @MaBaiGiaHan = 'BAI_Q1';
""",
        "execute_labels": [
            {"name": "Kết quả gia hạn thành công", "description": "Thời hạn mới và số tiền gia hạn thu được."}
        ],
        "after_sql": """
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0001';
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0001' ORDER BY NgayThanhToan DESC;
""",
        "after_labels": [
            {"name": "Hạn sử dụng vé tháng sau gia hạn", "description": "NgayHetHan đã được cộng thêm 2 tháng."},
            {"name": "Hóa đơn gia hạn mới được lập", "description": "Hóa đơn mới được thêm vào HOA_DON_VE_THANG."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 5: sp_BaoMatThe
    # --------------------------------------------------------------------------------
    "sp-bao-mat-the": {
        "title": "Demo Procedure + Trigger: Báo mất thẻ & Phạt đền bù (sp_BaoMatThe)",
        "problem": "Khách hàng báo mất thẻ THE0001 tại bãi Quận 1. Thủ tục cập nhật thẻ sang trạng thái 'Mất', Trigger trg_LogLichSuSuCo tự động can thiệp ghi nhận biên bản sự cố và áp tiền phạt 50,000 VND.",
        "before_sql": """
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0001';
SELECT TOP 5 MaSuCo, MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy FROM dbo.LICHSU_SU_CO ORDER BY MaSuCo DESC;
""",
        "before_labels": [
            {"name": "Trạng thái thẻ THE0001 trước khi báo mất", "description": "Đang ở trạng thái 'Hoạt động'."},
            {"name": "Nhật ký sự cố trước thao tác", "description": "Các biên bản sự cố hiện có."},
        ],
        "execute_sql": """
EXEC dbo.sp_BaoMatThe @MaTheBaoMat = 'THE0001';
""",
        "execute_labels": [
            {"name": "Kết quả xử lý báo mất thẻ", "description": "Thông báo thẻ đã bị khóa và áp mức phạt đền bù."}
        ],
        "after_sql": """
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0001';
SELECT TOP 5 MaSuCo, MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy FROM dbo.LICHSU_SU_CO ORDER BY MaSuCo DESC;
""",
        "after_labels": [
            {"name": "Trạng thái thẻ sau khi báo mất", "description": "Đã đổi thành 'Mất' để chặn quét qua cổng barrier."},
            {"name": "Biên bản sự cố tự động được Trigger tạo", "description": "Bản ghi mới kèm số tiền phạt 50.000 ₫ trong LICHSU_SU_CO."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 6: Trigger trg_KiemTraCheckIn
    # --------------------------------------------------------------------------------
    "trigger-chan-checkin-loi": {
        "title": "Demo Trigger: Chặn Check-In khi thẻ lỗi hoặc bãi xe đầy (trg_KiemTraCheckIn)",
        "problem": "Cố tình dùng thẻ THE0006 (thẻ đang có trạng thái 'Mất' hoặc 'Bị khóa') để check-in xe vào bãi. Trigger trg_KiemTraCheckIn sẽ phát hiện, ROLLBACK giao dịch và ném lỗi 50002. Lỗi này là KẾT QUẢ MONG ĐỢI của kịch bản demo.",
        "before_sql": """
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0006';
SELECT COUNT(*) AS TongSoLuotGuiHienTai FROM dbo.LUOT_GUI;
""",
        "before_labels": [
            {"name": "Kiểm tra tình trạng thẻ THE0006", "description": "Thẻ đang ở trạng thái 'Mất'."},
            {"name": "Tổng số lượt gửi trước khi chèn lỗi", "description": "Số lượng bản ghi trong LUOT_GUI."},
        ],
        "execute_sql": """
-- Cố tình vi phạm nghiệp vụ để kiểm chứng Trigger
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, MaViTri, TienGui, MaBai)
VALUES ('THE0006', '59X-888.88', GETDATE(), 'Q1_XM_01', 0, 'BAI_Q1');
""",
        "execute_labels": [
            {"name": "Kết quả", "description": "Lệnh INSERT bị Trigger chặn lại."}
        ],
        "after_sql": """
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0006';
SELECT COUNT(*) AS TongSoLuotGuiSauKhiChan FROM dbo.LUOT_GUI;
""",
        "after_labels": [
            {"name": "Trạng thái thẻ vẫn được bảo vệ", "description": "Thẻ vẫn là 'Mất'."},
            {"name": "Tổng số lượt gửi không thay đổi", "description": "Chứng minh giao dịch đã bị ROLLBACK hoàn toàn."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 7: Trigger trg_ChanSuDungVeHetHan
    # --------------------------------------------------------------------------------
    "trigger-chan-ve-het-han": {
        "title": "Demo Trigger: Chặn xe tháng quá hạn đóng tiền (trg_ChanSuDungVeHetHan)",
        "problem": "Thẻ tháng THE0008 gắn với vé V0003 đã quá hạn thanh toán cố tình quét vào bãi. Trigger trg_ChanSuDungVeHetHan tự động can thiệp, hủy giao dịch và ném lỗi 50003.",
        "before_sql": """
SELECT vt.MaVe, vt.MaThe, vt.NgayHetHan, vt.TrangThai, tx.LoaiThe 
FROM dbo.VE_THANG vt 
INNER JOIN dbo.THE_XE tx ON vt.MaThe = tx.MaThe 
WHERE vt.MaVe = 'V0003';
""",
        "before_labels": [
            {"name": "Kiểm tra vé tháng V0003", "description": "Vé đã hết hạn sử dụng."}
        ],
        "execute_sql": """
-- Cố tình check-in vé tháng đã hết hạn
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, MaViTri, TienGui, MaBai)
VALUES ('THE0008', '59B-456.78', GETDATE(), 'Q3_XM_01', 0, 'BAI_Q3');
""",
        "execute_labels": [
            {"name": "Kết quả", "description": "Lệnh INSERT bị Trigger chặn lại do vé quá hạn."}
        ],
        "after_sql": """
SELECT vt.MaVe, vt.MaThe, vt.NgayHetHan, vt.TrangThai 
FROM dbo.VE_THANG vt 
WHERE vt.MaVe = 'V0003';
SELECT TOP 5 * FROM dbo.LUOT_GUI WHERE MaThe = 'THE0008' ORDER BY MaLuot DESC;
""",
        "after_labels": [
            {"name": "Vé tháng vẫn ở trạng thái hết hạn", "description": "Thông tin vé tháng V0003."},
            {"name": "Không có lượt gửi nào được tạo", "description": "Giao dịch không thành công."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 8: Functions
    # --------------------------------------------------------------------------------
    "function-tinh-tien-slot": {
        "title": "Demo Database Functions: Tính phí gửi xe & Tìm ô đỗ tự động",
        "problem": "Demo các hàm nghiệp vụ: f_TinhTienGuiXe (tính phí đỗ theo số giờ lũy tiến), f_TimSlotTrong (tìm vị trí trống đầu tiên phù hợp loại xe) và f_DanhSachXeTrongBai (trích xuất danh sách xe đang trong bãi).",
        "before_sql": """
SELECT MaLoaiXe, MaBai, TenLoai, DonGiaGio FROM dbo.LOAI_XE;
SELECT MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' AND TrangThai = N'Trống';
""",
        "before_labels": [
            {"name": "Biểu phí đơn giá giờ của từng bãi", "description": "Bảng giá áp dụng cho hàm tính tiền."},
            {"name": "Danh sách ô đỗ trống hiện có tại bãi Lê Lai", "description": "Dữ liệu phục vụ hàm tìm slot."},
        ],
        "execute_sql": """
-- 1. Demo tính tiền gửi ô tô đỗ 5 tiếng tại bãi Landmark 81
SELECT 
    'OT' AS LoaiXe, 
    'BAI_BT' AS MaBai, 
    5 AS SoGioDo, 
    dbo.f_TinhTienGuiXe('2026-09-08 08:00:00', '2026-09-08 13:00:00', 'OT', 'BAI_BT') AS TienGuiCalculated;

-- 2. Demo tìm ô đỗ xe máy trống tại bãi Lê Lai (Q1)
SELECT dbo.f_TimSlotTrong('BAI_Q1', 'XM') AS SlotXeMayKhaDung_Q1;

-- 3. Demo tìm ô đỗ ô tô trống tại bãi Hai Bà Trưng (Q3)
SELECT dbo.f_TimSlotTrong('BAI_Q3', 'OT') AS SlotOToKhaDung_Q3;

-- 4. Demo lấy danh sách xe đang có mặt tại bãi Lê Lai
SELECT * FROM dbo.f_DanhSachXeTrongBai('BAI_Q1');
""",
        "execute_labels": [
            {"name": "Hàm tính tiền gửi ô tô 5 giờ tại Landmark 81", "description": "5 giờ * 30.000 ₫/giờ = 150.000 ₫."},
            {"name": "Hàm tìm ô đỗ xe máy trống bãi Q1", "description": "Trả về mã slot trống đầu tiên."},
            {"name": "Hàm tìm ô đỗ ô tô trống bãi Q3", "description": "Trả về mã slot ô tô trống."},
            {"name": "Hàm bảng: Danh sách xe đang đỗ tại bãi Q1", "description": "Danh sách xe hiện diện tức thời."},
        ],
        "after_sql": """
SELECT * FROM dbo.vw_Report_CongSuatBaiDo;
""",
        "after_labels": [
            {"name": "Báo cáo công suất toàn bộ hệ thống bãi xe", "description": "Số lượng xe và chỗ trống đối chiếu."}
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 9: Cursors
    # --------------------------------------------------------------------------------
    "cursor-canh-bao-doanh-thu": {
        "title": "Demo Database Cursors: Quét cảnh báo vé tháng & Thống kê tài chính toàn chuỗi",
        "problem": "Demo 2 Cursor duyệt dữ liệu chuyên sâu: sp_DemoCanhBaoHanTheThang (duyệt kiểm tra toàn bộ vé tháng, khóa thẻ quá hạn và nhắc nộp phí) và sp_DemoTongKetDoanhThuChuoi (duyệt cộng gộp doanh thu lượt và vé tháng của từng chi nhánh).",
        "before_sql": """
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG;
SELECT MaBai, TenBai FROM dbo.BAI_DO_XE;
""",
        "before_labels": [
            {"name": "Danh sách vé tháng trước khi chạy Cursor quét hạn", "description": "Trạng thái các vé tháng hiện tại."},
            {"name": "Danh mục các chi nhánh bãi xe", "description": "Các bãi đỗ thuộc chuỗi hệ thống."},
        ],
        "execute_sql": """
-- 1. Chạy Cursor quét hạn vé tháng và tự động xử lý
EXEC dbo.sp_DemoCanhBaoHanTheThang;

-- 2. Chạy Cursor tổng hợp doanh thu chuỗi
EXEC dbo.sp_DemoTongKetDoanhThuChuoi;
""",
        "execute_labels": [
            {"name": "Kết quả Cursor 1: Báo cáo quét hạn vé tháng", "description": "Phân loại: Đã quá hạn (tự khóa), Sắp hết hạn (nhắc nộp phí), Còn hạn an toàn."},
            {"name": "Kết quả Cursor 2: Bảng tổng kết tài chính chuỗi bãi đỗ", "description": "Cộng gộp doanh thu lượt + doanh thu tháng và đánh giá hiệu quả từng bãi."}
        ],
        "after_sql": """
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG;
SELECT * FROM dbo.vw_Report_DoanhThuTheoBai;
""",
        "after_labels": [
            {"name": "Trạng thái vé tháng sau khi Cursor xử lý", "description": "Các vé quá hạn đã được cập nhật thành 'Hết hạn'."},
            {"name": "Đối chiếu bảng doanh thu từ View báo cáo", "description": "Số liệu khớp hoàn toàn với kết quả Cursor."},
        ],
    },
}

# ====================================================================================
# PHÂN NHÓM 9 KỊCH BẢN DEMO CSDL (PROCEDURE | TRIGGER | FUNCTION | CURSOR)
# ====================================================================================
DEMO_GROUPS = [
    {
        "id": "procedure",
        "category": "Procedure",
        "title": "Nhóm Stored Procedures (Thủ Tục Lưu Trữ)",
        "badge_class": "badge-success",
        "color": "#10b981",
        "icon": "⚙️",
        "desc": "Xử lý các quy trình nghiệp vụ gồm nhiều bước: Check-In, Check-Out tính phí, Đăng ký vé tháng trong Transaction, Gia hạn vé và Báo mất thẻ phạt đền bù.",
        "case_keys": [
            "sp-xe-vao-bai",
            "sp-xe-ra-bai",
            "sp-dang-ky-thanh-vien",
            "sp-gia-han-ve-thang",
            "sp-bao-mat-the",
        ],
    },
    {
        "id": "trigger",
        "category": "Trigger",
        "title": "Nhóm Database Triggers (Bẫy Lỗi Tự Động)",
        "badge_class": "badge-danger",
        "color": "#ef4444",
        "icon": "⚡",
        "desc": "Tự động kích hoạt khi có sự kiện ghi dữ liệu để bảo vệ toàn vẹn: Chặn check-in thẻ lỗi/báo mất hoặc bãi đầy, Chặn xe tháng hết hạn nộp tiền.",
        "case_keys": [
            "trigger-chan-checkin-loi",
            "trigger-chan-ve-het-han",
        ],
    },
    {
        "id": "function",
        "category": "Function",
        "title": "Nhóm Database Functions (Hàm Nghiệp Vụ)",
        "badge_class": "badge-warning",
        "color": "#f59e0b",
        "icon": "📐",
        "desc": "Hàm tính toán và trích xuất dữ liệu: Tính phí gửi theo block giờ lũy tiến, Tìm ô đỗ trống đầu tiên phù hợp loại xe, Bảng danh sách xe đang trong bãi.",
        "case_keys": [
            "function-tinh-tien-slot",
        ],
    },
    {
        "id": "cursor",
        "category": "Cursor",
        "title": "Nhóm Database Cursors (Con Trỏ Duyệt Dữ Liệu)",
        "badge_class": "badge-info",
        "color": "#06b6d4",
        "icon": "🔄",
        "desc": "Duyệt tuần tự từng dòng bản ghi chuyên sâu: Quét kiểm tra hạn vé tháng tự động khóa thẻ quá hạn và Tổng kết báo cáo doanh thu toàn chuỗi.",
        "case_keys": [
            "cursor-canh-bao-doanh-thu",
        ],
    },
]

