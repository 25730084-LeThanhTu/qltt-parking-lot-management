# HƯỚNG DẪN XÂY DỰNG BÁO CÁO BI (POWER BI / TABLEAU)

> Hệ thống quản lý chuỗi nhiều bãi đỗ xe – CSDL `QuanLyBaiDoXe` (SQL Server).
> Tài liệu hướng dẫn từng bước dựng **16 báo cáo BI** từ các view `vw_Report_*` trong `sql/07_views.sql`, kèm câu query, biểu đồ đề xuất, công thức tính và cách đọc kết quả.
> Tên view, tên cột trong tài liệu khớp đúng mã nguồn.

---

## MỤC LỤC

1. Tổng quan và kết quả cần đạt
2. Chuẩn bị môi trường
3. Kết nối nguồn dữ liệu
4. Quy ước chung khi dựng báo cáo
5. Danh mục 16 báo cáo
6. Hướng dẫn chi tiết từng báo cáo (R01 – R16)
7. Gợi ý bố cục dashboard tổng hợp
8. Truy vấn đối soát số liệu
9. Đưa ảnh dashboard lên website
10. Xử lý sự cố thường gặp

---

## 1. TỔNG QUAN VÀ KẾT QUẢ CẦN ĐẠT

**Nguyên tắc:** toàn bộ phép tính nghiệp vụ (doanh thu, tỷ lệ lấp đầy, xếp hạng, cảnh báo…) đã nằm sẵn trong các view của SQL Server. Công cụ BI **chỉ đọc view và trực quan hóa**, không tính lại logic nghiệp vụ. Nhờ vậy số liệu trên dashboard luôn khớp với số liệu trên website và trong SSMS.

**Kết quả cần nộp:**
- 16 báo cáo (mỗi báo cáo 1 trang / 1 sheet) trong một file Power BI (`.pbix`) hoặc Tableau (`.twbx`).
- 16 ảnh chụp dashboard, đặt tên đúng theo view (mục 9) và chép vào thư mục `reports_screenshots/` → website tự nhúng ảnh vào trang `/report/<tên view>`.
- (Tùy chọn) 3 dashboard tổng hợp: Điều hành, Tài chính – Ví, Vận hành – An ninh (mục 7).

---

## 2. CHUẨN BỊ MÔI TRƯỜNG

### 2.1. Cơ sở dữ liệu
1. SQL Server 2022 (tối thiểu 2017) đang chạy, ví dụ `localhost,1433`.
2. Đã nạp CSDL: chạy ứng dụng, mở `http://127.0.0.1:5001/setup` → "Kiểm tra kết nối" → "Khởi tạo Full CSDL" (hoặc chạy `sql/QL_BaiDoXe_FullScript.sql` trong SSMS).
3. Kiểm tra nhanh 16 view đã tồn tại:

```sql
USE QuanLyBaiDoXe;
SELECT name AS TenView
FROM sys.views
WHERE name LIKE 'vw[_]Report[_]%'
ORDER BY name;
-- Kết quả mong đợi: 16 dòng
```

### 2.2. Công cụ BI (chọn một)

| Công cụ | Hệ điều hành | Kết nối SQL Server trực tiếp | Ghi chú |
|---|---|---|---|
| Power BI Desktop | Chỉ Windows | Có | Miễn phí. Trên macOS cần máy ảo Windows |
| Tableau Desktop | Windows, macOS | Có | Cần license (sinh viên có thể xin Tableau for Students) |
| Tableau Public | Windows, macOS | **Không** | Miễn phí; phải xuất dữ liệu ra CSV / Excel trước (mục 3.4) |
| Excel (PivotChart) | Windows, macOS | Có (Windows), CSV (macOS) | Phương án dự phòng |

Cần thêm: **ODBC Driver 17/18 for SQL Server** (Power BI / Tableau trên Windows thường đã có sẵn driver).

### 2.3. Tài khoản đăng nhập SQL
- **Khi làm đồ án / demo:** dùng login chủ CSDL (ví dụ `sa`) – đọc được cả 16 view.
- **Nếu dùng login thuộc role `r_QuanLyBai`:** role này hiện chỉ được GRANT 10 / 16 view. 6 view sau sẽ báo lỗi 229 (permission denied): `vw_Report_DoanhThuTheoNgay`, `vw_Report_DoanhThuTheoThang`, `vw_Report_LuuLuongTheoGio`, `vw_Report_ThongKeTheoLoaiXe`, `vw_Report_XepHangBai`, `vw_Report_TongQuanChuoi`. Khi đó quản trị viên cần chạy thêm:

```sql
-- Chạy bằng tài khoản quản trị (chưa có trong sql/08_security_rbac.sql)
GRANT SELECT ON dbo.vw_Report_DoanhThuTheoNgay   TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_DoanhThuTheoThang  TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_LuuLuongTheoGio    TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_ThongKeTheoLoaiXe  TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_XepHangBai         TO r_QuanLyBai;
GRANT SELECT ON dbo.vw_Report_TongQuanChuoi      TO r_QuanLyBai;
```

### 2.4. Lưu ý về dữ liệu mẫu
- Dữ liệu mẫu nhỏ (5 bãi, khoảng 30 lượt gửi, khoảng 20 hóa đơn) nên một số biểu đồ khá thưa. Để có thêm dữ liệu, chạy các kịch bản demo trên website (check-in / check-out, đăng ký, gia hạn, nạp tiền…) trước khi chụp ảnh.
- Nhiều view dùng `GETDATE()` (số phút đã đỗ, số ngày còn lại, "hôm nay", "tháng này"), nên giá trị thay đổi theo thời điểm làm mới (refresh). Chụp ảnh sau khi refresh.
- Lượt gửi mẫu có mốc tương đối (vài giờ / vài ngày trước thời điểm nạp CSDL); hóa đơn mẫu có ngày cố định từ tháng 1/2026 và một số mốc tương đối.

---

## 3. KẾT NỐI NGUỒN DỮ LIỆU

### 3.1. Power BI Desktop
1. **Home → Get data → SQL Server**.
2. Server: `localhost,1433` (hoặc tên máy chủ của nhóm); Database: `QuanLyBaiDoXe`.
3. Data Connectivity mode:
   - **Import** (khuyên dùng cho đồ án: nhanh, chụp ảnh ổn định).
   - **DirectQuery** nếu muốn số liệu realtime (mỗi lần tương tác sẽ truy vấn lại SQL Server).
4. Mở **Advanced options** → dán câu query của từng báo cáo vào ô **SQL statement** (mỗi báo cáo một bảng riêng, đặt tên bảng theo mã R01…R16). Hoặc bỏ trống để chọn trực tiếp các view trong Navigator.
5. Authentication: chọn **Database**, nhập user / password SQL.
6. Nếu báo lỗi chứng chỉ: tick **Trust server certificate**.
7. Mỗi lần dữ liệu thay đổi: **Home → Refresh**.

### 3.2. Tableau Desktop
1. **Connect → To a Server → Microsoft SQL Server**.
2. Server `localhost,1433`, Database `QuanLyBaiDoXe`, Authentication: *Use a specific username and password*.
3. Trong Data Source: kéo view vào vùng làm việc, hoặc chọn **New Custom SQL** và dán câu query của báo cáo.
4. Chọn **Extract** (tương đương Import) hoặc **Live** (realtime).
5. Đặt tên data source theo mã báo cáo (R01_CongSuat, …).

### 3.3. Excel
**Data → Get Data → From Database → From SQL Server Database** → nhập server, database → Advanced options → dán query → Load → chèn PivotTable / PivotChart.

