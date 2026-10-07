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
    # Cổng khách hàng (sql/01_schema.sql, phần cổng khách hàng)
    "PHUONG_THUC_THANH_TOAN",
    "TAI_KHOAN_KH",
    "NHAT_KY_DANG_NHAP",
    "VI_DIEN_TU",
    "GIAO_DICH",
    "THONG_BAO",
    "QUYEN_KH",
    "VAI_TRO_KH",
    "VAI_TRO_QUYEN",
    "UY_QUYEN_VE",
]

REPORT_VIEWS = [
    "vw_Report_CongSuatBaiDo",
    "vw_Report_DoanhThuTheoBai",
    "vw_Report_XeDangDoHienTai",
    "vw_Report_VeThangSapHetHan",
    "vw_Report_NhatKySuCo",
    # PHẦN E - 6 views tổng hợp cho quản lý chuỗi (issue #12)
    "vw_Report_DoanhThuTheoNgay",
    "vw_Report_DoanhThuTheoThang",
    "vw_Report_LuuLuongTheoGio",
    "vw_Report_ThongKeTheoLoaiXe",
    "vw_Report_XepHangBai",
    "vw_Report_TongQuanChuoi",
    # PHẦN G - 5 views thanh toán và bảo mật tài khoản khách hàng (sql/07_views.sql)
    "vw_Report_DoanhThuTheoPhuongThuc",
    "vw_Report_TongQuanViDienTu",
    "vw_Report_GiaoDichCanXuLy",
    "vw_Report_BaoMatTaiKhoanKH",
    "vw_Report_TyLeChuyenDoiOnline",
]

# ====================================================================================
# DANH MỤC VIEWS VẬN HÀNH THỜI GIAN THỰC (sql/07_views.sql - PHẦN C & PHẦN D)
# 4 views phục vụ bốt kiểm soát cổng vào/ra + 3 views phục vụ sơ đồ bãi xe realtime
# ====================================================================================

GATE_VIEWS = [
    "v_BotCong_TraCuuThe",
    "v_BotCong_XeChoRa",
    "v_BotCong_NhatKyVaoRa",
    "v_BotCong_BangDenCong",
]

MAP_VIEWS = [
    "v_SodoBai_ODoChiTiet",
    "v_SodoBai_TongHopKhuVuc",
    "v_SodoBai_TongQuanBai",
]

OPERATION_VIEWS = GATE_VIEWS + MAP_VIEWS

# Toàn bộ views được phép mở trực tiếp qua route /report/<view_name>
ALL_VIEWS = REPORT_VIEWS + OPERATION_VIEWS

# Chú giải hiển thị cho 7 views vận hành trên trang Báo cáo
OPERATION_VIEW_META = {
    "v_BotCong_TraCuuThe": {
        "icon": "🪪",
        "title": "Tra Cứu Thẻ Tại Bốt Cổng",
        "desc": "Quét 1 mã thẻ trả về đúng 1 dòng: tình trạng thẻ, vé tháng, chiều quét kế tiếp, cờ cho phép mở barrier và lý do từ chối.",
        "category": "Bốt Cổng",
    },
    "v_BotCong_XeChoRa": {
        "icon": "🧾",
        "title": "Xe Chờ Ra & Tiền Tạm Tính",
        "desc": "Danh sách xe đang trong bãi kèm số block giờ tính phí, tiền tạm tính theo f_TinhTienGuiXe và cảnh báo lệch biển số.",
        "category": "Bốt Cổng",
    },
    "v_BotCong_NhatKyVaoRa": {
        "icon": "📽️",
        "title": "Nhật Ký 200 Sự Kiện Vào / Ra",
        "desc": "Mỗi lượt gửi được trải thành 2 dòng sự kiện Vào và Ra theo trục thời gian cho màn hình phòng bảo vệ.",
        "category": "Bốt Cổng",
    },
    "v_BotCong_BangDenCong": {
        "icon": "🚦",
        "title": "Bảng Đèn Tín Hiệu Cổng Vào",
        "desc": "Trạng thái CÒN CHỖ / HẾT CHỖ theo từng cặp bãi đỗ x loại phương tiện, kèm ô đỗ gợi ý từ f_TimSlotTrong.",
        "category": "Bốt Cổng",
    },
    "v_SodoBai_ODoChiTiet": {
        "icon": "🅿️",
        "title": "Chi Tiết Ô Đỗ Trên Sơ Đồ",
        "desc": "Lưới ô đỗ thời gian thực (đúng 1 dòng / 1 ô đỗ) kèm xe đang chiếm chỗ, thời gian lưu bãi và cờ lệch dữ liệu.",
        "category": "Sơ Đồ Realtime",
    },
    "v_SodoBai_TongHopKhuVuc": {
        "icon": "🧱",
        "title": "Tổng Hợp Theo Khu Vực / Tầng",
        "desc": "Số ô trống và đã đỗ của từng khu vực, chia nhỏ theo loại phương tiện để hướng dẫn khách đi đúng tầng.",
        "category": "Sơ Đồ Realtime",
    },
    "v_SodoBai_TongQuanBai": {
        "icon": "📟",
        "title": "Tổng Quan Công Suất Từng Bãi",
        "desc": "Đối soát bộ đếm SoLuongHienTai với lượt gửi thực tế, nhịp xe vào/ra và doanh thu vé lượt trong ngày.",
        "category": "Sơ Đồ Realtime",
    },
}

