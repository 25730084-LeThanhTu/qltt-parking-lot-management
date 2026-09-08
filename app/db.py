import os
import re
from typing import Any, Dict, List, Tuple

import pyodbc
from dotenv import load_dotenv

load_dotenv()


def get_connection(database: str | None = None, autocommit: bool = False):
    driver = os.getenv("SQLSERVER_DRIVER", "ODBC Driver 17 for SQL Server")
    server = os.getenv("SQLSERVER_SERVER", "localhost")
    db_name = database or os.getenv("SQLSERVER_DATABASE", "QuanLyBaiDoXe")
    trusted = os.getenv("SQLSERVER_TRUSTED_CONNECTION", "yes").lower() in {"yes", "true", "1"}

    parts = [f"DRIVER={{{driver}}}", f"SERVER={server}", f"DATABASE={db_name}"]
    if trusted:
        parts.append("Trusted_Connection=yes")
        parts.append("TrustServerCertificate=yes")
    else:
        username = os.getenv("SQLSERVER_USERNAME", "sa")
        password = os.getenv("SQLSERVER_PASSWORD", "")
        parts.append(f"UID={username}")
        parts.append(f"PWD={password}")
        parts.append("TrustServerCertificate=yes")

    conn_str = ";".join(parts) + ";"
    return pyodbc.connect(conn_str, autocommit=autocommit)


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
