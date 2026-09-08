# BẢN THIẾT KẾ CƠ SỞ DỮ LIỆU VẬT LÝ & LẬP TRÌNH CSDL CHUYÊN SÂU: CHUỖI BÃI ĐỖ XE (V5)

Tài liệu này tập trung **duy nhất** vào thiết kế cơ sở dữ liệu vật lý (Data Schema) và đặc tả lập trình cơ sở dữ liệu chuyên sâu (Procedures, Triggers, Functions, Cursors) cho hệ thống **"Quản lý Chuỗi nhiều Bãi đỗ xe" (Multi-site Parking Management System)**.

Mô hình thiết kế đảm bảo dữ liệu của các bãi đỗ xe được phân tách rạch ròi, giải quyết trọn vẹn bài toán vận hành bãi xe thực tế và đáp ứng hoàn hảo các quy chế bảo vệ nghiêm ngặt của nhà trường (tương tác database thực thời, bẫy lỗi tự động, kịch bản demo song hành SSMS 5 bước).

---

## 🗄️ PHẦN I: THIẾT KẾ CẤU TRÚC VẬT LÝ CỦA CƠ SỞ DỮ LIỆU (9 BẢNG)

Hệ thống sử dụng **9 bảng dữ liệu** được chuẩn hóa cao độ, thiết lập các ràng buộc toàn vẹn, giá trị mặc định và cơ chế cô lập dữ liệu theo từng chi nhánh bãi đỗ cụ thể.

### 1. Bảng `BAI_DO_XE` (Thông tin các bãi đỗ xe trong chuỗi)
Quản lý danh sách các địa điểm bãi đỗ thuộc chuỗi hệ thống.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaBai` | `VARCHAR(10)` | **Primary Key** | Mã bãi đỗ xe (ví dụ: `BAI_Q1`, `BAI_Q3`, `BAI_BT`). |
| `TenBai` | `NVARCHAR(100)`| `NOT NULL`, `UNIQUE`| Tên hiển thị của bãi đỗ xe (ví dụ: *Bãi xe Lê Lai, Bãi xe Landmark 81*). |
| `DiaChi` | `NVARCHAR(255)`| `NOT NULL` | Địa chỉ vật lý của chi nhánh để định vị. |
| `SucChua` | `INT` | `NOT NULL` | Số lượng slot đỗ (sức chứa) tối đa. **Ràng buộc:** `CHECK (SucChua > 0)`. |
| `SoLuongHienTai`| `INT` | `NOT NULL`, `DEFAULT 0`| Số lượng xe thực tế đang gửi trong bãi. Tự động tăng/giảm qua Trigger. **Ràng buộc:** `CHECK (SoLuongHienTai >= 0 AND SoLuongHienTai <= SucChua)`. |

---

### 2. Bảng `LOAI_XE` (Phân loại phương tiện & Biểu phí chi tiết theo bãi)
Để giải quyết bài toán cùng một loại xe nhưng bãi đỗ ở trung tâm đắt hơn vùng ngoại ô, bảng này sử dụng **Khóa chính hỗn hợp (Composite Primary Key)** gồm `MaLoaiXe` và `MaBai`.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaLoaiXe` | `VARCHAR(10)` | **Composite PK** | Ký hiệu loại xe (ví dụ: `XM` - Xe máy, `OT` - Ô tô, `XD` - Xe đạp). |
| `MaBai` | `VARCHAR(10)` | **Composite PK**, **FK** | Liên kết đến `BAI_DO_XE(MaBai)`. Chỉ định bãi đỗ áp dụng biểu phí này. |
| `TenLoai` | `NVARCHAR(50)` | `NOT NULL` | Tên hiển thị loại xe (ví dụ: *Xe máy, Ô tô 4-7 chỗ*). |
| `DonGiaGio` | `DECIMAL(18,2)`| `NOT NULL` | Phí gửi xe lượt trên mỗi giờ (VND) tại bãi này. **Ràng buộc:** `CHECK (DonGiaGio > 0)`. |
| `GiaVeThang`| `DECIMAL(18,2)`| `NOT NULL` | Đơn giá đăng ký/gia hạn vé tháng (30 ngày) tại bãi này. **Ràng buộc:** `CHECK (GiaVeThang > 0)`. |

---

### 3. Bảng `VI_TRI_DO` (Sơ đồ mặt bằng các slot đỗ xe vật lý)
Quản lý vị trí của từng ô đỗ trong từng bãi xe cụ thể. Tham chiếu trực tiếp khóa ngoại hỗn hợp sang bảng `LOAI_XE` để đảm bảo ô đỗ đính kèm đúng loại xe cho phép tại bãi đó.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaViTri` | `VARCHAR(20)` | **Primary Key** | Mã vị trí đỗ duy nhất, định dạng: `MABAI_SLOT` (ví dụ: `Q1_A101`, `Q3_B202`). |
| `KhuVuc` | `NVARCHAR(20)` | `NOT NULL` | Phân khu vật lý trong bãi (ví dụ: *Khu A, Khu B, Tầng hầm 1*). |
| `TrangThai` | `NVARCHAR(20)` | `NOT NULL`, `DEFAULT N'Trống'`| Trạng thái ô đỗ. **Ràng buộc:** `CHECK (TrangThai IN (N'Trống', N'Đã đỗ'))`. |
| `MaLoaiXe` | `VARCHAR(10)` | **Foreign Key** | Kết hợp cùng `MaBai` làm khóa ngoại liên kết sang `LOAI_XE(MaLoaiXe, MaBai)`. |
| `MaBai` | `VARCHAR(10)` | **Foreign Key** | Liên kết `BAI_DO_XE(MaBai)`. |

---

### 4. Bảng `THE_XE` (Quản lý kho thẻ chip gửi xe theo bãi)
Để tránh nhầm lẫn và thất thoát thẻ vật lý, mỗi thẻ xe phải thuộc quyền sở hữu của một bãi đỗ xác định.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaThe` | `VARCHAR(10)` | **Primary Key** | Mã số thẻ quét vật lý (ví dụ: `THE0001`, `THE0002`). |
| `MaBai` | `VARCHAR(10)` | **Foreign Key** | Liên kết `BAI_DO_XE(MaBai)`. Xác định thẻ thuộc kho quản lý của bãi nào. |
| `LoaiThe` | `NVARCHAR(10)` | `NOT NULL` | Hình thức thẻ. **Ràng buộc:** `CHECK (LoaiThe IN (N'Lượt', N'Tháng'))`. |
| `TrangThai` | `NVARCHAR(20)` | `NOT NULL`, `DEFAULT N'Hoạt động'`| Tình trạng thẻ. **Ràng buộc:** `CHECK (TrangThai IN (N'Hoạt động', N'Bị khóa', N'Mất'))`. |
| `NgayCap` | `DATE` | `NOT NULL`, `DEFAULT GETDATE()`| Ngày nạp thẻ chip này vào hệ thống của bãi xe. |