### 3.4. Xuất CSV cho Tableau Public (hoặc khi không kết nối trực tiếp được)
- **Cách khuyên dùng – SSMS / Azure Data Studio:** chạy query của báo cáo → chuột phải lưới kết quả → *Save Results As…* → CSV. Cách này tự bọc các ô có dấu phẩy (địa chỉ, mô tả sự cố) trong dấu nháy.
- **Dòng lệnh `bcp`** (có trong mssql-tools) – phù hợp với báo cáo chỉ có số và tên ngắn:

```bash
bcp "SELECT * FROM QuanLyBaiDoXe.dbo.vw_Report_DoanhThuTheoBai" queryout R02_DoanhThuTheoBai.csv \
    -c -t"|" -S localhost,1433 -U sa -P "<mat_khau>"
```

> `bcp` không bọc nháy cho ô chứa ký tự phân cách, vì vậy dùng `|` làm phân cách và khai báo delimiter `|` khi mở file trong Tableau / Excel. Trên Windows thêm tham số `-C 65001` để xuất UTF-8; khi mở file có tiếng Việt, chọn mã hóa UTF-8.

---

## 4. QUY ƯỚC CHUNG KHI DỰNG BÁO CÁO

| Nội dung | Quy ước |
|---|---|
| Tên trang / sheet | `R01 – Công suất bãi đỗ`, `R02 – Doanh thu theo bãi`, … |
| Tên bảng dữ liệu | Theo mã báo cáo: `R01_CongSuatBaiDo`, … |
| Định dạng tiền | Số nguyên, phân cách hàng nghìn, hậu tố `₫` (ví dụ `1.800.000 ₫`). Power BI: Format → Custom `#,0 "₫"` |
| Định dạng % | Cột `...Percent` đã là số phần trăm (ví dụ 16,67 nghĩa là 16,67%). **Không** chọn định dạng Percentage của Power BI (sẽ nhân thêm 100); dùng Custom `0.00"%"` |
| Ngày giờ | `dd/MM/yyyy` và `dd/MM/yyyy HH:mm` |
| Màu cảnh báo | Xanh lá = bình thường, Vàng = cần chú ý, Đỏ = nguy hiểm (thống nhất với bảng đèn cổng trên website) |
| Tiêu đề biểu đồ | Câu hỏi kinh doanh ngắn, ví dụ "Bãi nào lấp đầy cao nhất?" |
| Bộ lọc chung | Bãi (`TenBai`) đặt ở góc trên bên phải mỗi trang có cột bãi |
| Ghi nguồn | Chân trang: "Nguồn: QuanLyBaiDoXe.dbo.<tên view> – cập nhật <thời điểm refresh>" |

**Bảng chiều Bãi (tùy chọn, để lọc đồng bộ nhiều báo cáo):**

```sql
SELECT MaBai, TenBai, DiaChi, SucChua
FROM dbo.BAI_DO_XE
ORDER BY MaBai;
```

Trong Power BI: tạo quan hệ 1 – n từ `Dim_BaiDoXe[MaBai]` tới cột `MaBai` của các bảng R01, R02, R06, R07, R08, R09, R10. Các view R03, R05 không có `MaBai`, chỉ có `TenBai` – nối theo `TenBai` (tên bãi là duy nhất).

---

## 5. DANH MỤC 16 BÁO CÁO

| Mã | Tên báo cáo | View nguồn | Câu hỏi kinh doanh | Biểu đồ chính |
|---|---|---|---|---|
| R01 | Công suất bãi đỗ | `vw_Report_CongSuatBaiDo` | Bãi nào đang đầy, còn bao nhiêu chỗ? | Thanh ngang + gauge |
| R02 | Doanh thu theo bãi | `vw_Report_DoanhThuTheoBai` | Bãi nào mang lại doanh thu cao nhất, cơ cấu lượt / tháng ra sao? | Cột chồng |
| R03 | Xe đang đỗ hiện tại | `vw_Report_XeDangDoHienTai` | Hiện có những xe nào trong bãi, xe nào đỗ quá lâu? | Bảng + cột |
| R04 | Vé tháng sắp hết hạn | `vw_Report_VeThangSapHetHan` | Cần nhắc gia hạn những khách nào? | Bảng có tô màu |
| R05 | Nhật ký sự cố | `vw_Report_NhatKySuCo` | Sự cố phát sinh ở đâu, tiền phạt bao nhiêu, đã xử lý chưa? | Cột + bảng |
| R06 | Doanh thu theo ngày | `vw_Report_DoanhThuTheoNgay` | Doanh thu biến động theo ngày thế nào? | Đường / vùng |
| R07 | Doanh thu theo tháng | `vw_Report_DoanhThuTheoThang` | Xu hướng doanh thu theo tháng? | Cột nhóm theo tháng |
| R08 | Lưu lượng theo giờ | `vw_Report_LuuLuongTheoGio` | Giờ cao điểm là khi nào? | Heatmap giờ × bãi |
| R09 | Thống kê theo loại xe | `vw_Report_ThongKeTheoLoaiXe` | Loại xe nào đóng góp nhiều nhất? | Tròn / cột |
| R10 | Xếp hạng bãi | `vw_Report_XepHangBai` | Thứ hạng các bãi theo doanh thu và lấp đầy? | Bảng xếp hạng + scatter |
| R11 | Tổng quan toàn chuỗi | `vw_Report_TongQuanChuoi` | Tình hình toàn chuỗi hôm nay / tháng này? | Thẻ KPI |
| R12 | Doanh thu theo phương thức thanh toán | `vw_Report_DoanhThuTheoPhuongThuc` | Khách trả tiền qua kênh nào, phí cổng bao nhiêu? | Cột chồng + bảng |
| R13 | Tổng quan ví điện tử | `vw_Report_TongQuanViDienTu` | Khách đang giữ bao nhiêu tiền trong ví? | Thẻ KPI |
| R14 | Giao dịch cần xử lý | `vw_Report_GiaoDichCanXuLy` | Giao dịch nào đang treo / thất bại cần xử lý? | Bảng tô màu |
| R15 | Bảo mật tài khoản khách hàng | `vw_Report_BaoMatTaiKhoanKH` | Tài khoản nào có dấu hiệu bị dò mật khẩu? | Bảng + cột |
| R16 | Tỷ lệ chuyển đổi online | `vw_Report_TyLeChuyenDoiOnline` | Khách chuyển sang gia hạn online đến đâu? | Cột chồng + đường |

---

## 6. HƯỚNG DẪN CHI TIẾT TỪNG BÁO CÁO

> Mỗi báo cáo gồm: mục đích, dữ liệu nguồn (cột và ý nghĩa), **câu query chính**, query bổ sung (nếu có), cách dựng biểu đồ, công thức (DAX cho Power BI / Calculated Field cho Tableau), cách đọc kết quả và tên file ảnh cần lưu.

---

### R01. CÔNG SUẤT BÃI ĐỖ

**Mục đích:** theo dõi số xe đang đỗ, chỗ trống và tỷ lệ lấp đầy của từng bãi để điều phối xe, tránh quá tải (an toàn PCCC).

**Nguồn:** `vw_Report_CongSuatBaiDo` – 1 dòng / bãi.

| Cột | Ý nghĩa |
|---|---|
| `MaBai`, `TenBai` | Mã, tên bãi |
| `SucChua` | Sức chứa (số ô đỗ) |
| `SoLuongHienTai` | Số xe đang đỗ (bộ đếm do trigger duy trì) |
| `SoChoTrong` | `SucChua − SoLuongHienTai` |
| `TyLeLapDayPercent` | `SoLuongHienTai × 100 / SucChua`, 2 chữ số thập phân |

**Query chính:**

```sql
SELECT MaBai, TenBai, SucChua, SoLuongHienTai, SoChoTrong, TyLeLapDayPercent,
       CASE WHEN TyLeLapDayPercent >= 100 THEN N'Đầy'
            WHEN TyLeLapDayPercent >= 80  THEN N'Gần đầy'
            ELSE N'Còn chỗ' END AS MucCanhBao
FROM dbo.vw_Report_CongSuatBaiDo
ORDER BY TyLeLapDayPercent DESC;
```

