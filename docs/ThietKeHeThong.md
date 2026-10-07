# 🏗️ THIẾT KẾ HỆ THỐNG QUẢN LÝ CHUỖI BÃI ĐỖ XE

> **Dự án:** Hệ thống quản lý chuỗi nhiều bãi đỗ xe thông minh + cổng khách hàng vé tháng  
> **Công nghệ:** Microsoft SQL Server 2022 + Python Flask + Web UI (Nhân viên + Khách hàng)  
> **Quy mô:** 21 bảng · 37 views · 23 stored procedures + 4 cursor · 16 triggers · 12 functions · 4 roles RBAC + Row-Level Security

---

## 🗄️ PHẦN I: THIẾT KẾ CƠ SỞ DỮ LIỆU VẬT LÝ HOÀN CHỈNH

### I.1 Kiến trúc theo phân hệ

**Vận hành bãi (7 bảng):** BAI_DO_XE, LOAI_XE, VI_TRI_DO, THE_XE, LUOT_GUI, NHAN_VIEN, TAI_KHOAN

**Vé tháng & khách (4 bảng):** KHACH_HANG, VE_THANG, HOA_DON_VE_THANG, LICHSU_SU_CO

**Cổng khách - Thanh toán (6 bảng):** TAI_KHOAN_KH, NHAT_KY_DANG_NHAP, VI_DIEN_TU, GIAO_DICH, PHUONG_THUC_THANH_TOAN, UY_QUYEN_VE

**Quản lý (2 bảng):** THONG_BAO, QUYEN_KH

### I.2 Chuẩn hóa & bảo vệ dữ liệu

- **N.1-N.3:** Ô đỗ, công suất bãi, thẻ lượt → Constraint + Trigger
- **N.4:** Thẻ cấp lại (N4) → Index lọc `UX_VeThang_MaThe_ConDung WHERE TrangThai <> 'Hết hạn'` + hàm `f_VeHienHanhCuaThe`
- **N.5:** Mật khẩu an toàn → SHA2_512(salt + password), salt 16 byte random
- **N.6:** Số dư ví ≥ 0 → Trigger chặn + CHECK constraint
- **N.7-N.8:** Vé tháng bãi, hết hạn → Trigger xét vé hiện hành

### I.3 Index tối ưu

```sql
-- Check-in nhanh: thẻ × ô × bãi
CREATE INDEX IX_LUOT_GUI_DangDo ON dbo.LUOT_GUI (MaBai, MaViTri) 
  INCLUDE (MaThe, BienSo, ThoiGianVao) WHERE ThoiGianRa IS NULL;

-- Quét hạn vé
CREATE INDEX IX_VeThang_TrangThai_NgayHetHan ON dbo.VE_THANG (TrangThai, NgayHetHan)
  INCLUDE (MaThe, MaKH, BienSo);

-- N.4 - Filtered Unique
CREATE UNIQUE INDEX UX_VeThang_MaThe_ConDung ON dbo.VE_THANG (MaThe) 
  WHERE TrangThai <> N'Hết hạn';
```

---

## 🔒 PHẦN II: AN TOÀN THÔNG TIN, PHÂN QUYỀN & QUẢN TRỊ CSDL

### II.1 RBAC - 4 vai trò

| Vai trò | Bảng | Procedures | Scope |
|---|---|---|---|
| **r_Admin** | GRANT CONTROL | Toàn bộ | Toàn DB |
| **r_QuanLyBai** | SELECT, INSERT, UPDATE trên 7 bảng vận hành + vé | sp_DangKyThanhVien, sp_GiaHanTheThang, sp_BaoMatThe | Mỗi bãi |
| **r_BaoVe** | DENY UPDATE, DELETE LUOT_GUI + HOA_DON | Chỉ sp_XeVaoBai, sp_XeRaBai | Mỗi bãi |
| **r_KhachHang** | DENY toàn bộ bảng gốc | EXECUTE sp_KH_* (10 thủ tục) | Cá nhân (RLS) |

### II.2 Row-Level Security - 3 lớp bảo vệ

1. **RBAC:** Role `r_KhachHang` bị DENY `SELECT, INSERT, UPDATE, DELETE` trên bảng gốc
2. **RLS Policy:** `bao_mat.rls_KhachHang` lọc 7 bảng theo `SESSION_CONTEXT('MaKH')`
3. **Procedure:** Chỉ EXECUTE sp_KH_*, không SELECT thẳn