---

### 5. Bảng `KHACH_HANG` (Hồ sơ chủ xe đăng ký vé tháng)
Lưu giữ thông tin cá nhân của các thành viên đăng ký dịch vụ gửi xe định kỳ hàng tháng.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaKH` | `VARCHAR(10)` | **Primary Key** | Mã số định danh khách hàng (ví dụ: `KH0001`, `KH0002`). |
| `HoTen` | `NVARCHAR(100)`| `NOT NULL` | Họ tên đầy đủ của chủ xe đăng ký. |
| `SDT` | `VARCHAR(15)` | `NOT NULL`, `UNIQUE`| Số điện thoại liên hệ chính chủ. |
| `Email` | `VARCHAR(100)` | `NULL`, `UNIQUE` | Email nhận thông tin cảnh báo hết hạn vé tháng. |
| `CMND_CCCD` | `VARCHAR(12)` | `NOT NULL`, `UNIQUE`| Số căn cước công dân phục vụ công tác an ninh bãi xe. |

---

### 6. Bảng `VE_THANG` (Bản đăng ký vé xe tháng)
Thông tin đăng ký vé tháng của phương tiện. Hỗ trợ đỗ tại 1 bãi nhất định hoặc toàn bộ các bãi trong chuỗi (`MaBaiApDung = 'ALL'`).

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaVe` | `VARCHAR(10)` | **Primary Key** | Mã số vé đăng ký tháng (ví dụ: `V0001`, `V0002`). |
| `MaThe` | `VARCHAR(10)` | **Foreign Key**, **UNIQUE**| Liên kết `THE_XE(MaThe)`. Đảm bảo 1 thẻ tháng tại 1 thời điểm chỉ gắn với 1 vé tháng. |
| `MaKH` | `VARCHAR(10)` | **Foreign Key** | Liên kết `KHACH_HANG(MaKH)`. Người sở hữu vé tháng. |
| `BienSo` | `VARCHAR(15)` | `NOT NULL` | Biển số xe đăng ký. Hệ thống sẽ so khớp biển này lúc check-in. |
| `MaLoaiXe` | `VARCHAR(10)` | **Foreign Key** | Liên kết sang bảng `LOAI_XE` (kết hợp với `MaBaiApDung` để áp dụng biểu phí nếu cần). |
| `NgayDangKy` | `DATE` | `NOT NULL`, `DEFAULT GETDATE()`| Ngày làm hợp đồng kích hoạt vé tháng. |
| `NgayHetHan` | `DATE` | `NOT NULL` | Ngày hết hạn. Phải lớn hơn ngày đăng ký. |
| `TrangThai` | `NVARCHAR(20)` | `NOT NULL`, `DEFAULT N'Hoạt động'`| Tình trạng vé. **Ràng buộc:** `CHECK (TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Hết hạn'))`. |
| `MaBaiApDung`| `VARCHAR(10)` | `NOT NULL` | Xác định bãi xe áp dụng. Gán mã bãi cụ thể (ví dụ: `BAI_Q1`) hoặc giá trị đặc biệt `'ALL'` (Được phép đỗ ở bất kỳ bãi nào). |

---

### 7. Bảng `LUOT_GUI` (Nhật ký kiểm soát xe vào/ra chi tiết theo bãi)
Lưu lịch sử chi tiết mọi lượt xe ra vào để phục vụ tính phí gửi xe và giám sát an ninh hệ thống.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaLuot` | `INT` | **Primary Key** | Mã lượt gửi xe tự tăng (`IDENTITY` / `AUTO_INCREMENT`). |
| `MaThe` | `VARCHAR(10)` | **Foreign Key** | Liên kết `THE_XE(MaThe)`. Thẻ dùng để quét check-in/out. |
| `BienSo` | `VARCHAR(15)` | `NOT NULL` | Biển số xe nhận dạng qua camera lúc xe vào bãi. |
| `ThoiGianVao`| `DATETIME` | `NOT NULL`, `DEFAULT GETDATE()`| Thời điểm xe quét thẻ vào bãi đỗ. |
| `ThoiGianRa` | `DATETIME` | `NULL` | Thời điểm xe quét thẻ ra bãi. `NULL` nếu xe đang đỗ trong bãi. |
| `MaViTri` | `VARCHAR(20)` | **Foreign Key** | Liên kết `VI_TRI_DO(MaViTri)`. Ô đỗ cụ thể được cấp cho xe này. |
| `TienGui` | `DECIMAL(18,2)`| `NOT NULL`, `DEFAULT 0`| Số tiền thực thu khi xe ra bãi (0 VND đối với xe tháng). **Ràng buộc:** `CHECK (TienGui >= 0)`. |
| `MaBai` | `VARCHAR(10)` | **Foreign Key** | Liên kết `BAI_DO_XE(MaBai)`. Ghi nhận giao dịch phát sinh tại bãi nào. |

---

### 8. Bảng `HOA_DON_VE_THANG` (Lịch sử đóng tiền gia hạn vé tháng theo bãi)
Theo dõi các khoản doanh thu thu được từ việc đóng tiền đăng ký và gia hạn vé tháng của khách hàng tại bãi cụ thể.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaHD` | `VARCHAR(15)` | **Primary Key** | Mã hóa đơn thanh toán (ví dụ: `HD20260907001`). |
| `MaVe` | `VARCHAR(10)` | **Foreign Key** | Liên kết `VE_THANG(MaVe)`. Hóa đơn thuộc về vé tháng nào. |
| `NgayThanhToan`| `DATETIME` | `NOT NULL`, `DEFAULT GETDATE()`| Thời điểm thực hiện thanh toán giao dịch. |
| `SoThangGiaHan`| `INT` | `NOT NULL`, `DEFAULT 1`| Số tháng đóng tiền trước. **Ràng buộc:** `CHECK (SoThangGiaHan > 0)`. |
| `SoTien` | `DECIMAL(18,2)`| `NOT NULL` | Tổng số tiền đóng. **Ràng buộc:** `CHECK (SoTien > 0)`. |
| `MaBai` | `VARCHAR(10)` | **Foreign Key** | Liên kết `BAI_DO_XE(MaBai)`. Xác định doanh thu thuộc về bãi nào đứng ra gia hạn. |

---

### 9. Bảng `LICHSU_SU_CO` (Nhật ký xử lý sự cố tại từng bãi xe)
Lưu vết các trường hợp mất thẻ xe, va chạm, mất mát tài sản xảy ra tại từng địa điểm bãi đỗ xe.