**Query bổ sung – tổng toàn chuỗi (cho gauge):**

```sql
SELECT SUM(SucChua) AS TongSucChua,
       SUM(SoLuongHienTai) AS TongXeDangDo,
       CAST(SUM(SoLuongHienTai) * 100.0 / NULLIF(SUM(SucChua), 0) AS DECIMAL(5,2)) AS TyLeLapDayChuoi
FROM dbo.vw_Report_CongSuatBaiDo;
```

**Dựng biểu đồ:**
1. *Stacked bar chart* (thanh ngang): Axis = `TenBai`; Values = `SoLuongHienTai` và `SoChoTrong` (tổng chiều dài thanh = sức chứa).
2. *Gauge*: Value = tổng `SoLuongHienTai`, Maximum = tổng `SucChua`.
3. *Table*: `TenBai`, `SucChua`, `SoLuongHienTai`, `SoChoTrong`, `TyLeLapDayPercent`, `MucCanhBao`; Conditional formatting cột `TyLeLapDayPercent`: < 80 xanh, 80 – dưới 100 vàng, ≥ 100 đỏ.

**Công thức:**
- DAX: `Tỷ lệ lấp đầy chuỗi = DIVIDE(SUM(R01[SoLuongHienTai]), SUM(R01[SucChua])) * 100`
- Tableau: `SUM([SoLuongHienTai]) / SUM([SucChua]) * 100`

**Cách đọc:** bãi có tỷ lệ ≥ 80% cần điều phối xe sang bãi gần nhất; ngưỡng 80% trùng với mức "VÀNG - GẦN ĐẦY" của view sơ đồ `v_SodoBai_TongQuanBai`.

**Ảnh lưu:** `reports_screenshots/vw_Report_CongSuatBaiDo.png`

---

### R02. DOANH THU THEO BÃI

**Mục đích:** so sánh tổng doanh thu và cơ cấu nguồn thu (gửi lượt / vé tháng; vé tháng tại quầy / online) giữa các bãi.

**Nguồn:** `vw_Report_DoanhThuTheoBai` – 1 dòng / bãi, toàn bộ lịch sử.

| Cột | Ý nghĩa |
|---|---|
| `DoanhThuLuot` | `SUM(LUOT_GUI.TienGui)` của bãi |
| `DoanhThuThang` | `SUM(HOA_DON_VE_THANG.SoTien)` của bãi |
| `TongDoanhThu` | `DoanhThuLuot + DoanhThuThang` |
| `DoanhThuThangTaiQuay` | Hóa đơn kênh "Tại quầy" |
| `DoanhThuThangOnline` | Hóa đơn kênh "Online" + "Tự động" |

**Query chính:**

```sql
SELECT MaBai, TenBai, DoanhThuLuot, DoanhThuThang, TongDoanhThu,
       DoanhThuThangTaiQuay, DoanhThuThangOnline,
       CAST(TongDoanhThu * 100.0 / NULLIF(SUM(TongDoanhThu) OVER (), 0) AS DECIMAL(5,2)) AS TyTrongChuoiPercent
FROM dbo.vw_Report_DoanhThuTheoBai
ORDER BY TongDoanhThu DESC;
```

**Query bổ sung – dạng "dài" (unpivot) để vẽ cột chồng theo nguồn thu:**

```sql
SELECT TenBai, N'Gửi lượt' AS NguonThu, DoanhThuLuot AS SoTien FROM dbo.vw_Report_DoanhThuTheoBai
UNION ALL
SELECT TenBai, N'Vé tháng - tại quầy', DoanhThuThangTaiQuay FROM dbo.vw_Report_DoanhThuTheoBai
UNION ALL
SELECT TenBai, N'Vé tháng - online / tự động', DoanhThuThangOnline FROM dbo.vw_Report_DoanhThuTheoBai;
```

**Dựng biểu đồ:**
1. *Stacked column chart*: Axis = `TenBai`; Legend = `NguonThu`; Values = `SoTien` (dùng query dạng dài).
2. *Donut chart*: Legend = `TenBai`; Values = `TongDoanhThu` → tỷ trọng doanh thu từng bãi.
3. *Card*: tổng doanh thu chuỗi.

**Công thức:**
- DAX: `Tổng doanh thu = SUM(R02[TongDoanhThu])`; `Tỷ trọng vé tháng = DIVIDE(SUM(R02[DoanhThuThang]), SUM(R02[TongDoanhThu]))`
- Tableau: `SUM([DoanhThuThang]) / SUM([TongDoanhThu])`

**Cách đọc:** bãi có doanh thu vé tháng cao là bãi có lượng khách cố định lớn; tỷ lệ online cao cho thấy cổng khách hàng được sử dụng tốt.

**Ảnh lưu:** `reports_screenshots/vw_Report_DoanhThuTheoBai.png`

---

### R03. XE ĐANG ĐỖ HIỆN TẠI

**Mục đích:** danh sách phương tiện đang có mặt trong toàn chuỗi; phát hiện xe đỗ quá lâu (bỏ quên).

**Nguồn:** `vw_Report_XeDangDoHienTai` – 1 dòng / lượt gửi chưa check-out.

| Cột | Ý nghĩa |
|---|---|
| `MaLuot`, `MaThe`, `LoaiThe` | Lượt gửi, thẻ, loại thẻ (Lượt / Tháng) |
| `BienSo`, `ThoiGianVao` | Biển số, giờ vào |
| `SoPhutDaDo` | Số phút từ lúc vào đến hiện tại |
| `MaViTri`, `KhuVuc` | Ô đỗ, khu vực / tầng |
| `LoaiPhuongTien`, `TenBai` | Loại xe, tên bãi |

**Query chính:**

```sql
SELECT MaLuot, TenBai, KhuVuc, MaViTri, BienSo, MaThe, LoaiThe, LoaiPhuongTien,
       ThoiGianVao, SoPhutDaDo,
       CAST(SoPhutDaDo / 60.0 AS DECIMAL(10,1)) AS SoGioDaDo,
       CASE WHEN SoPhutDaDo >= 24 * 60 THEN N'Quá 24 giờ'
            WHEN SoPhutDaDo >= 4 * 60  THEN N'4 - 24 giờ'
            ELSE N'Dưới 4 giờ' END AS NhomThoiGian
FROM dbo.vw_Report_XeDangDoHienTai
ORDER BY SoPhutDaDo DESC;
```

**Dựng biểu đồ:**
1. *Stacked column*: Axis = `TenBai`; Legend = `LoaiThe`; Values = Count of `MaLuot` → số xe đang đỗ theo bãi, tách thẻ lượt / thẻ tháng.
2. *Table*: toàn bộ cột, sắp theo `SoPhutDaDo` giảm dần; tô đỏ dòng `NhomThoiGian = 'Quá 24 giờ'`.
3. *Slicer*: `TenBai`, `LoaiPhuongTien`.

**Công thức:** DAX `Số xe đang đỗ = COUNTROWS(R03)`; Tableau `COUNTD([MaLuot])`.

**Cách đọc:** xe quá 24 giờ trùng với cảnh báo "Xe đỗ quá 24 giờ - kiểm tra phương tiện bỏ quên" trên bốt cổng; số xe theo bãi phải khớp `SoLuongHienTai` ở R01 (xem truy vấn đối soát 8.3).

**Ảnh lưu:** `reports_screenshots/vw_Report_XeDangDoHienTai.png`

---

### R04. VÉ THÁNG SẮP HẾT HẠN

**Mục đích:** danh sách vé còn ≤ 7 ngày (kể cả đã quá hạn) để nhắc khách gia hạn.

