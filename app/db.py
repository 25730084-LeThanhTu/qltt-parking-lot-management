import os
import re
from typing import Any, Dict, List, Tuple

import pyodbc
from dotenv import load_dotenv

load_dotenv()

# Tắt pooling của ODBC: SESSION_CONTEXT read-only được mang sang lần mở kết nối kế tiếp trên kết nối pooled
# (đã kiểm chứng trên SQL Server 2022). Phải đặt trước khi mở kết nối đầu tiên.
pyodbc.pooling = False


def get_connection(database: str | None = None, autocommit: bool = False, timeout: int = 5, credentials=None):
    driver = os.getenv("SQLSERVER_DRIVER", "ODBC Driver 17 for SQL Server")
    server = os.getenv("SQLSERVER_SERVER", "localhost")
    db_name = database or os.getenv("SQLSERVER_DATABASE", "QuanLyBaiDoXe")
    trusted = credentials is None and os.getenv("SQLSERVER_TRUSTED_CONNECTION", "yes").lower() in {"yes", "true", "1"}

    parts = [f"DRIVER={{{driver}}}", f"SERVER={server}", f"DATABASE={db_name}"]
    if trusted:
        parts.append("Trusted_Connection=yes")
        parts.append("TrustServerCertificate=yes")
    else:
        username, password = credentials or (os.getenv("SQLSERVER_USERNAME", "sa"), os.getenv("SQLSERVER_PASSWORD", ""))
        parts.append(f"UID={username}")
        parts.append(f"PWD={password}")
        parts.append("TrustServerCertificate=yes")

    conn_str = ";".join(parts) + ";"
    return pyodbc.connect(conn_str, autocommit=autocommit, timeout=timeout)


def get_kh_connection(ma_tk: str | None = None, ma_kh: str | None = None):
    """Kết nối demo: dùng login chính, autocommit để nhật ký đăng nhập sai được lưu khi thủ tục THROW.

    Đã đăng nhập thì đặt SESSION_CONTEXT MaTK / MaKH ở chế độ read-only cho cả phiên kết nối
    (các procedure sp_KH_* sử dụng SESSION_CONTEXT để biết khách hàng nào đang truy cập).
    """
    conn = get_connection(autocommit=True)
    if ma_tk:
        cursor = conn.cursor()
        cursor.execute(
            "EXEC sys.sp_set_session_context @key = N'MaTK', @value = ?, @read_only = 1;"
            "EXEC sys.sp_set_session_context @key = N'MaKH', @value = ?, @read_only = 1;",
            (ma_tk, ma_kh),
        )
    return conn


def rows_to_dicts(cursor) -> List[Dict[str, Any]]:
    if not cursor.description:
        return []
    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    return [dict(zip(columns, row)) for row in rows]


def execute_query(sql: str, params: Tuple[Any, ...] = (), commit: bool = False) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        data = rows_to_dicts(cursor)
        if commit:
            conn.commit()
        return data


def execute_script_return_sets(sql: str, params: Tuple[Any, ...] = (), commit: bool = True) -> List[Dict[str, Any]]:
    """Chạy câu lệnh hoặc batch SQL và lấy tất cả result sets trả về."""
    result_sets: List[Dict[str, Any]] = []
    with get_connection() as conn:
        cursor = conn.cursor()
        try:
            cursor.execute(sql, params)
            index = 1
            while True:
                if cursor.description:
                    columns = [col[0] for col in cursor.description]
                    rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
                    result_sets.append({"name": f"Result set {index}", "columns": columns, "rows": rows})
                    index += 1
                if not cursor.nextset():
                    break
            if commit:
                conn.commit()
        except Exception:
            conn.rollback()
            raise
    return result_sets


def split_sql_by_go(sql_text: str) -> List[str]:
    parts = re.split(r"^\s*GO\s*$", sql_text, flags=re.IGNORECASE | re.MULTILINE)
    return [part.strip() for part in parts if part.strip()]


def run_sql_file(path: str):
    """Chạy file SQL lớn có phân tách GO. Kết nối tới database master ban đầu với autocommit=True để cho phép CREATE DATABASE."""
    with open(path, "r", encoding="utf-8-sig") as f:
        content = f.read()
    batches = split_sql_by_go(content)
    with get_connection(database="master", autocommit=True) as conn:
        cursor = conn.cursor()
        for batch in batches:
            cursor.execute(batch)
            while cursor.nextset():
                pass
    return len(batches)