| Tên trường (Attribute) | Kiểu dữ liệu | Ràng buộc / Khóa | Mô tả chi tiết & Quy tắc nghiệp vụ |
| :--- | :--- | :--- | :--- |
| `MaSuCo` | `INT` | **Primary Key** | Mã sự cố tự động tăng (`IDENTITY`). |
| `MaThe` | `VARCHAR(10)` | **Foreign Key**, `NULL` | Liên kết `THE_XE(MaThe)`. Mã thẻ xe liên quan (nếu có). |
| `BienSo` | `VARCHAR(15)` | `NULL` | Biển số xe liên quan trực tiếp đến sự cố (nếu có). |
| `ThoiGianSuCo`| `DATETIME` | `NOT NULL`, `DEFAULT GETDATE()`| Thời gian ghi nhận sự việc xảy ra. |
| `MoTa` | `NVARCHAR(500)`| `NOT NULL` | Biên bản mô tả sự cố và phương án xử lý thực tế của bảo vệ. |
| `TienPhat` | `DECIMAL(18,2)`| `NOT NULL`, `DEFAULT 0`| Số tiền xử phạt hoặc đền bù thiệt hại (VND). **Ràng buộc:** `CHECK (TienPhat >= 0)`. |
| `TrangThaiXuLy`| `NVARCHAR(50)` | `NOT NULL`, `DEFAULT N'Chờ xử lý'`| Tiến trình xử lý. **Ràng buộc:** `CHECK (TrangThaiXuLy IN (N'Chờ xử lý', N'Đang giải quyết', N'Đã giải quyết'))`. |
| `MaBai` | `VARCHAR(10)` | **Foreign Key** | Liên kết `BAI_DO_XE(MaBai)`. Chỉ định sự cố xảy ra tại bãi đỗ xe nào trong hệ thống chuỗi. |

---

## 💻 PHẦN II: LẬP TRÌNH CSDL CHUYÊN SÂU & KỊCH BẢN DEMO SONG HÀNH SSMS (5 BƯỚC BẮT BUỘC)

Nhằm đáp ứng tiêu chí thuyết trình đồ án trực quan, các đối tượng lập trình dưới database (Procedures, Triggers, Functions, Cursors) phải được demo kết hợp giữa thao tác nút bấm bình thường trên Website và việc truy vấn kiểm chứng dữ liệu thủ công dưới SSMS (SQL Server Management Studio).

### 1. STORED PROCEDURES (5 PROCEDURES)

#### 1.1. `sp_XeVaoBai` (Quản lý Check-In xe vào bãi)
*   **Phát biểu bài toán:** Khi có xe đi vào cổng của một bãi xe, hệ thống tiếp nhận thẻ và biển số. Procedure kiểm tra tính hợp lệ của thẻ xe, sau đó tự động gọi Function `f_TimSlotTrong` để tìm ô đỗ khả dụng tại bãi đó. Cuối cùng, tạo bản ghi lượt gửi mới và đánh dấu ô đỗ là `'Đã đỗ'`.
*   **Các bảng liên quan:** `THE_XE` (Đọc), `BAI_DO_XE` (Đọc), `VI_TRI_DO` (Cập nhật), `LUOT_GUI` (Chèn mới).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Cho xe máy biển số `29A-12345` quét thẻ `THE0001` đi vào bãi `BAI_Q1`.
    *   **B2 (SQL Định nghĩa):** `EXEC sp_XeVaoBai @MaThe = 'THE0001', @BienSo = '29A-12345', @MaBai = 'BAI_Q1';`
    *   **B3 (Trước thực thi - SSMS):** Chạy truy vấn kiểm chứng trạng thái ban đầu:
        ```sql
        SELECT TrangThai, SoLuongHienTai FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1';
        SELECT * FROM LUOT_GUI WHERE MaThe = 'THE0001' AND ThoiGianRa IS NULL;
        SELECT MaViTri, TrangThai FROM VI_TRI_DO WHERE MaBai = 'BAI_Q1' AND MaLoaiXe = 'XM';
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ click nút **"Xác Nhận Check-In"** trên Giao diện bốt kiểm soát cổng vào của Website.
    *   **B5 (Sau thực thi - SSMS):** Chạy truy vấn kiểm chứng dữ liệu đã tự cập nhật:
        ```sql
        -- Kiểm tra bãi đỗ tăng số lượng xe gửi lên 1
        SELECT TenBai, SoLuongHienTai FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1';
        -- Kiểm tra lượt gửi mới được tạo kèm ô đỗ được phân bổ tự động
        SELECT * FROM LUOT_GUI WHERE MaThe = 'THE0001' AND ThoiGianRa IS NULL;
        -- Kiểm tra ô đỗ đó đã đổi trạng thái sang 'Đã đỗ' (trên website ô này cũng sẽ tự đổi sang màu đỏ realtime)
        SELECT MaViTri, TrangThai FROM VI_TRI_DO WHERE MaViTri = (SELECT MaViTri FROM LUOT_GUI WHERE MaThe = 'THE0001' AND ThoiGianRa IS NULL);
        ```

#### 1.2. `sp_XeRaBai` (Quản lý Check-Out xe ra bãi)
*   **Phát biểu bài toán:** Khi xe di chuyển ra cổng, bảo vệ quét thẻ xe. Procedure tự động đối chiếu thông tin lượt gửi hiện tại, gọi Function `f_TinhTienGuiXe` để tính toán số tiền thực thu, cập nhật thời gian ra, tính phí và tự động giải phóng ô đỗ cũ về lại trạng thái `'Trống'`.
*   **Các bảng liên quan:** `LUOT_GUI` (Cập nhật), `VI_TRI_DO` (Cập nhật), `BAI_DO_XE` (Cập nhật).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Xe máy dùng thẻ `THE0001` quét ra cổng bãi `BAI_Q1` sau khi đỗ 3 tiếng.
    *   **B2 (SQL Định nghĩa):** `EXEC sp_XeRaBai @MaThe = 'THE0001', @BienSoRa = '29A-12345';`
    *   **B3 (Trước thực thi - SSMS):** Chạy truy vấn xem thông tin lúc xe đang đỗ:
        ```sql
        SELECT * FROM LUOT_GUI WHERE MaThe = 'THE0001' AND ThoiGianRa IS NULL;
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ click nút **"Xác Nhận Check-Out"** trên Giao diện cổng ra của Website.
    *   **B5 (Sau thực thi - SSMS):** Chạy truy vấn xem kết quả hóa đơn và sự giải phóng ô đỗ:
        ```sql
        -- Xem lượt gửi đã cập nhật ThoiGianRa và số tiền gửi tính toán tự động chưa
        SELECT MaLuot, ThoiGianVao, ThoiGianRa, TienGui, MaViTri FROM LUOT_GUI WHERE MaThe = 'THE0001';
        -- Kiểm tra ô đỗ đã được trả về trạng thái 'Trống' (trên website sơ đồ bãi xe sẽ tự đổi ô này từ đỏ về xanh lá)
        SELECT MaViTri, TrangThai FROM VI_TRI_DO WHERE MaViTri = 'Q1_XM_01';
        -- Kiểm tra bãi đỗ đã giảm 1 xe hiện tại
        SELECT TenBai, SoLuongHienTai FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1';
        ```