**Nguồn:** `vw_Report_VeThangSapHetHan` – đã lọc sẵn số ngày còn lại ≤ 7.

| Cột | Ý nghĩa |
|---|---|
| `MaVe`, `HoTenKhachHang`, `SDT` | Vé, khách, số điện thoại |
| `BienSo`, `MaLoaiXe` | Biển số, loại xe (OT / XM / XD) |
| `NgayHetHan`, `SoNgayConLai` | Hạn dùng, số ngày còn lại (âm = đã quá hạn) |
| `TrangThaiVe`, `MaBaiApDung` | Trạng thái vé, bãi áp dụng (`ALL` = toàn chuỗi) |

**Query chính:**

```sql
SELECT MaVe, HoTenKhachHang, SDT, BienSo, MaLoaiXe, MaBaiApDung,
       NgayHetHan, SoNgayConLai, TrangThaiVe,
       CASE WHEN SoNgayConLai < 0  THEN N'Đã quá hạn'
            WHEN SoNgayConLai <= 3 THEN N'Còn ≤ 3 ngày'
            ELSE N'Còn 4 - 7 ngày' END AS MucDo
FROM dbo.vw_Report_VeThangSapHetHan
ORDER BY SoNgayConLai ASC;
```

**Query bổ sung – vé nào đã bật tự động gia hạn (để không nhắc thừa):**

```sql
SELECT r.MaVe, r.HoTenKhachHang, r.SoNgayConLai, vt.TuDongGiaHan, vt.SoThangTuDongGiaHan
FROM dbo.vw_Report_VeThangSapHetHan r
INNER JOIN dbo.VE_THANG vt ON vt.MaVe = r.MaVe
ORDER BY r.SoNgayConLai;
```

**Dựng biểu đồ:**
1. *Card*: số vé đã quá hạn; số vé còn ≤ 3 ngày.
2. *Table*: sắp theo `SoNgayConLai`; tô đỏ "Đã quá hạn", vàng "Còn ≤ 3 ngày".
3. *Column*: Axis = `MucDo`; Values = Count of `MaVe`.

**Cách đọc:** danh sách này là "việc cần làm" hằng ngày của quản lý bãi; khách có tài khoản online được hướng dẫn tự gia hạn trên cổng khách hàng.

**Ảnh lưu:** `reports_screenshots/vw_Report_VeThangSapHetHan.png`

---

### R05. NHẬT KÝ SỰ CỐ

**Mục đích:** thống kê sự cố an ninh (mất thẻ…), tiền phạt và tiến độ xử lý.

**Nguồn:** `vw_Report_NhatKySuCo` – 1 dòng / biên bản.

| Cột | Ý nghĩa |
|---|---|
| `MaSuCo`, `ThoiGianSuCo` | Mã, thời điểm |
| `MaThe`, `BienSo` | Thẻ, biển số liên quan |
| `MoTa`, `TienPhat` | Mô tả, tiền phạt (mất thẻ mặc định 50.000 ₫) |
| `TrangThaiXuLy`, `TenBai` | Chờ xử lý / Đang giải quyết / Đã giải quyết; bãi |

**Query chính:**

```sql
SELECT MaSuCo, TenBai, ThoiGianSuCo, CAST(ThoiGianSuCo AS DATE) AS NgaySuCo,
       MaThe, BienSo, MoTa, TienPhat, TrangThaiXuLy
FROM dbo.vw_Report_NhatKySuCo
ORDER BY ThoiGianSuCo DESC;
```

**Query bổ sung – tổng hợp theo bãi và trạng thái:**

```sql
SELECT TenBai, TrangThaiXuLy, COUNT(*) AS SoSuCo, SUM(TienPhat) AS TongTienPhat
FROM dbo.vw_Report_NhatKySuCo
GROUP BY TenBai, TrangThaiXuLy
ORDER BY TenBai, TrangThaiXuLy;
```

**Dựng biểu đồ:**
1. *Stacked column*: Axis = `TenBai`; Legend = `TrangThaiXuLy`; Values = `SoSuCo`.
2. *Card*: tổng tiền phạt; số sự cố "Chờ xử lý".
3. *Table* chi tiết biên bản.

**Cách đọc:** bãi có nhiều sự cố "Chờ xử lý" cần ưu tiên; tổng tiền phạt là khoản thu đền bù thẻ vật lý.

**Ảnh lưu:** `reports_screenshots/vw_Report_NhatKySuCo.png`

---

### R06. DOANH THU THEO NGÀY

**Mục đích:** theo dõi biến động doanh thu hằng ngày của từng bãi.

**Nguồn:** `vw_Report_DoanhThuTheoNgay` – 1 dòng / (bãi, ngày). Doanh thu lượt tính theo **ngày xe ra** (`ThoiGianRa`), doanh thu vé tháng theo **ngày thanh toán** hóa đơn.

| Cột | Ý nghĩa |
|---|---|
| `MaBai`, `TenBai`, `Ngay` | Bãi, ngày |
| `SoLuotXe`, `DoanhThuLuot` | Số lượt đã ra trong ngày, tiền gửi lượt |
| `SoHoaDonVeThang`, `DoanhThuVeThang` | Số hóa đơn, tiền vé tháng |
| `TongDoanhThu` | Lượt + vé tháng |

**Query chính (30 ngày gần nhất):**

```sql
SELECT MaBai, TenBai, Ngay, SoLuotXe, DoanhThuLuot, SoHoaDonVeThang, DoanhThuVeThang, TongDoanhThu
FROM dbo.vw_Report_DoanhThuTheoNgay
WHERE Ngay >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
ORDER BY Ngay, MaBai;
```

> Bỏ điều kiện `WHERE` để lấy toàn bộ lịch sử (hóa đơn mẫu có từ tháng 1/2026).

**Query bổ sung – tổng toàn chuỗi theo ngày:**

```sql
SELECT Ngay, SUM(SoLuotXe) AS SoLuotXe, SUM(DoanhThuLuot) AS DoanhThuLuot,
       SUM(DoanhThuVeThang) AS DoanhThuVeThang, SUM(TongDoanhThu) AS TongDoanhThu
FROM dbo.vw_Report_DoanhThuTheoNgay
GROUP BY Ngay
ORDER BY Ngay;
```

**Dựng biểu đồ:**
1. *Line chart*: Axis = `Ngay` (kiểu Date, tắt Date hierarchy); Values = `TongDoanhThu`; Legend = `TenBai`.
2. *Stacked area*: `DoanhThuLuot` và `DoanhThuVeThang` toàn chuỗi theo ngày (query bổ sung).
3. *Slicer* khoảng ngày (Between).

**Công thức:**
- DAX trung bình 7 ngày: `DT TB 7 ngày = AVERAGEX(DATESINPERIOD(R06[Ngay], MAX(R06[Ngay]), -7, DAY), CALCULATE(SUM(R06[TongDoanhThu])))`
- Tableau: `WINDOW_AVG(SUM([TongDoanhThu]), -6, 0)` (Compute using `Ngay`).

**Cách đọc:** đỉnh doanh thu vé tháng thường rơi vào kỳ gia hạn; doanh thu lượt phản ánh lưu lượng khách vãng lai.

**Ảnh lưu:** `reports_screenshots/vw_Report_DoanhThuTheoNgay.png`

---

### R07. DOANH THU THEO THÁNG

**Mục đích:** xu hướng doanh thu theo tháng, so sánh các bãi.

**Nguồn:** `vw_Report_DoanhThuTheoThang` – 1 dòng / (bãi, năm, tháng); cột giống R06 nhưng thay `Ngay` bằng `Nam`, `Thang`.

**Query chính:**

