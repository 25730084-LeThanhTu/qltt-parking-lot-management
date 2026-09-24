# 📋 TÀI LIỆU HƯỚNG DẪN THUYẾT TRÌNH & DEMO ĐỒ ÁN (DEMO GUIDE V6)
## HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING MANAGEMENT)
> **Môn học:** Quản lý Thông tin (IE103)  
> **Kiến trúc:** SQL Server (Docker / Local) + Python Backend (Flask / pyodbc) + Modern Responsive Dashboard  
> **Mục đích:** Hướng dẫn từng bước thao tác mượt mà khi bảo vệ đồ án trước giảng viên, kết hợp trực quan giữa Website Demo và câu lệnh truy vấn đối chứng trực tiếp dưới SQL Server Management Studio (SSMS).

---

## 🎯 PHẦN I: CÔNG TÁC CHUẨN BỊ TRƯỚC BUỔI BẢO VỆ

### 1. Khởi động Cơ sở Dữ liệu SQL Server & Khởi Tạo Dữ Liệu
1. Đảm bảo dịch vụ SQL Server hoặc Container Docker SQL Server đang chạy:
   ```bash
   # Kiểm tra container Docker
   docker ps
   # Nếu container tắt, khởi động lại:
   docker start <ten_container>
   ```
2. **Khởi tạo CSDL 11 bảng:** Có 2 cách thực hiện:
   - **Cách 1 (Khuyên dùng - Nhanh nhất):** Khởi chạy web, truy cập trang **`http://127.0.0.1:5001/setup`**, hệ thống tự kiểm tra kết nối thành công $\rightarrow$ nhấn nút **"🔄 Bắt Đầu Nạp Lại Toàn Bộ CSDL"**. Toàn bộ 11 bảng, 6 procedures, 5 triggers, 3 functions, 2 cursors, 8 views và phân quyền RBAC sẽ được tạo tự động 100%.
   - **Cách 2 (Thủ công qua SSMS / DBeaver):** Mở file script tổng hợp [sql/QL_BaiDoXe_FullScript.sql](file:///Users/tult/Documents/ORTHER/Học%20Tập/2026/Kì%202/Quản%20lý%20thông%20tin/Đồ%20án/qltt-parking-lot-management/sql/QL_BaiDoXe_FullScript.sql) $\rightarrow$ Bấm **Execute (F5)**.
3. Mở thêm 1 cửa sổ Query trắng dưới SSMS, gõ `USE QuanLyBaiDoXe;` để sẵn sàng chạy các câu lệnh đối chứng số liệu trước/sau.

---

### 2. Cấu hình Kết Nối Cơ sở Dữ liệu (File `.env`)

Hệ thống kết nối trực tiếp SQL Server thông qua thư viện `pyodbc`. Bạn cấu hình các thông số kết nối trong file `.env` tại thư mục gốc của dự án:

#### 🔹 Trường hợp A: Sử dụng SQL Server Authentication (Tài khoản `sa` trên Docker hoặc Windows)
```env
SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server
SQLSERVER_SERVER=localhost,1433
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=no
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=Lethanhtu@1996
ALLOW_RUN_FULL_SCRIPT=1
PORT=5001
```

#### 🔹 Trường hợp B: Sử dụng Windows Authentication (Chạy SQL Server cục bộ trên Windows)
```env
SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server
SQLSERVER_SERVER=localhost
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=yes
SQLSERVER_USERNAME=
SQLSERVER_PASSWORD=
ALLOW_RUN_FULL_SCRIPT=1
PORT=5001
```

> **Lưu ý quan trọng về Driver & Chứng chỉ:**
> - Hệ thống hỗ trợ cả `ODBC Driver 17 for SQL Server` và `ODBC Driver 18 for SQL Server`.
> - Backend đã tích hợp sẵn cờ `TrustServerCertificate=yes` và cơ chế fallback thông minh qua database `master` nếu DB `QuanLyBaiDoXe` chưa được tạo lần đầu.

---

### 3. Màn Hình Tích Hợp: Kiểm Tra Kết Nối (Health) & Cài Đặt (Setup)

Hệ thống đã **gom toàn bộ quy trình kiểm tra kết nối và khởi tạo CSDL vào chung 1 màn hình duy nhất**:
👉 **URL:** **`http://127.0.0.1:5001/setup`** *(hoặc bấm tab "Kiểm Tra & Cài Đặt" trên thanh Menu)*

- **Trạng thái kết nối máy chủ (Health Check):**
  - Tự động hiển thị thẻ Xanh khi kết nối thành công: Tên Database, Thời gian máy chủ (`GETDATE()`), Host/Port, ODBC Driver, User và chuỗi phiên bản SQL Server.
  - Nếu mất kết nối: Hiển thị cảnh báo Đỏ, in chi tiết lỗi kỹ thuật và các bước khắc phục.
- **Cơ chế an toàn (Conditional Setup):**
  - **CHỈ KHI KIỂM TRA KẾT NỐI THÀNH CÔNG**, phần Khởi tạo CSDL mới được mở khóa hiển thị.
  - Ngăn ngừa hoàn toàn nguy cơ sinh viên thao tác nhầm khi máy chủ cơ sở dữ liệu chưa sẵn sàng.

---

### 4. Khởi chạy Ứng dụng Web Demo
Mở Terminal tại thư mục dự án và chạy:
```bash
# Kích hoạt môi trường ảo Python
source .venv/bin/activate

# Khởi chạy web server Flask (Cổng 5001)
python run.py
```
Mở trình duyệt truy cập: **`http://127.0.0.1:5001`**

### 5. Bố trí Màn hình Thuyết trình Chuẩn Chuyên Nghiệp
- **Nửa màn hình bên trái:** Trình duyệt Web hiển thị giao diện Website Demo (Dashboard, Map, Demo 5 Bước).
- **Nửa màn hình bên phải:** Cửa sổ SSMS để chạy câu lệnh SQL kiểm chứng dữ liệu thay đổi tức thì trước mắt giảng viên.

---

## 🚀 PHẦN II: KỊCH BẢN THUYẾT TRÌNH CHI TIẾT 9 BƯỚC DEMO SONG HÀNH

Tại màn hình **Tổng Quan (`/`)**, 9 kịch bản Demo được phân loại khoa học thành **dạng List Card chia theo 4 nhóm chuyên biệt**:
1. **⚙️ Nhóm Stored Procedures (5 kịch bản)**
2. **⚡ Nhóm Database Triggers (2 kịch bản)**
3. **📐 Nhóm Database Functions (1 kịch bản)**
4. **🔄 Nhóm Database Cursors (1 kịch bản)**

*(Có thanh tab filter nhanh `🔘 Tất Cả` | `⚙️ Procedure` | `⚡ Trigger` | `📐 Function` | `🔄 Cursor` để chuyển đổi mượt mà).*

---

### 🔹 Kịch bản 1: Quản lý Check-In xe vào cổng bãi (`sp_XeVaoBai`)
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-xe-vao-bai`
- **Mục tiêu thuyết trình:** Chứng minh quy trình xe vào tự động: hệ thống tiếp nhận thẻ $\rightarrow$ tự tìm ô trống khả dụng $\rightarrow$ tạo lượt gửi $\rightarrow$ Trigger tự động đổi màu ô đỗ và tăng công suất bãi.
- **Các bước thực hiện:**
  1. **Bước 1 (Giới thiệu bài toán):** Chỉ vào khung B1 trên Web, thuyết minh: *"Khi xe máy biển số 59A-123.45 quét thẻ THE0001 vào bãi Lê Lai (Q1), hệ thống sẽ tìm slot trống và cấp phát."*
  2. **Bước 2 (Kiểm tra dữ liệu ban đầu):** 
     - Trên Web: Xem bảng B3.
     - Dưới SSMS: Chạy lệnh:
       ```sql
       SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
       SELECT MaViTri, TrangThai FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' AND MaLoaiXe = 'XM';
       ```
  3. **Bước 3 (Thao tác):** Bấm nút **"▶️ B4 - Kích Hoạt Thực Thi Câu Lệnh"** trên Web.
  4. **Bước 4 (Đối chứng kết quả):**
     - Trên Web: Xem bảng Output (trả về mã lượt gửi và mã ô đỗ được cấp, ví dụ: `Q1_XM_01`).
     - Dưới SSMS: Chạy lại truy vấn:
       ```sql
       SELECT TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1'; -- Số lượng xe tăng thêm 1
       SELECT MaViTri, TrangThai FROM dbo.VI_TRI_DO WHERE MaViTri = 'Q1_XM_01'; -- Đã tự chuyển sang 'Đã đỗ'
       SELECT TOP 1 * FROM dbo.LUOT_GUI WHERE MaThe = 'THE0001' ORDER BY MaLuot DESC;
       ```
  5. **Điểm nhấn đặc biệt:** Mở tab menu **"🗺️ Sơ Đồ Mặt Bằng"** (`/map`), chọn bãi Quận 1 $\rightarrow$ Ô đỗ `Q1_XM_01` đã chuyển sang màu **Đỏ (Đã đỗ)** kèm hiển thị biển số xe `59A-123.45`.

---

### 🔹 Kịch bản 2: Quản lý Check-Out xe & Tự động Tính phí (`sp_XeRaBai`)
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-xe-ra-bai`
- **Mục tiêu thuyết trình:** Chứng minh tính toán phí lũy tiến tự động theo block giờ bằng Function, cập nhật giờ ra và giải phóng ô đỗ về màu xanh.
- **Các bước thực hiện:**
  1. **Bước 1:** Trình bày bài toán xe đang đỗ quét thẻ ra cổng.
  2. **Bước 2:** Bấm nút **"B4 - Thực Thi Câu Lệnh"**.
  3. **Bước 3:** Quan sát bảng Output: Tiền gửi được tính toán chính xác (`TienThu`), thời gian ra được ghi nhận.
  4. **Bước 4 (Đối chứng SSMS):**
     ```sql
     -- Ô đỗ đã được Trigger trả về 'Trống'
     SELECT MaViTri, TrangThai FROM dbo.VI_TRI_DO WHERE MaViTri = 'Q1_XM_02';
     -- Bãi xe giảm đi 1 xe
     SELECT TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
     ```
  5. **Mở lại `/map`:** Ô đỗ vừa giải phóng đã tự động chuyển từ màu Đỏ về màu **Xanh Lá (Trống)**.

---

### 🔹 Kịch bản 3: Đăng ký vé tháng bọc trong TRANSACTION (`sp_DangKyThanhVien`)
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-dang-ky-thanh-vien`
- **Mục tiêu thuyết trình:** Minh họa tính toàn vẹn dữ liệu qua cơ chế Transaction của CSDL.
- **Quy trình 4 thao tác liên hoàn trong 1 Transaction:**
  1. Tạo hồ sơ khách hàng mới (`KHACH_HANG`).
  2. Chuyển đổi trạng thái thẻ chip từ thẻ Lượt sang thẻ Tháng (`THE_XE`).
  3. Sinh mã vé tháng mới và tính hạn dùng 3 tháng (`VE_THANG`).
  4. Tính tiền và lập hóa đơn thu tiền tương ứng (`HOA_DON_VE_THANG`).
- **Thao tác:** Bấm nút thực thi trên Web $\rightarrow$ Cả 4 bảng đều đồng thời xuất hiện dòng dữ liệu mới ăn khớp nhau tuyệt đối.

---

### 🔹 Kịch bản 4: Gia hạn thời hạn vé tháng (`sp_GiaHanTheThang`)
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-gia-han-ve-thang`
- **Mục tiêu:** Khách hàng nộp tiền gia hạn thêm 2 tháng.
- **Thao tác:** Bấm nút thực thi $\rightarrow$ So sánh cột `NgayHetHan`: Hạn sử dụng được cộng thêm đúng 60 ngày, và một hóa đơn mới được thêm vào `HOA_DON_VE_THANG`.

---

### 🔹 Kịch bản 5: Báo mất thẻ & Phạt đền bù tự động (`sp_BaoMatThe`)
- **Nhóm đối tượng:** `⚙️ Procedure` + `⚡ Trigger` | **Đường dẫn Web:** `/demo/sp-bao-mat-the`
- **Mục tiêu:** Chứng minh sự can thiệp tức thì của **Trigger** `trg_LogLichSuSuCo`.
- **Thao tác:** Bấm nút thực thi báo mất thẻ `THE0001`:
  - Thẻ đổi sang trạng thái `Mất`.
  - Trigger tự động bắt sự kiện `UPDATE` trên bảng `THE_XE`, tự chèn một dòng biên bản sự cố vào `LICHSU_SU_CO` và áp tiền phạt `50.000 ₫` mà ứng dụng không cần viết thêm câu INSERT nào.

---

### 🔹 Kịch bản 6: Trigger chặn Check-In thẻ lỗi hoặc bãi đầy (`trg_KiemTraCheckIn`)
- **Nhóm đối tượng:** `⚡ Trigger` | **Đường dẫn Web:** `/demo/trigger-chan-checkin-loi`
- **Mục tiêu:** Chứng minh cơ chế bảo vệ toàn vẹn và bẫy lỗi tự động của CSDL.
- **Thao tác:** Cố tình dùng thẻ `THE0006` (thẻ đã báo mất) để quét vào cổng.
- **Giải thích trước giảng viên:**
  - Trên Web sẽ xuất hiện khối thông báo màu đỏ: `Lỗi: Thẻ xe đang bị khóa hoặc báo mất. Không thể check-in! (Lỗi 50002)`.
  - **Nhấn mạnh:** *Lỗi này không phải là lỗi code website, mà là kết quả chặn có chủ đích của Trigger dưới CSDL để bảo vệ an ninh.*
  - Dưới SSMS: Số lượng lượt gửi trong `LUOT_GUI` không đổi (giao dịch đã bị `ROLLBACK TRANSACTION`).

---

### 🔹 Kịch bản 7: Trigger chặn xe tháng quá hạn (`trg_ChanSuDungVeHetHan`)
- **Nhóm đối tượng:** `⚡ Trigger` | **Đường dẫn Web:** `/demo/trigger-chan-ve-het-han`
- **Mục tiêu:** Xe sử dụng thẻ tháng `THE0008` (vé `V0003` đã hết hạn) quét check-in.
- **Kết quả:** Trigger phát hiện ngày hiện tại lớn hơn `NgayHetHan`, lập tức hủy giao dịch và ném lỗi `50003` yêu cầu gia hạn nộp phí.

---

### 🔹 Kịch bản 8: Demo các Database Functions (`function-tinh-tien-slot`)
- **Nhóm đối tượng:** `📐 Function` | **Đường dẫn Web:** `/demo/function-tinh-tien-slot`
- **Mục tiêu:** Trình bày 3 hàm chức năng viết bằng T-SQL:
  1. `dbo.f_TinhTienGuiXe`: Tính thử phí gửi ô tô đỗ 5 tiếng tại Landmark 81 (`5 x 30.000 = 150.000 ₫`).
  2. `dbo.f_TimSlotTrong`: Dò tìm ô đỗ xe máy còn trống tại Quận 1.
  3. `dbo.f_DanhSachXeTrongBai`: Hàm trả về bảng (Table-valued) danh sách toàn bộ xe đang gửi tại bãi.

---

### 🔹 Kịch bản 9: Demo Cursors duyệt dữ liệu (`cursor-canh-bao-doanh-thu`)
- **Nhóm đối tượng:** `🔄 Cursor` | **Đường dẫn Web:** `/demo/cursor-canh-bao-doanh-thu`
- **Mục tiêu:** Trình diễn 2 con trỏ dữ liệu chuyên sâu:
  1. `sp_DemoCanhBaoHanTheThang`: Con trỏ duyệt từng vé tháng $\rightarrow$ tự động khóa các thẻ quá hạn, gửi cảnh báo các thẻ sắp hết hạn trong 3 ngày tới.
  2. `sp_DemoTongKetDoanhThuChuoi`: Con trỏ duyệt qua từng bãi xe $\rightarrow$ cộng dồn doanh thu lượt + doanh thu tháng $\rightarrow$ xuất bảng xếp hạng và đánh giá hiệu quả kinh doanh của từng chi nhánh.

---

## 🖥️ PHẦN III: HƯỚNG DẪN DEMO CÁC MÀN HÌNH QUẢN TRỊ NÂNG CAO

### 1. Sơ đồ Ô đỗ Xe trực quan thời gian thực (`/map`)
- Segmented control chuyển đổi linh hoạt giữa 3 chi nhánh (`BAI_Q1`, `BAI_Q3`, `BAI_BT`).
- Thanh đo công suất lấp đầy tự động tính toán từ CSDL.
- Trực quan hóa từng ô đỗ: Ô trống hiển thị màu Xanh lá dịu; Ô có xe hiển thị màu Đỏ thể thao kèm **Biển số xe dập nổi phản quang (`.license-plate`)** và thời gian đỗ.

### 2. Danh Mục 11 Bảng Dữ liệu Vật Lý (`/tables`)
- Toàn bộ 11 thực thể CSDL (bổ sung **`NHAN_VIEN`** và **`TAI_KHOAN`**) được phân loại rõ ràng với Badge chuyên nghiệp (`Master Data`, `Security & Auth`, `Human Resources`, `Transaction`,...).
- Bấm vào từng bảng để truy vấn 100 dòng dữ liệu thực tế từ CSDL.

### 3. Phân Hệ Bảo Mật & Xác Thực Nhân Sự (`sp_DangNhap`)
Hệ thống tích hợp bảng `NHAN_VIEN` và `TAI_KHOAN` với mật khẩu băm mã hóa HASH SHA-256 chuẩn quốc tế. Bạn có thể mở **SQL Runner (`/sql`)** để demo câu lệnh đăng nhập trước giảng viên:
```sql
-- Demo đăng nhập tài khoản Giám đốc (Mật khẩu đúng: Admin@2026)
EXEC dbo.sp_DangNhap @TenDangNhap = 'admin', @MatKhauPlain = 'Admin@2026';

-- Demo đăng nhập tài khoản Bảo vệ bãi Quận 1 (Mật khẩu: 123456)
EXEC dbo.sp_DangNhap @TenDangNhap = 'baove_q1', @MatKhauPlain = '123456';

-- Demo thử đăng nhập tài khoản bị khóa (Sẽ bị chặn và báo lỗi 50021)
EXEC dbo.sp_DangNhap @TenDangNhap = 'baove_khoa', @MatKhauPlain = '123456';
```

**Danh sách tài khoản demo có sẵn:**
| Tên Đăng Nhập | Mật Khẩu | Quyền Hạn / Vai Trò | Phạm Vi Phụ Trách | Trạng Thái |
| :--- | :--- | :--- | :--- | :--- |
| `admin` | `Admin@2026` | Giám đốc điều hành | Toàn hệ thống | Hoạt động |
| `quanly_q1` | `123456` | Quản lý bãi Lê Lai | Bãi Quận 1 (`BAI_Q1`) | Hoạt động |
| `quanly_q3` | `123456` | Quản lý bãi Hai Bà Trưng | Bãi Quận 3 (`BAI_Q3`) | Hoạt động |
| `quanly_bt` | `123456` | Quản lý bãi Landmark 81 | Bãi Bình Thạnh (`BAI_BT`) | Hoạt động |
| `baove_q1` | `123456` | Nhân viên bảo vệ trực cổng | Bãi Quận 1 (`BAI_Q1`) | Hoạt động |
| `baove_khoa` | `123456` | Nhân viên bảo vệ | Bãi Quận 1 (`BAI_Q1`) | **Bị khóa** |

### 4. Phân Quyền Vai Trò RBAC (Role-Based Access Control)
Chỉ cho giảng viên thấy file [sql/08_security_rbac.sql](file:///Users/tult/Documents/ORTHER/Học%20Tập/2026/Kì%202/Quản%20lý%20thông%20tin/Đồ%20án/qltt-parking-lot-management/sql/08_security_rbac.sql):
- **`r_Admin`**: Quyền quản trị tối cao (`GRANT CONTROL`).
- **`r_QuanLyBai`**: Quản lý nghiệp vụ bãi, xem và cập nhật ô đỗ, thẻ xe, vé tháng và xem toàn bộ views báo cáo.
- **`r_BaoVe`**: Chỉ được quét xe qua thủ tục `sp_XeVaoBai`, `sp_XeRaBai` và xem sơ đồ đỗ; **chặn tuyệt đối** quyền chỉnh sửa hay xóa tiền gửi và nhật ký xe (`DENY UPDATE, DELETE ON LUOT_GUI, HOA_DON_VE_THANG`).

### 5. Báo Cáo Phân Tích & Views Quản Trị (`/reports`)
- Hệ thống xây dựng đầy đủ 8 Views (3 Views vận hành Blueprint + 5 Views báo cáo BI).
- Tích hợp khung Dashboard Dark Frame hiển thị đồ họa phân tích kết hợp bảng dữ liệu thời gian thực.

### 6. Trình Chạy SQL Trực Tiếp (`/sql`)
- Studio T-SQL Editor với header mô phỏng file tab `query_runner.sql`.
- Tích hợp thanh **Quick Snippets** click 1 phát để điền nhanh các câu lệnh mẫu thường dùng, hỗ trợ chạy bất kỳ câu lệnh nào thầy/cô yêu cầu tại chỗ.

---

## 🏆 KẾT LUẬN & ĐIỂM NỔI BẬT ĂN ĐIỂM TỐI ĐA

1. **CSDL chuẩn hóa 11 bảng:** Đáp ứng trọn vẹn cả phân hệ quản lý vận hành lẫn phân hệ nhân sự & an toàn thông tin (mã hóa mật khẩu SHA-256).
2. **Đầy đủ 100% đối tượng nâng cao:** 6 Stored Procedures, 5 Triggers, 3 Functions, 2 Cursors, 8 Views, 3 Roles RBAC.
3. **Màn hình Health & Setup thông minh:** Tích hợp kiểm tra máy chủ và chỉ cho phép nạp CSDL khi kết nối thành công.
4. **Màn hình Tổng quan phân nhóm List Card:** Trình bày 9 kịch bản rõ ràng theo từng nhóm đối tượng CSDL kèm bộ lọc nhanh dạng Pills.
5. **Chuẩn thiết kế UI/UX hiện đại:** Sticky Topbar/Nav ghim cố định, toàn bộ khoảng cách padding/margin/border-radius ≤ 12px, responsive trên mọi thiết bị.