#### 1.3. `sp_DangKyThanhVien` (Quản lý đăng ký vé tháng bọc trong TRANSACTION)
*   **Phát biểu bài toán:** Thực hiện quy trình đăng ký vé tháng cho khách hàng mới. Do quy trình này bao gồm nhiều thao tác ghi dữ liệu liên đới (Tạo thông tin khách hàng -> Đăng ký thông tin vé tháng gắn thẻ -> Xuất hóa đơn thu tiền), toàn bộ logic bắt buộc phải đặt trong một **Transaction** an toàn để đảm bảo tính nhất quán (nếu một bước lỗi thì toàn bộ dữ liệu sẽ được phục hồi lại như cũ).
*   **Các bảng liên quan:** `KHACH_HANG` (Chèn mới), `VE_THANG` (Chèn mới), `THE_XE` (Cập nhật), `HOA_DON_VE_THANG` (Chèn mới).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Đăng ký vé tháng cho khách hàng Nguyễn Văn A, số điện thoại `0901234567`, đăng ký cho xe máy `29A-99999` sử dụng thẻ `THE0002` tại bãi `BAI_Q1` đóng tiền trước 3 tháng.
    *   **B2 (SQL Định nghĩa):** 
        ```sql
        EXEC sp_DangKyThanhVien 
            @MaKH = 'KH0010', @HoTen = N'Nguyễn Văn A', @SDT = '0901234567', @CMND = '123456789012',
            @MaThe = 'THE0002', @BienSo = '29A-99999', @MaLoaiXe = 'XM', @MaBaiApDung = 'BAI_Q1', @SoThangDongTruoc = 3;
        ```
    *   **B3 (Trước thực thi - SSMS):** Kiểm tra xem khách hàng và thẻ xe đã được cấu hình trước chưa:
        ```sql
        SELECT * FROM KHACH_HANG WHERE MaKH = 'KH0010';
        SELECT MaThe, LoaiThe, TrangThai FROM THE_XE WHERE MaThe = 'THE0002';
        ```
    *   **B4 (Hành động kích hoạt):** Kế toán click nút **"Đăng Ký Thành Viên"** trên Form đăng ký vé tháng của Website.
    *   **B5 (Sau thực thi - SSMS):** Chạy truy vấn kiểm tra sự hoạt động của Transaction:
        ```sql
        -- Kiểm tra thông tin khách hàng mới được tạo
        SELECT * FROM KHACH_HANG WHERE MaKH = 'KH0010';
        -- Kiểm tra thẻ xe đã được chuyển đổi từ thẻ 'Lượt' sang thẻ 'Tháng'
        SELECT MaThe, LoaiThe FROM THE_XE WHERE MaThe = 'THE0002';
        -- Kiểm tra Vé tháng mới hoạt động kèm thời hạn dùng cộng thêm 90 ngày (3 tháng)
        SELECT MaVe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung FROM VE_THANG WHERE MaThe = 'THE0002';
        -- Kiểm tra Hóa đơn tài chính được xuất tự động tương ứng
        SELECT * FROM HOA_DON_VE_THANG WHERE MaVe = (SELECT MaVe FROM VE_THANG WHERE MaThe = 'THE0002');
        ```

#### 1.4. `sp_GiaHanTheThang` (Gia hạn thời hạn sử dụng vé tháng)
*   **Phát biểu bài toán:** Khi khách hàng đến bốt bảo vệ hoặc quầy kế toán để đóng tiền gia hạn, Procedure sẽ tiến hành cộng thêm thời gian sử dụng tương ứng vào cột `NgayHetHan` trong bảng `VE_THANG` và tự động lập một biên nhận giao dịch đóng tiền mới trong `HOA_DON_VE_THANG`.
*   **Các bảng liên quan:** `VE_THANG` (Cập nhật), `HOA_DON_VE_THANG` (Chèn mới).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Khách hàng sở hữu vé tháng `V0001` đến nộp tiền gia hạn thêm 2 tháng tại bãi `BAI_Q1`.
    *   **B2 (SQL Định nghĩa):** `EXEC sp_GiaHanTheThang @MaVe = 'V0001', @SoThangGiaHan = 2, @MaBaiGiaHan = 'BAI_Q1';`
    *   **B3 (Trước thực thi - SSMS):** Kiểm tra hạn sử dụng hiện tại của vé:
        ```sql
        SELECT MaVe, NgayHetHan, TrangThai FROM VE_THANG WHERE MaVe = 'V0001';
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ click nút **"Gia Hạn Vé"** trên màn hình Quản lý thành viên của Website.
    *   **B5 (Sau thực thi - SSMS):** Kiểm chứng hạn dùng đã tăng lên và hóa đơn được lưu:
        ```sql
        -- Kiểm tra ngày hết hạn của vé đã được cộng thêm 60 ngày thành công
        SELECT MaVe, NgayHetHan, TrangThai FROM VE_THANG WHERE MaVe = 'V0001';
        -- Kiểm tra hóa đơn đóng tiền tương ứng mới được tạo
        SELECT * FROM HOA_DON_VE_THANG WHERE MaVe = 'V0001' ORDER BY NgayThanhToan DESC;
        ```

#### 1.5. `sp_BaoMatThe` (Xử lý nghiệp vụ báo mất thẻ của khách hàng)
*   **Phát biểu bài toán:** Khi khách hàng thông báo bị mất thẻ vật lý, Procedure được gọi để lập tức vô hiệu hóa thẻ xe cũ (đổi trạng thái sang `'Mất'`), ghi nhận một sự việc trong `LICHSU_SU_CO`, áp phí phạt đền bù thẻ (mặc định 50,000 VND) và khóa thẻ vĩnh viễn trên hệ thống để tránh kẻ gian nhặt được đột nhập bãi xe.
*   **Các bảng liên quan:** `THE_XE` (Cập nhật), `LICHSU_SU_CO` (Chèn mới).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Khách hàng báo mất thẻ `THE0001` tại bãi `BAI_Q1`.
    *   **B2 (SQL Định nghĩa):** `EXEC sp_BaoMatThe @MaTheBaoMat = 'THE0001';`
    *   **B3 (Trước thực thi - SSMS):** Kiểm tra trạng thái thẻ ban đầu:
        ```sql
        SELECT MaThe, TrangThai FROM THE_XE WHERE MaThe = 'THE0001';
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ click nút **"Báo Mất Thẻ"** trên màn hình Danh sách thẻ của Website.
    *   **B5 (Sau thực thi - SSMS):** Kiểm chứng thẻ đã bị khóa và sự cố đã được lập biên bản:
        ```sql
        -- Kiểm tra thẻ xe chuyển trạng thái sang 'Mất'
        SELECT MaThe, TrangThai FROM THE_XE WHERE MaThe = 'THE0001';
        -- Kiểm tra nhật ký sự cố tự động ghi nhận biên bản và áp tiền phạt 50,000 VND
        SELECT * FROM LICHSU_SU_CO WHERE MaThe = 'THE0001' ORDER BY ThoiGianSuCo DESC;
        ```