```sql
SELECT MaBai, TenBai, Nam, Thang,
       DATEFROMPARTS(Nam, Thang, 1) AS DauThang,
       CONCAT(Nam, '-', RIGHT(CONCAT('0', Thang), 2)) AS NhanThang,
       SoLuotXe, DoanhThuLuot, SoHoaDonVeThang, DoanhThuVeThang, TongDoanhThu
FROM dbo.vw_Report_DoanhThuTheoThang
ORDER BY Nam, Thang, MaBai;
```

**Query bổ sung – tăng trưởng so với tháng trước (toàn chuỗi):**

```sql
WITH Chuoi AS (
    SELECT Nam, Thang, SUM(TongDoanhThu) AS TongDoanhThu
    FROM dbo.vw_Report_DoanhThuTheoThang
    GROUP BY Nam, Thang
)
SELECT Nam, Thang, TongDoanhThu,
       LAG(TongDoanhThu) OVER (ORDER BY Nam, Thang) AS ThangTruoc,
       CAST((TongDoanhThu - LAG(TongDoanhThu) OVER (ORDER BY Nam, Thang)) * 100.0
            / NULLIF(LAG(TongDoanhThu) OVER (ORDER BY Nam, Thang), 0) AS DECIMAL(10,2)) AS TangTruongPercent
FROM Chuoi
ORDER BY Nam, Thang;
```

**Dựng biểu đồ:**
1. *Clustered column*: Axis = `NhanThang` (hoặc `DauThang`); Values = `TongDoanhThu`; Legend = `TenBai`.
2. *Line and clustered column*: cột = `TongDoanhThu` toàn chuỗi, đường = `TangTruongPercent`.
3. *Matrix*: hàng = `TenBai`, cột = `NhanThang`, giá trị = `TongDoanhThu` (bật Conditional formatting dạng heatmap).

**Cách đọc:** so sánh xu hướng giữa các bãi; tháng tăng trưởng âm cần xem lại lưu lượng (R08) và vé hết hạn chưa gia hạn (R04).

**Ảnh lưu:** `reports_screenshots/vw_Report_DoanhThuTheoThang.png`

---

### R08. LƯU LƯỢNG XE THEO GIỜ

**Mục đích:** xác định giờ cao điểm để bố trí nhân sự trực cổng.

**Nguồn:** `vw_Report_LuuLuongTheoGio` – 1 dòng / (bãi, giờ trong ngày 0–23 có xe vào), tính theo **giờ xe vào** của mọi lượt gửi.

| Cột | Ý nghĩa |
|---|---|
| `GioTrongNgay` | 0 – 23 |
| `SoLuotVao` | Tổng lượt vào trong giờ đó (toàn bộ lịch sử) |
| `SoNgayCoDuLieu` | Số ngày khác nhau có lượt vào trong giờ đó |
| `SoLuotVaoTBMoiNgay` | `SoLuotVao / SoNgayCoDuLieu` |

**Query chính:**

```sql
SELECT MaBai, TenBai, GioTrongNgay,
       CONCAT(RIGHT(CONCAT('0', GioTrongNgay), 2), ':00') AS KhungGio,
       SoLuotVao, SoNgayCoDuLieu, SoLuotVaoTBMoiNgay
FROM dbo.vw_Report_LuuLuongTheoGio
ORDER BY MaBai, GioTrongNgay;
```

**Query bổ sung – đủ 24 khung giờ cho toàn chuỗi (giờ không có xe = 0, biểu đồ không bị đứt):**

```sql
WITH Gio AS (
    SELECT TOP (24) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS GioTrongNgay
    FROM sys.all_objects
)
SELECT g.GioTrongNgay,
       ISNULL(SUM(r.SoLuotVao), 0) AS SoLuotVao
FROM Gio g
LEFT JOIN dbo.vw_Report_LuuLuongTheoGio r ON r.GioTrongNgay = g.GioTrongNgay
GROUP BY g.GioTrongNgay
ORDER BY g.GioTrongNgay;
```

**Dựng biểu đồ:**
1. *Matrix heatmap* (Power BI) hoặc *Highlight table* (Tableau): hàng = `TenBai`, cột = `GioTrongNgay`, giá trị = `SoLuotVao`, tô màu nền theo giá trị.
2. *Column chart*: Axis = `GioTrongNgay` (0–23, dùng query 24 khung giờ); Values = `SoLuotVao`.

**Cách đọc:** ô đậm nhất là giờ cao điểm của từng bãi; dữ liệu mẫu ít nên nên chạy thêm vài lượt check-in trước khi chụp ảnh.

**Ảnh lưu:** `reports_screenshots/vw_Report_LuuLuongTheoGio.png`

---

### R09. THỐNG KÊ THEO LOẠI XE

**Mục đích:** cơ cấu lượt gửi và doanh thu theo loại phương tiện → quyết định đầu tư thêm ô ô tô hay xe máy.

**Nguồn:** `vw_Report_ThongKeTheoLoaiXe` – 1 dòng / (bãi, loại xe), chỉ tính **lượt đã check-out**.

| Cột | Ý nghĩa |
|---|---|
| `MaLoaiXe`, `LoaiPhuongTien` | OT – Ô tô 4-7 chỗ, XM – Xe máy, XD – Xe đạp / Xe điện |
| `SoLuotXe` | Số lượt đã ra |
| `DoanhThuLuot` | Tổng tiền gửi lượt (xe vé tháng = 0) |
| `SoGioGuiTB` | Thời gian gửi trung bình (giờ) |

**Query chính:**

```sql
SELECT MaBai, TenBai, MaLoaiXe, LoaiPhuongTien, SoLuotXe, DoanhThuLuot, SoGioGuiTB,
       CAST(DoanhThuLuot / NULLIF(SoLuotXe, 0) AS DECIMAL(18,0)) AS DoanhThuTBMoiLuot
FROM dbo.vw_Report_ThongKeTheoLoaiXe
ORDER BY MaBai, DoanhThuLuot DESC;
```

**Query bổ sung – so với số ô đỗ hiện có theo loại xe (hiệu quả khai thác ô):**

```sql
SELECT r.TenBai, r.LoaiPhuongTien, r.SoLuotXe,
       o.SoODo,
       CAST(r.SoLuotXe * 1.0 / NULLIF(o.SoODo, 0) AS DECIMAL(10,2)) AS SoLuotTrenMotO
FROM dbo.vw_Report_ThongKeTheoLoaiXe r
INNER JOIN (
    SELECT MaBai, MaLoaiXe, COUNT(*) AS SoODo
    FROM dbo.VI_TRI_DO
    GROUP BY MaBai, MaLoaiXe
) o ON o.MaBai = r.MaBai AND o.MaLoaiXe = r.MaLoaiXe
ORDER BY SoLuotTrenMotO DESC;
```

**Dựng biểu đồ:**
1. *Donut*: Legend = `LoaiPhuongTien`; Values = `SoLuotXe` (toàn chuỗi).
2. *Clustered column*: Axis = `TenBai`; Legend = `LoaiPhuongTien`; Values = `DoanhThuLuot`.
3. *Bar*: `SoLuotTrenMotO` theo bãi – loại xe (query bổ sung).

**Cách đọc:** loại xe có số lượt trên mỗi ô cao là loại đang thiếu chỗ → ưu tiên mở rộng.

**Ảnh lưu:** `reports_screenshots/vw_Report_ThongKeTheoLoaiXe.png`

---

### R10. XẾP HẠNG BÃI

**Mục đích:** bảng xếp hạng hiệu quả chi nhánh theo tổng doanh thu, kèm tỷ lệ lấp đầy hiện tại.

**Nguồn:** `vw_Report_XepHangBai` – dựng từ R02 và R01 nên số liệu đồng nhất; `HangDoanhThu = RANK() OVER (ORDER BY TongDoanhThu DESC)`.

**Query chính:**

