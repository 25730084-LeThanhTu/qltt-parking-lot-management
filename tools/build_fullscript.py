"""Sinh lại sql/QL_BaiDoXe_FullScript.sql bằng cách ghép các module SQL theo đúng thứ tự phụ thuộc.

Cách dùng (từ thư mục gốc dự án):
    python tools/build_fullscript.py           # ghi đè sql/QL_BaiDoXe_FullScript.sql
    python tools/build_fullscript.py --check   # chỉ kiểm tra file hiện tại có khớp các module không

Không sửa tay QL_BaiDoXe_FullScript.sql: sửa module tương ứng rồi chạy lại script này.
09_backup_restore.sql không nằm trong full script (kịch bản sao lưu chạy riêng khi cần).
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = ROOT / "sql"
OUTPUT = SQL_DIR / "QL_BaiDoXe_FullScript.sql"

# Thứ tự chạy: bảng -> dữ liệu -> functions -> triggers -> procedures -> cursors -> views -> phân quyền.
# Mỗi module gồm phần vận hành bãi rồi phần cổng khách hàng phía sau.
MODULES = [
    ("01_schema.sql", "21 BẢNG, SEQUENCE, DANH MỤC TRA CỨU"),
    ("02_sample_data.sql", "DỮ LIỆU MẪU"),
    ("05_functions.sql", "FUNCTIONS"),
    ("04_triggers.sql", "TRIGGERS"),
    ("03_procedures.sql", "STORED PROCEDURES"),
    ("06_cursors.sql", "CURSORS"),
    ("07_views.sql", "VIEWS"),
    ("08_security_rbac.sql", "PHÂN QUYỀN RBAC, ROLE r_KhachHang, ROW-LEVEL SECURITY"),
]

SEPARATOR = "-- " + "=" * 84

HEADER = f"""{SEPARATOR}
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- KỊCH BẢN ĐỒNG BỘ TOÀN DIỆN (FULL AUTOMATED SCRIPT: 21 BẢNG, PROCEDURES, TRIGGERS, VIEWS, RBAC, RLS)
-- FILE SINH TỰ ĐỘNG BỞI tools/build_fullscript.py TỪ CÁC MODULE TRONG sql/. KHÔNG SỬA TAY.
{SEPARATOR}

USE master;
GO

IF DB_ID('QuanLyBaiDoXe') IS NOT NULL
BEGIN
    ALTER DATABASE QuanLyBaiDoXe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyBaiDoXe;
END;
GO

CREATE DATABASE QuanLyBaiDoXe;
GO

USE QuanLyBaiDoXe;
GO
"""


def ends_with_go(text: str) -> bool:
    lines = [line.strip() for line in text.strip().splitlines() if line.strip()]
    return bool(lines) and lines[-1].upper() == "GO"


def build() -> str:
    chunks = [HEADER]
    for filename, label in MODULES:
        path = SQL_DIR / filename
        if not path.exists():
            raise FileNotFoundError(f"Thiếu module {path}")
        body = path.read_text(encoding="utf-8-sig").strip()
        if not ends_with_go(body):
            # Batch cuối của module phải kết thúc bằng GO để không dính vào module tiếp theo
            # (CREATE VIEW / PROCEDURE bắt buộc là lệnh duy nhất trong batch).
            body += "\nGO"
        chunks.append(f"\n\n-- {'=' * 20} BẮT ĐẦU: {filename} ({label}) {'=' * 20}\n{body}\n")
    return "".join(chunks)


def main() -> int:
    content = build()
    if "--check" in sys.argv:
        current = OUTPUT.read_text(encoding="utf-8-sig") if OUTPUT.exists() else ""
        if current == content:
            print("OK: QL_BaiDoXe_FullScript.sql khớp với các module.")
            return 0
        print("LỆCH: QL_BaiDoXe_FullScript.sql chưa được sinh lại từ các module.")
        return 1
    OUTPUT.write_text(content, encoding="utf-8")
    print(f"Đã ghi {OUTPUT.relative_to(ROOT)} ({content.count(chr(10))} dòng, {len(MODULES)} module).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
