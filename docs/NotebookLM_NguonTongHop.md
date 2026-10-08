# TÀI LIỆU NGUỒN TỔNG HỢP: HỆ THỐNG QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE

> **Mục đích:** nguồn duy nhất, đầy đủ về đồ án để nạp vào NotebookLM nhằm (1) sinh **báo cáo dự án dạng Word (.docx)** và (2) thiết kế **slide thuyết trình**.
> Mọi tên bảng, cột, thủ tục, trigger, mã lỗi, số liệu được trích từ mã nguồn thật của repository (`sql/`, `app/`) ngày 08/10/2026. Phụ lục A, B, C được sinh tự động từ mã nguồn.
> **Bố cục báo cáo (PHẦN A) theo đúng mẫu báo cáo đồ án Quản lý Thông tin** (`BaoCao_Nhom7_1.pdf`): Trang bìa → Báo cáo tóm tắt → Mục lục → Danh mục bảng → Danh mục hình → Chương 1 Tổng quan → Chương 2 Phân tích và thiết kế → Chương 3 Quản lý thông tin → Chương 4 Demo → Chương 5 Kết luận → Tài liệu tham khảo.

## HƯỚNG DẪN DÀNH CHO NOTEBOOKLM

- **Khi tạo báo cáo Word:** dùng **PHẦN A** làm báo cáo, giữ nguyên thứ tự trang, tên chương, số mục, số và tên Bảng / Hình. Mỗi bảng có chú thích "Bảng N. ..." đặt **dưới** bảng; mỗi hình có chú thích "Hình N. ..." đặt **dưới** hình (như mẫu). Các mục ghi "(chi tiết)" có thể rút gọn nếu báo cáo quá dài, nhưng không bỏ bảng tóm tắt có đánh số.
- **Hình ảnh:** NotebookLM không tự chụp được màn hình. Mỗi chỗ `[HÌNH: ...]` là khung chờ ảnh – giữ nguyên chú thích và mô tả ảnh cần chụp để nhóm dán ảnh sau.
- **Khi tạo slide:** dùng **PHẦN B** (dàn ý slide, lộ trình demo, câu hỏi phản biện) kết hợp nội dung PHẦN A.
- Chỉ dùng thông tin trong tài liệu này. Không tự thêm tên đối tượng CSDL, số liệu, mã lỗi, tính năng không có ở đây.
- Chỗ ghi **[CẦN BỔ SUNG]** là thông tin nhóm chưa cung cấp (họ tên, MSSV, giảng viên…): giữ nguyên nhãn, không tự bịa.
- Ngôn ngữ: tiếng Việt; giữ nguyên tên kỹ thuật ở dạng `code`.
- File đặc tả cũ (`docs/Dac Ta Nghiep Vu - Updated.docx`) còn ghi "SHA-256" và "3 vai trò"; thông tin đúng là **SHA2_512 có salt** và **4 vai trò**. Ưu tiên tài liệu này.

---

# PHẦN A – NỘI DUNG BÁO CÁO (THEO MẪU)

## TRANG BÌA

ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH
TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN
KHOA KHOA HỌC VÀ KỸ THUẬT THÔNG TIN [CẦN BỔ SUNG: xác nhận khoa]
---------

**BÁO CÁO ĐỒ ÁN QUẢN LÝ THÔNG TIN**

**XÂY DỰNG HỆ THỐNG CƠ SỞ DỮ LIỆU QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE**

Sinh viên thực hiện:
[CẦN BỔ SUNG: MSSV - Họ và tên, mỗi thành viên một dòng]

Giảng viên:
[CẦN BỔ SUNG: học hàm / học vị và họ tên giảng viên]

Thành phố Hồ Chí Minh, tháng 10 năm 2026

---

## BÁO CÁO TÓM TẮT

**1. Tiêu đề báo cáo:** XÂY DỰNG HỆ THỐNG CƠ SỞ DỮ LIỆU QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE

**2. Danh sách thành viên**

| MSSV | Họ tên | Ghi chú |
|---|---|---|
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nhóm trưởng |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | |

> Số dòng tạm theo README (nhóm 10 thành viên) – nhóm điều chỉnh theo thực tế. Tác giả commit Git để tham khảo: Lê Thanh Tú (25730084), Nguyễn Đông Triều (25730078), Trần Thủy Tiên, Ngô Võ Xuân Trường, Đặng Hồng Phong (24730055), Nguyễn Tú (25730085), tài khoản 25730082, Tuấn, nvat96.

**3. Nội dung chi tiết**

Nội dung 1:
+ Nghiên cứu đề tài, mô tả quy trình các nghiệp vụ của chuỗi bãi đỗ xe
+ Phân tích cấu trúc database và các stored procedure, trigger, function, cursor có thể áp dụng
+ Overview toàn bộ luồng nghiệp vụ, chia task
+ Tổng hợp báo cáo

Nội dung 2:
+ Xây dựng mô hình ERD, thiết kế 21 bảng, khóa chính / khóa ngoại, ràng buộc CHECK / UNIQUE, chỉ mục
+ Kiểm tra quan hệ dữ liệu, gộp script tổng `QL_BaiDoXe_FullScript.sql`
+ Chuẩn bị slide các mục liên quan

Nội dung 3:
+ Xây dựng dữ liệu mẫu 5 bãi đỗ (file Excel nguồn → `02_sample_data.sql`): bãi, biểu phí, ô đỗ, thẻ, nhân viên, khách hàng, vé tháng, lượt gửi, sự cố
+ Dữ liệu mẫu cổng khách hàng: tài khoản, ví, sổ cái, ủy quyền, thông báo
+ Chuẩn bị slide các mục liên quan

Nội dung 4:
+ Xây dựng nghiệp vụ check-in / check-out: `sp_XeVaoBai`, `sp_XeRaBai`, `f_TimSlotTrong`, `f_TinhTienGuiXe`
+ Xây dựng trigger cổng: `trg_KiemTraCheckIn`, `trg_ChanSuDungVeHetHan`, `trg_KiemTraBaiApDungVeThang`, `trg_DongBoTrangThaiSlot`
+ Chạy demo check-in, check-out, chặn thẻ lỗi
+ Chuẩn bị slide các mục liên quan

Nội dung 5:
+ Xây dựng nghiệp vụ vé tháng: đăng ký (transaction), gia hạn (lõi dùng chung), báo mất thẻ, cấp lại thẻ cho vé mới
+ Chạy demo các nghiệp vụ vé tháng
+ Chuẩn bị slide các mục liên quan

Nội dung 6:
+ Xây dựng các function và cursor: cảnh báo hạn vé, tổng kết doanh thu chuỗi, tự động gia hạn, đối soát ví
+ Xây dựng view bốt kiểm soát cổng và sơ đồ bãi thời gian thực
+ Chuẩn bị slide các mục liên quan

Nội dung 7:
+ Xây dựng các view báo cáo BI: doanh thu theo bãi / ngày / tháng / phương thức, công suất, xếp hạng, lưu lượng theo giờ, loại xe, sự cố, ví điện tử, bảo mật tài khoản
+ Xây dựng dashboard Power BI / Tableau từ các view [CẦN BỔ SUNG nếu nhóm có làm]
+ Chuẩn bị slide các mục liên quan

Nội dung 8:
+ Xây dựng cổng khách hàng: tài khoản, ví điện tử, sổ cái bất biến, nạp tiền 2 pha, gia hạn bằng ví, chia sẻ vé theo vai trò
+ Chạy demo cổng khách hàng
+ Chuẩn bị slide các mục liên quan

Nội dung 9:
+ Xây dựng an toàn thông tin: RBAC 4 role, Row-Level Security, băm mật khẩu SHA2_512 có salt, khóa tài khoản khi dò mật khẩu
+ Xây dựng kịch bản sao lưu / phục hồi, BULK INSERT
+ Chuẩn bị slide các mục liên quan

Nội dung 10:
+ Xây dựng website demo Flask (giao diện nhân viên và cổng khách hàng `/kh`)
+ Xây dựng 21 kịch bản demo, chạy demo full luồng, kiểm thử
+ Chuẩn bị slide tổng

**4. Phân công công việc**

| MSSV | Họ tên | Nội dung được phân công |
|---|---|---|
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 1 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 2 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 3 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 4 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 5 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 6 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 7 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 8 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 9 |
| [CẦN BỔ SUNG] | [CẦN BỔ SUNG] | Nội dung 10 |

---

## MỤC LỤC

CHƯƠNG 1: TỔNG QUAN
  1. Giới thiệu
  2. Mục tiêu, phạm vi đề tài
  3. Quy trình nghiệp vụ chính
    3.1. Nghiệp vụ quản lý bãi đỗ xe
    3.2. Nghiệp vụ quản lý nhân viên và tài khoản
    3.3. Nghiệp vụ quản lý loại xe và biểu phí
    3.4. Nghiệp vụ quản lý vị trí đỗ xe
    3.5. Nghiệp vụ quản lý thẻ xe
    3.6. Nghiệp vụ quản lý khách hàng và vé tháng
    3.7. Nghiệp vụ check-in xe vào bãi
    3.8. Nghiệp vụ check-out xe ra bãi và tính phí
    3.9. Nghiệp vụ xử lý sự cố và báo mất thẻ
    3.10. Nghiệp vụ quản lý vận hành (giám sát, đối soát)
    3.11. Nghiệp vụ quản trị (báo cáo doanh thu và vận hành)
    3.12. Nghiệp vụ tài khoản cổng khách hàng
    3.13. Nghiệp vụ ví điện tử và nạp tiền
    3.14. Nghiệp vụ gia hạn online và tự động gia hạn
    3.15. Nghiệp vụ chia sẻ vé
CHƯƠNG 2: PHÂN TÍCH VÀ THIẾT KẾ
  1. Chức năng hệ thống
  2. Mô hình cơ sở dữ liệu
    2.1. Thiết kế bảng (chi tiết)
  3. Ràng buộc về mặt dữ liệu
    3.1. Quy tắc nghiệp vụ và công thức (chi tiết)
  4. Luồng xử lý nghiệp vụ trên cơ sở dữ liệu
    4.1. Xe vào bãi (check-in)
    4.2. Xe ra bãi (check-out)
    4.3. Đăng ký vé tháng tại quầy
    4.4. Gia hạn vé (lõi dùng chung `sp_GiaHanVe_Core`)
    4.5. Báo mất thẻ
    4.6. Khách tạo tài khoản và đăng nhập
    4.7. Nạp tiền 2 pha
    4.8. Gia hạn online bằng ví
    4.9. Chia sẻ vé
    4.10. Tự động gia hạn và đối soát (chạy định kỳ)
    4.11. Hoàn tiền
  5. Dữ liệu mẫu
    5.1. Bãi đỗ
    5.2. Biểu phí (giá giờ / giá vé tháng, ₫)
    5.3. Nhân sự và tài khoản nhân viên
    5.4. Khách hàng và vé tháng
    5.5. Cổng khách hàng
CHƯƠNG 3: QUẢN LÝ THÔNG TIN
  1. Xử lý thông tin
    1.1. Store procedure
    1.2. Trigger
    1.3. Function
    1.4. Cursor
    1.5. Report
    1.6. Mã lỗi nghiệp vụ
  2. An toàn thông tin
    2.1. RBAC – 4 role
    2.2. Bảo vệ dữ liệu khách hàng – 3 lớp
    2.3. Mật khẩu và đăng nhập
    2.4. Sổ cái ví bất biến
    2.5. Bảo mật tầng web
    2.6. Sao lưu, phục hồi và nạp dữ liệu hàng loạt (`09_backup_restore.sql`, chạy riêng)
CHƯƠNG 4: DEMO
  1. Check-in xe vào bãi và tự cấp ô đỗ
  2. Check-out xe ra bãi và tính phí
  3. Đăng ký vé tháng trong transaction
  4. Gia hạn vé tháng tại quầy
  5. Báo mất thẻ và tự lập biên bản sự cố
  6. Cấp lại thẻ xe cho vé tháng mới
  7. Đăng nhập nhân viên, mật khẩu SHA2_512 có salt
  8. Chặn check-in thẻ bị khóa / mất và bãi đầy
  9. Chặn vé tháng quá hạn
  10. Chặn vé tháng gửi sai bãi áp dụng
  11. Tính tiền gửi xe và tìm ô đỗ trống bằng function
  12. Cursor quét hạn vé tháng và tổng kết doanh thu chuỗi
  13. Khách hàng tự tạo tài khoản
  14. Khóa tài khoản khi dò mật khẩu
  15. Nạp tiền 2 pha và callback lặp
  16. Khách tự gia hạn vé bằng số dư ví
  17. Chặn số dư ví âm
  18. Row-Level Security cô lập dữ liệu khách hàng
  19. Chia sẻ vé theo vai trò
  20. Tự động gia hạn vé bằng cursor và savepoint
  21. Sổ cái giao dịch bất biến và hoàn tiền
  22. Bốt kiểm soát cổng vào / ra
  23. Sơ đồ bãi đỗ thời gian thực
  24. Report doanh thu và xếp hạng bãi
  25. Report công suất, lưu lượng và loại xe
  26. Report vé tháng sắp hết hạn và sự cố
  27. Report thanh toán và ví điện tử
  28. Nghiệp vụ nhân viên: khách hàng và thanh toán
  29. Cổng khách hàng trên web
  30. Sao lưu và phục hồi cơ sở dữ liệu
  Tổng hợp kết quả kiểm thử
CHƯƠNG 5: KẾT LUẬN
  Hạn chế
  Hướng phát triển
TÀI LIỆU THAM KHẢO

---

## DANH MỤC BẢNG

Bảng 1. Mục tiêu, phạm vi đề tài
Bảng 2. Các chức năng chính
Bảng 3. Các table trong cơ sở dữ liệu
Bảng 4. Ràng buộc về mặt dữ liệu
Bảng 5. Danh sách store procedure
Bảng 6. Danh sách trigger
Bảng 7. Danh sách function
Bảng 8. Danh sách cursor
Bảng 9. Danh sách view vận hành cơ bản
Bảng 10. Danh sách view báo cáo BI (report)
Bảng 11. Danh sách view cổng khách hàng
Bảng 12. Danh sách mã lỗi nghiệp vụ
Bảng 13. Phân quyền theo role SQL Server
Bảng 14. Hàm lọc Row-Level Security

---

## DANH MỤC HÌNH VẼ

Hình 1. Mô hình ERD
Hình 2. Công suất và ô đỗ bãi Lê Lai trước khi check-in
Hình 3. Kết quả thực thi sp_XeVaoBai
Hình 4. Công suất, ô đỗ và lượt gửi sau khi check-in
Hình 5. Danh sách xe đang đỗ trước khi check-out
Hình 6. Hóa đơn check-out – tiền gửi tính tự động
Hình 7. Lượt gửi, ô đỗ và số xe sau khi check-out
Hình 8. Dữ liệu khách hàng, thẻ, vé, hóa đơn trước khi đăng ký
Hình 9. Kết quả đăng ký vé tháng
Hình 10. Khách mới, thẻ, vé và hóa đơn sau khi đăng ký
Hình 11. Vé V0001 và hóa đơn trước khi gia hạn
Hình 12. Kết quả gia hạn vé tháng
Hình 13. Hạn dùng và hóa đơn sau khi gia hạn
Hình 14. Thẻ THE0001 và nhật ký sự cố trước khi báo mất
Hình 15. Thẻ sau khi báo mất và biên bản sự cố do trigger tạo
Hình 16. Thẻ THE0022 và tra cứu bốt cổng trước khi cấp lại
Hình 17. Kết quả 4 bước cấp lại thẻ
Hình 18. Lịch sử vé của thẻ THE0022 sau khi cấp lại
Hình 19. Cùng mật khẩu nhưng khác salt và khác hash
Hình 20. Kết quả đăng nhập và các lần bị từ chối
Hình 21. Thẻ THE0006 và số lượt gửi trước khi quét
Hình 22. Trigger chặn check-in thẻ lỗi (50002)
Hình 23. Vé V0003 đã hết hạn
Hình 24. Trigger chặn vé tháng quá hạn (50003)
Hình 25. Phạm vi áp dụng của hai vé tháng
Hình 26. Trigger chặn vé gửi sai bãi (50004)
Hình 27. Biểu phí giờ và ô trống bãi Lê Lai
Hình 28. Kết quả các function tính tiền và tìm ô đỗ
Hình 29. Kết quả cursor quét hạn vé tháng
Hình 30. Kết quả cursor tổng kết doanh thu chuỗi
Hình 31. Trạng thái vé và đối chiếu doanh thu sau cursor
Hình 32. Hồ sơ KH0005 trước khi đăng ký tài khoản
Hình 33. Kết quả đăng ký tài khoản hai lần
Hình 34. Tài khoản, ví và thông báo sau khi đăng ký
Hình 35. Kết quả 6 lần đăng nhập
Hình 36. Tài khoản bị khóa, nhật ký và thông báo bảo mật
Hình 37. Ví và sổ cái của KH0001 trước khi nạp
Hình 38. Kết quả nạp tiền 2 pha và callback lặp
Hình 39. Ví, sổ cái và thông báo sau khi nạp
Hình 40. Vé, ví và giá gia hạn trước khi gia hạn online
Hình 41. Kết quả gia hạn online bằng ví
Hình 42. Ví KH0004 và giá gia hạn trước thao tác
Hình 43. Hai lớp chặn số dư âm (50031)
Hình 44. Góc nhìn quản trị trước khi áp RLS
Hình 45. Góc nhìn từng khách hàng dưới RLS
Hình 46. Role, user và security policy RLS
Hình 47. Vé V0004 và ma trận vai trò × quyền
Hình 48. Kết quả chia sẻ vé và kiểm tra quyền
Hình 49. Vé bật tự động gia hạn trước khi chạy cursor
Hình 50. Kết quả cursor tự động gia hạn
Hình 51. Vé, hóa đơn và thông báo sau khi tự động gia hạn
Hình 52. Sổ cái và ví VI0004 trước thao tác
Hình 53. Kết quả các thao tác trên sổ cái
Hình 54. Sổ cái và số dư sau khi hoàn tiền
Hình 55. Bốt kiểm soát cổng – tra cứu thẻ
Hình 56. Bảng đèn cổng, xe chờ ra và nhật ký vào / ra
Hình 57. Sơ đồ ô đỗ thời gian thực
Hình 58. Tổng hợp khu vực và tổng quan công suất bãi
Hình 59. Report doanh thu theo bãi
Hình 60. Report xếp hạng bãi
Hình 61. Report doanh thu thể hiện qua Power BI / Tableau
Hình 62. Report công suất bãi đỗ và tổng quan chuỗi
Hình 63. Report lưu lượng xe theo giờ
Hình 64. Report thống kê theo loại xe
Hình 65. Report vé tháng sắp hết hạn
Hình 66. Report nhật ký sự cố
Hình 67. Report doanh thu theo phương thức thanh toán
Hình 68. Report tổng quan ví điện tử và giao dịch cần xử lý
Hình 69. Màn hình nhân viên – tài khoản khách hàng
Hình 70. Report giám sát bảo mật tài khoản khách hàng
Hình 71. Cổng khách hàng – đăng nhập
Hình 72. Cổng khách hàng – tổng quan ví và vé
Hình 73. Cổng thanh toán mô phỏng
Hình 74. Cổng khách hàng – sao kê ví và chia sẻ vé
Hình 75. Sao lưu Full và Differential
Hình 76. Khôi phục cơ sở dữ liệu

---

## CHƯƠNG 1: TỔNG QUAN

### 1. Giới thiệu

Trong hoạt động vận hành chuỗi nhiều bãi đỗ xe thuộc các địa bàn khác nhau, việc quản lý ô đỗ, thẻ chip, lượt xe ra vào, vé tháng, biểu phí theo từng bãi và theo dõi sức chứa thời gian thực là nghiệp vụ cốt lõi, ảnh hưởng trực tiếp đến hiệu quả vận hành, doanh thu và an ninh. Nếu quản lý thủ công bằng sổ sách hoặc file Excel rời rạc, rất dễ xảy ra các vấn đề như: sai lệch số lượng xe đang đỗ, khó kiểm soát chỗ trống theo loại phương tiện, tính phí sai hoặc gian lận thu tiền, khó tra cứu lịch sử vào / ra, quên nhắc vé tháng hết hạn, khó đối soát sự cố mất thẻ; khách vé tháng phải ra quầy để gia hạn.

Vì vậy, đề tài xây dựng một hệ thống cơ sở dữ liệu quan hệ trên Microsoft SQL Server nhằm quản lý tập trung toàn bộ thông tin vận hành của **chuỗi 5 bãi đỗ xe tại TP.HCM**: Lê Lai - Bến Thành (Quận 1), Hai Bà Trưng (Quận 3), Landmark 81 (Bình Thạnh), TCP Park - Sân bay Tân Sơn Nhất (Tân Bình) và SC VivoCity (Quận 7). Hệ thống quản lý danh mục bãi đỗ, loại xe và biểu phí theo từng bãi, vị trí ô đỗ, thẻ chip, nhân viên và tài khoản, khách hàng, vé tháng, lượt gửi (check-in / check-out), hóa đơn vé tháng, nhật ký sự cố; đồng thời có **cổng khách hàng** cho khách vé tháng với ví điện tử trả trước, nạp tiền, tự gia hạn và chia sẻ vé.

Toàn bộ logic nghiệp vụ quan trọng (tìm ô trống, tính tiền, đồng bộ trạng thái ô đỗ và sức chứa, chặn thẻ lỗi / vé hết hạn, cập nhật số dư ví, phân quyền) được đẩy xuống tầng cơ sở dữ liệu thông qua Stored Procedure, Trigger, Function, Cursor, View và cơ chế bảo mật của SQL Server, đảm bảo tính nhất quán và tự động hóa cao. Website Flask chỉ dùng để demo dữ liệu.

**Quy mô CSDL:** 21 bảng · 37 view · 23 stored procedure + 4 procedure dùng cursor · 16 trigger · 12 function (+ 4 hàm lọc Row-Level Security) · 4 role · 1 sequence · 21 kịch bản demo.

### 2. Mục tiêu, phạm vi đề tài

| Nội dung | Mô tả |
|---|---|
| Mục tiêu | Quản lý tập trung chuỗi nhiều bãi đỗ xe: danh mục bãi / ô đỗ / thẻ / loại xe và biểu phí, lượt gửi vào – ra, vé tháng, tính phí lũy tiến, cảnh báo hết hạn, sự cố, ví điện tử của khách, báo cáo doanh thu và công suất theo từng bãi. |
| Phạm vi | Thiết kế và cài đặt CSDL quan hệ trên Microsoft SQL Server (T-SQL); sử dụng đầy đủ Stored Procedure, Trigger, Function, Cursor, View, Transaction, RBAC, Row-Level Security, Backup / Restore; demo bằng website Flask kết nối trực tiếp database. |
| Đối tượng sử dụng | Ban giám đốc / quản trị, quản lý bãi (kiêm kế toán, báo cáo), bảo vệ trực cổng, khách hàng vé tháng (qua cổng khách hàng). |
| Ngoài phạm vi | Không tích hợp cổng thanh toán thật (dùng cổng thanh toán mô phỏng), không nhận diện biển số tự động bằng camera, không đặt chỗ trước, không xử lý kế toán tổng hợp chuyên sâu. |

*Bảng 1. Mục tiêu, phạm vi đề tài*

### 3. Quy trình nghiệp vụ chính

Hệ thống quản lý các danh mục nền tảng (bãi đỗ xe, nhân viên và tài khoản, loại xe và biểu phí, vị trí đỗ, thẻ xe, khách hàng) và các nhóm nghiệp vụ lõi: xe vào bãi làm tăng số xe và chiếm ô đỗ; xe ra bãi giải phóng ô đỗ và tính phí; đăng ký / gia hạn vé tháng; báo mất thẻ và xử lý sự cố; giám sát vận hành thời gian thực; báo cáo quản trị; và các nghiệp vụ của cổng khách hàng (tài khoản, ví, gia hạn online, chia sẻ vé).

#### 3.1. Nghiệp vụ quản lý bãi đỗ xe

Bãi đỗ xe là đơn vị quản lý cơ bản. Mỗi bãi là một chi nhánh độc lập với mã bãi, tên bãi (không trùng), địa chỉ, sức chứa và số lượng xe hiện tại. Mỗi bãi có nhiều khu vực / tầng, nhiều ô đỗ, biểu phí riêng cho từng loại xe và kho thẻ riêng. Khi xe check-in thành công, số lượng xe hiện tại tăng; khi check-out, số lượng giảm – việc cập nhật do trigger đồng bộ tự động.

Điều kiện: `0 ≤ Số lượng hiện tại ≤ Sức chứa`; `Sức chứa > 0`.

Chỉ số theo dõi:
- Số chỗ trống = Sức chứa − Số lượng hiện tại
- Tỷ lệ lấp đầy = (Số lượng hiện tại / Sức chứa) × 100%

#### 3.2. Nghiệp vụ quản lý nhân viên và tài khoản

Nhân viên gồm 3 chức vụ: Giám đốc điều hành (toàn chuỗi), Quản lý bãi, Bảo vệ (gắn với bãi phụ trách). Mỗi nhân viên có thể có tài khoản đăng nhập; mật khẩu được băm **SHA2_512 kèm salt ngẫu nhiên 16 byte riêng từng tài khoản**. Tài khoản có trạng thái Hoạt động / Bị khóa. Phân quyền RBAC theo 4 vai trò SQL Server: `r_Admin` (toàn quyền), `r_QuanLyBai` (quản trị chi nhánh, tài chính, báo cáo), `r_BaoVe` (chỉ check-in / check-out, báo mất thẻ, xem bốt cổng và sơ đồ), `r_KhachHang` (cổng khách hàng).

#### 3.3. Nghiệp vụ quản lý loại xe và biểu phí

Mỗi loại xe tại một bãi được xác định bởi **mã loại xe kết hợp mã bãi** (khóa chính hỗn hợp), nên cùng loại xe có giá khác nhau giữa các bãi. Thông tin lưu: mã loại xe (OT – ô tô 4-7 chỗ, XM – xe máy, XD – xe đạp / xe điện), tên loại, đơn giá gửi theo giờ, giá vé tháng, bãi áp dụng. Giá phải lớn hơn 0.

#### 3.4. Nghiệp vụ quản lý vị trí đỗ xe

Mỗi ô đỗ thuộc một bãi, một loại xe và một khu vực / tầng; trạng thái chỉ nhận hai giá trị Trống hoặc Đã đỗ. Hệ thống tự tìm ô trống phù hợp loại xe khi check-in và tự chuyển trạng thái khi xe vào / ra. Sơ đồ mặt bằng thời gian thực hiển thị từng ô, khu vực, loại phương tiện và xe đang chiếm chỗ.

#### 3.5. Nghiệp vụ quản lý thẻ xe

Thẻ chip thuộc bãi phát hành, có loại Lượt hoặc Tháng, trạng thái Hoạt động / Bị khóa / Mất. Thẻ lượt chỉ dùng tại bãi phát hành. Thẻ của vé tháng đã hết hạn có thể được **cấp lại cho vé mới**; tại một thời điểm mỗi thẻ chỉ gắn với một vé còn dùng.

#### 3.6. Nghiệp vụ quản lý khách hàng và vé tháng

Khi đăng ký vé tháng, hệ thống lưu hồ sơ khách (họ tên, SĐT, email, CMND/CCCD – SĐT và CCCD không trùng) và thông tin vé: mã vé, mã thẻ, khách hàng, biển số, loại xe, ngày đăng ký, ngày hết hạn, trạng thái (Hoạt động / Tạm khóa / Hết hạn) và bãi áp dụng. Vé có thể **gắn một bãi** (chỉ gửi tại bãi đó) hoặc **toàn chuỗi** (`ALL`, gửi mọi bãi).

Đăng ký vé tháng thực hiện nhiều bước trong **một transaction**: thêm hoặc cập nhật khách hàng → chuyển thẻ sang loại Tháng → tạo vé và tính hạn → tạo hóa đơn. Lỗi ở bất kỳ bước nào thì toàn bộ được rollback.

Công thức:
- Tổng tiền đăng ký = Giá vé tháng (theo loại xe, bãi tính giá) × Số tháng đóng trước
- Số tiền gia hạn = Giá vé tháng × Số tháng gia hạn
- Bãi tính giá: vé gắn bãi → bãi áp dụng; vé `ALL` → bãi bán vé hoặc bãi phát hành thẻ
- Hạn mới khi gia hạn: vé còn hạn cộng dồn từ ngày hết hạn cũ; vé đã quá hạn tính từ hôm nay

Gia hạn có 3 kênh dùng chung một lõi xử lý: tại quầy, online bằng số dư ví, tự động bằng số dư ví.

#### 3.7. Nghiệp vụ check-in xe vào bãi

Hệ thống tự động: kiểm tra thẻ còn hiệu lực (không bị khóa / mất); kiểm tra vé tháng còn hạn và đúng bãi áp dụng (nếu là thẻ tháng); kiểm tra thẻ lượt đúng bãi phát hành; kiểm tra thẻ chưa có lượt đang mở; kiểm tra bãi còn chỗ; tìm ô đỗ trống phù hợp loại xe; tạo bản ghi lượt gửi; trigger chuyển ô sang Đã đỗ và tăng số lượng hiện tại của bãi.

#### 3.8. Nghiệp vụ check-out xe ra bãi và tính phí

Hệ thống tìm lượt đang mở của thẻ; thẻ Tháng → miễn phí lượt gửi; thẻ Lượt → tính phí; cập nhật thời gian ra và tiền gửi; trigger giải phóng ô về Trống và giảm số lượng hiện tại; cảnh báo nếu biển số lúc ra khác lúc vào.

Công thức tính tiền gửi xe lượt:
- Nếu thời gian đỗ ≤ 15 phút: miễn phí (0 ₫)
- Tổng số phút = Thời gian ra − Thời gian vào (tính bằng phút)
- Số giờ = CEILING(Tổng số phút / 60) (làm tròn lên block giờ tiếp theo)
- Tiền gửi = Số giờ × Đơn giá giờ (theo loại xe và bãi)
- Ví dụ: ô tô gửi 5 giờ tại Landmark 81: 5 × 30.000 = 150.000 ₫; xe máy 61 phút tại Lê Lai: 2 × 6.000 = 12.000 ₫

#### 3.9. Nghiệp vụ xử lý sự cố và báo mất thẻ

Khi thẻ được báo mất: thẻ chuyển sang Mất; vé tháng đang dùng của thẻ chuyển Tạm khóa; hệ thống tự ghi biên bản vào lịch sử sự cố với mức phạt mặc định 50.000 ₫, trạng thái Chờ xử lý; thẻ mất không check-in, không gia hạn, không cấp cho vé mới. Hệ thống hỗ trợ ghi nhận các sự cố khác với trạng thái xử lý Chờ xử lý / Đang giải quyết / Đã giải quyết.

#### 3.10. Nghiệp vụ quản lý vận hành (giám sát, đối soát)

Hệ thống chỉ cấp ô đỗ khi đủ điều kiện và cung cấp giám sát thời gian thực:
- Tra cứu thẻ tại bốt cổng: quyết định mở barrier hoặc từ chối kèm lý do, chiều quét kế tiếp, cảnh báo an ninh.
- Bảng đèn tín hiệu cổng theo loại xe: XANH (còn chỗ), VÀNG (còn ≤ 2 ô), ĐỎ (bãi đầy hoặc hết ô loại xe), kèm ô đỗ gợi ý.
- Danh sách xe chờ ra với tiền tạm tính và cờ lệch biển số; nhật ký 200 sự kiện vào / ra.
- Sơ đồ chi tiết từng ô, tổng hợp theo khu vực / tầng, tổng quan công suất từng bãi.
- Đối soát: số lượng xe hiện tại của bãi phải khớp số lượt gửi đang mở; trạng thái từng ô phải khớp việc có / không có lượt gửi đang chiếm ô (có cờ cảnh báo lệch).

Hệ thống lưu toàn bộ lịch sử lượt gửi và nhật ký sự cố, phục vụ truy vết, đối chiếu và báo cáo.

#### 3.11. Nghiệp vụ quản trị (báo cáo doanh thu và vận hành)

Tổng hợp doanh thu theo từng bãi gồm doanh thu xe gửi lượt và doanh thu vé tháng (tách kênh Tại quầy / Online / Tự động).
- Doanh thu lượt = SUM(Tiền gửi)
- Doanh thu tháng = SUM(Số tiền hóa đơn)
- Tổng doanh thu = Doanh thu lượt + Doanh thu tháng

Các báo cáo chính: công suất và tỷ lệ lấp đầy; doanh thu theo bãi / ngày / tháng / phương thức thanh toán; xếp hạng bãi; lưu lượng theo giờ (giờ cao điểm); cơ cấu loại xe; xe đang đỗ; vé sắp hoặc đã hết hạn; nhật ký sự cố và tiền phạt; tổng quan ví điện tử; giám sát bảo mật tài khoản khách. Hằng ngày hệ thống quét hạn vé (khóa vé quá hạn, cảnh báo vé còn ≤ 3 ngày) và tổng kết doanh thu chuỗi bằng cursor.

#### 3.12. Nghiệp vụ tài khoản cổng khách hàng

Khách đã có hồ sơ vé tháng tại quầy tự tạo tài khoản bằng **SĐT + CCCD** khớp hồ sơ; tên đăng nhập là SĐT; mật khẩu tối thiểu 8 ký tự gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt. Khi tạo tài khoản, hệ thống tạo kèm ví số dư 0 ₫. Đăng nhập sai **5 lần trong 15 phút** thì tài khoản bị khóa tạm 15 phút và khách nhận thông báo bảo mật; sai tên đăng nhập và sai mật khẩu trả cùng một thông báo để chống dò tài khoản. Nhân viên có thể mở khóa tài khoản.

#### 3.13. Nghiệp vụ ví điện tử và nạp tiền

Mỗi khách có một ví trả trước; số dư không bao giờ âm và **chỉ thay đổi thông qua sổ cái giao dịch** (không sửa, không xóa giao dịch). Nạp tiền online gồm 2 pha: (1) tạo lệnh nạp ở trạng thái Chờ xử lý; (2) cổng thanh toán gọi callback xác nhận → Thành công thì cộng tiền. Callback gửi lặp lại không cộng tiền lần nữa. Tiền mặt chỉ nạp tại quầy.
- Phí giao dịch = ROUND(Số tiền × Phí % của phương thức / 100)
- Số tiền nạp ≥ mức tối thiểu của phương thức (10.000 hoặc 50.000 ₫)
- Tổng nạp trong ngày (gồm lệnh đang chờ) ≤ hạn mức ngày (mặc định 20.000.000 ₫)
- Lệnh nạp chờ quá 30 phút được đối soát chuyển Thất bại

Hoàn tiền được ghi bằng **giao dịch đối ứng**, chỉ áp dụng cho khoản thanh toán chưa xuất hóa đơn (trừ trùng / trừ nhầm).

#### 3.14. Nghiệp vụ gia hạn online và tự động gia hạn

Khách tự gia hạn vé bằng số dư ví (1–12 tháng): trừ ví + gia hạn vé + lập hóa đơn kênh Online trong một transaction. Khách có thể bật tự động gia hạn: vé còn ≤ 3 ngày được hệ thống gia hạn bằng số dư ví (kênh Tự động); vé thiếu tiền chỉ bỏ qua riêng vé đó và khách nhận thông báo nạp thêm.

#### 3.15. Nghiệp vụ chia sẻ vé

Chủ vé chia sẻ vé cho tài khoản khác (người nhà, tài xế, kế toán) với vai trò hạn chế: Thành viên (xem vé, xem lịch sử, báo mất thẻ) hoặc Chỉ xem lịch sử. Mỗi vé chia sẻ tối đa 3 tài khoản cùng lúc; không chia sẻ vé hết hạn; chỉ chủ vé được gia hạn, cài tự gia hạn và chia sẻ. Chủ vé thu hồi chia sẻ bất kỳ lúc nào (giữ lịch sử).

---

## CHƯƠNG 2: PHÂN TÍCH VÀ THIẾT KẾ

### 1. Chức năng hệ thống

| Nhóm chức năng | Mô tả |
|---|---|
| Danh mục | Quản lý bãi đỗ, loại xe và biểu phí theo bãi, vị trí ô đỗ, thẻ xe, phương thức thanh toán. |
| Nhân sự và tài khoản | Quản lý nhân viên, tài khoản đăng nhập (SHA2_512 + salt), phân quyền theo 4 role. |
| Vận hành cổng | Check-in tự cấp ô, check-out tự tính phí; chặn thẻ khóa / mất, vé hết hạn, sai bãi, bãi đầy, thẻ đang đỗ. |
| Vé tháng | Đăng ký trong transaction, gia hạn tại quầy, cấp lại thẻ cho vé mới, vé gắn bãi / toàn chuỗi. |
| Sự cố | Báo mất thẻ, tự lập biên bản và tiền phạt, theo dõi trạng thái xử lý. |
| Giám sát realtime | Bốt kiểm soát cổng (tra thẻ, bảng đèn, xe chờ ra, nhật ký), sơ đồ bãi theo ô / khu vực / bãi. |
| Tự động hóa | Cursor quét hạn vé, tổng kết doanh thu, tự động gia hạn, đối soát ví. |
| Báo cáo | 16 view BI: doanh thu, công suất, xếp hạng, lưu lượng, loại xe, sự cố, vé sắp hết hạn, ví, bảo mật tài khoản, tỷ lệ online. |
| Cổng khách hàng | Tài khoản, ví, nạp tiền 2 pha, sao kê, gia hạn bằng ví, tự gia hạn, chia sẻ vé, thông báo, đổi mật khẩu, nhật ký đăng nhập. |
| Nghiệp vụ nhân viên cho ví | Nạp tiền tại quầy, hoàn tiền bằng giao dịch đối ứng, mở khóa tài khoản khách. |
| Quản trị | Phân quyền RBAC, Row-Level Security, import BULK INSERT, backup / restore, khởi tạo CSDL từ web. |

*Bảng 2. Các chức năng chính*

### 2. Mô hình cơ sở dữ liệu

Cơ sở dữ liệu gồm 21 bảng chia hai phân hệ: **vận hành bãi** (11 bảng) và **cổng khách hàng – ví điện tử** (10 bảng). Thiết kế sử dụng khóa chính (kể cả khóa hỗn hợp), khóa ngoại, bảng trung gian cho quan hệ nhiều – nhiều (vai trò × quyền), ràng buộc CHECK / UNIQUE và chỉ mục có lọc.

[HÌNH: Sơ đồ ERD 21 bảng – lấy từ `docs/Parking_lot_ERD.png` (cập nhật đủ 10 bảng cổng khách hàng nếu ảnh cũ chỉ có 11 bảng)]

*Hình 1. Mô hình ERD*

| Bảng | Diễn giải |
|---|---|
| `BAI_DO_XE` | Thông tin chi nhánh bãi đỗ: tên, địa chỉ, sức chứa, số xe hiện tại |
| `NHAN_VIEN` | Hồ sơ nhân viên, chức vụ, bãi phụ trách |
| `TAI_KHOAN` | Tài khoản đăng nhập nhân viên (hash + salt mật khẩu, trạng thái) |
| `LOAI_XE` | Loại xe và biểu phí (giá giờ, giá vé tháng) theo từng bãi – khóa hỗn hợp `(MaLoaiXe, MaBai)` |
| `VI_TRI_DO` | Ô đỗ vật lý: khu vực, loại xe, trạng thái Trống / Đã đỗ |
| `THE_XE` | Thẻ chip theo bãi phát hành: loại Lượt / Tháng, trạng thái |
| `KHACH_HANG` | Hồ sơ khách hàng vé tháng |
| `VE_THANG` | Hợp đồng vé tháng: thẻ, khách, biển số, hạn, phạm vi bãi, cài đặt tự gia hạn |
| `LUOT_GUI` | Nhật ký check-in / check-out, ô đỗ, tiền gửi, vé tháng liên quan |
| `HOA_DON_VE_THANG` | Hóa đơn đăng ký / gia hạn vé: số tháng, số tiền, phương thức, kênh, giao dịch ví |
| `LICHSU_SU_CO` | Biên bản sự cố, tiền phạt, trạng thái xử lý |
| `PHUONG_THUC_THANH_TOAN` | Danh mục phương thức thanh toán: kênh, phí %, mức tối thiểu |
| `TAI_KHOAN_KH` | Tài khoản cổng khách hàng: hash + salt, số lần sai, thời điểm khóa |
| `NHAT_KY_DANG_NHAP` | Nhật ký đăng nhập cổng khách hàng: kết quả, IP, thiết bị |
| `VI_DIEN_TU` | Ví trả trước của khách: số dư, hạn mức nạp ngày, trạng thái |
| `GIAO_DICH` | Sổ cái giao dịch ví (chỉ ghi thêm): nạp, thanh toán, hoàn tiền; số dư trước / sau |
| `THONG_BAO` | Hộp thư thông báo của khách |
| `QUYEN_KH` | Danh mục 9 quyền nghiệp vụ của khách |
| `VAI_TRO_KH` | Danh mục 3 vai trò trên vé: chủ sở hữu, thành viên, chỉ xem lịch sử |
| `VAI_TRO_QUYEN` | Ma trận vai trò × quyền |
| `UY_QUYEN_VE` | Chủ vé chia sẻ vé cho tài khoản khác với vai trò hạn chế |

*Bảng 3. Các table trong cơ sở dữ liệu*

#### 2.1. Thiết kế bảng (chi tiết)

> Danh sách cột đầy đủ với kiểu, NULL, mặc định của từng bảng nằm ở **Phụ lục A**.

##### Nhóm vận hành bãi (11 bảng)

| # | Bảng | Ý nghĩa | Khóa chính | Cột chính | Ràng buộc đáng chú ý |
|---|---|---|---|---|---|
| 1 | `BAI_DO_XE` | Chi nhánh bãi đỗ | `MaBai` | TenBai, DiaChi, SucChua, SoLuongHienTai | `UNIQUE(TenBai)`; `SucChua > 0`; `0 <= SoLuongHienTai <= SucChua` |
| 2 | `NHAN_VIEN` | Hồ sơ nhân viên | `MaNV` | HoTen, ChucVu, SDT, Email, MaBai | FK `MaBai` (NULL = toàn chuỗi); `ChucVu IN ('Giám đốc điều hành','Quản lý bãi','Bảo vệ')`; SĐT duy nhất; email duy nhất khi có |
| 3 | `TAI_KHOAN` | Tài khoản nhân viên | `TenDangNhap` | MatKhauHash VARBINARY(64), MatKhauSalt VARBINARY(16), MaNV, TrangThai | FK `MaNV`; `TrangThai IN ('Hoạt động','Bị khóa')` |
| 4 | `LOAI_XE` | Loại xe và biểu phí theo bãi | `(MaLoaiXe, MaBai)` | TenLoai, DonGiaGio, GiaVeThang | FK `MaBai` ON DELETE CASCADE; giá > 0 |
| 5 | `VI_TRI_DO` | Ô đỗ vật lý | `MaViTri` | KhuVuc, TrangThai, MaLoaiXe, MaBai | FK `(MaLoaiXe, MaBai)` → `LOAI_XE`; `TrangThai IN ('Trống','Đã đỗ')` |
| 6 | `THE_XE` | Thẻ chip RFID | `MaThe` | MaBai (bãi phát hành), LoaiThe, TrangThai, NgayCap | `LoaiThe IN ('Lượt','Tháng')`; `TrangThai IN ('Hoạt động','Bị khóa','Mất')` |
| 7 | `KHACH_HANG` | Khách vé tháng | `MaKH` | HoTen, SDT, Email, CMND_CCCD, NgayTao (V7) | SĐT, CCCD duy nhất; email duy nhất khi có |
| 8 | `VE_THANG` | Hợp đồng vé tháng | `MaVe` | MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung, TuDongGiaHan (V7), SoThangTuDongGiaHan (V7) | `TrangThai IN ('Hoạt động','Tạm khóa','Hết hạn')`; `NgayHetHan >= NgayDangKy`; `MaBaiApDung` = mã bãi hoặc `'ALL'`; `SoThangTuDongGiaHan` 1–12 |
| 9 | `LUOT_GUI` | Nhật ký check-in / check-out | `MaLuot` IDENTITY | MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai, MaVe (V7) | `TienGui >= 0`; `ThoiGianRa IS NULL OR >= ThoiGianVao` |
| 10 | `HOA_DON_VE_THANG` | Hóa đơn đăng ký / gia hạn | `MaHD` | MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai, MaPTTT (V7), KenhThanhToan (V7), MaGD (V7), MaNVThu (V7) | số tháng, số tiền > 0; `KenhThanhToan IN ('Tại quầy','Online','Tự động')` |
| 11 | `LICHSU_SU_CO` | Biên bản sự cố | `MaSuCo` IDENTITY | MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai | `TienPhat >= 0`; `TrangThaiXuLy IN ('Chờ xử lý','Đang giải quyết','Đã giải quyết')` |

**Vì sao `VE_THANG.MaBaiApDung` không có khóa ngoại?** Giá trị đặc biệt `'ALL'` (vé toàn chuỗi) không tồn tại trong `BAI_DO_XE`, nên toàn vẹn tham chiếu được kiểm tra bằng trigger `trg_KiemTraLoaiXe_VeThang` thay cho FOREIGN KEY.

##### Nhóm cổng khách hàng và ví điện tử (10 bảng)

| # | Bảng | Ý nghĩa | Ràng buộc đáng chú ý |
|---|---|---|---|
| 12 | `PHUONG_THUC_THANH_TOAN` | Danh mục phương thức | `LoaiKenh IN ('Tiền mặt','Ngân hàng','Ví điện tử','Thẻ','Số dư ví')`; `PhiPhanTram` 0–10; `SoTienToiThieu >= 0`; `ChoPhepNapVi`; `TrangThai IN ('Hoạt động','Tạm ngưng')` |
| 13 | `TAI_KHOAN_KH` | Tài khoản khách (tách khỏi tài khoản nhân viên) | 1 tài khoản / khách; tên đăng nhập = SĐT, duy nhất; mã `TK####`; salt đúng 16 byte; `SoLanSaiLienTiep`, `KhoaDen`, `LanDangNhapCuoi`; `TrangThai IN ('Hoạt động','Tạm khóa','Đã đóng')` |
| 14 | `NHAT_KY_DANG_NHAP` | Nhật ký đăng nhập | `KetQua IN ('Thành công','Sai mật khẩu','Không tồn tại','Bị khóa')`; lưu IP, thiết bị; `MaTK` NULL khi tên không tồn tại |
| 15 | `VI_DIEN_TU` | Ví trả trước | 1 ví / khách; mã `VI####`; `SoDu >= 0`; `HanMucNapNgay` mặc định 20.000.000 ₫; `TrangThai IN ('Hoạt động','Đóng băng')`; `PhienBan ROWVERSION` |
| 16 | `GIAO_DICH` | Sổ cái ví | Loại × hướng tiền nhất quán (nạp/hoàn = +1, thanh toán = −1); thanh toán phải có `MaVe`; hoàn tiền phải có `MaGDGoc`; `MaThamChieu` duy nhất; `NguoiThucHien IN ('Khách hàng','Nhân viên','Hệ thống')` |
| 17 | `THONG_BAO` | Hộp thư khách | `LoaiTB IN ('Giao dịch','Sắp hết hạn','Hết hạn','Bảo mật','Ủy quyền','Hệ thống')`; `DaDoc` |
| 18 | `QUYEN_KH` | 9 quyền nghiệp vụ | VE.XEM, LICHSU.XEM, VE.GIAHAN, VE.BAOMAT, VI.XEM, VI.NAPTIEN, GIAODICH.XEM, VE.UYQUYEN, VE.TUDONGGIAHAN |
| 19 | `VAI_TRO_KH` | 3 vai trò trên vé | CHU_SO_HUU, THANH_VIEN, XEM_LICH_SU |
| 20 | `VAI_TRO_QUYEN` | Ma trận vai trò × quyền | PK `(MaVaiTro, MaQuyen)` |
| 21 | `UY_QUYEN_VE` | Chia sẻ vé | Không cấp CHU_SO_HUU; `NgayKetThuc >= NgayBatDau`; `TrangThai IN ('Hiệu lực','Đã thu hồi')`; unique có lọc `(MaVe, MaTKDuocUyQuyen) WHERE TrangThai = 'Hiệu lực'` |

**Danh mục phương thức thanh toán (nạp sẵn):**

| Mã | Tên | Kênh | Phí | Tối thiểu | Nạp ví | Trạng thái |
|---|---|---|---|---|---|---|
| TIEN_MAT | Tiền mặt tại quầy | Tiền mặt | 0% | 10.000 | Có (chỉ tại quầy) | Hoạt động |
| CHUYEN_KHOAN | Chuyển khoản ngân hàng | Ngân hàng | 0% | 50.000 | Có | Hoạt động |
| MOMO | Ví MoMo | Ví điện tử | 1,5% | 10.000 | Có | Hoạt động |
| ZALOPAY | Ví ZaloPay | Ví điện tử | 1,2% | 10.000 | Có | Tạm ngưng |
| VNPAY | Cổng VNPay | Ví điện tử | 1,1% | 10.000 | Có | Hoạt động |
| THE_NH | Thẻ ngân hàng (ATM/Visa) | Thẻ | 2% | 50.000 | Có | Hoạt động |
| SO_DU_VI | Số dư ví SmartPark | Số dư ví | 0% | 0 | Không | Hoạt động |

**Ma trận vai trò × quyền trên vé:**

| Quyền | CHU_SO_HUU | THANH_VIEN | XEM_LICH_SU |
|---|:-:|:-:|:-:|
| VE.XEM – xem vé | ✔ | ✔ | ✔ |
| LICHSU.XEM – xem lịch sử đỗ | ✔ | ✔ | ✔ |
| VE.BAOMAT – báo mất thẻ | ✔ | ✔ | |
| VE.GIAHAN – gia hạn bằng ví | ✔ | | |
| VE.TUDONGGIAHAN – bật/tắt tự gia hạn | ✔ | | |
| VE.UYQUYEN – chia sẻ / thu hồi | ✔ | | |

Vai trò CHU_SO_HUU không lưu trong `UY_QUYEN_VE` mà suy ra từ `VE_THANG.MaKH`. Quyền ví và giao dịch (VI.*, GIAODICH.*) luôn chỉ áp dụng trên ví của chính tài khoản.

##### Chỉ mục và đối tượng phụ trợ

| Đối tượng | Định nghĩa | Mục đích |
|---|---|---|
| `UX_VeThang_MaThe_ConDung` | UNIQUE `VE_THANG(MaThe) WHERE TrangThai <> N'Hết hạn'` | Mỗi thẻ chỉ gắn một vé còn dùng; vé hết hạn không giữ thẻ nên thẻ được cấp lại cho vé mới |
| `IX_LuotGui_DangDo` | `LUOT_GUI(MaBai, MaViTri) INCLUDE (MaThe, BienSo, ThoiGianVao) WHERE ThoiGianRa IS NULL` | Tra nhanh xe đang đỗ cho sơ đồ realtime |
| `IX_VeThang_TrangThai_NgayHetHan` | `VE_THANG(TrangThai, NgayHetHan) INCLUDE (MaThe, MaKH, BienSo, MaBaiApDung)` | Quét hạn vé, báo cáo |
| `UX_GiaoDich_MaThamChieu` | UNIQUE `GIAO_DICH(MaThamChieu) WHERE MaThamChieu IS NOT NULL` | Idempotency callback cổng thanh toán |
| `IX_GiaoDich_MaVi_ThoiGian` | `GIAO_DICH(MaVi, ThoiGianTao DESC) INCLUDE (LoaiGD, SoTien, TrangThai)` | Sao kê ví |
| `UX_HoaDon_MaGD` | UNIQUE `HOA_DON_VE_THANG(MaGD) WHERE MaGD IS NOT NULL` | Một giao dịch ví chỉ gắn một hóa đơn |
| `UX_UyQuyen_HieuLuc` | UNIQUE `UY_QUYEN_VE(MaVe, MaTKDuocUyQuyen) WHERE TrangThai = N'Hiệu lực'` | Không trùng ủy quyền hiệu lực |
| `IX_ThongBao_MaKH_DaDoc` | `THONG_BAO(MaKH, DaDoc, ThoiGianTao DESC)` | Hộp thư, đếm chưa đọc |
| `IX_NhatKy_MaTK_ThoiGian` | `NHAT_KY_DANG_NHAP(MaTK, ThoiGian DESC) INCLUDE (KetQua)` | Đếm lần sai trong 15 phút |
| `IX_LuotGui_MaVe_ThoiGianVao` | `LUOT_GUI(MaVe, ThoiGianVao DESC) WHERE MaVe IS NOT NULL` | Lịch sử đỗ xe theo vé |
| `UQ_NhanVien_Email`, `UQ_KhachHang_Email` | UNIQUE `(Email) WHERE Email IS NOT NULL` | Email duy nhất nhưng cho phép nhiều dòng trống (UNIQUE constraint thường chỉ cho 1 NULL) |
| Sequence `seq_GiaoDich` | `BIGINT START WITH 1 INCREMENT BY 1` | Sinh mã `GD + yyMM + 8 chữ số`, an toàn khi ghi đồng thời |

##### Quan hệ chính (mô tả ERD bằng lời)

- `BAI_DO_XE` 1 – n `LOAI_XE`, `VI_TRI_DO`, `THE_XE`, `NHAN_VIEN`, `LUOT_GUI`, `HOA_DON_VE_THANG`, `LICHSU_SU_CO`.
- `LOAI_XE (MaLoaiXe, MaBai)` 1 – n `VI_TRI_DO`: ô đỗ chỉ nhận loại xe có biểu phí tại bãi đó.
- `NHAN_VIEN` 1 – n `TAI_KHOAN` (dữ liệu mẫu: NV005 có 2 tài khoản, một tài khoản đang khóa).
- `KHACH_HANG` 1 – n `VE_THANG`; `THE_XE` 1 – n `VE_THANG` theo thời gian, nhưng tại một thời điểm chỉ 1 vé còn dùng.
- `VE_THANG` 1 – n `HOA_DON_VE_THANG`, 1 – n `LUOT_GUI` (qua `MaVe`), 1 – n `UY_QUYEN_VE`, 1 – n `GIAO_DICH` (thanh toán).
- `THE_XE` 1 – n `LUOT_GUI`, 1 – n `LICHSU_SU_CO`; `VI_TRI_DO` 1 – n `LUOT_GUI`.
- `KHACH_HANG` 1 – 1 `TAI_KHOAN_KH`, 1 – 1 `VI_DIEN_TU`, 1 – n `THONG_BAO`.
- `TAI_KHOAN_KH` 1 – n `NHAT_KY_DANG_NHAP`; 1 – n `UY_QUYEN_VE` (người nhận và người cấp).
- `VI_DIEN_TU` 1 – n `GIAO_DICH`; `GIAO_DICH` tự tham chiếu `MaGDGoc` (hoàn tiền); `PHUONG_THUC_THANH_TOAN` 1 – n `GIAO_DICH`, `HOA_DON_VE_THANG`.
- `HOA_DON_VE_THANG.MaGD` → `GIAO_DICH`; `HOA_DON_VE_THANG.MaNVThu`, `GIAO_DICH.MaNV` → `NHAN_VIEN`.
- `VAI_TRO_KH` n – n `QUYEN_KH` qua `VAI_TRO_QUYEN`; `UY_QUYEN_VE.MaVaiTro` → `VAI_TRO_KH`.
- Ảnh ERD: `docs/Parking_lot_ERD.png`.

##### Quy ước sinh mã

| Đối tượng | Định dạng | Cách sinh |
|---|---|---|
| Khách hàng | `KH####` | MAX + 1 trong transaction, khóa `UPDLOCK, HOLDLOCK` |
| Vé tháng | `V####` | MAX + 1, khóa như trên |
| Hóa đơn | `HD` + yyyyMMdd + STT (≥ 3 chữ số) | MAX + 1 trong ngày |
| Tài khoản khách | `TK####` | MAX + 1 |
| Ví | `VI####` | MAX + 1 |
| Giao dịch | `GD` + yyMM + 8 chữ số | `NEXT VALUE FOR seq_GiaoDich` qua `sp_SinhMaGiaoDich` (sequence không dùng được trong function) |
| Lượt gửi, sự cố, nhật ký, thông báo, ủy quyền | Số nguyên | IDENTITY |
| Mã tham chiếu cổng thanh toán mô phỏng | `SIM-<MaGD>` | Cố định theo mã giao dịch để minh họa callback lặp |

### 3. Ràng buộc về mặt dữ liệu

| Nhóm ràng buộc | Mô tả |
|---|---|
| Danh mục | Mã bãi, mã nhân viên, mã khách hàng, mã thẻ, mã vé, mã ô đỗ, tên đăng nhập không được trùng; tên bãi không trùng; SĐT, CCCD khách hàng không trùng; email duy nhất khi có giá trị. |
| Sức chứa | Sức chứa > 0; 0 ≤ số lượng hiện tại ≤ sức chứa; số lượt đang mở của một bãi không vượt sức chứa. |
| Trạng thái | Ô đỗ: Trống / Đã đỗ. Thẻ: Hoạt động / Bị khóa / Mất. Vé: Hoạt động / Tạm khóa / Hết hạn. Sự cố: Chờ xử lý / Đang giải quyết / Đã giải quyết. |
| Thẻ và vé | Mỗi thẻ tối đa 1 lượt đang đỗ và 1 vé còn dùng; ô đỗ chỉ chứa 1 xe và phải thuộc đúng bãi; loại xe của vé phải có biểu phí tại bãi áp dụng; thẻ của vé gắn bãi phải do bãi đó phát hành. |
| Giá trị tiền | Đơn giá giờ, giá vé tháng, số tiền hóa đơn > 0; tiền gửi, tiền phạt, phí giao dịch ≥ 0; phí phương thức 0–10%. |
| Thời gian | Ngày hết hạn ≥ ngày đăng ký; thời gian ra ≥ thời gian vào; số tháng gia hạn > 0 (online 1–12). |
| Ví và sổ cái | Số dư ≥ 0; ví mới số dư 0; số dư chỉ đổi qua trigger sổ cái; giao dịch không sửa / xóa; trạng thái chỉ Chờ xử lý → Thành công / Thất bại và Thành công → Đã hoàn; hướng tiền khớp loại giao dịch; mã tham chiếu cổng thanh toán duy nhất. |
| Tài khoản | Salt đúng 16 byte; mật khẩu khách đủ mạnh; mỗi khách 1 tài khoản và 1 ví. |
| Ủy quyền | Không cấp vai trò chủ sở hữu; tối đa 3 ủy quyền hiệu lực / vé; mỗi tài khoản 1 ủy quyền hiệu lực / vé; không chia sẻ cho chính chủ, không chia sẻ vé hết hạn. |
| Xóa dữ liệu | Không xóa bãi đang có xe / còn ô đỗ; không xóa thẻ đang có lượt gửi; không xóa giao dịch. |

*Bảng 4. Ràng buộc về mặt dữ liệu*

#### 3.1. Quy tắc nghiệp vụ và công thức (chi tiết)

| Quy tắc | Nội dung |
|---|---|
| Tiền gửi xe lượt | Đỗ ≤ 15 phút: miễn phí. Ngược lại `SoGio = CEILING(TongSoPhut / 60.0)`, `Tiền = SoGio × DonGiaGio` (giá theo loại xe **và** bãi). Thẻ tháng: 0 ₫ |
| Ví dụ tính phí | Ô tô 5 giờ tại Landmark 81: 5 × 30.000 = 150.000 ₫. Xe máy 61 phút tại Lê Lai: CEILING(61/60) = 2 block × 6.000 = 12.000 ₫. Xe đỗ 15 phút: 0 ₫ |
| Loại xe mặc định khi check-in | Nếu không truyền loại xe: lấy theo vé tháng đang hoạt động của thẻ; không có vé thì mặc định xe máy `XM` |
| Tiền vé tháng | `Giá vé tháng (loại xe, bãi tính giá) × Số tháng` |
| Bãi tính giá | Vé gắn bãi: bãi áp dụng. Vé `ALL`: bãi bán vé nếu truyền, ngược lại bãi phát hành thẻ |
| Hạn mới khi gia hạn | Vé còn hạn: cộng dồn từ ngày hết hạn cũ. Vé đã quá hạn: tính từ hôm nay. `HanMoi = DATEADD(MONTH, SoThang, MocTinh)` |
| Gia hạn mở khóa | Gia hạn thành công đặt vé "Hoạt động" và mở khóa thẻ (trừ thẻ "Mất" – bị chặn trước bằng 50019) |
| Vé gắn bãi | Chỉ check-in tại bãi áp dụng (50004); chỉ gia hạn, thu tiền tại bãi đó (50018); loại xe phải có tại bãi và thẻ phải do bãi đó phát hành (50009) |
| Vé toàn chuỗi `ALL` | Gửi ở mọi bãi; loại xe phải có ở ít nhất một bãi |
| Thẻ lượt | Chỉ dùng tại bãi phát hành (50016) |
| Một thẻ – một lượt | Thẻ đang có lượt chưa ra không check-in lần nữa (50014) |
| Một ô – một xe | Ô phải thuộc đúng bãi và chỉ một lượt đang mở (50015) |
| Sức chứa | Số lượt đang mở không vượt `SucChua` (50001); chỗ trống = `SucChua − SoLuongHienTai`; tỷ lệ lấp đầy = `SoLuongHienTai / SucChua × 100%` |
| Mất thẻ | Thẻ "Mất", vé đang dùng "Tạm khóa", biên bản phạt 50.000 ₫ trạng thái "Chờ xử lý"; thẻ mất không check-in, không gia hạn, không cấp cho vé mới |
| Cấp lại thẻ | Vé cũ quá hạn của thẻ được chuyển "Hết hạn" và tắt tự gia hạn; thẻ còn gắn vé hiệu lực bị từ chối (50065); vé cũ không gia hạn mở lại (50066) |
| Doanh thu | Lượt = `SUM(TienGui)`; tháng = `SUM(SoTien)` hóa đơn; tổng = lượt + tháng; doanh thu tháng tách kênh Tại quầy / Online / Tự động |
| Đánh giá hiệu quả bãi (cursor) | Tổng ≥ 10.000.000 ₫: "Hiệu quả rất cao"; ≥ 2.000.000 ₫: "Hiệu quả tốt"; còn lại: "Cần đẩy mạnh khai thác" |
| Cảnh báo hạn vé | Cursor và view vận hành: ≤ 3 ngày; view báo cáo `vw_Report_VeThangSapHetHan`: ≤ 7 ngày |
| Mật khẩu khách | ≥ 8 ký tự, có hoa, thường, số, ký tự đặc biệt (so sánh collation BIN) |
| Khóa tài khoản khách | `SoLanSaiLienTiep >= 5` và ≥ 5 lần sai trong 15 phút → khóa 15 phút; hết hạn khóa tự mở ở lần đăng nhập kế tiếp |
| Nạp ví | Tối thiểu theo phương thức; phí = `ROUND(SoTien × PhiPhanTram / 100, 0)`; hạn mức/ngày tính cả lệnh "Chờ xử lý"; tiền mặt chỉ nạp tại quầy |
| Lệnh nạp treo | "Chờ xử lý" quá 30 phút bị cursor đối soát chuyển "Thất bại" |
| Gia hạn bằng ví | Số tháng 1–12; giá tính bằng `f_KH_TinhPhiGiaHan` phải bằng giá trên hóa đơn của lõi (lệch → 50046, hủy) |
| Chia sẻ vé | Chỉ chủ vé; tối đa 3 tài khoản hiệu lực cùng lúc; không chia sẻ vé hết hạn; không cho chính chủ; ủy quyền quá `NgayKetThuc` không tính vào giới hạn |
| Hoàn tiền | Chỉ giao dịch "Thanh toán vé tháng" ở trạng thái "Thành công" và **chưa gắn hóa đơn** (trừ trùng / trừ nhầm); bắt buộc lý do |
| Máy trạng thái giao dịch | Chờ xử lý → Thành công / Thất bại; Thành công → Đã hoàn. Không chuyển khác |
| Thông báo khách | Mọi hóa đơn, nạp tiền, hoàn tiền, khóa / mở khóa, đổi mật khẩu, chia sẻ / thu hồi, sắp hết hạn, hết hạn đều sinh `THONG_BAO` |

### 4. Luồng xử lý nghiệp vụ trên cơ sở dữ liệu

#### 4.1. Xe vào bãi (check-in)
1. Bảo vệ quét thẻ tại bốt; màn hình đọc `v_BotCong_TraCuuThe` để biết chiều quét kế tiếp ("Vào"/"Ra"), quyết định cho phép và lý do từ chối.
2. Gọi `sp_XeVaoBai(@MaThe, @BienSo, @MaBai, @MaLoaiXe)`:
   - Thẻ không tồn tại → 50007.
   - Xác định loại xe (từ vé tháng hoặc mặc định `XM`) và vé hiện hành qua `f_VeHienHanhCuaThe`.
   - `f_TimSlotTrong` lấy ô trống đầu tiên; không còn ô → 50010.
   - `INSERT LUOT_GUI` (ThoiGianVao = GETDATE(), TienGui = 0, MaVe).
3. Các trigger AFTER INSERT trên `LUOT_GUI` chạy (trong cùng transaction):
   - `trg_KiemTraCheckIn` (đặt chạy đầu tiên): thẻ khóa/mất 50002 → bãi đầy 50001 → thẻ đang có lượt 50014 → ô sai bãi / có xe 50015 → thẻ lượt sai bãi 50016.
   - `trg_ChanSuDungVeHetHan`: vé hiện hành quá hạn 50003.
   - `trg_KiemTraBaiApDungVeThang`: vé gắn bãi khác 50004.
   - `trg_DongBoTrangThaiSlot`: ô → "Đã đỗ", `SoLuongHienTai + 1`.
   - Bất kỳ trigger nào lỗi → ROLLBACK, lượt gửi không được ghi.
4. Thủ tục trả `MaLuot`, `ViTriDoDuocCap`, `MaVe`; sơ đồ `/map` và bảng đèn cập nhật ngay vì đọc trực tiếp từ bảng.

#### 4.2. Xe ra bãi (check-out)
1. Gọi `sp_XeRaBai(@MaThe, @BienSoRa)`: tìm lượt đang mở mới nhất của thẻ; không có → 50011.
2. Biển số lúc ra khác lúc vào → in cảnh báo an ninh (PRINT).
3. Thẻ tháng: tiền 0; thẻ lượt: `f_TinhTienGuiXe(ThoiGianVao, GETDATE(), MaLoaiXe của ô, MaBai)`.
4. `UPDATE LUOT_GUI SET ThoiGianRa, TienGui`; trigger `trg_DongBoTrangThaiSlot` phát hiện ThoiGianRa từ NULL → có giá trị: ô → "Trống", `SoLuongHienTai − 1` (không xuống dưới 0).
5. Trả mã lượt, ô giải phóng, tiền thực thu.

#### 4.3. Đăng ký vé tháng tại quầy
1. Kiểm tra phương thức thanh toán: phải đang hoạt động và **không** được là `SO_DU_VI` (50035).
2. BEGIN TRANSACTION.
3. Tìm khách theo CCCD (khóa UPDLOCK); chưa có thì sinh `KH####` và thêm; có rồi thì cập nhật họ tên, SĐT, email.
4. Xác định bãi tính giá (vé `ALL`: bãi bán vé hoặc bãi phát hành thẻ); bãi không hợp lệ 50008; thiếu biểu phí 50017.
5. Thẻ "Mất" → 50019. Vé cũ quá hạn của thẻ chuyển "Hết hạn" + tắt tự gia hạn. Thẻ còn gắn vé dùng được → 50065.
6. Đổi thẻ sang loại "Tháng", trạng thái "Hoạt động".
7. Sinh `V####`, `NgayHetHan = hôm nay + SoThangDongTruoc tháng`, thêm vé (trigger `trg_KiemTraLoaiXe_VeThang` kiểm tra loại xe / bãi / thẻ – 50009; unique index có lọc chặn 2 vé dùng chung thẻ).
8. Sinh mã `HD...`, thêm hóa đơn kênh "Tại quầy" (trigger `trg_HoaDon_ThongBaoKhachHang` tạo thông báo cho khách).
9. COMMIT; lỗi ở bất kỳ bước nào → ROLLBACK toàn bộ và ném lại lỗi.

#### 4.4. Gia hạn vé (lõi dùng chung `sp_GiaHanVe_Core`)
1. Vé không tồn tại 50012; phương thức không hoạt động 50035; dùng `SO_DU_VI` mà không có giao dịch ví 50064.
2. Nếu đã có transaction bên ngoài → `SAVE TRANSACTION`; nếu chưa → `BEGIN TRANSACTION`.
3. Đọc vé với `UPDLOCK`; thẻ "Mất" 50019; thẻ đã cấp cho vé khác 50066; vé gắn bãi mà thu ở bãi khác 50018; bãi tính giá không hợp lệ 50008; thiếu biểu phí 50017.
4. Tính hạn mới (cộng dồn hoặc tính từ hôm nay), cập nhật vé "Hoạt động", mở khóa thẻ.
5. Lập hóa đơn với phương thức, kênh (Tại quầy / Online / Tự động), mã giao dịch ví, nhân viên thu.
6. Commit nếu tự mở transaction; lỗi thì rollback toàn bộ hoặc chỉ về savepoint.
- **Ba kênh gọi lõi:** `sp_GiaHanTheThang` (quầy), `sp_KH_GiaHanBangVi` (online), `sp_DemoTuDongGiaHanVeThang` (tự động).

#### 4.5. Báo mất thẻ
1. Thẻ không tồn tại → 50013.
2. `UPDATE THE_XE SET TrangThai = 'Mất'` → trigger `trg_LogLichSuSuCo` thêm biên bản (biển số lấy từ vé hiện hành, phạt 50.000 ₫, "Chờ xử lý").
3. Vé đang dùng của thẻ chuyển "Tạm khóa" (vé đã hết hạn giữ nguyên lịch sử).
4. Từ cổng khách: `sp_KH_BaoMatThe` kiểm quyền `VE.BAOMAT`, gọi `sp_BaoMatThe`, gửi thông báo bảo mật cho chủ vé.

#### 4.6. Khách tạo tài khoản và đăng nhập
1. **Đăng ký** `sp_KH_DangKyTaiKhoan`: kiểm mật khẩu mạnh (50034) → SĐT + CCCD phải khớp hồ sơ khách đã có tại quầy (50030) → chưa có tài khoản (50032) → trong transaction: sinh `TK####`, salt `CRYPT_GEN_RANDOM(16)`, hash `f_BamMatKhau`; tạo ví `VI####` số dư 0 nếu chưa có; cập nhật email; gửi thông báo chào mừng.
2. **Đăng nhập** `sp_KH_DangNhap`:
   - Tên không tồn tại: ghi nhật ký "Không tồn tại", lỗi 50040.
   - Đang "Tạm khóa" và đã quá `KhoaDen`: tự mở khóa, reset bộ đếm.
   - Còn khóa: ghi "Bị khóa", lỗi 50041 kèm giờ mở khóa. Đã đóng: 50043.
   - Sai mật khẩu: tăng `SoLanSaiLienTiep`, ghi "Sai mật khẩu" (trigger có thể khóa), lỗi 50040 (cùng thông báo với tên sai).
   - Đúng: reset bộ đếm, ghi `LanDangNhapCuoi`, nhật ký "Thành công", đặt `SESSION_CONTEXT` `MaTK`, `MaKH` (read-only), trả hồ sơ, số dư, số vé sở hữu, số vé được chia sẻ, số thông báo chưa đọc.
   - Nhật ký được ghi **trước** khi THROW và không nằm trong transaction riêng → bên gọi dùng autocommit để nhật ký không bị rollback, nhờ đó trigger khóa tài khoản hoạt động.

#### 4.7. Nạp tiền 2 pha
1. **Pha 1** `sp_KH_NapTien_KhoiTao(@SoTien, @MaPTTT)`: phải đăng nhập (50042), có quyền `VI.NAPTIEN` (50050), ví hoạt động (50033), phương thức hợp lệ cho nạp online – không phải tiền mặt (50035), đủ mức tối thiểu (50036), không vượt hạn mức ngày (50037) → sinh mã giao dịch, thêm giao dịch "Nạp tiền" trạng thái **"Chờ xử lý"** kèm phí; số dư **chưa đổi**.
2. Web chuyển khách sang trang cổng thanh toán mô phỏng (chọn Thành công / Hủy).
3. **Pha 2** `sp_KH_NapTien_XacNhan(@MaGD, @MaThamChieu, @ThanhCong)` (chạy bằng quyền hệ thống):
   - Giao dịch không tồn tại hoặc không phải nạp tiền → 50038.
   - Đã xử lý rồi: cùng mã tham chiếu → trả kết quả cũ, **không cộng tiền lần nữa**; khác mã tham chiếu → 50039.
   - Đang chờ: mã tham chiếu đã dùng cho giao dịch khác → 50039; ngược lại chuyển "Thành công"/"Thất bại", gán mã tham chiếu, giờ hoàn tất; gửi thông báo.
4. Khi chuyển "Thành công", trigger `trg_GiaoDich_CapNhatSoDu` cộng tiền vào ví và ghi `SoDuTruoc`/`SoDuSau`.
5. Lệnh không có callback quá 30 phút: cursor đối soát chuyển "Thất bại".

#### 4.8. Gia hạn online bằng ví
1. `sp_KH_GiaHanBangVi(@MaVe, @SoThang)`: đăng nhập (50042), quyền `VE.GIAHAN` (50050), số tháng 1–12 (50045), giá `f_KH_TinhPhiGiaHan` không NULL (50017), ví hoạt động (50033), số dư đủ – báo rõ số tiền thiếu (50031).
2. Transaction (hoặc savepoint): sinh mã giao dịch; thêm giao dịch "Thanh toán vé tháng" −SoTien, phương thức `SO_DU_VI`, "Thành công" → trigger trừ ví.
3. Gọi `sp_GiaHanVe_Core` với kênh "Online", gắn mã giao dịch → hóa đơn + thông báo.
4. So sánh giá trừ ví với giá hóa đơn; lệch → 50046 và hủy toàn bộ.
5. Commit; trả số dư trước / sau, hạn mới, mã hóa đơn.

#### 4.9. Chia sẻ vé
1. `sp_KH_UyQuyenVe(@MaVe, @TenDangNhapNguoiNhan, @MaVaiTro, @NgayKetThuc)`: đăng nhập; quyền `VE.UYQUYEN` (chỉ chủ vé có); người nhận tồn tại (50047); vai trò chỉ THANH_VIEN / XEM_LICH_SU (50048); không cho chính chủ (50051); vé chưa hết hạn (50054); chưa chia sẻ cho người này (50049); chưa đủ 3 người (50053).
2. Transaction: thêm `UY_QUYEN_VE`, gửi thông báo cho người nhận và chủ vé. Trigger `trg_UyQuyen_KiemTra` kiểm lại các quy tắc làm chốt chặn cuối.
3. Người nhận thấy vé trong `vw_KH_VeThangCuaToi` với vai trò của mình; mọi thao tác vẫn qua `f_KH_CoQuyen`.
4. Thu hồi: `sp_KH_ThuHoiUyQuyen` chuyển "Đã thu hồi" (xóa mềm) và báo người nhận. Vé đổi chủ: trigger thu hồi toàn bộ.

#### 4.10. Tự động gia hạn và đối soát (chạy định kỳ)
1. `sp_DemoCanhBaoHanTheThang`: duyệt mọi vé; quá hạn → vé "Hết hạn", thẻ "Bị khóa", thông báo "Hết hạn"; còn ≤ 3 ngày → nếu bật tự gia hạn và ví đủ tiền thì ghi "Sẽ tự động gia hạn", ngược lại cảnh báo và thông báo "Sắp hết hạn" (tối đa 1 thông báo cùng loại / vé / ngày).
2. `sp_DemoTuDongGiaHanVeThang`: duyệt vé bật tự gia hạn, không "Tạm khóa", còn ≤ 3 ngày; mỗi vé trong transaction / savepoint riêng: kiểm biểu phí, ví, số dư → ghi giao dịch trừ ví (người thực hiện "Hệ thống") → lõi gia hạn kênh "Tự động". Vé lỗi chỉ hoàn tác phần của nó và nhận thông báo "Không thể tự động gia hạn".
3. `sp_DemoDoiSoatViDienTu`: chuyển lệnh nạp treo > 30 phút sang "Thất bại"; duyệt từng ví so số dư với tổng sổ cái (Thành công + Đã hoàn): "Khớp" hoặc "Lệch - cần kiểm tra".

#### 4.11. Hoàn tiền
1. `sp_NV_HoanTien(@MaGDGoc, @LyDo, @MaNV)`: lý do bắt buộc (50063); giao dịch tồn tại (50038); phải là "Thanh toán vé tháng" + "Thành công" (50063); chưa gắn hóa đơn (50063).
2. Transaction: thêm giao dịch "Hoàn tiền" +SoTien, `MaGDGoc`, người thực hiện "Nhân viên" (trigger cộng ví); giao dịch gốc → "Đã hoàn" (bước chuyển hợp lệ duy nhất từ "Thành công"); thông báo cho khách.

### 5. Dữ liệu mẫu

> Câu INSERT nguyên văn nằm ở **Phụ lục C**. Phần vận hành bãi sinh từ `docs/QuanLyBaiDoXe_DuLieuMau.xlsx`; phần cổng khách hàng hiện viết tay. Các mốc "đang đỗ", vé sắp hết hạn dùng `DATEADD(..., GETDATE())` nên luôn đúng tại thời điểm nạp.

#### 5.1. Bãi đỗ

| Mã | Tên | Địa chỉ | Sức chứa | Xe đang đỗ |
|---|---|---|---|---|
| BAI_Q1 | Bãi xe Lê Lai - Bến Thành | Số 26 Lê Lai, P. Bến Thành, Quận 1 | 12 | 2 |
| BAI_Q3 | Bãi xe Hai Bà Trưng | Số 180 Hai Bà Trưng, P. Đa Kao, Quận 3 | 10 | 1 |
| BAI_BT | Bãi xe Landmark 81 | Số 208 Nguyễn Hữu Cảnh, P.22, Bình Thạnh | 12 | 1 |
| BAI_TB | Bãi xe TCP Park - Sân bay Tân Sơn Nhất | Cạnh nhà ga quốc nội, P.2, Tân Bình | 14 | 3 |
| BAI_Q7 | Bãi xe SC VivoCity | Số 1058 Nguyễn Văn Linh, P. Tân Phong, Quận 7 | 12 | 2 |

Tổng: 60 ô đỗ (Q1: 12, Q3: 10, BT: 12, TB: 14, Q7: 12); 25 thẻ phát hành ở phần vận hành (Q1: 6, Q3: 4, BT: 5, TB: 5, Q7: 5) và thêm THE0026 (Q7), THE0027 (BT) cho vé V0011, V0012 ở phần cổng khách hàng.

#### 5.2. Biểu phí (giá giờ / giá vé tháng, ₫)

| Bãi | Ô tô 4-7 chỗ (OT) | Xe máy (XM) | Xe đạp / xe điện (XD) |
|---|---|---|---|
| BAI_Q1 | 25.000 / 1.800.000 | 6.000 / 180.000 | 3.000 / 80.000 |
| BAI_Q3 | 20.000 / 1.500.000 | 5.000 / 150.000 | 2.000 / 60.000 |
| BAI_BT | 30.000 / 2.200.000 | 7.000 / 200.000 | 4.000 / 90.000 |
| BAI_TB | 25.000 / 1.600.000 | 5.000 / 200.000 | 3.000 / 80.000 |
| BAI_Q7 | 20.000 / 1.700.000 | 5.000 / 170.000 | 2.000 / 70.000 |

#### 5.3. Nhân sự và tài khoản nhân viên

| Mã | Họ tên | Chức vụ | Bãi | Tài khoản |
|---|---|---|---|---|
| NV001 | Nguyễn Hữu Trí | Giám đốc điều hành | Toàn chuỗi | `admin` |
| NV002 | Trần Văn Hùng | Quản lý bãi | BAI_Q1 | `quanly_q1` |
| NV003 | Lê Thị Bích Ngọc | Quản lý bãi | BAI_Q3 | `quanly_q3` |
| NV004 | Hoàng Đình Nam | Quản lý bãi | BAI_BT | `quanly_bt` |
| NV005 | Phạm Văn Cường | Bảo vệ | BAI_Q1 | `baove_q1`, `baove_khoa` (đang bị khóa) |
| NV006 | Đặng Minh Tuấn | Bảo vệ | BAI_Q3 | `baove_q3` |
| NV007 | Vũ Đức Thắng | Bảo vệ | BAI_BT | `baove_bt` |
| NV008 | Huỳnh Quốc Bảo | Quản lý bãi | BAI_TB | `quanly_tb` |
| NV009 | Ngô Thị Thanh Hà | Quản lý bãi | BAI_Q7 | `quanly_q7` |
| NV010 | Trương Văn Lộc | Bảo vệ | BAI_TB | `baove_tb` |
| NV011 | Bùi Thành Đạt | Bảo vệ | BAI_Q7 | `baove_q7` |

#### 5.4. Khách hàng và vé tháng

| Mã KH | Họ tên | SĐT | Vé | Thẻ | Biển số | Loại | Phạm vi | Hạn | Trạng thái |
|---|---|---|---|---|---|---|---|---|---|
| KH0001 | Nguyễn Văn An | 0903112233 | V0001 | THE0002 | 59A-123.45 | XM | BAI_Q1 | 01/01/2027 | Hoạt động |
| KH0002 | Trần Thị Mai | 0912445566 | V0002 | THE0004 | 51G-888.99 | OT | BAI_Q1 | 10/10/2026 | Hoạt động |
| KH0003 | Lê Hoàng Long | 0988776655 | V0003 | THE0008 | 59B-456.78 | XM | BAI_Q3 | 03/02/2026 | Hết hạn |
| KH0004 | Phạm Thu Trang | 0934556677 | V0004 | THE0010 | 51H-999.11 | OT | ALL | 08/11/2026 | Hoạt động |
| KH0005 | Võ Minh Quân | 0977112244 | V0005 | THE0012 | 59C-678.90 | XM | BAI_BT | 02/01/2027 | Hoạt động |
| KH0006 | Đỗ Thanh Phong | 0908246810 | V0006 | THE0017 | 51K-246.80 | OT | BAI_TB | 01/03/2027 | Hoạt động |
| KH0007 | Lý Ngọc Hân | 0938135790 | V0007 | THE0019 | 59P-357.91 | XM | BAI_TB | 28 ngày trước + 1 tháng (sắp hết hạn) | Hoạt động |
| KH0008 | Châu Minh Khang | 0917258036 | V0008 | THE0022 | 59N-147.25 | XM | BAI_Q7 | 15/07/2026 | Hết hạn |
| KH0009 | Tạ Thị Kim Oanh | 0966369147 | V0009 | THE0024 | 51L-802.46 | OT | BAI_Q7 | 01/12/2026 | Hoạt động |
| KH0009 | (như trên) | | V0011 | THE0026 | 51L-913.57 | OT | BAI_Q7 | 29 ngày trước + 1 tháng, bật tự gia hạn | Hoạt động |
| KH0010 | Phan Gia Huy | 0945112233 | V0010 | THE0014 | 51M-135.24 | OT | BAI_BT | 06/01/2027 | Hoạt động |
| KH0010 | (như trên) | | V0012 | THE0027 | 51M-468.20 | OT | BAI_BT | 29 ngày trước + 1 tháng, bật tự gia hạn | Hoạt động |

#### 5.5. Cổng khách hàng

| Tài khoản | Khách | Tên đăng nhập | Trạng thái | Ví | Số dư ban đầu |
|---|---|---|---|---|---|
| TK0001 | KH0001 | 0903112233 | Hoạt động | VI0001 | 300.000 |
| TK0002 | KH0002 | 0912445566 | Hoạt động | VI0002 | 3.000.000 |
| TK0003 | KH0003 | 0988776655 | Hoạt động | VI0003 | 0 |
| TK0004 | KH0004 | 0934556677 | Hoạt động | VI0004 | 50.000 |
| TK0005 | KH0006 | 0908246810 | **Tạm khóa** (5 lần sai từ IP 45.124.84.12, công cụ curl) | VI0005 | 2.600.000 (có chuỗi trừ trùng và hoàn tiền) |
| TK0006 | KH0007 | 0938135790 | Hoạt động | VI0006 | 300.000 |
| TK0007 | KH0009 | 0966369147 | Hoạt động | VI0007 | 5.000.000 |
| TK0008 | KH0010 | 0945112233 | Hoạt động | VI0008 | 100.000 |

- KH0005 và KH0008 chưa có tài khoản (dùng cho demo đăng ký).
- Mật khẩu mẫu mọi tài khoản khách: `Khach@2026`.
- Ủy quyền sẵn có: KH0001 chia sẻ V0001 cho tài khoản của KH0002 với vai trò XEM_LICH_SU.
- Mỗi khách có tài khoản có ít nhất 1 thông báo chưa đọc; có lượt gửi lịch sử của xe vé tháng trong 30 ngày gần nhất (gồm lượt của V0004 cho demo chia sẻ).

---

## CHƯƠNG 3: QUẢN LÝ THÔNG TIN

### 1. Xử lý thông tin

#### 1.1. Store procedure

| STT | Stored Procedure | Mục đích |
|---|---|---|
| 1 | `sp_XeVaoBai` | Check-in: tự tìm ô trống, ghi lượt gửi |
| 2 | `sp_XeRaBai` | Check-out: tính phí, ghi giờ ra, giải phóng ô |
| 3 | `sp_DangKyThanhVien` | Đăng ký vé tháng trong transaction (khách, thẻ, vé, hóa đơn) |
| 4 | `sp_GiaHanTheThang` | Gia hạn vé tháng tại quầy |
| 5 | `sp_GiaHanVe_Core` | Lõi gia hạn dùng chung cho quầy, online, tự động |
| 6 | `sp_BaoMatThe` | Báo mất thẻ, tạm khóa vé đang dùng |
| 7 | `sp_DangNhap` | Đăng nhập nhân viên, đối chiếu mật khẩu băm có salt |
| 8 | `sp_SinhMaGiaoDich` | Sinh mã giao dịch ví từ sequence |
| 9 | `sp_KH_DangKyTaiKhoan` | Khách tự tạo tài khoản và ví |
| 10 | `sp_KH_DangNhap` | Khách đăng nhập, ghi nhật ký, đặt ngữ cảnh phiên |
| 11 | `sp_KH_DoiMatKhau` | Đổi mật khẩu, sinh salt mới |
| 12 | `sp_KH_NapTien_KhoiTao` | Pha 1 nạp tiền: tạo lệnh chờ xử lý |
| 13 | `sp_KH_NapTien_XacNhan` | Pha 2 nạp tiền: callback cổng thanh toán (idempotent) |
| 14 | `sp_KH_GiaHanBangVi` | Khách gia hạn vé bằng số dư ví |
| 15 | `sp_KH_CaiDatTuDongGiaHan` | Bật / tắt tự động gia hạn |
| 16 | `sp_KH_UyQuyenVe` | Chia sẻ vé cho tài khoản khác |
| 17 | `sp_KH_ThuHoiUyQuyen` | Thu hồi chia sẻ vé |
| 18 | `sp_KH_BaoMatThe` | Khách báo mất thẻ của vé |
| 19 | `sp_KH_DanhDauDaDoc` | Đánh dấu thông báo đã đọc |
| 20 | `sp_KH_DanhSachUyQuyen` | Danh sách ủy quyền đã cấp và được cấp |
| 21 | `sp_NV_HoanTien` | Nhân viên hoàn tiền bằng giao dịch đối ứng |
| 22 | `sp_NV_MoKhoaTaiKhoanKH` | Nhân viên mở khóa tài khoản khách |
| 23 | `sp_NV_NapTienTaiQuay` | Nhân viên nạp tiền mặt vào ví khách |

*Bảng 5. Danh sách store procedure*

**Chi tiết tham số, các bước xử lý và lỗi:**

##### Mẫu transaction an toàn khi lồng nhau
Các thủ tục ghi nhiều bảng (`sp_GiaHanVe_Core`, `sp_KH_DangKyTaiKhoan`, `sp_KH_GiaHanBangVi`, `sp_KH_UyQuyenVe`, `sp_KH_NapTien_XacNhan`, `sp_NV_HoanTien`, `sp_NV_NapTienTaiQuay`) và cursor tự động gia hạn dùng chung mẫu:

```sql
DECLARE @TranNgoai INT = @@TRANCOUNT;
IF @TranNgoai = 0 BEGIN TRANSACTION;
ELSE SAVE TRANSACTION <ten_savepoint>;
BEGIN TRY
    -- ... các bước nghiệp vụ ...
    IF @TranNgoai = 0 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @TranNgoai = 0 BEGIN IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; END
    ELSE IF XACT_STATE() = 1 ROLLBACK TRANSACTION <ten_savepoint>;
    THROW;
END CATCH;
```

Ý nghĩa: khi được gọi độc lập, thủ tục tự mở và đóng transaction; khi được gọi lồng trong thủ tục / cursor khác, lỗi chỉ hoàn tác phần việc của chính nó (về savepoint), không phá transaction của bên gọi.

##### Nhóm vận hành bãi và vé tháng (8)

| Thủ tục | Tham số | Các bước chính | Kết quả trả về | Lỗi có thể ném |
|---|---|---|---|---|
| `sp_XeVaoBai` | `@MaThe`, `@BienSo`, `@MaBai`, `@MaLoaiXe` = NULL, OUTPUT `@MaViTri`, `@MaLuot` | Kiểm thẻ; suy loại xe (vé tháng hoặc `XM`); lấy vé hiện hành; `f_TimSlotTrong`; INSERT `LUOT_GUI` (kèm `MaVe`) | MaLuot, MaThe, BienSo, MaBai, ViTriDoDuocCap, MaVe, "Check-In thành công" | 50007, 50010 (+ lỗi trigger 50001–50004, 50014–50016) |
| `sp_XeRaBai` | `@MaThe`, `@BienSoRa` = NULL, OUTPUT `@TienThu`, `@MaLuot` | Tìm lượt đang mở mới nhất; cảnh báo lệch biển số; thẻ tháng 0 ₫, thẻ lượt `f_TinhTienGuiXe`; UPDATE ThoiGianRa, TienGui | MaLuot, BienSo, ThoiGianVao/Ra, ViTriGiaiPhong, TienGuiThucThu | 50011 |
| `sp_DangKyThanhVien` | `@MaKH` = NULL, `@HoTen`, `@SDT`, `@CMND`, `@MaThe`, `@BienSo`, `@MaLoaiXe`, `@MaBaiApDung`, `@SoThangDongTruoc` = 1, `@Email`, `@MaBaiBan`, `@MaPTTT` = 'TIEN_MAT', `@MaNVThu` | Transaction: khách (thêm / cập nhật theo CCCD) → bãi tính giá, đơn giá → xử lý thẻ cấp lại → thẻ sang "Tháng" → vé mới → hóa đơn "Tại quầy" | MaVe, MaKH, HoTen, MaThe, BienSo, NgayHetHan, MaHoaDon, TongTienThanhToan | 50035, 50008, 50017, 50019, 50065 (+ 50009, trùng SĐT/CCCD) |
| `sp_GiaHanTheThang` | `@MaVe`, `@SoThangGiaHan` = 1, `@MaBaiGiaHan`, `@MaPTTT` = 'TIEN_MAT', `@MaNVThu` | Gọi `sp_GiaHanVe_Core` với kênh "Tại quầy" | Như lõi | Như lõi |
| `sp_GiaHanVe_Core` | `@MaVe`, `@SoThangGiaHan`, `@MaBaiGiaHan`, `@MaPTTT`, `@KenhThanhToan`, `@MaGD`, `@MaNVThu`, `@TraKetQua`, OUTPUT `@MaHDRa`, `@HanMoiRa`, `@SoTienRa` | Xem Chương 2, mục 4.4 | MaVe, HanCu, HanMoi, MaHoaDon, MaBaiThuTien, SoTienGiaHan, MaPTTT, KenhThanhToan | 50012, 50035, 50064, 50019, 50066, 50018, 50008, 50017 |
| `sp_BaoMatThe` | `@MaTheBaoMat` | Thẻ → "Mất" (trigger lập biên bản); vé đang dùng → "Tạm khóa" | MaThe, TrangThaiTheMoi, TienPhatDenBu = 50.000 | 50013 |
| `sp_DangNhap` | `@TenDangNhap`, `@MatKhauPlain` | Kiểm tồn tại → trạng thái → so `f_BamMatKhau(mật khẩu, salt)` với hash lưu | TenDangNhap, MaNV, HoTen, ChucVu, MaBaiPhuTrach ('ALL' nếu toàn chuỗi), TenBaiPhuTrach | 50020, 50021, 50022 |
| `sp_SinhMaGiaoDich` | OUTPUT `@MaGD` | `NEXT VALUE FOR seq_GiaoDich` → `GD` + yyMM + 8 chữ số | Mã giao dịch | – |

##### Nhóm cổng khách hàng `sp_KH_*` (12)

11 thủ tục khách gọi trực tiếp chạy `WITH EXECUTE AS OWNER` (để đọc / ghi bảng dù khách bị DENY bảng gốc). Các thủ tục thao tác trên tài khoản đang đăng nhập lấy danh tính từ `SESSION_CONTEXT('MaTK')` qua `f_KH_MaTKPhien()`, không nhận `@MaTK` làm tham số nên không giả mạo được; chưa đăng nhập → 50042. Riêng `sp_KH_NapTien_XacNhan` là callback do hệ thống gọi, khách bị DENY.

| Thủ tục | Tham số | Quyền kiểm tra | Các bước chính | Lỗi |
|---|---|---|---|---|
| `sp_KH_DangKyTaiKhoan` | `@SDT`, `@CMND`, `@MatKhau`, `@Email` | – | Xem Chương 2, mục 4.6 | 50034, 50030, 50032 |
| `sp_KH_DangNhap` | `@TenDangNhap`, `@MatKhau`, `@DiaChiIP`, `@ThietBi`, `@KhoaNguCanh` = 1 | – | Xem Chương 2, mục 4.6; đặt `SESSION_CONTEXT` read-only khi `@KhoaNguCanh = 1` | 50040, 50041, 50043 |
| `sp_KH_DoiMatKhau` | `@MatKhauCu`, `@MatKhauMoi` | Phiên | Kiểm mật khẩu cũ (50044) → mật khẩu mới mạnh (50034) → **salt mới** + hash mới → thông báo "Bảo mật" | 50042, 50044, 50034 |
| `sp_KH_NapTien_KhoiTao` | `@SoTien`, `@MaPTTT`, OUTPUT `@MaGD` | `VI.NAPTIEN` | Xem Chương 2, mục 4.7 pha 1 | 50042, 50050, 50033, 50035, 50036, 50037 |
| `sp_KH_GiaHanBangVi` | `@MaVe`, `@SoThang` = 1 | `VE.GIAHAN` | Xem Chương 2, mục 4.8 | 50042, 50050, 50045, 50017, 50033, 50031, 50046 |
| `sp_KH_CaiDatTuDongGiaHan` | `@MaVe`, `@BatTat`, `@SoThang` = 1 | `VE.TUDONGGIAHAN` | Cập nhật `TuDongGiaHan`, `SoThangTuDongGiaHan` | 50042, 50050, 50045 |
| `sp_KH_UyQuyenVe` | `@MaVe`, `@TenDangNhapNguoiNhan`, `@MaVaiTro`, `@NgayKetThuc` | `VE.UYQUYEN` | Xem Chương 2, mục 4.9 | 50042, 50050, 50047, 50048, 50051, 50054, 50049, 50053 |
| `sp_KH_ThuHoiUyQuyen` | `@MaUyQuyen` | `VE.UYQUYEN` | Chuyển "Đã thu hồi", thông báo người nhận | 50042, 50049, 50050 |
| `sp_KH_BaoMatThe` | `@MaVe` | `VE.BAOMAT` | Gọi `sp_BaoMatThe` với thẻ của vé, thông báo chủ vé | 50042, 50050 |
| `sp_KH_DanhDauDaDoc` | `@MaTB` = NULL (NULL = tất cả) | Phiên | Đặt `DaDoc = 1` cho thông báo của chính khách | 50042 |
| `sp_KH_DanhSachUyQuyen` | – | Phiên | Liệt kê ủy quyền "Tôi chia sẻ" và "Được chia sẻ cho tôi" (cần EXECUTE AS OWNER vì RLS ẩn tài khoản người khác) | 50042 |
| `sp_KH_NapTien_XacNhan` | `@MaGD`, `@MaThamChieu`, `@ThanhCong` = 1 | Chỉ hệ thống | Xem Chương 2, mục 4.7 pha 2 | 50038, 50039 |

##### Nhóm nhân viên `sp_NV_*` (3)

| Thủ tục | Tham số | Các bước chính | Lỗi |
|---|---|---|---|
| `sp_NV_HoanTien` | `@MaGDGoc`, `@LyDo`, `@MaNV` | Xem Chương 2, mục 4.11 | 50063, 50038 |
| `sp_NV_MoKhoaTaiKhoanKH` | `@MaTK` | Tài khoản phải tồn tại và đang "Tạm khóa" → "Hoạt động", xóa `KhoaDen`, reset bộ đếm → thông báo "Bảo mật" | 50047 |
| `sp_NV_NapTienTaiQuay` | `@MaKH`, `@SoTien`, `@MaNV` | Ví hoạt động (50033) → ≥ mức tối thiểu tiền mặt 10.000 (50036) → không vượt hạn mức ngày (50037) → giao dịch "Nạp tiền" `TIEN_MAT` "Thành công" ngay (trigger cộng ví) → thông báo | 50033, 50036, 50037 |

#### 1.2. Trigger

| Trigger | Bảng | Thời điểm / sự kiện | Mục đích | Lỗi |
|---|---|---|---|---|
| `trg_KiemTraCheckIn` | `LUOT_GUI` | AFTER INSERT, **chạy đầu tiên** (`sp_settriggerorder 'First'`) | Chặn thẻ khóa/mất, bãi đầy, thẻ đang đỗ, ô sai bãi / có xe, thẻ lượt sai bãi | 50002, 50001, 50014, 50015, 50016 |
| `trg_ChanSuDungVeHetHan` | `LUOT_GUI` | AFTER INSERT | Thẻ tháng có vé hiện hành quá hạn hoặc "Hết hạn" | 50003 |
| `trg_KiemTraBaiApDungVeThang` | `LUOT_GUI` | AFTER INSERT | Vé gắn bãi check-in ở bãi khác (vé `ALL` bỏ qua) | 50004 |
| `trg_DongBoTrangThaiSlot` | `LUOT_GUI` | AFTER INSERT, UPDATE | Đồng bộ trạng thái ô và bộ đếm bãi | – |
| `trg_LogLichSuSuCo` | `THE_XE` | AFTER UPDATE (khi cột TrangThai đổi) | Thẻ chuyển sang "Mất" → biên bản phạt 50.000 ₫ | – |
| `trg_ChanXoaBaiDoXe` | `BAI_DO_XE` | INSTEAD OF DELETE | Chặn xóa bãi đang có xe hoặc còn ô đỗ | 50005 |
| `trg_ChanXoaTheXe` | `THE_XE` | INSTEAD OF DELETE | Chặn xóa thẻ đang có lượt chưa ra | 50006 |
| `trg_KiemTraLoaiXe_VeThang` | `VE_THANG` | AFTER INSERT, UPDATE | Thay khóa ngoại cho `(MaLoaiXe, MaBaiApDung)` vì có giá trị `'ALL'` | 50009 |
| `trg_GiaoDich_CapNhatSoDu` | `GIAO_DICH` | AFTER INSERT, UPDATE | Nguồn duy nhất cập nhật số dư ví | 50033, 50031 |
| `trg_GiaoDich_ChanXoa` | `GIAO_DICH` | INSTEAD OF DELETE | Sổ cái không bao giờ xóa | 50060 |
| `trg_GiaoDich_BatBien` | `GIAO_DICH` | AFTER UPDATE, **chạy đầu tiên** | Chặn sửa trường tiền / tham chiếu, chặn chuyển trạng thái sai | 50061 |
| `trg_ViDienTu_ChanSuaTrucTiep` | `VI_DIEN_TU` | AFTER INSERT, UPDATE | Ví mới phải 0 ₫; số dư chỉ đổi từ bên trong trigger sổ cái | 50062 |
| `trg_NhatKyDangNhap_KhoaTaiKhoan` | `NHAT_KY_DANG_NHAP` | AFTER INSERT | 5 lần sai / 15 phút → khóa 15 phút + thông báo | – |
| `trg_UyQuyen_KiemTra` | `UY_QUYEN_VE` | AFTER INSERT, UPDATE | Chốt chặn cuối quy tắc chia sẻ | 50051, 50052, 50054, 50053 |
| `trg_HoaDon_ThongBaoKhachHang` | `HOA_DON_VE_THANG` | AFTER INSERT | Mọi hóa đơn tạo thông báo cho chủ vé (tiêu đề theo kênh) | – |
| `trg_VeThang_ThuHoiUyQuyenKhiDoiChu` | `VE_THANG` | AFTER UPDATE (khi `MaKH` đổi) | Vé đổi chủ → thu hồi mọi ủy quyền hiệu lực | – |

*Bảng 6. Danh sách trigger*

**Chi tiết các trigger quan trọng:**

##### Chi tiết các trigger quan trọng

**`trg_KiemTraCheckIn`** – kiểm tra theo thứ tự, mỗi lỗi đều `ROLLBACK TRANSACTION` rồi `THROW`:
1. Thẻ trong `inserted` có trạng thái "Bị khóa" hoặc "Mất" → 50002.
2. Đếm trực tiếp số lượt đang mở của bãi (đã gồm lượt vừa chèn) > `SucChua` → 50001. Không đọc `SoLuongHienTai` để không phụ thuộc thứ tự chạy với trigger đồng bộ; nhờ vậy xe cuối cùng khi bãi còn đúng 1 chỗ vẫn vào được.
3. Thẻ có hơn 1 lượt đang mở → 50014.
4. Ô không thuộc bãi của lượt hoặc có hơn 1 lượt đang mở trên ô → 50015.
5. Thẻ lượt dùng ở bãi khác bãi phát hành → 50016.

**`trg_DongBoTrangThaiSlot`:**
- Lượt mới (ThoiGianRa NULL, không có trong `deleted`): ô → "Đã đỗ"; bãi `SoLuongHienTai += số lượt mới` (gom nhóm theo bãi nên đúng khi chèn nhiều dòng).
- Lượt check-out (ThoiGianRa từ NULL sang có giá trị): ô → "Trống"; bãi `SoLuongHienTai −= số lượt ra`, không xuống dưới 0.

**`trg_LogLichSuSuCo`:** chỉ chạy khi cột `TrangThai` được cập nhật; với mỗi thẻ chuyển từ khác "Mất" sang "Mất": thêm biên bản với biển số của vé hiện hành (hoặc "Chưa rõ biển số"), mô tả "Khách hàng báo mất thẻ chip ...", phạt 50.000, "Chờ xử lý", bãi phát hành thẻ. Dùng `OUTER APPLY f_VeHienHanhCuaThe` nên mỗi thẻ đúng 1 biên bản dù từng gắn nhiều vé.

**`trg_GiaoDich_CapNhatSoDu`:**
1. Lấy các giao dịch **vừa chuyển sang "Thành công"** (INSERT trực tiếp "Thành công" hoặc UPDATE từ trạng thái khác) vào biến bảng, tính biến động `HuongTien × SoTien` và lũy kế theo ví bằng window function `SUM() OVER (PARTITION BY MaVi ORDER BY ThoiGianTao, MaGD)`.
2. Ví không "Hoạt động" → ROLLBACK, 50033.
3. Đọc số dư cũ với `UPDLOCK, HOLDLOCK`; nếu tại bất kỳ bước nào trong chuỗi `SoDuCu + LuyKe < 0` → ROLLBACK, 50031.
4. Cập nhật `VI_DIEN_TU.SoDu`; ghi `SoDuTruoc`, `SoDuSau`, `ThoiGianHoanTat` cho từng giao dịch.

**`trg_GiaoDich_BatBien`** (chạy đầu tiên khi UPDATE):
- Đổi `MaGD` → 50061.
- Đổi `MaVi`, `LoaiGD`, `HuongTien`, `SoTien`, `PhiGiaoDich`, `MaPTTT`, `NguoiThucHien`, `ThoiGianTao`, `MaVe`, `MaGDGoc`, `MaNV`; đổi `MaThamChieu` / `SoDuTruoc` / `SoDuSau` khi đã có giá trị → 50061.
- Chuyển trạng thái ngoài 2 bước hợp lệ (Chờ xử lý → Thành công / Thất bại; Thành công → Đã hoàn) → 50061.
- Được phép: ghi `SoDuTruoc`, `SoDuSau`, `MaThamChieu` lần đầu (NULL → giá trị), `ThoiGianHoanTat`, `GhiChu`.

**`trg_ViDienTu_ChanSuaTrucTiep`:** nếu `TRIGGER_NESTLEVEL` của `trg_GiaoDich_CapNhatSoDu` > 0 (đang chạy bên trong trigger sổ cái) thì cho qua; ngược lại ví mới có số dư ≠ 0 hoặc số dư bị đổi → ROLLBACK, 50062. Áp dụng cả với người có quyền UPDATE, kể cả `r_Admin`.

**`trg_NhatKyDangNhap_KhoaTaiKhoan`:** khi chèn nhật ký "Sai mật khẩu": tài khoản đang "Hoạt động", `SoLanSaiLienTiep ≥ 5` và có ≥ 5 lần sai trong 15 phút gần nhất → "Tạm khóa", `KhoaDen = GETDATE() + 15 phút`; gửi thông báo "Tài khoản tạm khóa do đăng nhập sai nhiều lần" kèm giờ mở khóa.

**`trg_UyQuyen_KiemTra`:** với dòng "Hiệu lực": người nhận là chủ vé → 50051; người cấp không phải chủ vé → 50052; vé hết hạn → 50054; vé có hơn 3 ủy quyền hiệu lực (chưa quá `NgayKetThuc`) → 50053.

##### Thứ tự trigger trên `LUOT_GUI`
`LUOT_GUI` có 4 trigger AFTER INSERT. `trg_KiemTraCheckIn` được đặt `First` để lỗi luôn rõ ràng (ví dụ thẻ mất báo 50002 trước khi trigger đồng bộ cập nhật ô). Mọi trigger chạy trong cùng transaction với câu INSERT, nên một trigger ROLLBACK là toàn bộ lượt gửi, cập nhật ô và bộ đếm đều bị hủy.

#### 1.3. Function

| Function | Loại | Tham số → Trả về | Logic |
|---|---|---|---|
| `f_TinhTienGuiXe` | Scalar | `@ThoiGianVao, @ThoiGianRa, @MaLoaiXe, @MaBai` → DECIMAL(18,2) | Thời gian không hợp lệ hoặc thiếu đơn giá → 0; ≤ 15 phút → 0; ngược lại `CEILING(phút / 60.0) × DonGiaGio` |
| `f_TimSlotTrong` | Scalar | `@MaBai, @MaLoaiXe` → VARCHAR(20) | `TOP 1 MaViTri` của ô "Trống" đúng bãi, đúng loại, `ORDER BY MaViTri`; NULL nếu hết ô |
| `f_DanhSachXeTrongBai` | Inline TVF | `@MaBai` → bảng | Lượt đang mở của bãi: MaLuot, MaThe, LoaiThe, BienSo, ThoiGianVao, SoPhutDaDo, MaViTri, KhuVuc, LoaiPhuongTien, TenBai |
| `f_BamMatKhau` | Scalar | `@MatKhau VARCHAR(100), @Salt VARBINARY(16)` → VARBINARY(64) | `HASHBYTES('SHA2_512', @Salt + CAST(@MatKhau AS VARBINARY(100)))`. Mật khẩu luôn VARCHAR vì cùng chuỗi kiểu NVARCHAR cho hash khác |
| `f_KH_TinhPhiGiaHan` | Scalar | `@MaVe, @SoThang` → DECIMAL(18,2) | Giá vé tháng tại bãi áp dụng (vé `ALL`: bãi phát hành thẻ) × số tháng; NULL khi số tháng ≤ 0 hoặc thiếu biểu phí |
| `f_KH_TongNapTrongNgay` | Scalar | `@MaVi` → DECIMAL(18,2) | Tổng giao dịch "Nạp tiền" "Thành công" + "Chờ xử lý" từ 0 giờ hôm nay |
| `f_KH_CoQuyen` | Scalar | `@MaTK, @MaQuyen, @MaVe` → BIT | (1) tài khoản phải hoạt động (hoặc tạm khóa đã quá hạn khóa); (2) quyền `VI.*` / `GIAODICH.*` → 1; (3) chủ vé → CHU_SO_HUU, ngược lại vai trò từ ủy quyền hiệu lực trong khoảng ngày; (4) vai trò có quyền trong `VAI_TRO_QUYEN` → 1 |
| `f_KH_LichSuDoXe` | Inline TVF | `@MaKH, @TuNgay, @DenNgay` → bảng | Lượt gửi của vé chính chủ + vé được ủy quyền hiệu lực, kèm vai trò, số phút, trạng thái "Đang đỗ"/"Đã ra" |
| `f_KH_SaoKeVi` | Inline TVF | `@MaVi, @TuNgay, @DenNgay` → bảng | Sao kê có `SoDuLuyKe` (window function trên toàn lịch sử rồi mới lọc ngày, để dòng đầu kỳ đúng); có `SESSION_CONTEXT` thì chỉ trả ví của chính khách |
| `f_KH_MatKhauHopLe` | Scalar | `@MatKhau` → BIT | ≥ 8 ký tự; có hoa, thường (so collation `Latin1_General_BIN`), số, ký tự đặc biệt |
| `f_KH_MaTKPhien` | Scalar | () → VARCHAR(12) | `SESSION_CONTEXT(N'MaTK')` |
| `f_VeHienHanhCuaThe` | Inline TVF | `@MaThe` → 1 dòng | `TOP 1` vé của thẻ, ưu tiên vé chưa "Hết hạn", rồi `NgayHetHan DESC`, `MaVe DESC`. Dùng ở 3 trigger, `sp_XeVaoBai`, `v_BotCong_TraCuuThe`, `v_SodoBai_ODoChiTiet` |

*Bảng 7. Danh sách function*

#### 1.4. Cursor

| STT | Cursor (procedure) | Mục đích |
|---|---|---|
| 1 | `sp_DemoCanhBaoHanTheThang` (`cur_VeThang`) | Duyệt vé tháng: khóa vé quá hạn, cảnh báo vé còn ≤ 3 ngày, ghi thông báo |
| 2 | `sp_DemoTongKetDoanhThuChuoi` (`cur_BaiDo`) | Duyệt từng bãi: tổng doanh thu lượt và vé tháng theo kênh, đánh giá hiệu quả |
| 3 | `sp_DemoTuDongGiaHanVeThang` (`cur_TuDongGiaHan`) | Duyệt vé bật tự gia hạn: gia hạn bằng ví, mỗi vé một savepoint |
| 4 | `sp_DemoDoiSoatViDienTu` (`cur_DoiSoatVi`) | Đối soát cuối ngày: hủy lệnh nạp treo, so số dư ví với sổ cái |

*Bảng 8. Danh sách cursor*

**Chi tiết:**

Tất cả dùng `CURSOR LOCAL FAST_FORWARD` (chỉ đọc tiến, phạm vi cục bộ), gom kết quả vào bảng tạm `#...` rồi trả một bảng kết quả.

##### `sp_DemoCanhBaoHanTheThang` – cursor `cur_VeThang`
- **Nguồn duyệt:** toàn bộ `VE_THANG`.
- **Với mỗi vé:** `SoNgay = DATEDIFF(DAY, hôm nay, NgayHetHan)`.
  - `SoNgay < 0`: vé → "Hết hạn", thẻ → "Bị khóa"; ghi "ĐÃ QUÁ HẠN: Tự động khóa thẻ và đổi trạng thái hết hạn"; thông báo loại "Hết hạn" (nếu hôm nay chưa gửi).
  - `0 ≤ SoNgay ≤ 3`: nếu vé bật tự gia hạn và số dư ví ≥ phí gia hạn → "Sẽ tự động gia hạn N tháng bằng số dư ví (phí ...)"; ngược lại "CẢNH BÁO: Sắp hết hạn trong N ngày" + thông báo "Sắp hết hạn" (nếu hôm nay chưa gửi).
  - `SoNgay > 3`: "Còn hạn an toàn".
- **Kết quả:** bảng `MaVe, MaThe, BienSo, NgayHetHan, SoNgayConLai, HanhDong, TrangThaiVe`, sắp theo số ngày còn lại tăng dần.
- **Bảng bị ghi:** `VE_THANG`, `THE_XE`, `THONG_BAO`.

##### `sp_DemoTongKetDoanhThuChuoi` – cursor `cur_BaiDo`
- **Nguồn duyệt:** từng bãi trong `BAI_DO_XE`.
- **Với mỗi bãi:** doanh thu lượt `SUM(LUOT_GUI.TienGui)`; doanh thu tháng `SUM(HOA_DON_VE_THANG.SoTien)` tách Tại quầy / Online / Tự động; tổng = lượt + tháng; đánh giá: ≥ 10 triệu "Hiệu quả rất cao (Doanh thu > 10 triệu)", ≥ 2 triệu "Hiệu quả tốt", còn lại "Cần đẩy mạnh khai thác thêm lượt gửi".
- **Kết quả:** sắp theo tổng doanh thu giảm dần (xếp hạng chi nhánh). Chỉ đọc, không ghi bảng.

##### `sp_DemoTuDongGiaHanVeThang` – cursor `cur_TuDongGiaHan`
- **Nguồn duyệt:** vé có `TuDongGiaHan = 1`, không "Tạm khóa", `NgayHetHan ≤ hôm nay + 3 ngày`, sắp theo hạn.
- **Với mỗi vé (transaction hoặc savepoint `sp_TuDongMotVe` riêng):** tính phí `f_KH_TinhPhiGiaHan`; kiểm biểu phí (50017), ví (50033), số dư (50031) **trước** khi ghi sổ cái (để lỗi đến từ thủ tục, hoàn tác được về savepoint, không phải từ trigger – trigger ROLLBACK sẽ hủy toàn bộ); ghi giao dịch trừ ví, người thực hiện "Hệ thống"; gọi lõi với kênh "Tự động".
- **Khi lỗi:** chỉ hoàn tác vé đang xử lý; ghi kết quả "Thiếu số dư" hoặc "Lỗi"; gửi thông báo "Không thể tự động gia hạn vé tháng" (tối đa 1 lần / vé / ngày). Nếu transaction bên ngoài đã hỏng thì dừng.
- **Kết quả:** `MaVe, MaKH, HoTen, BienSo, HanCu, SoThang, SoTien, SoDuTruoc, KetQua, HanMoi, MaGD, MaHoaDon, GhiChu`.
- **Bảng bị ghi:** `GIAO_DICH`, `VI_DIEN_TU` (qua trigger), `VE_THANG`, `THE_XE`, `HOA_DON_VE_THANG`, `THONG_BAO`.

##### `sp_DemoDoiSoatViDienTu` – cursor `cur_DoiSoatVi`
- **Bước 1 (set-based):** giao dịch "Nạp tiền" "Chờ xử lý" tạo trước hơn 30 phút → "Thất bại", ghi chú "Hết thời gian chờ cổng thanh toán (quá 30 phút)"; lưu danh sách bằng `OUTPUT ... INTO`.
- **Bước 2 (cursor):** duyệt từng ví, tính `SoDuTheoSoCai = SUM(HuongTien × SoTien)` của giao dịch "Thành công" và "Đã hoàn"; so với `SoDu`: "Khớp" hoặc "Lệch - cần kiểm tra"; kèm chênh lệch và số giao dịch.
- **Kết quả:** 2 bảng – đối soát từng ví và danh sách giao dịch treo đã xử lý.

#### 1.5. Report

##### Vận hành cơ bản (3)
| View | Cột chính | Ghi chú |
|---|---|---|
| `v_SodoOdoRealtime` | MaBai, TenBai, MaViTri, KhuVuc, TrangThai, TenLoai, BienSo, ThoiGianVao | Ô đỗ + xe đang chiếm (LEFT JOIN lượt đang mở) |
| `v_Xedangtrongbai` | MaLuot, MaBai, TenBai, MaThe, BienSo, MaViTri, ThoiGianVao, LoaiThe | Lượt chưa check-out |
| `v_DanhsachveThangsaphethan` | MaVe, MaThe, HoTen, SDT, BienSo, NgayHetHan, SongayConLai, MaBaiApDung | Vé "Hoạt động" còn 0–3 ngày |

*Bảng 9. Danh sách view vận hành cơ bản*

##### Bốt kiểm soát cổng – `/gate` (4)

**`v_BotCong_TraCuuThe`** – 1 dòng / thẻ. Bãi kiểm soát = bãi xe đang đỗ, nếu không thì bãi áp dụng vé, nếu không thì bãi phát hành thẻ.
- Cột: thông tin thẻ, bãi kiểm soát (sức chứa, chỗ trống), hồ sơ vé hiện hành (khách, SĐT, biển đăng ký, hạn, trạng thái, phạm vi, `VeApDungToanChuoi`, `SoNgayConLaiVe`), lượt đang mở (`DangTrongBai`, `SoPhutDaDo`), `ChieuQuetKeTiep`, `ChoPhepQuet`, `LyDoTuChoi`, `GhiChuCanhBao`, `CoTaiKhoanOnline`, `TuDongGiaHan`.
- `ChieuQuetKeTiep`: có lượt đang mở → "Ra", ngược lại "Vào".
- `ChoPhepQuet = 0` khi (không có lượt đang mở và): thẻ không "Hoạt động"; thẻ tháng chưa gắn vé; vé không "Hoạt động" hoặc quá hạn; bãi đầy.
- `LyDoTuChoi`: "Thẻ đã được báo mất – trigger sẽ chặn (50002)", "Thẻ đang bị khóa (50002)", "Thẻ tháng chưa gắn hợp đồng vé tháng", "Vé tháng đã hết hạn (50003)", "Vé tháng đang ở trạng thái ...", "Bãi đã đầy công suất (50001)".
- `GhiChuCanhBao`: thẻ không còn hiệu lực nhưng xe vẫn trong bãi (lập biên bản trước khi cho ra); vé hết hạn trong lúc xe đang đỗ; xe đỗ quá 24 giờ (kiểm tra phương tiện bỏ quên); vé còn 0–3 ngày (khách có tài khoản online → hướng dẫn tự gia hạn trên cổng; không có → nhắc đóng phí).

**`v_BotCong_XeChoRa`** – mọi xe đang trong bãi: số phút, số giờ, `SoBlockGioTinhPhi` (0 nếu ≤ 15 phút), `TienTamTinh` (thẻ tháng 0, thẻ lượt `f_TinhTienGuiXe`), `ChinhSachThanhToan` ("Miễn phí - xe vé tháng" / "Miễn phí - đỗ dưới 15 phút" / "Thu phí gửi lượt"), hồ sơ vé tháng, `CanhBaoLechBienSo` (biển lúc vào ≠ biển đăng ký vé), `GhiChuCanhBao` (thẻ không hoạt động, lệch biển số, vé hết hạn, đỗ quá 24 giờ).

**`v_BotCong_NhatKyVaoRa`** – 200 sự kiện mới nhất; mỗi lượt gửi trải thành sự kiện "Vào" và (nếu đã ra) "Ra" kèm số phút lưu bãi, số tiền thu; sắp theo thời gian giảm dần, như màn hình camera giám sát.

**`v_BotCong_BangDenCong`** – mỗi cặp (bãi × loại xe): tổng ô, ô đã đỗ, ô trống, tỷ lệ lấp đầy theo loại, `MaViTriGoiY` (`f_TimSlotTrong`), giá giờ, giá vé tháng, `ChoPhepVaoCong`, `DenTinHieuCong`:
- "ĐỎ - BÃI ĐẦY, ĐIỀU PHỐI SANG BÃI KHÁC" khi `SoLuongHienTai >= SucChua`;
- "ĐỎ - HẾT Ô ĐỖ DÀNH CHO LOẠI XE NÀY" khi loại xe hết ô trống;
- "VÀNG - CÒN ÍT Ô ĐỖ" khi còn ≤ 2 ô trống;
- "XANH - CÒN CHỖ, MỜI XE VÀO" còn lại.

##### Sơ đồ bãi realtime – `/map` (3)
- **`v_SodoBai_ODoChiTiet`**: đúng 1 dòng / ô (OUTER APPLY TOP 1 nên không nhân dòng khi dữ liệu lỗi); thứ tự hiển thị theo khu vực; xe đang chiếm, số phút / giờ, tiền tạm tính, chủ xe vé tháng; `TrangThaiHienThi` ("Đã đỗ" / "Trống" / "Lệch dữ liệu"); `CanhBaoLechDuLieu` khi trạng thái ô không khớp lượt gửi đang mở.
- **`v_SodoBai_TongHopKhuVuc`**: theo (bãi, khu vực): tổng ô, đã đỗ, trống, tỷ lệ lấp đầy, số ô và ô trống theo xe máy / ô tô / xe đạp, ô đầu và ô cuối khu vực.
- **`v_SodoBai_TongQuanBai`**: theo bãi: sức chứa, đang đỗ, chỗ trống, tỷ lệ; số ô vật lý, số khu vực; số xe thực tế trong bãi (thẻ tháng / thẻ lượt); giờ xe vào / ra gần nhất; lượt vào / ra và doanh thu lượt hôm nay; `CanhBaoLechBoDem` (bộ đếm ≠ lượt đang mở); `MucDoCanhBao`: "ĐỎ - BÃI ĐẦY" / "VÀNG - GẦN ĐẦY" (≥ 80%) / "XANH - CÒN NHIỀU CHỖ".

##### Báo cáo BI – `/reports` (16)

| View | Cột / logic chính |
|---|---|
| `vw_Report_CongSuatBaiDo` | SucChua, SoLuongHienTai, SoChoTrong, TyLeLapDayPercent (2 chữ số thập phân) |
| `vw_Report_DoanhThuTheoBai` | DoanhThuLuot, DoanhThuThang, TongDoanhThu, DoanhThuThangTaiQuay, DoanhThuThangOnline (gồm Online + Tự động) |
| `vw_Report_XeDangDoHienTai` | Xe đang đỗ toàn chuỗi, số phút, khu vực, loại xe, tên bãi |
| `vw_Report_VeThangSapHetHan` | Vé còn ≤ 7 ngày (kể cả đã quá hạn), khách, SĐT, số ngày còn lại |
| `vw_Report_NhatKySuCo` | Biên bản sự cố, tiền phạt, trạng thái xử lý, tên bãi |
| `vw_Report_DoanhThuTheoNgay` | Theo (bãi, ngày): số lượt (theo ngày ra), doanh thu lượt, số hóa đơn, doanh thu vé tháng, tổng |
| `vw_Report_DoanhThuTheoThang` | Như trên theo (bãi, năm, tháng) |
| `vw_Report_LuuLuongTheoGio` | Theo (bãi, giờ trong ngày): số lượt vào, số ngày có dữ liệu, trung bình lượt / ngày → tìm giờ cao điểm |
| `vw_Report_ThongKeTheoLoaiXe` | Theo (bãi, loại xe): số lượt đã ra, doanh thu lượt, số giờ gửi trung bình |
| `vw_Report_XepHangBai` | `RANK() OVER (ORDER BY TongDoanhThu DESC)`, dựng lại từ 2 view doanh thu và công suất nên số liệu đồng nhất |
| `vw_Report_TongQuanChuoi` | 1 dòng: số bãi, tổng sức chứa, xe đang gửi, tỷ lệ lấp đầy chuỗi, doanh thu lượt / vé tháng hôm nay và tháng này, số vé còn hiệu lực, số vé sắp hết hạn 7 ngày, số sự cố hôm nay |
| `vw_Report_DoanhThuTheoPhuongThuc` | Theo phương thức: số hóa đơn, doanh thu tại quầy / online / tự động, số lần nạp ví, tổng nạp, phí cổng thanh toán, tiền nạp thực nhận |
| `vw_Report_TongQuanViDienTu` | 1 dòng: tổng số ví, ví có số dư, **tổng số dư đang giữ (nợ phải trả khách hàng)**, tổng nạp và chi vé tháng tháng này, doanh thu gia hạn online tháng này, số giao dịch chờ, số tài khoản, số tài khoản tạm khóa |
| `vw_Report_GiaoDichCanXuLy` | Giao dịch "Chờ xử lý" và "Thất bại" 7 ngày: phân loại "Treo quá 30 phút" / "Đang chờ cổng thanh toán" / "Thất bại" |
| `vw_Report_BaoMatTaiKhoanKH` | Theo tài khoản: số lần sai, thành công, số IP trong 24 giờ; cảnh báo "Đang tạm khóa" / "Nhiều lần sai mật khẩu" (≥ 3) / "Đăng nhập từ nhiều địa chỉ IP" (≥ 3) / "Bình thường" |
| `vw_Report_TyLeChuyenDoiOnline` | Theo (năm, tháng): số hóa đơn tại quầy và online (+ tự động), tỷ lệ online %, tỷ lệ khách có tài khoản % |

*Bảng 10. Danh sách view báo cáo BI (report)*

##### Cổng khách hàng `vw_KH_*` (11)
Tất cả lọc theo `SESSION_CONTEXT` (`MaTK` hoặc `MaKH`); không có ngữ cảnh khách (nhân viên) thì trả rỗng.

| View | Nội dung |
|---|---|
| `vw_KH_HoSoCuaToi` | Hồ sơ, tên đăng nhập, trạng thái tài khoản, lần đăng nhập cuối, mã ví, số dư, trạng thái ví, số thông báo chưa đọc |
| `vw_KH_VeThangCuaToi` | Vé chính chủ + vé được ủy quyền hiệu lực: loại xe, phạm vi ("Toàn chuỗi" hoặc tên bãi), hạn, số ngày còn lại, vai trò của tôi, chủ vé, hạn ủy quyền, cài đặt tự gia hạn, `PhiGiaHan1Thang` |
| `vw_KH_LichSuDoXe` | Lượt gửi của các vé tôi xem được, kèm vai trò, bãi, khu vực, số phút, trạng thái, tiền |
| `vw_KH_LichSuGiaoDich` | Sổ cái ví của tôi: số tiền có dấu, phí, phương thức, mã tham chiếu, trạng thái, số dư trước / sau, giao dịch gốc |
| `vw_KH_HoaDonCuaToi` | Hóa đơn các vé tôi đứng tên, mọi kênh |
| `vw_KH_ThongBao` | Hộp thư thông báo |
| `vw_KH_NhatKyDangNhap` | Nhật ký đăng nhập của tài khoản (thời gian, kết quả, IP, thiết bị) |
| `vw_KH_PhuongThucNapVi` | Phương thức được chọn khi nạp online (không gồm tiền mặt) |
| `vw_KH_HanMucNap` | Hạn mức ngày, đã nạp hôm nay, hạn mức còn lại |
| `vw_KH_QuyenTrenVe` | Quyền của tôi trên từng vé (giao diện ẩn nút không có quyền; máy chủ vẫn kiểm tra lại) |
| `vw_KH_VaiTroUyQuyen` | Vai trò được phép chia sẻ kèm danh sách quyền (`STRING_AGG`) |

*Bảng 11. Danh sách view cổng khách hàng*


#### 1.6. Mã lỗi nghiệp vụ

Dải 50001–50022: vận hành bãi và nhân viên; 50030–50066: cổng khách hàng và ví.

| Mã | Nơi ném | Ý nghĩa |
|---|---|---|
| 50001 | `trg_KiemTraCheckIn` | Bãi đã đầy công suất |
| 50002 | `trg_KiemTraCheckIn` | Thẻ bị khóa hoặc báo mất |
| 50003 | `trg_ChanSuDungVeHetHan` | Vé tháng đã hết hạn |
| 50004 | `trg_KiemTraBaiApDungVeThang` | Vé tháng dùng sai bãi áp dụng |
| 50005 | `trg_ChanXoaBaiDoXe` | Không xóa được bãi đang có xe / còn ô đỗ |
| 50006 | `trg_ChanXoaTheXe` | Không xóa được thẻ đang có lượt gửi |
| 50007 | `sp_XeVaoBai` | Thẻ không tồn tại |
| 50008 | `sp_DangKyThanhVien`, lõi gia hạn | Bãi bán vé / bãi tính giá không hợp lệ |
| 50009 | `trg_KiemTraLoaiXe_VeThang` | Loại xe / bãi áp dụng / thẻ không hợp lệ cho vé |
| 50010 | `sp_XeVaoBai` | Không còn ô trống phù hợp |
| 50011 | `sp_XeRaBai` | Không tìm thấy lượt đang đỗ của thẻ |
| 50012 | Lõi gia hạn | Không tìm thấy vé cần gia hạn |
| 50013 | `sp_BaoMatThe` | Thẻ cần báo mất không tồn tại |
| 50014 | `trg_KiemTraCheckIn` | Thẻ đang có lượt chưa check-out |
| 50015 | `trg_KiemTraCheckIn` | Ô sai bãi hoặc đã có xe |
| 50016 | `trg_KiemTraCheckIn` | Thẻ lượt dùng sai bãi phát hành |
| 50017 | Đăng ký, gia hạn, cursor | Loại xe chưa có biểu phí vé tháng |
| 50018 | Lõi gia hạn | Vé gắn bãi chỉ gia hạn tại bãi áp dụng |
| 50019 | Đăng ký, lõi gia hạn | Thẻ đã báo mất |
| 50020 | `sp_DangNhap` | Tên đăng nhập nhân viên không tồn tại |
| 50021 | `sp_DangNhap` | Tài khoản nhân viên bị khóa |
| 50022 | `sp_DangNhap` | Sai mật khẩu nhân viên |
| 50030 | `sp_KH_DangKyTaiKhoan` | SĐT + CCCD không khớp hồ sơ |
| 50031 | Gia hạn ví, trigger sổ cái, cursor | Số dư ví không đủ |
| 50032 | `sp_KH_DangKyTaiKhoan` | Khách đã có tài khoản |
| 50033 | Nạp, gia hạn, trigger sổ cái | Ví không tồn tại / đóng băng |
| 50034 | Đăng ký, đổi mật khẩu | Mật khẩu không đủ mạnh |
| 50035 | Nạp tiền, đăng ký, lõi gia hạn | Phương thức thanh toán không hợp lệ |
| 50036 | Nạp online, nạp tại quầy | Dưới mức nạp tối thiểu |
| 50037 | Nạp online, nạp tại quầy | Vượt hạn mức nạp trong ngày |
| 50038 | Callback, hoàn tiền | Giao dịch không tồn tại |
| 50039 | Callback | Mã tham chiếu không khớp / đã dùng |
| 50040 | `sp_KH_DangNhap` | Sai tên đăng nhập hoặc mật khẩu (thông báo trung tính) |
| 50041 | `sp_KH_DangNhap` | Tài khoản tạm khóa (kèm giờ mở khóa) |
| 50042 | Mọi `sp_KH_*` cần phiên | Chưa đăng nhập / phiên hết hạn |
| 50043 | `sp_KH_DangNhap` | Tài khoản đã đóng |
| 50044 | `sp_KH_DoiMatKhau` | Mật khẩu hiện tại không đúng |
| 50045 | Gia hạn ví, cài tự gia hạn | Số tháng phải 1–12 |
| 50046 | `sp_KH_GiaHanBangVi` | Lệch giá giữa tiền trừ ví và hóa đơn |
| 50047 | Ủy quyền, mở khóa | Không tìm thấy tài khoản / tài khoản không ở trạng thái tạm khóa |
| 50048 | `sp_KH_UyQuyenVe` | Vai trò ủy quyền không hợp lệ |
| 50049 | Ủy quyền, thu hồi | Đã chia sẻ cho tài khoản này / ủy quyền không tồn tại |
| 50050 | Mọi `sp_KH_*` có kiểm quyền | Không có quyền nghiệp vụ trên vé / ví |
| 50051 | Ủy quyền, trigger | Không ủy quyền cho chính chủ vé |
| 50052 | `trg_UyQuyen_KiemTra` | Chỉ chủ vé được chia sẻ |
| 50053 | Ủy quyền, trigger | Tối đa 3 tài khoản |
| 50054 | Ủy quyền, trigger | Vé hết hạn không được chia sẻ |
| 50060 | `trg_GiaoDich_ChanXoa` | Không được xóa giao dịch |
| 50061 | `trg_GiaoDich_BatBien` | Không được sửa giao dịch / chuyển trạng thái sai |
| 50062 | `trg_ViDienTu_ChanSuaTrucTiep` | Không được sửa trực tiếp số dư |
| 50063 | `sp_NV_HoanTien` | Hoàn tiền không hợp lệ (thiếu lý do / sai loại, trạng thái / đã xuất hóa đơn) |
| 50064 | Lõi gia hạn | Thanh toán bằng số dư ví phải kèm giao dịch ví |
| 50065 | `sp_DangKyThanhVien` | Thẻ đang gắn vé tháng còn hiệu lực |
| 50066 | Lõi gia hạn | Thẻ của vé đã cấp cho vé khác, vé cũ không gia hạn được |

Ứng dụng web (`app/errors.py`) chuyển các mã này thành thông báo thân thiện và hiển thị kèm mã lỗi.

*Bảng 12. Danh sách mã lỗi nghiệp vụ*

### 2. An toàn thông tin

#### 2.1. RBAC – 4 role

| Role | Được cấp | Bị chặn (DENY) |
|---|---|---|
| `r_Admin` | `GRANT CONTROL` toàn CSDL | Trigger sổ cái và trigger ví vẫn chặn sửa / xóa giao dịch và sửa số dư |
| `r_QuanLyBai` | SELECT/INSERT/UPDATE: `BAI_DO_XE`, `LOAI_XE`, `VI_TRI_DO`, `THE_XE`, `KHACH_HANG`, `VE_THANG`, `NHAN_VIEN`, `LICHSU_SU_CO`. SELECT: `TAI_KHOAN`, `LUOT_GUI`, `HOA_DON_VE_THANG`, `PHUONG_THUC_THANH_TOAN`, `TAI_KHOAN_KH`, `NHAT_KY_DANG_NHAP`, `VI_DIEN_TU`, `GIAO_DICH`, `THONG_BAO`, `UY_QUYEN_VE`, `QUYEN_KH`, `VAI_TRO_KH`, `VAI_TRO_QUYEN`. EXECUTE: `sp_DangKyThanhVien`, `sp_GiaHanTheThang`, `sp_BaoMatThe`, `sp_DangNhap`, 4 cursor, `sp_NV_HoanTien`, `sp_NV_MoKhoaTaiKhoanKH`, `sp_NV_NapTienTaiQuay`. SELECT 3 view vận hành cơ bản, 7 view bốt cổng / sơ đồ và 10 view báo cáo (`vw_Report_CongSuatBaiDo`, `DoanhThuTheoBai`, `XeDangDoHienTai`, `VeThangSapHetHan`, `NhatKySuCo`, `DoanhThuTheoPhuongThuc`, `TongQuanViDienTu`, `GiaoDichCanXuLy`, `BaoMatTaiKhoanKH`, `TyLeChuyenDoiOnline`). 6 view báo cáo tổng hợp bổ sung sau (theo ngày, theo tháng, lưu lượng, loại xe, xếp hạng, tổng quan chuỗi) chưa được GRANT riêng – cần bổ sung khi triển khai | `DENY SELECT` cột `MatKhauHash`, `MatKhauSalt` trên `TAI_KHOAN` và `TAI_KHOAN_KH`; `DENY UPDATE` `VI_DIEN_TU`; `DENY INSERT, UPDATE, DELETE` `GIAO_DICH` |
| `r_BaoVe` | EXECUTE `sp_XeVaoBai`, `sp_XeRaBai`, `sp_BaoMatThe`, `sp_DangNhap`; SELECT `v_SodoOdoRealtime`, `v_Xedangtrongbai`, 4 view bốt cổng, 3 view sơ đồ | `DENY UPDATE, DELETE` `LUOT_GUI`, `HOA_DON_VE_THANG`; `DENY` mọi quyền trên `TAI_KHOAN`, `TAI_KHOAN_KH`, `NHAT_KY_DANG_NHAP`, `VI_DIEN_TU`, `GIAO_DICH`, `THONG_BAO`, `UY_QUYEN_VE` |
| `r_KhachHang` | EXECUTE 10 `sp_KH_*` + `sp_KH_DanhSachUyQuyen`; SELECT 11 `vw_KH_*`, `f_KH_SaoKeVi`; EXECUTE `f_KH_TinhPhiGiaHan` | DENY mọi quyền trên từng bảng gốc (21 bảng); DENY EXECUTE `sp_KH_NapTien_XacNhan`, `sp_NV_*`, `sp_GiaHanVe_Core`, `sp_GiaHanTheThang`, `sp_SinhMaGiaoDich` |

*Bảng 13. Phân quyền theo role SQL Server*

User demo cổng khách hàng: `u_WebKhachHang` (`CREATE USER ... WITHOUT LOGIN`, thành viên `r_KhachHang`). Khi triển khai thật nên tạo login riêng và `CREATE USER ... FOR LOGIN`.

**Vì sao DENY từng bảng chứ không DENY cả schema `dbo`?** DENY ở cấp schema sẽ thắng cả GRANT trên procedure / view nằm trong schema đó, khiến khách không gọi được cả thủ tục dành cho mình. DENY từng bảng vẫn để ownership chaining hoạt động: procedure và view cùng chủ sở hữu `dbo` được đọc / ghi bảng thay khách.

#### 2.2. Bảo vệ dữ liệu khách hàng – 3 lớp
1. **Lớp 1 – quyền đối tượng:** khách chỉ có EXECUTE `sp_KH_*` và SELECT `vw_KH_*`; truy cập thẳng bảng gốc bị từ chối (lỗi 229 – permission denied).
2. **Lớp 2 – Row-Level Security:** schema `bao_mat`, 4 hàm lọc inline `WITH SCHEMABINDING`, security policy `bao_mat.rls_KhachHang` (`STATE = ON`):

| Hàm lọc | Áp lên bảng | Cho phép dòng khi |
|---|---|---|
| `fn_rls_KhachHang(@MaKH)` | `VI_DIEN_TU`, `THONG_BAO`, `TAI_KHOAN_KH` | `USER_NAME() = 'dbo'` HOẶC không phải thành viên `r_KhachHang` HOẶC `@MaKH = SESSION_CONTEXT('MaKH')` |
| `fn_rls_VeThang(@MaVe, @MaKH)` | `VE_THANG` | Như trên, hoặc vé được ủy quyền hiệu lực cho `SESSION_CONTEXT('MaTK')` |
| `fn_rls_GiaoDich(@MaVi)` | `GIAO_DICH` | Như trên, hoặc ví thuộc khách trong phiên |
| `fn_rls_TheoVe(@MaVe)` | `LUOT_GUI`, `HOA_DON_VE_THANG` | Như trên, hoặc vé thuộc khách / được ủy quyền (lượt thẻ lượt có `MaVe` NULL → khách không thấy) |

*Bảng 14. Hàm lọc Row-Level Security*

Không tạo BLOCK predicate vì khách đã bị DENY ghi trên mọi bảng; mọi thao tác ghi đi qua `sp_KH_*` với `EXECUTE AS OWNER` và `f_KH_CoQuyen`.

3. **Lớp 3 – quyền nghiệp vụ:** mọi `sp_KH_*` gọi `f_KH_CoQuyen(MaTK, MaQuyen, MaVe)` theo ma trận vai trò × quyền.

#### 2.3. Mật khẩu và đăng nhập
- `SHA2_512(salt + mật khẩu)` qua `f_BamMatKhau`; salt ngẫu nhiên 16 byte riêng từng tài khoản (`CRYPT_GEN_RANDOM(16)`), áp dụng cho nhân viên (`TAI_KHOAN`) và khách (`TAI_KHOAN_KH`); hai tài khoản cùng mật khẩu có hash khác nhau → chống rainbow table.
- Đổi mật khẩu sinh salt mới.
- Dữ liệu mẫu: salt cố định (nhân viên: 16 byte đầu của SHA-256(tên đăng nhập); khách: giá trị tổng hợp) để nạp lại cho ra cùng kết quả; tài khoản tạo mới luôn dùng salt ngẫu nhiên.
- Khách: chống dò tài khoản (cùng thông báo 50040 cho sai tên / sai mật khẩu), khóa 15 phút sau 5 lần sai, nhật ký đăng nhập có IP và thiết bị, nhân viên mở khóa, view giám sát `vw_Report_BaoMatTaiKhoanKH`.
- `r_QuanLyBai` xem được tài khoản nhưng không đọc được cột hash / salt.

#### 2.4. Sổ cái ví bất biến
- Số dư chỉ đổi qua `trg_GiaoDich_CapNhatSoDu`; `trg_ViDienTu_ChanSuaTrucTiep` chặn mọi UPDATE số dư khác (50062).
- Không xóa (50060), không sửa trường tiền / tham chiếu (50061), máy trạng thái chặt chẽ; trả tiền lại khách bằng giao dịch đối ứng `sp_NV_HoanTien`.
- Nạp 2 pha + unique index `MaThamChieu` → idempotent.
- `CHECK (SoDu >= 0)` + kiểm tra lũy kế trong trigger → không bao giờ âm (50031).
- Cursor đối soát kiểm tra số dư = tổng sổ cái mỗi ngày.

#### 2.5. Bảo mật tầng web
- CSRF token cho mọi form POST của `/kh` (sai → HTTP 400).
- Phiên khách hết hạn sau 30 phút không thao tác; cookie `SameSite=Lax`; `FLASK_SECRET_KEY` đọc từ `.env` (trống thì sinh ngẫu nhiên mỗi lần khởi động).
- `SESSION_CONTEXT` đặt read-only, không thể đổi sang khách khác trong cùng kết nối.
- Tắt ODBC pooling.
- Bản demo dùng chung một login SQL; cô lập dữ liệu ở web dựa vào `SESSION_CONTEXT` trong `sp_KH_*` / `vw_KH_*`. Lớp RBAC + RLS cho `r_KhachHang` được minh họa ở kịch bản `rls-co-lap-du-lieu-khach-hang` bằng `EXECUTE AS USER = 'u_WebKhachHang'`.
- Trang `/setup` (nạp lại CSDL) chỉ hoạt động khi `ALLOW_RUN_FULL_SCRIPT=1`.

#### 2.6. Sao lưu, phục hồi và nạp dữ liệu hàng loạt (`09_backup_restore.sql`, chạy riêng)
- **BULK INSERT** thẻ xe từ file CSV vào `THE_XE`.
- **Full backup** hằng tuần (00:00 Chủ nhật) và **Differential backup** hằng ngày (23:00), đường dẫn mẫu cho Windows hoặc thư mục Docker `/var/opt/mssql/backup/`.
- **Phục hồi:** `ALTER DATABASE ... SET SINGLE_USER WITH ROLLBACK IMMEDIATE` → `RESTORE` bản Full `WITH NORECOVERY` → `RESTORE` bản Diff gần nhất `WITH RECOVERY` → `SET MULTI_USER`.

---

## CHƯƠNG 4: DEMO

Phần demo được thực hiện trên website Flask kết nối trực tiếp SQL Server. Mỗi kịch bản trên trang `/demo/<mã kịch bản>` gồm 5 bước: **bài toán → dữ liệu trước → thực thi → dữ liệu sau → đối chiếu**; câu lệnh SQL tương ứng có thể chạy song song trong SSMS (Phụ lục B). Với kịch bản trigger chặn vi phạm, lỗi trả về là **kết quả mong đợi**. Khối thực thi được COMMIT thật, nên trước buổi demo nạp lại CSDL qua trang `/setup`. Mỗi mục dưới đây đính kèm các kết quả trọng tâm.

**Môi trường demo:** SQL Server 2022, Python 3.10+, Flask 3.0.3, pyodbc 5.2.0; giao diện nhân viên (`/`, `/demo`, `/gate`, `/map`, `/reports`, `/tables`, `/sql`, `/setup`, `/khach-hang`) và cổng khách hàng `/kh` (tài khoản demo mật khẩu `Khach@2026`).

### 1. Check-in xe vào bãi và tự cấp ô đỗ

**Nội dung:** Xe máy quét thẻ THE0003 (biển 59T1-888.88) vào bãi Lê Lai (BAI_Q1). Hệ thống tự tìm ô trống phù hợp loại xe, ghi lượt gửi, chuyển ô sang Đã đỗ và tăng số xe của bãi.

**Thực hiện:** kịch bản `sp-xe-vao-bai`. **Đối tượng CSDL:** `sp_XeVaoBai`, `f_TimSlotTrong`, `trg_KiemTraCheckIn`, `trg_DongBoTrangThaiSlot`.

**Kết quả demo:**

- Công suất bãi Lê Lai và các ô đỗ trước khi check-in: số xe hiện tại, sức chứa, trạng thái ô.

[HÌNH: Công suất bãi Lê Lai và các ô đỗ trước khi check-in: số xe hiện tại, sức chứa, trạng thái ô.]

*Hình 2. Công suất và ô đỗ bãi Lê Lai trước khi check-in*

- Thủ tục trả về mã lượt gửi và ô đỗ được cấp tự động.

[HÌNH: Thủ tục trả về mã lượt gửi và ô đỗ được cấp tự động.]

*Hình 3. Kết quả thực thi sp_XeVaoBai*

- Sau check-in: số xe hiện tại tăng 1, ô vừa cấp chuyển Đã đỗ, lượt gửi mới xuất hiện trong LUOT_GUI.

[HÌNH: Sau check-in: số xe hiện tại tăng 1, ô vừa cấp chuyển Đã đỗ, lượt gửi mới xuất hiện trong LUOT_GUI.]

*Hình 4. Công suất, ô đỗ và lượt gửi sau khi check-in*

### 2. Check-out xe ra bãi và tính phí

**Nội dung:** Xe đang đỗ quét thẻ ra cổng. Hệ thống đối chiếu thời gian vào, tính tiền theo block giờ (miễn phí 15 phút đầu, thẻ tháng miễn phí), giải phóng ô và giảm số xe.

**Thực hiện:** kịch bản `sp-xe-ra-bai`. **Đối tượng CSDL:** `sp_XeRaBai`, `f_TinhTienGuiXe`, `trg_DongBoTrangThaiSlot`.

**Kết quả demo:**

- Danh sách xe đang đỗ, ô đang có xe và số xe các bãi trước khi check-out.

[HÌNH: Danh sách xe đang đỗ, ô đang có xe và số xe các bãi trước khi check-out.]

*Hình 5. Danh sách xe đang đỗ trước khi check-out*

- Hóa đơn check-out: thời gian vào / ra, ô giải phóng, tiền gửi thực thu tính tự động.

[HÌNH: Hóa đơn check-out: thời gian vào / ra, ô giải phóng, tiền gửi thực thu tính tự động.]

*Hình 6. Hóa đơn check-out – tiền gửi tính tự động*

- Sau check-out: lượt gửi có ThoiGianRa và TienGui, ô về Trống, số xe bãi giảm 1.

[HÌNH: Sau check-out: lượt gửi có ThoiGianRa và TienGui, ô về Trống, số xe bãi giảm 1.]

*Hình 7. Lượt gửi, ô đỗ và số xe sau khi check-out*

### 3. Đăng ký vé tháng trong transaction

**Nội dung:** Đăng ký vé 3 tháng cho khách mới Trần Đình Trọng bằng thẻ THE0003: tạo khách hàng → đổi thẻ sang Tháng → tạo vé → lập hóa đơn trong một transaction.

**Thực hiện:** kịch bản `sp-dang-ky-thanh-vien`. **Đối tượng CSDL:** `sp_DangKyThanhVien`, `trg_KiemTraLoaiXe_VeThang`, `trg_HoaDon_ThongBaoKhachHang`.

**Kết quả demo:**

- Khách hàng, thẻ THE0003 (đang là thẻ lượt), vé và hóa đơn trước khi đăng ký.

[HÌNH: Khách hàng, thẻ THE0003 (đang là thẻ lượt), vé và hóa đơn trước khi đăng ký.]

*Hình 8. Dữ liệu khách hàng, thẻ, vé, hóa đơn trước khi đăng ký*

- Kết quả đăng ký: mã vé, mã khách, ngày hết hạn, mã hóa đơn, tổng tiền.

[HÌNH: Kết quả đăng ký: mã vé, mã khách, ngày hết hạn, mã hóa đơn, tổng tiền.]

*Hình 9. Kết quả đăng ký vé tháng*

- Khách mới, thẻ đổi sang Tháng, vé mới hiệu lực 3 tháng, hóa đơn được lưu.

[HÌNH: Khách mới, thẻ đổi sang Tháng, vé mới hiệu lực 3 tháng, hóa đơn được lưu.]

*Hình 10. Khách mới, thẻ, vé và hóa đơn sau khi đăng ký*

### 4. Gia hạn vé tháng tại quầy

**Nội dung:** Khách vé V0001 (xe máy, bãi Lê Lai) gia hạn thêm 2 tháng tại quầy BAI_Q1; hạn mới cộng dồn từ hạn cũ, hóa đơn 2 × 180.000 = 360.000 ₫.

**Thực hiện:** kịch bản `sp-gia-han-ve-thang`. **Đối tượng CSDL:** `sp_GiaHanTheThang`, `sp_GiaHanVe_Core`.

**Kết quả demo:**

- Vé V0001 và lịch sử hóa đơn trước khi gia hạn.

[HÌNH: Vé V0001 và lịch sử hóa đơn trước khi gia hạn.]

*Hình 11. Vé V0001 và hóa đơn trước khi gia hạn*

- Kết quả gia hạn: hạn cũ, hạn mới, mã hóa đơn, số tiền, kênh Tại quầy.

[HÌNH: Kết quả gia hạn: hạn cũ, hạn mới, mã hóa đơn, số tiền, kênh Tại quầy.]

*Hình 12. Kết quả gia hạn vé tháng*

- Ngày hết hạn đã cộng 2 tháng; hóa đơn gia hạn mới được thêm.

[HÌNH: Ngày hết hạn đã cộng 2 tháng; hóa đơn gia hạn mới được thêm.]

*Hình 13. Hạn dùng và hóa đơn sau khi gia hạn*

### 5. Báo mất thẻ và tự lập biên bản sự cố

**Nội dung:** Khách báo mất thẻ THE0001 tại bãi Quận 1. Thẻ bị khóa ngay, trigger tự lập biên bản và áp tiền phạt 50.000 ₫.

**Thực hiện:** kịch bản `sp-bao-mat-the`. **Đối tượng CSDL:** `sp_BaoMatThe`, `trg_LogLichSuSuCo`.

**Kết quả demo:**

- Trạng thái thẻ THE0001 (Hoạt động) và nhật ký sự cố trước thao tác.

[HÌNH: Trạng thái thẻ THE0001 (Hoạt động) và nhật ký sự cố trước thao tác.]

*Hình 14. Thẻ THE0001 và nhật ký sự cố trước khi báo mất*

- Thẻ chuyển Mất; biên bản sự cố mới do trigger tạo với tiền phạt 50.000 ₫, trạng thái Chờ xử lý.

[HÌNH: Thẻ chuyển Mất; biên bản sự cố mới do trigger tạo với tiền phạt 50.000 ₫, trạng thái Chờ xử lý.]

*Hình 15. Thẻ sau khi báo mất và biên bản sự cố do trigger tạo*

### 6. Cấp lại thẻ xe cho vé tháng mới

**Nội dung:** Vé V0008 của KH0008 hết hạn từ 15/07/2026; quầy Quận 7 thu hồi thẻ THE0022 và cấp lại cho khách mới. Unique index có lọc chỉ cấm 2 vé còn dùng trên cùng thẻ.

**Thực hiện:** kịch bản `sp-cap-lai-the`. **Đối tượng CSDL:** `UX_VeThang_MaThe_ConDung`, `f_VeHienHanhCuaThe`, `sp_DangKyThanhVien`, `sp_XeVaoBai`, `sp_GiaHanTheThang`.

**Kết quả demo:**

- THE0022 đang gắn vé đã hết hạn; bốt cổng tra cứu thẻ báo vé hết hạn.

[HÌNH: THE0022 đang gắn vé đã hết hạn; bốt cổng tra cứu thẻ báo vé hết hạn.]

*Hình 16. Thẻ THE0022 và tra cứu bốt cổng trước khi cấp lại*

- 4 bước: cấp thẻ đang gắn vé còn hạn bị từ chối (50065); đăng ký vé mới với THE0022 thành công; khách mới check-in được; vé cũ không gia hạn mở lại được (50066).

[HÌNH: 4 bước: cấp thẻ đang gắn vé còn hạn bị từ chối (50065); đăng ký vé mới với THE0022 thành công; khách mới check-in được; vé cũ không gia hạn mở lại được (50066).]

*Hình 17. Kết quả 4 bước cấp lại thẻ*

- THE0022 có 2 vé trong lịch sử (cũ Hết hạn, mới Hoạt động); lượt gửi ghi đúng vé mới; bốt cổng chỉ hiện vé hiện hành.

[HÌNH: THE0022 có 2 vé trong lịch sử (cũ Hết hạn, mới Hoạt động); lượt gửi ghi đúng vé mới; bốt cổng chỉ hiện vé hiện hành.]

*Hình 18. Lịch sử vé của thẻ THE0022 sau khi cấp lại*

### 7. Đăng nhập nhân viên, mật khẩu SHA2_512 có salt

**Nội dung:** Các tài khoản cùng mật khẩu 123456 nhưng có salt riêng nên hash khác nhau; thủ tục băm lại mật khẩu nhập với salt của tài khoản để đối chiếu.

**Thực hiện:** kịch bản `sp-dang-nhap-nhan-vien`. **Đối tượng CSDL:** `sp_DangNhap`, `f_BamMatKhau`.

**Kết quả demo:**

- Cùng mật khẩu, khác salt, khác chuỗi băm (hiển thị 16 byte đầu của hash 64 byte).

[HÌNH: Cùng mật khẩu, khác salt, khác chuỗi băm (hiển thị 16 byte đầu của hash 64 byte).]

*Hình 19. Cùng mật khẩu nhưng khác salt và khác hash*

- admin đăng nhập thành công; quanly_q1 sai mật khẩu (50022); baove_khoa bị khóa (50021); quyền đọc cột hash / salt bị DENY với r_QuanLyBai.

[HÌNH: admin đăng nhập thành công; quanly_q1 sai mật khẩu (50022); baove_khoa bị khóa (50021); quyền đọc cột hash / salt bị DENY với r_QuanLyBai.]

*Hình 20. Kết quả đăng nhập và các lần bị từ chối*

### 8. Chặn check-in thẻ bị khóa / mất và bãi đầy

**Nội dung:** Cố tình dùng thẻ THE0006 (đang Mất / Bị khóa) để check-in. Trigger phát hiện, ROLLBACK và ném lỗi 50002 – đây là kết quả mong đợi.

**Thực hiện:** kịch bản `trigger-chan-checkin-loi`. **Đối tượng CSDL:** `trg_KiemTraCheckIn` (còn chặn 50001 bãi đầy, 50014, 50015, 50016).

**Kết quả demo:**

- Trạng thái thẻ THE0006 và tổng số lượt gửi trước khi quét.

[HÌNH: Trạng thái thẻ THE0006 và tổng số lượt gửi trước khi quét.]

*Hình 21. Thẻ THE0006 và số lượt gửi trước khi quét*

- Lỗi 50002; thẻ giữ nguyên trạng thái; tổng số lượt gửi không đổi.

[HÌNH: Lỗi 50002; thẻ giữ nguyên trạng thái; tổng số lượt gửi không đổi.]

*Hình 22. Trigger chặn check-in thẻ lỗi (50002)*

### 9. Chặn vé tháng quá hạn

**Nội dung:** Thẻ tháng THE0008 gắn vé V0003 đã hết hạn quét vào bãi.

**Thực hiện:** kịch bản `trigger-chan-ve-het-han`. **Đối tượng CSDL:** `trg_ChanSuDungVeHetHan`.

**Kết quả demo:**

- Vé V0003 ở trạng thái Hết hạn.

[HÌNH: Vé V0003 ở trạng thái Hết hạn.]

*Hình 23. Vé V0003 đã hết hạn*

- Lỗi 50003; vé vẫn Hết hạn; không có lượt gửi mới.

[HÌNH: Lỗi 50003; vé vẫn Hết hạn; không có lượt gửi mới.]

*Hình 24. Trigger chặn vé tháng quá hạn (50003)*

### 10. Chặn vé tháng gửi sai bãi áp dụng

**Nội dung:** Ô tô vé V0006 (thẻ THE0017) chỉ đăng ký tại BAI_TB nhưng quét vào BAI_Q1; so sánh với vé toàn chuỗi V0004.

**Thực hiện:** kịch bản `trigger-chan-sai-bai`. **Đối tượng CSDL:** `trg_KiemTraBaiApDungVeThang`, `sp_XeVaoBai`.

**Kết quả demo:**

- Phạm vi áp dụng của vé V0006 (BAI_TB) và V0004 (ALL); bãi Lê Lai trước khi quét.

[HÌNH: Phạm vi áp dụng của vé V0006 (BAI_TB) và V0004 (ALL); bãi Lê Lai trước khi quét.]

*Hình 25. Phạm vi áp dụng của hai vé tháng*

- Lỗi 50004; bãi Lê Lai không tăng xe, không có lượt gửi mới.

[HÌNH: Lỗi 50004; bãi Lê Lai không tăng xe, không có lượt gửi mới.]

*Hình 26. Trigger chặn vé gửi sai bãi (50004)*

### 11. Tính tiền gửi xe và tìm ô đỗ trống bằng function

**Nội dung:** Kiểm chứng trực tiếp các hàm nghiệp vụ: tính phí ô tô gửi 5 giờ tại Landmark 81, tìm ô trống xe máy BAI_Q1 và ô tô BAI_Q3, danh sách xe đang trong bãi BAI_Q1.

**Thực hiện:** kịch bản `function-tinh-tien-slot`. **Đối tượng CSDL:** `f_TinhTienGuiXe`, `f_TimSlotTrong`, `f_DanhSachXeTrongBai`.

**Kết quả demo:**

- Biểu phí đơn giá giờ các bãi và ô trống bãi Lê Lai.

[HÌNH: Biểu phí đơn giá giờ các bãi và ô trống bãi Lê Lai.]

*Hình 27. Biểu phí giờ và ô trống bãi Lê Lai*

- f_TinhTienGuiXe = 150.000 ₫ (5 × 30.000); mã ô gợi ý của f_TimSlotTrong; bảng xe đang đỗ của f_DanhSachXeTrongBai.

[HÌNH: f_TinhTienGuiXe = 150.000 ₫ (5 × 30.000); mã ô gợi ý của f_TimSlotTrong; bảng xe đang đỗ của f_DanhSachXeTrongBai.]

*Hình 28. Kết quả các function tính tiền và tìm ô đỗ*

### 12. Cursor quét hạn vé tháng và tổng kết doanh thu chuỗi

**Nội dung:** Cursor duyệt từng vé tháng để khóa vé quá hạn, cảnh báo vé còn ≤ 3 ngày; cursor duyệt từng bãi để tổng hợp doanh thu lượt và vé tháng theo kênh, đánh giá hiệu quả.

**Thực hiện:** kịch bản `cursor-canh-bao-doanh-thu`. **Đối tượng CSDL:** `sp_DemoCanhBaoHanTheThang` (`cur_VeThang`), `sp_DemoTongKetDoanhThuChuoi` (`cur_BaiDo`).

**Kết quả demo:**

- Bảng kết quả quét hạn vé: số ngày còn lại, hành động (đã quá hạn / cảnh báo / sẽ tự động gia hạn / còn hạn).

[HÌNH: Bảng kết quả quét hạn vé: số ngày còn lại, hành động (đã quá hạn / cảnh báo / sẽ tự động gia hạn / còn hạn).]

*Hình 29. Kết quả cursor quét hạn vé tháng*

- Bảng tổng kết tài chính từng chi nhánh: doanh thu lượt, vé tháng tại quầy / online / tự động, tổng, đánh giá hiệu quả.

[HÌNH: Bảng tổng kết tài chính từng chi nhánh: doanh thu lượt, vé tháng tại quầy / online / tự động, tổng, đánh giá hiệu quả.]

*Hình 30. Kết quả cursor tổng kết doanh thu chuỗi*

- Trạng thái vé sau khi cursor xử lý và đối chiếu với view doanh thu theo bãi.

[HÌNH: Trạng thái vé sau khi cursor xử lý và đối chiếu với view doanh thu theo bãi.]

*Hình 31. Trạng thái vé và đối chiếu doanh thu sau cursor*

### 13. Khách hàng tự tạo tài khoản

**Nội dung:** KH0005 (Võ Minh Quân) có vé V0005 nhưng chưa có tài khoản; tự đăng ký bằng SĐT 0977112244 + CCCD 079090005555.

**Thực hiện:** kịch bản `kh-dang-ky-tai-khoan`. **Đối tượng CSDL:** `sp_KH_DangKyTaiKhoan`, `f_KH_MatKhauHopLe`, `f_BamMatKhau`.

**Kết quả demo:**

- Hồ sơ KH0005; chưa có tài khoản và ví.

[HÌNH: Hồ sơ KH0005; chưa có tài khoản và ví.]

*Hình 32. Hồ sơ KH0005 trước khi đăng ký tài khoản*

- Lần 1 tạo tài khoản thành công; lần 2 bị chặn 50032.

[HÌNH: Lần 1 tạo tài khoản thành công; lần 2 bị chặn 50032.]

*Hình 33. Kết quả đăng ký tài khoản hai lần*

- Đúng 1 tài khoản, ví số dư 0 ₫ và thông báo chào mừng.

[HÌNH: Đúng 1 tài khoản, ví số dư 0 ₫ và thông báo chào mừng.]

*Hình 34. Tài khoản, ví và thông báo sau khi đăng ký*

### 14. Khóa tài khoản khi dò mật khẩu

**Nội dung:** Kẻ gian dò mật khẩu tài khoản 0988776655 (KH0003) 5 lần liên tiếp.

**Thực hiện:** kịch bản `kh-dang-nhap-khoa-tai-khoan`. **Đối tượng CSDL:** `sp_KH_DangNhap`, `trg_NhatKyDangNhap_KhoaTaiKhoan`.

**Kết quả demo:**

- 5 lần sai trả cùng thông báo 50040; lần 6 dù đúng mật khẩu vẫn bị từ chối 50041.

[HÌNH: 5 lần sai trả cùng thông báo 50040; lần 6 dù đúng mật khẩu vẫn bị từ chối 50041.]

*Hình 35. Kết quả 6 lần đăng nhập*

- Tài khoản bị khóa tạm 15 phút; nhật ký đăng nhập; thông báo bảo mật gửi khách.

[HÌNH: Tài khoản bị khóa tạm 15 phút; nhật ký đăng nhập; thông báo bảo mật gửi khách.]

*Hình 36. Tài khoản bị khóa, nhật ký và thông báo bảo mật*

### 15. Nạp tiền 2 pha và callback lặp

**Nội dung:** KH0001 nạp 500.000 ₫ qua MoMo. Pha 1 tạo lệnh Chờ xử lý; pha 2 callback xác nhận thì cộng tiền; callback gửi lại lần 2 không cộng tiền nữa.

**Thực hiện:** kịch bản `kh-nap-tien-2-pha`. **Đối tượng CSDL:** `sp_KH_NapTien_KhoiTao`, `sp_KH_NapTien_XacNhan`, `trg_GiaoDich_CapNhatSoDu`.

**Kết quả demo:**

- Ví và sổ cái VI0001 trước khi nạp.

[HÌNH: Ví và sổ cái VI0001 trước khi nạp.]

*Hình 37. Ví và sổ cái của KH0001 trước khi nạp*

- Pha 1 Chờ xử lý (số dư chưa đổi); callback lần 1 Thành công; callback lần 2 bị bỏ qua.

[HÌNH: Pha 1 Chờ xử lý (số dư chưa đổi); callback lần 1 Thành công; callback lần 2 bị bỏ qua.]

*Hình 38. Kết quả nạp tiền 2 pha và callback lặp*

- Số dư tăng đúng 500.000 ₫; sổ cái có số dư trước / sau; thông báo nạp tiền.

[HÌNH: Số dư tăng đúng 500.000 ₫; sổ cái có số dư trước / sau; thông báo nạp tiền.]

*Hình 39. Ví, sổ cái và thông báo sau khi nạp*

### 16. Khách tự gia hạn vé bằng số dư ví

**Nội dung:** KH0002 gia hạn vé ô tô V0002 (bãi Lê Lai) thêm 1 tháng, giá 1.800.000 ₫ tính bằng f_KH_TinhPhiGiaHan.

**Thực hiện:** kịch bản `kh-gia-han-bang-vi`. **Đối tượng CSDL:** `sp_KH_GiaHanBangVi`, `f_KH_TinhPhiGiaHan`, `sp_GiaHanVe_Core`, `trg_HoaDon_ThongBaoKhachHang`.

**Kết quả demo:**

- Vé V0002, ví KH0002, giá gia hạn 1 tháng và hóa đơn trước thao tác.

[HÌNH: Vé V0002, ví KH0002, giá gia hạn 1 tháng và hóa đơn trước thao tác.]

*Hình 40. Vé, ví và giá gia hạn trước khi gia hạn online*

- Trừ ví, vé cộng 1 tháng, hóa đơn kênh Online gắn mã giao dịch, thông báo cho khách.

[HÌNH: Trừ ví, vé cộng 1 tháng, hóa đơn kênh Online gắn mã giao dịch, thông báo cho khách.]

*Hình 41. Kết quả gia hạn online bằng ví*

### 17. Chặn số dư ví âm

**Nội dung:** KH0004 (ví 50.000 ₫) gia hạn vé toàn chuỗi V0004 thêm 3 tháng = 4.500.000 ₫ (giá tại bãi phát hành thẻ BAI_Q3).

**Thực hiện:** kịch bản `trigger-chan-so-du-am`. **Đối tượng CSDL:** `sp_KH_GiaHanBangVi`, `trg_GiaoDich_CapNhatSoDu`, `CHECK (SoDu >= 0)`.

**Kết quả demo:**

- Vé V0004, ví KH0004, giá gia hạn 3 tháng, số giao dịch trong sổ cái.

[HÌNH: Vé V0004, ví KH0004, giá gia hạn 3 tháng, số giao dịch trong sổ cái.]

*Hình 42. Ví KH0004 và giá gia hạn trước thao tác*

- Lớp 1 thủ tục từ chối, báo số tiền thiếu (50031); lớp 2 ghi thẳng sổ cái bị trigger ROLLBACK; dữ liệu không đổi.

[HÌNH: Lớp 1 thủ tục từ chối, báo số tiền thiếu (50031); lớp 2 ghi thẳng sổ cái bị trigger ROLLBACK; dữ liệu không đổi.]

*Hình 43. Hai lớp chặn số dư âm (50031)*

### 18. Row-Level Security cô lập dữ liệu khách hàng

**Nội dung:** Cùng một câu SELECT nhưng mỗi khách chỉ thấy dữ liệu của mình; chạy dưới user u_WebKhachHang (role r_KhachHang).

**Thực hiện:** kịch bản `rls-co-lap-du-lieu-khach-hang`. **Đối tượng CSDL:** `r_KhachHang`, `u_WebKhachHang`, `bao_mat.rls_KhachHang`, `vw_KH_LichSuGiaoDich`, `f_KH_SaoKeVi`.

**Kết quả demo:**

- Góc nhìn quản trị (dbo) thấy toàn bộ giao dịch.

[HÌNH: Góc nhìn quản trị (dbo) thấy toàn bộ giao dịch.]

*Hình 44. Góc nhìn quản trị trước khi áp RLS*

- KH0001 và KH0002 thấy dữ liệu khác nhau; truy cập thẳng bảng GIAO_DICH bị từ chối (lỗi 229); xem sao kê ví người khác nhận 0 dòng.

[HÌNH: KH0001 và KH0002 thấy dữ liệu khác nhau; truy cập thẳng bảng GIAO_DICH bị từ chối (lỗi 229); xem sao kê ví người khác nhận 0 dòng.]

*Hình 45. Góc nhìn từng khách hàng dưới RLS*

- Role, user cổng khách hàng và security policy RLS.

[HÌNH: Role, user cổng khách hàng và security policy RLS.]

*Hình 46. Role, user và security policy RLS*

### 19. Chia sẻ vé theo vai trò

**Nội dung:** Chủ vé KH0004 chia sẻ V0004 cho KH0007 (0938135790) với vai trò THANH_VIEN, sau đó thử vượt quyền và vượt giới hạn 3 người.

**Thực hiện:** kịch bản `kh-uy-quyen-ve`. **Đối tượng CSDL:** `sp_KH_UyQuyenVe`, `f_KH_CoQuyen`, `trg_UyQuyen_KiemTra`.

**Kết quả demo:**

- Vé V0004, ủy quyền hiện có và ma trận vai trò × quyền.

[HÌNH: Vé V0004, ủy quyền hiện có và ma trận vai trò × quyền.]

*Hình 47. Vé V0004 và ma trận vai trò × quyền*

- KH0007 thấy vé và lịch sử đỗ; gia hạn bị từ chối (50050); người thứ 4 bị chặn (50053); thông báo ủy quyền.

[HÌNH: KH0007 thấy vé và lịch sử đỗ; gia hạn bị từ chối (50050); người thứ 4 bị chặn (50053); thông báo ủy quyền.]

*Hình 48. Kết quả chia sẻ vé và kiểm tra quyền*

### 20. Tự động gia hạn vé bằng cursor và savepoint

**Nội dung:** 3 vé bật tự gia hạn còn ≤ 3 ngày: V0007 (ví đủ), V0011 (ví đủ), V0012 (ví thiếu). Mỗi vé xử lý trong savepoint riêng.

**Thực hiện:** kịch bản `cursor-tu-dong-gia-han`. **Đối tượng CSDL:** `sp_DemoTuDongGiaHanVeThang` (`cur_TuDongGiaHan`).

**Kết quả demo:**

- Danh sách vé bật tự động gia hạn trước khi chạy.

[HÌNH: Danh sách vé bật tự động gia hạn trước khi chạy.]

*Hình 49. Vé bật tự động gia hạn trước khi chạy cursor*

- V0007, V0011 gia hạn thành công (hóa đơn kênh Tự động); V0012 thiếu tiền chỉ hoàn tác riêng và nhận thông báo.

[HÌNH: V0007, V0011 gia hạn thành công (hóa đơn kênh Tự động); V0012 thiếu tiền chỉ hoàn tác riêng và nhận thông báo.]

*Hình 50. Kết quả cursor tự động gia hạn*

- Vé sau khi chạy, hóa đơn kênh Tự động và thông báo gửi khách.

[HÌNH: Vé sau khi chạy, hóa đơn kênh Tự động và thông báo gửi khách.]

*Hình 51. Vé, hóa đơn và thông báo sau khi tự động gia hạn*

### 21. Sổ cái giao dịch bất biến và hoàn tiền

**Nội dung:** Nhân viên gian lận cố sửa số tiền, xóa giao dịch, tự cộng số dư ví VI0004; sau đó hoàn tiền đúng quy trình.

**Thực hiện:** kịch bản `trigger-so-cai-bat-bien`. **Đối tượng CSDL:** `trg_GiaoDich_BatBien`, `trg_GiaoDich_ChanXoa`, `trg_ViDienTu_ChanSuaTrucTiep`, `sp_NV_HoanTien`.

**Kết quả demo:**

- Sổ cái và số dư ví VI0004 trước thao tác.

[HÌNH: Sổ cái và số dư ví VI0004 trước thao tác.]

*Hình 52. Sổ cái và ví VI0004 trước thao tác*

- Sửa tiền 50061, xóa 50060, sửa số dư 50062, hoàn khoản đã xuất hóa đơn 50063; hoàn tiền hợp lệ thành công.

[HÌNH: Sửa tiền 50061, xóa 50060, sửa số dư 50062, hoàn khoản đã xuất hóa đơn 50063; hoàn tiền hợp lệ thành công.]

*Hình 53. Kết quả các thao tác trên sổ cái*

- Giao dịch Hoàn tiền đối ứng, giao dịch gốc Đã hoàn, số dư tăng đúng.

[HÌNH: Giao dịch Hoàn tiền đối ứng, giao dịch gốc Đã hoàn, số dư tăng đúng.]

*Hình 54. Sổ cái và số dư sau khi hoàn tiền*

### 22. Bốt kiểm soát cổng vào / ra

**Nội dung:** Bảo vệ quét mã thẻ tại bốt cổng; màn hình trả về quyết định mở barrier hoặc từ chối và các thông tin vận hành của bãi.

**Thực hiện:** màn hình `/gate`. **Đối tượng CSDL:** `v_BotCong_TraCuuThe`, `v_BotCong_BangDenCong`, `v_BotCong_XeChoRa`, `v_BotCong_NhatKyVaoRa`.

**Kết quả demo:**

- Tra cứu thẻ: đèn MỞ BARRIER / TỪ CHỐI, chiều quét kế tiếp, lý do từ chối, ghi chú cảnh báo.

[HÌNH: Tra cứu thẻ: đèn MỞ BARRIER / TỪ CHỐI, chiều quét kế tiếp, lý do từ chối, ghi chú cảnh báo.]

*Hình 55. Bốt kiểm soát cổng – tra cứu thẻ*

- Bảng đèn XANH / VÀNG / ĐỎ theo loại xe kèm ô gợi ý; danh sách xe chờ ra với tiền tạm tính và cờ lệch biển số; nhật ký 200 sự kiện.

[HÌNH: Bảng đèn XANH / VÀNG / ĐỎ theo loại xe kèm ô gợi ý; danh sách xe chờ ra với tiền tạm tính và cờ lệch biển số; nhật ký 200 sự kiện.]

*Hình 56. Bảng đèn cổng, xe chờ ra và nhật ký vào / ra*

### 23. Sơ đồ bãi đỗ thời gian thực

**Nội dung:** Hiển thị mặt bằng ô đỗ của từng bãi; ô trống màu xanh, ô có xe màu đỏ kèm biển số; cập nhật ngay sau check-in / check-out.

**Thực hiện:** màn hình `/map`. **Đối tượng CSDL:** `v_SodoBai_ODoChiTiet`, `v_SodoBai_TongHopKhuVuc`, `v_SodoBai_TongQuanBai`.

**Kết quả demo:**

- Lưới ô đỗ theo khu vực, thông tin xe đang chiếm chỗ, cờ lệch dữ liệu.

[HÌNH: Lưới ô đỗ theo khu vực, thông tin xe đang chiếm chỗ, cờ lệch dữ liệu.]

*Hình 57. Sơ đồ ô đỗ thời gian thực*

- Tổng hợp ô trống theo khu vực / loại xe; thẻ tổng quan công suất, mức cảnh báo, cờ lệch bộ đếm.

[HÌNH: Tổng hợp ô trống theo khu vực / loại xe; thẻ tổng quan công suất, mức cảnh báo, cờ lệch bộ đếm.]

*Hình 58. Tổng hợp khu vực và tổng quan công suất bãi*

### 24. Report doanh thu và xếp hạng bãi

**Nội dung:** Lấy doanh thu theo từng bãi (lượt và vé tháng, tại quầy và online), theo ngày, theo tháng và xếp hạng các bãi.

**Thực hiện:** màn hình `/reports`. **Đối tượng CSDL:** `vw_Report_DoanhThuTheoBai`, `vw_Report_DoanhThuTheoNgay`, `vw_Report_DoanhThuTheoThang`, `vw_Report_XepHangBai`.

**Kết quả demo:**

- Doanh thu lượt, doanh thu vé tháng, tổng doanh thu, tách tại quầy / online theo từng bãi.

[HÌNH: Doanh thu lượt, doanh thu vé tháng, tổng doanh thu, tách tại quầy / online theo từng bãi.]

*Hình 59. Report doanh thu theo bãi*

- Hạng doanh thu kèm sức chứa và tỷ lệ lấp đầy của từng bãi.

[HÌNH: Hạng doanh thu kèm sức chứa và tỷ lệ lấp đầy của từng bãi.]

*Hình 60. Report xếp hạng bãi*

- Biểu đồ doanh thu từ view thể hiện qua Power BI / Tableau [CẦN BỔ SUNG nếu nhóm có làm dashboard].

[HÌNH: Biểu đồ doanh thu từ view thể hiện qua Power BI / Tableau [CẦN BỔ SUNG nếu nhóm có làm dashboard].]

*Hình 61. Report doanh thu thể hiện qua Power BI / Tableau*

### 25. Report công suất, lưu lượng và loại xe

**Nội dung:** Lấy tỷ lệ lấp đầy từng bãi, lưu lượng xe vào theo khung giờ để tìm giờ cao điểm, cơ cấu lượt gửi và doanh thu theo loại xe.

**Thực hiện:** màn hình `/reports`. **Đối tượng CSDL:** `vw_Report_CongSuatBaiDo`, `vw_Report_LuuLuongTheoGio`, `vw_Report_ThongKeTheoLoaiXe`, `vw_Report_TongQuanChuoi`.

**Kết quả demo:**

- Sức chứa, số xe, chỗ trống, tỷ lệ lấp đầy từng bãi; tổng quan toàn chuỗi.

[HÌNH: Sức chứa, số xe, chỗ trống, tỷ lệ lấp đầy từng bãi; tổng quan toàn chuỗi.]

*Hình 62. Report công suất bãi đỗ và tổng quan chuỗi*

- Số lượt vào theo giờ trong ngày và trung bình mỗi ngày.

[HÌNH: Số lượt vào theo giờ trong ngày và trung bình mỗi ngày.]

*Hình 63. Report lưu lượng xe theo giờ*

- Số lượt, doanh thu lượt, số giờ gửi trung bình theo loại xe.

[HÌNH: Số lượt, doanh thu lượt, số giờ gửi trung bình theo loại xe.]

*Hình 64. Report thống kê theo loại xe*

### 26. Report vé tháng sắp hết hạn và sự cố

**Nội dung:** Lấy danh sách vé còn ≤ 7 ngày (kể cả đã quá hạn) để nhắc gia hạn và nhật ký sự cố kèm tiền phạt.

**Thực hiện:** màn hình `/reports`. **Đối tượng CSDL:** `vw_Report_VeThangSapHetHan`, `vw_Report_NhatKySuCo`, `vw_Report_XeDangDoHienTai`.

**Kết quả demo:**

- Vé, khách, SĐT, ngày hết hạn, số ngày còn lại.

[HÌNH: Vé, khách, SĐT, ngày hết hạn, số ngày còn lại.]

*Hình 65. Report vé tháng sắp hết hạn*

- Biên bản sự cố, tiền phạt, trạng thái xử lý theo bãi.

[HÌNH: Biên bản sự cố, tiền phạt, trạng thái xử lý theo bãi.]

*Hình 66. Report nhật ký sự cố*

### 27. Report thanh toán và ví điện tử

**Nội dung:** Lấy doanh thu vé tháng theo phương thức / kênh, tiền nạp ví qua từng cổng, tổng số dư khách đang giữ, giao dịch treo và tỷ lệ gia hạn online.

**Thực hiện:** màn hình `/reports`. **Đối tượng CSDL:** `vw_Report_DoanhThuTheoPhuongThuc`, `vw_Report_TongQuanViDienTu`, `vw_Report_GiaoDichCanXuLy`, `vw_Report_TyLeChuyenDoiOnline`.

**Kết quả demo:**

- Doanh thu theo phương thức thanh toán, phí cổng, tiền nạp thực nhận.

[HÌNH: Doanh thu theo phương thức thanh toán, phí cổng, tiền nạp thực nhận.]

*Hình 67. Report doanh thu theo phương thức thanh toán*

- Tổng quan ví (tổng số dư đang giữ – nợ phải trả khách), giao dịch cần xử lý, tỷ lệ chuyển đổi online.

[HÌNH: Tổng quan ví (tổng số dư đang giữ – nợ phải trả khách), giao dịch cần xử lý, tỷ lệ chuyển đổi online.]

*Hình 68. Report tổng quan ví điện tử và giao dịch cần xử lý*

### 28. Nghiệp vụ nhân viên: khách hàng và thanh toán

**Nội dung:** Nhân viên xem tài khoản khách, mở khóa tài khoản bị khóa, nạp tiền mặt tại quầy, xem sổ cái và hoàn tiền; giám sát bảo mật đăng nhập.

**Thực hiện:** màn hình `/khach-hang`. **Đối tượng CSDL:** `sp_NV_MoKhoaTaiKhoanKH`, `sp_NV_NapTienTaiQuay`, `sp_NV_HoanTien`, `vw_Report_BaoMatTaiKhoanKH`.

**Kết quả demo:**

- Danh sách tài khoản khách, tài khoản TK0005 đang tạm khóa và thao tác mở khóa.

[HÌNH: Danh sách tài khoản khách, tài khoản TK0005 đang tạm khóa và thao tác mở khóa.]

*Hình 69. Màn hình nhân viên – tài khoản khách hàng*

- Báo cáo giám sát bảo mật: số lần sai, số IP trong 24 giờ, cảnh báo.

[HÌNH: Báo cáo giám sát bảo mật: số lần sai, số IP trong 24 giờ, cảnh báo.]

*Hình 70. Report giám sát bảo mật tài khoản khách hàng*

### 29. Cổng khách hàng trên web

**Nội dung:** Khách đăng nhập bằng SĐT (bảng tài khoản demo), xem ví và vé, nạp tiền qua cổng thanh toán mô phỏng (có nút gửi lại callback), gia hạn bằng ví, chia sẻ vé.

**Thực hiện:** màn hình `/kh`. **Đối tượng CSDL:** `vw_KH_*`, `sp_KH_*`, `f_KH_SaoKeVi`.

**Kết quả demo:**

- Trang đăng nhập với bảng tài khoản demo.

[HÌNH: Trang đăng nhập với bảng tài khoản demo.]

*Hình 71. Cổng khách hàng – đăng nhập*

- Trang tổng quan: số dư ví, danh sách vé, thông báo.

[HÌNH: Trang tổng quan: số dư ví, danh sách vé, thông báo.]

*Hình 72. Cổng khách hàng – tổng quan ví và vé*

- Cổng thanh toán mô phỏng: Thành công / Hủy / Gửi lại callback.

[HÌNH: Cổng thanh toán mô phỏng: Thành công / Hủy / Gửi lại callback.]

*Hình 73. Cổng thanh toán mô phỏng*

- Sao kê ví có số dư lũy kế; màn hình chia sẻ vé.

[HÌNH: Sao kê ví có số dư lũy kế; màn hình chia sẻ vé.]

*Hình 74. Cổng khách hàng – sao kê ví và chia sẻ vé*

### 30. Sao lưu và phục hồi cơ sở dữ liệu

**Nội dung:** Thực hiện Full backup, Differential backup và kịch bản khôi phục (Full NORECOVERY → Diff RECOVERY) trong SSMS.

**Thực hiện:** SSMS – sql/09_backup_restore.sql. **Đối tượng CSDL:** `BACKUP DATABASE`, `RESTORE DATABASE`, `BULK INSERT`.

**Kết quả demo:**

- Thực thi Full backup và Differential backup thành công.

[HÌNH: Thực thi Full backup và Differential backup thành công.]

*Hình 75. Sao lưu Full và Differential*

- Khôi phục CSDL từ bản Full và Diff, CSDL trở lại MULTI_USER.

[HÌNH: Khôi phục CSDL từ bản Full và Diff, CSDL trở lại MULTI_USER.]

*Hình 76. Khôi phục cơ sở dữ liệu*


### Tổng hợp kết quả kiểm thử

Theo nhật ký của nhóm trong `UPGRADE_PLAN.md`:

| Ngày | Môi trường | Kết quả |
|---|---|---|
| 06/10/2026 | SQL Server 2022 thật, CSDL thử `QuanLyBaiDoXe_Test` | Nạp full script 0 lỗi; 19/19 kịch bản demo đúng kết quả mong đợi (kể cả kịch bản RLS và kịch bản trigger ROLLBACK trong TRY/CATCH) |
| 06/10/2026 | Cổng `/kh` | Smoke test 40/40 ca: RLS, CSRF, nạp 2 pha + callback lặp, gia hạn, thiếu số dư, quyền người được ủy quyền, khóa sau 5 lần sai, không rò quyền sang trang nhân viên |
| 06/10/2026 | Giao diện | Kiểm tra ở 1440 px và 390 px, chế độ Sáng / Tối |
| 07/10/2026 | SQL Server 2022 | Sau khi thêm N4 (cấp lại thẻ) và N5 (salt nhân viên): full script 0 lỗi, 20/20 ca kiểm thử N4/N5, 19 kịch bản cũ không đổi kết quả; tổng kịch bản demo nâng lên 21 |

**Phương pháp kiểm thử:** mỗi kịch bản demo đóng vai một ca kiểm thử có dữ liệu trước, thao tác và dữ liệu sau để đối chiếu; các ca lỗi kiểm tra đúng mã lỗi mong đợi và dữ liệu không đổi.

---

## CHƯƠNG 5: KẾT LUẬN

Đề tài đã thiết kế và cài đặt được hệ thống cơ sở dữ liệu quản lý chuỗi nhiều bãi đỗ xe trên Microsoft SQL Server. Hệ thống đáp ứng các yêu cầu chính của đồ án: mô tả bài toán, thiết kế mô hình dữ liệu 21 bảng, cài đặt bảng / ràng buộc / chỉ mục / dữ liệu mẫu, xử lý thông tin bằng 23 stored procedure, 4 cursor, 16 trigger, 12 function, 37 view báo cáo và giám sát, an toàn thông tin bằng phân quyền 4 role, Row-Level Security, băm mật khẩu SHA2_512 có salt, sổ cái ví bất biến; kịch bản BULK INSERT, backup / restore; cùng website demo với 21 kịch bản và cổng khách hàng.

**Kết quả nổi bật:**
- Toàn bộ logic nghiệp vụ nằm trong CSDL: dù ghi dữ liệu từ web, SSMS hay công cụ khác đều tuân thủ cùng quy tắc.
- Biểu phí riêng từng chi nhánh, tính phí tự động theo block giờ, chặn gian lận (bảo vệ không sửa được tiền và lượt gửi).
- Giám sát sức chứa thời gian thực, chặn quá tải, đối soát bộ đếm.
- Vé tháng toàn vẹn giao dịch; thẻ vật lý tái sử dụng cho vé mới mà vẫn giữ lịch sử.
- Ví điện tử an toàn: số dư không âm, không sửa / xóa sổ cái kể cả quản trị viên, nạp tiền idempotent, hoàn tiền đối ứng.
- Kiểm thử trên SQL Server 2022: full script 0 lỗi, kịch bản demo đúng kết quả mong đợi, 40/40 ca smoke test cổng khách hàng.

### Hạn chế
- Bản demo dùng một login SQL chung cho toàn web; RLS cho khách chỉ được minh họa qua `EXECUTE AS USER`, chưa áp vào luồng web `/kh`.
- Cổng thanh toán là mô phỏng (mã tham chiếu cố định `SIM-<MaGD>`), chưa xác thực chữ ký callback.
- 6 view báo cáo tổng hợp bổ sung (`vw_Report_DoanhThuTheoNgay`, `DoanhThuTheoThang`, `LuuLuongTheoGio`, `ThongKeTheoLoaiXe`, `XepHangBai`, `TongQuanChuoi`) chưa được GRANT cho `r_QuanLyBai`.
- Dữ liệu mẫu phần cổng khách hàng còn viết tay, chưa có script sinh từ Excel.
- `QL_BaiDoXe_FullScript.sql` phải cập nhật thủ công khi sửa module.
- Script sao lưu dùng đường dẫn mẫu, chạy riêng; chưa có Log backup.
- Trang demo COMMIT thật nên phải nạp lại CSDL để chạy lại từ đầu.
- Biển số nhập tay, chưa có nhận diện tự động.

### Hướng phát triển
- Tạo login riêng cho cổng khách hàng (`CREATE USER ... FOR LOGIN` thêm vào `r_KhachHang`) để RLS áp dụng thật trên web.
- Tích hợp cổng thanh toán thật (MoMo, VNPay) với chữ ký và xác thực callback.
- Bổ sung GRANT cho 6 view báo cáo tổng hợp.
- Nhận diện biển số (camera / LPR), đặt chỗ trước, thanh toán không tiền mặt tại cổng.
- Dashboard Power BI / Tableau kết nối trực tiếp `vw_Report_*` (thư mục `reports_screenshots/` đã chuẩn bị chỗ lưu ảnh).
- Lập lịch chạy cursor bằng SQL Server Agent; thêm Transaction Log backup, Always On.
- Script sinh dữ liệu mẫu cổng khách hàng từ Excel; script tự gộp full script.

---

## TÀI LIỆU THAM KHẢO

[1] Microsoft SQL Server Documentation – Transact-SQL reference.
[2] Microsoft SQL Server Documentation – Row-Level Security; SESSION_CONTEXT.
[3] Microsoft SQL Server Documentation – Back up and restore of SQL Server databases.
[4] Flask Documentation (phiên bản 3.0).
[5] pyodbc Documentation.
[6] [CẦN BỔ SUNG: giáo trình / slide bài giảng môn Quản lý Thông tin]

---

# PHẦN B – TƯ LIỆU BỔ SUNG CHO SLIDE VÀ THUYẾT TRÌNH

> Phần này không đưa vào thân báo cáo Word; dùng để thiết kế slide và chuẩn bị thuyết trình.

## B.1. Tám bài toán thực tế

Chuỗi bãi đỗ xe ở nhiều quận (Quận 1, Quận 3, Bình Thạnh, Tân Bình, Quận 7) nếu quản lý thủ công bằng sổ sách hoặc Excel rời rạc sẽ gặp: sai lệch số xe đang đỗ, không biết còn chỗ theo loại xe, tính phí sai hoặc gian lận, khó tra lịch sử vào/ra, quên nhắc vé tháng hết hạn, khó đối soát sự cố mất thẻ. Đồ án giải quyết 8 bài toán:

### Bài toán 1 – Kiểm soát barrier và cấp ô đỗ tự động
- **Vấn đề:** giờ cao điểm, bảo vệ phải nhìn bằng mắt xem bãi còn chỗ không và chỉ tay hướng dẫn, gây ùn tắc ở cổng; ô tô chạy vòng tìm chỗ trong hầm.
- **Giải pháp:** `sp_XeVaoBai` gọi `f_TimSlotTrong(@MaBai, @MaLoaiXe)` lấy ô trống đầu tiên đúng loại xe; trigger `trg_DongBoTrangThaiSlot` đổi ô sang "Đã đỗ" và tăng `SoLuongHienTai`; view `v_BotCong_BangDenCong` hiện đèn XANH / VÀNG / ĐỎ và ô gợi ý cho từng loại xe trước khi barrier mở.

### Bài toán 2 – Tính phí theo chi nhánh, chống thất thoát doanh thu
- **Vấn đề:** bãi trung tâm (Quận 1) có giá cao hơn bãi vùng ven; bảo vệ tính nhẩm dễ sai hoặc thông đồng: thu tiền nhưng không ghi lượt, sửa số tiền rồi bỏ túi.
- **Giải pháp:** khóa chính hỗn hợp `(MaLoaiXe, MaBai)` trong `LOAI_XE` cho phép mỗi bãi có biểu phí riêng; `f_TinhTienGuiXe` tự tính tiền; role `r_BaoVe` bị `DENY UPDATE, DELETE` trên `LUOT_GUI` và `HOA_DON_VE_THANG`; view `v_BotCong_XeChoRa` gắn cờ `CanhBaoLechBienSo` khi biển số lúc vào khác biển số đăng ký vé tháng (mượn thẻ).

### Bài toán 3 – Vé tháng và toàn vẹn giao dịch
- **Vấn đề:** đăng ký vé tháng gồm nhiều bước; mất điện hoặc đứt mạng giữa chừng (đã đổi thẻ nhưng chưa ghi hóa đơn) làm lệch dữ liệu kế toán.
- **Giải pháp:** `sp_DangKyThanhVien` gói các bước trong một TRANSACTION với TRY/CATCH: lỗi ở bất kỳ bước nào (trùng CCCD, thẻ đã gắn vé, thiếu biểu phí) đều ROLLBACK toàn bộ; `trg_ChanSuDungVeHetHan` chặn thẻ tháng quá hạn ở cổng.

### Bài toán 4 – Mất thẻ và sự cố an ninh
- **Vấn đề:** khách đánh rơi thẻ, kẻ gian nhặt được có thể lấy xe; biên bản giấy dễ thất lạc, không lưu vết thời gian và tiền phạt.
- **Giải pháp:** `sp_BaoMatThe` chuyển thẻ sang "Mất" và tạm khóa vé tháng đang dùng; trigger `trg_LogLichSuSuCo` tự lập biên bản `LICHSU_SU_CO` phạt 50.000 ₫; `trg_KiemTraCheckIn` chặn thẻ mất ở cổng (lỗi 50002).

### Bài toán 5 – Giám sát sức chứa thời gian thực
- **Vấn đề:** nhận xe vượt sức chứa làm xe đỗ chắn lối thoát hiểm, vi phạm PCCC; quản lý không biết tầng nào còn chỗ.
- **Giải pháp:** `CHECK (SoLuongHienTai >= 0 AND SoLuongHienTai <= SucChua)`; trigger chặn bãi đầy (50001) bằng cách đếm trực tiếp lượt đang mở; 3 view sơ đồ `v_SodoBai_ODoChiTiet`, `v_SodoBai_TongHopKhuVuc`, `v_SodoBai_TongQuanBai` (kèm cờ đối soát bộ đếm).

### Bài toán 6 – Tự động hóa vận hành bằng cursor
- **Vấn đề:** hằng ngày quản lý dò tay hàng trăm vé để nhắc gia hạn / khóa thẻ; cuối kỳ kế toán cộng tay doanh thu nhiều bãi.
- **Giải pháp:** 4 procedure dùng cursor: cảnh báo hạn vé, tổng kết doanh thu chuỗi, tự động gia hạn bằng ví (savepoint từng vé), đối soát ví cuối ngày.

### Bài toán 7 – Báo cáo BI hỗ trợ quyết định
- **Vấn đề:** ban giám đốc cần số liệu: bãi nào hiệu quả nhất, nên đầu tư thêm ô ô tô hay xe máy, giờ cao điểm, tỷ lệ lấp đầy.
- **Giải pháp:** 16 view `vw_Report_*` sẵn sàng kết nối Power BI / Tableau: doanh thu theo bãi / ngày / tháng / phương thức, công suất, xếp hạng, lưu lượng theo giờ, cơ cấu loại xe, sự cố, tổng quan ví, bảo mật tài khoản, tỷ lệ chuyển đổi online.

### Bài toán 8 – Cổng khách hàng và ví trả trước
- **Vấn đề:** khách vé tháng phải ra quầy gia hạn, dễ quên hạn và bị chặn ở cổng; một vé dùng cho cả gia đình nhưng chỉ chủ vé thao tác; tiền trong ví là tiền của khách – số dư sai, cộng trùng khi cổng thanh toán gửi lại callback, hoặc bị sửa tay đều gây thiệt hại trực tiếp.
- **Giải pháp:** khách tự tạo tài khoản bằng SĐT + CCCD; đăng nhập sai 5 lần khóa 15 phút; nạp tiền 2 pha idempotent; sổ cái `GIAO_DICH` chỉ ghi thêm; gia hạn online và tự động gia hạn dùng chung lõi `sp_GiaHanVe_Core` với quầy; chia sẻ vé cho tối đa 3 người theo vai trò.

---

## B.2. Kiến trúc hệ thống và tổ chức mã nguồn

### Kiến trúc 3 lớp

```
┌──────────────────────────── Trình duyệt ─────────────────────────────┐
│  Giao diện nhân viên (/, /gate, /map, /reports, /tables, /sql,       │
│  /setup, /khach-hang)          │      Cổng khách hàng (/kh/...)      │
└───────────────┬────────────────┴──────────────────┬──────────────────┘
                │ HTTP                              │ HTTP (CSRF, phiên 30 phút)
┌───────────────▼───────────────────────────────────▼──────────────────┐
│ Flask (app/routes.py, app/kh_routes.py, app/queries.py, app/db.py)   │
│ - Chỉ gọi EXEC thủ tục / SELECT view, không chứa logic nghiệp vụ     │
│ - Cổng /kh đặt SESSION_CONTEXT (MaTK, MaKH) read-only cho mỗi kết nối│
│ - Tắt ODBC pooling để ngữ cảnh phiên không rò sang kết nối khác      │
└───────────────┬──────────────────────────────────────────────────────┘
                │ pyodbc (ODBC Driver 17/18)
┌───────────────▼──────────────────────────────────────────────────────┐
│ SQL Server: CSDL QuanLyBaiDoXe                                       │
│ 21 bảng · 37 view · 23 SP + 4 cursor SP · 16 trigger · 12 function   │
│ RBAC 4 role · RLS policy bao_mat.rls_KhachHang · sequence seq_GiaoDich│
└──────────────────────────────────────────────────────────────────────┘
```

### Tổ chức mã nguồn SQL (chạy theo thứ tự)

| File | Số dòng | Nội dung |
|---|---|---|
| `01_schema.sql` | 608 | 21 bảng, ràng buộc, chỉ mục, sequence, danh mục tra cứu (MERGE), cột V7 trên bảng cũ, backfill `LUOT_GUI.MaVe` |
| `02_sample_data.sql` | 426 | Dữ liệu mẫu (phần vận hành sinh từ Excel; phần cổng khách hàng viết tay) |
| `03_procedures.sql` | 1.659 | 23 stored procedure |
| `04_triggers.sql` | 653 | 16 trigger + thứ tự chạy trigger |
| `05_functions.sql` | 362 | 12 function |
| `06_cursors.sql` | 434 | 4 procedure dùng cursor |
| `07_views.sql` | 1.167 | 37 view |
| `08_security_rbac.sql` | 347 | 4 role, GRANT/DENY, schema `bao_mat`, 4 hàm lọc, security policy |
| `09_backup_restore.sql` | 81 | BULK INSERT, Full / Differential backup, restore (chạy riêng) |
| `QL_BaiDoXe_FullScript.sql` | 5.701 | Bản gộp 01 → 08 để cài đặt một lần |
| `Demo_Queries.sql` | 115 | Câu lệnh đối chứng chạy trong SSMS |

Mỗi file 01 → 08 gồm phần **vận hành bãi** (phiên bản V6, 11 bảng gốc) rồi đến phần **cổng khách hàng** (nâng cấp V7, 10 bảng mới). Nguyên tắc nâng cấp: chỉ thêm cột cho phép NULL hoặc có DEFAULT trên bảng cũ, không đổi tên, không xóa cột, không phá các kịch bản demo ban đầu. Script schema tự gỡ đối tượng cũ theo thứ tự ngược phụ thuộc (gỡ security policy và hàm RLS trước vì chúng gắn `SCHEMABINDING` vào bảng).

### Tổ chức mã nguồn ứng dụng

| File | Vai trò |
|---|---|
| `run.py` | Điểm khởi chạy Flask, cổng lấy từ biến `PORT` (mặc định 5000) |
| `app/__init__.py` | Tạo Flask app, bộ lọc hiển thị tiền VND, ngày giờ, trạng thái; cấu hình cookie `SameSite=Lax`, phiên 30 phút |
| `app/db.py` | Tầng kết nối pyodbc: `get_connection`, `get_kh_connection` (đặt `SESSION_CONTEXT`), `execute_script_return_sets` (lấy mọi result set), `run_sql_file` (tách batch theo `GO`); tắt pooling |
| `app/errors.py` | Chuẩn hóa lỗi SQL Server (mã 500xx) thành thông báo thân thiện |
| `app/queries.py` | Danh mục 21 bảng, view báo cáo, view vận hành, 21 kịch bản demo (SQL trước / thực thi / sau, nhãn kết quả), 5 nhóm kịch bản |
| `app/routes.py` | Màn hình nhân viên |
| `app/kh_routes.py` | Cổng khách hàng `/kh` |
| `app/templates/` | 16 template giao diện nhân viên + 15 template cổng khách hàng |
| `app/static/` | `style.css` (design tokens, Sáng / Tối, responsive), `main.js` |

### Cơ chế kết nối và chạy demo
- **Trang demo `/demo/<mã>`:** khi mở trang chạy khối SQL "Trước" (không commit); khi bấm thực thi chạy khối "Thực thi" với **COMMIT thật**, sau đó chạy khối "Sau" để đối chiếu. Nếu khối thực thi ném lỗi (trigger chặn), web hiển thị thông báo "lỗi này là KẾT QUẢ MONG ĐỢI". Vì dữ liệu thay đổi thật, muốn chạy lại kịch bản từ đầu cần nạp lại CSDL qua `/setup`.
- **Cổng khách hàng:** mỗi request mở một kết nối riêng ở chế độ autocommit (để nhật ký đăng nhập sai không bị rollback khi thủ tục THROW), đặt `SESSION_CONTEXT` `MaTK` và `MaKH` ở chế độ read-only, đóng kết nối khi kết thúc request.
- **Tắt ODBC pooling (`pyodbc.pooling = False`):** đã kiểm chứng trên SQL Server 2022 rằng kết nối pooled giữ lại `SESSION_CONTEXT` sang lần mở kế tiếp; tắt pooling để trang nhân viên không chạy nhầm ngữ cảnh khách (chi phí mở kết nối mới khoảng 25 ms).
- **Cài đặt CSDL từ web (`/setup`):** đọc full script, tách theo `GO`, chạy trên database `master` ở chế độ autocommit (cho phép `CREATE DATABASE`); chỉ bật khi `ALLOW_RUN_FULL_SCRIPT=1`.

---

## B.3. Ứng dụng web demo

### Giao diện nhân viên

| Đường dẫn | Màn hình | Dữ liệu dùng |
|---|---|---|
| `/` | Trang chủ: KPI, 21 kịch bản demo dạng thẻ, lọc theo 5 nhóm kèm số lượng | `DEMO_GROUPS`, `DEMO_CASES` |
| `/demo/<mã kịch bản>` | Chạy kịch bản: bài toán, bảng dữ liệu **Trước**, nút thực thi, kết quả, bảng **Sau**; xem SQL song song SSMS | SQL trong `app/queries.py` |
| `/gate` | Bốt kiểm soát cổng: ô quét thẻ (đèn MỞ BARRIER / TỪ CHỐI, lý do, cảnh báo), bảng đèn theo loại xe, xe chờ ra (tiền tạm tính, lệch biển số), nhật ký 200 sự kiện; chọn bãi | 4 view `v_BotCong_*` |
| `/map` | Sơ đồ bãi: ô trống xanh, ô có xe đỏ kèm biển số; thanh tổng hợp khu vực; thẻ công suất; chọn bãi | 3 view `v_SodoBai_*` |
| `/reports`, `/report/<view>` | Danh mục 23 view (16 báo cáo + 7 vận hành), nhóm, tìm kiếm; xem dữ liệu chi tiết; ảnh dashboard mẫu nếu có trong `reports_screenshots/` | `REPORT_VIEWS`, `OPERATION_VIEWS` |
| `/tables`, `/table/<bảng>` | Danh mục 21 bảng nhóm theo phân hệ, tìm kiếm; xem dữ liệu bảng | `TABLES_TO_SHOW` |
| `/sql` | Trình soạn và chạy câu lệnh SQL, hiển thị mọi result set | – |
| `/setup` | Kiểm tra kết nối (`CONNECTED`), đếm số đối tượng thực trong CSDL, nạp lại full script (chỉ mở khóa sau khi kết nối thành công) | Full script |
| `/khach-hang` | 3 tab cho nhân viên: tài khoản khách (mở khóa), giao dịch (nạp tiền tại quầy, sổ cái, hoàn tiền có xác nhận), giám sát bảo mật; dùng ô tìm kiếm | `sp_NV_*`, view báo cáo ví |
| `/health` | Kiểm tra sống của ứng dụng | – |

### Cổng khách hàng `/kh` (layout riêng, mở từ sidebar "Cổng khách hàng ↗")

| Đường dẫn | Chức năng | Đối tượng CSDL |
|---|---|---|
| `/kh/dang-nhap` | Đăng nhập SĐT + mật khẩu; bảng **tài khoản demo** bấm để điền sẵn (mật khẩu mẫu `Khach@2026`, ẩn khi `KH_DEMO_ACCOUNTS=0`) | `sp_KH_DangNhap` |
| `/kh/dang-ky` | Tạo tài khoản bằng SĐT + CCCD | `sp_KH_DangKyTaiKhoan` |
| `/kh/dang-xuat` | Đăng xuất | – |
| `/kh/` | Tổng quan: số dư ví, danh sách vé, thông báo | `vw_KH_HoSoCuaToi`, `vw_KH_VeThangCuaToi` |
| `/kh/ve/<mã vé>` | Chi tiết vé, hóa đơn, bật / tắt tự gia hạn, báo mất thẻ, người được chia sẻ; nút ẩn theo quyền | `vw_KH_QuyenTrenVe`, `sp_KH_CaiDatTuDongGiaHan`, `sp_KH_BaoMatThe` |
| `/kh/ve/<mã vé>/gia-han` | Chọn số tháng, xem trước giá và số dư sau gia hạn, xác nhận | `f_KH_TinhPhiGiaHan`, `sp_KH_GiaHanBangVi` |
| `/kh/nap-tien` | Chọn phương thức, số tiền (gợi ý 100.000 / 200.000 / 500.000 / 1.000.000), hiển thị hạn mức còn lại | `vw_KH_PhuongThucNapVi`, `vw_KH_HanMucNap`, `sp_KH_NapTien_KhoiTao` |
| `/kh/nap-tien/<mã GD>/cong-thanh-toan` | Cổng thanh toán mô phỏng: Thành công / Hủy / **Gửi lại callback** (mã tham chiếu `SIM-<MaGD>`) | `sp_KH_NapTien_XacNhan` |
| `/kh/lich-su-do-xe` | Lịch sử đỗ xe, lọc theo khoảng ngày | `vw_KH_LichSuDoXe` |
| `/kh/giao-dich` | Sao kê ví có số dư lũy kế, lọc theo khoảng ngày | `f_KH_SaoKeVi` |
| `/kh/thong-bao` | Hộp thư, đánh dấu đã đọc | `vw_KH_ThongBao`, `sp_KH_DanhDauDaDoc` |
| `/kh/uy-quyen` | Chia sẻ vé, xem danh sách, thu hồi | `vw_KH_VaiTroUyQuyen`, `sp_KH_DanhSachUyQuyen`, `sp_KH_UyQuyenVe`, `sp_KH_ThuHoiUyQuyen` |
| `/kh/bao-mat` | Đổi mật khẩu, nhật ký đăng nhập | `sp_KH_DoiMatKhau`, `vw_KH_NhatKyDangNhap` |

Giao diện hỗ trợ chế độ Sáng / Tối, responsive (đã kiểm tra ở 1440 px và 390 px).

---

## B.4. Tiến trình dự án và mảng công việc

**Các mảng công việc của dự án (dùng để phân công khi điền bảng):**

| # | Mảng công việc | Sản phẩm tương ứng |
|---|---|---|
| 1 | Phân tích nghiệp vụ, đặc tả, ERD, từ điển dữ liệu | `docs/Dac Ta Nghiep Vu - Updated.docx`, `docs/Parking_lot_ERD.png` |
| 2 | Schema 21 bảng, ràng buộc, chỉ mục, script tổng hợp | `sql/01_schema.sql`, `sql/QL_BaiDoXe_FullScript.sql` |
| 3 | Stored procedure và transaction | `sql/03_procedures.sql` |
| 4 | Trigger | `sql/04_triggers.sql` |
| 5 | Function, cursor | `sql/05_functions.sql`, `sql/06_cursors.sql` |
| 6 | View vận hành và báo cáo BI | `sql/07_views.sql` |
| 7 | Bảo mật RBAC, RLS; sao lưu / phục hồi | `sql/08_security_rbac.sql`, `sql/09_backup_restore.sql` |
| 8 | Dữ liệu mẫu | `docs/QuanLyBaiDoXe_DuLieuMau.xlsx`, `sql/02_sample_data.sql` |
| 9 | Ứng dụng web nhân viên | `app/routes.py`, `app/queries.py`, `app/templates/*.html` |
| 10 | Cổng khách hàng `/kh` | `app/kh_routes.py`, `app/templates/kh/*.html` |
| 11 | Kịch bản demo, kiểm thử, tài liệu, báo cáo, slide | `docs/DemoGuilde.md`, `README.md`, `UPGRADE_PLAN.md` |

**Tiến trình dự án (theo Git và `UPGRADE_PLAN.md`):**

| Mốc | Nội dung |
|---|---|
| 07/09/2026 | Khởi tạo repository, cấu trúc dự án |
| 08/09/2026 | Chuyển kiến trúc sang Python Flask + SQL script tối ưu; làm mới giao diện |
| Tháng 9/2026 | Phiên bản V6: 11 bảng, 6 procedure, 8 trigger, 3 function, 2 cursor, 21 view, 10 kịch bản demo; dữ liệu mẫu sinh từ Excel, mở rộng 5 bãi |
| 30/09/2026 | Lập kế hoạch nâng cấp cổng khách hàng (`UPGRADE_PLAN.md`) |
| 06/10/2026 | Triển khai V7: 10 bảng mới, ví điện tử, sổ cái, RLS, cổng `/kh`; chạy thử trên SQL Server 2022 thật |
| 07/10/2026 | Xử lý N4 (cấp lại thẻ cho vé mới) và N5 (salt cho mật khẩu nhân viên); tổng 21 kịch bản demo |

---

## B.5. Lộ trình demo trực tiếp (khoảng 25 phút)

> Gợi ý sắp xếp; nhóm có thể điều chỉnh. Trước buổi demo: nạp lại CSDL qua `/setup`.

| Phút | Phần | Thao tác | Thông điệp |
|---|---|---|---|
| 0–2 | Mở đầu | `/setup` kiểm tra kết nối, đếm đối tượng; `/tables` | Quy mô: 21 bảng, 37 view, 27 procedure, 16 trigger |
| 2–8 | Vòng đời lượt xe | A1 check-in → `/map` thấy ô đổi màu → `/gate` tra thẻ, bảng đèn → A2 check-out | Logic nằm trong CSDL, giao diện chỉ đọc view |
| 8–12 | An ninh cổng | B1 thẻ mất, B2 vé hết hạn, B3 sai bãi; A5 báo mất thẻ | Trigger chặn mọi đường ghi dữ liệu |
| 12–16 | Vé tháng | A3 đăng ký (transaction), A4 gia hạn, A6 cấp lại thẻ | ACID, lõi dùng chung, filtered index |
| 16–19 | Tự động hóa và BI | D1 cursor; `/reports` mở `vw_Report_DoanhThuTheoBai`, `vw_Report_XepHangBai`, `vw_Report_LuuLuongTheoGio` | Cursor cho xử lý từng dòng, view cho báo cáo |
| 19–23 | Cổng khách hàng | Đăng nhập `/kh` bằng tài khoản demo → nạp tiền 2 pha, bấm "Gửi lại callback" → gia hạn bằng ví → chia sẻ vé | Ví an toàn, idempotent, phân quyền theo vai trò |
| 23–25 | Bảo mật | A7 salt, E2 khóa tài khoản, E6 RLS, E9 sổ cái bất biến | Bảo mật nhiều lớp ngay trong CSDL |

---

## B.6. Kịch bản demo kèm lời dẫn thuyết trình

Mỗi kịch bản trên web chạy theo 5 bước: **(1) Bài toán → (2) Dữ liệu trước → (3) Thực thi → (4) Dữ liệu sau → (5) Đối chiếu kết luận**. Kịch bản trigger chặn coi lỗi trả về là **kết quả mong đợi**. Mã SQL đầy đủ của từng kịch bản ở **Phụ lục B**.

**Lưu ý vận hành:** khối "Thực thi" được COMMIT thật. Một số kịch bản thay đổi dữ liệu mẫu (ví dụ A3 đổi thẻ THE0003 sang thẻ tháng, A5 khóa thẻ THE0001), nên trước buổi demo chính thức nên nạp lại CSDL qua `/setup` và chạy theo thứ tự đã tập.

### Tóm tắt 21 kịch bản

| Nhóm | Số kịch bản | Mã kịch bản |
|---|---|---|
| A. Procedure | 7 | sp-xe-vao-bai, sp-xe-ra-bai, sp-dang-ky-thanh-vien, sp-gia-han-ve-thang, sp-bao-mat-the, sp-cap-lai-the, sp-dang-nhap-nhan-vien |
| B. Trigger | 3 | trigger-chan-checkin-loi, trigger-chan-ve-het-han, trigger-chan-sai-bai |
| C. Function | 1 | function-tinh-tien-slot |
| D. Cursor | 1 | cursor-canh-bao-doanh-thu |
| E. Cổng khách hàng | 9 | kh-dang-ky-tai-khoan, kh-dang-nhap-khoa-tai-khoan, kh-nap-tien-2-pha, kh-gia-han-bang-vi, trigger-chan-so-du-am, rls-co-lap-du-lieu-khach-hang, kh-uy-quyen-ve, cursor-tu-dong-gia-han, trigger-so-cai-bat-bien |

### Nhóm A – Stored Procedure (7)

**A1. `sp-xe-vao-bai` – Check-in xe vào bãi**
- **Bài toán:** xe máy quét thẻ THE0003, biển 59T1-888.88, vào bãi Lê Lai (BAI_Q1); hệ thống phải tự cấp ô đỗ.
- **Đối tượng CSDL:** `sp_XeVaoBai`, `f_TimSlotTrong`, `trg_KiemTraCheckIn`, `trg_DongBoTrangThaiSlot`.
- **Dữ liệu trước:** công suất BAI_Q1; 10 ô đầu của BAI_Q1; 5 lượt gửi gần nhất.
- **Kết quả mong đợi:** thủ tục trả mã lượt và ô được cấp; ô chuyển "Đã đỗ"; `SoLuongHienTai` BAI_Q1 tăng 1; dòng mới trong `LUOT_GUI`.
- **Bảng ảnh hưởng:** `LUOT_GUI` (thêm), `VI_TRI_DO`, `BAI_DO_XE` (cập nhật qua trigger).
- **Lời dẫn:** "Python chỉ gọi một thủ tục. Việc chọn ô, ghi lượt, đổi màu ô và tăng bộ đếm đều do CSDL làm, nên bất kỳ ứng dụng nào ghi vào bảng này cũng được kiểm soát giống nhau."

**A2. `sp-xe-ra-bai` – Check-out và thu phí**
- **Bài toán:** xe đang đỗ quét thẻ ra; tính tiền chính xác theo block giờ.
- **Đối tượng:** `sp_XeRaBai`, `f_TinhTienGuiXe`, `trg_DongBoTrangThaiSlot`.
- **Dữ liệu trước:** xe đang đỗ, ô đang có xe, số xe các bãi.
- **Kết quả:** hóa đơn check-out với số tiền thực thu; lượt có `ThoiGianRa`, `TienGui`; ô về "Trống"; số xe bãi giảm 1.
- **Bảng ảnh hưởng:** `LUOT_GUI`, `VI_TRI_DO`, `BAI_DO_XE`.
- **Lời dẫn:** "Miễn phí 15 phút đầu, sau đó làm tròn lên từng giờ, đơn giá lấy theo đúng loại xe tại đúng bãi. Bảo vệ không nhập số tiền nên không thể sửa."

**A3. `sp-dang-ky-thanh-vien` – Đăng ký vé tháng (Transaction)**
- **Bài toán:** đăng ký vé 3 tháng cho khách mới Trần Đình Trọng bằng thẻ THE0003; chuỗi tạo khách → đổi thẻ → tạo vé → hóa đơn phải "tất cả hoặc không".
- **Đối tượng:** `sp_DangKyThanhVien` (BEGIN TRAN / COMMIT / ROLLBACK), `trg_KiemTraLoaiXe_VeThang`, `trg_HoaDon_ThongBaoKhachHang`.
- **Kết quả:** khách mới; thẻ THE0003 đổi sang "Tháng"; vé mới hạn 3 tháng; hóa đơn được lập.
- **Bảng ảnh hưởng:** `KHACH_HANG`, `THE_XE`, `VE_THANG`, `HOA_DON_VE_THANG`, `THONG_BAO`.
- **Lời dẫn:** "Nếu bất kỳ bước nào lỗi – trùng CCCD, thẻ đang gắn vé khác, thiếu biểu phí – toàn bộ được hoàn tác, không bao giờ có thẻ đã đổi mà thiếu hóa đơn."

**A4. `sp-gia-han-ve-thang` – Gia hạn vé tại quầy**
- **Bài toán:** khách vé V0001 (xe máy, BAI_Q1) đến quầy BAI_Q1 gia hạn thêm 2 tháng.
- **Đối tượng:** `sp_GiaHanTheThang` → `sp_GiaHanVe_Core`.
- **Kết quả:** `NgayHetHan` cộng dồn 2 tháng từ hạn cũ; hóa đơn mới 2 × 180.000 = 360.000 ₫ kênh "Tại quầy"; thông báo cho khách.
- **Bảng ảnh hưởng:** `VE_THANG`, `THE_XE` (mở khóa nếu đang khóa), `HOA_DON_VE_THANG`, `THONG_BAO`.
- **Lời dẫn:** "Quầy, cổng online và cursor tự động gia hạn đều gọi cùng một lõi, nên quy tắc giá và quy tắc chặn (50018, 50019, 50066) chỉ viết một lần."

**A5. `sp-bao-mat-the` – Báo mất thẻ và lập biên bản**
- **Bài toán:** khách báo mất thẻ THE0001 tại bãi Quận 1.
- **Đối tượng:** `sp_BaoMatThe`, `trg_LogLichSuSuCo`.
- **Kết quả:** thẻ chuyển "Mất"; trigger tự tạo biên bản phạt 50.000 ₫ "Chờ xử lý"; vé tháng đang dùng của thẻ (nếu có) chuyển "Tạm khóa".
- **Bảng ảnh hưởng:** `THE_XE`, `LICHSU_SU_CO`, `VE_THANG`.
- **Lời dẫn:** "Thủ tục chỉ đổi một cột trạng thái. Biên bản do trigger tạo, nên dù ai đổi trạng thái thẻ sang 'Mất' bằng cách nào cũng luôn có biên bản."

**A6. `sp-cap-lai-the` – Cấp lại thẻ cho vé mới (Filtered Index)**
- **Bài toán:** vé V0008 của KH0008 hết hạn từ 15/07/2026; quầy Quận 7 thu hồi thẻ THE0022 và cấp lại cho khách mới.
- **Đối tượng:** `UX_VeThang_MaThe_ConDung`, `f_VeHienHanhCuaThe`, `sp_DangKyThanhVien`, `sp_XeVaoBai`, `sp_GiaHanTheThang`.
- **Dữ liệu trước:** THE0022 đang gắn vé đã hết hạn; bốt cổng tra THE0022 (quẹt lúc này bị chặn 50003).
- **Các bước thực thi (4 bảng kết quả):** (1) thử cấp một thẻ đang gắn vé còn hạn → 50065 thay vì lỗi trùng khóa thô; (2) đăng ký vé mới với THE0022 → thành công; (3) khách mới quẹt thẻ vào bãi → check-in thành công, vé cũ không chặn; (4) thử gia hạn vé cũ V0008 → 50066.
- **Dữ liệu sau:** THE0022 có 2 vé trong lịch sử (cũ "Hết hạn", mới "Hoạt động"); lượt gửi ghi đúng vé mới; bốt cổng chỉ hiện vé hiện hành.
- **Bảng ảnh hưởng:** `KHACH_HANG`, `THE_XE`, `VE_THANG`, `HOA_DON_VE_THANG`, `THONG_BAO`, `LUOT_GUI`, `VI_TRI_DO`, `BAI_DO_XE`.
- **Lời dẫn:** "Unique index có lọc chỉ cấm hai vé còn dùng trên cùng thẻ, nên thẻ vật lý được tái sử dụng mà lịch sử vé cũ vẫn giữ nguyên."

**A7. `sp-dang-nhap-nhan-vien` – Đăng nhập nhân viên, mật khẩu có salt**
- **Bài toán:** hai tài khoản cùng mật khẩu `123456` phải có hash khác nhau để chống tra bảng băm dựng sẵn.
- **Đối tượng:** `sp_DangNhap`, `f_BamMatKhau`.
- **Dữ liệu trước:** các tài khoản cùng mật khẩu `123456` nhưng khác salt và khác hash (hiển thị 16 byte đầu của hash 64 byte); đối chiếu bằng `f_BamMatKhau` đều khớp.
- **Thực thi:** `admin` / `Admin@2026` đăng nhập thành công, trả hồ sơ và phạm vi bãi phụ trách; `quanly_q1` nhập sai mật khẩu → 50022; `baove_khoa` đúng mật khẩu nhưng tài khoản bị khóa → 50021.
- **Dữ liệu sau:** phân quyền trên bảng `TAI_KHOAN` (`r_QuanLyBai` bị DENY đọc cột hash / salt).
- **Bảng ảnh hưởng:** chỉ đọc `TAI_KHOAN`, `NHAN_VIEN`, `BAI_DO_XE`.
- **Lời dẫn:** "Mỗi tài khoản có salt 16 byte riêng. Kẻ gian có lấy được bảng cũng không thể dùng một bảng tra hash cho tất cả tài khoản."

### Nhóm B – Trigger (3)

**B1. `trigger-chan-checkin-loi` – Chặn thẻ lỗi và bãi đầy**
- **Bài toán:** cố dùng thẻ THE0006 (đang "Mất" / "Bị khóa") để check-in.
- **Đối tượng:** `trg_KiemTraCheckIn`.
- **Kết quả:** lỗi 50002, ROLLBACK; thẻ giữ nguyên trạng thái; tổng số lượt gửi không đổi. Trigger còn chặn 50001, 50014, 50015, 50016.
- **Bảng ảnh hưởng:** không bảng nào thay đổi.
- **Lời dẫn:** "Lỗi đỏ trên màn hình là kết quả mong đợi: CSDL tự từ chối, kể cả khi lệnh INSERT không đi qua thủ tục."

**B2. `trigger-chan-ve-het-han` – Chặn vé tháng quá hạn**
- **Bài toán:** thẻ tháng THE0008 (vé V0003 hết hạn 03/02/2026) quét vào bãi.
- **Đối tượng:** `trg_ChanSuDungVeHetHan`.
- **Kết quả:** lỗi 50003; vé vẫn "Hết hạn"; không có lượt gửi mới.

**B3. `trigger-chan-sai-bai` – Chặn vé gửi sai bãi**
- **Bài toán:** ô tô vé V0006 (thẻ THE0017) chỉ đăng ký tại BAI_TB nhưng quét vào BAI_Q1; so sánh với vé toàn chuỗi V0004 (`ALL`).
- **Đối tượng:** `trg_KiemTraBaiApDungVeThang`, `sp_XeVaoBai`.
- **Kết quả:** lỗi 50004; BAI_Q1 không tăng xe; không có lượt gửi mới tại BAI_Q1; vé `ALL` gửi được mọi bãi.

### Nhóm C – Function (1)

**C1. `function-tinh-tien-slot` – Tính tiền giờ và dò ô trống**
- **Bài toán:** kiểm chứng trực tiếp kết quả các hàm nghiệp vụ.
- **Dữ liệu trước:** biểu phí giá giờ các bãi; ô trống hiện có tại BAI_Q1.
- **Thực thi (4 bảng):** `f_TinhTienGuiXe` cho ô tô gửi 5 giờ tại Landmark 81 (5 × 30.000 = 150.000 ₫); `f_TimSlotTrong` xe máy BAI_Q1; `f_TimSlotTrong` ô tô BAI_Q3; `f_DanhSachXeTrongBai('BAI_Q1')`.
- **Dữ liệu sau:** báo cáo công suất toàn hệ thống.
- **Bảng ảnh hưởng:** chỉ đọc.

### Nhóm D – Cursor (1)

**D1. `cursor-canh-bao-doanh-thu` – Quét hạn vé và tổng kết doanh thu chuỗi**
- **Bài toán:** thay việc dò tay vé hết hạn và cộng doanh thu thủ công.
- **Đối tượng:** `sp_DemoCanhBaoHanTheThang` (`cur_VeThang`), `sp_DemoTongKetDoanhThuChuoi` (`cur_BaiDo`).
- **Kết quả:** bảng quét hạn vé (vé quá hạn → "Hết hạn" và khóa thẻ; vé ≤ 3 ngày được cảnh báo hoặc "Sẽ tự động gia hạn"); bảng tổng kết tài chính từng chi nhánh có đánh giá hiệu quả; đối chiếu khớp với `vw_Report_DoanhThuTheoBai`.
- **Bảng ảnh hưởng:** `VE_THANG`, `THE_XE`, `THONG_BAO` (ghi); đọc `BAI_DO_XE`, `LUOT_GUI`, `HOA_DON_VE_THANG`.
- **Lời dẫn:** "Cursor phù hợp khi mỗi dòng cần một quyết định khác nhau và ghi thông báo riêng; báo cáo thuần tổng hợp thì nhóm dùng view set-based."

### Nhóm E – Cổng khách hàng (9)

**E1. `kh-dang-ky-tai-khoan` – Khách tự tạo tài khoản**
- **Bài toán:** KH0005 (Võ Minh Quân) có vé V0005 nhưng chưa có tài khoản; tự đăng ký bằng SĐT 0977112244 + CCCD 079090005555.
- **Đối tượng:** `sp_KH_DangKyTaiKhoan`, `f_KH_MatKhauHopLe`, `f_BamMatKhau`.
- **Kết quả:** lần 1 tạo tài khoản + ví 0 ₫ + thông báo chào mừng trong một transaction; lần 2 bị chặn 50032; sau thao tác chỉ có đúng 1 tài khoản.
- **Bảng ảnh hưởng:** `TAI_KHOAN_KH`, `VI_DIEN_TU`, `THONG_BAO`.

**E2. `kh-dang-nhap-khoa-tai-khoan` – Khóa khi dò mật khẩu**
- **Bài toán:** kẻ gian dò mật khẩu tài khoản 0988776655 (KH0003).
- **Đối tượng:** `sp_KH_DangNhap`, `trg_NhatKyDangNhap_KhoaTaiKhoan`.
- **Kết quả:** 5 lần sai đều trả 50040; trigger khóa 15 phút và gửi thông báo bảo mật; lần thứ 6 dù **đúng** mật khẩu vẫn bị từ chối 50041.
- **Bảng ảnh hưởng:** `NHAT_KY_DANG_NHAP`, `TAI_KHOAN_KH`, `THONG_BAO`.
- **Lời dẫn:** "Sai tên và sai mật khẩu trả cùng một thông báo nên kẻ gian không dò được tài khoản nào tồn tại."

**E3. `kh-nap-tien-2-pha` – Nạp tiền 2 pha, callback lặp**
- **Bài toán:** KH0001 nạp 500.000 ₫ qua MoMo; MoMo gửi callback 2 lần.
- **Đối tượng:** `sp_KH_NapTien_KhoiTao`, `sp_KH_NapTien_XacNhan`, `trg_GiaoDich_CapNhatSoDu`.
- **Thực thi (5 bảng):** pha 1 tạo lệnh "Chờ xử lý"; số dư sau pha 1 không đổi; callback lần 1 → "Thành công", cộng tiền, ghi số dư trước / sau; callback lần 2 → "đã xử lý trước đó, không cộng tiền lần nữa"; số dư cuối = số dư đầu + 500.000.
- **Bảng ảnh hưởng:** `GIAO_DICH`, `VI_DIEN_TU`, `THONG_BAO`.
- **Lời dẫn:** "Cổng thanh toán thật thường gửi lại callback khi mạng chập chờn. Hệ thống nhận ra và không cộng tiền hai lần – đây là tính idempotent."

**E4. `kh-gia-han-bang-vi` – Tự gia hạn bằng ví**
- **Bài toán:** KH0002 gia hạn vé ô tô V0002 (bãi Lê Lai) thêm 1 tháng.
- **Đối tượng:** `sp_KH_GiaHanBangVi`, `f_KH_TinhPhiGiaHan` (1.800.000 ₫), `sp_GiaHanVe_Core`, `trg_GiaoDich_CapNhatSoDu`, `trg_HoaDon_ThongBaoKhachHang`.
- **Kết quả:** trong một transaction: giao dịch trừ ví, vé cộng 1 tháng, hóa đơn kênh "Online" gắn mã giao dịch, thông báo cho khách.
- **Bảng ảnh hưởng:** `GIAO_DICH`, `VI_DIEN_TU`, `VE_THANG`, `THE_XE`, `HOA_DON_VE_THANG`, `THONG_BAO`.

**E5. `trigger-chan-so-du-am` – Chặn số dư âm (2 lớp)**
- **Bài toán:** KH0004 (ví còn 50.000 ₫) gia hạn vé toàn chuỗi V0004 thêm 3 tháng = 3 × 1.500.000 = 4.500.000 ₫ (giá tại bãi phát hành thẻ BAI_Q3).
- **Đối tượng:** `sp_KH_GiaHanBangVi`, `trg_GiaoDich_CapNhatSoDu`, `CHECK (SoDu >= 0)`.
- **Kết quả:** lớp 1 – thủ tục từ chối, báo rõ cần bao nhiêu, có bao nhiêu, thiếu bao nhiêu (50031); lớp 2 – cố ghi thẳng giao dịch trừ tiền vào sổ cái để vượt thủ tục → trigger phát hiện số dư sẽ âm, ROLLBACK toàn bộ. Vé, số dư, số giao dịch đều không đổi.
- **Bảng ảnh hưởng:** không bảng nào thay đổi.

**E6. `rls-co-lap-du-lieu-khach-hang` – Row-Level Security**
- **Bài toán:** cùng một câu SELECT nhưng mỗi khách chỉ thấy dữ liệu của mình.
- **Đối tượng:** `r_KhachHang`, `u_WebKhachHang`, `bao_mat.rls_KhachHang`, `vw_KH_LichSuGiaoDich`, `f_KH_SaoKeVi`.
- **Thực thi (5 bảng, dùng `EXECUTE AS USER = 'u_WebKhachHang'` và `REVERT`):** góc nhìn KH0001; góc nhìn KH0002; vé của KH0002; truy cập thẳng bảng `GIAO_DICH` bị từ chối (lỗi 229 – lớp DENY); KH0002 xem sao kê ví KH0001 nhận 0 dòng (lớp RLS).
- **Dữ liệu trước / sau:** góc nhìn quản trị (`dbo`) thấy toàn bộ; danh sách role / user cổng khách hàng và security policy RLS.
- **Bảng ảnh hưởng:** chỉ đọc.

**E7. `kh-uy-quyen-ve` – Chia sẻ vé theo vai trò**
- **Bài toán:** chủ vé KH0004 chia sẻ V0004 cho KH0007 (0938135790) với vai trò THANH_VIEN.
- **Đối tượng:** `sp_KH_UyQuyenVe`, `f_KH_CoQuyen`, `trg_UyQuyen_KiemTra`, `sp_KH_GiaHanBangVi`.
- **Thực thi (7 bảng):** chia sẻ cho KH0007; KH0007 thấy vé được chia sẻ; KH0007 xem lịch sử đỗ của V0004; KH0007 thử gia hạn → 50050 (THANH_VIEN không có VE.GIAHAN); chia sẻ người thứ 2, thứ 3; người thứ 4 → 50053.
- **Bảng ảnh hưởng:** `UY_QUYEN_VE`, `THONG_BAO`.

**E8. `cursor-tu-dong-gia-han` – Tự động gia hạn (Cursor + Savepoint)**
- **Bài toán:** 3 vé bật tự gia hạn còn ≤ 3 ngày: V0007 (xe máy BAI_TB, 200.000 ₫, ví 300.000 ₫), V0011 (ô tô BAI_Q7, 1.700.000 ₫, ví 5.000.000 ₫), V0012 (ô tô BAI_BT, 2.200.000 ₫, ví 100.000 ₫).
- **Đối tượng:** `sp_DemoTuDongGiaHanVeThang` (`cur_TuDongGiaHan`, `SAVE TRANSACTION`).
- **Kết quả:** V0007 và V0011 gia hạn thành công, hóa đơn kênh "Tự động"; V0012 thiếu tiền chỉ hoàn tác phần của nó, khách nhận thông báo nạp thêm.
- **Bảng ảnh hưởng:** `VE_THANG`, `THE_XE`, `GIAO_DICH`, `VI_DIEN_TU`, `HOA_DON_VE_THANG`, `THONG_BAO`.
- **Lời dẫn:** "Một vé lỗi không làm hỏng cả mẻ chạy – đó là tác dụng của savepoint."

**E9. `trigger-so-cai-bat-bien` – Sổ cái bất biến và hoàn tiền**
- **Bài toán:** nhân viên gian lận cố sửa số tiền một giao dịch, xóa giao dịch, tự cộng số dư ví VI0004.
- **Đối tượng:** `trg_GiaoDich_BatBien`, `trg_GiaoDich_ChanXoa`, `trg_ViDienTu_ChanSuaTrucTiep`, `sp_NV_HoanTien`.
- **Thực thi (5 bảng):** sửa số tiền → 50061; xóa giao dịch → 50060; tự cộng số dư → 50062; hoàn khoản đã xuất hóa đơn → 50063; hoàn tiền hợp lệ khoản trừ nhầm → giao dịch "Hoàn tiền" đối ứng, giao dịch gốc "Đã hoàn", số dư tăng đúng.
- **Bảng ảnh hưởng:** `GIAO_DICH`, `VI_DIEN_TU`, `THONG_BAO`.
- **Lời dẫn:** "Giống sổ kế toán: không tẩy xóa, chỉ ghi bút toán đối ứng. Ngay cả quản trị viên cũng bị trigger chặn."

---

## B.7. Câu hỏi phản biện dự kiến và gợi ý trả lời

| Câu hỏi | Gợi ý trả lời |
|---|---|
| Vì sao đặt logic trong CSDL mà không ở backend? | Mọi đường ghi dữ liệu đều bị kiểm soát như nhau; tránh lặp quy tắc ở nhiều ứng dụng; transaction và khóa gần dữ liệu nhất. Python chỉ gọi thủ tục và đọc view. |
| Hai xe quẹt cùng lúc khi bãi còn 1 chỗ thì sao? | Trigger đếm trực tiếp lượt đang mở sau khi chèn, trong cùng transaction; `CHECK SoLuongHienTai <= SucChua` là chốt chặn cuối; lượt vượt sức chứa bị ROLLBACK với lỗi 50001. |
| Vì sao không dùng FOREIGN KEY cho `MaBaiApDung`? | Có giá trị đặc biệt `'ALL'` không tồn tại trong `BAI_DO_XE`; dùng trigger `trg_KiemTraLoaiXe_VeThang` để kiểm tra thay. |
| Thẻ được cấp lại thì lịch sử vé cũ có mất không? | Không. Vé cũ vẫn ở trạng thái "Hết hạn"; unique index có lọc chỉ cấm hai vé còn dùng; lượt gửi có cột `MaVe` nên lịch sử đỗ xe đúng theo vé. |
| Số dư ví có thể bị sửa tay không? | Không, kể cả `r_Admin`: `trg_ViDienTu_ChanSuaTrucTiep` chỉ cho phép đổi số dư từ bên trong trigger sổ cái (kiểm `TRIGGER_NESTLEVEL`). |
| Nếu cổng thanh toán gửi callback hai lần? | Lần hai thấy giao dịch đã xử lý với cùng mã tham chiếu nên trả kết quả cũ, không cộng tiền; khác mã tham chiếu bị từ chối 50039; `MaThamChieu` có unique index. |
| Khách có xem được dữ liệu của khách khác không? | Ba lớp: DENY bảng gốc, RLS lọc theo `SESSION_CONTEXT`, `f_KH_CoQuyen` trong thủ tục. Danh tính lấy từ `SESSION_CONTEXT` read-only, không nhận từ tham số. |
| Vì sao dùng cursor khi có thể viết set-based? | Mỗi vé cần quyết định riêng, thông báo riêng và transaction / savepoint riêng để vé lỗi không ảnh hưởng vé khác; báo cáo tổng hợp thuần thì nhóm dùng view set-based. |
| Băm mật khẩu như thế nào? | SHA2_512 trên salt ngẫu nhiên 16 byte ghép mật khẩu; salt lưu riêng từng tài khoản; đổi mật khẩu sinh salt mới. |
| Làm sao biết bộ đếm số xe không bị lệch? | View `v_SodoBai_TongQuanBai` có cờ `CanhBaoLechBoDem` so bộ đếm với số lượt đang mở; `v_SodoBai_ODoChiTiet` có cờ `CanhBaoLechDuLieu` cho từng ô. |
| Hoàn tiền có làm sai doanh thu không? | Chỉ hoàn khoản chưa gắn hóa đơn (trừ trùng / nhầm); khoản đã xuất hóa đơn bị từ chối 50063 để không lệch hạn vé và doanh thu. |
| Phân quyền bảo vệ khác quản lý thế nào? | Bảo vệ chỉ chạy thủ tục vào / ra / báo mất và xem view cổng, bị DENY sửa / xóa lượt gửi và hóa đơn; quản lý xem tài chính nhưng không đọc được hash mật khẩu, không sửa được sổ cái. |
| Khôi phục dữ liệu khi sự cố? | Full backup hằng tuần + Differential hằng ngày; khôi phục Full `NORECOVERY` rồi Diff `RECOVERY`. |
| Đã kiểm thử như thế nào? | Chạy full script trên SQL Server 2022 thật, các kịch bản có đối chiếu trước / sau, 40 ca smoke test cổng khách hàng, 20 ca cho N4/N5. |

---

## B.8. Quyết định thiết kế quan trọng

| # | Quyết định | Lý do |
|---|---|---|
| 1 | Đặt logic nghiệp vụ trong CSDL (procedure, trigger, constraint) | Mọi đường ghi dữ liệu (web, SSMS, công cụ khác) đều tuân thủ cùng quy tắc; đúng trọng tâm môn học |
| 2 | Khóa chính hỗn hợp `(MaLoaiXe, MaBai)` cho biểu phí | Mỗi chi nhánh có giá riêng cho cùng loại xe |
| 3 | `MaBaiApDung = 'ALL'` + trigger thay khóa ngoại | Hỗ trợ vé toàn chuỗi mà vẫn kiểm tra toàn vẹn |
| 4 | Trigger check-in đếm trực tiếp lượt đang mở, đặt chạy đầu tiên | Không phụ thuộc thứ tự trigger; lỗi luôn rõ ràng |
| 5 | Unique index có lọc + `f_VeHienHanhCuaThe` | Thẻ vật lý được cấp lại mà vẫn giữ lịch sử vé |
| 6 | Tách `TAI_KHOAN_KH` khỏi `TAI_KHOAN` nhân viên | Khác chính sách mật khẩu, khóa, phân quyền |
| 7 | Sổ cái `GIAO_DICH` chỉ ghi thêm, số dư chỉ đổi qua trigger | Kiểm toán được, không mất tiền khách, đối soát được |
| 8 | Nạp tiền 2 pha + unique `MaThamChieu` | Chịu được callback lặp từ cổng thanh toán |
| 9 | Sequence cho mã giao dịch | Ghi đồng thời nhiều; tránh MAX + 1 |
| 10 | Lõi gia hạn dùng chung 3 kênh | Một quy tắc giá cho mọi kênh; kiểm lệch giá 50046 |
| 11 | Transaction lồng an toàn bằng savepoint | Cursor xử lý nhiều vé, vé lỗi không phá cả mẻ |
| 12 | Danh tính khách lấy từ `SESSION_CONTEXT` read-only, không nhận `@MaTK` | Không giả mạo được khách khác |
| 13 | DENY từng bảng thay vì DENY schema | Giữ được ownership chaining cho procedure / view |
| 14 | Không dùng BLOCK predicate RLS | Khách đã bị DENY ghi; mọi ghi đi qua thủ tục có kiểm quyền |
| 15 | Hoàn tiền chỉ cho khoản chưa xuất hóa đơn | Khoản đã xuất hóa đơn đã cộng hạn vé và ghi doanh thu; hoàn sẽ làm lệch cả hai |
| 16 | Tắt ODBC pooling | Ngữ cảnh phiên không rò giữa các kết nối |
| 17 | Kiểm số dư trong thủ tục trước khi ghi sổ cái (cursor) | Lỗi từ thủ tục hoàn tác được về savepoint; lỗi từ trigger hủy cả transaction |

---

## B.9. Dàn ý slide thuyết trình kèm ghi chú người nói

| # | Tiêu đề | Nội dung trên slide | Ghi chú người nói |
|---|---|---|---|
| 1 | Hệ thống quản lý chuỗi nhiều bãi đỗ xe | Tên đề tài, môn IE103, giảng viên, nhóm | Chào hội đồng, giới thiệu tên đề tài trong một câu (PHẦN A, Chương 1) |
| 2 | Thành viên nhóm | Bảng họ tên – MSSV – phần việc | Mỗi thành viên nói 1 câu về phần mình phụ trách |
| 3 | Bối cảnh | Chuỗi 5 bãi tại TP.HCM; vấn đề của quản lý thủ công | Nêu 3 vấn đề lớn: ùn tắc cổng, thất thoát tiền, quên hạn vé |
| 4 | 8 bài toán thực tế | Lưới 8 ô | Mỗi bài toán gắn với một nhóm đối tượng CSDL |
| 5 | Mục tiêu và phạm vi | Logic trong CSDL; web chỉ để demo; 4 nhóm người dùng | Nhấn mạnh trọng tâm môn học là CSDL |
| 6 | Kiến trúc hệ thống | Sơ đồ 3 lớp | Python không tính tiền, không đổi trạng thái |
| 7 | Quy mô hệ thống | 21 bảng · 37 view · 27 procedure · 16 trigger · 12 function · 4 role · 21 kịch bản | Con số có thể xác minh ở trang `/setup` |
| 8 | ERD – vận hành bãi | 11 bảng, khóa hỗn hợp biểu phí | Giải thích vì sao biểu phí theo bãi |
| 9 | ERD – cổng khách hàng | 10 bảng: tài khoản, ví, sổ cái, vai trò × quyền | Ví và sổ cái tách riêng, số dư là kết quả của sổ cái |
| 10 | Quy tắc tính phí và vé tháng | Miễn phí 15 phút, block giờ, ví dụ 150.000 ₫; vé gắn bãi / `ALL` | Dùng ví dụ cụ thể |
| 11 | Luồng check-in | Thủ tục → hàm tìm ô → 4 trigger | Trigger kiểm tra đặt chạy đầu tiên |
| 12 | Transaction và lõi gia hạn | Đăng ký nhiều bước; 3 kênh dùng chung lõi; savepoint | ACID và tái sử dụng |
| 13 | Trigger an ninh | 50001–50004, 50014–50016 | Lỗi là kết quả mong đợi |
| 14 | Cursor | 4 cursor, ngưỡng 3 ngày, đánh giá doanh thu, savepoint | Khi nào dùng cursor, khi nào dùng view |
| 15 | View giám sát realtime | Bảng đèn XANH / VÀNG / ĐỎ, sơ đồ ô, cờ lệch dữ liệu | Màn hình chỉ SELECT view |
| 16 | Báo cáo BI | 16 view: doanh thu, công suất, xếp hạng, giờ cao điểm, ví | Phục vụ ra quyết định |
| 17 | Ví điện tử và sổ cái bất biến | Nạp 2 pha, idempotent, chặn sửa / xóa, hoàn tiền đối ứng | So sánh với sổ kế toán |
| 18 | Bảo mật nhiều lớp | RBAC 4 role, RLS 3 lớp, SHA2_512 + salt, khóa tài khoản | Không ai sửa được sổ cái, kể cả admin |
| 19 | Giới thiệu kịch bản demo | 21 kịch bản, 5 nhóm, quy trình 5 bước | Giải thích màn hình Trước / Sau |
| 20 | Demo: vòng đời lượt xe | A1, A2, B1–B3 | Theo lộ trình B.5 |
| 21 | Demo: vé tháng và cấp lại thẻ | A3, A4, A5, A6 | Nhấn mạnh filtered index |
| 22 | Demo: cổng khách hàng | E1, E3, E4, E5, E7, E8 | Bấm "Gửi lại callback" trực tiếp |
| 23 | Demo: bảo mật | A7, E2, E6, E9 | RLS: cùng câu SELECT, kết quả khác |
| 24 | Kết luận | Kết quả kiểm thử, hạn chế, hướng phát triển; cảm ơn và hỏi đáp | Chuẩn bị câu trả lời theo B.7 |

---

## B.10. Hướng dẫn cài đặt

1. Cài SQL Server 2022 (hoặc ≥ 2017), ODBC Driver 17/18 for SQL Server, Python 3.10+. Có thể chạy SQL Server trong container Docker (`mcr.microsoft.com/mssql/server:2022-latest`, cổng 1433); Mac Apple Silicon cần bật giả lập amd64.
2. Tạo môi trường Python: `python3 -m venv .venv`, kích hoạt, `pip install -r requirements.txt`.
3. Sao chép `.env.example` thành `.env`, khai báo:
   - `SQLSERVER_DRIVER`, `SQLSERVER_SERVER`, `SQLSERVER_DATABASE=QuanLyBaiDoXe`
   - `SQLSERVER_TRUSTED_CONNECTION` (yes: Windows Authentication; no: dùng `SQLSERVER_USERNAME`, `SQLSERVER_PASSWORD`)
   - `PORT=5001` (macOS: cổng 5000 thường bị AirPlay Receiver chiếm)
   - `ALLOW_RUN_FULL_SCRIPT=1`, `FLASK_SECRET_KEY`, `KH_DEMO_ACCOUNTS=1`
4. `python run.py`, mở `http://127.0.0.1:5001/setup`, bấm "Kiểm tra kết nối" rồi "Khởi tạo Full CSDL" (hoặc chạy `sql/QL_BaiDoXe_FullScript.sql` trong SSMS).
5. Tài khoản demo: khách – tên đăng nhập là SĐT (ví dụ 0903112233), mật khẩu `Khach@2026`; nhân viên – `admin` / `Admin@2026` (các tài khoản nhân viên khác dùng mật khẩu mẫu trong file Excel dữ liệu mẫu).

---

## B.11. Thuật ngữ

| Thuật ngữ | Giải thích |
|---|---|
| Check-in / Check-out | Xe quét thẻ vào / ra bãi |
| Ô đỗ (slot) | Vị trí đỗ vật lý, trạng thái Trống / Đã đỗ |
| Thẻ lượt / thẻ tháng | Thẻ cho khách vãng lai tính tiền theo giờ / thẻ gắn hợp đồng vé tháng |
| Vé `ALL` | Vé tháng toàn chuỗi, dùng được ở mọi bãi |
| Composite PK | Khóa chính gồm nhiều cột, ở đây `(MaLoaiXe, MaBai)` |
| Filtered index | Chỉ mục có điều kiện `WHERE`, chỉ áp lên một phần dòng |
| Transaction / ACID | Nhóm thao tác "tất cả hoặc không"; Atomicity, Consistency, Isolation, Durability |
| Savepoint | Điểm lưu trong transaction, cho phép hoàn tác một phần |
| Trigger AFTER / INSTEAD OF | Chạy sau câu lệnh / chạy thay câu lệnh |
| Cursor | Con trỏ duyệt từng dòng kết quả |
| Inline table-valued function | Hàm trả bảng viết bằng một câu SELECT |
| Window function | Hàm tính trên cửa sổ dòng, ví dụ `SUM() OVER (...)` để tính lũy kế |
| Idempotent | Gọi lặp nhiều lần cho cùng một kết quả |
| Callback | Cổng thanh toán gọi ngược lại hệ thống để báo kết quả giao dịch |
| Sổ cái (ledger) | Bảng giao dịch chỉ ghi thêm, không sửa / xóa |
| Giao dịch đối ứng | Giao dịch ngược chiều để điều chỉnh, thay vì sửa giao dịch cũ |
| RBAC | Phân quyền theo vai trò (role) |
| RLS | Row-Level Security – lọc dòng dữ liệu theo người dùng |
| Ownership chaining | Cơ chế SQL Server cho phép procedure / view truy cập bảng cùng chủ sở hữu mà không kiểm quyền trên bảng |
| `SESSION_CONTEXT` | Biến ngữ cảnh phiên kết nối SQL Server, ở đây giữ `MaTK`, `MaKH` của khách |
| Salt | Chuỗi ngẫu nhiên ghép vào mật khẩu trước khi băm để hash khác nhau |
| Rainbow table | Bảng tra hash dựng sẵn để dò mật khẩu |
| CSRF | Tấn công giả mạo yêu cầu từ trang khác; chống bằng token trong form |

---

# PHỤ LỤC

## PHỤ LỤC A. TỪ ĐIỂN DỮ LIỆU CHI TIẾT (TRÍCH TỰ ĐỘNG TỪ `sql/01_schema.sql`)

Mỗi bảng liệt kê đủ cột theo thứ tự khai báo, kiểu dữ liệu, cho phép NULL, giá trị mặc định và ràng buộc. Cột đánh dấu (V7) được thêm ở bản nâng cấp cổng khách hàng bằng `ALTER TABLE ... ADD`.


### A.1. Bảng `BAI_DO_XE`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaBai` | VARCHAR(10) | Không |  |  |
| `TenBai` | NVARCHAR(100) | Không |  |  |
| `DiaChi` | NVARCHAR(255) | Không |  |  |
| `SucChua` | INT | Không |  |  |
| `SoLuongHienTai` | INT | Không | 0 |  |

Ràng buộc:
- `CONSTRAINT PK_BAI_DO_XE PRIMARY KEY (MaBai)`
- `CONSTRAINT UQ_TenBai UNIQUE (TenBai)`
- `CONSTRAINT CK_SucChua CHECK (SucChua > 0)`
- `CONSTRAINT CK_SoLuongHienTai CHECK (SoLuongHienTai >= 0 AND SoLuongHienTai <= SucChua)`

### A.2. Bảng `NHAN_VIEN`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaNV` | VARCHAR(10) | Không |  |  |
| `HoTen` | NVARCHAR(100) | Không |  |  |
| `ChucVu` | NVARCHAR(50) | Không |  |  |
| `SDT` | VARCHAR(15) | Không |  |  |
| `Email` | VARCHAR(100) | Có |  |  |
| `MaBai` | VARCHAR(10) | Có |  |  |

Ràng buộc:
- `CONSTRAINT PK_NHAN_VIEN PRIMARY KEY (MaNV)`
- `CONSTRAINT UQ_NhanVien_SDT UNIQUE (SDT)`
- `CONSTRAINT FK_NhanVien_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)`
- `CONSTRAINT CK_NhanVien_ChucVu CHECK (ChucVu IN (N'Giám đốc điều hành', N'Quản lý bãi', N'Bảo vệ'))`

Chỉ mục:
- `UNIQUE INDEX UQ_NhanVien_Email (Email) WHERE Email IS NOT NULL`

### A.3. Bảng `TAI_KHOAN`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `TenDangNhap` | VARCHAR(50) | Không |  |  |
| `MatKhauHash` | VARBINARY(64) | Không |  | SHA2_512(salt + mật khẩu) qua dbo.f_BamMatKhau (N5) |
| `MatKhauSalt` | VARBINARY(16) | Không |  | salt ngẫu nhiên riêng từng tài khoản |
| `MaNV` | VARCHAR(10) | Không |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hoạt động' |  |

Ràng buộc:
- `CONSTRAINT PK_TAI_KHOAN PRIMARY KEY (TenDangNhap)`
- `CONSTRAINT FK_TaiKhoan_NhanVien FOREIGN KEY (MaNV) REFERENCES dbo.NHAN_VIEN(MaNV)`
- `CONSTRAINT CK_TaiKhoan_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Bị khóa'))`

### A.4. Bảng `LOAI_XE`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaLoaiXe` | VARCHAR(10) | Không |  |  |
| `MaBai` | VARCHAR(10) | Không |  |  |
| `TenLoai` | NVARCHAR(50) | Không |  |  |
| `DonGiaGio` | DECIMAL(18,2) | Không |  |  |
| `GiaVeThang` | DECIMAL(18,2) | Không |  |  |

Ràng buộc:
- `CONSTRAINT PK_LOAI_XE PRIMARY KEY (MaLoaiXe, MaBai)`
- `CONSTRAINT FK_LoaiXe_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai) ON DELETE CASCADE`
- `CONSTRAINT CK_DonGiaGio CHECK (DonGiaGio > 0)`
- `CONSTRAINT CK_GiaVeThang CHECK (GiaVeThang > 0)`

### A.5. Bảng `VI_TRI_DO`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaViTri` | VARCHAR(20) | Không |  |  |
| `KhuVuc` | NVARCHAR(20) | Không |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Trống' |  |
| `MaLoaiXe` | VARCHAR(10) | Không |  |  |
| `MaBai` | VARCHAR(10) | Không |  |  |

Ràng buộc:
- `CONSTRAINT PK_VI_TRI_DO PRIMARY KEY (MaViTri)`
- `CONSTRAINT FK_ViTriDo_LoaiXe FOREIGN KEY (MaLoaiXe, MaBai) REFERENCES dbo.LOAI_XE(MaLoaiXe, MaBai)`
- `CONSTRAINT FK_ViTriDo_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)`
- `CONSTRAINT CK_TrangThaiViTri CHECK (TrangThai IN (N'Trống', N'Đã đỗ'))`

### A.6. Bảng `THE_XE`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaThe` | VARCHAR(10) | Không |  |  |
| `MaBai` | VARCHAR(10) | Không |  |  |
| `LoaiThe` | NVARCHAR(10) | Không |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hoạt động' |  |
| `NgayCap` | DATE | Không | CAST(GETDATE() AS DATE) |  |

Ràng buộc:
- `CONSTRAINT PK_THE_XE PRIMARY KEY (MaThe)`
- `CONSTRAINT FK_TheXe_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)`
- `CONSTRAINT CK_LoaiThe CHECK (LoaiThe IN (N'Lượt', N'Tháng'))`
- `CONSTRAINT CK_TrangThaiThe CHECK (TrangThai IN (N'Hoạt động', N'Bị khóa', N'Mất'))`

### A.7. Bảng `KHACH_HANG`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaKH` | VARCHAR(10) | Không |  |  |
| `HoTen` | NVARCHAR(100) | Không |  |  |
| `SDT` | VARCHAR(15) | Không |  |  |
| `Email` | VARCHAR(100) | Có |  |  |
| `CMND_CCCD` | VARCHAR(12) | Không |  |  |
| `NgayTao` | DATETIME | Không | GETDATE() | (V7) |

Ràng buộc:
- `CONSTRAINT PK_KHACH_HANG PRIMARY KEY (MaKH)`
- `CONSTRAINT UQ_KhachHang_SDT UNIQUE (SDT)`
- `CONSTRAINT UQ_KhachHang_CMND UNIQUE (CMND_CCCD)`

Chỉ mục:
- `UNIQUE INDEX UQ_KhachHang_Email (Email) WHERE Email IS NOT NULL`

### A.8. Bảng `VE_THANG`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaVe` | VARCHAR(10) | Không |  |  |
| `MaThe` | VARCHAR(10) | Không |  |  |
| `MaKH` | VARCHAR(10) | Không |  |  |
| `BienSo` | VARCHAR(15) | Không |  |  |
| `MaLoaiXe` | VARCHAR(10) | Không |  |  |
| `NgayDangKy` | DATE | Không | CAST(GETDATE() AS DATE) |  |
| `NgayHetHan` | DATE | Không |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hoạt động' |  |
| `MaBaiApDung` | VARCHAR(10) | Không |  |  |
| `TuDongGiaHan` | BIT | Không | 0 | (V7) |
| `SoThangTuDongGiaHan` | TINYINT | Không | 1 | (V7) |

Ràng buộc:
- `CONSTRAINT PK_VE_THANG PRIMARY KEY (MaVe)`
- `CONSTRAINT FK_VeThang_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe)`
- `CONSTRAINT FK_VeThang_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH)`
- `CONSTRAINT CK_VeThang_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Hết hạn'))`
- `CONSTRAINT CK_VeThang_Han CHECK (NgayHetHan >= NgayDangKy)`
- `CONSTRAINT CK_VeThang_SoThangTuDongGiaHan CHECK (SoThangTuDongGiaHan BETWEEN 1 AND 12) (V7)`

Chỉ mục:
- `UNIQUE INDEX UX_VeThang_MaThe_ConDung (MaThe) WHERE TrangThai <> N'Hết hạn'`
- `INDEX IX_VeThang_TrangThai_NgayHetHan (TrangThai, NgayHetHan) INCLUDE (MaThe, MaKH, BienSo, MaBaiApDung)`

### A.9. Bảng `LUOT_GUI`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaLuot` | INT | Không |  | IDENTITY(1,1) |
| `MaThe` | VARCHAR(10) | Không |  |  |
| `BienSo` | VARCHAR(15) | Không |  |  |
| `ThoiGianVao` | DATETIME | Không | GETDATE() |  |
| `ThoiGianRa` | DATETIME | Có |  |  |
| `MaViTri` | VARCHAR(20) | Không |  |  |
| `TienGui` | DECIMAL(18,2) | Không | 0 |  |
| `MaBai` | VARCHAR(10) | Không |  |  |
| `MaVe` | VARCHAR(10) | Có |  | (V7) |

Ràng buộc:
- `CONSTRAINT PK_LUOT_GUI PRIMARY KEY (MaLuot)`
- `CONSTRAINT FK_LuotGui_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe)`
- `CONSTRAINT FK_LuotGui_ViTriDo FOREIGN KEY (MaViTri) REFERENCES dbo.VI_TRI_DO(MaViTri)`
- `CONSTRAINT FK_LuotGui_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)`
- `CONSTRAINT CK_LuotGui_TienGui CHECK (TienGui >= 0)`
- `CONSTRAINT CK_LuotGui_ThoiGianRa CHECK (ThoiGianRa IS NULL OR ThoiGianRa >= ThoiGianVao)`
- `CONSTRAINT FK_LuotGui_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe) (V7)`

Chỉ mục:
- `INDEX IX_LuotGui_DangDo (MaBai, MaViTri) INCLUDE (MaThe, BienSo, ThoiGianVao) WHERE ThoiGianRa IS NULL`
- `INDEX IX_LuotGui_MaVe_ThoiGianVao (MaVe, ThoiGianVao DESC) WHERE MaVe IS NOT NULL`

### A.10. Bảng `HOA_DON_VE_THANG`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaHD` | VARCHAR(15) | Không |  |  |
| `MaVe` | VARCHAR(10) | Không |  |  |
| `NgayThanhToan` | DATETIME | Không | GETDATE() |  |
| `SoThangGiaHan` | INT | Không | 1 |  |
| `SoTien` | DECIMAL(18,2) | Không |  |  |
| `MaBai` | VARCHAR(10) | Không |  |  |
| `MaPTTT` | VARCHAR(20) | Không | 'TIEN_MAT' | (V7) |
| `KenhThanhToan` | NVARCHAR(20) | Không | N'Tại quầy' | (V7) |
| `MaGD` | VARCHAR(16) | Có |  | (V7) |
| `MaNVThu` | VARCHAR(10) | Có |  | (V7) |

Ràng buộc:
- `CONSTRAINT PK_HOA_DON_VE_THANG PRIMARY KEY (MaHD)`
- `CONSTRAINT FK_HoaDon_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe)`
- `CONSTRAINT FK_HoaDon_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)`
- `CONSTRAINT CK_HoaDon_SoThang CHECK (SoThangGiaHan > 0)`
- `CONSTRAINT CK_HoaDon_SoTien CHECK (SoTien > 0)`
- `CONSTRAINT FK_HoaDon_PTTT FOREIGN KEY (MaPTTT) REFERENCES dbo.PHUONG_THUC_THANH_TOAN(MaPTTT) (V7)`
- `CONSTRAINT FK_HoaDon_GiaoDich FOREIGN KEY (MaGD) REFERENCES dbo.GIAO_DICH(MaGD) (V7)`
- `CONSTRAINT FK_HoaDon_NhanVienThu FOREIGN KEY (MaNVThu) REFERENCES dbo.NHAN_VIEN(MaNV) (V7)`
- `CONSTRAINT CK_HoaDon_KenhThanhToan CHECK (KenhThanhToan IN (N'Tại quầy', N'Online', N'Tự động')) (V7)`

Chỉ mục:
- `UNIQUE INDEX UX_HoaDon_MaGD (MaGD) WHERE MaGD IS NOT NULL`

### A.11. Bảng `LICHSU_SU_CO`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaSuCo` | INT | Không |  | IDENTITY(1,1) |
| `MaThe` | VARCHAR(10) | Có |  |  |
| `BienSo` | VARCHAR(15) | Có |  |  |
| `ThoiGianSuCo` | DATETIME | Không | GETDATE() |  |
| `MoTa` | NVARCHAR(500) | Không |  |  |
| `TienPhat` | DECIMAL(18,2) | Không | 0 |  |
| `TrangThaiXuLy` | NVARCHAR(50) | Không | N'Chờ xử lý' |  |
| `MaBai` | VARCHAR(10) | Không |  |  |

Ràng buộc:
- `CONSTRAINT PK_LICHSU_SU_CO PRIMARY KEY (MaSuCo)`
- `CONSTRAINT FK_SuCo_TheXe FOREIGN KEY (MaThe) REFERENCES dbo.THE_XE(MaThe)`
- `CONSTRAINT FK_SuCo_BaiDoXe FOREIGN KEY (MaBai) REFERENCES dbo.BAI_DO_XE(MaBai)`
- `CONSTRAINT CK_SuCo_TienPhat CHECK (TienPhat >= 0)`
- `CONSTRAINT CK_SuCo_TrangThai CHECK (TrangThaiXuLy IN (N'Chờ xử lý', N'Đang giải quyết', N'Đã giải quyết'))`

### A.12. Bảng `PHUONG_THUC_THANH_TOAN`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaPTTT` | VARCHAR(20) | Không |  |  |
| `TenPTTT` | NVARCHAR(100) | Không |  |  |
| `LoaiKenh` | NVARCHAR(30) | Không |  |  |
| `PhiPhanTram` | DECIMAL(5,2) | Không | 0 |  |
| `SoTienToiThieu` | DECIMAL(18,2) | Không | 10000 |  |
| `ChoPhepNapVi` | BIT | Không | 1 |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hoạt động' |  |

Ràng buộc:
- `CONSTRAINT PK_PHUONG_THUC_THANH_TOAN PRIMARY KEY (MaPTTT)`
- `CONSTRAINT UQ_PTTT_TenPTTT UNIQUE (TenPTTT)`
- `CONSTRAINT CK_PTTT_LoaiKenh CHECK (LoaiKenh IN (N'Tiền mặt', N'Ngân hàng', N'Ví điện tử', N'Thẻ', N'Số dư ví'))`
- `CONSTRAINT CK_PTTT_PhiPhanTram CHECK (PhiPhanTram BETWEEN 0 AND 10)`
- `CONSTRAINT CK_PTTT_SoTienToiThieu CHECK (SoTienToiThieu >= 0)`
- `CONSTRAINT CK_PTTT_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm ngưng'))`

### A.13. Bảng `TAI_KHOAN_KH`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaTK` | VARCHAR(12) | Không |  |  |
| `MaKH` | VARCHAR(10) | Không |  |  |
| `TenDangNhap` | VARCHAR(100) | Không |  |  |
| `MatKhauHash` | VARBINARY(64) | Không |  |  |
| `MatKhauSalt` | VARBINARY(16) | Không |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hoạt động' |  |
| `SoLanSaiLienTiep` | TINYINT | Không | 0 |  |
| `KhoaDen` | DATETIME | Có |  |  |
| `NgayTao` | DATETIME | Không | GETDATE() |  |
| `LanDangNhapCuoi` | DATETIME | Có |  |  |

Ràng buộc:
- `CONSTRAINT PK_TAI_KHOAN_KH PRIMARY KEY (MaTK)`
- `CONSTRAINT UQ_TKKH_MaKH UNIQUE (MaKH)`
- `CONSTRAINT UQ_TKKH_TenDangNhap UNIQUE (TenDangNhap)`
- `CONSTRAINT FK_TKKH_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH)`
- `CONSTRAINT CK_TKKH_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Tạm khóa', N'Đã đóng'))`
- `CONSTRAINT CK_TKKH_DinhDangMa CHECK (MaTK LIKE 'TK[0-9][0-9][0-9][0-9]%')`
- `CONSTRAINT CK_TKKH_DoDaiSalt CHECK (DATALENGTH(MatKhauSalt) = 16)`

### A.14. Bảng `NHAT_KY_DANG_NHAP`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaNK` | BIGINT | Không |  | IDENTITY(1,1) |
| `MaTK` | VARCHAR(12) | Có |  |  |
| `TenDangNhapNhap` | VARCHAR(100) | Không |  |  |
| `ThoiGian` | DATETIME | Không | GETDATE() |  |
| `KetQua` | NVARCHAR(20) | Không |  |  |
| `DiaChiIP` | VARCHAR(45) | Có |  |  |
| `ThietBi` | NVARCHAR(200) | Có |  |  |

Ràng buộc:
- `CONSTRAINT PK_NHAT_KY_DANG_NHAP PRIMARY KEY (MaNK)`
- `CONSTRAINT FK_NKDN_TaiKhoanKH FOREIGN KEY (MaTK) REFERENCES dbo.TAI_KHOAN_KH(MaTK)`
- `CONSTRAINT CK_NKDN_KetQua CHECK (KetQua IN (N'Thành công', N'Sai mật khẩu', N'Không tồn tại', N'Bị khóa'))`

Chỉ mục:
- `INDEX IX_NhatKy_MaTK_ThoiGian (MaTK, ThoiGian DESC) INCLUDE (KetQua)`

### A.15. Bảng `VI_DIEN_TU`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaVi` | VARCHAR(12) | Không |  |  |
| `MaKH` | VARCHAR(10) | Không |  |  |
| `SoDu` | DECIMAL(18,2) | Không | 0 |  |
| `HanMucNapNgay` | DECIMAL(18,2) | Không | 20000000 |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hoạt động' |  |
| `NgayTao` | DATETIME | Không | GETDATE() |  |
| `PhienBan` | ROWVERSION | Có |  |  |

Ràng buộc:
- `CONSTRAINT PK_VI_DIEN_TU PRIMARY KEY (MaVi)`
- `CONSTRAINT UQ_Vi_MaKH UNIQUE (MaKH)`
- `CONSTRAINT FK_Vi_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH)`
- `CONSTRAINT CK_Vi_SoDu CHECK (SoDu >= 0)`
- `CONSTRAINT CK_Vi_HanMucNapNgay CHECK (HanMucNapNgay > 0)`
- `CONSTRAINT CK_Vi_TrangThai CHECK (TrangThai IN (N'Hoạt động', N'Đóng băng'))`
- `CONSTRAINT CK_Vi_DinhDangMa CHECK (MaVi LIKE 'VI[0-9][0-9][0-9][0-9]%')`

### A.16. Bảng `GIAO_DICH`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaGD` | VARCHAR(16) | Không |  |  |
| `MaVi` | VARCHAR(12) | Không |  |  |
| `LoaiGD` | NVARCHAR(30) | Không |  |  |
| `HuongTien` | SMALLINT | Không |  |  |
| `SoTien` | DECIMAL(18,2) | Không |  |  |
| `PhiGiaoDich` | DECIMAL(18,2) | Không | 0 |  |
| `SoDuTruoc` | DECIMAL(18,2) | Có |  |  |
| `SoDuSau` | DECIMAL(18,2) | Có |  |  |
| `MaPTTT` | VARCHAR(20) | Không |  |  |
| `MaThamChieu` | VARCHAR(64) | Có |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Chờ xử lý' |  |
| `MaVe` | VARCHAR(10) | Có |  |  |
| `MaGDGoc` | VARCHAR(16) | Có |  |  |
| `NguoiThucHien` | NVARCHAR(20) | Không | N'Khách hàng' |  |
| `MaNV` | VARCHAR(10) | Có |  |  |
| `ThoiGianTao` | DATETIME | Không | GETDATE() |  |
| `ThoiGianHoanTat` | DATETIME | Có |  |  |
| `GhiChu` | NVARCHAR(255) | Có |  |  |

Ràng buộc:
- `CONSTRAINT PK_GIAO_DICH PRIMARY KEY (MaGD)`
- `CONSTRAINT FK_GD_ViDienTu FOREIGN KEY (MaVi) REFERENCES dbo.VI_DIEN_TU(MaVi)`
- `CONSTRAINT FK_GD_PTTT FOREIGN KEY (MaPTTT) REFERENCES dbo.PHUONG_THUC_THANH_TOAN(MaPTTT)`
- `CONSTRAINT FK_GD_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe)`
- `CONSTRAINT FK_GD_GiaoDichGoc FOREIGN KEY (MaGDGoc) REFERENCES dbo.GIAO_DICH(MaGD)`
- `CONSTRAINT FK_GD_NhanVien FOREIGN KEY (MaNV) REFERENCES dbo.NHAN_VIEN(MaNV)`
- `CONSTRAINT CK_GD_LoaiGD CHECK (LoaiGD IN (N'Nạp tiền', N'Thanh toán vé tháng', N'Hoàn tiền', N'Điều chỉnh'))`
- `CONSTRAINT CK_GD_HuongTien CHECK (HuongTien IN (1, -1))`
- `CONSTRAINT CK_GD_HuongTien_Loai CHECK ( (LoaiGD IN (N'Nạp tiền', N'Hoàn tiền') AND HuongTien = 1) OR (LoaiGD = N'Thanh toán vé tháng' AND HuongTien = -1) OR LoaiGD = N'Điều chỉnh')`
- `CONSTRAINT CK_GD_SoTien CHECK (SoTien > 0)`
- `CONSTRAINT CK_GD_PhiGiaoDich CHECK (PhiGiaoDich >= 0)`
- `CONSTRAINT CK_GD_TrangThai CHECK (TrangThai IN (N'Chờ xử lý', N'Thành công', N'Thất bại', N'Đã hoàn'))`
- `CONSTRAINT CK_GD_VeThang CHECK (LoaiGD <> N'Thanh toán vé tháng' OR MaVe IS NOT NULL)`
- `CONSTRAINT CK_GD_HoanTienCoGoc CHECK (LoaiGD <> N'Hoàn tiền' OR MaGDGoc IS NOT NULL)`
- `CONSTRAINT CK_GD_NguoiThucHien CHECK (NguoiThucHien IN (N'Khách hàng', N'Nhân viên', N'Hệ thống'))`

Chỉ mục:
- `UNIQUE INDEX UX_GiaoDich_MaThamChieu (MaThamChieu) WHERE MaThamChieu IS NOT NULL`
- `INDEX IX_GiaoDich_MaVi_ThoiGian (MaVi, ThoiGianTao DESC) INCLUDE (LoaiGD, SoTien, TrangThai)`

### A.17. Bảng `THONG_BAO`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaTB` | BIGINT | Không |  | IDENTITY(1,1) |
| `MaKH` | VARCHAR(10) | Không |  |  |
| `LoaiTB` | NVARCHAR(30) | Không |  |  |
| `TieuDe` | NVARCHAR(150) | Không |  |  |
| `NoiDung` | NVARCHAR(1000) | Không |  |  |
| `MaVe` | VARCHAR(10) | Có |  |  |
| `MaGD` | VARCHAR(16) | Có |  |  |
| `DaDoc` | BIT | Không | 0 |  |
| `ThoiGianTao` | DATETIME | Không | GETDATE() |  |

Ràng buộc:
- `CONSTRAINT PK_THONG_BAO PRIMARY KEY (MaTB)`
- `CONSTRAINT FK_TB_KhachHang FOREIGN KEY (MaKH) REFERENCES dbo.KHACH_HANG(MaKH)`
- `CONSTRAINT FK_TB_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe)`
- `CONSTRAINT FK_TB_GiaoDich FOREIGN KEY (MaGD) REFERENCES dbo.GIAO_DICH(MaGD)`
- `CONSTRAINT CK_TB_LoaiTB CHECK (LoaiTB IN (N'Giao dịch', N'Sắp hết hạn', N'Hết hạn', N'Bảo mật', N'Ủy quyền', N'Hệ thống'))`

Chỉ mục:
- `INDEX IX_ThongBao_MaKH_DaDoc (MaKH, DaDoc, ThoiGianTao DESC) `

### A.18. Bảng `QUYEN_KH`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaQuyen` | VARCHAR(30) | Không |  |  |
| `MoTa` | NVARCHAR(200) | Không |  |  |

Ràng buộc:
- `CONSTRAINT PK_QUYEN_KH PRIMARY KEY (MaQuyen)`

### A.19. Bảng `VAI_TRO_KH`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaVaiTro` | VARCHAR(20) | Không |  |  |
| `TenVaiTro` | NVARCHAR(100) | Không |  |  |
| `MoTa` | NVARCHAR(300) | Có |  |  |

Ràng buộc:
- `CONSTRAINT PK_VAI_TRO_KH PRIMARY KEY (MaVaiTro)`
- `CONSTRAINT UQ_VaiTroKH_Ten UNIQUE (TenVaiTro)`

### A.20. Bảng `VAI_TRO_QUYEN`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaVaiTro` | VARCHAR(20) | Không |  |  |
| `MaQuyen` | VARCHAR(30) | Không |  |  |

Ràng buộc:
- `CONSTRAINT PK_VAI_TRO_QUYEN PRIMARY KEY (MaVaiTro, MaQuyen)`
- `CONSTRAINT FK_VTQ_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES dbo.VAI_TRO_KH(MaVaiTro)`
- `CONSTRAINT FK_VTQ_Quyen FOREIGN KEY (MaQuyen) REFERENCES dbo.QUYEN_KH(MaQuyen)`

### A.21. Bảng `UY_QUYEN_VE`

| Cột | Kiểu | NULL | Mặc định | Ghi chú |
|---|---|---|---|---|
| `MaUyQuyen` | INT | Không |  | IDENTITY(1,1) |
| `MaVe` | VARCHAR(10) | Không |  |  |
| `MaTKDuocUyQuyen` | VARCHAR(12) | Không |  |  |
| `MaVaiTro` | VARCHAR(20) | Không |  |  |
| `NgayBatDau` | DATE | Không | CAST(GETDATE() AS DATE) |  |
| `NgayKetThuc` | DATE | Có |  |  |
| `TrangThai` | NVARCHAR(20) | Không | N'Hiệu lực' |  |
| `MaTKCap` | VARCHAR(12) | Không |  |  |
| `NgayTao` | DATETIME | Không | GETDATE() |  |

Ràng buộc:
- `CONSTRAINT PK_UY_QUYEN_VE PRIMARY KEY (MaUyQuyen)`
- `CONSTRAINT FK_UQ_VeThang FOREIGN KEY (MaVe) REFERENCES dbo.VE_THANG(MaVe)`
- `CONSTRAINT FK_UQ_TaiKhoanNhan FOREIGN KEY (MaTKDuocUyQuyen) REFERENCES dbo.TAI_KHOAN_KH(MaTK)`
- `CONSTRAINT FK_UQ_TaiKhoanCap FOREIGN KEY (MaTKCap) REFERENCES dbo.TAI_KHOAN_KH(MaTK)`
- `CONSTRAINT FK_UQ_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES dbo.VAI_TRO_KH(MaVaiTro)`
- `CONSTRAINT CK_UQ_KhongPhaiChuVe CHECK (MaVaiTro <> 'CHU_SO_HUU')`
- `CONSTRAINT CK_UQ_ThoiHan CHECK (NgayKetThuc IS NULL OR NgayKetThuc >= NgayBatDau)`
- `CONSTRAINT CK_UQ_TrangThai CHECK (TrangThai IN (N'Hiệu lực', N'Đã thu hồi'))`

Chỉ mục:
- `UNIQUE INDEX UX_UyQuyen_HieuLuc (MaVe, MaTKDuocUyQuyen) WHERE TrangThai = N'Hiệu lực'`


## PHỤ LỤC B. MÃ SQL CỦA 21 KỊCH BẢN DEMO (TRÍCH TỰ ĐỘNG TỪ `app/queries.py`)

Mỗi kịch bản gồm 3 khối SQL: **Trước** (đọc dữ liệu), **Thực thi** (thao tác chính, web chạy với COMMIT) và **Sau** (đọc lại để đối chiếu). Nhãn từng bảng kết quả được ghi kèm.


### B.1. Nhóm Stored Procedures (Thủ Tục Lưu Trữ)

Xử lý các quy trình nghiệp vụ gồm nhiều bước: Check-In, Check-Out tính phí, Đăng ký vé tháng trong Transaction, Gia hạn vé, Báo mất thẻ phạt đền bù, Cấp lại thẻ cho vé mới và Đăng nhập nhân viên với mật khẩu có salt.


#### `sp-xe-vao-bai` – Demo Stored Procedure: Check-In xe vào cổng bãi (sp_XeVaoBai)

**Bài toán:** Xe máy quét thẻ THE0003 vào bãi xe Lê Lai (BAI_Q1). Thủ tục tự động gọi Function f_TimSlotTrong tìm ô trống khả dụng, ghi nhận lượt gửi mới và kích hoạt Trigger chuyển trạng thái ô đỗ sang 'Đã đỗ' đồng thời tăng số lượng xe trong bãi.

**Trước** – các bảng kết quả:
1. Công suất bãi Quận 1 trước khi check-in: Số lượng xe hiện tại và sức chứa tối đa của bãi Lê Lai.
2. Sơ đồ ô đỗ bãi Quận 1 trước khi check-in: Trạng thái các ô đỗ 'Trống' và 'Đã đỗ'.
3. Lượt gửi gần nhất trước khi check-in: Nhật ký các lượt xe vào gần nhất.

```sql
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 10 MaViTri, KhuVuc, TrangThai, MaLoaiXe FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' ORDER BY TrangThai DESC, MaViTri ASC;
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, MaViTri FROM dbo.LUOT_GUI WHERE MaBai = 'BAI_Q1' ORDER BY MaLuot DESC;
```

**Thực thi** – các bảng kết quả:
1. Kết quả thực thi Stored Procedure: Mã lượt gửi và vị trí ô đỗ được tự động cấp phát cho xe.

```sql
DECLARE @MaViTri VARCHAR(20);
DECLARE @MaLuot INT;
EXEC dbo.sp_XeVaoBai 
    @MaThe = 'THE0003', 
    @BienSo = '59T1-888.88', 
    @MaBai = 'BAI_Q1',
    @MaLoaiXe = 'XM', 
    @MaViTri = @MaViTri OUTPUT, 
    @MaLuot = @MaLuot OUTPUT;
```

**Sau** – các bảng kết quả:
1. Công suất bãi Quận 1 sau khi check-in: Số lượng xe tăng thêm 1 do Trigger trg_DongBoTrangThaiSlot tự động cập nhật.
2. Sơ đồ ô đỗ bãi Quận 1 sau khi check-in: Ô đỗ vừa được cấp đã tự động chuyển sang trạng thái 'Đã đỗ'.
3. Lượt gửi mới được tạo thành công: Dòng bản ghi mới xuất hiện trong bảng LUOT_GUI.

```sql
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 10 MaViTri, KhuVuc, TrangThai, MaLoaiXe FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' ORDER BY TrangThai DESC, MaViTri ASC;
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, MaViTri FROM dbo.LUOT_GUI WHERE MaBai = 'BAI_Q1' ORDER BY MaLuot DESC;
```


#### `sp-xe-ra-bai` – Demo Stored Procedure: Check-Out xe ra cổng & Tính phí (sp_XeRaBai)

**Bài toán:** Xe đang đỗ quét thẻ ra cổng. Thủ tục đối chiếu thời gian vào, gọi Function f_TinhTienGuiXe tính tiền theo block giờ, cập nhật ThoiGianRa, kích hoạt Trigger giải phóng ô đỗ về 'Trống' và giảm số xe trong bãi.

**Trước** – các bảng kết quả:
1. Danh sách xe đang đỗ trong các bãi: Các lượt gửi chưa có ThoiGianRa.
2. Các ô đỗ đang có xe chiếm chỗ: Trạng thái 'Đã đỗ' của các slot.
3. Số lượng xe hiện tại các bãi: Số xe đang đỗ trước khi check-out.

```sql
SELECT TOP 5 lg.MaLuot, lg.MaThe, lg.BienSo, lg.ThoiGianVao, lg.MaViTri, lg.MaBai 
FROM dbo.LUOT_GUI lg 
WHERE lg.ThoiGianRa IS NULL 
ORDER BY lg.MaLuot DESC;
SELECT MaViTri, TrangThai, MaBai FROM dbo.VI_TRI_DO WHERE TrangThai = N'Đã đỗ';
SELECT MaBai, TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE;
```

**Thực thi** – các bảng kết quả:
1. Hóa đơn thanh toán khi Check-Out: Số tiền gửi xe thực thu tính toán tự động dựa trên thời gian đỗ và loại xe.

```sql
DECLARE @MaTheRa VARCHAR(10) = (SELECT TOP 1 MaThe FROM dbo.LUOT_GUI WHERE ThoiGianRa IS NULL ORDER BY MaLuot DESC);
DECLARE @TienThu DECIMAL(18,2);
DECLARE @MaLuot INT;
EXEC dbo.sp_XeRaBai 
    @MaThe = @MaTheRa, 
    @TienThu = @TienThu OUTPUT,
    @MaLuot = @MaLuot OUTPUT;
```

**Sau** – các bảng kết quả:
1. Lượt gửi vừa check-out: Đã cập nhật ThoiGianRa và TienGui.
2. Ô đỗ đã được giải phóng: Trigger trg_DongBoTrangThaiSlot tự động chuyển ô đỗ về 'Trống'.
3. Số lượng xe bãi đỗ sau khi check-out: Số xe giảm đi 1 tương ứng.

```sql
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, ThoiGianRa, TienGui, MaViTri, MaBai 
FROM dbo.LUOT_GUI 
ORDER BY ThoiGianRa DESC, MaLuot DESC;
SELECT MaViTri, TrangThai, MaBai FROM dbo.VI_TRI_DO WHERE TrangThai = N'Đã đỗ';
SELECT MaBai, TenBai, SoLuongHienTai FROM dbo.BAI_DO_XE;
```


#### `sp-dang-ky-thanh-vien` – Demo Stored Procedure + Transaction: Đăng ký vé tháng mới (sp_DangKyThanhVien)

**Bài toán:** Quy trình đăng ký vé tháng cho khách hàng mới: Tạo hồ sơ khách hàng -> Chuyển đổi thẻ chip sang Thẻ Tháng -> Sinh vé tháng mới -> Xuất hóa đơn tài chính. Toàn bộ chuỗi thao tác được bảo vệ trong TRANSACTION an toàn tuyệt đối.

**Trước** – các bảng kết quả:
1. Danh sách khách hàng trước đăng ký: Hồ sơ khách hàng hiện có.
2. Thẻ xe dự kiến đăng ký: Hiện là thẻ lượt THE0003.
3. Danh sách vé tháng gần nhất: Các vé tháng đã phát hành.
4. Hóa đơn thu tiền vé tháng: Lịch sử thu tiền trước thao tác.

```sql
SELECT TOP 5 MaKH, HoTen, SDT, CMND_CCCD FROM dbo.KHACH_HANG ORDER BY MaKH DESC;
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0003';
SELECT TOP 5 MaVe, MaThe, BienSo, NgayDangKy, NgayHetHan, TrangThai FROM dbo.VE_THANG ORDER BY MaVe DESC;
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG ORDER BY NgayThanhToan DESC;
```

**Thực thi** – các bảng kết quả:
1. Kết quả đăng ký thành viên và xuất hóa đơn: Thông tin hợp đồng vé tháng và số tiền đã thanh toán trong Transaction.

```sql
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
```

**Sau** – các bảng kết quả:
1. Khách hàng mới được tạo: Hồ sơ khách hàng Trần Đình Trọng.
2. Thẻ xe được chuyển sang Thẻ Tháng: Thẻ THE0003 đã đổi LoaiThe thành 'Tháng'.
3. Vé tháng mới có hiệu lực 3 tháng: Hạn sử dụng được cộng thêm 90 ngày.
4. Hóa đơn đóng tiền được lưu tự động: Ghi nhận doanh thu vé tháng trong HOA_DON_VE_THANG.

```sql
SELECT TOP 5 MaKH, HoTen, SDT, CMND_CCCD FROM dbo.KHACH_HANG ORDER BY MaKH DESC;
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0003';
SELECT TOP 5 MaVe, MaThe, BienSo, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung FROM dbo.VE_THANG ORDER BY MaVe DESC;
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG ORDER BY NgayThanhToan DESC;
```


#### `sp-gia-han-ve-thang` – Demo Stored Procedure: Gia hạn hạn dùng vé tháng (sp_GiaHanTheThang)

**Bài toán:** Khách hàng sở hữu vé tháng V0001 đến nộp tiền gia hạn thêm 2 tháng. Thủ tục tự động tính ngày hết hạn mới và xuất hóa đơn thu phí gia hạn.

**Trước** – các bảng kết quả:
1. Thông tin vé tháng V0001 trước khi gia hạn: Ngày hết hạn hiện tại của vé.
2. Lịch sử hóa đơn cũ của vé V0001: Các lần nộp tiền trước đó.

```sql
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0001';
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0001' ORDER BY NgayThanhToan DESC;
```

**Thực thi** – các bảng kết quả:
1. Kết quả gia hạn thành công: Thời hạn mới và số tiền gia hạn thu được.

```sql
EXEC dbo.sp_GiaHanTheThang 
    @MaVe = 'V0001', 
    @SoThangGiaHan = 2, 
    @MaBaiGiaHan = 'BAI_Q1';
```

**Sau** – các bảng kết quả:
1. Hạn sử dụng vé tháng sau gia hạn: NgayHetHan đã được cộng thêm 2 tháng.
2. Hóa đơn gia hạn mới được lập: Hóa đơn mới được thêm vào HOA_DON_VE_THANG.

```sql
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0001';
SELECT TOP 5 MaHD, MaVe, SoThangGiaHan, SoTien, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0001' ORDER BY NgayThanhToan DESC;
```


#### `sp-bao-mat-the` – Demo Procedure + Trigger: Báo mất thẻ & Phạt đền bù (sp_BaoMatThe)

**Bài toán:** Khách hàng báo mất thẻ THE0001 tại bãi Quận 1. Thủ tục cập nhật thẻ sang trạng thái 'Mất', Trigger trg_LogLichSuSuCo tự động can thiệp ghi nhận biên bản sự cố và áp tiền phạt 50,000 VND.

**Trước** – các bảng kết quả:
1. Trạng thái thẻ THE0001 trước khi báo mất: Đang ở trạng thái 'Hoạt động'.
2. Nhật ký sự cố trước thao tác: Các biên bản sự cố hiện có.

```sql
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0001';
SELECT TOP 5 MaSuCo, MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy FROM dbo.LICHSU_SU_CO ORDER BY MaSuCo DESC;
```

**Thực thi** – các bảng kết quả:
1. Kết quả xử lý báo mất thẻ: Thông báo thẻ đã bị khóa và áp mức phạt đền bù.

```sql
EXEC dbo.sp_BaoMatThe @MaTheBaoMat = 'THE0001';
```

**Sau** – các bảng kết quả:
1. Trạng thái thẻ sau khi báo mất: Đã đổi thành 'Mất' để chặn quét qua cổng barrier.
2. Biên bản sự cố tự động được Trigger tạo: Bản ghi mới kèm số tiền phạt 50.000 ₫ trong LICHSU_SU_CO.

```sql
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0001';
SELECT TOP 5 MaSuCo, MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy FROM dbo.LICHSU_SU_CO ORDER BY MaSuCo DESC;
```


#### `sp-cap-lai-the` – Demo Procedure + Filtered Index: Cấp lại thẻ xe cho vé tháng mới (sp_DangKyThanhVien, f_VeHienHanhCuaThe)

**Bài toán:** Vé V0008 của khách KH0008 đã hết hạn từ 15/07/2026, thẻ THE0022 được thu hồi và quầy Quận 7 cấp lại chính thẻ này cho khách mới. Unique index có lọc UX_VeThang_MaThe_ConDung chỉ cấm 2 vé CÒN DÙNG trên cùng một thẻ; hàm f_VeHienHanhCuaThe giúp trigger cổng và bốt cổng chỉ xét vé hiện hành nên vé cũ không chặn check-in. Thẻ đang gắn vé còn hạn bị từ chối (50065), vé cũ không gia hạn mở lại được (50066).

**Trước** – các bảng kết quả:
1. Thẻ THE0022 đang gắn vé đã hết hạn: V0008 hết hạn: thẻ không còn bị giữ bởi vé nào đang dùng.
2. Bốt cổng tra cứu thẻ THE0022: Quẹt thẻ lúc này sẽ bị trigger chặn vì vé hết hạn (50003).

```sql
SELECT MaVe, MaThe, MaKH, BienSo, NgayHetHan, TrangThai, MaBaiApDung FROM dbo.VE_THANG WHERE MaThe = 'THE0022';
SELECT MaThe, MaVe, HoTenKhachHang, TrangThaiVeThang, SoNgayConLaiVe, ChoPhepQuet, LyDoTuChoi FROM dbo.v_BotCong_TraCuuThe WHERE MaThe = 'THE0022';
```

**Thực thi** – các bảng kết quả:
1. Thẻ đang gắn vé còn hạn bị từ chối: sp_DangKyThanhVien báo lỗi 50065 thay vì lỗi trùng khóa thô.
2. Đăng ký vé mới với thẻ cấp lại: Vé mới, khách mới và hóa đơn được tạo trong một transaction.
3. Khách mới quẹt thẻ vào bãi: Check-in thành công: vé cũ hết hạn không còn chặn thẻ.
4. Vé cũ không mở lại được: Lõi gia hạn từ chối với lỗi 50066.

```sql
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
```

**Sau** – các bảng kết quả:
1. Thẻ THE0022 có 2 vé trong lịch sử: Vé cũ giữ trạng thái 'Hết hạn', vé mới 'Hoạt động'.
2. Lượt gửi ghi đúng vé mới: LUOT_GUI.MaVe là vé hiện hành của thẻ.
3. Bốt cổng chỉ hiện vé hiện hành: Một dòng duy nhất cho thẻ, đúng khách mới, đang trong bãi.

```sql
SELECT MaVe, MaThe, MaKH, BienSo, NgayDangKy, NgayHetHan, TrangThai, TuDongGiaHan FROM dbo.VE_THANG WHERE MaThe = 'THE0022' ORDER BY MaVe;
SELECT TOP 1 MaLuot, MaThe, MaVe, BienSo, ThoiGianVao, MaViTri, MaBai FROM dbo.LUOT_GUI WHERE MaThe = 'THE0022' ORDER BY MaLuot DESC;
SELECT MaThe, MaVe, HoTenKhachHang, TrangThaiVeThang, SoNgayConLaiVe, DangTrongBai, ChieuQuetKeTiep FROM dbo.v_BotCong_TraCuuThe WHERE MaThe = 'THE0022';
```


#### `sp-dang-nhap-nhan-vien` – Demo Procedure + Function: Đăng nhập nhân viên, mật khẩu SHA2_512 có salt (sp_DangNhap, f_BamMatKhau)

**Bài toán:** Mỗi tài khoản nhân viên có salt ngẫu nhiên 16 byte riêng (MatKhauSalt); hash = SHA2_512(salt + mật khẩu) qua f_BamMatKhau. Hai tài khoản cùng mật khẩu 123456 vẫn có hash khác nhau nên kẻ gian không thể tra bảng băm có sẵn. sp_DangNhap băm lại mật khẩu nhập với salt của tài khoản để đối chiếu: sai mật khẩu ném 50022, tài khoản bị khóa ném 50021.

**Trước** – các bảng kết quả:
1. Cùng mật khẩu 123456, khác salt và khác chuỗi băm: Chỉ hiện 16 byte đầu của chuỗi băm 64 byte; đối chiếu bằng f_BamMatKhau đều khớp.

```sql
SELECT TenDangNhap, MaNV, TrangThai,
       CONVERT(VARCHAR(34), MatKhauSalt, 1) AS GiaTriMuoi16Byte,
       CONVERT(VARCHAR(34), SUBSTRING(MatKhauHash, 1, 16), 1) AS DauChuoiBam16Byte,
       DATALENGTH(MatKhauHash) AS DoDaiChuoiBamByte,
       CASE WHEN dbo.f_BamMatKhau('123456', MatKhauSalt) = MatKhauHash THEN N'Khớp' ELSE N'Không khớp' END AS DoiChieu123456
FROM dbo.TAI_KHOAN
WHERE TenDangNhap IN ('quanly_q1', 'baove_q1', 'baove_khoa');
```

**Thực thi** – các bảng kết quả:
1. Đăng nhập thành công: Hồ sơ nhân viên và phạm vi bãi phụ trách.
2. Các lần đăng nhập bị từ chối: 50022: sai mật khẩu; 50021: tài khoản bị khóa.

```sql
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
```

**Sau** – các bảng kết quả:
1. Phân quyền trên bảng TAI_KHOAN: Quản lý bãi xem được tài khoản nhưng bị DENY 2 cột chuỗi băm và salt; bảo vệ và khách hàng bị DENY cả bảng.

```sql
SELECT r.name AS VaiTro, p.state_desc AS Quyen, p.permission_name AS LoaiQuyen,
       ISNULL(COL_NAME(p.major_id, p.minor_id), N'(cả bảng)') AS Cot
FROM sys.database_permissions p
INNER JOIN sys.database_principals r ON r.principal_id = p.grantee_principal_id
WHERE p.major_id = OBJECT_ID('dbo.TAI_KHOAN')
ORDER BY r.name, Cot;
```


### B.2. Nhóm Database Triggers (Bẫy Lỗi Tự Động)

Tự động kích hoạt khi có sự kiện ghi dữ liệu để bảo vệ toàn vẹn: Chặn check-in thẻ lỗi/báo mất hoặc bãi đầy, Chặn xe tháng hết hạn nộp tiền, Chặn vé tháng gửi sai bãi áp dụng.


#### `trigger-chan-checkin-loi` – Demo Trigger: Chặn Check-In khi thẻ lỗi hoặc bãi xe đầy (trg_KiemTraCheckIn)

**Bài toán:** Cố tình dùng thẻ THE0006 (thẻ đang có trạng thái 'Mất' hoặc 'Bị khóa') để check-in xe vào bãi. Trigger trg_KiemTraCheckIn sẽ phát hiện, ROLLBACK giao dịch và ném lỗi 50002. Lỗi này là KẾT QUẢ MONG ĐỢI của kịch bản demo.

**Trước** – các bảng kết quả:
1. Kiểm tra tình trạng thẻ THE0006: Thẻ đang ở trạng thái 'Mất'.
2. Tổng số lượt gửi trước khi chèn lỗi: Số lượng bản ghi trong LUOT_GUI.

```sql
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0006';
SELECT COUNT(*) AS TongSoLuotGuiHienTai FROM dbo.LUOT_GUI;
```

**Thực thi** – các bảng kết quả:
1. Kết quả: Lệnh INSERT bị Trigger chặn lại.

```sql
-- Cố tình vi phạm nghiệp vụ để kiểm chứng Trigger
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, MaViTri, TienGui, MaBai)
VALUES ('THE0006', '59X-888.88', GETDATE(), 'Q1_XM_01', 0, 'BAI_Q1');
```

**Sau** – các bảng kết quả:
1. Trạng thái thẻ vẫn được bảo vệ: Thẻ vẫn là 'Mất'.
2. Tổng số lượt gửi không thay đổi: Chứng minh giao dịch đã bị ROLLBACK hoàn toàn.

```sql
SELECT MaThe, LoaiThe, TrangThai, MaBai FROM dbo.THE_XE WHERE MaThe = 'THE0006';
SELECT COUNT(*) AS TongSoLuotGuiSauKhiChan FROM dbo.LUOT_GUI;
```


#### `trigger-chan-ve-het-han` – Demo Trigger: Chặn xe tháng quá hạn đóng tiền (trg_ChanSuDungVeHetHan)

**Bài toán:** Thẻ tháng THE0008 gắn với vé V0003 đã quá hạn thanh toán cố tình quét vào bãi. Trigger trg_ChanSuDungVeHetHan tự động can thiệp, hủy giao dịch và ném lỗi 50003.

**Trước** – các bảng kết quả:
1. Kiểm tra vé tháng V0003: Vé đã hết hạn sử dụng.

```sql
SELECT vt.MaVe, vt.MaThe, vt.NgayHetHan, vt.TrangThai, tx.LoaiThe 
FROM dbo.VE_THANG vt 
INNER JOIN dbo.THE_XE tx ON vt.MaThe = tx.MaThe 
WHERE vt.MaVe = 'V0003';
```

**Thực thi** – các bảng kết quả:
1. Kết quả: Lệnh INSERT bị Trigger chặn lại do vé quá hạn.

```sql
-- Cố tình check-in vé tháng đã hết hạn
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, MaViTri, TienGui, MaBai)
VALUES ('THE0008', '59B-456.78', GETDATE(), 'Q3_XM_01', 0, 'BAI_Q3');
```

**Sau** – các bảng kết quả:
1. Vé tháng vẫn ở trạng thái hết hạn: Thông tin vé tháng V0003.
2. Không có lượt gửi nào được tạo: Giao dịch không thành công.

```sql
SELECT vt.MaVe, vt.MaThe, vt.NgayHetHan, vt.TrangThai 
FROM dbo.VE_THANG vt 
WHERE vt.MaVe = 'V0003';
SELECT TOP 5 * FROM dbo.LUOT_GUI WHERE MaThe = 'THE0008' ORDER BY MaLuot DESC;
```


#### `trigger-chan-sai-bai` – Demo Trigger: Chặn vé tháng gửi sai bãi áp dụng (trg_KiemTraBaiApDungVeThang)

**Bài toán:** Ô tô vé tháng V0006 (thẻ THE0017) chỉ đăng ký gửi tại bãi TCP Park - Tân Sơn Nhất (BAI_TB) nhưng quét thẻ vào bãi Lê Lai (BAI_Q1). Trigger trg_KiemTraBaiApDungVeThang hủy giao dịch và ném lỗi 50004. Ngược lại, vé toàn chuỗi V0004 (MaBaiApDung = 'ALL') được gửi tại mọi bãi.

**Trước** – các bảng kết quả:
1. Phạm vi áp dụng của 2 vé tháng: V0006 gắn bãi BAI_TB; V0004 là vé toàn chuỗi 'ALL'.
2. Bãi Lê Lai trước khi quét thẻ: Số xe hiện tại của bãi BAI_Q1.

```sql
SELECT vt.MaVe, vt.MaThe, vt.BienSo, vt.MaLoaiXe, vt.NgayHetHan, vt.TrangThai, vt.MaBaiApDung,
       CASE WHEN vt.MaBaiApDung = 'ALL' THEN N'Gửi được mọi bãi' ELSE N'Chỉ gửi tại ' + b.TenBai END AS PhamViGui
FROM dbo.VE_THANG vt
LEFT JOIN dbo.BAI_DO_XE b ON vt.MaBaiApDung = b.MaBai
WHERE vt.MaVe IN ('V0006', 'V0004');
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
```

**Thực thi** – các bảng kết quả:
1. Kết quả: Lệnh check-in bị Trigger chặn lại do vé không áp dụng tại bãi này.

```sql
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
```

**Sau** – các bảng kết quả:
1. Bãi Lê Lai không tăng xe: Giao dịch bị rollback, bộ đếm giữ nguyên.
2. Không có lượt gửi mới tại BAI_Q1: Chỉ còn lịch sử gửi tại bãi BAI_TB của thẻ THE0017.

```sql
SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE WHERE MaBai = 'BAI_Q1';
SELECT TOP 5 MaLuot, MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, MaBai FROM dbo.LUOT_GUI WHERE MaThe = 'THE0017' ORDER BY MaLuot DESC;
```


### B.3. Nhóm Database Functions (Hàm Nghiệp Vụ)

Hàm tính toán và trích xuất dữ liệu: Tính phí gửi theo block giờ lũy tiến, Tìm ô đỗ trống đầu tiên phù hợp loại xe, Bảng danh sách xe đang trong bãi.


#### `function-tinh-tien-slot` – Demo Database Functions: Tính phí gửi xe & Tìm ô đỗ tự động

**Bài toán:** Demo các hàm nghiệp vụ: f_TinhTienGuiXe (tính phí đỗ theo số giờ lũy tiến), f_TimSlotTrong (tìm vị trí trống đầu tiên phù hợp loại xe) và f_DanhSachXeTrongBai (trích xuất danh sách xe đang trong bãi).

**Trước** – các bảng kết quả:
1. Biểu phí đơn giá giờ của từng bãi: Bảng giá áp dụng cho hàm tính tiền.
2. Danh sách ô đỗ trống hiện có tại bãi Lê Lai: Dữ liệu phục vụ hàm tìm slot.

```sql
SELECT MaLoaiXe, MaBai, TenLoai, DonGiaGio FROM dbo.LOAI_XE;
SELECT MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai FROM dbo.VI_TRI_DO WHERE MaBai = 'BAI_Q1' AND TrangThai = N'Trống';
```

**Thực thi** – các bảng kết quả:
1. Hàm tính tiền gửi ô tô 5 giờ tại Landmark 81: 5 giờ * 30.000 ₫/giờ = 150.000 ₫.
2. Hàm tìm ô đỗ xe máy trống bãi Q1: Trả về mã slot trống đầu tiên.
3. Hàm tìm ô đỗ ô tô trống bãi Q3: Trả về mã slot ô tô trống.
4. Hàm bảng: Danh sách xe đang đỗ tại bãi Q1: Danh sách xe hiện diện tức thời.

```sql
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
```

**Sau** – các bảng kết quả:
1. Báo cáo công suất toàn bộ hệ thống bãi xe: Số lượng xe và chỗ trống đối chiếu.

```sql
SELECT * FROM dbo.vw_Report_CongSuatBaiDo;
```


### B.4. Nhóm Database Cursors (Con Trỏ Duyệt Dữ Liệu)

Duyệt tuần tự từng dòng bản ghi chuyên sâu: Quét kiểm tra hạn vé tháng tự động khóa thẻ quá hạn và Tổng kết báo cáo doanh thu toàn chuỗi.


#### `cursor-canh-bao-doanh-thu` – Demo Database Cursors: Quét cảnh báo vé tháng & Thống kê tài chính toàn chuỗi

**Bài toán:** Demo 2 Cursor duyệt dữ liệu chuyên sâu: sp_DemoCanhBaoHanTheThang (duyệt kiểm tra toàn bộ vé tháng, khóa thẻ quá hạn và nhắc nộp phí) và sp_DemoTongKetDoanhThuChuoi (duyệt cộng gộp doanh thu lượt và vé tháng của từng chi nhánh).

**Trước** – các bảng kết quả:
1. Danh sách vé tháng trước khi chạy Cursor quét hạn: Trạng thái các vé tháng hiện tại.
2. Danh mục các chi nhánh bãi xe: Các bãi đỗ thuộc chuỗi hệ thống.

```sql
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG;
SELECT MaBai, TenBai FROM dbo.BAI_DO_XE;
```

**Thực thi** – các bảng kết quả:
1. Kết quả Cursor 1: Báo cáo quét hạn vé tháng: Phân loại: Đã quá hạn (tự khóa), Sắp hết hạn (nhắc nộp phí), Còn hạn an toàn.
2. Kết quả Cursor 2: Bảng tổng kết tài chính chuỗi bãi đỗ: Cộng gộp doanh thu lượt + doanh thu tháng và đánh giá hiệu quả từng bãi.

```sql
-- 1. Chạy Cursor quét hạn vé tháng và tự động xử lý
EXEC dbo.sp_DemoCanhBaoHanTheThang;

-- 2. Chạy Cursor tổng hợp doanh thu chuỗi
EXEC dbo.sp_DemoTongKetDoanhThuChuoi;
```

**Sau** – các bảng kết quả:
1. Trạng thái vé tháng sau khi Cursor xử lý: Các vé quá hạn đã được cập nhật thành 'Hết hạn'.
2. Đối chiếu bảng doanh thu từ View báo cáo: Số liệu khớp hoàn toàn với kết quả Cursor.

```sql
SELECT MaVe, MaThe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG;
SELECT * FROM dbo.vw_Report_DoanhThuTheoBai;
```


### B.5. Nhóm Cổng Khách Hàng (Tài Khoản, Ví, Phân Quyền)

Tài khoản khách hàng, ví trả trước, sổ cái bất biến, nạp tiền 2 pha, tự gia hạn, tự động gia hạn bằng cursor, Row-Level Security và chia sẻ vé theo vai trò.


#### `kh-dang-ky-tai-khoan` – Demo Procedure + Transaction: Khách hàng tự đăng ký tài khoản (sp_KH_DangKyTaiKhoan)

**Bài toán:** Khách KH0005 (Võ Minh Quân) đã có vé V0005 tại quầy nhưng chưa có tài khoản online. Khách tự đăng ký bằng SĐT 0977112244 + CCCD 079090005555. Thủ tục xác minh hồ sơ, băm mật khẩu SHA2_512 với salt ngẫu nhiên, tạo tài khoản + ví số dư 0 + thông báo chào mừng trong một transaction. Đăng ký lần 2 bị chặn (50032) và không tạo dữ liệu dư.

**Trước** – các bảng kết quả:
1. Hồ sơ khách hàng KH0005: Khách đã có hồ sơ tại quầy (điều kiện để tự đăng ký - D8).
2. Tài khoản cổng khách hàng của KH0005: Chưa có tài khoản.
3. Ví điện tử của KH0005: Chưa có ví.

```sql
SELECT MaKH, HoTen, SDT, CMND_CCCD FROM dbo.KHACH_HANG WHERE MaKH = 'KH0005';
SELECT MaTK, MaKH, TenDangNhap, TrangThai FROM dbo.TAI_KHOAN_KH WHERE MaKH = 'KH0005';
SELECT MaVi, MaKH, SoDu, TrangThai FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0005';
```

**Thực thi** – các bảng kết quả:
1. Lần 1: tạo tài khoản thành công: Mã tài khoản TK#### và ví VI#### được sinh tự động.
2. Lần 2: bị chặn đúng như mong đợi: Lỗi 50032 - khách đã có tài khoản.

```sql
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
```

**Sau** – các bảng kết quả:
1. Tài khoản vừa tạo (1 dòng duy nhất): Hash và salt là dữ liệu nhị phân, giao diện tự che giá trị.
2. Ví điện tử số dư 0: Trigger trg_ViDienTu_ChanSuaTrucTiep chỉ cho tạo ví với số dư 0.
3. Thông báo chào mừng: Ghi trong cùng transaction với tài khoản.

```sql
SELECT MaTK, MaKH, TenDangNhap, MatKhauHash, MatKhauSalt, TrangThai, NgayTao FROM dbo.TAI_KHOAN_KH WHERE MaKH = 'KH0005';
SELECT MaVi, MaKH, SoDu, TrangThai FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0005';
SELECT TOP 3 LoaiTB, TieuDe, NoiDung, DaDoc, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0005' ORDER BY MaTB DESC;
```


#### `kh-dang-nhap-khoa-tai-khoan` – Demo Trigger: Khóa tài khoản khi đăng nhập sai 5 lần (trg_NhatKyDangNhap_KhoaTaiKhoan)

**Bài toán:** Kẻ gian dò mật khẩu tài khoản 0988776655 (KH0003) 5 lần liên tiếp. Mỗi lần sai, sp_KH_DangNhap ghi nhật ký; khi đủ 5 lần trong 15 phút, trigger tự khóa tài khoản 15 phút và gửi thông báo bảo mật. Lần thử thứ 6 dù đúng mật khẩu vẫn bị từ chối (50041). Sai tên đăng nhập và sai mật khẩu luôn trả cùng một thông báo (50040) để chống dò tài khoản.

**Trước** – các bảng kết quả:
1. Tài khoản TK0003 trước khi bị dò mật khẩu: Đang hoạt động, chưa sai lần nào.
2. Nhật ký đăng nhập gần nhất: Lịch sử đăng nhập của tài khoản.

```sql
SELECT MaTK, TenDangNhap, TrangThai, SoLanSaiLienTiep, KhoaDen, LanDangNhapCuoi FROM dbo.TAI_KHOAN_KH WHERE MaTK = 'TK0003';
SELECT TOP 5 MaNK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP FROM dbo.NHAT_KY_DANG_NHAP WHERE MaTK = 'TK0003' ORDER BY MaNK DESC;
```

**Thực thi** – các bảng kết quả:
1. Kết quả 6 lần đăng nhập: Lần 1-5: 50040 (thông báo trung tính). Lần 6: 50041 - tài khoản đã bị khóa.

```sql
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
```

**Sau** – các bảng kết quả:
1. Tài khoản bị trigger khóa tạm 15 phút: TrangThai = 'Tạm khóa', KhoaDen = thời điểm mở khóa tự động.
2. Nhật ký đăng nhập: 5 dòng 'Sai mật khẩu' và 1 dòng 'Bị khóa'.
3. Thông báo bảo mật gửi cho khách: Trigger tạo thông báo ngay khi khóa tài khoản.

```sql
SELECT MaTK, TenDangNhap, TrangThai, SoLanSaiLienTiep, KhoaDen FROM dbo.TAI_KHOAN_KH WHERE MaTK = 'TK0003';
SELECT TOP 7 MaNK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP, ThietBi FROM dbo.NHAT_KY_DANG_NHAP WHERE MaTK = 'TK0003' ORDER BY MaNK DESC;
SELECT TOP 2 LoaiTB, TieuDe, NoiDung, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0003' AND LoaiTB = N'Bảo mật' ORDER BY MaTB DESC;
```


#### `kh-nap-tien-2-pha` – Demo Procedure + Trigger: Nạp tiền 2 pha và callback lặp không cộng tiền 2 lần

**Bài toán:** KH0001 nạp 500.000 ₫ qua MoMo. Pha 1 (sp_KH_NapTien_KhoiTao) tạo giao dịch 'Chờ xử lý', số dư chưa đổi. Pha 2 MoMo gọi callback (sp_KH_NapTien_XacNhan): giao dịch chuyển 'Thành công', trigger trg_GiaoDich_CapNhatSoDu cộng tiền và ghi số dư trước/sau. MoMo gửi lại callback lần 2: thủ tục nhận ra giao dịch đã xử lý (idempotent) nên số dư không tăng thêm.

**Trước** – các bảng kết quả:
1. Ví của KH0001 trước khi nạp: Số dư hiện tại.
2. Sổ cái ví VI0001: Các giao dịch gần nhất.

```sql
SELECT MaVi, MaKH, SoDu, TrangThai FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0001';
SELECT TOP 5 MaGD, LoaiGD, SoTien, MaPTTT, TrangThai, SoDuTruoc, SoDuSau, ThoiGianTao FROM dbo.GIAO_DICH WHERE MaVi = 'VI0001' ORDER BY ThoiGianTao DESC;
```

**Thực thi** – các bảng kết quả:
1. Pha 1: lệnh nạp 'Chờ xử lý': Phí cổng MoMo 1,5% do công ty chịu.
2. Số dư sau pha 1: Chưa thay đổi vì cổng thanh toán chưa xác nhận.
3. Pha 2: callback lần 1: Trigger cộng tiền, ghi SoDuTruoc / SoDuSau.
4. Callback lần 2 (lặp): Thủ tục bỏ qua, không cộng tiền lần nữa.
5. Số dư cuối cùng: Chỉ tăng đúng 500.000 ₫.

```sql
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
```

**Sau** – các bảng kết quả:
1. Ví sau khi nạp: Số dư tăng đúng 1 lần.
2. Sổ cái sau khi nạp: Giao dịch mới ở trạng thái 'Thành công', có mã tham chiếu MoMo.
3. Thông báo nạp tiền: Gửi một lần duy nhất.

```sql
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0001';
SELECT TOP 5 MaGD, LoaiGD, SoTien, PhiGiaoDich, MaPTTT, MaThamChieu, TrangThai, SoDuTruoc, SoDuSau FROM dbo.GIAO_DICH WHERE MaVi = 'VI0001' ORDER BY ThoiGianTao DESC;
SELECT TOP 2 LoaiTB, TieuDe, NoiDung, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0001' ORDER BY MaTB DESC;
```


#### `kh-gia-han-bang-vi` – Demo Procedure + Function: Khách tự gia hạn vé bằng số dư ví (sp_KH_GiaHanBangVi)

**Bài toán:** KH0002 tự gia hạn vé ô tô V0002 (gắn bãi Lê Lai) thêm 1 tháng. f_KH_TinhPhiGiaHan tính giá theo đúng quy tắc tại quầy (1.800.000 ₫). Trong một transaction: ghi giao dịch trừ ví (trigger cập nhật số dư), gọi lõi sp_GiaHanVe_Core gia hạn vé và xuất hóa đơn kênh Online gắn mã giao dịch; trigger hóa đơn gửi thông báo cho khách.

**Trước** – các bảng kết quả:
1. Vé tháng V0002 trước khi gia hạn: Hạn dùng hiện tại.
2. Ví của KH0002: Số dư trước khi trừ.
3. Giá gia hạn 1 tháng (function): Giá ô tô tại bãi áp dụng BAI_Q1.
4. Hóa đơn của vé V0002: Lịch sử thanh toán.

```sql
SELECT MaVe, MaKH, BienSo, MaLoaiXe, MaBaiApDung, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0002';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0002';
SELECT dbo.f_KH_TinhPhiGiaHan('V0002', 1) AS PhiGiaHan1Thang;
SELECT TOP 3 MaHD, SoThangGiaHan, SoTien, MaPTTT, KenhThanhToan, MaGD, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0002' ORDER BY NgayThanhToan DESC;
```

**Thực thi** – các bảng kết quả:
1. Kết quả gia hạn online: Mã giao dịch, mã hóa đơn, số dư trước / sau và hạn mới.

```sql
EXEC sys.sp_set_session_context @key = N'MaTK', @value = 'TK0002';
EXEC sys.sp_set_session_context @key = N'MaKH', @value = 'KH0002';

EXEC dbo.sp_KH_GiaHanBangVi @MaVe = 'V0002', @SoThang = 1;
```

**Sau** – các bảng kết quả:
1. Vé V0002 sau khi gia hạn: Hạn dùng cộng thêm 1 tháng.
2. Ví sau khi trừ tiền: Giảm đúng giá do function tính.
3. Hóa đơn mới kênh Online: MaPTTT = SO_DU_VI, gắn mã giao dịch ví.
4. Thông báo do trigger hóa đơn tạo: trg_HoaDon_ThongBaoKhachHang.

```sql
SELECT MaVe, BienSo, NgayHetHan, TrangThai FROM dbo.VE_THANG WHERE MaVe = 'V0002';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0002';
SELECT TOP 3 MaHD, SoThangGiaHan, SoTien, MaPTTT, KenhThanhToan, MaGD, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE MaVe = 'V0002' ORDER BY NgayThanhToan DESC;
SELECT TOP 2 LoaiTB, TieuDe, NoiDung, ThoiGianTao FROM dbo.THONG_BAO WHERE MaKH = 'KH0002' ORDER BY MaTB DESC;
```


#### `trigger-chan-so-du-am` – Demo Trigger + Constraint: Chặn số dư ví âm (trg_GiaoDich_CapNhatSoDu)

**Bài toán:** KH0004 (ví chỉ còn 50.000 ₫) cố gia hạn vé ô tô toàn chuỗi V0004 thêm 3 tháng (3 × 1.500.000 ₫, giá tại bãi phát hành thẻ BAI_Q3). Lớp 1: thủ tục kiểm tra trước và báo rõ số tiền thiếu (50031). Lớp 2: cố ghi thẳng giao dịch trừ tiền vào sổ cái để vượt thủ tục -> trigger sổ cái phát hiện số dư sẽ âm, ROLLBACK toàn bộ. Đối chiếu trước / sau: không thay đổi gì.

**Trước** – các bảng kết quả:
1. Vé V0004 (toàn chuỗi): Hạn dùng trước khi thử gia hạn.
2. Ví của KH0004: Số dư không đủ.
3. Giá gia hạn 3 tháng: Tính theo bãi phát hành thẻ (D12).
4. Số giao dịch trong sổ cái: Dùng để đối chiếu sau khi chạy.

```sql
SELECT MaVe, MaKH, MaLoaiXe, MaBaiApDung, NgayHetHan FROM dbo.VE_THANG WHERE MaVe = 'V0004';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0004';
SELECT dbo.f_KH_TinhPhiGiaHan('V0004', 3) AS PhiGiaHan3Thang;
SELECT COUNT(*) AS SoGiaoDich FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004';
```

**Thực thi** – các bảng kết quả:
1. Lớp 1: thủ tục từ chối: Lỗi 50031 kèm số tiền thiếu.

```sql
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
```

**Sau** – các bảng kết quả:
1. Vé V0004 không đổi hạn: Giao dịch bị hủy hoàn toàn.
2. Số dư không đổi: CHECK SoDu >= 0 và trigger sổ cái bảo vệ.
3. Sổ cái không có giao dịch mới: Toàn vẹn ACID.

```sql
SELECT MaVe, MaKH, MaLoaiXe, MaBaiApDung, NgayHetHan FROM dbo.VE_THANG WHERE MaVe = 'V0004';
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaKH = 'KH0004';
SELECT COUNT(*) AS SoGiaoDich FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004';
```


#### `rls-co-lap-du-lieu-khach-hang` – Demo Security: Row-Level Security cô lập dữ liệu từng khách hàng (r_KhachHang + RLS)

**Bài toán:** Cổng khách hàng kết nối CSDL bằng user u_WebKhachHang (role r_KhachHang). Cùng một câu SELECT trên vw_KH_LichSuGiaoDich trả về dữ liệu khác nhau tùy khách trong SESSION_CONTEXT. Truy cập thẳng bảng GIAO_DICH bị từ chối quyền (lớp 1 - DENY). KH0002 thử xem sao kê ví của KH0001 nhận về 0 dòng (lớp 2 - RLS). Nhân viên / quản trị (dbo) vẫn thấy toàn bộ dữ liệu.

**Trước** – các bảng kết quả:
1. Góc nhìn quản trị (dbo): Thấy ví và giao dịch của mọi khách hàng.

```sql
SELECT vi.MaKH, kh.HoTen, COUNT(g.MaGD) AS SoGiaoDich, vi.SoDu
FROM dbo.VI_DIEN_TU vi
INNER JOIN dbo.KHACH_HANG kh ON vi.MaKH = kh.MaKH
LEFT JOIN dbo.GIAO_DICH g ON g.MaVi = vi.MaVi
GROUP BY vi.MaKH, kh.HoTen, vi.SoDu
ORDER BY vi.MaKH;
```

**Thực thi** – các bảng kết quả:
1. Góc nhìn KH0001: Chỉ giao dịch ví của KH0001.
2. Góc nhìn KH0002: Cùng câu lệnh, chỉ giao dịch ví của KH0002.
3. Vé của KH0002: Vé chính chủ V0002 + vé V0001 được KH0001 chia sẻ (XEM_LICH_SU).
4. Lớp 1: truy cập bảng gốc bị từ chối: Lỗi 229 - DENY SELECT trên GIAO_DICH.
5. Lớp 2: sao kê ví người khác rỗng: Hàm và RLS chỉ trả ví của khách trong phiên.

```sql
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
```

**Sau** – các bảng kết quả:
1. Role và user cổng khách hàng: Lớp 1 của mô hình phân quyền.
2. Security policy RLS: Lớp 2: 7 filter predicate trên các bảng có dữ liệu khách hàng.

```sql
SELECT name AS DoiTuong, type_desc AS Loai FROM sys.database_principals WHERE name IN ('r_KhachHang', 'u_WebKhachHang');
SELECT p.name AS SecurityPolicy, p.is_enabled AS DangBat, COUNT(*) AS SoPredicate
FROM sys.security_policies p
INNER JOIN sys.security_predicates sp ON sp.object_id = p.object_id
GROUP BY p.name, p.is_enabled;
```


#### `kh-uy-quyen-ve` – Demo Function + Trigger: Chia sẻ vé cho người nhà với quyền hạn chế (f_KH_CoQuyen)

**Bài toán:** Chủ vé KH0004 chia sẻ vé V0004 cho KH0007 (0938135790) với vai trò THANH_VIEN. KH0007 thấy V0004 và lịch sử đỗ xe nhưng gọi gia hạn thì f_KH_CoQuyen từ chối (50050 - THANH_VIEN không có quyền VE.GIAHAN). Chủ vé chia sẻ thêm 2 tài khoản cho đủ 3 rồi thử người thứ 4 -> bị chặn (50053).

**Trước** – các bảng kết quả:
1. Vé V0004 của KH0004: Vé toàn chuỗi đang còn hạn.
2. Ủy quyền hiện có trên V0004: Chưa chia sẻ cho ai.
3. Ma trận vai trò x quyền: THANH_VIEN không có VE.GIAHAN.

```sql
SELECT MaVe, MaKH, BienSo, MaBaiApDung, NgayHetHan FROM dbo.VE_THANG WHERE MaVe = 'V0004';
SELECT uq.MaUyQuyen, uq.MaVe, tk.TenDangNhap AS NguoiNhan, uq.MaVaiTro, uq.TrangThai FROM dbo.UY_QUYEN_VE uq INNER JOIN dbo.TAI_KHOAN_KH tk ON uq.MaTKDuocUyQuyen = tk.MaTK WHERE uq.MaVe = 'V0004';
SELECT MaVaiTro, MaQuyen FROM dbo.VAI_TRO_QUYEN ORDER BY MaVaiTro, MaQuyen;
```

**Thực thi** – các bảng kết quả:
1. Chia sẻ V0004 cho KH0007: Vai trò THANH_VIEN, gửi thông báo cho cả hai bên.
2. KH0007 thấy vé được chia sẻ: vw_KH_VeThangCuaToi gồm vé chính chủ V0007 và V0004.
3. KH0007 xem lịch sử đỗ của V0004: Mọi vai trò đều có quyền LICHSU.XEM.
4. KH0007 thử gia hạn: f_KH_CoQuyen từ chối: lỗi 50050.
5. Chia sẻ người thứ 2: Thành công.
6. Chia sẻ người thứ 3: Thành công (đủ 3).
7. Chia sẻ người thứ 4: Bị chặn: lỗi 50053.

```sql
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
```

**Sau** – các bảng kết quả:
1. Ủy quyền trên V0004: Đúng 3 ủy quyền còn hiệu lực.
2. Thông báo ủy quyền: Gửi cho người nhận và chủ vé.

```sql
SELECT uq.MaUyQuyen, uq.MaVe, tk.TenDangNhap AS NguoiNhan, uq.MaVaiTro, uq.TrangThai, uq.NgayTao FROM dbo.UY_QUYEN_VE uq INNER JOIN dbo.TAI_KHOAN_KH tk ON uq.MaTKDuocUyQuyen = tk.MaTK WHERE uq.MaVe = 'V0004';
SELECT TOP 4 MaKH, LoaiTB, TieuDe, NoiDung FROM dbo.THONG_BAO WHERE LoaiTB = N'Ủy quyền' ORDER BY MaTB DESC;
```


#### `cursor-tu-dong-gia-han` – Demo Cursor + Savepoint: Tự động gia hạn vé tháng bằng số dư ví (sp_DemoTuDongGiaHanVeThang)

**Bài toán:** 3 vé bật tự động gia hạn đều còn <= 3 ngày: V0007 (xe máy BAI_TB, 200.000 ₫, ví 300.000 ₫), V0011 (ô tô BAI_Q7, 1.700.000 ₫, ví 5.000.000 ₫), V0012 (ô tô BAI_BT, 2.200.000 ₫, ví 100.000 ₫). Cursor xử lý từng vé trong savepoint riêng: 2 vé gia hạn thành công (hóa đơn kênh Tự động), vé thiếu tiền chỉ hoàn tác riêng phần của nó và khách nhận thông báo nạp thêm tiền.

**Trước** – các bảng kết quả:
1. Vé bật tự động gia hạn: Phí gia hạn (function) so với số dư ví của từng khách.

```sql
SELECT vt.MaVe, vt.MaKH, vt.BienSo, vt.NgayHetHan, vt.SoThangTuDongGiaHan, dbo.f_KH_TinhPhiGiaHan(vt.MaVe, vt.SoThangTuDongGiaHan) AS PhiGiaHan, vi.SoDu
FROM dbo.VE_THANG vt LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = vt.MaKH
WHERE vt.TuDongGiaHan = 1 ORDER BY vt.NgayHetHan;
```

**Thực thi** – các bảng kết quả:
1. Kết quả duyệt cursor: Mỗi vé một dòng: Đã gia hạn / Thiếu số dư (đã hoàn tác riêng).

```sql
EXEC dbo.sp_DemoTuDongGiaHanVeThang;
```

**Sau** – các bảng kết quả:
1. Vé sau khi chạy cursor: 2 vé được cộng hạn, vé thiếu tiền giữ nguyên.
2. Hóa đơn kênh Tự động: Gắn mã giao dịch trừ ví.
3. Thông báo gửi khách: Gia hạn thành công / yêu cầu nạp thêm tiền.

```sql
SELECT vt.MaVe, vt.MaKH, vt.BienSo, vt.NgayHetHan, vi.SoDu
FROM dbo.VE_THANG vt LEFT JOIN dbo.VI_DIEN_TU vi ON vi.MaKH = vt.MaKH
WHERE vt.TuDongGiaHan = 1 ORDER BY vt.NgayHetHan;
SELECT TOP 5 MaHD, MaVe, SoTien, MaPTTT, KenhThanhToan, MaGD, NgayThanhToan FROM dbo.HOA_DON_VE_THANG WHERE KenhThanhToan = N'Tự động' ORDER BY NgayThanhToan DESC;
SELECT TOP 5 MaKH, LoaiTB, TieuDe, NoiDung FROM dbo.THONG_BAO ORDER BY MaTB DESC;
```


#### `trigger-so-cai-bat-bien` – Demo Trigger: Sổ cái giao dịch bất biến (trg_GiaoDich_BatBien, trg_GiaoDich_ChanXoa)

**Bài toán:** Nhân viên gian lận cố sửa số tiền một giao dịch đã ghi, xóa giao dịch khỏi sổ cái và tự cộng số dư ví. Cả 3 thao tác đều bị trigger chặn (50061, 50060, 50062). Cách hợp lệ duy nhất để trả tiền lại cho khách là sp_NV_HoanTien: tạo giao dịch 'Hoàn tiền' đối ứng và chuyển giao dịch gốc sang 'Đã hoàn'. Thủ tục chỉ hoàn khoản trừ nhầm chưa gắn hóa đơn; khoản đã xuất hóa đơn gia hạn (vé đã được cộng hạn) bị từ chối (50063).

**Trước** – các bảng kết quả:
1. Sổ cái ví VI0004: Giao dịch GD260900000007 là thanh toán vé tháng 1.500.000 ₫.
2. Ví VI0004: Số dư trước khi thử gian lận.

```sql
SELECT MaGD, MaVi, LoaiGD, SoTien, TrangThai, SoDuTruoc, SoDuSau FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004' ORDER BY ThoiGianTao;
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaVi = 'VI0004';
```

**Thực thi** – các bảng kết quả:
1. Sửa số tiền: trg_GiaoDich_BatBien chặn: 50061.
2. Xóa giao dịch: trg_GiaoDich_ChanXoa chặn: 50060.
3. Tự cộng số dư: trg_ViDienTu_ChanSuaTrucTiep chặn: 50062.
4. Hoàn khoản đã xuất hóa đơn: sp_NV_HoanTien từ chối: 50063.
5. Hoàn tiền hợp lệ: Giao dịch đối ứng +50.000 ₫ cho khoản trừ nhầm qua sổ cái.

```sql
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
```

**Sau** – các bảng kết quả:
1. Sổ cái sau khi hoàn tiền: GD260900000007 vẫn 'Thành công'; khoản trừ nhầm chuyển 'Đã hoàn' và có thêm 1 giao dịch 'Hoàn tiền'.
2. Số dư ví: Trở về như trước sự cố: trừ nhầm -50.000 ₫ rồi hoàn +50.000 ₫ qua trigger sổ cái.

```sql
SELECT MaGD, MaVi, LoaiGD, SoTien, TrangThai, MaGDGoc, SoDuTruoc, SoDuSau, GhiChu FROM dbo.GIAO_DICH WHERE MaVi = 'VI0004' ORDER BY ThoiGianTao;
SELECT MaVi, MaKH, SoDu FROM dbo.VI_DIEN_TU WHERE MaVi = 'VI0004';
```



## PHỤ LỤC C. DỮ LIỆU MẪU GỐC (TRÍCH NGUYÊN VĂN TỪ `sql/02_sample_data.sql`)

Các câu INSERT dưới đây là dữ liệu mẫu nạp sẵn. Biểu thức `DATEADD(..., GETDATE())` nghĩa là mốc thời gian tính tương đối theo thời điểm nạp CSDL. Cột băm mật khẩu được rút gọn thành `<hash>` cho dễ đọc.


### 1. Bãi Đỗ Xe (5 chi nhánh; SucChua = số ô đỗ, SoLuongHienTai = số xe đang đỗ)

```sql
-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 2: NẠP DỮ LIỆU KHỞI TẠO MẪU (SAMPLE DATA CHO 11 BẢNG CHUẨN HÓA V6)
-- ====================================================================================

-- SINH TỰ ĐỘNG TỪ docs/QuanLyBaiDoXe_DuLieuMau.xlsx (NGUỒN CHUẨN CỦA DỮ LIỆU MẪU).
-- Không sửa tay file này: sửa dữ liệu trong Excel (sheet KiemTra phải ĐẠT hết) rồi sinh lại.
-- Các cột dẫn xuất (SucChua, SoLuongHienTai, VI_TRI_DO.TrangThai, TienGui, SoTien, NgayHetHan, MaHD...)
-- được ghi đúng giá trị Excel đã tính, nên không cần UPDATE đồng bộ sau khi nạp.
-- Dòng có mốc tương đối (xe đang đỗ, vé V0007) dùng DATEADD(..., GETDATE()) để luôn đúng tại thời điểm nạp.

-- 1. Bãi Đỗ Xe (5 chi nhánh; SucChua = số ô đỗ, SoLuongHienTai = số xe đang đỗ)
INSERT INTO dbo.BAI_DO_XE (MaBai, TenBai, DiaChi, SucChua, SoLuongHienTai) VALUES
('BAI_Q1', N'Bãi xe Lê Lai - Bến Thành', N'Số 26 Lê Lai, Phường Bến Thành, Quận 1, TP.HCM', 12, 2),
('BAI_Q3', N'Bãi xe Hai Bà Trưng', N'Số 180 Hai Bà Trưng, Phường Đa Kao, Quận 3, TP.HCM', 10, 1),
('BAI_BT', N'Bãi xe Landmark 81', N'Số 208 Nguyễn Hữu Cảnh, Phường 22, Bình Thạnh, TP.HCM', 12, 1),
('BAI_TB', N'Bãi xe TCP Park - Sân bay Tân Sơn Nhất', N'Cạnh nhà ga quốc nội, Cảng HKQT Tân Sơn Nhất, Phường 2, Quận Tân Bình, TP.HCM', 14, 3),
('BAI_Q7', N'Bãi xe SC VivoCity', N'Số 1058 Nguyễn Văn Linh, Phường Tân Phong, Quận 7, TP.HCM', 12, 2);
```

### 2. Hồ sơ Nhân Viên (Ban giám đốc, Quản lý bãi, Bảo vệ ca trực)

```sql
-- 2. Hồ sơ Nhân Viên (Ban giám đốc, Quản lý bãi, Bảo vệ ca trực)
INSERT INTO dbo.NHAN_VIEN (MaNV, HoTen, ChucVu, SDT, Email, MaBai) VALUES
('NV001', N'Nguyễn Hữu Trí', N'Giám đốc điều hành', '0901000001', 'tri.nguyen@smartparking.vn', NULL),
('NV002', N'Trần Văn Hùng', N'Quản lý bãi', '0901000002', 'hung.tran@smartparking.vn', 'BAI_Q1'),
('NV003', N'Lê Thị Bích Ngọc', N'Quản lý bãi', '0901000003', 'ngoc.le@smartparking.vn', 'BAI_Q3'),
('NV004', N'Hoàng Đình Nam', N'Quản lý bãi', '0901000004', 'nam.hoang@smartparking.vn', 'BAI_BT'),
('NV005', N'Phạm Văn Cường', N'Bảo vệ', '0901000005', 'cuong.pham@smartparking.vn', 'BAI_Q1'),
('NV006', N'Đặng Minh Tuấn', N'Bảo vệ', '0901000006', 'tuan.dang@smartparking.vn', 'BAI_Q3'),
('NV007', N'Vũ Đức Thắng', N'Bảo vệ', '0901000007', 'thang.vu@smartparking.vn', 'BAI_BT'),
('NV008', N'Huỳnh Quốc Bảo', N'Quản lý bãi', '0901000008', 'bao.huynh@smartparking.vn', 'BAI_TB'),
('NV009', N'Ngô Thị Thanh Hà', N'Quản lý bãi', '0901000009', 'ha.ngo@smartparking.vn', 'BAI_Q7'),
('NV010', N'Trương Văn Lộc', N'Bảo vệ', '0901000010', 'loc.truong@smartparking.vn', 'BAI_TB'),
('NV011', N'Bùi Thành Đạt', N'Bảo vệ', '0901000011', 'dat.bui@smartparking.vn', 'BAI_Q7');
```

### 3. Tài Khoản Truy Cập (mật khẩu mẫu từ cột MatKhauMau của Excel)

```sql
-- 3. Tài Khoản Truy Cập (mật khẩu mẫu từ cột MatKhauMau của Excel)
--    Băm SHA2_512(salt + mật khẩu) giống dbo.f_BamMatKhau (N5). Salt cố định = 16 byte đầu SHA-256(TenDangNhap)
--    để seed tái lập được; tài khoản tạo mới sau này dùng salt ngẫu nhiên CRYPT_GEN_RANDOM(16).
INSERT INTO dbo.TAI_KHOAN (TenDangNhap, MatKhauHash, MatKhauSalt, MaNV, TrangThai) VALUES
('admin', <hash>, <hex>, 'NV001', N'Hoạt động'),
('quanly_q1', <hash>, <hex>, 'NV002', N'Hoạt động'),
('quanly_q3', <hash>, <hex>, 'NV003', N'Hoạt động'),
('quanly_bt', <hash>, <hex>, 'NV004', N'Hoạt động'),
('baove_khoa', <hash>, <hex>, 'NV005', N'Bị khóa'),
('baove_q1', <hash>, <hex>, 'NV005', N'Hoạt động'),
('baove_q3', <hash>, <hex>, 'NV006', N'Hoạt động'),
('baove_bt', <hash>, <hex>, 'NV007', N'Hoạt động'),
('quanly_tb', <hash>, <hex>, 'NV008', N'Hoạt động'),
('quanly_q7', <hash>, <hex>, 'NV009', N'Hoạt động'),
('baove_tb', <hash>, <hex>, 'NV010', N'Hoạt động'),
('baove_q7', <hash>, <hex>, 'NV011', N'Hoạt động');
```

### 4. Phân Loại Phương Tiện & Biểu Phí theo từng Bãi Đỗ

```sql
-- 4. Phân Loại Phương Tiện & Biểu Phí theo từng Bãi Đỗ
INSERT INTO dbo.LOAI_XE (MaLoaiXe, MaBai, TenLoai, DonGiaGio, GiaVeThang) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 3 loại xe
('OT', 'BAI_Q1', N'Ô tô 4-7 chỗ', 25000, 1800000),
('XD', 'BAI_Q1', N'Xe đạp / Xe điện', 3000, 80000),
('XM', 'BAI_Q1', N'Xe máy', 6000, 180000),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 3 loại xe
('OT', 'BAI_Q3', N'Ô tô 4-7 chỗ', 20000, 1500000),
('XD', 'BAI_Q3', N'Xe đạp / Xe điện', 2000, 60000),
('XM', 'BAI_Q3', N'Xe máy', 5000, 150000),

-- Bãi xe Landmark 81 (BAI_BT) - 3 loại xe
('OT', 'BAI_BT', N'Ô tô 4-7 chỗ', 30000, 2200000),
('XD', 'BAI_BT', N'Xe đạp / Xe điện', 4000, 90000),
('XM', 'BAI_BT', N'Xe máy', 7000, 200000),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 3 loại xe
('OT', 'BAI_TB', N'Ô tô 4-7 chỗ', 25000, 1600000),
('XD', 'BAI_TB', N'Xe đạp / Xe điện', 3000, 80000),
('XM', 'BAI_TB', N'Xe máy', 5000, 200000),

-- Bãi xe SC VivoCity (BAI_Q7) - 3 loại xe
('OT', 'BAI_Q7', N'Ô tô 4-7 chỗ', 20000, 1700000),
('XD', 'BAI_Q7', N'Xe đạp / Xe điện', 2000, 70000),
('XM', 'BAI_Q7', N'Xe máy', 5000, 170000);
```

### 5. Vị Trí Ô Đỗ Xe (60 vị trí; TrangThai = 'Đã đỗ' khi có lượt đang mở)

```sql
-- 5. Vị Trí Ô Đỗ Xe (60 vị trí; TrangThai = 'Đã đỗ' khi có lượt đang mở)
INSERT INTO dbo.VI_TRI_DO (MaViTri, KhuVuc, TrangThai, MaLoaiXe, MaBai) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 12 vị trí
('Q1_OT_01', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_02', N'Khu B - Ngoài trời', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_03', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_OT_04', N'Khu B - Có mái che', N'Trống', 'OT', 'BAI_Q1'),
('Q1_XD_01', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XD_02', N'Khu C - Cửa vào', N'Trống', 'XD', 'BAI_Q1'),
('Q1_XM_01', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_02', N'Khu A - Tầng 1', N'Đã đỗ', 'XM', 'BAI_Q1'),
('Q1_XM_03', N'Khu A - Tầng 1', N'Đã đỗ', 'XM', 'BAI_Q1'),
('Q1_XM_04', N'Khu A - Tầng 1', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_05', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),
('Q1_XM_06', N'Khu A - Tầng 2', N'Trống', 'XM', 'BAI_Q1'),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 10 vị trí
('Q3_OT_01', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_02', N'Khu Ô tô Sân 1', N'Trống', 'OT', 'BAI_Q3'),
('Q3_OT_03', N'Khu Ô tô Sân 2', N'Trống', 'OT', 'BAI_Q3'),
('Q3_XD_01', N'Khu Xe đạp 1', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XD_02', N'Khu Xe đạp 2', N'Trống', 'XD', 'BAI_Q3'),
('Q3_XM_01', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_02', N'Khu Máy A', N'Đã đỗ', 'XM', 'BAI_Q3'),
('Q3_XM_03', N'Khu Máy A', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_04', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),
('Q3_XM_05', N'Khu Máy B', N'Trống', 'XM', 'BAI_Q3'),

-- Bãi xe Landmark 81 (BAI_BT) - 12 vị trí
('BT_OT_01', N'Hầm B2 - Zone A', N'Đã đỗ', 'OT', 'BAI_BT'),
('BT_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_03', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_BT'),
('BT_XD_01', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XD_02', N'Hầm B1 - Zone E', N'Trống', 'XD', 'BAI_BT'),
('BT_XM_01', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_02', N'Hầm B1 - Zone 1', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_03', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_04', N'Hầm B1 - Zone 2', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_05', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),
('BT_XM_06', N'Hầm B1 - Zone 3', N'Trống', 'XM', 'BAI_BT'),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 14 vị trí
('TB_OT_01', N'Tầng 2 - Khu ô tô', N'Đã đỗ', 'OT', 'BAI_TB'),
('TB_OT_02', N'Tầng 2 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_03', N'Tầng 2 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_04', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_05', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_OT_06', N'Tầng 3 - Khu ô tô', N'Trống', 'OT', 'BAI_TB'),
('TB_XD_01', N'Tầng 1 - Cổng vào', N'Trống', 'XD', 'BAI_TB'),
('TB_XD_02', N'Tầng 1 - Cổng vào', N'Trống', 'XD', 'BAI_TB'),
('TB_XM_01', N'Tầng 1 - Khu xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_02', N'Tầng 1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_TB'),
('TB_XM_03', N'Tầng 1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_TB'),
('TB_XM_04', N'Tầng 1 - Khu xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_05', N'Tầng lửng - Xe máy', N'Trống', 'XM', 'BAI_TB'),
('TB_XM_06', N'Tầng lửng - Xe máy', N'Trống', 'XM', 'BAI_TB'),

-- Bãi xe SC VivoCity (BAI_Q7) - 12 vị trí
('Q7_OT_01', N'Hầm B2 - Zone A', N'Đã đỗ', 'OT', 'BAI_Q7'),
('Q7_OT_02', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_03', N'Hầm B2 - Zone A', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_04', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_Q7'),
('Q7_OT_05', N'Hầm B2 - Zone B', N'Trống', 'OT', 'BAI_Q7'),
('Q7_XD_01', N'Hầm B1 - Khu xe đạp', N'Trống', 'XD', 'BAI_Q7'),
('Q7_XD_02', N'Hầm B1 - Khu xe đạp', N'Trống', 'XD', 'BAI_Q7'),
('Q7_XM_01', N'Hầm B1 - Khu xe máy', N'Đã đỗ', 'XM', 'BAI_Q7'),
('Q7_XM_02', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_03', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_04', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7'),
('Q7_XM_05', N'Hầm B1 - Khu xe máy', N'Trống', 'XM', 'BAI_Q7');
```

### 6. Kho Thẻ Xe theo bãi phát hành

```sql
-- 6. Kho Thẻ Xe theo bãi phát hành
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
-- Bãi xe Lê Lai - Bến Thành (BAI_Q1) - 6 thẻ
('THE0001', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0002', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-01'),
('THE0003', 'BAI_Q1', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0004', 'BAI_Q1', N'Tháng', N'Hoạt động', '2026-01-10'),
('THE0005', 'BAI_Q1', N'Lượt', N'Bị khóa', '2026-01-12'),
('THE0006', 'BAI_Q1', N'Lượt', N'Mất', '2026-01-15'),

-- Bãi xe Hai Bà Trưng (BAI_Q3) - 4 thẻ
('THE0007', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0008', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-03'),
('THE0009', 'BAI_Q3', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0010', 'BAI_Q3', N'Tháng', N'Hoạt động', '2026-01-08'),

-- Bãi xe Landmark 81 (BAI_BT) - 5 thẻ
('THE0011', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-01'),
('THE0012', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-02'),
('THE0013', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-05'),
('THE0014', 'BAI_BT', N'Tháng', N'Hoạt động', '2026-01-06'),
('THE0015', 'BAI_BT', N'Lượt', N'Hoạt động', '2026-01-10'),

-- Bãi xe TCP Park - Sân bay Tân Sơn Nhất (BAI_TB) - 5 thẻ
('THE0016', 'BAI_TB', N'Lượt', N'Hoạt động', '2026-02-01'),
('THE0017', 'BAI_TB', N'Tháng', N'Hoạt động', '2026-03-01'),
('THE0018', 'BAI_TB', N'Lượt', N'Hoạt động', '2026-02-01'),
('THE0019', 'BAI_TB', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE)),
('THE0020', 'BAI_TB', N'Lượt', N'Bị khóa', '2026-02-10'),

-- Bãi xe SC VivoCity (BAI_Q7) - 5 thẻ
('THE0021', 'BAI_Q7', N'Lượt', N'Hoạt động', '2026-01-15'),
('THE0022', 'BAI_Q7', N'Tháng', N'Hoạt động', '2026-01-15'),
('THE0023', 'BAI_Q7', N'Lượt', N'Hoạt động', '2026-01-15'),
('THE0024', 'BAI_Q7', N'Tháng', N'Hoạt động', '2026-06-01'),
('THE0025', 'BAI_Q7', N'Lượt', N'Mất', '2026-01-20');
```

### 7. Hồ sơ Khách Hàng

```sql
-- 7. Hồ sơ Khách Hàng
INSERT INTO dbo.KHACH_HANG (MaKH, HoTen, SDT, Email, CMND_CCCD) VALUES
('KH0001', N'Nguyễn Văn An', '0903112233', 'nguyenvanan@gmail.com', '079090001111'),
('KH0002', N'Trần Thị Mai', '0912445566', 'tranmai.hcm@gmail.com', '079090002222'),
('KH0003', N'Lê Hoàng Long', '0988776655', 'long.lehoang@yahoo.com', '079090003333'),
('KH0004', N'Phạm Thu Trang', '0934556677', 'trangpham@outlook.com', '079090004444'),
('KH0005', N'Võ Minh Quân', '0977112244', 'quan.vominh@gmail.com', '079090005555'),
('KH0006', N'Đỗ Thanh Phong', '0908246810', 'phong.dothanh@gmail.com', '079090006666'),
('KH0007', N'Lý Ngọc Hân', '0938135790', 'han.lyngoc@gmail.com', '079090007777'),
('KH0008', N'Châu Minh Khang', '0917258036', 'khang.chau@outlook.com', '079090018888'),
('KH0009', N'Tạ Thị Kim Oanh', '0966369147', 'oanh.takim@yahoo.com', '079090009999'),
('KH0010', N'Phan Gia Huy', '0945112233', 'huy.phangia@gmail.com', '079090010101');
```

### 8. Vé Tháng (NgayHetHan = NgayDangKy + tổng số tháng trên hóa đơn)

```sql
-- 8. Vé Tháng (NgayHetHan = NgayDangKy + tổng số tháng trên hóa đơn)
INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung) VALUES
('V0001', 'THE0002', 'KH0001', '59A-123.45', 'XM', '2026-01-01', '2027-01-01', N'Hoạt động', 'BAI_Q1'),
('V0002', 'THE0004', 'KH0002', '51G-888.99', 'OT', '2026-01-10', '2026-10-10', N'Hoạt động', 'BAI_Q1'),
('V0003', 'THE0008', 'KH0003', '59B-456.78', 'XM', '2026-01-03', '2026-02-03', N'Hết hạn', 'BAI_Q3'),
('V0004', 'THE0010', 'KH0004', '51H-999.11', 'OT', '2026-01-08', '2026-11-08', N'Hoạt động', 'ALL'),
('V0005', 'THE0012', 'KH0005', '59C-678.90', 'XM', '2026-01-02', '2027-01-02', N'Hoạt động', 'BAI_BT'),
('V0006', 'THE0017', 'KH0006', '51K-246.80', 'OT', '2026-03-01', '2027-03-01', N'Hoạt động', 'BAI_TB'),
('V0007', 'THE0019', 'KH0007', '59P-357.91', 'XM', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -28, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_TB'),
('V0008', 'THE0022', 'KH0008', '59N-147.25', 'XM', '2026-01-15', '2026-07-15', N'Hết hạn', 'BAI_Q7'),
('V0009', 'THE0024', 'KH0009', '51L-802.46', 'OT', '2026-06-01', '2026-12-01', N'Hoạt động', 'BAI_Q7'),
('V0010', 'THE0014', 'KH0010', '51M-135.24', 'OT', '2026-01-06', '2027-01-06', N'Hoạt động', 'BAI_BT');
```

### 9. Hóa Đơn Vé Tháng (SoTien = số tháng x giá vé tháng tại bãi tính giá)

```sql
-- 9. Hóa Đơn Vé Tháng (SoTien = số tháng x giá vé tháng tại bãi tính giá)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai) VALUES
('HD20260101001', 'V0001', '2026-01-01 00:00:00', 12, 2160000, 'BAI_Q1'),
('HD20260110002', 'V0002', '2026-01-10 00:00:00', 9, 16200000, 'BAI_Q1'),
('HD20260103003', 'V0003', '2026-01-03 00:00:00', 1, 150000, 'BAI_Q3'),
('HD20260108004', 'V0004', '2026-01-08 00:00:00', 10, 15000000, 'BAI_Q3'),
('HD20260102005', 'V0005', '2026-01-02 00:00:00', 12, 2400000, 'BAI_BT'),
('HD20260301006', 'V0006', '2026-03-01 00:00:00', 12, 19200000, 'BAI_TB'),
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), 'yyyyMMdd'), '007'), 'V0007', CAST(DATEADD(DAY, -28, GETDATE()) AS DATE), 1, 200000, 'BAI_TB'),
('HD20260115008', 'V0008', '2026-01-15 00:00:00', 6, 1020000, 'BAI_Q7'),
('HD20260601009', 'V0009', '2026-06-01 00:00:00', 6, 10200000, 'BAI_Q7'),
('HD20260106010', 'V0010', '2026-01-06 00:00:00', 12, 26400000, 'BAI_BT');
```

### 10. Nhật Ký Lượt Gửi Xe (MaLuot IDENTITY theo thứ tự dòng; TienGui theo f_TinhTienGuiXe, thẻ tháng = 0)

```sql
-- 10. Nhật Ký Lượt Gửi Xe (MaLuot IDENTITY theo thứ tự dòng; TienGui theo f_TinhTienGuiXe, thẻ tháng = 0)
-- Lượt đã check-out
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59A-111.22', '2026-09-07 07:15:00', '2026-09-07 11:15:00', 'Q1_XM_01', 24000, 'BAI_Q1'),
('THE0003', '51G-222.33', '2026-09-07 08:00:00', '2026-09-07 14:00:00', 'Q1_OT_01', 150000, 'BAI_Q1'),
('THE0007', '59B-333.44', '2026-09-07 09:30:00', '2026-09-07 12:30:00', 'Q3_XM_01', 15000, 'BAI_Q3'),
('THE0011', '59C-444.55', '2026-09-07 06:45:00', '2026-09-07 17:45:00', 'BT_XM_01', 77000, 'BAI_BT'),
('THE0016', '59D-234.56', '2026-09-07 05:30:00', '2026-09-07 08:10:00', 'TB_XM_01', 15000, 'BAI_TB'),
('THE0018', '51F-135.79', '2026-09-07 10:00:00', '2026-09-07 15:20:00', 'TB_OT_04', 150000, 'BAI_TB'),
('THE0017', '51K-246.80', '2026-09-08 06:00:00', '2026-09-08 18:00:00', 'TB_OT_02', 0, 'BAI_TB'),
('THE0021', '59T-111.22', '2026-09-07 18:00:00', '2026-09-07 21:45:00', 'Q7_XM_02', 20000, 'BAI_Q7'),
('THE0023', '51H-246.13', '2026-09-07 11:00:00', '2026-09-07 11:10:00', 'Q7_OT_03', 0, 'BAI_Q7');

-- Lượt hiện đang đỗ (ThoiGianRa IS NULL)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai) VALUES
('THE0001', '59K-987.65', DATEADD(MINUTE, -120, GETDATE()), NULL, 'Q1_XM_02', 0, 'BAI_Q1'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -240, GETDATE()), NULL, 'Q1_XM_03', 0, 'BAI_Q1'),
('THE0007', '59E-555.66', DATEADD(MINUTE, -60, GETDATE()), NULL, 'Q3_XM_02', 0, 'BAI_Q3'),
('THE0013', '51A-777.88', DATEADD(MINUTE, -180, GETDATE()), NULL, 'BT_OT_01', 0, 'BAI_BT'),
('THE0016', '59D-678.12', DATEADD(MINUTE, -90, GETDATE()), NULL, 'TB_XM_02', 0, 'BAI_TB'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -300, GETDATE()), NULL, 'TB_XM_03', 0, 'BAI_TB'),
('THE0018', '51G-468.02', DATEADD(MINUTE, -120, GETDATE()), NULL, 'TB_OT_01', 0, 'BAI_TB'),
('THE0024', '51L-802.46', DATEADD(MINUTE, -360, GETDATE()), NULL, 'Q7_OT_01', 0, 'BAI_Q7'),
('THE0021', '59T-579.13', DATEADD(MINUTE, -60, GETDATE()), NULL, 'Q7_XM_01', 0, 'BAI_Q7');
```

### 11. Nhật Ký Sự Cố (sự cố mất thẻ áp phí phạt PhatMatThe)

```sql
-- 11. Nhật Ký Sự Cố (sự cố mất thẻ áp phí phạt PhatMatThe)
INSERT INTO dbo.LICHSU_SU_CO (MaThe, BienSo, ThoiGianSuCo, MoTa, TienPhat, TrangThaiXuLy, MaBai) VALUES
('THE0006', '59X-999.01', '2026-01-15 11:00:00', N'Khách hàng làm rơi thẻ xe tại quầy nước, lập biên bản báo mất thẻ chip', 50000, N'Đã giải quyết', 'BAI_Q1'),
(NULL, '51B-123.45', '2026-02-10 18:30:00', N'Va quẹt nhẹ gương chiếu hậu khi lùi xe vào ô đỗ Q3_OT_01', 200000, N'Đã giải quyết', 'BAI_Q3'),
(NULL, '51F-135.79', '2026-09-07 10:05:00', N'Ô tô cọ quẹt trụ bê tông tại dốc lên Tầng 3, trầy sơn hông xe, đang chờ đối chiếu camera', 300000, N'Đang giải quyết', 'BAI_TB'),
('THE0025', NULL, '2026-08-20 20:15:00', N'Khách hàng báo mất thẻ chip THE0025 (Loại: Lượt). Hệ thống tự động khóa thẻ và áp phí phạt đền bù thẻ vật lý.', 50000, N'Đã giải quyết', 'BAI_Q7');
```

### 1. Tài khoản cổng khách hàng (8 tài khoản; KH0005 và KH0008 chưa có tài khoản - dùng cho demo đăng ký)

```sql
-- ====================================================================================
-- PHẦN CỔNG KHÁCH HÀNG
-- ====================================================================================

-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- DỮ LIỆU MẪU CỔNG KHÁCH HÀNG (UPGRADE_PLAN.md MỤC 11)
--
-- TẠM THỜI VIẾT TAY: script sinh seed từ docs/QuanLyBaiDoXe_DuLieuMau.xlsx chưa có trong repo (N8).
-- Khi có script, chuyển dữ liệu dưới đây vào các sheet tương ứng của Excel master (D11) và sinh lại file này.
--
-- Quy ước giống 02_sample_data.sql:
-- - Chạy một lần trên CSDL vừa nạp 01 -> 10 (không idempotent, giống 02).
-- - Cột dẫn xuất ghi giá trị đã tính sẵn: VI_DIEN_TU.SoDu, GIAO_DICH.SoDuTruoc / SoDuSau (file này chạy TRƯỚC
--   khi trigger sổ cái ở bước 14 được tạo, nên không dựa vào trigger để tính số dư).
-- - Mốc thời gian tương đối dùng DATEADD(..., GETDATE()) để luôn đúng khi nạp lại.
-- - Mật khẩu mẫu của mọi tài khoản khách: 'Khach@2026', salt cố định (giá trị tổng hợp cho demo) để seed tái lập được.
--   Biểu thức hash trùng với dbo.f_BamMatKhau: HASHBYTES('SHA2_512', salt + CAST(<mật khẩu VARCHAR> AS VARBINARY(100))).
-- - Các lượt gửi lịch sử chèn ở đây đi qua trigger V6 của LUOT_GUI nên chỉ dùng vé còn hạn, đúng bãi, thẻ hoạt động.
-- ====================================================================================

-- 1. Tài khoản cổng khách hàng (8 tài khoản; KH0005 và KH0008 chưa có tài khoản - dùng cho demo đăng ký)
-- TK0005 (KH0006) đang tạm khóa để màn hình nhân viên có dữ liệu "Mở khóa".
INSERT INTO dbo.TAI_KHOAN_KH (MaTK, MaKH, TenDangNhap, MatKhauHash, MatKhauSalt, TrangThai, SoLanSaiLienTiep, KhoaDen, NgayTao, LanDangNhapCuoi) VALUES
('TK0001', 'KH0001', '0903112233', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -60, GETDATE()), DATEADD(HOUR, -20, GETDATE())),
('TK0002', 'KH0002', '0912445566', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -45, GETDATE()), DATEADD(HOUR, -5, GETDATE())),
('TK0003', 'KH0003', '0988776655', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -12, GETDATE())),
('TK0004', 'KH0004', '0934556677', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -2, GETDATE())),
('TK0005', 'KH0006', '0908246810', <hash>, <hex>, N'Tạm khóa', 5, DATEADD(MINUTE, 10, GETDATE()), DATEADD(DAY, -62, GETDATE()), DATEADD(DAY, -3, GETDATE())),
('TK0006', 'KH0007', '0938135790', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -1, GETDATE())),
('TK0007', 'KH0009', '0966369147', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -4, GETDATE())),
('TK0008', 'KH0010', '0945112233', <hash>, <hex>, N'Hoạt động', 0, NULL, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -5, GETDATE()));
```

### 2. Nhật ký đăng nhập (TK0005 sai 5 lần trong 15 phút gần nhất -> đang tạm khóa)

```sql
-- 2. Nhật ký đăng nhập (TK0005 sai 5 lần trong 15 phút gần nhất -> đang tạm khóa)
INSERT INTO dbo.NHAT_KY_DANG_NHAP (MaTK, TenDangNhapNhap, ThoiGian, KetQua, DiaChiIP, ThietBi) VALUES
('TK0001', '0903112233', DATEADD(HOUR, -20, GETDATE()), N'Thành công', '113.161.45.10', N'Chrome / Windows'),
('TK0002', '0912445566', DATEADD(HOUR, -5, GETDATE()), N'Thành công', '14.169.22.81', N'Safari / iOS'),
('TK0004', '0934556677', DATEADD(DAY, -2, GETDATE()), N'Thành công', '27.72.98.140', N'Chrome / Android'),
('TK0006', '0938135790', DATEADD(DAY, -1, GETDATE()), N'Thành công', '171.244.10.55', N'Chrome / macOS'),
(NULL, '0900000000', DATEADD(HOUR, -3, GETDATE()), N'Không tồn tại', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -9, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -8, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -7, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -6, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4'),
('TK0005', '0908246810', DATEADD(MINUTE, -5, GETDATE()), N'Sai mật khẩu', '45.124.84.12', N'curl/8.4');
```

### 3. Ví điện tử (SoDu = tổng sổ cái các giao dịch 'Thành công' / 'Đã hoàn' ở mục 4)

```sql
-- 3. Ví điện tử (SoDu = tổng sổ cái các giao dịch 'Thành công' / 'Đã hoàn' ở mục 4)
INSERT INTO dbo.VI_DIEN_TU (MaVi, MaKH, SoDu, NgayTao) VALUES
('VI0001', 'KH0001', 300000, DATEADD(DAY, -60, GETDATE())),
('VI0002', 'KH0002', 3000000, DATEADD(DAY, -45, GETDATE())),
('VI0003', 'KH0003', 0, DATEADD(DAY, -40, GETDATE())),
('VI0004', 'KH0004', 50000, DATEADD(DAY, -42, GETDATE())),
('VI0005', 'KH0006', 2600000, DATEADD(DAY, -62, GETDATE())),
('VI0006', 'KH0007', 300000, DATEADD(DAY, -27, GETDATE())),
('VI0007', 'KH0009', 5000000, DATEADD(DAY, -21, GETDATE())),
('VI0008', 'KH0010', 100000, DATEADD(DAY, -6, GETDATE()));
```

### 4. Sổ cái giao dịch (theo thứ tự thời gian trong từng ví; SoDuTruoc / SoDuSau liên tục)

```sql
-- 4. Sổ cái giao dịch (theo thứ tự thời gian trong từng ví; SoDuTruoc / SoDuSau liên tục)
-- VI0001: 0 -> +480.000 (MoMo) -> -180.000 (gia hạn V0001 online) = 300.000; 1 lệnh VNPay thất bại
-- VI0002: 0 -> +3.000.000 (tiền mặt tại quầy) = 3.000.000; 1 lệnh chuyển khoản treo 2 giờ (cursor đối soát sẽ chuyển Thất bại)
-- VI0004: 0 -> +1.550.000 (thẻ) -> -1.500.000 (gia hạn V0004 online, giá bãi phát hành thẻ BAI_Q3) = 50.000
-- VI0005: 0 -> +2.600.000 -> -1.600.000 (gia hạn V0006) -> +1.600.000 -> -1.600.000 (trừ trùng, đã hoàn) -> +1.600.000 (hoàn) = 2.600.000
-- VI0006: +300.000 (ZaloPay, trước khi cổng tạm ngưng) | VI0007: +5.000.000 | VI0008: +100.000
INSERT INTO dbo.GIAO_DICH (MaGD, MaVi, LoaiGD, HuongTien, SoTien, PhiGiaoDich, SoDuTruoc, SoDuSau, MaPTTT, MaThamChieu, TrangThai, MaVe, MaGDGoc, NguoiThucHien, MaNV, ThoiGianTao, ThoiGianHoanTat, GhiChu) VALUES
('GD260900000001', 'VI0001', N'Nạp tiền', 1, 480000, 7200, 0, 480000, 'MOMO', 'MOMO-SEED-0001', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -25, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000002', 'VI0001', N'Thanh toán vé tháng', -1, 180000, 0, 480000, 300000, 'SO_DU_VI', NULL, N'Thành công', 'V0001', NULL, N'Khách hàng', NULL, DATEADD(DAY, -24, GETDATE()), DATEADD(DAY, -24, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000003', 'VI0001', N'Nạp tiền', 1, 200000, 2200, NULL, NULL, 'VNPAY', 'VNPAY-SEED-0003', N'Thất bại', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -10, GETDATE()), N'Cổng thanh toán báo thất bại'),
('GD260900000004', 'VI0002', N'Nạp tiền', 1, 3000000, 0, 0, 3000000, 'TIEN_MAT', NULL, N'Thành công', NULL, NULL, N'Nhân viên', 'NV002', DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -30, GETDATE()), N'Nạp tiền mặt tại quầy'),
('GD260900000005', 'VI0002', N'Nạp tiền', 1, 1000000, 0, NULL, NULL, 'CHUYEN_KHOAN', NULL, N'Chờ xử lý', NULL, NULL, N'Khách hàng', NULL, DATEADD(MINUTE, -120, GETDATE()), NULL, N'Chờ kết quả từ cổng thanh toán'),
('GD260900000006', 'VI0004', N'Nạp tiền', 1, 1550000, 31000, 0, 1550000, 'THE_NH', 'THENH-SEED-0006', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -40, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000007', 'VI0004', N'Thanh toán vé tháng', -1, 1500000, 0, 1550000, 50000, 'SO_DU_VI', NULL, N'Thành công', 'V0004', NULL, N'Khách hàng', NULL, DATEADD(DAY, -39, GETDATE()), DATEADD(DAY, -39, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000008', 'VI0005', N'Nạp tiền', 1, 2600000, 28600, 0, 2600000, 'VNPAY', 'VNPAY-SEED-0008', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -60, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000009', 'VI0005', N'Thanh toán vé tháng', -1, 1600000, 0, 2600000, 1000000, 'SO_DU_VI', NULL, N'Thành công', 'V0006', NULL, N'Khách hàng', NULL, DATEADD(DAY, -59, GETDATE()), DATEADD(DAY, -59, GETDATE()), N'Gia hạn online 1 tháng'),
('GD260900000010', 'VI0005', N'Nạp tiền', 1, 1600000, 24000, 1000000, 2600000, 'MOMO', 'MOMO-SEED-0010', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -31, GETDATE()), DATEADD(DAY, -31, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000011', 'VI0005', N'Thanh toán vé tháng', -1, 1600000, 0, 2600000, 1000000, 'SO_DU_VI', NULL, N'Đã hoàn', 'V0006', NULL, N'Khách hàng', NULL, DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -30, GETDATE()), N'Trừ trùng do lỗi kết nối | Đã hoàn tiền bởi GD260900000012'),
('GD260900000012', 'VI0005', N'Hoàn tiền', 1, 1600000, 0, 1000000, 2600000, 'SO_DU_VI', NULL, N'Thành công', 'V0006', 'GD260900000011', N'Nhân viên', 'NV008', DATEADD(DAY, -29, GETDATE()), DATEADD(DAY, -29, GETDATE()), N'Hoàn tiền giao dịch trừ trùng'),
('GD260900000013', 'VI0006', N'Nạp tiền', 1, 300000, 3600, 0, 300000, 'ZALOPAY', 'ZALO-SEED-0013', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -27, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000014', 'VI0007', N'Nạp tiền', 1, 5000000, 0, 0, 5000000, 'CHUYEN_KHOAN', 'BANK-SEED-0014', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -20, GETDATE()), N'Cổng thanh toán xác nhận thành công'),
('GD260900000015', 'VI0008', N'Nạp tiền', 1, 100000, 1500, 0, 100000, 'MOMO', 'MOMO-SEED-0015', N'Thành công', NULL, NULL, N'Khách hàng', NULL, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -5, GETDATE()), N'Cổng thanh toán xác nhận thành công');
```

### 5. Hai vé tháng mới có mốc tương đối (giống V0007): đăng ký 1 tháng cách thời điểm nạp 29 ngày,

```sql
-- 5. Hai vé tháng mới có mốc tương đối (giống V0007): đăng ký 1 tháng cách thời điểm nạp 29 ngày,
--    nên luôn còn <= 3 ngày khi demo cursor tự động gia hạn.
INSERT INTO dbo.THE_XE (MaThe, MaBai, LoaiThe, TrangThai, NgayCap) VALUES
('THE0026', 'BAI_Q7', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)),
('THE0027', 'BAI_BT', N'Tháng', N'Hoạt động', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE));
```

### VE_THANG

```sql
INSERT INTO dbo.VE_THANG (MaVe, MaThe, MaKH, BienSo, MaLoaiXe, NgayDangKy, NgayHetHan, TrangThai, MaBaiApDung, TuDongGiaHan, SoThangTuDongGiaHan) VALUES
('V0011', 'THE0026', 'KH0009', '51L-913.57', 'OT', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_Q7', 1, 1),
('V0012', 'THE0027', 'KH0010', '51M-468.20', 'OT', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), DATEADD(MONTH, 1, CAST(DATEADD(DAY, -29, GETDATE()) AS DATE)), N'Hoạt động', 'BAI_BT', 1, 1);
```

### 6. Hóa đơn: 2 hóa đơn tại quầy của V0011 / V0012 và 3 hóa đơn online gắn giao dịch ví

```sql
-- 6. Hóa đơn: 2 hóa đơn tại quầy của V0011 / V0012 và 3 hóa đơn online gắn giao dịch ví
-- (10 hóa đơn V6 tự nhận MaPTTT = 'TIEN_MAT', KenhThanhToan = 'Tại quầy' từ DEFAULT ở bước 10)
INSERT INTO dbo.HOA_DON_VE_THANG (MaHD, MaVe, NgayThanhToan, SoThangGiaHan, SoTien, MaBai, MaPTTT, KenhThanhToan, MaGD, MaNVThu) VALUES
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 'yyyyMMdd'), '011'), 'V0011', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 1, 1700000, 'BAI_Q7', 'TIEN_MAT', N'Tại quầy', NULL, 'NV009'),
(CONCAT('HD', FORMAT(CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 'yyyyMMdd'), '012'), 'V0012', CAST(DATEADD(DAY, -29, GETDATE()) AS DATE), 1, 2200000, 'BAI_BT', 'TIEN_MAT', N'Tại quầy', NULL, 'NV004'),
(CONCAT('HD', FORMAT(DATEADD(DAY, -24, GETDATE()), 'yyyyMMdd'), '013'), 'V0001', DATEADD(DAY, -24, GETDATE()), 1, 180000, 'BAI_Q1', 'SO_DU_VI', N'Online', 'GD260900000002', NULL),
(CONCAT('HD', FORMAT(DATEADD(DAY, -39, GETDATE()), 'yyyyMMdd'), '014'), 'V0004', DATEADD(DAY, -39, GETDATE()), 1, 1500000, 'BAI_Q3', 'SO_DU_VI', N'Online', 'GD260900000007', NULL),
(CONCAT('HD', FORMAT(DATEADD(DAY, -59, GETDATE()), 'yyyyMMdd'), '015'), 'V0006', DATEADD(DAY, -59, GETDATE()), 1, 1600000, 'BAI_TB', 'SO_DU_VI', N'Online', 'GD260900000009', NULL);
```

### 7. Ủy quyền: KH0001 chia sẻ V0001 cho tài khoản KH0002 với vai trò chỉ xem lịch sử

```sql
-- 7. Ủy quyền: KH0001 chia sẻ V0001 cho tài khoản KH0002 với vai trò chỉ xem lịch sử
INSERT INTO dbo.UY_QUYEN_VE (MaVe, MaTKDuocUyQuyen, MaVaiTro, NgayBatDau, NgayKetThuc, TrangThai, MaTKCap, NgayTao) VALUES
('V0001', 'TK0002', 'XEM_LICH_SU', CAST(DATEADD(DAY, -10, GETDATE()) AS DATE), NULL, N'Hiệu lực', 'TK0001', DATEADD(DAY, -10, GETDATE()));
```

### 8. Thông báo mẫu (mỗi khách có tài khoản có ít nhất 1 thông báo chưa đọc)

```sql
-- 8. Thông báo mẫu (mỗi khách có tài khoản có ít nhất 1 thông báo chưa đọc)
INSERT INTO dbo.THONG_BAO (MaKH, LoaiTB, TieuDe, NoiDung, MaVe, MaGD, DaDoc, ThoiGianTao) VALUES
('KH0001', N'Giao dịch', N'Gia hạn vé tháng online thành công', N'Vé V0001 đã được gia hạn thêm 1 tháng bằng số dư ví (180.000 đồng).', 'V0001', 'GD260900000002', 1, DATEADD(DAY, -24, GETDATE())),
('KH0001', N'Ủy quyền', N'Đã chia sẻ vé tháng', N'Bạn đã chia sẻ vé V0001 cho tài khoản 0912445566 với vai trò Chỉ xem lịch sử.', 'V0001', NULL, 0, DATEADD(DAY, -10, GETDATE())),
('KH0002', N'Giao dịch', N'Nạp tiền tại quầy thành công', N'Ví đã được cộng 3.000.000 đồng tiền mặt tại quầy (giao dịch GD260900000004).', NULL, 'GD260900000004', 1, DATEADD(DAY, -30, GETDATE())),
('KH0002', N'Ủy quyền', N'Bạn được chia sẻ một vé tháng', N'Vé V0001 đã được chia sẻ cho bạn với vai trò Chỉ xem lịch sử (không thời hạn).', 'V0001', NULL, 0, DATEADD(DAY, -10, GETDATE())),
('KH0003', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Bạn có thể nạp tiền vào ví, tự gia hạn vé tháng và xem lịch sử đỗ xe.', NULL, NULL, 0, DATEADD(DAY, -40, GETDATE())),
('KH0004', N'Giao dịch', N'Gia hạn vé tháng online thành công', N'Vé V0004 đã được gia hạn thêm 1 tháng bằng số dư ví (1.500.000 đồng).', 'V0004', 'GD260900000007', 0, DATEADD(DAY, -39, GETDATE())),
('KH0006', N'Giao dịch', N'Hoàn tiền vào ví', N'Ví được hoàn 1.600.000 đồng cho giao dịch GD260900000011. Lý do: Hoàn tiền giao dịch trừ trùng.', 'V0006', 'GD260900000012', 1, DATEADD(DAY, -29, GETDATE())),
('KH0006', N'Bảo mật', N'Tài khoản tạm khóa do đăng nhập sai nhiều lần', N'Phát hiện 5 lần nhập sai mật khẩu trong 15 phút. Tài khoản đang tạm khóa.', NULL, NULL, 0, DATEADD(MINUTE, -5, GETDATE())),
('KH0007', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Hãy bật tự động gia hạn để không bị gián đoạn khi gửi xe.', NULL, NULL, 0, DATEADD(DAY, -27, GETDATE())),
('KH0009', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Ví đã sẵn sàng để gia hạn vé tháng online.', NULL, NULL, 0, DATEADD(DAY, -21, GETDATE())),
('KH0010', N'Hệ thống', N'Chào mừng đến cổng khách hàng SmartPark', N'Tài khoản đã được tạo. Ví đã sẵn sàng để gia hạn vé tháng online.', NULL, NULL, 0, DATEADD(DAY, -6, GETDATE()));
```

### 9. Lượt gửi lịch sử của xe vé tháng trong 30 ngày gần nhất (đã ra bãi, xe tháng miễn phí lượt gửi)

```sql
-- 9. Lượt gửi lịch sử của xe vé tháng trong 30 ngày gần nhất (đã ra bãi, xe tháng miễn phí lượt gửi)
INSERT INTO dbo.LUOT_GUI (MaThe, BienSo, ThoiGianVao, ThoiGianRa, MaViTri, TienGui, MaBai, MaVe) VALUES
('THE0002', '59A-123.45', DATEADD(MINUTE, -(3 * 1440 + 620), GETDATE()), DATEADD(MINUTE, -(3 * 1440 + 80), GETDATE()), 'Q1_XM_01', 0, 'BAI_Q1', 'V0001'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -(6 * 1440 + 610), GETDATE()), DATEADD(MINUTE, -(6 * 1440 + 95), GETDATE()), 'Q1_XM_04', 0, 'BAI_Q1', 'V0001'),
('THE0002', '59A-123.45', DATEADD(MINUTE, -(9 * 1440 + 600), GETDATE()), DATEADD(MINUTE, -(9 * 1440 + 70), GETDATE()), 'Q1_XM_05', 0, 'BAI_Q1', 'V0001'),
('THE0012', '59C-678.90', DATEADD(MINUTE, -(2 * 1440 + 540), GETDATE()), DATEADD(MINUTE, -(2 * 1440 + 30), GETDATE()), 'BT_XM_02', 0, 'BAI_BT', 'V0005'),
('THE0012', '59C-678.90', DATEADD(MINUTE, -(7 * 1440 + 560), GETDATE()), DATEADD(MINUTE, -(7 * 1440 + 45), GETDATE()), 'BT_XM_02', 0, 'BAI_BT', 'V0005'),
('THE0017', '51K-246.80', DATEADD(MINUTE, -(4 * 1440 + 480), GETDATE()), DATEADD(MINUTE, -(4 * 1440 + 120), GETDATE()), 'TB_OT_03', 0, 'BAI_TB', 'V0006'),
('THE0017', '51K-246.80', DATEADD(MINUTE, -(12 * 1440 + 500), GETDATE()), DATEADD(MINUTE, -(12 * 1440 + 60), GETDATE()), 'TB_OT_03', 0, 'BAI_TB', 'V0006'),
('THE0014', '51M-135.24', DATEADD(MINUTE, -(1 * 1440 + 600), GETDATE()), DATEADD(MINUTE, -(1 * 1440 + 50), GETDATE()), 'BT_OT_02', 0, 'BAI_BT', 'V0010'),
('THE0014', '51M-135.24', DATEADD(MINUTE, -(5 * 1440 + 620), GETDATE()), DATEADD(MINUTE, -(5 * 1440 + 40), GETDATE()), 'BT_OT_02', 0, 'BAI_BT', 'V0010'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -(3 * 1440 + 400), GETDATE()), DATEADD(MINUTE, -(3 * 1440 + 100), GETDATE()), 'TB_XM_04', 0, 'BAI_TB', 'V0007'),
('THE0019', '59P-357.91', DATEADD(MINUTE, -(10 * 1440 + 420), GETDATE()), DATEADD(MINUTE, -(10 * 1440 + 90), GETDATE()), 'TB_XM_04', 0, 'BAI_TB', 'V0007'),
('THE0010', '51H-999.11', DATEADD(MINUTE, -(2 * 1440 + 500), GETDATE()), DATEADD(MINUTE, -(2 * 1440 + 100), GETDATE()), 'Q1_OT_02', 0, 'BAI_Q1', 'V0004'),
('THE0010', '51H-999.11', DATEADD(MINUTE, -(9 * 1440 + 480), GETDATE()), DATEADD(MINUTE, -(9 * 1440 + 60), GETDATE()), 'Q3_OT_02', 0, 'BAI_Q3', 'V0004'),
('THE0026', '51L-913.57', DATEADD(MINUTE, -(6 * 1440 + 300), GETDATE()), DATEADD(MINUTE, -(6 * 1440 + 60), GETDATE()), 'Q7_OT_02', 0, 'BAI_Q7', 'V0011'),
('THE0027', '51M-468.20', DATEADD(MINUTE, -(8 * 1440 + 360), GETDATE()), DATEADD(MINUTE, -(8 * 1440 + 30), GETDATE()), 'BT_OT_03', 0, 'BAI_BT', 'V0012');
```
