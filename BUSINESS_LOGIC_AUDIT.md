# 🔍 AUDIT LOGIC NGHIỆP VỤ - HỆ THỐNG QUẢN LÝ BÃI ĐỖ XE

**Ngày Audit:** 2026-10-06 | **Phiên Bản:** V6 + V7 | **Trạng Thái:** 11 vấn đề, 3 CRITICAL/HIGH

---

## 📊 DANH SÁCH VẤN ĐỀ

### 🔴 CRITICAL (Ngày 1)

**Vấn Đề 1: SoThangGiaHan Hiển Thị Sai Format Tiền Tệ**
- **Vị Trí:** `_result_table.html` rule N11
- **Mô Tả:** Cột TINYINT (số tháng) format như tiền tệ → "0,03 ₫" thay "3 tháng"
- **Fix:** Phân biệt loại dữ liệu trong template

---

### 🔴 HIGH (Tuần 1)

**Vấn Đề 2: Vé Hết Hạn Vẫn Được Chia Sẻ (50054 Missing)**
- **Vị Trí:** `sp_KH_UyQuyenVe` - chưa check NgayHetHan
- **Fix:** Kiểm tra `NgayHetHan > GETDATE()` trước tạo UY_QUYEN_VE

**Vấn Đề 3: Bãi Tính Giá Vé ALL - Quy Tắc Mâu Thuẫn**
- **Vị Trí:** `sp_GiaHanTheThang`, `sp_DangKyThanhVien`
- **Vấn Đề:** Quầy có thể chọn bãi khác → Doanh thu ghi sai bãi
- **Fix:** Khóa vé ALL chỉ gia hạn tại bãi phát hành

---

### 🟡 MEDIUM (Tuần 1-2)

| Vấn Đề | Vị Trí | Fix |
|--------|--------|-----|
| 4. sp_GiaHanVe_Core Missing | UPGRADE_PLAN 5.3 | Tạo procedure core + sp_KH_GiaHanBangVi |
| 5. Loại Xe Default | sp_XeVaoBai | Query THE_XE.MaLoaiXe trước default |
| 6. LUOT_GUI.MaVe NULL | sp_XeVaoBai | Cập nhật MaVe sau INSERT |
| 7. SoDu Âm Risk | trigger trg_GiaoDich | Check trước update SoDu |
| 8. MaTK ↔ MaKH Verify | sp_KH_DangNhap | Xác thực tài khoản thuộc khách |
| 9. State Machine Unclear | sp_GiaHanTheThang | Thêm trạng thái trung gian |

---

### 🟢 LOW (Tuần 2+)

| Vấn Đề | Fix |
|--------|-----|
| 10. Mã Lỗi 50007 Trùng | Rename theo D10 (50030-50069) |
| 11. Validation SoThang | Check 1 ≤ SoThang ≤ 12 |

---

## ✅ XỬ LÝ TỪNG VẤN ĐỀ

### 🔴 CRITICAL
- **Vấn Đề 1:** ✅ **FIXED** - `app/__init__.py` dòng 48: Thêm "giahan" vào NON_MONEY_PREFIXES
  - SoThangGiaHan không còn format như tiền

### 🔴 HIGH
- **Vấn Đề 2:** ✅ **Đã có trong code** - `sp_KH_UyQuyenVe` dòng 942-945 kiểm tra NgayHetHan
- **Vấn Đề 3:** ✅ **FIXED** (2 procedure):
  - `sql/03_procedures.sql` dòng 307-310: Thêm check vé ALL, lỗi 50059
  - `sql/13_upgrade_procedures.sql` dòng 274-282: Thêm check đăng ký vé ALL

### 🟡 MEDIUM  
- **Vấn Đề 5:** ✅ **FIXED** - `sql/13_upgrade_procedures.sql`: Query THE_XE nếu vé không hoạt động
- **Vấn Đề 6:** ✅ **FIXED** - `sql/03_procedures.sql`: Thêm MaVe vào INSERT LUOT_GUI

### ⏳ CẦN KỲ TIẾP THEO
- Vấn Đề 4, 7, 8, 9, 10, 11 (chi tiết ở DANH SÁCH VẤN ĐỀ)

**Note:** Cần regenerate `QL_BaiDoXe_FullScript.sql` để đồng bộ fixes
