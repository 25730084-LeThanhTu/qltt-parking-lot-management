# 📋 TÀI LIỆU HƯỚNG DẪN THUYẾT TRÌNH & DEMO ĐỒ ÁN (DEMO GUIDE)
## HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING MANAGEMENT)
> **Môn học:** Quản lý Thông tin (IE103)  
> **Mục đích:** Hướng dẫn từng bước thao tác mượt mà khi bảo vệ đồ án trước giảng viên, kết hợp trực quan giữa Website Demo và câu lệnh truy vấn đối chứng trực tiếp dưới SQL Server Management Studio (SSMS).

---

## 🎯 PHẦN I: CÔNG TÁC CHUẨN BỊ TRƯỚC BUỔI BẢO VỆ

### 1. Khởi động Cơ sở Dữ liệu SQL Server
1. Mở **SQL Server Management Studio (SSMS)**, kết nối tới SQL Server Server.
2. Mở file script tổng hợp: [sql/QL_BaiDoXe_FullScript.sql].
3. Bấm **Execute (F5)** để khởi tạo database `QuanLyBaiDoXe`, 9 bảng dữ liệu, các thủ tục, trigger, function, cursor, views và dữ liệu mẫu ban đầu.
4. Mở thêm 1 cửa sổ Query trắng mới dưới SSMS, gõ `USE QuanLyBaiDoXe;` để sẵn sàng chạy các câu lệnh đối chứng.

### 2. Hướng dẫn Cấu hình Kết nối Cơ sở Dữ liệu (File `.env`)

Hệ thống kết nối trực tiếp SQL Server thông qua thư viện `pyodbc`. Bạn cấu hình các thông số kết nối trong file `.env` tại thư mục gốc của dự án:

#### 🔹 Trường hợp A: Sử dụng Windows Authentication (Chạy SQL Server cục bộ trên Windows)
Dành cho máy tính cá nhân cài đặt SQL Server trên Windows không dùng mật khẩu sa:
```env
SQLSERVER_DRIVER=ODBC Driver 17 for SQL Server
SQLSERVER_SERVER=localhost
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=yes
SQLSERVER_USERNAME=
SQLSERVER_PASSWORD=
ALLOW_RUN_FULL_SCRIPT=1
PORT=5000
```
> *Lưu ý về `SQLSERVER_SERVER`: Có thể là `localhost`, `127.0.0.1`, hoặc tên instance cụ thể như `.\SQLEXPRESS`, `.\SQL2019` tùy theo cấu hình máy của bạn.*

#### 🔹 Trường hợp B: Sử dụng SQL Server Authentication (Tài khoản `sa`)
Dành cho trường hợp đăng nhập bằng username/password SQL Server hoặc chạy SQL Server qua Docker (Azure SQL Edge trên macOS M1/M2/M3):
```env
SQLSERVER_DRIVER=ODBC Driver 17 for SQL Server
SQLSERVER_SERVER=localhost,1433
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=no
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=YourPassword123!
ALLOW_RUN_FULL_SCRIPT=1
PORT=5000
```

#### 🔹 Lưu ý về Driver ODBC:
- Hệ thống hỗ trợ cả `ODBC Driver 17 for SQL Server` và `ODBC Driver 18 for SQL Server`.
- Nếu máy bạn cài Driver 18, chỉ cần đổi dòng đầu thành `SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server` (mã nguồn backend đã tự động tích hợp cờ `TrustServerCertificate=yes` nên không lo lỗi SSL Certificate).

#### 🔹 Kiểm tra Kết Nối Database Nhanh:
Sau khi khởi chạy website, bạn mở trình duyệt và truy cập vào đường dẫn:
```text
http://127.0.0.1:5000/health
```
Nếu màn hình hiển thị bảng **"Kết nối thành công"** kèm tên CSDL `QuanLyBaiDoXe`, thời gian `ServerTime` và phiên bản SQL Server thì cấu hình kết nối đã hoàn toàn chính xác 100%!

---

### 3. Khởi chạy Ứng dụng Web Demo
Mở Terminal tại thư mục `qltt-parking-lot-management` và chạy:
```bash
# Kích hoạt môi trường ảo
source .venv/bin/activate

# Chạy web server Flask
python run.py
```
Mở trình duyệt truy cập: **`http://127.0.0.1:5000`**

### 4. Bố trí Màn hình khi Thuyết trình
- **Nửa màn hình bên trái:** Trình duyệt Web hiển thị giao diện Website Demo.
- **Nửa màn hình bên phải:** Cửa sổ SSMS để chạy câu lệnh SQL kiểm chứng dữ liệu thay đổi thời gian thực.


---

## 🚀 PHẦN II: KỊCH BẢN THUYẾT TRÌNH CHI TIẾT 9 BƯỚC DEMO SONG HÀNH

---

