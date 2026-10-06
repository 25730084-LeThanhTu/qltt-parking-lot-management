# 🔄 MIGRATION PLAN: V6 + V7 MERGE

**Mục Đích:** Hợp nhất V6 (01_-09_) + V7 (10_-17_) → Single integrated schema  
**Ngày:** 2026-10-06 | **Trạng Thái:** Planning Phase

---

## 📋 FILE MAPPING

| V7 File | Size | Merge vào | Loại |
|---------|------|-----------|------|
| 10_upgrade_schema_khachhang.sql | 11K | 01_schema.sql | ADD |
| 11_upgrade_sample_data.sql | 18K | 02_sample_data.sql | APPEND |
| 12_upgrade_functions.sql | 17K | 05_functions.sql | ADD |
| 13_upgrade_procedures.sql | 54K | 03_procedures.sql | ADD+MERGE |
| 14_upgrade_triggers.sql | 20K | 04_triggers.sql | ADD+MERGE |
| 15_upgrade_cursors.sql | 10K | 06_cursors.sql | ADD |
| 16_upgrade_views.sql | 19K | 07_views.sql | ADD |
| 17_upgrade_security_khachhang.sql | 11K | 08_security_rbac.sql | MERGE |

---

## 🔍 KEY MERGE POINTS

### 01_schema.sql (CRITICAL)
- Add 8 bảng V7: TAI_KHOAN_KH, VI_DIEN_TU, GIAO_DICH, UY_QUYEN_VE, VAI_TRO_KH, VAI_TRO_QUYEN, THONG_BAO, NHAT_KY_DANG_NHAP
- Add sequence: seq_GiaoDich
- **Xung đột:** Dependency order, FK linking bảng V6 ↔ V7

### 03_procedures.sql (CRITICAL)
- Merge edits: sp_GiaHanTheThang (lỗi 50059, 50060), sp_DangKyThanhVien (lỗi 50059), sp_XeVaoBai (lỗi 5, 6)
- Add 13 procedure V7: sp_GiaHanVe_Core, sp_SinhMaGiaoDich, 10 sp_KH_*, 3 sp_NV_*
- **Xung đột:** Procedure lồng nhau, gọi V6 procedures

### 04_triggers.sql (IMPORTANT)
- Merge edits: trg_GiaoDich_CapNhatSoDu (safeguard)
- Add trigger mới: trg_VeThang_CapNhatTrangThai (state machine)
- Add 8 trigger V7: giao dịch, ví, khách hàng
- **Xung đột:** Trigger nesting, recursion

### 08_security_rbac.sql (IMPORTANT)
- Thêm role: r_KhachHang, r_Admin, r_QuanLyBai
- GRANT procedure V7
- GRANT view V7
- RLS policies cho ví, giao dịch
- **Xung đột:** Role naming, permission hierarchy

---

## 🛠️ IMPLEMENTATION PHASES

### Phase 1: Schema Analysis & Merge (4h)
- [ ] Phân tích dependency graph từ 10_upgrade_schema_khachhang.sql
- [ ] Xác định thứ tự CREATE TABLE (parent → child)
- [ ] Merge V6 + V7 schemas vào 01_schema_merged.sql
- [ ] Validate FK constraints

### Phase 2: Sample Data Merge (1h)
- [ ] Merge INSERT từ 11_upgrade_sample_data.sql
- [ ] Đảm bảo thứ tự (master tables → detail tables)
- [ ] Validate referential integrity

### Phase 3: Procedures Merge (6h) - LARGEST
- [ ] Merge edits từ 03_procedures.sql (lỗi 50059, 50060) vào v7 procedure
- [ ] Merge edits từ sp_XeVaoBai (lỗi 5, 6) vào v7
- [ ] Add sp_SinhMaGiaoDich, sp_GiaHanVe_Core (lõi)
- [ ] Add 10 sp_KH_* (khách hàng)
- [ ] Add 3 sp_NV_* (nhân viên)

### Phase 4: Triggers Merge (2h)
- [ ] Merge edits từ trg_GiaoDich_CapNhatSoDu (safeguard)
- [ ] Add trg_VeThang_CapNhatTrangThai (state machine)
- [ ] Add 7 trigger V7 (giao dịch, ví, khách hàng)
- [ ] Validate trigger order, nesting

### Phase 5-8: Functions, Cursors, Views, Security (5h)
- [ ] Phase 5: Append functions từ 12_
- [ ] Phase 6: Append cursors từ 15_
- [ ] Phase 7: Append views từ 16_
- [ ] Phase 8: Merge security từ 17_

### Phase 9: Integration & Testing (1h)
- [ ] Regenerate QL_BaiDoXe_FullScript.sql từ merged files
- [ ] Validate syntax (GO batches, object counts)
- [ ] Backup old 01_-09_ → 01_v6_backup_*
- [ ] Replace với merged versions

---

## ⚠️ CRITICAL DEPENDENCIES

```
KHACH_HANG (V6)
  ↓ MaKH
  ├─→ TAI_KHOAN_KH (V7)
  ├─→ VI_DIEN_TU (V7)
  └─→ VE_THANG (V6)
       ↓ MaVe
       ├─→ UY_QUYEN_VE (V7)
       └─→ GIAO_DICH (V7) [via VI_DIEN_TU]

VI_DIEN_TU (V7)
  ↓ MaVi
  └─→ GIAO_DICH (V7)
       ↓ MaGD, MaVi
       └─→ Trigger: trg_GiaoDich_CapNhatSoDu

seq_GiaoDich → GIAO_DICH.MaGD (CREATE BEFORE sp_SinhMaGiaoDich)
```

---

## 🎯 EDITS TO MERGE

**From 03_procedures.sql edits:**
- sp_GiaHanTheThang: +lỗi 50059, 50060 validation (dòng ~269-275)
- sp_DangKyThanhVien: +lỗi 50059 validation (dòng ~274-282)
- sp_XeVaoBai: +loại xe query từ THE_XE, +MaVe ghi (dòng ~46-54)

**From 14_upgrade_triggers.sql edits:**
- trg_GiaoDich_CapNhatSoDu: +safeguard check SoDu >= 0 (dòng ~78-89)
- trg_VeThang_CapNhatTrangThai: NEW trigger state machine

---

## 📊 EFFORT ESTIMATE

| Phase | Effort | Status |
|-------|--------|--------|
| 1. Schema | 4h | Pending |
| 2. Data | 1h | Pending |
| 3. Procedures | 6h | Pending |
| 4. Triggers | 2h | Pending |
| 5-8. Other | 5h | Pending |
| 9. Integration | 1h | Pending |
| **TOTAL** | **19h** | ~2.5 ngày |

---

## ✅ SUCCESS CRITERIA

- [ ] Merged files syntax valid
- [ ] All dependencies resolved
- [ ] All 11 fixes preserved
- [ ] QL_BaiDoXe_FullScript.sql regenerate OK
- [ ] No duplicate objects
- [ ] Object counts match expected

**Bạn muốn bắt đầu Phase nào?**
