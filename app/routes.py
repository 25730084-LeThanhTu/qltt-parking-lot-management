import os
from pathlib import Path

from flask import Blueprint, flash, redirect, render_template, request, send_from_directory, url_for

from .db import execute_query, execute_script_return_sets, run_sql_file
from .queries import DEMO_CASES, REPORT_VIEWS, TABLES_TO_SHOW

bp = Blueprint("main", __name__)

REPORT_IMAGE_EXTENSIONS = (".png", ".jpg", ".jpeg", ".webp")


def get_reports_screenshots_dir():
    return Path(__file__).resolve().parents[1] / "reports_screenshots"


def find_report_screenshot(view_name):
    base_dir = get_reports_screenshots_dir()
    for ext in REPORT_IMAGE_EXTENSIONS:
        candidate = base_dir / f"{view_name}{ext}"
        if candidate.exists():
            return candidate.name
    return None


def build_report_items():
    items = []
    for view_name in REPORT_VIEWS:
        screenshot_filename = find_report_screenshot(view_name)
        items.append({
            "view_name": view_name,
            "expected_filename": f"{view_name}.png",
            "screenshot_filename": screenshot_filename,
        })
    return items


def make_result_set(name, rows, description=None):
    columns = list(rows[0].keys()) if rows else []
    return {"name": name, "description": description, "columns": columns, "rows": rows}


def apply_result_labels(result_sets, labels=None):
    labels = labels or []
    for index, result_set in enumerate(result_sets):
        if index < len(labels):
            label = labels[index]
            if isinstance(label, dict):
                result_set["name"] = label.get("name", result_set.get("name", f"Kết quả {index + 1}"))
                result_set["description"] = label.get("description")
            else:
                result_set["name"] = label
    return result_sets


@bp.route("/")
def index():
    overview = []
    try:
        overview = execute_query("""
            SELECT 
                (SELECT COUNT(*) FROM dbo.BAI_DO_XE) AS TongSoBai,
                (SELECT SUM(SucChua) FROM dbo.BAI_DO_XE) AS TongSucChua,
                (SELECT SUM(SoLuongHienTai) FROM dbo.BAI_DO_XE) AS TongXeDangDo,
                (SELECT COUNT(*) FROM dbo.VE_THANG WHERE TrangThai = N'Hoạt động') AS TongVeThangHoatDong;
        """)
    except Exception:
        overview = []
    return render_template("index.html", demo_cases=DEMO_CASES, reports=REPORT_VIEWS, overview=overview)


@bp.route("/health")
def health():
    try:
        rows = execute_query("SELECT DB_NAME() AS DatabaseName, GETDATE() AS ServerTime, @@VERSION AS SQLServerVersion;")
        return render_template("simple_result.html", title="Kiểm tra kết nối CSDL SQL Server", result_sets=[make_result_set("Kết nối thành công", rows)])
    except Exception as exc:
        return render_template("error.html", title="Không kết nối được SQL Server", error=str(exc))


@bp.route("/map")
def parking_map():
    selected_bai = request.args.get("bai", "BAI_Q1")
    bai_list = []
    slots = []
    bai_info = None
    error = None

    try:
        bai_list = execute_query("SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE ORDER BY MaBai;")
        if bai_list and not any(b["MaBai"] == selected_bai for b in bai_list):
            selected_bai = bai_list[0]["MaBai"]

        bai_info_rows = execute_query("SELECT * FROM dbo.vw_Report_CongSuatBaiDo WHERE MaBai = ?", (selected_bai,))
        if bai_info_rows:
            bai_info = bai_info_rows[0]

        slots = execute_query("""
            SELECT 
                vt.MaViTri, 
                vt.KhuVuc, 
                vt.TrangThai, 
                vt.MaLoaiXe, 
                lx.TenLoai,
                lg.BienSo,
                lg.ThoiGianVao,
                lg.MaThe
            FROM dbo.VI_TRI_DO vt
            INNER JOIN dbo.LOAI_XE lx ON vt.MaLoaiXe = lx.MaLoaiXe AND vt.MaBai = lx.MaBai
            LEFT JOIN dbo.LUOT_GUI lg ON vt.MaViTri = lg.MaViTri AND lg.ThoiGianRa IS NULL
            WHERE vt.MaBai = ?
            ORDER BY vt.KhuVuc, vt.MaViTri;
        """, (selected_bai,))
    except Exception as exc:
        error = str(exc)

    return render_template(
        "parking_map.html", 
        bai_list=bai_list, 
        selected_bai=selected_bai, 
        bai_info=bai_info, 
        slots=slots, 
        error=error
    )


@bp.route("/tables")
def tables():
    return render_template("tables.html", tables=TABLES_TO_SHOW)


