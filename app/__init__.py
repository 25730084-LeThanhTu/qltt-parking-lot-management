from decimal import Decimal, InvalidOperation
from flask import Flask
from .routes import bp

# Danh mục các cột mang ý nghĩa tiền tệ trong CSDL Quản lý Bãi đỗ xe
MONEY_COLUMNS = {
    "tiengui",
    "dongiagio",
    "giavethang",
    "sotien",
    "tienphat",
    "doanhthuluot",
    "doanhthuthang",
    "tongdoanhthu",
    "tienguithucthu",
    "sotiengiahan",
    "tongtienthanhtoan",
    "tienphatdenbu",
    "tienguicalculated",
    "tienguio_to_5gio",
}

PERCENT_COLUMNS = {
    "tylelapdaypercent",
    "tylelapday",
}

STATUS_COLUMNS = {
    "trangthai",
    "trangthaive",
    "trangthaixuly",
    "trangthaithe",
    "loaithe",
}


def _normalize_col(column_name):
    return str(column_name or "").replace("_", "").replace(" ", "").lower()


def is_money_column(column_name):
    col = _normalize_col(column_name)
    return col in MONEY_COLUMNS or "tien" in col or "doanhthu" in col or "gia" in col


def is_percent_column(column_name):
    col = _normalize_col(column_name)
    return col in PERCENT_COLUMNS or "percent" in col or "tyle" in col


def is_status_column(column_name):
    col = _normalize_col(column_name)
    return col in STATUS_COLUMNS


def _to_decimal(value):
    if value is None:
        return None
    try:
        return Decimal(str(value))
    except (InvalidOperation, ValueError, TypeError):
        return None


def format_vnd(value):
    number = _to_decimal(value)
    if number is None:
        return value

    if number == number.to_integral_value():
        formatted = f"{int(number):,}".replace(",", ".")
    else:
        formatted = f"{float(number):,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return f"{formatted} ₫"


def format_percent(value):
    number = _to_decimal(value)
    if number is None:
        return value
    formatted = f"{float(number):.2f}"
    return f"{formatted}%"


def format_cell(value, column_name=None):
    """Format hiển thị dữ liệu bảng: Tiền tệ VND, Tỷ lệ %, hoặc giữ nguyên."""
    if value is None:
        return ""
    if column_name and is_money_column(column_name):
        return format_vnd(value)
    if column_name and is_percent_column(column_name):
        return format_percent(value)
    return value


def cell_class(column_name=None):
    if column_name and is_money_column(column_name):
        return "money-cell"
    if column_name and is_percent_column(column_name):
        return "number-cell"
    return ""


def status_badge_class(value):
    """Xác định màu badge trạng thái."""
    val = str(value or "").strip().lower()
    if val in {"hoạt động", "trống", "đã giải quyết", "còn hạn an toàn", "check-in thành công", "check-out thành công"}:
        return "badge-success"
    if val in {"đã đỗ", "bị khóa", "mất", "hết hạn", "đã quá hạn", "quá hạn"}:
        return "badge-danger"
    if val in {"chờ xử lý", "đang giải quyết", "tạm khóa", "sắp hết hạn"}:
        return "badge-warning"
    return "badge-info"


def create_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = "qltt-parking-lot-secret-key-2026"
    app.jinja_env.filters["format_cell"] = format_cell
    app.jinja_env.filters["cell_class"] = cell_class
    app.jinja_env.filters["status_badge_class"] = status_badge_class
    app.register_blueprint(bp)
    return app
