# HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
> **Môn học:** Quản lý Thông tin (IE103)  
> **Nền tảng:** Python 3 (Flask), Microsoft SQL Server (T-SQL, Stored Procedures, Triggers, Functions, Cursors, Views)

---

## 📌 1. Giới thiệu Đề tài

Đề tài giải quyết bài toán vận hành chuỗi nhiều bãi đỗ xe thuộc các địa bàn khác nhau (Quận 1, Quận 3, Bình Thạnh). 

### Điểm nổi bật về nghiệp vụ và kỹ thuật:
- **Phân tách chi nhánh độc lập**: Mỗi bãi đỗ quản lý kho thẻ, sơ đồ ô đỗ và sức chứa riêng biệt.
- **Biểu phí linh hoạt**: Cùng là một loại xe (xe máy, ô tô) nhưng mức phí gửi lượt và vé tháng được định nghĩa khác nhau theo từng bãi đỗ (Khóa chính hỗn hợp `(MaLoaiXe, MaBai)`).
- **Tự động hóa hoàn toàn bằng CSDL**:
  - Không hardcode logic tính tiền hay đồng bộ trạng thái ở backend.
  - Tự động tìm ô đỗ trống qua **Scalar Function** `f_TimSlotTrong`.
  - Tự động tính phí gửi xe lũy tiến qua **Scalar Function** `f_TinhTienGuiXe`.
  - Tự động đồng bộ trạng thái ô đỗ (`Trống` $\leftrightarrow$ `Đã đỗ`) và cập nhật số lượng xe thời gian thực qua **Trigger** `trg_DongBoTrangThaiSlot`.
  - Tự động bẫy lỗi chặn thẻ mất/khóa, chặn vé tháng quá hạn qua **Trigger** `trg_KiemTraCheckIn` và `trg_ChanSuDungVeHetHan`.
  - Bảo toàn tính toàn vẹn khi đăng ký vé tháng bằng **Transaction** nhiều bước.
  - Quét cảnh báo vé tháng hết hạn và tổng kết doanh thu toàn chuỗi bằng **Cursors**.
- **Quy trình Demo 5 bước chuẩn mực**: Đối chiếu trực tiếp giữa thao tác Web và câu truy vấn dưới SQL Server Management Studio (SSMS).

---

## 🗂️ 2. Cấu trúc Thư mục Dự án

