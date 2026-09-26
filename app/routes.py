import os
from pathlib import Path

from flask import Blueprint, flash, redirect, render_template, request, send_from_directory, url_for

from .db import execute_query, execute_script_return_sets, get_connection, run_sql_file
from .queries import (
    ALL_VIEWS,
    DEMO_CASES,
    DEMO_GROUPS,
    GATE_VIEWS,
    MAP_VIEWS,
    OPERATION_VIEW_META,
    OPERATION_VIEWS,
    REPORT_VIEWS,
    TABLES_TO_SHOW,
)

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


def build_operation_view_items():
    """Dựng danh mục 7 views vận hành (bốt cổng + sơ đồ realtime) cho trang Báo cáo."""
    items = []
    for view_name in OPERATION_VIEWS:
        meta = OPERATION_VIEW_META.get(view_name, {})
        items.append({
            "view_name": view_name,
            "icon": meta.get("icon", "📊"),
            "title": meta.get("title", view_name),
            "desc": meta.get("desc", "View vận hành thời gian thực."),
            "category": meta.get("category", "Vận Hành"),
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
    return render_template("index.html", demo_cases=DEMO_CASES, demo_groups=DEMO_GROUPS, reports=REPORT_VIEWS, overview=overview)


@bp.route("/health")
def health():
    return redirect(url_for("main.setup"))


@bp.route("/map")
def parking_map():
    """Sơ đồ bãi xe thời gian thực, dữ liệu lấy trực tiếp từ 3 views PHẦN D của sql/07_views.sql."""
    selected_bai = request.args.get("bai", "BAI_Q1")
    bai_list = []
    slots = []
    zones = []
    bai_info = None
    error = None

    try:
        bai_list = execute_query("SELECT MaBai, TenBai, SucChua, SoLuongHienTai FROM dbo.BAI_DO_XE ORDER BY MaBai;")
        if bai_list and not any(b["MaBai"] == selected_bai for b in bai_list):
            selected_bai = bai_list[0]["MaBai"]

        # Thẻ tổng quan công suất bãi (kèm cờ đối soát bộ đếm và nhịp xe vào/ra trong ngày)
        bai_info_rows = execute_query(
            "SELECT * FROM dbo.v_SodoBai_TongQuanBai WHERE MaBai = ?;", (selected_bai,)
        )
        if bai_info_rows:
            bai_info = bai_info_rows[0]

        # Thanh tổng hợp số ô trống theo từng khu vực / tầng
        zones = execute_query(
            "SELECT * FROM dbo.v_SodoBai_TongHopKhuVuc WHERE MaBai = ? ORDER BY KhuVuc;", (selected_bai,)
        )

        # Lưới ô đỗ chi tiết (view đã bảo đảm đúng 1 dòng cho 1 ô đỗ)
        slots = execute_query(
            "SELECT * FROM dbo.v_SodoBai_ODoChiTiet WHERE MaBai = ? ORDER BY ThuTuHienThi;", (selected_bai,)
        )
    except Exception as exc:
        error = str(exc)

    return render_template(
        "parking_map.html",
        bai_list=bai_list,
        selected_bai=selected_bai,
        bai_info=bai_info,
        zones=zones,
        slots=slots,
        map_views=MAP_VIEWS,
        error=error
    )


@bp.route("/gate")
def gate_booth():
    """Bốt kiểm soát cổng vào/ra, dữ liệu lấy trực tiếp từ 4 views PHẦN C của sql/07_views.sql."""
    selected_bai = request.args.get("bai", "")
    ma_the = (request.args.get("the") or "").strip().upper()

    bai_list = []
    den_cong = []
    xe_cho_ra = []
    nhat_ky = []
    the_options = []
    the_info = None
    error = None

    try:
        bai_list = execute_query("SELECT MaBai, TenBai FROM dbo.BAI_DO_XE ORDER BY MaBai;")
        if selected_bai and not any(b["MaBai"] == selected_bai for b in bai_list):
            selected_bai = ""

        # Bảng đèn tín hiệu CÒN CHỖ / HẾT CHỖ tại cổng vào
        if selected_bai:
            den_cong = execute_query(
                "SELECT * FROM dbo.v_BotCong_BangDenCong WHERE MaBai = ? ORDER BY MaLoaiXe;", (selected_bai,)
            )
            xe_cho_ra = execute_query(
                "SELECT * FROM dbo.v_BotCong_XeChoRa WHERE MaBai = ? ORDER BY ThoiGianVao;", (selected_bai,)
            )
            nhat_ky = execute_query(
                "SELECT TOP 25 * FROM dbo.v_BotCong_NhatKyVaoRa WHERE MaBai = ?;", (selected_bai,)
            )
        else:
            den_cong = execute_query("SELECT * FROM dbo.v_BotCong_BangDenCong ORDER BY MaBai, MaLoaiXe;")
            xe_cho_ra = execute_query("SELECT * FROM dbo.v_BotCong_XeChoRa ORDER BY ThoiGianVao;")
            nhat_ky = execute_query("SELECT TOP 25 * FROM dbo.v_BotCong_NhatKyVaoRa;")

        # Danh sách mã thẻ gợi ý cho ô nhập quét thẻ tại bốt cổng
        the_options = execute_query("""
            SELECT MaThe, LoaiThe, TrangThaiThe, ChieuQuetKeTiep, ChoPhepQuet
            FROM dbo.v_BotCong_TraCuuThe
            ORDER BY MaThe;
        """)

        # Kết quả quét 1 mã thẻ cụ thể tại barrier
        if ma_the:
            the_rows = execute_query("SELECT * FROM dbo.v_BotCong_TraCuuThe WHERE MaThe = ?;", (ma_the,))
            the_info = the_rows[0] if the_rows else None
    except Exception as exc:
        error = str(exc)

    return render_template(
        "gate_booth.html",
        bai_list=bai_list,
        selected_bai=selected_bai,
        ma_the=ma_the,
        the_info=the_info,
        the_options=the_options,
        den_cong=den_cong,
        xe_cho_ra=xe_cho_ra,
        nhat_ky=nhat_ky,
        gate_views=GATE_VIEWS,
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
    return render_template(
        "reports.html",
        reports=REPORT_VIEWS,
        report_items=build_report_items(),
        operation_view_items=build_operation_view_items(),
    )


@bp.route("/report-image/<path:filename>")
def report_image(filename):
    return send_from_directory(get_reports_screenshots_dir(), filename)


@bp.route("/report/<view_name>")
def report_detail(view_name):
    if view_name not in ALL_VIEWS:
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


def check_db_health():
    """Kiểm tra tình trạng kết nối tới SQL Server, thử DB chỉ định trước, nếu chưa có thì thử master."""
    result = {
        "connected": False,
        "database_name": None,
        "server_time": None,
        "version": None,
        "server_host": os.getenv("SQLSERVER_SERVER", "localhost,1433"),
        "driver": os.getenv("SQLSERVER_DRIVER", "ODBC Driver 18 for SQL Server"),
        "user": os.getenv("SQLSERVER_USERNAME", "sa"),
        "error": None,
        "is_master_fallback": False,
    }
    # 1. Thử kết nối trực tiếp vào database cấu hình trong .env (mặc định QuanLyBaiDoXe)
    try:
        rows = execute_query("SELECT DB_NAME() AS DatabaseName, GETDATE() AS ServerTime, @@VERSION AS SQLServerVersion;")
        if rows:
            result["connected"] = True
            result["database_name"] = rows[0].get("DatabaseName")
            result["server_time"] = rows[0].get("ServerTime")
            result["version"] = rows[0].get("SQLServerVersion")
            return result
    except Exception as exc:
        err_msg = str(exc)
        # 2. Nếu database QuanLyBaiDoXe chưa tồn tại (ví dụ lỗi 4060), thử kết nối qua database master
        try:
            with get_connection(database="master") as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT DB_NAME() AS DatabaseName, GETDATE() AS ServerTime, @@VERSION AS SQLServerVersion;")
                row = cursor.fetchone()
                if row:
                    result["connected"] = True
                    result["database_name"] = f"{row[0]} (Đã kết nối máy chủ SQL Server, sẵn sàng tạo CSDL QuanLyBaiDoXe)"
                    result["server_time"] = row[1]
                    result["version"] = row[2]
                    result["is_master_fallback"] = True
                    return result
        except Exception as master_exc:
            result["connected"] = False
            result["error"] = str(master_exc)
            return result

        result["connected"] = False
        result["error"] = err_msg
    return result


@bp.route("/setup", methods=["GET", "POST"])
def setup():
    allow = os.getenv("ALLOW_RUN_FULL_SCRIPT", "0") == "1"
    health_info = check_db_health()

    if request.method == "POST":
        if not health_info["connected"]:
            flash("Lỗi kết nối: Không thể thực hiện Setup vì chưa kết nối được tới máy chủ SQL Server!", "error")
            return redirect(url_for("main.setup"))
        if not allow:
            flash("Chức năng chạy nạp lại full script đang bị khóa an toàn trong .env (ALLOW_RUN_FULL_SCRIPT=0).", "error")
            return redirect(url_for("main.setup"))
        try:
            sql_file = Path(__file__).resolve().parents[1] / "sql" / "QL_BaiDoXe_FullScript.sql"
            count = run_sql_file(str(sql_file))
            flash(f"Khởi tạo và nạp thành công toàn bộ CSDL QuanLyBaiDoXe với {count} batch SQL!", "success")
            return redirect(url_for("main.setup"))
        except Exception as exc:
            flash(f"Lỗi khi nạp script CSDL: {str(exc)}", "error")
            return redirect(url_for("main.setup"))

    return render_template("setup.html", allow=allow, health=health_info)