```sql
SELECT HangDoanhThu, MaBai, TenBai, DoanhThuLuot, DoanhThuThang, TongDoanhThu,
       SucChua, SoLuongHienTai, TyLeLapDayPercent,
       CAST(TongDoanhThu / NULLIF(SucChua, 0) AS DECIMAL(18,0)) AS DoanhThuTrenMotO
FROM dbo.vw_Report_XepHangBai
ORDER BY HangDoanhThu;
```

**Dựng biểu đồ:**
1. *Table*: `HangDoanhThu`, `TenBai`, `TongDoanhThu`, `DoanhThuTrenMotO`, `TyLeLapDayPercent`; thêm Data bars cho `TongDoanhThu`.
2. *Scatter chart*: X = `TyLeLapDayPercent`, Y = `TongDoanhThu`, Size = `SucChua`, Details = `TenBai` → góc trên phải là bãi vừa đông vừa sinh lời.

**Cách đọc:** `DoanhThuTrenMotO` cho phép so sánh công bằng giữa bãi lớn và bãi nhỏ.

**Ảnh lưu:** `reports_screenshots/vw_Report_XepHangBai.png`

---

### R11. TỔNG QUAN TOÀN CHUỖI

**Mục đích:** trang KPI điều hành – view luôn trả đúng 1 dòng.

**Nguồn:** `vw_Report_TongQuanChuoi`.

| Cột | Ý nghĩa |
|---|---|
| `TongSoBai`, `TongSucChua`, `TongXeDangGui` | Quy mô và tải hiện tại |
| `TyLeLapDayToanChuoiPercent` | Tỷ lệ lấp đầy toàn chuỗi |
| `DoanhThuLuotHomNay`, `DoanhThuVeThangHomNay` | Doanh thu hôm nay |
| `DoanhThuLuotThangNay`, `DoanhThuVeThangThangNay` | Doanh thu từ đầu tháng |
| `SoVeThangConHieuLuc`, `SoVeThangSapHetHan7Ngay` | Vé tháng |
| `SoSuCoHomNay` | Sự cố hôm nay |

**Query chính:**

```sql
SELECT TongSoBai, TongSucChua, TongXeDangGui, TyLeLapDayToanChuoiPercent,
       DoanhThuLuotHomNay, DoanhThuVeThangHomNay,
       DoanhThuLuotHomNay + DoanhThuVeThangHomNay AS TongDoanhThuHomNay,
       DoanhThuLuotThangNay, DoanhThuVeThangThangNay,
       DoanhThuLuotThangNay + DoanhThuVeThangThangNay AS TongDoanhThuThangNay,
       SoVeThangConHieuLuc, SoVeThangSapHetHan7Ngay, SoSuCoHomNay
FROM dbo.vw_Report_TongQuanChuoi;
```

**Dựng biểu đồ:** 8 – 10 *Card* / *Multi-row card* xếp thành lưới 2 hàng: Quy mô (số bãi, sức chứa, xe đang gửi, % lấp đầy) – Doanh thu (hôm nay, tháng này) – Vé tháng (còn hiệu lực, sắp hết hạn) – An ninh (sự cố hôm nay). Thêm *Gauge* cho `TyLeLapDayToanChuoiPercent` (Max = 100).

**Cách đọc:** đây là trang đầu tiên của dashboard điều hành; các con số "hôm nay", "tháng này" phụ thuộc thời điểm refresh.

**Ảnh lưu:** `reports_screenshots/vw_Report_TongQuanChuoi.png`

---

### R12. DOANH THU THEO PHƯƠNG THỨC THANH TOÁN

**Mục đích:** khách trả tiền vé tháng và nạp ví qua kênh nào; chi phí cổng thanh toán.

**Nguồn:** `vw_Report_DoanhThuTheoPhuongThuc` – 1 dòng / phương thức (7 phương thức: TIEN_MAT, CHUYEN_KHOAN, MOMO, ZALOPAY, VNPAY, THE_NH, SO_DU_VI).

| Cột | Ý nghĩa |
|---|---|
| `MaPTTT`, `PhuongThucThanhToan`, `LoaiKenh`, `TrangThai` | Phương thức, kênh, trạng thái |
| `SoHoaDonVeThang`, `DoanhThuTaiQuay`, `DoanhThuOnline`, `DoanhThuTuDong`, `TongDoanhThuVeThang` | Hóa đơn vé tháng theo kênh bán |
| `SoLanNapVi`, `TongTienNapVi` | Nạp ví thành công (gồm giao dịch đã hoàn) |
| `PhiCongThanhToan`, `TienNapThucNhan` | Phí cổng; tiền thực nhận = nạp − phí |

**Query chính:**

```sql
SELECT MaPTTT, PhuongThucThanhToan, LoaiKenh, TrangThai,
       SoHoaDonVeThang, DoanhThuTaiQuay, DoanhThuOnline, DoanhThuTuDong, TongDoanhThuVeThang,
       SoLanNapVi, TongTienNapVi, PhiCongThanhToan, TienNapThucNhan,
       CAST(PhiCongThanhToan * 100.0 / NULLIF(TongTienNapVi, 0) AS DECIMAL(5,2)) AS TyLePhiPercent
FROM dbo.vw_Report_DoanhThuTheoPhuongThuc
ORDER BY TongDoanhThuVeThang + TongTienNapVi DESC;
```

**Dựng biểu đồ:**
1. *Stacked bar*: Axis = `PhuongThucThanhToan`; Values = `DoanhThuTaiQuay`, `DoanhThuOnline`, `DoanhThuTuDong`.
2. *Clustered column*: `TongTienNapVi` và `PhiCongThanhToan` theo phương thức.
3. *Table* đầy đủ, lọc bỏ dòng toàn số 0 (Visual filter: `TongDoanhThuVeThang + TongTienNapVi > 0`).

**Cách đọc:** `SO_DU_VI` là thanh toán bằng số dư ví (gia hạn online / tự động); phương thức có `TyLePhiPercent` cao làm giảm tiền thực nhận.

**Ảnh lưu:** `reports_screenshots/vw_Report_DoanhThuTheoPhuongThuc.png`

---

### R13. TỔNG QUAN VÍ ĐIỆN TỬ

**Mục đích:** KPI ví – đặc biệt **tổng số dư khách đang giữ** (nợ phải trả khách hàng). View luôn trả đúng 1 dòng.

**Nguồn:** `vw_Report_TongQuanViDienTu`.

**Query chính:**

```sql
SELECT TongSoVi, SoViCoSoDu, TongSoDuDangGiu,
       TongNapThangNay, TongChiVeThangThangNay, DoanhThuGiaHanOnlineThangNay,
       SoGiaoDichChoXuLy, SoTaiKhoanKhachHang, SoTaiKhoanTamKhoa
FROM dbo.vw_Report_TongQuanViDienTu;
```

**Query bổ sung – phân bố số dư từng ví (biểu đồ chi tiết):**

```sql
SELECT vi.MaVi, kh.HoTen, vi.SoDu, vi.TrangThai,
       CASE WHEN vi.SoDu = 0 THEN N'0 ₫'
            WHEN vi.SoDu < 500000 THEN N'Dưới 500 nghìn'
            WHEN vi.SoDu < 2000000 THEN N'500 nghìn - 2 triệu'
            ELSE N'Từ 2 triệu' END AS NhomSoDu
FROM dbo.VI_DIEN_TU vi
INNER JOIN dbo.KHACH_HANG kh ON kh.MaKH = vi.MaKH
ORDER BY vi.SoDu DESC;
```

**Dựng biểu đồ:** *Card* cho từng chỉ số; *Column* số ví theo `NhomSoDu`; *Bar* top ví theo `SoDu`.