```text
qltt-parking-lot-management/
│
├── run.py                              # Entry-point khởi chạy Flask server
├── requirements.txt                    # Danh sách thư viện Python
├── .env.example                        # Mẫu cấu hình môi trường SQL Server
├── .env                                # Cấu hình môi trường cục bộ
├── README.md                           # Tài liệu tổng quan & hướng dẫn
│
├── docs/
│   └── parking-project-blueprint-v5.md # Bản đặc tả chi tiết CSDL & nghiệp vụ V5
│
├── sql/                                # Phân chia module chuẩn nộp đồ án CSDL
│   ├── 01_schema.sql                   # Khởi tạo 9 bảng và các ràng buộc toàn vẹn
│   ├── 02_sample_data.sql              # Dữ liệu mẫu (3 bãi, 34 ô đỗ, thẻ, khách hàng, vé, sự cố)
│   ├── 03_procedures.sql               # 5 Stored Procedures cốt lõi (Check-in, Check-out, Đăng ký, Gia hạn, Báo mất)
│   ├── 04_triggers.sql                 # 5 Database Triggers bẫy lỗi & đồng bộ dữ liệu
│   ├── 05_functions.sql                # 3 Functions (Tính tiền giờ, Tìm slot trống, Danh sách xe)
│   ├── 06_cursors.sql                  # 2 Cursors (Quét hạn vé tháng, Tổng kết tài chính chuỗi)
│   ├── 07_views.sql                    # 15 Views: vận hành, bốt cổng vào/ra, sơ đồ realtime & báo cáo BI
│   ├── QL_BaiDoXe_FullScript.sql       # Script tổng hợp chạy 1 lần tự động dựng toàn bộ CSDL
│   └── Demo_Queries.sql                # Câu lệnh SQL mẫu để đối chứng song hành dưới SSMS
│
├── app/
│   ├── __init__.py                     # Khởi tạo Flask App, format tiền tệ VND, thời gian, trạng thái
│   ├── db.py                           # Tầng kết nối pyodbc, cơ chế transaction, xử lý batch GO
│   ├── queries.py                      # Danh mục bảng, view và chi tiết 9 kịch bản Demo 5 bước
│   ├── routes.py                       # Quản lý toàn bộ endpoint điều hướng
│   │
│   ├── static/
│   │   ├── css/style.css               # Giao diện hiện đại, tối ưu responsive và hiển thị sơ đồ slot
│   │   └── js/main.js                  # Hỗ trợ tương tác, tự động cuộn kết quả
│   │
│   └── templates/
│       ├── base.html                   # Layout khung sườn
│       ├── index.html                  # Trang chủ & thẻ thống kê tổng quan
│       ├── parking_map.html            # Sơ đồ mặt bằng ô đỗ xe thời gian thực (Slot Map)
│       ├── gate_booth.html             # Bốt kiểm soát cổng vào/ra (quét thẻ, đèn cổng, xe chờ ra, nhật ký)
│       ├── demo.html                   # Màn hình Demo 5 bước song hành SSMS
│       ├── tables.html                 # Danh mục 9 bảng dữ liệu
│       ├── reports.html                # Danh mục 5 báo cáo BI + 7 views vận hành realtime
│       ├── report_detail.html          # Chi tiết dữ liệu View & ảnh Dashboard
│       ├── sql_query.html              # Trình gõ và chạy SQL trực tiếp
│       ├── setup.html                  # Công cụ nạp lại CSDL từ web
│       ├── simple_result.html          # Hiển thị bảng kết quả đơn giản
│       ├── _result_table.html          # Component Macro render bảng dữ liệu
│       └── error.html                  # Màn hình thông báo lỗi
│
└── reports_screenshots/                # Thư mục chứa ảnh dashboard từ Tableau / PowerBI
    └── README.txt
```

---

## 🛠️ 3. Yêu cầu Cài đặt & Hướng dẫn Khởi chạy

### 3.1. Yêu cầu Hệ thống
- **Python:** 3.10 trở lên.
- **Hệ quản trị CSDL:** Microsoft SQL Server (2017, 2019, 2022 hoặc Azure SQL Edge trên Mac M1/M2).
- **Driver kết nối:** `ODBC Driver 17 for SQL Server` (hoặc Driver 18).
- **Công cụ quản lý:** SQL Server Management Studio (SSMS) hoặc Azure Data Studio.

### 3.2. Khởi tạo Cơ sở Dữ liệu