---

### 2. DATABASE TRIGGERS (5 TRIGGERS)

#### 2.1. `trg_KiemTraCheckIn` (Chặn xe khi thẻ lỗi hoặc bãi đỗ đầy)
*   **Phát biểu bài toán (Nghiệp vụ):** Ngăn chặn việc thêm mới lượt gửi vào `LUOT_GUI` nếu thẻ xe đang ở trạng thái `'Bị khóa'` hoặc `'Mất'`. Đồng thời, nếu bãi xe nhận lệnh đã đầy công suất (`SoLuongHienTai >= SucChua`), Trigger tự động hủy giao dịch và ném ra thông báo lỗi chi tiết để bảo vệ đóng barrier.
*   **Các bảng liên quan:** `THE_XE` (Đọc), `BAI_DO_XE` (Đọc), `LUOT_GUI` (Chặn hành động chèn).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Thao tác check-in bằng thẻ `THE0001` đã bị chuyển trạng thái `'Mất'` ở mục 1.5, hệ thống phải tự động từ chối.
    *   **B2 (SQL Định nghĩa):** (Mã nguồn trigger chặn sự kiện `INSERT` trên bảng `LUOT_GUI`).
    *   **B3 (Trước thực thi - SSMS):** Kiểm chứng trạng thái lỗi của thẻ xe trước:
        ```sql
        SELECT MaThe, TrangThai FROM THE_XE WHERE MaThe = 'THE0001'; -- Thẻ đang bị 'Mất'
        ```
    *   **B4 (Hành động kích hoạt):** Trên Website, bảo vệ cố tình nhập mã thẻ `THE0001` đã mất và nhấn **"Check-In"**.
    *   **B5 (Sau thực thi - SSMS):** Thử chèn trực tiếp bằng lệnh dưới SSMS để hứng lỗi:
        ```sql
        -- Lệnh chèn sẽ thất bại hoàn toàn và ném ra lỗi RAISERROR từ Trigger
        -- INSERT INTO LUOT_GUI (MaThe, BienSo, MaViTri, MaBai) VALUES ('THE0001', '29A-12345', 'Q1_XM_01', 'BAI_Q1');
        -- Thông báo lỗi trả về: "Lỗi: Thẻ xe đang bị khóa hoặc báo mất. Không thể check-in!"
        -- Trên website, hộp thoại Alert màu đỏ của Tailwind cũng sẽ xuất hiện thông báo đúng câu lỗi này.
        ```

#### 2.2. `trg_ChanSuDungVeHetHan` (Chặn xe tháng quá hạn đóng tiền)
*   **Phát biểu bài toán (Nghiệp vụ):** Khi xe sử dụng thẻ tháng quét check-in, Trigger tự động đối chiếu thông tin thời hạn sử dụng `NgayHetHan` của vé tháng tương ứng trong bảng `VE_THANG`. Nếu ngày hiện tại vượt quá ngày hết hạn, Trigger tự động từ chối check-in và gửi cảnh báo yêu cầu nộp tiền gia hạn.
*   **Các bảng liên quan:** `VE_THANG` (Đọc), `LUOT_GUI` (Chặn hành động chèn).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Thẻ tháng `THE0002` gắn với vé tháng đã hết hạn sử dụng cố tình quét check-in để đi vào bãi.
    *   **B2 (SQL Định nghĩa):** (Mã nguồn trigger chặn sự kiện `INSERT` trên bảng `LUOT_GUI`).
    *   **B3 (Trước thực thi - SSMS):** Cố tình chỉnh ngày hết hạn của vé `V0001` về quá khứ để chạy thử nghiệm:
        ```sql
        UPDATE VE_THANG SET NgayHetHan = '2026-01-01' WHERE MaVe = 'V0001';
        SELECT MaVe, NgayHetHan, TrangThai FROM VE_THANG WHERE MaVe = 'V0001';
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ thực hiện thao tác quét thẻ tháng đã hết hạn trên giao diện kiểm soát cổng vào.
    *   **B5 (Sau thực thi - SSMS):** Thực thi lệnh chèn kiểm chứng dưới SSMS:
        ```sql
        -- Lệnh chèn thất bại, SQL Server văng lỗi: "Lỗi: Vé tháng này đã hết hạn sử dụng. Yêu cầu gia hạn đóng phí!"
        -- INSERT INTO LUOT_GUI (MaThe, BienSo, MaViTri, MaBai) VALUES ('THE0002', '29A-99999', 'Q1_XM_02', 'BAI_Q1');
        -- Trên màn hình website, thông báo Toast màu đỏ sẽ bật lên kèm yêu cầu gia hạn nộp tiền.
        ```

#### 2.3. `trg_DongBoTrangThaiSlot` (Tự động đồng bộ sơ đồ bãi xe thời gian thực)
*   **Phát biểu bài toán (Nghiệp vụ):** Để bãi xe vận hành tự động, khi một lượt gửi xe được tạo trong bảng `LUOT_GUI` (xe vào), Trigger phải tự động chuyển trạng thái của ô đỗ đính kèm trong `VI_TRI_DO` sang `'Đã đỗ'`, đồng thời tăng chỉ số `SoLuongHienTai` của bãi xe lên 1. Ngược lại, khi xe ra bãi (ThoiGianRa được cập nhật), Trigger tự trả ô đỗ về `'Trống'` và giảm chỉ số xe gửi trong bãi đi 1.
*   **Các bảng liên quan:** `LUOT_GUI` (Bắt sự kiện), `VI_TRI_DO` (Cập nhật), `BAI_DO_XE` (Cập nhật).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Xe máy check-in thành công vào vị trí đỗ `Q1_XM_01`.
    *   **B2 (SQL Định nghĩa):** (Trigger hoạt động sau sự kiện `INSERT` và `UPDATE` của bảng `LUOT_GUI`).
    *   **B3 (Trước thực thi - SSMS):** Kiểm tra hiện trạng ô đỗ và bãi xe:
        ```sql
        SELECT MaViTri, TrangThai FROM VI_TRI_DO WHERE MaViTri = 'Q1_XM_01'; -- Đang 'Trống'
        SELECT SoLuongHienTai FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1';
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ thực hiện bấm nút **"Xác Nhận Xe Vào"** thành công trên giao diện web.
    *   **B5 (Sau thực thi - SSMS):** Chạy lệnh kiểm chứng tự động đồng bộ dữ liệu:
        ```sql
        -- Kiểm tra ô đỗ đã tự động chuyển sang 'Đã đỗ' mà không cần bất cứ lệnh UPDATE thủ công nào từ code backend
        SELECT MaViTri, TrangThai FROM VI_TRI_DO WHERE MaViTri = 'Q1_XM_01'; -- Đã tự đổi thành 'Đã đỗ'
        -- Kiểm tra công suất bãi xe tự động tăng lên 1
        SELECT SoLuongHienTai FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1';
        -- Trên website, ô đỗ Q1_XM_01 trên sơ đồ sẽ tự động chuyển đổi từ màu xanh lá sang đỏ mượt mà nhờ Angular Signal nhận diện state mới.
        ```

