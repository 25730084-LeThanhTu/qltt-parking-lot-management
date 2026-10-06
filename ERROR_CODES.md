# 🔴 ERROR CODES MAPPING

**Phiên Bản:** V6 + V7 | **Cập Nhật:** 2026-10-06

---

## 📌 QUY ƯỚC MÃ LỖI

| Dải | Phiên Bản | Mục Đích |
|-----|-----------|---------|
| 50000-50029 | V6 | Bãi xe, thẻ, vé |
| 50030-50069 | V7 | Cổng khách hàng (tránh trùng V6) |
| 50070+ | Reserved | Mở rộng tương lai |

---

## 📋 V6 ERROR CODES

| Code | Procedure | Mô Tả |
|------|-----------|-------|
| 50007 | sp_XeVaoBai | Thẻ xe không tồn tại |
| 50008 | sp_GiaHanTheThang | Bãi không hợp lệ |
| 50010 | sp_XeVaoBai | Không còn ô đỗ trống |
| 50012 | sp_GiaHanTheThang | Vé tháng không tồn tại |
| 50013 | sp_BaoMatThe | Mã thẻ không tồn tại |
| 50017 | sp_GiaHanTheThang | Loại xe chưa có biểu phí |
| 50018 | sp_GiaHanTheThang | Vé gắn bãi, sai bãi |
| 50019 | sp_GiaHanTheThang | Thẻ đã báo mất |

---

## 📋 V7 ERROR CODES (50030-50069)

| Code | Procedure | Mô Tả | Category |
|------|-----------|-------|----------|
| 50031 | trg_GiaoDich | Số dư ví không đủ / âm | VALIDATION |
| 50033 | sp_KH_GiaHanBangVi | Ví đóng băng | LOGIC |
| 50035 | sp_DangKyThanhVien | PTTT không hợp lệ | LOGIC |
| 50040 | sp_KH_DangNhap | Tên/mật khẩu sai | SECURITY |
| 50041 | sp_KH_DangNhap | Tài khoản bị khóa | SECURITY |
| 50042 | sp_KH_* | Chưa đăng nhập | SECURITY |
| 50043 | sp_KH_DangNhap | Tài khoản đã đóng | SECURITY |
| 50045 | sp_KH_GiaHanBangVi | Số tháng không hợp lệ | VALIDATION |
| 50046 | sp_KH_GiaHanBangVi | Lệch giá ví/HD | DATA INTEGRITY |
| 50047 | sp_KH_UyQuyenVe | Không tìm người nhận | LOGIC |
| 50048 | sp_KH_UyQuyenVe | Vai trò sai | VALIDATION |
| 50049 | sp_KH_UyQuyenVe | Vé đã chia cho account | LOGIC |
| 50050 | sp_KH_* | Không có quyền | SECURITY |
| 50051 | sp_KH_UyQuyenVe | Chia cho chính chủ | LOGIC |
| 50053 | sp_KH_UyQuyenVe | Chia cho quá 3 account | BUSINESS |
| 50054 | sp_KH_UyQuyenVe | Vé hết hạn, không chia | BUSINESS |
| 50057 | sp_KH_DangNhap | TK không liên kết KH | DATA INTEGRITY |
| 50059 | sp_GiaHan* | Vé ALL, sai bãi | BUSINESS |
| 50060 | sp_GiaHan/trg_GiaoDich | Số tháng / Xóa GD | VALIDATION |
| 50061 | trg_GiaoDich_BatBien | Không được đổi mã GD | DATA INTEGRITY |
| 50064 | sp_GiaHanVe_Core | ViDienTu không kèm | LOGIC |

---

## ✅ FIX LOG

- [x] Vấn đề 10 FIXED: Tất cả V7 codes trong 50030-50069 (không trùng V6)
- [x] Tài liệu đầy đủ cho team mapping

**Note:** Document này để reference, developers map với front-end messages.