1. Mở SSMS hoặc Azure Data Studio, kết nối tới SQL Server instance của bạn.
2. Mở file [sql/QL_BaiDoXe_FullScript.sql](file:///Users/tult/Documents/ORTHER/H%E1%BB%8Dc%20T%E1%BA%ADp/2026/K%C3%AC%202/Qu%E1%BA%A3n%20l%C3%BD%20th%C3%B4ng%20tin/%C4%90%E1%BB%93%20%C3%A1n/qltt-parking-lot-management/sql/QL_BaiDoXe_FullScript.sql).
3. Bấm **Execute** (F5). Script sẽ tự động tạo database `QuanLyBaiDoXe`, 9 bảng, nạp đầy đủ dữ liệu mẫu và các đối tượng Functions, Triggers, Procedures, Cursors, Views.

### 3.3. Cài đặt Môi trường Python

```bash
# Mở terminal tại thư mục qltt-parking-lot-management
python3 -m venv .venv

# Kích hoạt môi trường ảo:
# Trên Windows:
# .venv\Scripts\activate
# Trên macOS / Linux:
source .venv/bin/activate

# Cài đặt thư viện:
pip install -r requirements.txt
```

### 3.4. Cấu hình Kết nối File `.env`

Sao chép `.env.example` thành `.env` và chỉnh sửa các thông số:

```env
SQLSERVER_DRIVER=ODBC Driver 17 for SQL Server
SQLSERVER_SERVER=localhost
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=yes
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=your_password
ALLOW_RUN_FULL_SCRIPT=1
PORT=5000
```

### 3.5. Khởi chạy Ứng dụng Web

```bash
python run.py
```

Truy cập trên trình duyệt web:
```text
http://127.0.0.1:5000
```

---

## 🎯 4. Danh mục Kịch bản Demo Nghiệp vụ 5 Bước

Hệ thống được lập trình sẵn 9 kịch bản demo tại route `/demo/<case_key>`:

| Mã Kịch Bản | Tên Kịch Bản | Đối Tượng CSDL | Ý Nghĩa Thực Tiễn |
| :--- | :--- | :--- | :--- |
| `sp-xe-vao-bai` | Check-In xe vào bãi | `sp_XeVaoBai` + `f_TimSlotTrong` + `trg_DongBoTrangThaiSlot` | Tự động cấp slot trống, bãi tăng 1 xe, ô đỗ đổi sang 'Đã đỗ' (chuyển đỏ). |
| `sp-xe-ra-bai` | Check-Out xe ra bãi & Tính phí | `sp_XeRaBai` + `f_TinhTienGuiXe` + `trg_DongBoTrangThaiSlot` | Tính tiền theo block giờ, giải phóng slot về 'Trống' (chuyển xanh), bãi giảm 1 xe. |
| `sp-dang-ky-thanh-vien` | Đăng ký vé tháng an toàn | `sp_DangKyThanhVien` (TRANSACTION) | Đảm bảo tính toàn vẹn: Tạo KH $\rightarrow$ Đổi thẻ $\rightarrow$ Cấp vé $\rightarrow$ Lập hóa đơn. |
| `sp-gia-han-ve-thang` | Gia hạn vé tháng | `sp_GiaHanTheThang` | Cộng dồn hạn sử dụng và tự động sinh hóa đơn thu tiền. |
| `sp-bao-mat-the` | Báo mất thẻ & Phạt đền bù | `sp_BaoMatThe` + `trg_LogLichSuSuCo` | Khóa thẻ lập tức, tự động ghi nhận biên bản sự cố và áp tiền phạt 50.000 ₫. |
| `trigger-chan-checkin-loi` | Chặn thẻ lỗi hoặc bãi đầy | `trg_KiemTraCheckIn` | Chặn check-in thẻ mất/khóa hoặc khi bãi đầy công suất (ném lỗi có chủ đích). |
| `trigger-chan-ve-het-han` | Chặn xe tháng quá hạn | `trg_ChanSuDungVeHetHan` | Từ chối mở barrier khi vé tháng đã quá ngày hết hạn. |
| `function-tinh-tien-slot` | Tính tiền giờ & Dò slot trống | `f_TinhTienGuiXe`, `f_TimSlotTrong`, `f_DanhSachXeTrongBai` | Demo gọi trực tiếp các hàm tính toán và hàm trả về bảng. |
| `cursor-canh-bao-doanh-thu` | Quét hạn vé & Doanh thu chuỗi | `sp_DemoCanhBaoHanTheThang`, `sp_DemoTongKetDoanhThuChuoi` | Demo 2 con trỏ duyệt từng dòng dữ liệu chuyên sâu. |

---

## 🗺️ 5. Màn hình Sơ đồ Mặt bằng Bãi xe (`/map`)

Đặc tính trực quan vượt trội:
- Lọc theo từng bãi: Bãi Lê Lai (Q1), Bãi Hai Bà Trưng (Q3), Bãi Landmark 81 (Bình Thạnh).
- Thanh đo tỷ lệ lấp đầy (%) và chỗ trống còn lại.
- Mỗi ô đỗ hiển thị mã vị trí, phân khu, loại xe đỗ cho phép.
- Ô màu xanh lá = **Trống**; Ô màu đỏ = **Đã đỗ** (hiển thị kèm Biển số xe, mã thẻ chip, thời gian vào).
- Sau khi bấm Check-in hoặc Check-out ở màn hình Demo, vào lại màn hình `/map` sẽ thấy trạng thái ô đỗ và số lượng xe được tự động cập nhật thời gian thực nhờ Trigger.
- Toàn bộ số liệu đọc trực tiếp từ 3 SQL View: `v_SodoBai_ODoChiTiet` (lưới ô đỗ), `v_SodoBai_TongHopKhuVuc` (thanh tổng hợp theo khu vực/tầng) và `v_SodoBai_TongQuanBai` (thẻ tổng quan công suất, cờ đối soát bộ đếm, doanh thu vé lượt trong ngày).

---

## 🚦 5b. Màn hình Bốt Kiểm Soát Cổng Vào / Ra (`/gate`)

Màn hình trực barrier của nhân viên bảo vệ, đọc trực tiếp từ 4 SQL View nhóm bốt cổng:

- **Khối 1 · Quét thẻ tại barrier** (`v_BotCong_TraCuuThe`): nhập/chọn mã thẻ → hiển thị đèn quyết định **MỞ BARRIER** hoặc **TỪ CHỐI**, chiều quét kế tiếp (Vào / Ra), lý do từ chối (thẻ khóa/mất, vé tháng hết hạn, bãi đầy) và ghi chú cảnh báo an ninh; kèm hồ sơ thẻ, hợp đồng vé tháng và lượt gửi đang mở.
- **Khối 2 · Bảng đèn tín hiệu cổng vào** (`v_BotCong_BangDenCong`): đèn 🟢 / 🟡 / 🔴 theo từng loại phương tiện, số ô trống, ô đỗ gợi ý và đơn giá niêm yết.
- **Khối 3 · Xe chờ ra cổng** (`v_BotCong_XeChoRa`): số phút đỗ, số block giờ tính phí, tiền tạm tính và cảnh báo lệch biển số so với vé tháng.
- **Khối 4 · Nhật ký sự kiện qua barrier** (`v_BotCong_NhatKyVaoRa`): dòng sự kiện Vào / Ra mới nhất kèm thời gian lưu bãi và số tiền thực thu.

Hỗ trợ lọc theo từng chi nhánh bãi đỗ hoặc xem toàn chuỗi.

---

## 📊 6. Danh mục Báo cáo Quản trị (`/reports`)

### 6a. 5 Views báo cáo BI

1. `vw_Report_CongSuatBaiDo`: Sức chứa, số lượng đang gửi, chỗ trống, tỷ lệ lấp đầy từng bãi.
2. `vw_Report_DoanhThuTheoBai`: Doanh thu xe lượt, doanh thu vé tháng và tổng doanh thu phân bổ.
3. `vw_Report_XeDangDoHienTai`: Danh sách chi tiết toàn bộ phương tiện đang có mặt trong chuỗi.
4. `vw_Report_VeThangSapHetHan`: Danh sách khách hàng và phương tiện cần gửi thông báo gia hạn vé.
5. `vw_Report_NhatKySuCo`: Tổng hợp biên bản mất thẻ và số tiền phạt đền bù thu được.

### 6b. 7 Views vận hành realtime

Trang `/reports` liệt kê thêm 7 view vận hành, bấm vào từng thẻ để xem dữ liệu thô qua route `/report/<view_name>`:

1. `v_BotCong_TraCuuThe`: Quyết định mở barrier khi quét thẻ tại bốt cổng.
2. `v_BotCong_XeChoRa`: Xe đang trong bãi kèm tiền tạm tính khi ra cổng.
3. `v_BotCong_NhatKyVaoRa`: 200 sự kiện xe qua barrier mới nhất.
4. `v_BotCong_BangDenCong`: Đèn tín hiệu CÒN CHỖ / HẾT CHỖ tại cổng vào.
5. `v_SodoBai_ODoChiTiet`: Chi tiết từng ô đỗ trên sơ đồ mặt bằng.
6. `v_SodoBai_TongHopKhuVuc`: Tổng hợp ô trống theo khu vực / tầng.
7. `v_SodoBai_TongQuanBai`: Tổng quan công suất và đối soát bộ đếm từng bãi.
