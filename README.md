# HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
> **Môn học:** Quản lý Thông tin / Quản trị Cơ sở Dữ liệu (IE103)  
> **Nền tảng:** Python 3 (Flask), Microsoft SQL Server 2022 (T-SQL, Stored Procedures, Triggers, Functions, Cursors, 37 Views, RBAC Security, Backup/Restore)  
> **Cổng phục vụ Web:** `http://127.0.0.1:5001`

---

## 📌 1. Giới thiệu Đề tài

Đề tài giải quyết bài toán vận hành chuỗi nhiều bãi đỗ xe thông minh thuộc các địa bàn trọng điểm (Quận 1 - Lê Lai, Quận 3 - Hai Bà Trưng, Bình Thạnh - Landmark 81). Hệ thống xử lý trọn vẹn luồng nghiệp vụ từ khâu quét thẻ tự động tại barrier, điều phối ô đỗ, tính toán biểu phí động, quản lý hợp đồng vé tháng, xử lý sự cố an ninh cho đến báo cáo phân tích kinh doanh (BI) cho ban giám đốc.

### Điểm nổi bật về nghiệp vụ và kỹ thuật:
- **Phân tách chi nhánh độc lập**: Mỗi bãi đỗ quản lý kho thẻ chip RFID, sơ đồ ô đỗ, biểu phí và sức chứa riêng biệt qua mã bãi (`MaBai`).
- **Biểu phí linh hoạt theo vị trí**: Cùng một loại xe (xe máy, ô tô) nhưng mức phí gửi lượt và vé tháng được định nghĩa khác nhau theo từng chi nhánh bằng **Khóa chính hỗn hợp (Composite PK)** `(MaLoaiXe, MaBai)`.
- **Tự động hóa 100% bằng logic CSDL**:
  - Không hardcode logic tính tiền hay chuyển đổi trạng thái ở backend Python.
  - Tự động tìm ô đỗ trống qua **Scalar Function** `f_TimSlotTrong`.
  - Tự động tính tiền gửi xe lũy tiến qua **Scalar Function** `f_TinhTienGuiXe`.
  - Tự động đồng bộ trạng thái ô đỗ (`Trống` $\leftrightarrow$ `Đã đỗ`) và cập nhật số lượng xe thời gian thực qua **Trigger** `trg_DongBoTrangThaiSlot`.
  - Tự động bẫy lỗi chặn thẻ mất/khóa, chặn vé tháng quá hạn qua **Trigger** `trg_KiemTraCheckIn` và `trg_ChanSuDungVeHetHan`.
  - Bảo toàn tính toàn vẹn khi đăng ký vé tháng bằng **SQL Transaction** nhiều bước.
  - Tự động quét cảnh báo hạn vé và tổng kết doanh thu toàn chuỗi bằng **Database Cursors**.
- **Bộ 37 Views chuyên sâu**: Phục vụ trực tiếp bốt kiểm soát cổng vào/ra (`/gate`), sơ đồ mặt bằng realtime (`/map`) và báo cáo quản trị BI (`/reports`).
- **An toàn thông tin & Phân quyền RBAC**: Phân cấp 3 nhóm vai trò (`r_Admin`, `r_QuanLyBai`, `r_BaoVe`) với chính sách cấp quyền (`GRANT`) và ngăn chặn nghiêm ngặt (`DENY`), mật khẩu băm `SHA2_512` kèm salt ngẫu nhiên riêng từng tài khoản (nhân viên và khách hàng).

---

## 🏢 2. Chi Tiết Các Bài Toán Thực Tế Được Giải Quyết Trong Project