#### 2.4. `trg_LogLichSuSuCo` (Tự động ghi nhận nhật ký khi báo mất thẻ)
*   **Phát biểu bài toán (Nghiệp vụ):** Để phục vụ báo cáo an ninh chặt chẽ, khi trạng thái của một thẻ xe trong bảng `THE_XE` bị thay đổi thành `'Mất'`, Trigger tự động can thiệp, khởi tạo một bản ghi biên bản xử lý sự cố trong bảng `LICHSU_SU_CO` và áp đặt số tiền phạt mất thẻ là 50,000 VND.
*   **Các bảng liên quan:** `THE_XE` (Bắt sự kiện `UPDATE`), `LICHSU_SU_CO` (Chèn tự động).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Thực hiện khóa thẻ báo mất `THE0003` tại bãi đỗ.
    *   **B2 (SQL Định nghĩa):** (Trigger bắt sự kiện `UPDATE` trường TrangThai trong bảng `THE_XE`).
    *   **B3 (Trước thực thi - SSMS):** Xem danh sách sự cố hiện tại của thẻ:
        ```sql
        SELECT * FROM LICHSU_SU_CO WHERE MaThe = 'THE0003'; -- Trống rỗng
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ nhấn nút **"Khóa Thẻ / Báo Mất"** trên màn hình quản lý kho thẻ của Website.
    *   **B5 (Sau thực thi - SSMS):** Kiểm tra xem Trigger dưới Database đã tự tạo biên bản phạt tiền chưa:
        ```sql
        -- Kiểm tra bảng sự cố đã tự động ghi nhận biên bản mất thẻ kèm mức phạt 50,000 VND
        SELECT * FROM LICHSU_SU_CO WHERE MaThe = 'THE0003';
        ```

#### 2.5. `trg_ChanXoaDuLieuDangDung` (Bảo vệ dữ liệu bãi xe và thẻ hoạt động)
*   **Phát biểu bài toán (Nghiệp vụ):** Ngăn chặn việc xóa thông tin của một bãi đỗ xe hoặc một thẻ xe ra khỏi hệ thống nếu bãi đỗ đó vẫn đang tồn tại các ô đỗ hoặc thẻ xe đó đang được sử dụng trong một lượt gửi xe chưa hoàn thành (chưa check-out).
*   **Các bảng liên quan:** `BAI_DO_XE` (Chặn xóa), `THE_XE` (Chặn xóa), `LUOT_GUI` (Đọc).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Admin cố tình xóa thông tin bãi xe `BAI_Q1` khi bãi đang có xe đỗ hoạt động.
    *   **B2 (SQL Định nghĩa):** (Trigger chặn sự kiện `DELETE` trên bảng `BAI_DO_XE` và `THE_XE`).
    *   **B3 (Trước thực thi - SSMS):** Kiểm chứng bãi đang có xe đỗ hoạt động:
        ```sql
        SELECT SoLuongHienTai FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1'; -- Lớn hơn 0
        ```
    *   **B4 (Hành động kích hoạt):** Admin click nút **"Xóa Bãi Xe"** trên giao diện cấu hình hệ thống của Website.
    *   **B5 (Sau thực thi - SSMS):** Chạy thử lệnh xóa trực tiếp dưới SSMS:
        ```sql
        -- Lệnh xóa thất bại hoàn toàn và ném lỗi: "Lỗi: Bãi đỗ xe đang có xe gửi hoạt động hoặc chứa ô đỗ. Không thể xóa!"
        -- DELETE FROM BAI_DO_XE WHERE MaBai = 'BAI_Q1';
        -- Giao diện quản trị Admin trên Web hiển thị Toast thông báo lỗi màu đỏ từ chối thao tác thành công.
        ```

---

### 3. DATABASE FUNCTIONS (3 FUNCTIONS)

#### 3.1. `f_TinhTienGuiXe` (Tính toán phí gửi xe lượt lũy tiến)
*   **Phát biểu bài toán:** Hàm Scalar nhận đầu vào là thời gian xe vào, thời gian xe ra, loại phương tiện và mã bãi xe để tính tiền gửi xe lượt. Phí được tính lũy tiến theo số giờ gửi thực tế nhân với đơn giá giờ `DonGiaGio` được quy định riêng tại bãi đó. *(Nếu xe đăng ký vé tháng hoạt động và đỗ đúng bãi áp dụng thì trả về 0 VND)*.
*   **Các bảng liên quan:** `LOAI_XE` (Đọc đơn giá giờ của từng bãi).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Một xe ô tô (`OT`) đỗ tại bãi `BAI_Q1` trong thời gian 5 tiếng.
    *   **B2 (SQL Định nghĩa):** 
        ```sql
        -- Tính toán trực tiếp phí gửi xe
        SELECT dbo.f_TinhTienGuiXe('2026-09-07 10:00:00', '2026-09-07 15:00:00', 'OT', 'BAI_Q1') AS TienGuiCalculated;
        ```
    *   **B3 (Trước thực thi - SSMS):** Kiểm tra đơn giá giờ của xe ô tô tại bãi Quận 1:
        ```sql
        SELECT DonGiaGio FROM LOAI_XE WHERE MaLoaiXe = 'OT' AND MaBai = 'BAI_Q1'; -- Kết quả ví dụ: 20,000 VND/giờ
        ```
    *   **B4 (Hành động kích hoạt):** Bảo vệ quét thẻ xe ra cổng, website tự động gọi API chạy hàm tính tiền hiển thị lên màn hình thanh toán.
    *   **B5 (Sau thực thi - SSMS):** Đối chiếu kết quả hiển thị trên Website với kết quả hàm tính toán:
        ```sql
        -- Phí gửi xe lượt tính toán: 5 giờ * 20,000 VND = 100,000 VND
        -- Con số 100,000 VND này phải khớp chính xác tuyệt đối với số tiền thanh toán hiện trên màn hình Web.
        ```

#### 3.2. `f_TimSlotTrong` (Tự động định vị trí ô đỗ trống khả dụng)
*   **Phát biểu bài toán:** Hàm Scalar nhận đầu vào là mã bãi đỗ xe và mã loại xe, tiến hành quét bảng vị trí đỗ `VI_TRI_DO` để tìm kiếm và trả về mã vị trí đỗ trống đầu tiên thuộc bãi xe đó để phân bổ cho xe mới vào.
*   **Các bảng liên quan:** `VI_TRI_DO` (Đọc trạng thái).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Tìm kiếm một vị trí đỗ xe ô tô còn trống tại bãi đỗ Quận 3 (`BAI_Q3`).
    *   **B2 (SQL Định nghĩa):** `SELECT dbo.f_TimSlotTrong('BAI_Q3', 'OT') AS SlotTrongKhaDung;`
    *   **B3 (Trước thực thi - SSMS):** Quét danh sách ô đỗ ô tô đang trống của bãi Quận 3 dưới SSMS:
        ```sql
        SELECT MaViTri, TrangThai FROM VI_TRI_DO WHERE MaBai = 'BAI_Q3' AND MaLoaiXe = 'OT' AND TrangThai = N'Trống';
        ```
    *   **B4 (Hành động kích hoạt):** Nhân viên click nút **"Quét Thẻ Vào"** trên màn hình check-in của Website.
    *   **B5 (Sau thực thi - SSMS):** Kết quả hàm trả về mã vị trí trống đầu tiên (ví dụ: `Q3_OT_05`). Vị trí này sẽ được hệ thống Python trích xuất đưa thẳng vào trường `MaViTri` của bảng `LUOT_GUI` và đồng thời hiển thị vị trí đỗ đề xuất lên màn hình của bảo vệ để hướng dẫn khách đỗ xe.

#### 3.3. `f_DanhSachXeTrongBai` (Kiểm soát chi tiết xe hiện diện tại bãi)
*   **Phát biểu bài toán:** Hàm Table-valued nhận đầu vào là mã bãi xe, thực hiện lọc bảng nhật ký `LUOT_GUI` để trả về danh sách chi tiết toàn bộ các xe hiện đang đỗ trong bãi (có thời gian vào nhưng chưa check-out).
*   **Các bảng liên quan:** `LUOT_GUI` (Đọc), `THE_XE` (Đọc).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Trích xuất danh sách tất cả các xe đang đỗ tại bãi Quận 1 (`BAI_Q1`).
    *   **B2 (SQL Định nghĩa):** `SELECT * FROM dbo.f_DanhSachXeTrongBai('BAI_Q1');`
    *   **B3 (Trước thực thi - SSMS):** Thống kê số lượng xe đang trong bãi:
        ```sql
        SELECT COUNT(*) FROM LUOT_GUI WHERE MaBai = 'BAI_Q1' AND ThoiGianRa IS NULL;
        ```
    *   **B4 (Hành động kích hoạt):** Quản lý bãi xe chọn bãi đỗ "Quận 1" trên thanh Dropdown giám sát của Website.
    *   **B5 (Sau thực thi - SSMS):** Hàm CSDL trả về bảng dữ liệu đầy đủ biển số, mã vị trí, thời điểm vào của từng xe. Bảng thông tin động này sẽ được render trực tiếp lên giao diện Dashboard của Website để quản lý giám sát mà không hề hardcode dữ liệu tĩnh.

---

### 4. DATABASE CURSORS (2 CURSORS BỌC TRONG PROCEDURES ĐỂ DEMO)

Để chạy demo Cursor trực tiếp, chúng ta sẽ bọc mã lệnh Cursor vào trong một Stored Procedure để gọi thực thi dễ dàng từ Website hoặc SSMS.

#### 4.1. `sp_DemoCanhBaoHanTheThang` (Quét cảnh báo hạn dùng vé tháng bằng CURSOR)
*   **Phát biểu bài toán:** Cursor quét tuần tự qua danh sách toàn bộ các vé tháng đang hoạt động trong bảng `VE_THANG`. Nếu vé có hạn dùng sắp hết (trong vòng 3 ngày tới), in ra thông báo cảnh báo nộp phí gia hạn. Nếu ngày hiện tại vượt quá ngày hết hạn, Cursor tự động cập nhật trạng thái vé sang `'Hết hạn'` và khóa thẻ xe tương ứng.
*   **Các bảng liên quan:** `VE_THANG` (Duyệt qua, Cập nhật), `THE_XE` (Cập nhật).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Thực hiện quét hệ thống kiểm tra và tự động khóa các thẻ tháng đã quá hạn nộp tiền gửi xe.
    *   **B2 (SQL Định nghĩa):** `EXEC sp_DemoCanhBaoHanTheThang;`
    *   **B3 (Trước thực thi - SSMS):** Xem danh sách vé đã quá ngày hiện tại nhưng chưa bị khóa:
        ```sql
        SELECT MaVe, NgayHetHan, TrangThai FROM VE_THANG WHERE NgayHetHan < GETDATE() AND TrangThai = N'Hoạt động';
        ```
    *   **B4 (Hành động kích hoạt):** Quản trị viên click nút **"Chạy Quét Hạn Thẻ"** trên màn hình Quản lý vận hành của Website.
    *   **B5 (Sau thực thi - SSMS):** Chạy lại truy vấn kiểm chứng dữ liệu đã được Cursor xử lý tự động:
        ```sql
        -- Kiểm tra các vé quá hạn đã bị Cursor cập nhật trạng thái sang 'Hết hạn' thành công
        SELECT MaVe, NgayHetHan, TrangThai FROM VE_THANG WHERE NgayHetHan < GETDATE();
        -- Đồng thời thẻ xe liên kết cũng tự động bị khóa để chặn check-in
        SELECT MaThe, TrangThai FROM THE_XE WHERE MaThe IN (SELECT MaThe FROM VE_THANG WHERE TrangThai = N'Hết hạn');
        -- Trong cửa sổ Console / Message của SSMS hiển thị danh sách dòng in ra của Cursor (PRINT) ghi nhận chi tiết lịch trình quét.
        ```

#### 4.2. `sp_DemoTongKetDoanhThuChuoi` (Thống kê tài chính bằng CURSOR)
*   **Phát biểu bài toán:** Cursor duyệt tuần tự qua từng bãi đỗ xe được đăng ký trong bảng `BAI_DO_XE`. Với mỗi bãi đỗ, Cursor tiến hành cộng gộp tổng số tiền thu được từ xe lượt (bảng `LUOT_GUI`) và xe tháng (bảng `HOA_DON_VE_THANG`) phát sinh trong tháng hiện tại, kết xuất ra bảng tổng hợp doanh thu chi tiết của toàn chuỗi bãi đỗ xe.
*   **Các bảng liên quan:** `BAI_DO_XE` (Duyệt qua), `LUOT_GUI` (Đọc doanh thu lượt), `HOA_DON_VE_THANG` (Đọc doanh thu tháng).
*   **Kịch bản Demo 5 bước song hành:**
    *   **B1 (Nghiệp vụ):** Xuất báo cáo tài chính thống kê so sánh hiệu quả kinh doanh giữa các bãi trong chuỗi.
    *   **B2 (SQL Định nghĩa):** `EXEC sp_DemoTongKetDoanhThuChuoi;`
    *   **B3 (Trước thực thi - SSMS):** Kiểm tra danh sách bãi xe và tổng tiền phát sinh ghi nhận trong bảng thô:
        ```sql
        SELECT MaBai, TenBai FROM BAI_DO_XE;
        SELECT MaBai, SUM(TienGui) FROM LUOT_GUI GROUP BY MaBai;
        SELECT MaBai, SUM(SoTien) FROM HOA_DON_VE_THANG GROUP BY MaBai;
        ```
    *   **B4 (Hành động kích hoạt):** Giám đốc click nút **"Xuất Báo Cáo Doanh Thu"** trên màn hình Kế toán quản trị của Website.
    *   **B5 (Sau thực thi - SSMS):** Cursor hoàn thành quét và in ra màn hình SSMS bảng doanh thu phân tích chi tiết từng bãi:
        ```text
        Bãi đỗ: Bãi xe Lê Lai (BAI_Q1) | Doanh thu lượt: 15,200,000 VND | Doanh thu tháng: 45,000,000 VND | TỔNG: 60,200,000 VND
        Bãi đỗ: Bãi xe Landmark 81 (BAI_BT) | Doanh thu lượt: 28,500,000 VND | Doanh thu tháng: 90,000,000 VND | TỔNG: 118,500,000 VND
        ----------------------------------------------------------------------------------------------------------------------
        TỔNG DOANH THU TOÀN CHUỖI: 178,700,000 VND
        ```
        *(Số liệu tổng hợp thống kê này sẽ được API nạp trực tiếp để vẽ biểu đồ trực quan hóa doanh thu trên giao diện Web mà không hardcode).*

---

## 📅 PHẦN III: LỘ TRÌNH TRIỂN KHAI PHÁT TRIỂN CSDL CHI TIẾT (ACTION CHEKLIST)

Dưới đây là danh sách các đầu việc lập trình thiết kế cơ sở dữ liệu vật lý chi tiết phân chia theo lộ trình phát triển của nhóm:

- [ ] **Bước 1: Khởi tạo CSDL Vật lý (`01_schema.sql`)**
    - [ ] Tạo bảng `BAI_DO_XE` kèm ràng buộc CHECK sức chứa.
    - [ ] Tạo bảng `LOAI_XE` thiết lập khóa chính hỗn hợp `(MaLoaiXe, MaBai)` để phân tách biểu phí bãi xe.
    - [ ] Tạo bảng `VI_TRI_DO` thiết lập ràng buộc khóa ngoại hỗn hợp trỏ trực tiếp sang `LOAI_XE`.
    - [ ] Tạo bảng `THE_XE` liên kết thẻ với bãi cụ thể và ràng buộc CHECK trạng thái thẻ.
    - [ ] Tạo các bảng `KHACH_HANG`, `VE_THANG`, `LUOT_GUI`, `HOA_DON_VE_THANG`, `LICHSU_SU_CO` cấu hình khóa chính và khóa ngoại liên kết chặt chẽ.
- [ ] **Bước 2: Cấu hình nạp dữ liệu mẫu (`02_sample_data.sql`)**
    - [ ] Viết lệnh INSERT nạp thông tin cho 3 bãi xe mẫu (`BAI_Q1`, `BAI_Q3`, `BAI_BT`).
    - [ ] Nạp biểu phí chi tiết cho xe máy và ô tô phân biệt theo từng bãi đỗ xe.
    - [ ] Thiết lập sơ đồ ô đỗ mẫu (15-20 ô đỗ) cho từng bãi.
    - [ ] Nạp thông tin khách hàng mẫu, vé tháng hoạt động/quá hạn và lịch sử đỗ xe để phục vụ demo.
- [ ] **Bước 3: Lập trình Stored Procedures (`03_procedures.sql`)**
    - [ ] Viết SP `sp_XeVaoBai` tích hợp hàm tìm ô trống tự động.
    - [ ] Viết SP `sp_XeRaBai` tích hợp hàm tính tiền theo block giờ.
    - [ ] Viết SP `sp_DangKyThanhVien` bọc trong TRANSACTION an toàn.
    - [ ] Viết SP `sp_GiaHanTheThang` cập nhật thời hạn dùng và xuất hóa đơn tự động.
    - [ ] Viết SP `sp_BaoMatThe` xử lý biên bản phạt mất thẻ.
- [ ] **Bước 4: Thiết lập Triggers nghiệp vụ (`04_triggers.sql`)**
    - [ ] Hoàn thiện `trg_KiemTraCheckIn` chặn thẻ mất/khóa hoặc bãi đỗ đã đầy.
    - [ ] Hoàn thiện `trg_ChanSuDungVeHetHan` chặn check-in xe tháng quá hạn đóng phí.
    - [ ] Viết `trg_DongBoTrangThaiSlot` tự động chuyển đổi trạng thái ô trống/đầy và cập nhật số lượng xe đỗ trong bãi.
    - [ ] Viết `trg_LogLichSuSuCo` tự động chèn nhật ký phạt tiền đền bù khi mất thẻ.
    - [ ] Viết `trg_ChanXoaDuLieuDangDung` chặn hành vi xóa thông tin bãi xe/thẻ đang vận hành.
- [ ] **Bước 5: Phát triển Functions & Cursors (`05_functions.sql` & `06_cursors.sql`)**
    - [ ] Viết Scalar Function `f_TinhTienGuiXe` tính phí đỗ xe lũy tiến.
    - [ ] Viết Scalar Function `f_TimSlotTrong` dò tìm ô đỗ trống theo loại phương tiện.
    - [ ] Viết Table Function `f_DanhSachXeTrongBai` trích xuất thông tin xe đang gửi.
    - [ ] Viết Cursor quét định kỳ gửi cảnh báo và tự động khóa vé tháng hết hạn.
    - [ ] Viết Cursor thống kê so sánh doanh thu chi tiết giữa các bãi xe trong hệ thống chuỗi.
- [ ] **Bước 6: Kiểm thử và Đồng bộ hóa**
    - [ ] Khởi chạy cơ sở dữ liệu trên container Docker (Azure SQL Edge) của Mac M1.
    - [ ] Đồng bộ script SQL Server để các thành viên khác nạp trực tiếp vào SQL Server local dưới máy Windows.
    - [ ] Tiến hành chạy thử nghiệm liên hoàn kịch bản demo 5 bước song hành dưới SSMS để chuẩn bị báo cáo bảo vệ đồ án.