@bp.route("/table/<table_name>")
def table_detail(table_name):
    if table_name not in TABLES_TO_SHOW:
        return render_template("error.html", title="Bảng không hợp lệ", error="Bảng không nằm trong danh mục hệ thống."), 400
    try:
        rows = execute_query(f"SELECT TOP 100 * FROM dbo.{table_name};")
        return render_template("simple_result.html", title=f"Dữ liệu bảng {table_name}", result_sets=[make_result_set(table_name, rows)])
    except Exception as exc:
        return render_template("error.html", title=f"Lỗi đọc bảng {table_name}", error=str(exc))


@bp.route("/reports")
def reports():
    return render_template("reports.html", reports=REPORT_VIEWS, report_items=build_report_items())


@bp.route("/report-image/<path:filename>")
def report_image(filename):
    return send_from_directory(get_reports_screenshots_dir(), filename)


@bp.route("/report/<view_name>")
def report_detail(view_name):
    if view_name not in REPORT_VIEWS:
        return render_template("error.html", title="Báo cáo không hợp lệ", error="View không nằm trong danh mục cho phép."), 400
    try:
        rows = execute_query(f"SELECT TOP 200 * FROM dbo.{view_name};")
        result_sets = [make_result_set(view_name, rows)]
        screenshot_filename = find_report_screenshot(view_name)
        return render_template(
            "report_detail.html",
            title=f"Báo cáo: {view_name}",
            view_name=view_name,
            expected_filename=f"{view_name}.png",
            screenshot_filename=screenshot_filename,
            result_sets=result_sets,
        )
    except Exception as exc:
        return render_template("error.html", title=f"Lỗi đọc báo cáo {view_name}", error=str(exc))


@bp.route("/demo/<case_key>", methods=["GET", "POST"])
def demo_case(case_key):
    case = DEMO_CASES.get(case_key)
    if not case:
        return render_template("error.html", title="Demo case không tồn tại", error="Không tìm thấy kịch bản demo."), 404

    before_sets = []
    execute_sets = []
    after_sets = []
    execution_error = None

    try:
        before_sets = execute_script_return_sets(case["before_sql"], commit=False)
        before_sets = apply_result_labels(before_sets, case.get("before_labels"))
    except Exception as exc:
        execution_error = f"Lỗi khi load dữ liệu trước thao tác: {exc}"

    if request.method == "POST":
        try:
            execute_sets = execute_script_return_sets(case["execute_sql"], commit=True)
            execute_sets = apply_result_labels(execute_sets, case.get("execute_labels"))
            flash("Đã thực thi câu lệnh SQL demo thành công.", "success")
        except Exception as exc:
            execution_error = str(exc)
            flash("Câu lệnh demo kích hoạt bẫy lỗi CSDL. Nếu đây là demo Trigger chặn vi phạm nghiệp vụ thì lỗi này là KẾT QUẢ MONG ĐỢI.", "error")

        try:
            after_sets = execute_script_return_sets(case["after_sql"], commit=False)
            after_sets = apply_result_labels(after_sets, case.get("after_labels"))
        except Exception as exc:
            if execution_error:
                execution_error += f"\nLỗi khi load dữ liệu sau thao tác: {exc}"
            else:
                execution_error = f"Lỗi khi load dữ liệu sau thao tác: {exc}"

    return render_template(
        "demo.html",
        case_key=case_key,
        case=case,
        before_sets=before_sets,
        execute_sets=execute_sets,
        after_sets=after_sets,
        execution_error=execution_error,
    )


@bp.route("/sql", methods=["GET", "POST"])
def sql_query():
    result_sets = []
    error = None
    sql = request.form.get("sql", "SELECT * FROM dbo.vw_Report_CongSuatBaiDo;")
    if request.method == "POST":
        try:
            result_sets = execute_script_return_sets(sql, commit=True)
        except Exception as exc:
            error = str(exc)
    return render_template("sql_query.html", sql=sql, result_sets=result_sets, error=error)


@bp.route("/setup", methods=["GET", "POST"])
def setup():
    allow = os.getenv("ALLOW_RUN_FULL_SCRIPT", "0") == "1"
    if request.method == "POST":
        if not allow:
            flash("Chức năng chạy nạp lại full script đang bị khóa. Hãy cấu hình ALLOW_RUN_FULL_SCRIPT=1 trong .env nếu muốn bật.", "error")
            return redirect(url_for("main.setup"))
        try:
            sql_file = Path(__file__).resolve().parents[1] / "sql" / "QL_BaiDoXe_FullScript.sql"
            count = run_sql_file(str(sql_file))
            flash(f"Đã khởi tạo và nạp thành công toàn bộ CSDL QuanLyBaiDoXe với {count} batch SQL!", "success")
            return redirect(url_for("main.health"))
        except Exception as exc:
            return render_template("error.html", title="Lỗi nạp full script CSDL", error=str(exc))
    return render_template("setup.html", allow=allow)