**Cách đọc:** `TongSoDuDangGiu` là tiền khách đã nạp nhưng chưa dùng – doanh nghiệp đang "nợ" khách khoản này; `SoGiaoDichChoXuLy` > 0 kéo dài cần kiểm tra R14.

**Ảnh lưu:** `reports_screenshots/vw_Report_TongQuanViDienTu.png`

---

### R14. GIAO DỊCH CẦN XỬ LÝ

**Mục đích:** hàng đợi công việc của nhân viên – giao dịch đang chờ cổng thanh toán, treo quá 30 phút, thất bại trong 7 ngày.

**Nguồn:** `vw_Report_GiaoDichCanXuLy`.

| Cột | Ý nghĩa |
|---|---|
| `MaGD`, `ThoiGianTao`, `SoPhutTuKhiTao` | Giao dịch, thời điểm tạo, đã chờ bao lâu |
| `MaKH`, `HoTen` | Khách hàng |
| `LoaiGD`, `SoTien`, `PhuongThucThanhToan`, `TrangThai` | Nội dung giao dịch |
| `PhanLoai` | "Treo quá 30 phút" / "Đang chờ cổng thanh toán" / "Thất bại" |
| `GhiChu` | Ghi chú |

**Query chính:**

```sql
SELECT MaGD, ThoiGianTao, SoPhutTuKhiTao, MaKH, HoTen, LoaiGD, SoTien,
       PhuongThucThanhToan, TrangThai, PhanLoai, GhiChu
FROM dbo.vw_Report_GiaoDichCanXuLy
ORDER BY CASE PhanLoai WHEN N'Treo quá 30 phút' THEN 0
                       WHEN N'Đang chờ cổng thanh toán' THEN 1
                       ELSE 2 END,
         ThoiGianTao;
```

**Dựng biểu đồ:** *Card* đếm theo `PhanLoai`; *Table* tô đỏ "Treo quá 30 phút", cam "Thất bại".

**Cách đọc:** giao dịch treo quá 30 phút sẽ được cursor đối soát `sp_DemoDoiSoatViDienTu` chuyển sang "Thất bại". Nếu báo cáo trống: tạo một lệnh nạp trên cổng khách hàng `/kh/nap-tien` nhưng không xác nhận ở cổng thanh toán mô phỏng.

**Ảnh lưu:** `reports_screenshots/vw_Report_GiaoDichCanXuLy.png`

---

### R15. BẢO MẬT TÀI KHOẢN KHÁCH HÀNG

**Mục đích:** phát hiện tài khoản bị dò mật khẩu, đăng nhập từ nhiều IP trong 24 giờ.

**Nguồn:** `vw_Report_BaoMatTaiKhoanKH` – 1 dòng / tài khoản khách.

| Cột | Ý nghĩa |
|---|---|
| `MaTK`, `TenDangNhap`, `HoTen` | Tài khoản |
| `TrangThai`, `KhoaDen`, `SoLanSaiLienTiep` | Trạng thái khóa |
| `LanDangNhapCuoi` | Lần đăng nhập thành công gần nhất |
| `SoLanSai24h`, `SoLanThanhCong24h`, `SoDiaChiIP24h` | Thống kê 24 giờ |
| `CanhBao` | "Đang tạm khóa" / "Nhiều lần sai mật khẩu" (≥ 3) / "Đăng nhập từ nhiều địa chỉ IP" (≥ 3) / "Bình thường" |

**Query chính:**

```sql
SELECT MaTK, TenDangNhap, HoTen, TrangThai, KhoaDen, SoLanSaiLienTiep, LanDangNhapCuoi,
       SoLanSai24h, SoLanThanhCong24h, SoDiaChiIP24h, CanhBao
FROM dbo.vw_Report_BaoMatTaiKhoanKH
ORDER BY CASE CanhBao WHEN N'Bình thường' THEN 1 ELSE 0 END, SoLanSai24h DESC;
```

**Query bổ sung – số lần đăng nhập theo kết quả và giờ (24 giờ gần nhất):**

```sql
SELECT DATEPART(HOUR, ThoiGian) AS Gio, KetQua, COUNT(*) AS SoLan
FROM dbo.NHAT_KY_DANG_NHAP
WHERE ThoiGian >= DATEADD(HOUR, -24, GETDATE())
GROUP BY DATEPART(HOUR, ThoiGian), KetQua
ORDER BY Gio, KetQua;
```

**Dựng biểu đồ:**
1. *Donut*: Legend = `CanhBao`; Values = Count of `MaTK`.
2. *Table*: tài khoản có `CanhBao` khác "Bình thường" lên đầu, tô đỏ "Đang tạm khóa".
3. *Stacked column*: Axis = `Gio`; Legend = `KetQua`; Values = `SoLan` (query bổ sung).

**Cách đọc:** dữ liệu mẫu có tài khoản TK0005 đang tạm khóa do 5 lần sai từ cùng một IP – minh họa tấn công dò mật khẩu.

**Ảnh lưu:** `reports_screenshots/vw_Report_BaoMatTaiKhoanKH.png`

---

### R16. TỶ LỆ CHUYỂN ĐỔI ONLINE

**Mục đích:** đo mức độ khách chuyển từ gia hạn tại quầy sang online / tự động theo tháng.

**Nguồn:** `vw_Report_TyLeChuyenDoiOnline` – 1 dòng / (năm, tháng) có hóa đơn.

| Cột | Ý nghĩa |
|---|---|
| `SoHoaDon`, `SoHoaDonTaiQuay`, `SoHoaDonOnline` | Số hóa đơn (online gồm Online + Tự động) |
| `TyLeOnlinePercent` | `SoHoaDonOnline × 100 / SoHoaDon` |
| `TyLeKhachCoTaiKhoanPercent` | Số tài khoản khách / số khách hàng (giống nhau ở mọi dòng) |

**Query chính:**

```sql
SELECT Nam, Thang, DATEFROMPARTS(Nam, Thang, 1) AS DauThang,
       CONCAT(Nam, '-', RIGHT(CONCAT('0', Thang), 2)) AS NhanThang,
       SoHoaDon, SoHoaDonTaiQuay, SoHoaDonOnline, TyLeOnlinePercent, TyLeKhachCoTaiKhoanPercent
FROM dbo.vw_Report_TyLeChuyenDoiOnline
ORDER BY Nam, Thang;
```

**Dựng biểu đồ:**
1. *Line and stacked column*: cột chồng = `SoHoaDonTaiQuay`, `SoHoaDonOnline` theo `NhanThang`; đường = `TyLeOnlinePercent`.
2. *Card*: `TyLeKhachCoTaiKhoanPercent` (lấy MAX).

**Cách đọc:** đường tỷ lệ online đi lên nghĩa là cổng khách hàng giảm tải cho quầy; tỷ lệ khách có tài khoản thấp → cần khuyến khích khách đăng ký.

**Ảnh lưu:** `reports_screenshots/vw_Report_TyLeChuyenDoiOnline.png`

---

## 7. GỢI Ý BỐ CỤC DASHBOARD TỔNG HỢP

| Dashboard | Đối tượng xem | Thành phần (lấy từ các báo cáo) |
|---|---|---|
| **Điều hành chuỗi** | Ban giám đốc | Thẻ KPI R11 · Gauge lấp đầy R01 · Cột doanh thu theo bãi R02 · Bảng xếp hạng R10 · Doanh thu theo tháng R07 |
| **Tài chính – Ví điện tử** | Kế toán, quản lý | Thẻ KPI R13 · Doanh thu theo phương thức R12 · Tỷ lệ online R16 · Doanh thu theo ngày R06 · Giao dịch cần xử lý R14 |
| **Vận hành – An ninh** | Quản lý bãi | Heatmap giờ cao điểm R08 · Cơ cấu loại xe R09 · Xe đang đỗ R03 · Vé sắp hết hạn R04 · Sự cố R05 · Bảo mật tài khoản R15 |

