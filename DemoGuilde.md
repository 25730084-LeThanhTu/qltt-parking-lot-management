# 📋 TÀI LIỆU HƯỚNG DẪN THUYẾT TRÌNH & DEMO ĐỒ ÁN (DEMO GUIDE V6)
## HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE THÔNG MINH (MULTI-SITE PARKING MANAGEMENT)
> **Môn học:** Quản lý Thông tin / Quản trị Cơ sở Dữ liệu (IE103)  
> **Kiến trúc:** Microsoft SQL Server 2022 (Docker / Local port 1433) + Python Backend (Flask / pyodbc port 5001) + Modern Responsive Dashboard UI  
> **Mục đích:** Cẩm nang chi tiết từng bước bảo vệ đồ án trước giảng viên, kết nối trực quan giữa **7 Bài toán thực tế** $\leftrightarrow$ **Thao tác Website Demo** $\leftrightarrow$ **Bộ lệnh T-SQL đối chứng song hành dưới SSMS**.

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
   - **Cách 1 (Khuyên dùng - Nhanh nhất trên Web):** Khởi chạy web, truy cập trang **`http://127.0.0.1:5001/setup`**, hệ thống tự kiểm tra kết nối thành công $\rightarrow$ nhấn nút **"🔄 Khởi Tạo Toàn Bộ CSDL (01-09)"**. Toàn bộ 11 bảng, 6 procedures, 5 triggers, 3 functions, 2 cursors, 15 views, phân quyền RBAC và kịch bản backup sẽ được dựng tự động 100% trong 3 giây.
   - **Cách 2 (Thủ công qua SSMS / Azure Data Studio):** Mở file script tổng hợp [sql/QL_BaiDoXe_FullScript.sql](file:///Users/tult/Documents/ORTHER/H%E1%BB%8Dc%20T%E1%BA%ADp/2026/K%C3%AC%202/Qu%E1%BA%A3n%20l%C3%BD%20th%C3%B4ng%20tin/%C4%90%E1%BB%93%20%C3%A1n/qltt-parking-lot-management/sql/QL_BaiDoXe_FullScript.sql) $\rightarrow$ Bấm **Execute (F5)**.
3. Mở thêm 1 cửa sổ Query trắng dưới SSMS, gõ `USE QuanLyBaiDoXe;` để sẵn sàng chạy các câu lệnh đối chứng số liệu trước/sau.

---

### 2. Cấu hình Kết Nối Cơ sở Dữ liệu (File `.env`)
Kiểm tra các thông số kết nối trong file `.env` tại thư mục gốc:

```env
SQLSERVER_DRIVER=ODBC Driver 18 for SQL Server
SQLSERVER_SERVER=localhost,1433
SQLSERVER_DATABASE=QuanLyBaiDoXe
SQLSERVER_TRUSTED_CONNECTION=no
SQLSERVER_USERNAME=sa
SQLSERVER_PASSWORD=Password123!
PORT=5001
```

> **Lưu ý kỹ thuật:** Backend đã tích hợp sẵn cờ `TrustServerCertificate=yes` và cơ chế fallback thông minh qua database `master` nếu DB `QuanLyBaiDoXe` chưa được tạo lần đầu.

---

### 3. Màn Hình Tích Hợp: Kiểm Tra Kết Nối (Health) & Cài Đặt (Setup)
👉 **URL:** **`http://127.0.0.1:5001/setup`** *(hoặc bấm nút "Cài Đặt CSDL" trên thanh Menu)*

- **Trạng thái kết nối máy chủ (Health Check):**
  - Tự động hiển thị thẻ Xanh khi kết nối thành công: Tên Database, Thời gian máy chủ (`GETDATE()`), Host/Port, ODBC Driver, User và chuỗi phiên bản SQL Server.
- **Cơ chế an toàn (Conditional Setup):**
  - **CHỈ KHI KIỂM TRA KẾT NỐI THÀNH CÔNG**, khối Khởi tạo CSDL mới được mở khóa hiển thị.
  - Ngăn ngừa hoàn toàn nguy cơ người dùng bấm cài đặt khi máy chủ cơ sở dữ liệu chưa sẵn sàng.

---

### 4. Khởi chạy Ứng dụng Web Demo
Mở Terminal tại thư mục dự án:
```bash
# Kích hoạt môi trường ảo Python
source .venv/bin/activate

# Khởi chạy web server Flask (Cổng 5001)
python run.py
```
Mở trình duyệt truy cập: **`http://127.0.0.1:5001`**

### 5. Bố trí Màn hình Thuyết trình Chuẩn Chuyên Nghiệp
- **Nửa màn hình bên trái:** Trình duyệt Web hiển thị giao diện Website Demo (Dashboard, Bốt Cổng, Sơ Đồ Bãi Xe, Demo 5 Bước).
- **Nửa màn hình bên phải:** Cửa sổ SSMS để chạy câu lệnh SQL kiểm chứng dữ liệu thay đổi tức thì trước mắt thầy/cô.

---

## 🚀 PHẦN II: KỊCH BẢN THUYẾT TRÌNH CHI TIẾT 9 BƯỚC DEMO SONG HÀNH

Tại màn hình **Tổng Quan (`/`)**, 10 kịch bản Demo được phân loại khoa học thành **dạng List Card chia theo 4 nhóm chuyên biệt**:
1. **⚙️ Nhóm Stored Procedures (5 kịch bản)**
2. **⚡ Nhóm Database Triggers (2 kịch bản)**
3. **📐 Nhóm Database Functions (1 kịch bản)**
4. **🔄 Nhóm Database Cursors (1 kịch bản)**

*(Có thanh tab filter nhanh `🔘 Tất Cả` | `⚙️ Procedure` | `⚡ Trigger` | `📐 Function` | `🔄 Cursor` để chuyển đổi mượt mà).*

---

### 🔹 Kịch bản 1: Quản lý Check-In xe vào cổng bãi (`sp_XeVaoBai`)
- **Bài toán thực tế giải quyết:** *Bài toán 1 - Kiểm soát Cổng Barrier & Tự động Cấp phát Ô đỗ.*
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-xe-vao-bai`
- **Mục tiêu thuyết trình:** Chứng minh quy trình xe vào tự động: tiếp nhận thẻ chip $\rightarrow$ tự tìm ô trống khả dụng bằng function $\rightarrow$ tạo lượt gửi $\rightarrow$ Trigger tự động đổi màu ô đỗ và tăng công suất bãi.
- **Các bước thực hiện:**
  1. **Bước 1 (Giới thiệu bài toán):** Chỉ vào khung B1 trên Web: *"Khi xe máy biển số 59T1-888.88 quét thẻ THE0003 vào bãi Lê Lai (Q1), hệ thống sẽ tìm slot trống và cấp phát."*
  2. **Bước 2 (Kiểm tra dữ liệu ban đầu):**
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
       SELECT TOP 1 * FROM dbo.LUOT_GUI WHERE MaThe = 'THE0003' ORDER BY MaLuot DESC;
       ```
  5. **Điểm nhấn ăn điểm:** Mở tab menu **"🗺️ Sơ Đồ Mặt Bằng"** (`/map`), chọn bãi Quận 1 $\rightarrow$ Ô đỗ `Q1_XM_01` đã tự động chuyển sang màu **Đỏ (Đã đỗ)** kèm hiển thị biển số xe `59T1-888.88`.

---

### 🔹 Kịch bản 2: Quản lý Check-Out xe & Tự động Tính phí (`sp_XeRaBai`)
- **Bài toán thực tế giải quyết:** *Bài toán 2 - Tính Phí Đỗ Xe Linh Hoạt & Chống Thất Thoát Doanh Thu.*
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-xe-ra-bai`
- **Mục tiêu thuyết trình:** Chứng minh tính toán phí lũy tiến tự động theo block giờ bằng Function `f_TinhTienGuiXe`, cập nhật giờ ra và giải phóng ô đỗ về màu xanh.
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
- **Bài toán thực tế giải quyết:** *Bài toán 3 - Quản lý Thuê bao Vé tháng & Toàn vẹn Giao dịch (ACID).*
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-dang-ky-thanh-vien`
- **Mục tiêu thuyết trình:** Minh họa tính toàn vẹn dữ liệu qua cơ chế Transaction của CSDL.
- **Quy trình 4 thao tác liên hoàn trong 1 Transaction:**
  1. Tạo hồ sơ khách hàng mới (`KHACH_HANG`). Không truyền `@MaKH` thì thủ tục tìm khách theo CMND/CCCD, chưa có thì sinh mã `KH####` tiếp theo. Email có thể để trống (chỉ bắt buộc duy nhất khi có giá trị).
  2. Chuyển đổi trạng thái thẻ chip từ thẻ Lượt sang thẻ Tháng (`THE_XE`).
  3. Sinh mã hợp đồng vé tháng `V####` tiếp theo (ví dụ `V0011`) và tính hạn dùng 3 tháng (`VE_THANG`).
  4. Tính tiền và lập hóa đơn `HD` + ngày + STT (ví dụ `HD20261005011`) trong `HOA_DON_VE_THANG`. Loại xe chưa có biểu phí tại bãi tính giá sẽ báo lỗi 50017 và rollback toàn bộ.
- **Thao tác:** Bấm nút thực thi trên Web $\rightarrow$ Cả 4 bảng đều đồng thời xuất hiện dòng dữ liệu mới ăn khớp nhau tuyệt đối. Nếu có bất kỳ lỗi nào xảy ra giữa chừng, toàn bộ 4 thao tác đều bị `ROLLBACK TRANSACTION`.

---

### 🔹 Kịch bản 4: Gia hạn thời hạn vé tháng (`sp_GiaHanTheThang`)
- **Bài toán thực tế giải quyết:** *Bài toán 3 - Quản lý Thuê bao Vé tháng.*
- **Nhóm đối tượng:** `⚙️ Procedure` | **Đường dẫn Web:** `/demo/sp-gia-han-ve-thang`
- **Mục tiêu:** Khách hàng nộp tiền gia hạn thêm 2 tháng.
- **Thao tác:** Bấm nút thực thi $\rightarrow$ So sánh cột `NgayHetHan`: Hạn sử dụng được cộng thêm đúng 2 tháng, và một hóa đơn mới được thêm vào `HOA_DON_VE_THANG`.
- **Quy tắc thu tiền:** Vé gắn một bãi chỉ gia hạn tại bãi áp dụng (truyền bãi khác báo lỗi 50018); vé `ALL` thu tại `@MaBaiGiaHan`, mặc định bãi phát hành thẻ. Thẻ đã báo mất không gia hạn được (lỗi 50019).

---

### 🔹 Kịch bản 5: Báo mất thẻ & Phạt đền bù tự động (`sp_BaoMatThe`)
- **Bài toán thực tế giải quyết:** *Bài toán 4 - Bảo mật Thẻ RFID, Xử lý Sự cố & Bồi thường Mất thẻ.*
- **Nhóm đối tượng:** `⚙️ Procedure` + `⚡ Trigger` | **Đường dẫn Web:** `/demo/sp-bao-mat-the`
- **Mục tiêu:** Chứng minh sự can thiệp tức thì của **Trigger** `trg_LogLichSuSuCo`.
- **Thao tác:** Bấm nút thực thi báo mất thẻ `THE0001`:
  - Thẻ đổi sang trạng thái `Mất`.
  - Trigger tự động bắt sự kiện `UPDATE` trên bảng `THE_XE`, tự chèn một dòng biên bản sự cố vào `LICHSU_SU_CO` và áp tiền phạt `50.000 ₫` mà ứng dụng không cần viết thêm câu INSERT nào.

---

### 🔹 Kịch bản 6: Trigger chặn Check-In thẻ lỗi hoặc bãi đầy (`trg_KiemTraCheckIn`)
- **Bài toán thực tế giải quyết:** *Bài toán 4 & 5 - An ninh bãi xe và Chặn nhận xe vượt công suất (Overbooking).*
- **Nhóm đối tượng:** `⚡ Trigger` | **Đường dẫn Web:** `/demo/trigger-chan-checkin-loi`
- **Mục tiêu:** Chứng minh cơ chế bảo vệ toàn vẹn và bẫy lỗi tự động của CSDL.
- **Thao tác:** Cố tình dùng thẻ `THE0006` (thẻ đã báo mất) để quét vào cổng.
- **Giải thích trước giảng viên:**
  - Trên Web xuất hiện thông báo lỗi màu đỏ: `Lỗi: Thẻ xe đang bị khóa hoặc báo mất. Không thể check-in! (Lỗi 50001)`.
  - **Nhấn mạnh:** *Lỗi này không phải là lỗi code website, mà là kết quả chặn có chủ đích của Trigger dưới CSDL để bảo vệ an ninh.*
  - Dưới SSMS: Số lượng lượt gửi trong `LUOT_GUI` không đổi (giao dịch đã bị `ROLLBACK TRANSACTION`).

---

### 🔹 Kịch bản 7: Trigger chặn xe tháng quá hạn (`trg_ChanSuDungVeHetHan`)
- **Bài toán thực tế giải quyết:** *Bài toán 3 - Chặn gian lận quẹt thẻ tháng hết hạn.*
- **Nhóm đối tượng:** `⚡ Trigger` | **Đường dẫn Web:** `/demo/trigger-chan-ve-het-han`
- **Mục tiêu:** Xe sử dụng thẻ tháng `THE0008` (vé `V0003` đã hết hạn) quét check-in.
- **Kết quả:** Trigger phát hiện ngày hiện tại lớn hơn `NgayHetHan`, lập tức hủy giao dịch và ném mã lỗi `50003: Vé tháng đã hết hạn sử dụng!`.

---

### 🔹 Kịch bản 7b: Trigger chặn vé tháng gửi sai bãi (`trg_KiemTraBaiApDungVeThang`)
- **Nhóm đối tượng:** `⚡ Trigger` | **Đường dẫn Web:** `/demo/trigger-chan-sai-bai`
- **Mục tiêu:** Thẻ tháng `THE0017` (vé `V0006` chỉ áp dụng tại `BAI_TB` - Tân Sơn Nhất) quét check-in tại bãi Lê Lai (`BAI_Q1`).
- **Kết quả:** Trigger so `MaBaiApDung` của vé với bãi đang check-in, hủy giao dịch và ném lỗi `50004`. Vé toàn chuỗi (`MaBaiApDung = 'ALL'`, ví dụ `V0004`) không bị chặn ở bất kỳ bãi nào.
- **Ghi chú định giá:** Vé `ALL` tính giá và ghi doanh thu tại bãi bán vé (`@MaBaiBan` của `sp_DangKyThanhVien`, mặc định là bãi phát hành thẻ).

---

### 🔹 Kịch bản 8: Demo các Database Functions (`function-tinh-tien-slot`)
- **Bài toán thực tế giải quyết:** *Bài toán 1 & 2 - Tính tiền lũy tiến và tìm slot tự động.*
- **Nhóm đối tượng:** `📐 Function` | **Đường dẫn Web:** `/demo/function-tinh-tien-slot`
- **Mục tiêu:** Trình bày 3 hàm chức năng viết bằng T-SQL:
  1. `dbo.f_TinhTienGuiXe`: Tính thử phí gửi ô tô đỗ 5 tiếng tại Landmark 81 (`5 x 30.000 = 150.000 ₫`).
  2. `dbo.f_TimSlotTrong`: Dò tìm ô đỗ xe máy còn trống tại Quận 1.
  3. `dbo.f_DanhSachXeTrongBai`: Hàm trả về bảng (Inline Table-valued) danh sách toàn bộ xe đang gửi tại bãi.

---

### 🔹 Kịch bản 9: Demo Cursors duyệt dữ liệu (`cursor-canh-bao-doanh-thu`)
- **Bài toán thực tế giải quyết:** *Bài toán 6 - Tự động hóa Vận hành Hàng ngày bằng Con trỏ CSDL.*
- **Nhóm đối tượng:** `🔄 Cursor` | **Đường dẫn Web:** `/demo/cursor-canh-bao-doanh-thu`
- **Mục tiêu:** Trình diễn 2 con trỏ dữ liệu chuyên sâu:
  1. `sp_DemoCanhBaoHanTheThang`: Con trỏ duyệt từng vé tháng $\rightarrow$ tự động khóa các thẻ quá hạn, gửi cảnh báo các thẻ sắp hết hạn trong 3 ngày tới.
  2. `sp_DemoTongKetDoanhThuChuoi`: Con trỏ duyệt qua từng bãi xe $\rightarrow$ cộng dồn doanh thu lượt + doanh thu tháng $\rightarrow$ xuất bảng xếp hạng và đánh giá hiệu quả kinh doanh của từng chi nhánh.

---

## 🖥️ PHẦN III: HƯỚNG DẪN DEMO CÁC MÀN HÌNH QUẢN TRỊ NÂNG CAO

### 🚦 1. Màn hình Bốt Kiểm Soát Cổng Vào / Ra (`/gate`) — [ĐIỂM NHẤN ĐẶC SẮC]
Màn hình này mô phỏng trọn vẹn bốt trực barrier thực tế của nhân viên bảo vệ, đọc trực tiếp từ 4 Views chuyên sâu:
- **Khối 1 · Quét thẻ tại barrier (`v_BotCong_TraCuuThe`):**
  - **Demo thẻ hợp lệ:** Nhập thẻ `THE0001` $\rightarrow$ Đèn xanh **MỞ BARRIER**, hiển thị hướng quét tiếp theo (Vào), loại xe, ô đỗ gợi ý.
  - **Demo thẻ lỗi:** Nhập thẻ `THE0006` $\rightarrow$ Đèn đỏ **TỪ CHỐI**, hiển thị nguyên nhân thẻ mất (Lỗi 50001).
- **Khối 2 · Bảng đèn tín hiệu cổng vào (`v_BotCong_BangDenCong`):**
  - Đèn tín hiệu giao thông 🟢 Còn chỗ / 🟡 Sắp đầy / 🔴 Hết chỗ theo từng loại xe (Xe máy, Ô tô, Xe đạp), hiển thị số ô trống và đơn giá niêm yết.
- **Khối 3 · Xe chờ ra cổng (`v_BotCong_XeChoRa`):**
  - Danh sách phương tiện đang trong bãi kèm số phút đã đỗ, số block giờ tính phí, số tiền tạm tính và cờ cảnh báo đỏ `CanhBaoLechBienSo` nếu phát hiện khách mượn thẻ người khác.
- **Khối 4 · Nhật ký sự kiện qua barrier (`v_BotCong_NhatKyVaoRa`):**
  - 200 sự kiện Vào/Ra mới nhất theo trục thời gian đối chiếu camera an ninh.

---

### 🗺️ 2. Sơ đồ Ô đỗ Xe trực quan thời gian thực (`/map`)
- Chuyển đổi linh hoạt giữa 3 chi nhánh (`BAI_Q1`, `BAI_Q3`, `BAI_BT`).
- Thanh đo công suất lấp đầy tự động tính toán từ View `v_SodoBai_TongQuanBai`.
- Trực quan hóa từng ô đỗ: Ô trống hiển thị màu Xanh lá dịu; Ô có xe hiển thị màu Đỏ thể thao kèm **Biển số xe dập nổi phản quang (`.license-plate`)** và thời gian đỗ.
- Dữ liệu được cấp bởi View `v_SodoBai_ODoChiTiet` và `v_SodoBai_TongHopKhuVuc`.

---

### 🗄️ 3. Danh Mục 11 Bảng Dữ liệu Vật Lý (`/tables`)
- Toàn bộ 11 thực thể CSDL (bao gồm **`NHAN_VIEN`** và **`TAI_KHOAN`**) được phân loại rõ ràng với Badge chuyên nghiệp (`Master Data`, `Security & Auth`, `Human Resources`, `Transaction`,...).
- Bấm vào từng bảng để truy vấn 100 dòng dữ liệu thực tế từ CSDL.

---

### 🔒 4. Phân Hệ Bảo Mật & Xác Thực Nhân Sự (`sp_DangNhap`)
Hệ thống băm mật khẩu mã hóa HASH SHA-256 chuẩn quốc tế. Mở **SQL Runner (`/sql`)** để demo đăng nhập:
```sql
-- Demo đăng nhập tài khoản Giám đốc (Mật khẩu đúng: Admin@2026)
EXEC dbo.sp_DangNhap @TenDangNhap = 'admin', @MatKhauPlain = 'Admin@2026';

-- Demo đăng nhập tài khoản Bảo vệ bãi Quận 1 (Mật khẩu: 123456)
EXEC dbo.sp_DangNhap @TenDangNhap = 'baove_q1', @MatKhauPlain = '123456';

-- Demo thử đăng nhập tài khoản bị khóa (Bị chặn báo lỗi 50021)
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
| `quanly_tb` | `123456` | Quản lý bãi TCP Park - Sân bay Tân Sơn Nhất | Bãi Tân Bình (`BAI_TB`) | Hoạt động |
| `quanly_q7` | `123456` | Quản lý bãi SC VivoCity | Bãi Quận 7 (`BAI_Q7`) | Hoạt động |
| `baove_tb` | `123456` | Nhân viên bảo vệ trực cổng | Bãi Tân Bình (`BAI_TB`) | Hoạt động |
| `baove_q7` | `123456` | Nhân viên bảo vệ trực cổng | Bãi Quận 7 (`BAI_Q7`) | Hoạt động |

---

### 🛡️ 5. Phân Quyền Vai Trò RBAC (Role-Based Access Control)
Chỉ cho giảng viên thấy file [sql/08_security_rbac.sql](file:///Users/tult/Documents/ORTHER/H%E1%BB%8Dc%20T%E1%BA%ADp/2026/K%C3%AC%202/Qu%E1%BA%A3n%20l%C3%BD%20th%C3%B4ng%20tin/%C4%90%E1%BB%93%20%C3%A1n/qltt-parking-lot-management/sql/08_security_rbac.sql):
- **`r_Admin`**: Quyền quản trị tối cao (`GRANT CONTROL`).
- **`r_QuanLyBai`**: Quản lý nghiệp vụ bãi, xem và cập nhật ô đỗ, thẻ xe, vé tháng và xem toàn bộ views báo cáo.
- **`r_BaoVe`**: Chỉ được quét xe qua thủ tục `sp_XeVaoBai`, `sp_XeRaBai` và xem sơ đồ đỗ; **chặn tuyệt đối** quyền chỉnh sửa hay xóa tiền gửi và nhật ký xe (`DENY UPDATE, DELETE ON LUOT_GUI, HOA_DON_VE_THANG`).

---

### 📊 6. Báo Cáo Phân Tích & Views Quản Trị BI (`/reports`)
- Hệ thống xây dựng đầy đủ **15 Views** (3 Views vận hành Blueprint + 5 Views báo cáo BI + 4 Views bốt kiểm soát cổng vào/ra + 3 Views sơ đồ bãi xe realtime).
- Tích hợp khung Dashboard Dark Frame hiển thị đồ họa phân tích kết hợp bảng dữ liệu thời gian thực.
- Sẵn sàng xuất báo cáo hoặc kết nối trực tiếp vào **Microsoft Power BI** và **Tableau**.

---

### 💻 7. Trình Chạy SQL Trực Tiếp (`/sql`)
- Studio T-SQL Editor với giao diện thanh lịch.
- Tích hợp thanh **Quick Snippets** click 1 phát để điền nhanh các câu lệnh mẫu thường dùng, hỗ trợ chạy bất kỳ câu lệnh nào thầy/cô yêu cầu tại chỗ.

---

## ❓ PHẦN IV: CÁC CÂU HỎI VẤN ĐÁP KINH ĐIỂN CỦA GIẢNG VIÊN & CÁCH TRẢ LỜI "ĂN ĐIỂM"

### 💬 Câu 1: Tại sao nhóm không tính tiền gửi xe ở Backend Python mà lại viết hàm `f_TinhTienGuiXe` dưới CSDL?
> **Trả lời:**  
> *"Dạ thưa Thầy/Cô, việc đẩy logic tính tiền xuống Scalar Function trong CSDL mang lại 3 lợi thế vượt trội:*  
> *1. **Nhất quán nghiệp vụ:** Bất kỳ ứng dụng nào kết nối vào CSDL (Web Flask, App di động của bảo vệ, máy POS cầm tay, hay công cụ BI) đều dùng chung một công thức tính tiền chuẩn xác, không bị tình trạng mỗi nền tảng code một kiểu.*  
> *2. **Bảo mật và chống gian lận:** Nhân viên không thể can thiệp sửa logic tính tiền ở tầng giao diện.*  
> *3. **Tối ưu hiệu năng:** CSDL tính toán trực tiếp trên tập dữ liệu mà không cần tải dữ liệu thô về tầng ứng dụng."*

---

### 💬 Câu 2: Trong kịch bản đăng ký vé tháng, nếu quá trình tạo hóa đơn bị lỗi thì dữ liệu trước đó có bị rác không?
> **Trả lời:**  
> *"Dạ không ạ. Toàn bộ 4 thao tác (tạo khách hàng, cập nhật thẻ, cấp vé tháng, xuất hóa đơn) được nhóm bọc trong một khối **SQL Transaction (`BEGIN TRANSACTION ... COMMIT TRANSACTION`)** với khối bẫy lỗi `BEGIN TRY ... BEGIN CATCH`. Nếu khâu xuất hóa đơn bị lỗi (ví dụ lỗi số tiền âm hoặc trùng mã), khối CATCH sẽ lập tức kích hoạt lệnh `ROLLBACK TRANSACTION`, hoàn tác 100% các dữ liệu đã chèn trước đó, bảo đảm tuyệt đối tính nguyên tử (Atomicity) theo chuẩn ACID."*

---

### 💬 Câu 3: Làm thế nào để nhóm ngăn chặn nhân viên bảo vệ thông đồng gian lận tiền gửi xe?
> **Trả lời:**  
> *"Dạ thưa Thầy/Cô, nhóm áp dụng giải pháp 3 lớp:*  
> *1. **Lớp RBAC tại CSDL:** Phân quyền vai trò `r_BaoVe` bị áp lệnh `DENY UPDATE, DELETE ON LUOT_GUI` và `HOA_DON_VE_THANG`. Bảo vệ chỉ có quyền quẹt thẻ qua Stored Procedure, không có quyền sửa hay xóa tiền.*  
> *2. **Lớp đối soát tự động:** View `v_BotCong_XeChoRa` tự động tính tiền tạm tính dựa trên thời gian vào thực tế và cắm cờ `CanhBaoLechBienSo` nếu biển số lúc ra khác biển số vé tháng.*  
> *3. **Lớp lưu vết sự cố:** Khi có mất thẻ, Trigger tự động ghi nhận vào `LICHSU_SU_CO` và áp tiền phạt 50.000 ₫ tự động."*

---

### 💬 Câu 4: Vì sao bảng `LOAI_XE` lại sử dụng Khóa chính hỗn hợp `(MaLoaiXe, MaBai)`?
> **Trả lời:**  
> *"Dạ thưa Thầy/Cô, đây là bài toán quản lý chuỗi nhiều bãi đỗ xe ở các vị trí khác nhau. Mặt bằng bãi xe tại Quận 1 có chi phí đầu tư cao hơn bãi ở Bình Thạnh, do đó cùng là loại xe máy (`XM`), đơn giá theo giờ và vé tháng tại Quận 1 phải cao hơn. Việc sử dụng Composite PK `(MaLoaiXe, MaBai)` cho phép mỗi chi nhánh bãi đỗ tự chủ biểu phí riêng biệt mà không cần tạo thêm nhiều bảng phân loại."*

---

## 🏆 PHẦN V: KẾT LUẬN & ĐIỂM NỔI BẬT ĂN ĐIỂM TỐI ĐA

1. **CSDL chuẩn hóa 11 bảng đạt chuẩn 3NF:** Đáp ứng trọn vẹn cả phân hệ quản lý vận hành lẫn phân hệ nhân sự & an toàn thông tin (mã hóa mật khẩu SHA-256).
2. **Đầy đủ 100% đối tượng nâng cao:** 6 Stored Procedures, 5 Triggers, 3 Functions, 2 Cursors, 15 Views, 3 Roles RBAC, kịch bản Full/Diff Backup & Restore.
3. **Màn hình Bốt Cổng (`/gate`) & Sơ đồ Realtime (`/map`):** Mô phỏng nghiệp vụ bãi xe thực tế với đèn tín hiệu barrier và biển số dập nổi phản quang chân thực.
4. **Màn hình Health & Setup thông minh:** Tích hợp kiểm tra máy chủ và chỉ cho phép nạp CSDL khi kết nối thành công.
5. **Màn hình Tổng quan phân nhóm List Card:** Trình bày 9 kịch bản rõ ràng theo từng nhóm đối tượng CSDL kèm bộ lọc nhanh dạng Pills.
6. **Chuẩn thiết kế UI/UX hiện đại:** Sticky Topbar/Nav ghim cố định, toàn bộ khoảng cách padding/margin/border-radius ≤ 12px, responsive trên mọi thiết bị.