### II.3 Sổ cái bất biến (Ledger Pattern)

**Nguyên tắc:** Chỉ ghi thêm, không sửa tiền/xóa

```
GIAO_DICH:
├─ INSERT: Trạng thái "Chờ xử lý", số dư chưa đổi
├─ UPDATE: Chỉ trạng thái + ghi SoDuTruoc/Sau lần đầu
└─ Trigger chặn: sửa tiền (50061), xóa (50060), UPDATE trực tiếp ví (50062)

VI_DIEN_TU:
└─ Trigger cập nhật khi giao dịch → Thành công (trg_GiaoDich_CapNhatSoDu)
```

### II.4 Bảo vệ brute force & idempotency

- **Khóa tài khoản:** 5 lần sai → khóa 15 phút (trigger)
- **Nạp tiền lặp:** Lock dòng + kiểm tra mã tham chiếu (idempotent)
- **Dò tên khách:** Cùng lỗi 50040 cho sai tên / sai mật khẩu

---

## 👁️ PHẦN III: HỆ THỐNG BẢNG ẢO GIÁM SÁT REALTIME & BÁO CÁO BI

### III.1 Phân loại 37 Views

| Nhóm | Tên | Dùng ở đâu | Điểm chính |
|---|---|---|---|
| **Vận hành (3)** | v_SodoOdoRealtime, v_Xedangtrongbai, v_DanhsachveThangsaphethan | Sơ đồ, quản lý | Realtime từ LUOT_GUI |
| **BI (5)** | vw_Report_CongSuat, vw_Report_DoanhThuTheoBai, ... | Dashboard quản lý | Tính toán + tích lũy |
| **Bốt cổng (4)** | v_BotCong_TraCuuThe, v_BotCong_XeChoRa, ... | Quẹt thẻ, barrier | `OUTER APPLY f_VeHienHanhCuaThe` (N.4) |
| **Sơ đồ (3)** | v_SodoBai_ODoChiTiet, v_SodoBai_TongHopKhuVuc | Map mặt bằng | `OUTER APPLY TOP 1` (tránh nhân dòng) |
| **Tổng hợp (6)** | v_TongQuanChuoi, v_ThongKeVeThang, ... | KPI chuỗi | Khối count, sum |
| **Khách hàng (7)** | vw_KH_LichSuGiaoDich, vw_KH_VeThangCuaKhach, ... | `/kh` cổng | **RLS Filter** trên mỗi view |
| **Nhân viên (4)** | v_NhanVienToanChuoi, v_TaiKhoanNhanVien, ... | Quản lý nhân sự | Không lọc (nhân viên xem toàn bộ) |

### III.2 Kỹ thuật thiết kế

**CTE + OUTER APPLY (tránh nhân dòng vé cũ):**
```sql
OUTER APPLY dbo.f_VeHienHanhCuaThe(t.MaThe) vt  -- 1 dòng/thẻ
```

**UNION ALL (nhật ký vào/ra từ 1 lượt):**
```sql
SELECT ..., N'Vào' ChieuDiChuyen, lg.ThoiGianVao ...
UNION ALL
SELECT ..., N'Ra' ChieuDiChuyen, lg.ThoiGianRa ... WHERE ThoiGianRa IS NOT NULL
```

**RLS trên View khách:**
```sql
CREATE VIEW vw_KH_LichSuGiaoDich AS
SELECT ... FROM GIAO_DICH 
WHERE MaKH = SESSION_CONTEXT('MaKH')  -- Filter tự động khi query
```

---

## ⚙️ PHẦN IV: PROCEDURES, TRIGGERS, FUNCTIONS & CURSORS

### IV.1 Stored Procedures (23)

**Vận hành (6):** sp_XeVaoBai, sp_XeRaBai, sp_DangKyThanhVien, sp_GiaHanTheThang, sp_BaoMatThe, sp_DangNhap

**Khách hàng (10):** sp_KH_DangKyTaiKhoan, sp_KH_DangNhap, sp_KH_DoiMatKhau, sp_KH_NapTien_KhoiTao/XacNhan, sp_KH_GiaHanBangVi, sp_KH_UyQuyenVe, sp_KH_ThuHoiUyQuyen, sp_KH_DuyetLichSu