Hệ thống được thiết kế xuất phát từ các vấn đề nhức nhối trong thực tế quản lý bãi đỗ xe đô thị hiện nay:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CÁC BÀI TOÁN THỰC TẾ TRONG DỰ ÁN                         │
├──────────────────────────────┬──────────────────────────────┬───────────────┤
│ 1. Kiểm soát Barrier Vào/Ra  │ 2. Chống Thất thoát Thu phí  │ 3. Hợp đồng   │
│    & Cấp phát ô đỗ tự động   │    & Biểu phí theo chi nhánh │    Vé tháng   │
├──────────────────────────────┼──────────────────────────────┼───────────────┤
│ 4. An ninh & Xử lý Sự cố     │ 5. Giám sát Mặt bằng & Sức   │ 6. Quyết định │
│    Báo mất thẻ tức thời      │    chứa Thời gian thực       │    Kinh doanh │
└──────────────────────────────┴──────────────────────────────┴───────────────┘
```

### 🚗 Bài toán 1: Kiểm soát Cổng Barrier & Tự động Cấp phát Ô đỗ (Smart Access & Slot Allocation)
- **Vấn đề thực tế:** 
  - Vào giờ cao điểm (sáng đi làm, chiều tan tầm), việc nhân viên bảo vệ phải nhìn mắt thường xem bãi còn chỗ hay không và chỉ tay hướng dẫn ô đỗ gây ùn tắc kéo dài tại cổng barrier.
  - Lái xe ô tô vào bãi phải chạy lòng vòng tìm chỗ đỗ, dễ gây va chạm trong tầng hầm.
- **Giải pháp trong project:**
  - Khi xe quẹt thẻ tại barrier vào, thủ tục `sp_XeVaoBai` tự động gọi hàm vô hướng `f_TimSlotTrong(@MaBai, @MaLoaiXe)`. Hàm này quét nhanh các ô đang có `TrangThai = N'Trống'` khớp loại xe và trả về ngay mã ô đỗ đầu tiên (ví dụ: `Q1_A101`).
  - Trigger `trg_DongBoTrangThaiSlot` tự động chuyển trạng thái ô đỗ thành `'Đã đỗ'` và cộng `SoLuongHienTai` của bãi lên 1.
  - Bảng đèn cổng (`v_BotCong_BangDenCong`) hiển thị ngay tín hiệu **CÒN CHỖ (🟢)**, số chỗ trống và mã ô đỗ gợi ý cho tài xế trước khi barrier mở.

### 💰 Bài toán 2: Tính Phí Đỗ xe Linh hoạt & Chống Thất thoát Doanh thu (Dynamic Tariffs & Fraud Prevention)
- **Vấn đề thực tế:**
  - Bãi xe ở khu trung tâm (Quận 1) có chi phí mặt bằng rất cao nên giá gửi xe phải cao hơn bãi ở vùng ven (Bình Thạnh).
  - Nhân viên bảo vệ tính nhẩm tiền giờ thủ công dễ nhầm lẫn hoặc có nguy cơ thông đồng gian lận: thu tiền khách nhưng không ghi nhận lượt gửi hoặc tự ý sửa đổi số tiền thực thu rồi bỏ túi riêng.
- **Giải pháp trong project:**
  - **Khóa chính hỗn hợp `(MaLoaiXe, MaBai)`** trong bảng `LOAI_XE`: Thiết lập giá giờ (`DonGiaGio`) và giá vé tháng (`GiaVeThang`) riêng biệt cho từng chi nhánh.
  - **Hàm `f_TinhTienGuiXe`:** Tự động tính số block giờ gửi `CEILING(DATEDIFF(MINUTE, ThoiGianVao, GETDATE()) / 60.0)` và nhân với đơn giá niêm yết của bãi. Xe vé tháng hợp lệ được tự động trả về `0 ₫`.
  - **Phân quyền RBAC (`sql/08_security_rbac.sql`):** Vai trò bảo vệ (`r_BaoVe`) bị `DENY UPDATE, DELETE ON LUOT_GUI` và `HOA_DON_VE_THANG`. Bảo vệ tuyệt đối không thể can thiệp sửa tiền hay xóa vết xe ra/vào.
  - **Phát hiện gian lận mượn thẻ:** View `v_BotCong_XeChoRa` gắn cờ `CanhBaoLechBienSo` cảnh báo đỏ nếu biển số lúc check-out khác với biển số đăng ký trên vé tháng.

### 📑 Bài toán 3: Quản lý Thuê bao Vé tháng & Toàn vẹn Giao dịch (Monthly Subscription & ACID Integrity)
- **Vấn đề thực tế:**
  - Đăng ký vé tháng là quy trình nghiệp vụ gồm 4 bước liên hoàn: (1) Tạo hồ sơ khách hàng mới $\rightarrow$ (2) Đổi loại thẻ từ `Lượt` sang `Tháng` $\rightarrow$ (3) Cấp mã hợp đồng vé tháng $\rightarrow$ (4) Lập hóa đơn thu tiền tháng đầu tiên.
  - Nếu hệ thống bị mất điện hoặc đứt kết nối mạng giữa chừng (ví dụ: đã đổi thẻ nhưng chưa kịp ghi hóa đơn thu tiền), dữ liệu sẽ bị sai lệch nghiêm trọng, kế toán không khớp với bãi xe.
- **Giải pháp trong project:**
  - Đóng gói toàn bộ 4 bước trong Stored Procedure `sp_DangKyThanhVien` với **SQL Transaction**:
    ```sql
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Bước 1: INSERT KHACH_HANG
        -- Bước 2: UPDATE THE_XE (LoaiThe = N'Tháng')
        -- Bước 3: INSERT VE_THANG
        -- Bước 4: INSERT HOA_DON_VE_THANG
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
    ```
  - Nếu bất kỳ bước nào lỗi (như trùng CMND/CCCD, thẻ đã có người đăng ký), toàn bộ giao dịch được hoàn tác 100%, bảo vệ tuyệt đối tính nhất quán dữ liệu (ACID).
  - Trigger `trg_ChanSuDungVeHetHan` tự động từ chối mở cổng nếu khách dùng thẻ tháng đã quá hạn mà chưa đóng tiền gia hạn.

### 🚨 Bài toán 4: Bảo mật Thẻ RFID, Xử lý Sự cố & Bồi thường Mất thẻ (Lost Card Protocol & Security Incident)
- **Vấn đề thực tế:**
  - Khách làm rơi mất thẻ chip gửi xe. Kẻ gian nhặt được thẻ có thể ra bãi lấy trộm xe của khách.
  - Quy trình xử lý mất thẻ bằng biên bản giấy dễ thất lạc, không lưu vết thời gian và số tiền phạt bồi hoàn thẻ (thường là 50.000 ₫).
- **Giải pháp trong project:**
  - Thủ tục `sp_BaoMatThe`: Lập tức chuyển trạng thái thẻ trong `THE_XE` thành `N'Mất'`.
  - Trigger `trg_LogLichSuSuCo`: Tự động kích hoạt khi phát hiện thẻ đổi sang trạng thái `Mất`, tự chèn một biên bản điều tra sự cố vào bảng `LICHSU_SU_CO` kèm mức tiền phạt 50.000 ₫.
  - Trigger `trg_KiemTraCheckIn`: Khi kẻ gian quẹt thẻ đã bị báo mất tại cổng, trigger lập tức chặn đứng barrier và trả về mã lỗi bảo mật `50002: Thẻ xe đang bị khóa hoặc đã báo mất!`.

### 🗺️ Bài toán 5: Giám sát Sơ đồ Mặt bằng & Quản trị Công suất Thời gian thực (Realtime Lot Capacity & Overbooking Prevention)
- **Vấn đề thực tế:**
  - Tình trạng nhận xe vượt quá sức chứa thiết kế (Overbooking) làm xe đỗ chắn lối thoát hiểm, vi phạm an toàn PCCC.
  - Người quản lý không nắm được tầng nào, khu vực nào còn chỗ để điều phối nhân sự trực.
- **Giải pháp trong project:**
  - Ràng buộc toàn vẹn `CHECK (SoLuongHienTai <= SucChua)` trên bảng `BAI_DO_XE`.
  - Trigger `trg_KiemTraCheckIn`: Chặn xe vào khi số lượt đang mở vượt `SucChua` (mã lỗi `50001: Bãi đỗ xe đã đầy công suất!`). Trigger đếm trực tiếp lượt chưa ra và được đặt chạy trước (`sp_settriggerorder ... 'First'`), nên xe cuối cùng khi bãi còn đúng 1 chỗ vẫn vào được.
  - Cũng trong trigger này: thẻ đang có lượt chưa ra không check-in lần nữa (`50014`), ô đỗ phải thuộc đúng bãi và chỉ chứa 1 xe (`50015`), thẻ lượt chỉ dùng tại bãi phát hành (`50016`).
  - Hệ thống 3 Views sơ đồ realtime:
    - `v_SodoBai_ODoChiTiet`: Hiển thị từng vị trí đỗ, biển số xe, thời gian gửi và cảnh báo lệch trạng thái giữa ô đỗ với lượt gửi.
    - `v_SodoBai_TongHopKhuVuc`: Tổng hợp số ô trống/đã đỗ theo từng phân khu và tầng hầm.
    - `v_SodoBai_TongQuanBai`: Đối soát bộ đếm tự động với thực tế xe đang đỗ (`CanhBaoLechBoDem`).

### ⚙️ Bài toán 6: Tự động hóa Vận hành Hàng ngày bằng Con trỏ CSDL (Automated Maintenance with Cursors)
- **Vấn đề thực tế:**
  - Mỗi ngày quản lý phải dò tay danh sách hàng trăm khách hàng vé tháng xem ai sắp hết hạn để gọi điện nhắc gia hạn, ai đã quá hạn để khóa thẻ.
  - Cuối kỳ, kế toán trưởng phải tổng hợp doanh thu từ nhiều bãi xe khác nhau một cách thủ công.
- **Giải pháp trong project:**
  - **Cursor `cur_CanhBaoHanTheThang`:** Tự động duyệt qua bảng `VE_THANG`, kiểm tra ngày hết hạn so với ngày hiện tại; tự động chuyển trạng thái sang `N'Hết hạn'` đối với vé quá hạn và in thông báo cảnh báo cho các vé còn hạn $\le 3$ ngày.
  - **Cursor `cur_TongKetDoanhThuChuoi`:** Duyệt tuần tự qua danh sách các bãi đỗ trong bảng `BAI_DO_XE`, tổng hợp doanh thu vé lượt và vé tháng theo từng chi nhánh, xuất bảng tổng kết tài chính chuỗi.

### 📈 Bài toán 7: Hỗ trợ Ra Quyết định Kinh doanh & Báo cáo BI Đa chiều (Business Intelligence & Executive Analytics)
- **Vấn đề thực tế:**
  - Ban giám đốc chuỗi cần các con số thực tế để quyết định: Chi nhánh nào hoạt động hiệu quả nhất? Có nên đầu tư thêm ô đỗ ô tô thay vì xe máy? Tỷ lệ lấp đầy trung bình vào các ngày trong tuần ra sao?
- **Giải pháp trong project:**
  - Hệ thống Views chuẩn hóa cung cấp dữ liệu tức thì cho **Microsoft Power BI** và **Tableau**:
    - `vw_Report_DoanhThuTheoBai`: Phân tích cơ cấu nguồn thu (vé lượt vs vé tháng).
    - `vw_Report_CongSuatBaiDo`: Đánh giá tỷ lệ lấp đầy bình quân của từng chi nhánh.
    - `v_ThongKeLoaiXe`: Tỷ lệ phân bổ các dòng phương tiện để quy hoạch mặt bằng.
    - `vw_Report_NhatKySuCo`: Thống kê tỷ lệ sự cố và tiền phạt theo tháng.

---

## 🗂️ 3. Cấu trúc Thư mục Dự án

```text
qltt-parking-lot-management/
│
├── run.py                              # Entry-point khởi chạy Flask server (Port 5001)
├── requirements.txt                    # Danh sách thư viện Python (Flask, pyodbc, python-dotenv)
├── .env.example                        # Mẫu cấu hình môi trường kết nối SQL Server
├── .env                                # Cấu hình môi trường cục bộ
├── README.md                           # Tài liệu tổng quan, bài toán thực tế & hướng dẫn cài đặt
├── DemoGuilde.md                       # Cẩm nang thuyết trình 21 kịch bản Demo 5 bước + cổng khách hàng
│
├── docs/
│   └── parking-project-blueprint.md    # Đặc tả kỹ thuật kiến trúc toàn diện V6 (11 bảng, 15 views, RBAC)
│
├── sql/                                # 9 module SQL; mỗi module 01-08 gồm phần vận hành bãi rồi phần cổng khách hàng
│   ├── 01_schema.sql                   # 21 bảng (11 bảng vận hành + 10 bảng cổng khách hàng), sequence seq_GiaoDich, danh mục PTTT / quyền / vai trò
│   ├── 02_sample_data.sql              # Dữ liệu mẫu (sinh từ docs/QuanLyBaiDoXe_DuLieuMau.xlsx) + tài khoản, ví, sổ cái cổng khách hàng
│   ├── 03_procedures.sql               # 23 Stored Procedures: quầy, lõi gia hạn, 12 sp_KH_*, 3 sp_NV_*
│   ├── 04_triggers.sql                 # 16 Triggers: an ninh bãi, sổ cái ví bất biến, khóa tài khoản, ủy quyền
│   ├── 05_functions.sql                # 12 Functions: tính tiền, tìm slot, băm mật khẩu, phân quyền, sao kê ví, vé hiện hành của thẻ
│   ├── 06_cursors.sql                  # 4 Cursors: cảnh báo hạn vé, tổng kết doanh thu, tự động gia hạn, đối soát ví
│   ├── 07_views.sql                    # 37 Views: vận hành, bốt cổng, báo cáo BI, cổng khách hàng vw_KH_*
│   ├── 08_security_rbac.sql            # RBAC 4 vai trò (r_Admin, r_QuanLyBai, r_BaoVe, r_KhachHang) + Row-Level Security
│   ├── 09_backup_restore.sql           # Kịch bản sao lưu Full/Diff/Log & khôi phục (chạy riêng, không nằm trong full script)
│   ├── QL_BaiDoXe_FullScript.sql       # Sinh tự động bởi tools/build_fullscript.py từ 01-08, không sửa tay
│   └── Demo_Queries.sql                # Bộ câu lệnh SQL đối chứng song hành dưới SSMS
│
├── tools/
│   └── build_fullscript.py             # Sinh lại full script; --check để kiểm tra đã đồng bộ với module chưa
│
├── app/
│   ├── __init__.py                     # Khởi tạo Flask App, format tiền tệ VND, thời gian, trạng thái
│   ├── db.py                           # Tầng kết nối pyodbc, cơ chế transaction, xử lý batch GO
│   ├── queries.py                      # Danh mục bảng, views và chi tiết 21 kịch bản Demo 5 bước
│   ├── routes.py                       # Quản lý toàn bộ endpoint điều hướng và REST API
│   │
│   ├── static/
│   │   ├── css/style.css               # Giao diện hiện đại (Design Tokens, Sticky Header, Spacing <= 12px)
│   │   └── js/main.js                  # Hỗ trợ tương tác, lọc tab, cuộn kết quả
│   │
│   └── templates/
│       ├── base.html                   # Layout khung sườn ứng dụng
│       ├── index.html                  # Trang chủ & Danh mục 21 kịch bản Demo dạng List Card phân nhóm
│       ├── parking_map.html            # Sơ đồ mặt bằng ô đỗ xe realtime (Slot Map) kèm biển số phản quang
│       ├── gate_booth.html             # Bốt kiểm soát cổng vào/ra (quét thẻ, đèn cổng, xe chờ ra, nhật ký)
│       ├── demo.html                   # Màn hình thực thi kịch bản Demo 5 bước song hành SSMS
│       ├── tables.html                 # Danh mục 21 bảng dữ liệu CSDL (nhóm theo phân hệ, tìm kiếm)
│       ├── reports.html                # Danh mục 23 view báo cáo BI & vận hành realtime
│       ├── report_detail.html          # Chi tiết dữ liệu View & trích xuất bảng
│       ├── sql_query.html              # Trình soạn thảo và chạy câu lệnh SQL trực tiếp
│       ├── setup.html                  # Màn hình tích hợp Health Check & Setup CSDL thông minh
│       ├── simple_result.html          # Hiển thị bảng kết quả đơn giản
│       ├── _result_table.html          # Component Macro render dữ liệu bảng chuyên nghiệp
│       └── error.html                  # Màn hình thông báo lỗi
│
└── reports_screenshots/                # Thư mục lưu trữ ảnh Dashboard mẫu từ Power BI / Tableau
    └── README.txt