DEMO_CASES = {
    # --------------------------------------------------------------------------------
    # CASE 1: sp_XeVaoBai
    # --------------------------------------------------------------------------------
    "sp-xe-vao-bai": {
        "title": "Demo Stored Procedure: Check-In xe vào cổng bãi (sp_XeVaoBai)",
        "problem": "Xe máy quét thẻ THE0003 vào bãi xe Lê Lai (BAI_Q1). Thủ tục tự động gọi Function f_TimSlotTrong tìm ô trống khả dụng, ghi nhận lượt gửi mới và kích hoạt Trigger chuyển trạng thái ô đỗ sang 'Đã đỗ' đồng thời tăng số lượng xe trong bãi.",
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
    @MaThe = 'THE0003', 
    @BienSo = '59T1-888.88', 
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
-- Không truyền @MaKH: thủ tục tự sinh mã KH#### tiếp theo (mã vé V####, mã hóa đơn HD + ngày + STT)
EXEC dbo.sp_DangKyThanhVien
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
    # CASE 5b: Cấp lại thẻ xe cho vé tháng mới (N4)
    # --------------------------------------------------------------------------------
    "sp-cap-lai-the": {
        "title": "Demo Procedure + Filtered Index: Cấp lại thẻ xe cho vé tháng mới (sp_DangKyThanhVien, f_VeHienHanhCuaThe)",
        "problem": "Vé V0008 của khách KH0008 đã hết hạn từ 15/07/2026, thẻ THE0022 được thu hồi và quầy Quận 7 cấp lại chính thẻ này cho khách mới. Unique index có lọc UX_VeThang_MaThe_ConDung chỉ cấm 2 vé CÒN DÙNG trên cùng một thẻ; hàm f_VeHienHanhCuaThe giúp trigger cổng và bốt cổng chỉ xét vé hiện hành nên vé cũ không chặn check-in. Thẻ đang gắn vé còn hạn bị từ chối (50065), vé cũ không gia hạn mở lại được (50066).",
        "before_sql": """
SELECT MaVe, MaThe, MaKH, BienSo, NgayHetHan, TrangThai, MaBaiApDung FROM dbo.VE_THANG WHERE MaThe = 'THE0022';
SELECT MaThe, MaVe, HoTenKhachHang, TrangThaiVeThang, SoNgayConLaiVe, ChoPhepQuet, LyDoTuChoi FROM dbo.v_BotCong_TraCuuThe WHERE MaThe = 'THE0022';
""",
        "before_labels": [
            {"name": "Thẻ THE0022 đang gắn vé đã hết hạn", "description": "V0008 hết hạn: thẻ không còn bị giữ bởi vé nào đang dùng."},
            {"name": "Bốt cổng tra cứu thẻ THE0022", "description": "Quẹt thẻ lúc này sẽ bị trigger chặn vì vé hết hạn (50003)."},
        ],
        "execute_sql": """
-- 1. Thẻ THE0002 đang gắn vé V0001 còn hạn: không được cấp cho vé mới
--    (đặt đầu tiên vì sp_DangKyThanhVien ROLLBACK toàn bộ transaction khi lỗi)
BEGIN TRY
    EXEC dbo.sp_DangKyThanhVien @HoTen = N'Khách thử thẻ đang dùng', @SDT = '0907000111', @CMND = '079200000111',
         @MaThe = 'THE0002', @BienSo = '59A-000.11', @MaLoaiXe = 'XM', @MaBaiApDung = 'BAI_Q1';
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
    SELECT N'Cấp thẻ THE0002 (vé V0001 còn hạn) cho vé mới' AS ThaoTac, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- 2. Cấp lại thẻ THE0022 (vé V0008 đã hết hạn) cho khách mới
EXEC dbo.sp_DangKyThanhVien @HoTen = N'Võ Minh Khôi', @SDT = '0907223344', @CMND = '079095002233',
     @MaThe = 'THE0022', @BienSo = '59N-246.80', @MaLoaiXe = 'XM', @MaBaiApDung = 'BAI_Q7', @SoThangDongTruoc = 1;

-- 3. Khách mới quẹt thẻ vào bãi Quận 7: trigger chỉ xét vé hiện hành nên vé cũ không chặn
DECLARE @MaViTri VARCHAR(20), @MaLuot INT;
EXEC dbo.sp_XeVaoBai @MaThe = 'THE0022', @BienSo = '59N-246.80', @MaBai = 'BAI_Q7', @MaViTri = @MaViTri OUTPUT, @MaLuot = @MaLuot OUTPUT;

-- 4. Vé cũ V0008 không gia hạn mở lại được vì thẻ đã thuộc vé mới
BEGIN TRY
    EXEC dbo.sp_GiaHanTheThang @MaVe = 'V0008', @SoThangGiaHan = 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
    SELECT N'Gia hạn vé cũ V0008' AS ThaoTac, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
""",
        "execute_labels": [
            {"name": "Thẻ đang gắn vé còn hạn bị từ chối", "description": "sp_DangKyThanhVien báo lỗi 50065 thay vì lỗi trùng khóa thô."},
            {"name": "Đăng ký vé mới với thẻ cấp lại", "description": "Vé mới, khách mới và hóa đơn được tạo trong một transaction."},
            {"name": "Khách mới quẹt thẻ vào bãi", "description": "Check-in thành công: vé cũ hết hạn không còn chặn thẻ."},
            {"name": "Vé cũ không mở lại được", "description": "Lõi gia hạn từ chối với lỗi 50066."},
        ],
        "after_sql": """
SELECT MaVe, MaThe, MaKH, BienSo, NgayDangKy, NgayHetHan, TrangThai, TuDongGiaHan FROM dbo.VE_THANG WHERE MaThe = 'THE0022' ORDER BY MaVe;
SELECT TOP 1 MaLuot, MaThe, MaVe, BienSo, ThoiGianVao, MaViTri, MaBai FROM dbo.LUOT_GUI WHERE MaThe = 'THE0022' ORDER BY MaLuot DESC;
SELECT MaThe, MaVe, HoTenKhachHang, TrangThaiVeThang, SoNgayConLaiVe, DangTrongBai, ChieuQuetKeTiep FROM dbo.v_BotCong_TraCuuThe WHERE MaThe = 'THE0022';
""",
        "after_labels": [
            {"name": "Thẻ THE0022 có 2 vé trong lịch sử", "description": "Vé cũ giữ trạng thái 'Hết hạn', vé mới 'Hoạt động'."},
            {"name": "Lượt gửi ghi đúng vé mới", "description": "LUOT_GUI.MaVe là vé hiện hành của thẻ."},
            {"name": "Bốt cổng chỉ hiện vé hiện hành", "description": "Một dòng duy nhất cho thẻ, đúng khách mới, đang trong bãi."},
        ],
    },

    # --------------------------------------------------------------------------------
    # CASE 5c: Đăng nhập nhân viên, mật khẩu băm có salt (N5)
    # --------------------------------------------------------------------------------
    "sp-dang-nhap-nhan-vien": {
        "title": "Demo Procedure + Function: Đăng nhập nhân viên, mật khẩu SHA2_512 có salt (sp_DangNhap, f_BamMatKhau)",
        "problem": "Mỗi tài khoản nhân viên có salt ngẫu nhiên 16 byte riêng (MatKhauSalt); hash = SHA2_512(salt + mật khẩu) qua f_BamMatKhau. Hai tài khoản cùng mật khẩu 123456 vẫn có hash khác nhau nên kẻ gian không thể tra bảng băm có sẵn. sp_DangNhap băm lại mật khẩu nhập với salt của tài khoản để đối chiếu: sai mật khẩu ném 50022, tài khoản bị khóa ném 50021.",
        "before_sql": """
SELECT TenDangNhap, MaNV, TrangThai,
       CONVERT(VARCHAR(34), MatKhauSalt, 1) AS GiaTriMuoi16Byte,
       CONVERT(VARCHAR(34), SUBSTRING(MatKhauHash, 1, 16), 1) AS DauChuoiBam16Byte,
       DATALENGTH(MatKhauHash) AS DoDaiChuoiBamByte,
       CASE WHEN dbo.f_BamMatKhau('123456', MatKhauSalt) = MatKhauHash THEN N'Khớp' ELSE N'Không khớp' END AS DoiChieu123456
FROM dbo.TAI_KHOAN
WHERE TenDangNhap IN ('quanly_q1', 'baove_q1', 'baove_khoa');
""",
        "before_labels": [
            {"name": "Cùng mật khẩu 123456, khác salt và khác chuỗi băm", "description": "Chỉ hiện 16 byte đầu của chuỗi băm 64 byte; đối chiếu bằng f_BamMatKhau đều khớp."},
        ],
        "execute_sql": """
-- 1. Đăng nhập đúng mật khẩu
EXEC dbo.sp_DangNhap @TenDangNhap = 'admin', @MatKhauPlain = 'Admin@2026';

-- 2. Sai mật khẩu và tài khoản bị khóa
DECLARE @KetQua TABLE (TinhHuong NVARCHAR(80), MaLoi INT, ThongBao NVARCHAR(400));
BEGIN TRY
    EXEC dbo.sp_DangNhap @TenDangNhap = 'quanly_q1', @MatKhauPlain = '654321';
END TRY
BEGIN CATCH
    INSERT INTO @KetQua VALUES (N'quanly_q1 nhập sai mật khẩu', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.sp_DangNhap @TenDangNhap = 'baove_khoa', @MatKhauPlain = '123456';
END TRY
BEGIN CATCH
    INSERT INTO @KetQua VALUES (N'baove_khoa đúng mật khẩu nhưng tài khoản bị khóa', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;
SELECT * FROM @KetQua;
""",
        "execute_labels": [
            {"name": "Đăng nhập thành công", "description": "Hồ sơ nhân viên và phạm vi bãi phụ trách."},
            {"name": "Các lần đăng nhập bị từ chối", "description": "50022: sai mật khẩu; 50021: tài khoản bị khóa."},
        ],
        "after_sql": """
SELECT r.name AS VaiTro, p.state_desc AS Quyen, p.permission_name AS LoaiQuyen,
       ISNULL(COL_NAME(p.major_id, p.minor_id), N'(cả bảng)') AS Cot
FROM sys.database_permissions p
INNER JOIN sys.database_principals r ON r.principal_id = p.grantee_principal_id
WHERE p.major_id = OBJECT_ID('dbo.TAI_KHOAN')
ORDER BY r.name, Cot;
""",
        "after_labels": [
            {"name": "Phân quyền trên bảng TAI_KHOAN", "description": "Quản lý bãi xem được tài khoản nhưng bị DENY 2 cột chuỗi băm và salt; bảo vệ và khách hàng bị DENY cả bảng."},
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
    # CASE: trg_KiemTraBaiApDungVeThang
    # --------------------------------------------------------------------------------
    "trigger-chan-sai-bai": {
        "title": "Demo Trigger: Chặn vé tháng gửi sai bãi áp dụng (trg_KiemTraBaiApDungVeThang)",
        "problem": "Ô tô vé tháng V0006 (thẻ THE0017) chỉ đăng ký gửi tại bãi TCP Park - Tân Sơn Nhất (BAI_TB) nhưng quét thẻ vào bãi Lê Lai (BAI_Q1). Trigger trg_KiemTraBaiApDungVeThang hủy giao dịch và ném lỗi 50004. Ngược lại, vé toàn chuỗi V0004 (MaBaiApDung = 'ALL') được gửi tại mọi bãi.",
        "before_sql": """
SELECT vt.MaVe, vt.MaThe, vt.BienSo, vt.MaLoaiXe, vt.NgayHetHan, vt.TrangThai, vt.MaBaiApDung,
       CASE WHEN vt.MaBaiApDung = 'ALL' THEN N'Gửi được mọi bãi' ELSE N'Chỉ gửi tại ' + b.TenBai END AS PhamViGui
FROM dbo.VE_THANG vt
LEFT JOIN dbo.BAI_DO_XE b ON vt.MaBaiApDung = b.MaBai
WHERE vt.MaVe IN ('V0006', 'V0004');
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
""",
        "before_labels": [
            {"name": "Phạm vi áp dụng của 2 vé tháng", "description": "V0006 gắn bãi BAI_TB; V0004 là vé toàn chuỗi 'ALL'."},
            {"name": "Bãi Lê Lai trước khi quét thẻ", "description": "Số xe hiện tại của bãi BAI_Q1."},
        ],
        "execute_sql": """
-- Thẻ tháng của bãi Tân Sơn Nhất cố tình check-in tại bãi Lê Lai
DECLARE @MaViTri VARCHAR(20);
DECLARE @MaLuot INT;
EXEC dbo.sp_XeVaoBai
    @MaThe = 'THE0017',
    @BienSo = '51K-246.80',
    @MaBai = 'BAI_Q1',
    @MaLoaiXe = 'OT',
    @MaViTri = @MaViTri OUTPUT,
    @MaLuot = @MaLuot OUTPUT;
""",
        "execute_labels": [
            {"name": "Kết quả", "description": "Lệnh check-in bị Trigger chặn lại do vé không áp dụng tại bãi này."}
        ],
        "after_sql": """
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, MaBai FROM dbo.LUOT_GUI WHERE MaThe = 'THE0017' ORDER BY MaLuot DESC;
""",
        "after_labels": [
            {"name": "Bãi Lê Lai không tăng xe", "description": "Giao dịch bị rollback, bộ đếm giữ nguyên."},
            {"name": "Không có lượt gửi mới tại BAI_Q1", "description": "Chỉ còn lịch sử gửi tại bãi BAI_TB của thẻ THE0017."},
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

    # ================================================================================
    # NHÓM CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md mục 10) - 9 kịch bản
    # Các thủ tục sp_KH_* lấy danh tính từ SESSION_CONTEXT, nên mỗi kịch bản đặt ngữ cảnh
    # bằng sp_set_session_context (@read_only mặc định = 0 để đổi qua lại giữa các khách trong demo).
    # ================================================================================
    "kh-dang-ky-tai-khoan": {
        "title": "Demo Procedure + Transaction: Khách hàng tự đăng ký tài khoản (sp_KH_DangKyTaiKhoan)",
        "problem": "Khách KH0005 (Võ Minh Quân) đã có vé V0005 tại quầy nhưng chưa có tài khoản online. Khách tự đăng ký bằng SĐT 0977112244 + CCCD 079090005555. Thủ tục xác minh hồ sơ, băm mật khẩu SHA2_512 với salt ngẫu nhiên, tạo tài khoản + ví số dư 0 + thông báo chào mừng trong một transaction. Đăng ký lần 2 bị chặn (50032) và không tạo dữ liệu dư.",
        "before_sql": """
SELECT MaKH, HoTen, SDT, CMND_CCCD FROM dbo.KHACH_HANG WHERE MaKH = 'KH0005';
SELECT MaTK, MaKH, TenDangNhap, TrangThai FROM dbo.TAI_KHOAN_KH WHERE MaKH = 'KH0005';
SELECT MaVi, MaKH, SoDu, TrangThai FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0005';
""",
        "before_labels": [
            {"name": "Hồ sơ khách hàng KH0005", "description": "Khách đã có hồ sơ tại quầy (điều kiện để tự đăng ký - D8)."},
            {"name": "Tài khoản cổng khách hàng của KH0005", "description": "Chưa có tài khoản."},
            {"name": "Ví điện tử của KH0005", "description": "Chưa có ví."},
        ],
        "execute_sql": """
-- Lần 1: đăng ký hợp lệ (mật khẩu đạt chính sách: >= 8 ký tự, hoa, thường, số, ký tự đặc biệt)
BEGIN TRY
    EXEC dbo.sp_KH_DangKyTaiKhoan @SDT = '0977112244', @CMND = '079090005555', @MatKhau = 'Quan@2026';
END TRY
BEGIN CATCH
    SELECT N'Lần 1' AS LanDangKy, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- Lần 2: đăng ký lại cùng khách -> thủ tục chặn 50032 trước khi ghi bất kỳ dữ liệu nào
BEGIN TRY
    EXEC dbo.sp_KH_DangKyTaiKhoan @SDT = '0977112244', @CMND = '079090005555', @MatKhau = 'Quan@2026';
END TRY
BEGIN CATCH
    SELECT N'Lần 2' AS LanDangKy, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
""",
        "execute_labels": [
            {"name": "Lần 1: tạo tài khoản thành công", "description": "Mã tài khoản TK#### và ví VI#### được sinh tự động."},
            {"name": "Lần 2: bị chặn đúng như mong đợi", "description": "Lỗi 50032 - khách đã có tài khoản."},
        ],
        "after_sql": """
SELECT MaTK, MaKH, TenDangNhap, MatKhauHash, MatKhauSalt, TrangThai, NgayTao FROM dbo.TAI_KHOAN_KH WHERE MaKH = 'KH0005';
SELECT MaVi, MaKH, SoDu, TrangThai FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0005';
SELECT TOP 3 LoaiTB, TieuDe, NoiDung, DaDoc, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0005' ORDER BY MaTB DESC;
""",
        "after_labels": [
            {"name": "Tài khoản vừa tạo (1 dòng duy nhất)", "description": "Hash và salt là dữ liệu nhị phân, giao diện tự che giá trị."},
            {"name": "Ví điện tử số dư 0", "description": "Trigger trg_ViDienTu_ChanSuaTrucTiep chỉ cho tạo ví với số dư 0."},
            {"name": "Thông báo chào mừng", "description": "Ghi trong cùng transaction với tài khoản."},
        ],
    },

    "kh-dang-nhap-khoa-tai-khoan": {
        "title": "Demo Trigger: Khóa tài khoản khi đăng nhập sai 5 lần (trg_NhatKyDangNhap_KhoaTaiKhoan)",
        "problem": "Kẻ gian dò mật khẩu tài khoản 0988776655 (KH0003) 5 lần liên tiếp. Mỗi lần sai, sp_KH_DangNhap ghi nhật ký; khi đủ 5 lần trong 15 phút, trigger tự khóa tài khoản 15 phút và gửi thông báo bảo mật. Lần thử thứ 6 dù đúng mật khẩu vẫn bị từ chối (50041). Sai tên đăng nhập và sai mật khẩu luôn trả cùng một thông báo (50040) để chống dò tài khoản.",
        "before_sql": """
SELECT MaTK, TenDangNhap, TrangThai, SoLanSaiLienTiep, KhoaDen, LanDangNhapCuoi FROM dbo.TAI_KHOAN_KH WHERE MaTK = 'TK0003';
SELECT TOP 5 MaNK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP FROM dbo.NHAT_KY_DANG_NHAP WHERE MaTK = 'TK0003' ORDER BY MaNK DESC;
""",
        "before_labels": [
            {"name": "Tài khoản TK0003 trước khi bị dò mật khẩu", "description": "Đang hoạt động, chưa sai lần nào."},
            {"name": "Nhật ký đăng nhập gần nhất", "description": "Lịch sử đăng nhập của tài khoản."},
        ],
        "execute_sql": """
DECLARE @KetQua TABLE (LanThu INT, MatKhauThu VARCHAR(50), MaLoi INT, ThongBao NVARCHAR(400));
DECLARE @i INT = 1;

WHILE @i <= 5
BEGIN
    BEGIN TRY
        EXEC dbo.sp_KH_DangNhap @TenDangNhap = '0988776655', @MatKhau = 'doan-mat-khau', @DiaChiIP = '45.124.84.99', @ThietBi = N'Bot dò mật khẩu', @KhoaNguCanh = 0;
        INSERT INTO @KetQua VALUES (@i, 'doan-mat-khau', 0, N'Đăng nhập thành công');
    END TRY
    BEGIN CATCH
        INSERT INTO @KetQua VALUES (@i, 'doan-mat-khau', ERROR_NUMBER(), ERROR_MESSAGE());
    END CATCH;
    SET @i += 1;
END;

-- Lần 6: đúng mật khẩu nhưng tài khoản đã bị trigger khóa
BEGIN TRY
    EXEC dbo.sp_KH_DangNhap @TenDangNhap = '0988776655', @MatKhau = 'Khach@2026', @KhoaNguCanh = 0;
    INSERT INTO @KetQua VALUES (6, 'Khach@2026 (đúng)', 0, N'Đăng nhập thành công');
END TRY
BEGIN CATCH
    INSERT INTO @KetQua VALUES (6, 'Khach@2026 (đúng)', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;

SELECT * FROM @KetQua ORDER BY LanThu;
""",
        "execute_labels": [
            {"name": "Kết quả 6 lần đăng nhập", "description": "Lần 1-5: 50040 (thông báo trung tính). Lần 6: 50041 - tài khoản đã bị khóa."},
        ],
        "after_sql": """
SELECT MaTK, TenDangNhap, TrangThai, SoLanSaiLienTiep, KhoaDen FROM dbo.TAI_KHOAN_KH WHERE MaTK = 'TK0003';
SELECT TOP 7 MaNK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP, ThietBi FROM dbo.NHAT_KY_DANG_NHAP WHERE MaTK = 'TK0003' ORDER BY MaNK DESC;
SELECT TOP 2 LoaiTB, TieuDe, NoiDung, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0003' AND LoaiTB = N'Bảo mật' ORDER BY MaTB DESC;
""",
        "after_labels": [
            {"name": "Tài khoản bị trigger khóa tạm 15 phút", "description": "TrangThai = 'Tạm khóa', KhoaDen = thời điểm mở khóa tự động."},
            {"name": "Nhật ký đăng nhập", "description": "5 dòng 'Sai mật khẩu' và 1 dòng 'Bị khóa'."},
            {"name": "Thông báo bảo mật gửi cho khách", "description": "Trigger tạo thông báo ngay khi khóa tài khoản."},
        ],
    },

    "kh-nap-tien-2-pha": {
        "title": "Demo Procedure + Trigger: Nạp tiền 2 pha và callback lặp không cộng tiền 2 lần",
        "problem": "KH0001 nạp 500.000 ₫ qua MoMo. Pha 1 (sp_KH_NapTien_KhoiTao) tạo giao dịch 'Chờ xử lý', số dư chưa đổi. Pha 2 MoMo gọi callback (sp_KH_NapTien_XacNhan): giao dịch chuyển 'Thành công', trigger trg_GiaoDich_CapNhatSoDu cộng tiền và ghi số dư trước/sau. MoMo gửi lại callback lần 2: thủ tục nhận ra giao dịch đã xử lý (idempotent) nên số dư không tăng thêm.",
        "before_sql": """
SELECT MaVi, MaKH, SoDu, TrangThai FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0001';
SELECT TOP 5 MaGD, LoaiGD, SoTien, MaPTTT, TrangThai, SoDuTruoc, SoDuSau, ThoiGianTao FROM dbo.GIAO_DICH WHERE MaVi = 'VI0001' ORDER BY ThoiGianTao DESC;
""",
        "before_labels": [
            {"name": "Ví của KH0001 trước khi nạp", "description": "Số dư hiện tại."},
            {"name": "Sổ cái ví VI0001", "description": "Các giao dịch gần nhất."},
        ],
        "execute_sql": """
-- Phiên đăng nhập của KH0001 (trên cổng thật do sp_KH_DangNhap đặt ở chế độ read-only)
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0001';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0001';

-- Pha 1: khởi tạo lệnh nạp, chuyển khách sang cổng MoMo
DECLARE @MaGD VARCHAR(16);
EXEC dbo.sp_KH_NapTien_KhoiTao @SoTien = 500000, @MaPTTT = 'MOMO', @MaGD = @MaGD OUTPUT;
SELECT N'Sau pha 1 - chưa thanh toán' AS Buoc, SoDu FROM dbo.vw_KH_HoSoCuaToi;

-- Pha 2: MoMo gọi callback xác nhận thành công
DECLARE @MaThamChieu VARCHAR(64) = CONCAT('MOMO-', @MaGD);
EXEC dbo.sp_KH_NapTien_XacNhan @MaGD = @MaGD, @MaThamChieu = @MaThamChieu, @ThanhCong = 1;

-- MoMo gửi lại callback lần 2 (mạng chập chờn)
EXEC dbo.sp_KH_NapTien_XacNhan @MaGD = @MaGD, @MaThamChieu = @MaThamChieu, @ThanhCong = 1;
SELECT N'Sau callback lặp' AS Buoc, SoDu FROM dbo.vw_KH_HoSoCuaToi;
""",
        "execute_labels": [
            {"name": "Pha 1: lệnh nạp 'Chờ xử lý'", "description": "Phí cổng MoMo 1,5% do công ty chịu."},
            {"name": "Số dư sau pha 1", "description": "Chưa thay đổi vì cổng thanh toán chưa xác nhận."},
            {"name": "Pha 2: callback lần 1", "description": "Trigger cộng tiền, ghi SoDuTruoc / SoDuSau."},
            {"name": "Callback lần 2 (lặp)", "description": "Thủ tục bỏ qua, không cộng tiền lần nữa."},
            {"name": "Số dư cuối cùng", "description": "Chỉ tăng đúng 500.000 ₫."},
        ],
        "after_sql": """
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0001';
SELECT TOP 5 MaGD, LoaiGD, SoTien, PhiGiaoDich, MaPTTT, MaThamChieu, TrangThai, SoDuTruoc, SoDuSau FROM dbo.GIAO_DICH WHERE MaVi = 'VI0001' ORDER BY ThoiGianTao DESC;
SELECT TOP 2 LoaiTB, TieuDe, NoiDung, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0001' ORDER BY MaTB DESC;
""",
        "after_labels": [
            {"name": "Ví sau khi nạp", "description": "Số dư tăng đúng 1 lần."},
            {"name": "Sổ cái sau khi nạp", "description": "Giao dịch mới ở trạng thái 'Thành công', có mã tham chiếu MoMo."},
            {"name": "Thông báo nạp tiền", "description": "Gửi một lần duy nhất."},
        ],
    },

    "kh-gia-han-bang-vi": {
        "title": "Demo Procedure + Function: Khách tự gia hạn vé bằng số dư ví (sp_KH_GiaHanBangVi)",
        "problem": "KH0002 tự gia hạn vé ô tô V0002 (gắn bãi Lê Lai) thêm 1 tháng. f_KH_TinhPhiGiaHan tính giá theo đúng quy tắc tại quầy (1.800.000 ₫). Trong một transaction: ghi giao dịch trừ ví (trigger cập nhật số dư), gọi lõi sp_GiaHanVe_Core gia hạn vé và xuất hóa đơn kênh Online gắn mã giao dịch; trigger hóa đơn gửi thông báo cho khách.",
        "before_sql": """
SELECT MaVe, MaKH, BienSo, MaLoaiXe, MaBaiApDung, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0002';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0002';
SELECT dbo.f_KH_TinhPhiGiaHan('V0002', 1) AS PhiGiaHan1Thang;
SELECT TOP 3 MaHD, SoThangGiaHan, SoTien, MaPTTT, KenhThanhToan, MaGD, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0002' ORDER BY NgayThanhToan DESC;
""",
        "before_labels": [
            {"name": "Vé tháng V0002 trước khi gia hạn", "description": "Hạn dùng hiện tại."},
            {"name": "Ví của KH0002", "description": "Số dư trước khi trừ."},
            {"name": "Giá gia hạn 1 tháng (function)", "description": "Giá ô tô tại bãi áp dụng BAI_Q1."},
            {"name": "Hóa đơn của vé V0002", "description": "Lịch sử thanh toán."},
        ],
        "execute_sql": """
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0002';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0002';

EXEC dbo.sp_KH_GiaHanBangVi @MaVe = 'V0002', @SoThang = 1;
""",
        "execute_labels": [
            {"name": "Kết quả gia hạn online", "description": "Mã giao dịch, mã hóa đơn, số dư trước / sau và hạn mới."},
        ],
        "after_sql": """
SELECT MaVe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0002';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0002';
SELECT TOP 3 MaHD, SoThangGiaHan, SoTien, MaPTTT, KenhThanhToan, MaGD, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0002' ORDER BY NgayThanhToan DESC;
SELECT TOP 2 LoaiTB, TieuDe, NoiDung, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0002' ORDER BY MaTB DESC;
""",
        "after_labels": [
            {"name": "Vé V0002 sau khi gia hạn", "description": "Hạn dùng cộng thêm 1 tháng."},
            {"name": "Ví sau khi trừ tiền", "description": "Giảm đúng giá do function tính."},
            {"name": "Hóa đơn mới kênh Online", "description": "MaPTTT = SO_DU_VI, gắn mã giao dịch ví."},
            {"name": "Thông báo do trigger hóa đơn tạo", "description": "trg_HoaDon_ThongBaoKhachHang."},
        ],
    },

    "trigger-chan-so-du-am": {
        "title": "Demo Trigger + Constraint: Chặn số dư ví âm (trg_GiaoDich_CapNhatSoDu)",
        "problem": "KH0004 (ví chỉ còn 50.000 ₫) cố gia hạn vé ô tô toàn chuỗi V0004 thêm 3 tháng (3 × 1.500.000 ₫, giá tại bãi phát hành thẻ BAI_Q3). Lớp 1: thủ tục kiểm tra trước và báo rõ số tiền thiếu (50031). Lớp 2: cố ghi thẳng giao dịch trừ tiền vào sổ cái để vượt thủ tục -> trigger sổ cái phát hiện số dư sẽ âm, ROLLBACK toàn bộ. Đối chiếu trước / sau: không thay đổi gì.",
        "before_sql": """
SELECT MaVe, MaKH, MaLoaiXe, MaBaiApDung, NgayHetHan FROM dbo.VE_THANG WHERE MaVe = 'V0004';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0004';
SELECT dbo.f_KH_TinhPhiGiaHan('V0004', 3) AS PhiGiaHan3Thang;
SELECT COUNT(*) AS SoGiaoDich FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004';
""",
        "before_labels": [
            {"name": "Vé V0004 (toàn chuỗi)", "description": "Hạn dùng trước khi thử gia hạn."},
            {"name": "Ví của KH0004", "description": "Số dư không đủ."},
            {"name": "Giá gia hạn 3 tháng", "description": "Tính theo bãi phát hành thẻ (D12)."},
            {"name": "Số giao dịch trong sổ cái", "description": "Dùng để đối chiếu sau khi chạy."},
        ],
        "execute_sql": """
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0004';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0004';

-- Lớp 1: thủ tục kiểm tra số dư trước khi ghi
BEGIN TRY
    EXEC dbo.sp_KH_GiaHanBangVi @MaVe = 'V0004', @SoThang = 3;
END TRY
BEGIN CATCH
    SELECT N'Lớp 1 - sp_KH_GiaHanBangVi' AS LopBaoVe, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- Lớp 2: cố ghi thẳng vào sổ cái, bỏ qua thủ tục -> trigger sổ cái chặn số dư âm
DECLARE @MaGD VARCHAR(16);
EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGD OUTPUT;
INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, MaPTTT, TrangThai, MaVe, NguoiThucHien)
VALUES (@MaGD, 'VI0004', N'Thanh toán vé tháng', -1, 4500000, 'SO_DU_VI', N'Thành công', 'V0004', N'Hệ thống');
""",
        "execute_labels": [
            {"name": "Lớp 1: thủ tục từ chối", "description": "Lỗi 50031 kèm số tiền thiếu."},
        ],
        "after_sql": """
SELECT MaVe, MaKH, MaLoaiXe, MaBaiApDung, NgayHetHan FROM dbo.VE_THANG WHERE MaVe = 'V0004';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0004';
SELECT COUNT(*) AS SoGiaoDich FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004';
""",
        "after_labels": [
            {"name": "Vé V0004 không đổi hạn", "description": "Giao dịch bị hủy hoàn toàn."},
            {"name": "Số dư không đổi", "description": "CHECK SoDu >= 0 và trigger sổ cái bảo vệ."},
            {"name": "Sổ cái không có giao dịch mới", "description": "Toàn vẹn ACID."},
        ],
    },

    "rls-co-lap-du-lieu-khach-hang": {
        "title": "Demo Security: Row-Level Security cô lập dữ liệu từng khách hàng (r_KhachHang + RLS)",
        "problem": "Cổng khách hàng kết nối CSDL bằng user u_WebKhachHang (role r_KhachHang). Cùng một câu SELECT trên vw_KH_LichSuGiaoDich trả về dữ liệu khác nhau tùy khách trong SESSION_CONTEXT. Truy cập thẳng bảng GIAO_DICH bị từ chối quyền (lớp 1 - DENY). KH0002 thử xem sao kê ví của KH0001 nhận về 0 dòng (lớp 2 - RLS). Nhân viên / quản trị (dbo) vẫn thấy toàn bộ dữ liệu.",
        "before_sql": """
SELECT vi.MaKH, kh.HoTen, COUNT(g.MaGD) AS SoGiaoDich, vi.SoDu
FROM dbo.VI_DIEN_TU vi
INNER JOIN dbo.KHACH_HANG kh ON vi.MaKH = kh.MaKH
LEFT JOIN dbo.GIAO_DICH g ON g.MaVi = vi.MaVi
GROUP BY vi.MaKH, kh.HoTen, vi.SoDu
ORDER BY vi.MaKH;
""",
        "before_labels": [
            {"name": "Góc nhìn quản trị (dbo)", "description": "Thấy ví và giao dịch của mọi khách hàng."},
        ],
        "execute_sql": """
EXECUTE AS USER = 'u_WebKhachHang';

EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0001';
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0001';
SELECT N'Góc nhìn KH0001' AS NguCanh, MaGD, LoaiGD, SoTienCoDau, PhuongThucThanhToan, TrangThai, SoDuSau FROM dbo.vw_KH_LichSuGiaoDich;

EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0002';
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0002';
SELECT N'Góc nhìn KH0002' AS NguCanh, MaGD, LoaiGD, SoTienCoDau, PhuongThucThanhToan, TrangThai, SoDuSau FROM dbo.vw_KH_LichSuGiaoDich;
SELECT N'KH0002 xem vé (chính chủ + được chia sẻ)' AS NguCanh, MaVe, BienSo, MaVaiTroCuaToi, VaiTroCuaToi, ChuVe FROM dbo.vw_KH_VeThangCuaToi;

-- Lớp 1: DENY bảng gốc
BEGIN TRY
    SELECT TOP 1 * FROM dbo.GIAO_DICH;
END TRY
BEGIN CATCH
    SELECT N'Truy cập thẳng bảng GIAO_DICH' AS ThuNghiem, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- Lớp 2: RLS - KH0002 thử xem sao kê ví VI0001 của KH0001
SELECT N'KH0002 xem sao kê ví VI0001' AS NguCanh, * FROM dbo.f_KH_SaoKeVi('VI0001', NULL, NULL);

REVERT;
""",
        "execute_labels": [
            {"name": "Góc nhìn KH0001", "description": "Chỉ giao dịch ví của KH0001."},
            {"name": "Góc nhìn KH0002", "description": "Cùng câu lệnh, chỉ giao dịch ví của KH0002."},
            {"name": "Vé của KH0002", "description": "Vé chính chủ V0002 + vé V0001 được KH0001 chia sẻ (XEM_LICH_SU)."},
            {"name": "Lớp 1: truy cập bảng gốc bị từ chối", "description": "Lỗi 229 - DENY SELECT trên GIAO_DICH."},
            {"name": "Lớp 2: sao kê ví người khác rỗng", "description": "Hàm và RLS chỉ trả ví của khách trong phiên."},
        ],
        "after_sql": """
SELECT name AS DoiTuong, type_desc AS Loai FROM sys.database_principals WHERE name IN ('r_KhachHang', 'u_WebKhachHang');
SELECT p.name AS SecurityPolicy, p.is_enabled AS DangBat, COUNT(*) AS SoPredicate
FROM sys.security_policies p
INNER JOIN sys.security_predicates sp ON sp.object_id = p.object_id
GROUP BY p.name, p.is_enabled;
""",
        "after_labels": [
            {"name": "Role và user cổng khách hàng", "description": "Lớp 1 của mô hình phân quyền."},
            {"name": "Security policy RLS", "description": "Lớp 2: 7 filter predicate trên các bảng có dữ liệu khách hàng."},
        ],
    },

    "kh-uy-quyen-ve": {
        "title": "Demo Function + Trigger: Chia sẻ vé cho người nhà với quyền hạn chế (f_KH_CoQuyen)",
        "problem": "Chủ vé KH0004 chia sẻ vé V0004 cho KH0007 (0938135790) với vai trò THANH_VIEN. KH0007 thấy V0004 và lịch sử đỗ xe nhưng gọi gia hạn thì f_KH_CoQuyen từ chối (50050 - THANH_VIEN không có quyền VE.GIAHAN). Chủ vé chia sẻ thêm 2 tài khoản cho đủ 3 rồi thử người thứ 4 -> bị chặn (50053).",
        "before_sql": """
SELECT MaVe, MaKH, BienSo, MaBaiApDung, NgayHetHan FROM dbo.VE_THANG WHERE MaVe = 'V0004';
SELECT uq.MaUyQuyen, uq.MaVe, tk.TenDangNhap AS NguoiNhan, uq.MaVaiTro, uq.TrangThai FROM dbo.UY_QUYEN_VE uq INNER JOIN dbo.TAI_KHOAN_KH tk ON uq.MaTKDuocUyQuyen = tk.MaTK WHERE uq.MaVe = 'V0004';
SELECT MaVaiTro, MaQuyen FROM dbo.VAI_TRO_QUYEN ORDER BY MaVaiTro, MaQuyen;
""",
        "before_labels": [
            {"name": "Vé V0004 của KH0004", "description": "Vé toàn chuỗi đang còn hạn."},
            {"name": "Ủy quyền hiện có trên V0004", "description": "Chưa chia sẻ cho ai."},
            {"name": "Ma trận vai trò x quyền", "description": "THANH_VIEN không có VE.GIAHAN."},
        ],
        "execute_sql": """
-- 1. Chủ vé KH0004 chia sẻ V0004 cho KH0007 với vai trò THANH_VIEN
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0004';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0004';
BEGIN TRY
    EXEC dbo.sp_KH_UyQuyenVe @MaVe = 'V0004', @TenDangNhapNguoiNhan = '0938135790', @MaVaiTro = 'THANH_VIEN';
END TRY
BEGIN CATCH
    SELECT N'Chia sẻ cho KH0007' AS ThuNghiem, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- 2. KH0007 đăng nhập: thấy vé được chia sẻ và lịch sử đỗ xe, nhưng không được gia hạn
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0006';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0007';
SELECT N'KH0007 xem danh sách vé' AS NguCanh, MaVe, BienSo, MaVaiTroCuaToi, VaiTroCuaToi, ChuVe FROM dbo.vw_KH_VeThangCuaToi;
SELECT N'KH0007 xem lịch sử đỗ của V0004' AS NguCanh, MaLuot, TenBai, MaViTri, ThoiGianVao, ThoiGianRa, SoPhutGui FROM dbo.vw_KH_LichSuDoXe WHERE MaVe = 'V0004';
BEGIN TRY
    EXEC dbo.sp_KH_GiaHanBangVi @MaVe = 'V0004', @SoThang = 1;
END TRY
BEGIN CATCH
    SELECT N'KH0007 thử gia hạn V0004' AS ThuNghiem, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- 3. Chủ vé chia sẻ thêm 2 tài khoản (đủ 3), rồi thử người thứ 4
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0004';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0004';
BEGIN TRY
    EXEC dbo.sp_KH_UyQuyenVe @MaVe = 'V0004', @TenDangNhapNguoiNhan = '0966369147', @MaVaiTro = 'XEM_LICH_SU';
    EXEC dbo.sp_KH_UyQuyenVe @MaVe = 'V0004', @TenDangNhapNguoiNhan = '0945112233', @MaVaiTro = 'XEM_LICH_SU';
END TRY
BEGIN CATCH
    SELECT N'Chia sẻ người thứ 2, 3' AS ThuNghiem, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
BEGIN TRY
    EXEC dbo.sp_KH_UyQuyenVe @MaVe = 'V0004', @TenDangNhapNguoiNhan = '0903112233', @MaVaiTro = 'XEM_LICH_SU';
END TRY
BEGIN CATCH
    SELECT N'Chia sẻ người thứ 4' AS ThuNghiem, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
""",
        "execute_labels": [
            {"name": "Chia sẻ V0004 cho KH0007", "description": "Vai trò THANH_VIEN, gửi thông báo cho cả hai bên."},
            {"name": "KH0007 thấy vé được chia sẻ", "description": "vw_KH_VeThangCuaToi gồm vé chính chủ V0007 và V0004."},
            {"name": "KH0007 xem lịch sử đỗ của V0004", "description": "Mọi vai trò đều có quyền LICHSU.XEM."},
            {"name": "KH0007 thử gia hạn", "description": "f_KH_CoQuyen từ chối: lỗi 50050."},
            {"name": "Chia sẻ người thứ 2", "description": "Thành công."},
            {"name": "Chia sẻ người thứ 3", "description": "Thành công (đủ 3)."},
            {"name": "Chia sẻ người thứ 4", "description": "Bị chặn: lỗi 50053."},
        ],
        "after_sql": """
SELECT uq.MaUyQuyen, uq.MaVe, tk.TenDangNhap AS NguoiNhan, uq.MaVaiTro, uq.TrangThai, uq.NgayTao FROM dbo.UY_QUYEN_VE uq INNER JOIN dbo.TAI_KHOAN_KH tk ON uq.MaTKDuocUyQuyen = tk.MaTK WHERE uq.MaVe = 'V0004';
SELECT TOP 4 MaKH, LoaiTB, TieuDe, NoiDung FROM dbo.THONG_BAO WHERE LoaiTB = N'Ủy quyền' ORDER BY MaTB DESC;
""",
        "after_labels": [
            {"name": "Ủy quyền trên V0004", "description": "Đúng 3 ủy quyền còn hiệu lực."},
            {"name": "Thông báo ủy quyền", "description": "Gửi cho người nhận và chủ vé."},
        ],
    },

    "cursor-tu-dong-gia-han": {
        "title": "Demo Cursor + Savepoint: Tự động gia hạn vé tháng bằng số dư ví (sp_DemoTuDongGiaHanVeThang)",
        "problem": "3 vé bật tự động gia hạn đều còn <= 3 ngày: V0007 (xe máy BAI_TB, 200.000 ₫, ví 300.000 ₫), V0011 (ô tô BAI_Q7, 1.700.000 ₫, ví 5.000.000 ₫), V0012 (ô tô BAI_BT, 2.200.000 ₫, ví 100.000 ₫). Cursor xử lý từng vé trong savepoint riêng: 2 vé gia hạn thành công (hóa đơn kênh Tự động), vé thiếu tiền chỉ hoàn tác riêng phần của nó và khách nhận thông báo nạp thêm tiền.",
        "before_sql": """
SELECT vt.MaVe, vt.MaKH, vt.BienSo, vt.NgayHetHan, vt.SoThangTuDongGiaHan, dbo.f_KH_TinhPhiGiaHan(vt.MaVe, vt.SoThangTuDongGiaHan) AS PhiGiaHan, vi.SoDu
FROM dbo.VE_THANG vt LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = vt.MaKH
WHERE vt.TuDongGiaHan = 1 ORDER BY vt.NgayHetHan;
""",
        "before_labels": [
            {"name": "Vé bật tự động gia hạn", "description": "Phí gia hạn (function) so với số dư ví của từng khách."},
        ],
        "execute_sql": """
EXEC dbo.sp_DemoTuDongGiaHanVeThang;
""",
        "execute_labels": [
            {"name": "Kết quả duyệt cursor", "description": "Mỗi vé một dòng: Đã gia hạn / Thiếu số dư (đã hoàn tác riêng)."},
        ],
        "after_sql": """
SELECT vt.MaVe, vt.MaKH, vt.BienSo, vt.NgayHetHan, vi.SoDu
FROM dbo.VE_THANG vt LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = vt.MaKH
WHERE vt.TuDongGiaHan = 1 ORDER BY vt.NgayHetHan;
SELECT TOP 5 MaHD, MaVe, SoTien, MaPTTT, KenhThanhToan, MaGD, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE KenhThanhToan = N'Tự động' ORDER BY NgayThanhToan DESC;
SELECT TOP 5 MaKH, LoaiTB, TieuDe, NoiDung FROM dbo.THONG_BAO ORDER BY MaTB DESC;
""",
        "after_labels": [
            {"name": "Vé sau khi chạy cursor", "description": "2 vé được cộng hạn, vé thiếu tiền giữ nguyên."},
            {"name": "Hóa đơn kênh Tự động", "description": "Gắn mã giao dịch trừ ví."},
            {"name": "Thông báo gửi khách", "description": "Gia hạn thành công / yêu cầu nạp thêm tiền."},
        ],
    },

    "trigger-so-cai-bat-bien": {
        "title": "Demo Trigger: Sổ cái giao dịch bất biến (trg_GiaoDich_BatBien, trg_GiaoDich_ChanXoa)",
        "problem": "Nhân viên gian lận cố sửa số tiền một giao dịch đã ghi, xóa giao dịch khỏi sổ cái và tự cộng số dư ví. Cả 3 thao tác đều bị trigger chặn (50061, 50060, 50062). Cách hợp lệ duy nhất để trả tiền lại cho khách là sp_NV_HoanTien: tạo giao dịch 'Hoàn tiền' đối ứng và chuyển giao dịch gốc sang 'Đã hoàn'. Thủ tục chỉ hoàn khoản trừ nhầm chưa gắn hóa đơn; khoản đã xuất hóa đơn gia hạn (vé đã được cộng hạn) bị từ chối (50063).",
        "before_sql": """
SELECT MaGD, MaVi, LoaiGD, SoTien, TrangThai, SoDuTruoc, SoDuSau FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004' ORDER BY ThoiGianTao;
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaVi = 'VI0004';
""",
        "before_labels": [
            {"name": "Sổ cái ví VI0004", "description": "Giao dịch GD260900000007 là thanh toán vé tháng 1.500.000 ₫."},
            {"name": "Ví VI0004", "description": "Số dư trước khi thử gian lận."},
        ],
        "execute_sql": """
BEGIN TRY
    UPDATE dbo.GIAO_DICH SET SoTien = 1000 WHERE MaGD = 'GD260900000007';
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
    SELECT N'Sửa số tiền giao dịch đã ghi' AS ThaoTacGianLan, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

BEGIN TRY
    DELETE FROM dbo.GIAO_DICH WHERE MaGD = 'GD260900000007';
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
    SELECT N'Xóa giao dịch khỏi sổ cái' AS ThaoTacGianLan, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

BEGIN TRY
    UPDATE dbo.VI_DIEN_TU SET SoDu = SoDu + 10000000 WHERE MaVi = 'VI0004';
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
    SELECT N'Tự cộng số dư ví' AS ThaoTacGianLan, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- Khoản đã xuất hóa đơn gia hạn V0004 không được hoàn (vé đã được cộng hạn, doanh thu đã ghi nhận)
BEGIN TRY
    EXEC dbo.sp_NV_HoanTien @MaGDGoc = 'GD260900000007', @LyDo = N'Khách đòi lại tiền gia hạn (demo)', @MaNV = 'NV003';
END TRY
BEGIN CATCH
    IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
    SELECT N'Hoàn khoản đã xuất hóa đơn' AS ThaoTacGianLan, ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;

-- Sự cố: hệ thống trừ nhầm 50.000 ₫ của ví VI0004 (không có hóa đơn đi kèm)
DECLARE @MaGDTruNham VARCHAR(16);
EXEC dbo.sp_SinhMaGiaoDich @MaGD = @MaGDTruNham OUTPUT;
INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, MaPTTT, TrangThai, MaVe, NguoiThucHien, GhiChu)
VALUES (@MaGDTruNham, 'VI0004', N'Thanh toán vé tháng', -1, 50000, 'SO_DU_VI', N'Thành công', 'V0004', N'Hệ thống', N'Trừ nhầm do lỗi kết nối (demo)');

-- Cách hợp lệ: hoàn khoản trừ nhầm bằng giao dịch đối ứng
EXEC dbo.sp_NV_HoanTien @MaGDGoc = @MaGDTruNham, @LyDo = N'Khách khiếu nại trừ nhầm (demo)', @MaNV = 'NV003';
""",
        "execute_labels": [
            {"name": "Sửa số tiền", "description": "trg_GiaoDich_BatBien chặn: 50061."},
            {"name": "Xóa giao dịch", "description": "trg_GiaoDich_ChanXoa chặn: 50060."},
            {"name": "Tự cộng số dư", "description": "trg_ViDienTu_ChanSuaTrucTiep chặn: 50062."},
            {"name": "Hoàn khoản đã xuất hóa đơn", "description": "sp_NV_HoanTien từ chối: 50063."},
            {"name": "Hoàn tiền hợp lệ", "description": "Giao dịch đối ứng +50.000 ₫ cho khoản trừ nhầm qua sổ cái."},
        ],
        "after_sql": """
SELECT MaGD, MaVi, LoaiGD, SoTien, TrangThai, MaGDGoc, SoDuTruoc, SoDuSau, GhiChu FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004' ORDER BY ThoiGianTao;
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaVi = 'VI0004';
""",
        "after_labels": [
            {"name": "Sổ cái sau khi hoàn tiền", "description": "GD260900000007 vẫn 'Thành công'; khoản trừ nhầm chuyển 'Đã hoàn' và có thêm 1 giao dịch 'Hoàn tiền'."},
            {"name": "Số dư ví", "description": "Trở về như trước sự cố: trừ nhầm -50.000 ₫ rồi hoàn +50.000 ₫ qua trigger sổ cái."},
        ],
    },
}

# ====================================================================================
# PHÂN NHÓM 21 KỊCH BẢN DEMO CSDL (PROCEDURE | TRIGGER | FUNCTION | CURSOR | CỔNG KHÁCH HÀNG)
# ====================================================================================
DEMO_GROUPS = [
    {
        "id": "procedure",
        "category": "Procedure",
        "title": "Nhóm Stored Procedures (Thủ Tục Lưu Trữ)",
        "badge_class": "badge-success",
        "color": "#10b981",
        "icon": "⚙️",
        "desc": "Xử lý các quy trình nghiệp vụ gồm nhiều bước: Check-In, Check-Out tính phí, Đăng ký vé tháng trong Transaction, Gia hạn vé, Báo mất thẻ phạt đền bù, Cấp lại thẻ cho vé mới và Đăng nhập nhân viên với mật khẩu có salt.",
        "case_keys": [
            "sp-xe-vao-bai",
            "sp-xe-ra-bai",
            "sp-dang-ky-thanh-vien",
            "sp-gia-han-ve-thang",
            "sp-bao-mat-the",
            "sp-cap-lai-the",
            "sp-dang-nhap-nhan-vien",
        ],
    },
    {
        "id": "trigger",
        "category": "Trigger",
        "title": "Nhóm Database Triggers (Bẫy Lỗi Tự Động)",
        "badge_class": "badge-danger",
        "color": "#ef4444",
        "icon": "⚡",
        "desc": "Tự động kích hoạt khi có sự kiện ghi dữ liệu để bảo vệ toàn vẹn: Chặn check-in thẻ lỗi/báo mất hoặc bãi đầy, Chặn xe tháng hết hạn nộp tiền, Chặn vé tháng gửi sai bãi áp dụng.",
        "case_keys": [
            "trigger-chan-checkin-loi",
            "trigger-chan-ve-het-han",
            "trigger-chan-sai-bai",
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
    {
        "id": "customer",
        "category": "Cổng khách hàng",
        "title": "Nhóm Cổng Khách Hàng (Tài Khoản, Ví, Phân Quyền)",
        "badge_class": "badge-info",
        "color": "#0891b2",
        "icon": "👛",
        "desc": "Tài khoản khách hàng, ví trả trước, sổ cái bất biến, nạp tiền 2 pha, tự gia hạn, tự động gia hạn bằng cursor, Row-Level Security và chia sẻ vé theo vai trò.",
        "case_keys": [
            "kh-dang-ky-tai-khoan",
            "kh-dang-nhap-khoa-tai-khoan",
            "kh-nap-tien-2-pha",
            "kh-gia-han-bang-vi",
            "trigger-chan-so-du-am",
            "rls-co-lap-du-lieu-khach-hang",
            "kh-uy-quyen-ve",
            "cursor-tu-dong-gia-han",
            "trigger-so-cai-bat-bien",
        ],
    },
]