Mỗi dashboard: khổ 16:9, slicer `TenBai` dùng chung (đồng bộ qua bảng chiều Bãi ở mục 4), tiêu đề và thời điểm cập nhật ở đầu trang.

---

## 8. TRUY VẤN ĐỐI SOÁT SỐ LIỆU

Chạy trong SSMS trước khi nộp, để chứng minh dashboard khớp dữ liệu gốc.

**8.1. Doanh thu theo bãi (R02) khớp bảng gốc:**

```sql
SELECT r.MaBai, r.TongDoanhThu AS TheoView,
       ISNULL(l.Tien, 0) + ISNULL(h.Tien, 0) AS TheoBangGoc
FROM dbo.vw_Report_DoanhThuTheoBai r
LEFT JOIN (SELECT MaBai, SUM(TienGui) AS Tien FROM dbo.LUOT_GUI GROUP BY MaBai) l ON l.MaBai = r.MaBai
LEFT JOIN (SELECT MaBai, SUM(SoTien) AS Tien FROM dbo.HOA_DON_VE_THANG GROUP BY MaBai) h ON h.MaBai = r.MaBai;
-- Hai cột phải bằng nhau ở mọi dòng
```

**8.2. Tổng doanh thu theo tháng (R07) khớp tổng theo bãi (R02):**

```sql
SELECT (SELECT SUM(TongDoanhThu) FROM dbo.vw_Report_DoanhThuTheoThang) AS TongTheoThang,
       (SELECT SUM(TongDoanhThu) FROM dbo.vw_Report_DoanhThuTheoBai)   AS TongTheoBai;
-- R07 chỉ tính lượt đã ra, nhưng lượt đang đỗ có TienGui = 0 nên hai giá trị bằng nhau
```

**8.3. Bộ đếm xe đang đỗ (R01) khớp danh sách xe đang đỗ (R03):**

```sql
SELECT c.TenBai, c.SoLuongHienTai, ISNULL(x.SoXe, 0) AS SoXeThucTe
FROM dbo.vw_Report_CongSuatBaiDo c
LEFT JOIN (SELECT TenBai, COUNT(*) AS SoXe FROM dbo.vw_Report_XeDangDoHienTai GROUP BY TenBai) x
       ON x.TenBai = c.TenBai;
-- Hai cột phải bằng nhau (tương ứng cờ CanhBaoLechBoDem = 0 trong v_SodoBai_TongQuanBai)
```

**8.4. Tổng số dư ví (R13) khớp sổ cái:**

```sql
SELECT (SELECT TongSoDuDangGiu FROM dbo.vw_Report_TongQuanViDienTu) AS TongSoDuView,
       (SELECT SUM(HuongTien * SoTien) FROM dbo.GIAO_DICH
         WHERE TrangThai IN (N'Thành công', N'Đã hoàn')) AS TongTheoSoCai;
-- Hai giá trị phải bằng nhau (cùng nguyên tắc với cursor sp_DemoDoiSoatViDienTu)
```

**8.5. Xếp hạng (R10) dùng cùng số liệu với R02:**

```sql
SELECT x.TenBai, x.TongDoanhThu, d.TongDoanhThu AS TuR02
FROM dbo.vw_Report_XepHangBai x
INNER JOIN dbo.vw_Report_DoanhThuTheoBai d ON d.MaBai = x.MaBai;
```

---

## 9. ĐƯA ẢNH DASHBOARD LÊN WEBSITE

Website tự quét thư mục `reports_screenshots/` và nhúng ảnh vào trang chi tiết báo cáo `/report/<tên view>` nếu **tên file trùng tên view**. Hỗ trợ `.png`, `.jpg`, `.jpeg`, `.webp`.

| Báo cáo | Tên file ảnh |
|---|---|
| R01 | `vw_Report_CongSuatBaiDo.png` |
| R02 | `vw_Report_DoanhThuTheoBai.png` |
| R03 | `vw_Report_XeDangDoHienTai.png` |
| R04 | `vw_Report_VeThangSapHetHan.png` |
| R05 | `vw_Report_NhatKySuCo.png` |
| R06 | `vw_Report_DoanhThuTheoNgay.png` |
| R07 | `vw_Report_DoanhThuTheoThang.png` |
| R08 | `vw_Report_LuuLuongTheoGio.png` |
| R09 | `vw_Report_ThongKeTheoLoaiXe.png` |
| R10 | `vw_Report_XepHangBai.png` |
| R11 | `vw_Report_TongQuanChuoi.png` |
| R12 | `vw_Report_DoanhThuTheoPhuongThuc.png` |
| R13 | `vw_Report_TongQuanViDienTu.png` |
| R14 | `vw_Report_GiaoDichCanXuLy.png` |
| R15 | `vw_Report_BaoMatTaiKhoanKH.png` |
| R16 | `vw_Report_TyLeChuyenDoiOnline.png` |

**Các bước:**
1. Power BI: chụp từng trang ở chế độ *Focus mode*, hoặc *File → Export → Export to PDF* rồi cắt ảnh. Tableau: *Worksheet / Dashboard → Export Image*.
2. Lưu ảnh với tên đúng bảng trên vào `reports_screenshots/`.
3. Mở `http://127.0.0.1:5001/reports` → chọn báo cáo → ảnh hiển thị cùng bảng dữ liệu realtime.
4. Dùng cùng các ảnh này cho Chương 4 của báo cáo Word (mục "Report … thể hiện qua Power BI / Tableau").

---

## 10. XỬ LÝ SỰ CỐ THƯỜNG GẶP

| Hiện tượng | Nguyên nhân | Cách xử lý |
|---|---|---|
| Lỗi 229 "The SELECT permission was denied" | Login thuộc `r_QuanLyBai` chưa được GRANT 6 view tổng hợp | Dùng login `sa` khi làm đồ án hoặc chạy đoạn GRANT ở mục 2.3 |
| Không kết nối được, lỗi chứng chỉ SSL | ODBC Driver 18 mặc định bắt mã hóa | Bật *Trust server certificate*; hoặc dùng ODBC Driver 17 |
| Không thấy dữ liệu "hôm nay" / "tháng này" | View dùng `GETDATE()`, dữ liệu mẫu chưa có giao dịch trong ngày | Chạy vài kịch bản demo (check-out, gia hạn, nạp tiền) rồi Refresh |
| Phần trăm hiển thị 1667% | Cột `...Percent` đã nhân 100, Power BI nhân thêm lần nữa | Định dạng Custom `0.00"%"` thay vì Percentage |
| Tiếng Việt bị lỗi dấu khi nạp CSV | Sai mã hóa | Xuất / mở CSV dạng UTF-8 |
| CSV bị lệch cột | Ô văn bản chứa dấu phẩy (địa chỉ, mô tả) | Xuất bằng SSMS / Azure Data Studio, hoặc `bcp` với phân cách dấu gạch đứng (mục 3.4) |
| Số liệu dashboard khác website | Dữ liệu Import chưa refresh | *Home → Refresh* (Power BI) / *Data → Refresh Extract* (Tableau) |
| Biểu đồ R06 / R08 thưa | Dữ liệu mẫu ít lượt gửi | Tạo thêm lượt check-in / check-out qua `/demo/sp-xe-vao-bai`, `/demo/sp-xe-ra-bai` hoặc màn hình `/gate` |
| Power BI không có trên macOS | Power BI Desktop chỉ chạy trên Windows | Dùng máy ảo Windows, Tableau Desktop, hoặc xuất CSV sang Tableau Public / Excel |
| R14 trống | Không có giao dịch chờ / thất bại | Tạo lệnh nạp trên `/kh/nap-tien` và không xác nhận ở cổng thanh toán mô phỏng |