```

---

## 🛠️ 4. Yêu cầu Cài đặt & Hướng dẫn Khởi chạy

### 4.1. Yêu cầu Hệ thống
- **Python:** Phiên bản 3.10 trở lên.
- **Hệ quản trị CSDL:** Microsoft SQL Server (2017, 2019, 2022 hoặc Docker `azure-sql-edge` trên macOS M1/M2/M3).
- **Driver kết nối:** `ODBC Driver 18 for SQL Server` (hoặc Driver 17).
- **Công cụ truy vấn:** SQL Server Management Studio (SSMS) hoặc Azure Data Studio.

### 4.2. Khởi tạo Cơ sở Dữ liệu

**Cách 1: Khởi tạo tự động từ Màn hình Web Setup (Khuyên dùng)**
1. Khởi động ứng dụng web (xem mục 4.4 bên dưới).
2. Truy cập đường dẫn: `http://127.0.0.1:5001/setup`.
3. Bấm **"Kiểm tra kết nối"** $\rightarrow$ Khi hệ thống trả về `CONNECTED`, khối Cài đặt CSDL sẽ tự động mở khóa.
4. Bấm **"Khởi tạo Full CSDL"** để hệ thống chạy `sql/QL_BaiDoXe_FullScript.sql`, dựng toàn bộ 21 bảng, 37 views, procedures, triggers, dữ liệu mẫu, phân quyền RBAC và Row-Level Security.