### 🔹 Kịch bản 1: Quản lý Check-In xe vào cổng bãi (`sp_XeVaoBai`)
- **Đường dẫn Web:** `/demo/sp-xe-vao-bai`
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
  5. **Điểm nhấn đặc biệt:** Mở tab menu **"🗺️ Sơ Đồ Bãi Xe"** (`/map`), chọn bãi Quận 1 $\rightarrow$ Ô đỗ `Q1_XM_01` đã chuyển sang màu **Đỏ (Đã đỗ)** kèm hiển thị biển số xe `59A-123.45`.

---

### 🔹 Kịch bản 2: Quản lý Check-Out xe & Tự động Tính phí (`sp_XeRaBai`)
- **Đường dẫn Web:** `/demo/sp-xe-ra-bai`
- **Mục tiêu thuyết trình:** Chứng minh tính toán phí lũy tiến tự động theo block giờ bằng Function, cập nhật giờ ra và giải phóng ô đỗ về màu xanh.
- **Các bước thực hiện:**
  1. **Bước 1:** Trình bày bài toán xe đang đỗ quét thẻ ra cổng.
  2. **Bước 2:** Bấm nút **"B4 - Thực Thi Câu Lệnh"**.
  3. **Bước 3:** Quan sát bảng Output: Tiền gửi được tính toán chính xác (`TienGuiThucThu`), thời gian ra được ghi nhận.
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
- **Đường dẫn Web:** `/demo/sp-dang-ky-thanh-vien`
- **Mục tiêu thuyết trình:** Minh họa tính toàn vẹn dữ liệu qua cơ chế Transaction của CSDL.
- **Quy trình 4 thao tác liên hoàn trong 1 Transaction:**
  1. Tạo hồ sơ khách hàng mới (`KHACH_HANG`).
  2. Chuyển đổi trạng thái thẻ chip từ thẻ Lượt sang thẻ Tháng (`THE_XE`).
  3. Sinh mã vé tháng mới và tính hạn dùng 3 tháng (`VE_THANG`).
  4. Tính tiền và lập hóa đơn thu tiền tương ứng (`HOA_DON_VE_THANG`).
- **Thao tác:** Bấm nút thực thi trên Web $\rightarrow$ Chỉ cho giảng viên thấy cả 4 bảng đều đồng thời xuất hiện dòng dữ liệu mới ăn khớp nhau tuyệt đối.

---

### 🔹 Kịch bản 4: Gia hạn thời hạn vé tháng (`sp_GiaHanTheThang`)
- **Đường dẫn Web:** `/demo/sp-gia-han-ve-thang`
- **Mục tiêu:** Khách hàng nộp tiền gia hạn thêm 2 tháng.
- **Thao tác:** Bấm nút thực thi $\rightarrow$ So sánh cột `NgayHetHan` ở bảng B3 và B5: Hạn sử dụng được cộng thêm đúng 60 ngày, và một hóa đơn mới được thêm vào `HOA_DON_VE_THANG`.

---

### 🔹 Kịch bản 5: Báo mất thẻ & Phạt đền bù tự động (`sp_BaoMatThe`)
- **Đường dẫn Web:** `/demo/sp-bao-mat-the`
- **Mục tiêu:** Chứng minh sự can thiệp tức thì của **Trigger** `trg_LogLichSuSuCo`.
- **Thao tác:** Bấm nút thực thi báo mất thẻ `THE0001`:
  - Thẻ đổi sang trạng thái `Mất`.
  - Trigger tự động bắt sự kiện `UPDATE` trên bảng `THE_XE`, tự chèn một dòng biên bản sự cố vào `LICHSU_SU_CO` và áp tiền phạt `50.000 ₫` mà backend không cần viết thêm câu INSERT nào.

---

### 🔹 Kịch bản 6: Trigger chặn Check-In thẻ lỗi hoặc bãi đầy (`trg_KiemTraCheckIn`)
- **Đường dẫn Web:** `/demo/trigger-chan-checkin-loi`
- **Mục tiêu:** Chứng minh cơ chế bảo vệ toàn vẹn và bẫy lỗi tự động của CSDL.
- **Thao tác:** Cố tình dùng thẻ `THE0006` (thẻ đã báo mất) để quét vào cổng.
- **Giải thích trước giảng viên:**
  - Trên Web sẽ xuất hiện khối thông báo màu đỏ: `Lỗi: Thẻ xe đang bị khóa hoặc báo mất. Không thể check-in! (Lỗi 50002)`.
  - **Nhấn mạnh:** *Lỗi này không phải là lỗi lập trình website, mà là kết quả chặn có chủ đích của Trigger dưới CSDL để bảo vệ an ninh bãi xe.*
  - Dưới SSMS: Số lượng lượt gửi trong `LUOT_GUI` không hề tăng lên (giao dịch đã bị `ROLLBACK TRANSACTION`).

---