**Quản trị & tự động (7):** sp_GiaHanVe_Core (lõi), sp_DemoCanhBao, sp_DemoTongKet, sp_DemoTuDongGiaHan, sp_DemoDoiSoat, sp_NV_HoanTien, sp_NV_MoKhoaTaiKhoan

### IV.2 Triggers (16)

**Check-in (4):** trg_KiemTraCheckIn, trg_ChanSuDungVeHetHan, trg_KiemTraBaiApDung, trg_DongBoTrangThaiSlot

**Vé (2):** trg_KiemTraLoaiXe_VeThang, trg_ChanXoaDuLieu

**Sự cố (1):** trg_LogLichSuSuCo (tự ghi LICHSU_SU_CO + tiền phạt)

**Sổ cái (4):** trg_GiaoDich_CapNhatSoDu, trg_GiaoDich_BatBien, trg_GiaoDich_ChanXoa, trg_ViDienTu_ChanSuaTrucTiep

**Cổng khách (3):** trg_NhatKyDangNhap_KhoaTaiKhoan, trg_UyQuyen_KiemTra, trg_ThongBao_TuDongGiaHan

### IV.3 Functions (12)

**Vận hành (3):** f_TinhTienGuiXe (tính phí block), f_TimSlotTrong (ô trống), f_DanhSachXeTrongBai (TABLE)

**Xác thực (1):** f_BamMatKhau (SHA2_512 + salt)

**N.4 (1):** f_VeHienHanhCuaThe (vé hiện hành → tất cả trigger/view dùng)

**Cổng khách (7):** f_KH_TinhPhiGiaHan, f_KH_CoQuyen, f_KH_MaTKPhien, f_KH_MatKhauHopLe, f_KH_TongNapTrongNgay, f_KH_SaoKeVi, fn_rls_KhachHang

### IV.4 Cursors (4)

| Cursor | Duyệt | Xử lý | Savepoint |
|---|---|---|---|
| sp_DemoCanhBao | VE_THANG | Chuyển hạn, cảnh báo | Chung |
| sp_DemoTongKet | BAI_DO_XE | Cộng doanh thu, xếp hạng | Chung |
| **sp_DemoTuDongGiaHan** | VE_THANG (auto flag) | **Mỗi vé riêng savepoint** | **ROLLBACK riêng vế thiếu** |
| sp_DemoDoiSoat | VI_DIEN_TU | So sánh vs GIAO_DICH | Chung |

### IV.5 Lỗi chủ chốt (Error Codes)

| Mã | Trigger / Procedure | Ý nghĩa |
|---|---|---|
| 50001-50002 | trg_KiemTraCheckIn | Bãi đầy, thẻ mất |
| 50003 | trg_ChanSuDungVeHetHan | Vé tháng hết hạn |
| 50004 | trg_KiemTraBaiApDung | Vé gửi sai bãi |
| 50031 | trg_GiaoDich_CapNhatSoDu | Số dư không đủ |
| 50040-50041 | sp_KH_DangNhap | Sai mật khẩu, tài khoản khóa |
| 50050 | f_KH_CoQuyen | Không quyền gia hạn vé ủy quyền |
| 50060-50062 | trg_GiaoDich_* | Xóa/sửa/cộng trực tiếp sổ cái |
| 50065-50066 | sp_DangKyThanhVien | Thẻ gắn vé đang dùng / vé cũ của thẻ cấp lại |

---

## 📊 KỲ VỌNG & CHỈ SỐ

| Chỉ số | Mục tiêu | Giải pháp |
|---|---|---|
| **Check-in 1000 xe/h** | 5 bãi × 200 xe/h | Index `IX_LuotGui_DangDo` |
| **Bốt cổng < 100ms** | Realtime | Indexed view `v_BotCong_TraCuuThe` |
| **Nạp tiền idempotent** | Lặp callback 1 lần | Lock + mã tham chiếu |
| **Sổ cái 100% đúng** | Không lỗi toán học | 3 lớp trigger + ràng buộc |
| **Backup hourly** | RPO 1h, RTO 15 phút | S3 + restore procedure |

---

## 🎯 KẾT LUẬN

✅ Tính toàn vẹn cao (3 lớp trigger + constraint)  
✅ Bảo mật nhiều lớp (RBAC + RLS + Session context)  
✅ Hiệu suất tối ưu (Index lọc + cursor savepoint)  
✅ Mở rộng dễ dàng (Phân hệ rõ ràng)  
✅ Bảo trì đơn giản (Trigger tự động + view tập trung)