**Cách 2: Thực thi thủ công trong SSMS**
1. Mở file [sql/QL_BaiDoXe_FullScript.sql](file:///Users/tult/Documents/ORTHER/H%E1%BB%8Dc%20T%E1%BA%ADp/2026/K%C3%AC%202/Qu%E1%BA%A3n%20l%C3%BD%20th%C3%B4ng%20tin/%C4%90%E1%BB%93%20%C3%A1n/qltt-parking-lot-management/sql/QL_BaiDoXe_FullScript.sql).
2. Nhấn **Execute (F5)** để khởi tạo hoàn chỉnh CSDL `QuanLyBaiDoXe`.

### 4.3. Cài đặt Môi trường Python

```bash
# Mở terminal tại thư mục gốc qltt-parking-lot-management
python3 -m venv .venv

# Kích hoạt môi trường ảo:
# Trên macOS / Linux:
source .venv/bin/activate
# Trên Windows:
# .venv\Scripts\activate

# Cài đặt các thư viện cần thiết:
pip install -r requirements.txt
```

### 4.4. Cấu hình Kết nối `.env` & Khởi chạy Web

Sao chép `.env.example` thành `.env` và thiết lập thông số:

```env
SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server
SQLSERVER_SERVER=localhost,1433
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=no
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=Password123!
PORT=5001
```

Khởi chạy ứng dụng:
```bash
python run.py
```

Truy cập hệ thống trên trình duyệt:
```text
http://127.0.0.1:5001
```

### 3.6. Chạy bằng Docker (Mac Apple Silicon M1/M2 + Colima)

SQL Server 2022 chỉ có image `amd64`, nên Colima cần bật Rosetta để giả lập (tối thiểu 4 GB RAM):

```bash
colima start --vm-type vz --vz-rosetta --cpu 4 --memory 4

docker compose up -d --build     # db (SQL Server) -> db-init (nạp full script lần đầu) -> app (Flask)
docker compose ps                # db: healthy, db-init: Exited (0), app: Up
```

- Web: `http://127.0.0.1:5001` (cổng 5000 trên macOS bị AirPlay Receiver chiếm; đổi bằng biến `APP_PORT`).
- SSMS / Azure Data Studio: server `localhost,1433`, user `sa`, mật khẩu `Parking@12345` (đổi bằng biến `MSSQL_SA_PASSWORD` trong shell hoặc `.env` trước lần chạy đầu tiên).
- `db-init` chỉ nạp `sql/QL_BaiDoXe_FullScript.sql` khi CSDL chưa được dựng hoàn chỉnh, nên dữ liệu demo được giữ lại giữa các lần `up`. Muốn nạp lại: dùng trang `/setup`, hoặc xóa sạch volume bằng `docker compose down -v`.
- Mã nguồn được mount vào container, Flask tự reload khi sửa code.

---

## 🎯 5. Danh mục 21 Kịch Bản Demo CSDL Chuẩn 5 Bước

Các kịch bản demo được tổ chức thành dạng **List Card** phân 5 nhóm tại trang chủ (`/`); hướng dẫn thuyết trình từng kịch bản trong [DemoGuilde.md](DemoGuilde.md), cho phép đối chiếu trực tiếp dữ liệu trước và sau khi thực thi:

| Nhóm | Mã Kịch Bản | Tên Kịch Bản | Đối Tượng CSDL Sử Dụng | Bài Toán Giải Quyết |
| :--- | :--- | :--- | :--- | :--- |
| **Procedure** | `sp-xe-vao-bai` | Check-In xe vào bãi | `sp_XeVaoBai`, `f_TimSlotTrong`, `trg_DongBoTrangThaiSlot` | Cấp phát slot trống tự động, tăng số lượng xe đang đỗ, đổi trạng thái ô đỗ sang `'Đã đỗ'`. |
| **Procedure** | `sp-xe-ra-bai` | Check-Out xe & Thu phí | `sp_XeRaBai`, `f_TinhTienGuiXe`, `trg_DongBoTrangThaiSlot` | Tính phí theo số block giờ, giải phóng slot về `'Trống'`, giảm số xe bãi đỗ. |
| **Procedure** | `sp-dang-ky-thanh-vien` | Đăng ký vé tháng an toàn | `sp_DangKyThanhVien` (TRANSACTION) | Đảm bảo tính toàn vẹn ACID: Tạo KH $\rightarrow$ Đổi loại thẻ $\rightarrow$ Cấp vé $\rightarrow$ Sinh hóa đơn. Tự sinh mã `KH####` / `V####` / `HD` + ngày + STT; thiếu biểu phí báo lỗi 50017. |
| **Procedure** | `sp-gia-han-ve-thang` | Gia hạn vé tháng | `sp_GiaHanTheThang` (TRANSACTION) | Cộng dồn thời hạn sử dụng vé và tự động sinh hóa đơn thanh toán. Vé gắn bãi chỉ thu tiền tại bãi áp dụng (50018), vé `ALL` thu tại bãi gia hạn (mặc định bãi phát hành thẻ), thẻ đã báo mất không gia hạn được (50019). |
| **Procedure** | `sp-bao-mat-the` | Báo mất thẻ & Lập biên bản | `sp_BaoMatThe`, `trg_LogLichSuSuCo` | Khóa thẻ lập tức, tự động sinh biên bản sự cố và áp tiền phạt đền bù 50.000 ₫. |
| **Procedure** | `sp-cap-lai-the` | Cấp lại thẻ cho vé mới | `sp_DangKyThanhVien`, `f_VeHienHanhCuaThe`, unique index có lọc | Thẻ của vé đã hết hạn được cấp cho vé mới; thẻ đang gắn vé còn hạn bị từ chối (50065), vé cũ không mở lại được (50066). |
| **Procedure** | `sp-dang-nhap-nhan-vien` | Đăng nhập nhân viên có salt | `sp_DangNhap`, `f_BamMatKhau` | Cùng mật khẩu khác hash (SHA2_512 + salt); sai mật khẩu 50022, tài khoản khóa 50021. |
| **Trigger** | `trigger-chan-checkin-loi` | Chặn thẻ mất & Bãi đầy | `trg_KiemTraCheckIn` | Bẫy lỗi chủ động: Chặn thẻ bị khóa/mất (lỗi 50002), bãi đầy 100% (lỗi 50001), thẻ đang đỗ (50014), ô sai bãi / đã có xe (50015), thẻ lượt sai bãi (50016). |
| **Trigger** | `trigger-chan-ve-het-han` | Chặn vé tháng quá hạn | `trg_ChanSuDungVeHetHan` | Từ chối mở barrier khi vé tháng đã hết hạn sử dụng (lỗi 50003). |
| **Trigger** | `trigger-chan-sai-bai` | Chặn vé gửi sai bãi | `trg_KiemTraBaiApDungVeThang` | Vé gắn một bãi quét ở bãi khác bị chặn (50004); vé toàn chuỗi `ALL` đi được mọi bãi. |
| **Function** | `function-tinh-tien-slot` | Tính tiền giờ & Dò slot | `f_TinhTienGuiXe`, `f_TimSlotTrong`, `f_DanhSachXeTrongBai` | Kiểm chứng trực tiếp kết quả trả về của các hàm vô hướng và hàm trả về bảng. |
| **Cursor** | `cursor-canh-bao-doanh-thu` | Quét hạn vé & Doanh thu chuỗi | `sp_DemoCanhBaoHanTheThang`, `sp_DemoTongKetDoanhThuChuoi` | Vận hành 2 con trỏ CSDL duyệt từng dòng dữ liệu tự động. |
| **Cổng KH** | `kh-dang-ky-tai-khoan` | Khách tự tạo tài khoản | `sp_KH_DangKyTaiKhoan` | Xác minh SĐT + CCCD, tài khoản + ví 0 ₫ trong một transaction; đăng ký lại 50032. |
| **Cổng KH** | `kh-dang-nhap-khoa-tai-khoan` | Khóa khi dò mật khẩu | `sp_KH_DangNhap`, `trg_NhatKyDangNhap_KhoaTaiKhoan` | Sai 5 lần trong 15 phút khóa 15 phút (50041); thông báo trung tính 50040. |
| **Cổng KH** | `kh-nap-tien-2-pha` | Nạp tiền 2 pha | `sp_KH_NapTien_KhoiTao`, `sp_KH_NapTien_XacNhan`, `trg_GiaoDich_CapNhatSoDu` | Callback lặp không cộng tiền 2 lần (idempotent). |
| **Cổng KH** | `kh-gia-han-bang-vi` | Tự gia hạn bằng ví | `sp_KH_GiaHanBangVi`, `sp_GiaHanVe_Core` | Trừ ví + gia hạn + hóa đơn kênh Online trong một transaction. |
| **Cổng KH** | `trigger-chan-so-du-am` | Chặn số dư âm | `trg_GiaoDich_CapNhatSoDu`, `CHECK SoDu >= 0` | Thủ tục và trigger sổ cái đều chặn (50031). |
| **Cổng KH** | `rls-co-lap-du-lieu-khach-hang` | Row-Level Security | `r_KhachHang`, `bao_mat.rls_KhachHang` | DENY bảng gốc, mỗi khách chỉ thấy dữ liệu của mình. |
| **Cổng KH** | `kh-uy-quyen-ve` | Chia sẻ vé theo vai trò | `sp_KH_UyQuyenVe`, `f_KH_CoQuyen` | Thành viên không gia hạn được (50050), tối đa 3 người (50053). |
| **Cổng KH** | `cursor-tu-dong-gia-han` | Tự động gia hạn | `sp_DemoTuDongGiaHanVeThang` | Cursor + savepoint: vé thiếu tiền chỉ hoàn tác phần của nó. |
| **Cổng KH** | `trigger-so-cai-bat-bien` | Sổ cái bất biến & hoàn tiền | `trg_GiaoDich_BatBien`, `trg_GiaoDich_ChanXoa`, `sp_NV_HoanTien` | Chặn sửa / xóa sổ cái (50061, 50060, 50062); chỉ hoàn khoản chưa xuất hóa đơn (50063). |

---

## 🚦 6. Các Màn Hình Chức Năng Chính Trên Giao Diện Web

1. **Màn hình Tổng quan (`/`):**
   - Danh mục 21 kịch bản Demo dạng List Card phân chia theo 5 nhóm (`Procedure` | `Trigger` | `Function` | `Cursor` | `Cổng khách hàng`).
   - Quick Filter Pills lọc nhanh theo nhóm kèm badge số lượng.
   - Hộp thoại nhập tham số tương tác và bảng so sánh **Trước (Before)** $\leftrightarrow$ **Sau (After)** thực thi.
2. **Màn hình Bốt Kiểm Soát Cổng Vào / Ra (`/gate`):**
   - **Khối Quét Thẻ:** Nhập mã thẻ $\rightarrow$ Hệ thống lập tức trả về tín hiệu đèn quyết định **MỞ BARRIER** hoặc **TỪ CHỐI**, chiều quét tiếp theo, lý do từ chối và ghi chú cảnh báo an ninh (`v_BotCong_TraCuuThe`).
   - **Bảng Đèn Cổng Vào:** Đèn tín hiệu 🟢 / 🟡 / 🔴 theo từng loại xe, số chỗ trống và ô đỗ gợi ý (`v_BotCong_BangDenCong`).
   - **Danh Sách Xe Chờ Ra Cổng:** Hiển thị số phút đã đỗ, tiền tạm tính và cờ cảnh báo lệch biển số (`v_BotCong_XeChoRa`).
   - **Nhật Ký Dòng Sự Kiện:** Lưu vết 200 lượt xe qua barrier theo trục thời gian (`v_BotCong_NhatKyVaoRa`).
3. **Màn hình Sơ đồ Bãi xe Thời gian thực (`/map`):**
   - Trực quan hóa mặt bằng các ô đỗ xe theo chi nhánh. Ô trống màu xanh lá, ô đã đỗ màu đỏ hiển thị biển kiểm soát dập nổi phản quang chân thực.
   - Dữ liệu đồng bộ tự động ngay sau khi thao tác check-in/out nhờ 3 Views: `v_SodoBai_ODoChiTiet`, `v_SodoBai_TongHopKhuVuc`, `v_SodoBai_TongQuanBai`.
4. **Màn hình Báo cáo Quản trị BI (`/reports`):**
   - Danh mục 23 view báo cáo phân tích (nhóm + tìm kiếm) kinh doanh, tỷ lệ lấp đầy, cơ cấu phương tiện và sự cố.
5. **Màn hình Danh mục Bảng (`/tables`):**
   - Khám phá cấu trúc và dữ liệu thực tế của 21 bảng CSDL.
6. **Màn hình Truy vấn SQL (`/sql`):**
   - Trình gõ và chạy lệnh SQL trực tiếp an toàn, hiển thị kết quả dạng bảng linh hoạt.
7. **Màn hình Tích hợp Health & Setup CSDL Thông minh (`/setup`):**
   - Hợp nhất kiểm tra kết nối SQL Server và cài đặt CSDL vào cùng một giao diện.
   - Cơ chế bảo vệ thông minh: Tự động khóa/ẩn phần cài đặt cho đến khi kiểm tra kết nối thành công (`CONNECTED`).
8. **Màn hình nhân viên Khách hàng & Thanh toán (`/khach-hang`):** tài khoản cổng khách hàng, mở khóa, nạp tiền mặt tại quầy, sổ cái và hoàn tiền (`sp_NV_*`), giám sát bảo mật đăng nhập.
9. **Cổng khách hàng (`/kh`, layout riêng, mở từ sidebar "Cổng khách hàng ↗"):**
   - Đăng nhập / đăng ký bằng SĐT + CCCD; trang đăng nhập có bảng **tài khoản demo** bấm để điền sẵn (mật khẩu mẫu `Khach@2026`, ẩn bằng `KH_DEMO_ACCOUNTS=0`).
   - Tổng quan số dư ví và vé; chi tiết vé (hóa đơn, tự động gia hạn, báo mất thẻ, người được chia sẻ); gia hạn bằng ví có xem trước giá và số dư sau gia hạn.
   - Nạp tiền 2 pha qua **cổng thanh toán mô phỏng** (thành công / hủy / gửi lại callback để minh họa idempotency); sao kê ví có số dư lũy kế; lịch sử đỗ xe; thông báo; chia sẻ / thu hồi vé; đổi mật khẩu và nhật ký đăng nhập.
   - Mỗi request chạy dưới quyền `r_KhachHang` (`EXECUTE AS USER = 'u_WebKhachHang'`, hoặc login riêng qua `SQLSERVER_KH_USERNAME`) với `SESSION_CONTEXT` read-only, nên Row-Level Security lọc dữ liệu thật sự; có CSRF token và hết phiên sau 30 phút không thao tác.

---

## 👥 7. Phân Công Trách Nhiệm Nhóm 10 Thành Viên

| Nhóm | Thành viên | Phụ trách chính | Sản phẩm nộp bài |
| :--- | :--- | :--- | :--- |
| **Nhóm 1** | **Thành viên A, B** | Thiết kế ERD 11 bảng, Từ điển dữ liệu & Phân quyền RBAC 3 roles | File ERD PNG, Word Từ điển dữ liệu, script `sql/08_security_rbac.sql` |
| **Nhóm 2** | **Thành viên C, D** | Môi trường Docker, Core Schema 11 bảng, Script tổng hợp | `docker-compose.yml`, `sql/01_schema.sql`, `sql/QL_BaiDoXe_FullScript.sql` |
| **Nhóm 3** | **Thành viên E, F** | 6 Stored Procedures, 5 Triggers & Kịch bản Backup/Restore | `sql/03_procedures.sql`, `sql/04_triggers.sql`, `sql/09_backup_restore.sql` |
| **Nhóm 4** | **Thành viên G, H** | 15 Views, 3 Functions, 2 Cursors & Kịch bản Bulk Insert | `sql/05_functions.sql`, `sql/06_cursors.sql`, `sql/07_views.sql`, CSV files |
| **Nhóm 5** | **Thành viên I, K** | Dữ liệu mẫu 11 bảng, Giao diện Web Dashboard & Báo cáo cuối kỳ | `sql/02_sample_data.sql`, Web Source Code (`app/`), Báo cáo Word/PDF |