### 🔹 Kịch bản 7: Trigger chặn xe tháng quá hạn (`trg_ChanSuDungVeHetHan`)
- **Đường dẫn Web:** `/demo/trigger-chan-ve-het-han`
- **Mục tiêu:** Xe sử dụng thẻ tháng `THE0008` (vé `V0003` đã hết hạn) quét check-in.
- **Kết quả:** Trigger phát hiện ngày hiện tại lớn hơn `NgayHetHan`, lập tức hủy giao dịch và ném lỗi `50003` yêu cầu gia hạn nộp phí.

---

### 🔹 Kịch bản 8: Demo các Database Functions (`function-tinh-tien-slot`)
- **Đường dẫn Web:** `/demo/function-tinh-tien-slot`
- **Mục tiêu:** Trình bày 3 hàm chức năng viết bằng T-SQL:
  1. `dbo.f_TinhTienGuiXe`: Tính thử phí gửi ô tô đỗ 5 tiếng tại Landmark 81 (`5 x 30.000 = 150.000 ₫`).
  2. `dbo.f_TimSlotTrong`: Dò tìm ô đỗ xe máy còn trống tại Quận 1.
  3. `dbo.f_DanhSachXeTrongBai`: Hàm trả về bảng (Table-valued) danh sách toàn bộ xe đang gửi tại bãi.

---

### 🔹 Kịch bản 9: Demo Cursors duyệt dữ liệu (`cursor-canh-bao-doanh-thu`)
- **Đường dẫn Web:** `/demo/cursor-canh-bao-doanh-thu`
- **Mục tiêu:** Trình diễn 2 con trỏ dữ liệu chuyên sâu:
  1. `sp_DemoCanhBaoHanTheThang`: Con trỏ duyệt từng vé tháng $\rightarrow$ tự động khóa các thẻ quá hạn, gửi cảnh báo các thẻ sắp hết hạn trong 3 ngày tới.
  2. `sp_DemoTongKetDoanhThuChuoi`: Con trỏ duyệt qua từng bãi xe $\rightarrow$ cộng dồn doanh thu lượt + doanh thu tháng $\rightarrow$ xuất bảng xếp hạng và đánh giá hiệu quả kinh doanh của từng chi nhánh.

---

## 🖥️ PHẦN III: HƯỚNG DẪN DEMO CÁC MÀN HÌNH QUẢN TRỊ

1. **Sơ đồ Ô đỗ Xe trực quan (`/map`):**
   - Giới thiệu khả năng lọc linh hoạt giữa 3 bãi xe.
   - Thể hiện thanh đo công suất và tỷ lệ lấp đầy.
   - Minh họa sự thay đổi màu sắc ô đỗ real-time khi phối hợp với các thao tác Check-in / Check-out.
2. **Tra cứu 9 Bảng Dữ liệu (`/tables`):**
   - Nhấn vào từng bảng (`BAI_DO_XE`, `LOAI_XE`, `VI_TRI_DO`, `VE_THANG`, `LUOT_GUI`,...) để cho giảng viên thấy dữ liệu được load trực tiếp từ SQL Server kèm định dạng tiền tệ VND chuyên nghiệp.
3. **Báo cáo Thống kê (`/reports`):**
   - Giới thiệu 5 Views báo cáo thống kê phục vụ quản lý cấp cao.
   - Nếu có ảnh Dashboard Tableau/PowerBI đặt trong `reports_screenshots/`, website sẽ hiển thị trực quan đồ họa ngay phía trên bảng dữ liệu.
4. **Trình Chạy SQL Trực Tiếp (`/sql`):**
   - Cho phép gõ bất kỳ câu lệnh T-SQL nào mà thầy/cô yêu cầu kiểm tra ngay tại buổi bảo vệ (ví dụ: `SELECT * FROM dbo.f_DanhSachXeTrongBai('BAI_Q1');`) và xem kết quả tức thì.
5. **Công cụ Khởi tạo CSDL (`/setup`):**
   - Nếu muốn làm mới lại dữ liệu từ đầu sau nhiều lần thử nghiệm, chỉ cần truy cập `/setup` và nhấn nút nạp lại toàn bộ database.

---

## 🏆 KẾT LUẬN & ĐÁNH GIÁ TỔNG QUAN

Hệ thống đáp ứng trọn vẹn mọi yêu cầu khắt khe của môn học:
- ✅ CSDL chuẩn hóa, phân tách chuỗi bãi xe rạch ròi.
- ✅ Đầy đủ 5 Stored Procedures, 5 Database Triggers, 3 User-Defined Functions, 2 Cursors, 5 Views.
- ✅ Tương tác dữ liệu thời gian thực 100%, không lưu sẵn dữ liệu tĩnh ở backend.
- ✅ Giao diện Web trực quan, hiện đại, có Sơ đồ bãi xe realtime hỗ trợ thuyết trình bảo vệ đạt điểm tối đa.
