import os
import secrets
from datetime import timedelta
from decimal import Decimal, InvalidOperation
from flask import Flask
from .kh_routes import kh_bp
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
    # Cổng khách hàng: số dư ví, phí cổng thanh toán, hạn mức
    "sodu",
    "sodutruoc",
    "sodusau",
    "soduhientai",
    "sodutheosocai",
    "chenhlech",
    "sodudanggiu",
    "tongsodudanggiu",
    "phigiaodich",
    "phicongthanhtoan",
    "hanmucnapngay",
    "sotientoithieu",
    "sotiencodau",
    "tongnapthangnay",
    "tongchivethangthangnay",
    "tongnap",
    "soduluyke",
}

# Tiền tố cột KHÔNG phải tiền dù tên có chứa "tien" / "gia" (vd: SoThangGiaHan, HuongTien, MaGiaoDich,
# TrangThaiGiaoDich, LoaiPhuongTien). Kiểm tra trước khi so khớp chuỗi con.
NON_MONEY_PREFIXES = (
    "sothang",
    "songay",
    "sophut",
    "solan",
    "huongtien",
    "ma",
    "trangthai",
    "loai",
    "kenh",
    "ten",
    "phuongthuc",
)

# Cột tiền có dấu (+ cộng ví, - trừ ví) hiển thị kèm dấu và màu
SIGNED_MONEY_COLUMNS = {"sotiencodau", "chenhlech"}

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
    # Cổng khách hàng
    "trangthaitaikhoan",
    "trangthaivi",
    "kenhthanhtoan",
    "loaigd",
    "ketqua",
    "phanloai",
    "canhbao",
    "mavaitrocuatoi",
}


def _normalize_col(column_name):
    return str(column_name or "").replace("_", "").replace(" ", "").lower()


def is_money_column(column_name):
    col = _normalize_col(column_name)
    if col in MONEY_COLUMNS:
        return True
    if col.startswith(NON_MONEY_PREFIXES):
        return False
    # Cột đếm "So..." (SoGiaoDich, SoHoaDon, SoLanNapVi...) không phải tiền, trừ SoTien* / SoDu*
    if col.startswith("so") and not col.startswith(("sotien", "sodu")):
        return False
    return "tien" in col or "doanhthu" in col or "gia" in col


def is_signed_money_column(column_name):
    return _normalize_col(column_name) in SIGNED_MONEY_COLUMNS


def is_sensitive_column(column_name):
    """Cột mật khẩu / salt / hash không bao giờ hiển thị giá trị thật trên giao diện."""
    col = _normalize_col(column_name)
    return "matkhau" in col or "salt" in col or col.endswith("hash")


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
    """Format hiển thị dữ liệu bảng: che cột mật khẩu, tiền tệ VND (có dấu nếu cần), tỷ lệ %, nhị phân."""
    if column_name and is_sensitive_column(column_name):
        return "•••••• (đã ẩn)" if value is not None else ""
    if value is None:
        return ""
    if isinstance(value, (bytes, bytearray, memoryview)):
        hex_value = bytes(value).hex().upper()
        return f"0x{hex_value[:16]}…" if len(hex_value) > 16 else f"0x{hex_value}"
    if column_name and is_signed_money_column(column_name):
        number = _to_decimal(value)
        if number is not None and number > 0:
            return f"+{format_vnd(number)}"
        return format_vnd(value)
    if column_name and is_money_column(column_name):
        return format_vnd(value)
    if column_name and is_percent_column(column_name):
        return format_percent(value)
    return value


def cell_class(column_name=None, value=None):
    if column_name and is_sensitive_column(column_name):
        return "sensitive-cell"
    if column_name and is_signed_money_column(column_name):
        number = _to_decimal(value)
        if number is not None and number < 0:
            return "money-cell money-out"
        if number is not None and number > 0:
            return "money-cell money-in"
        return "money-cell"
    if column_name and is_money_column(column_name):
        return "money-cell"
    if column_name and is_percent_column(column_name):
        return "number-cell"
    return ""


def status_badge_class(value):
    """Xác định màu badge trạng thái."""
    val = str(value or "").strip().lower()
    if val in {"hoạt động", "trống", "đã giải quyết", "còn hạn an toàn", "check-in thành công", "check-out thành công",
               "thành công", "hiệu lực", "đã gia hạn", "khớp", "bình thường", "đã ra", "chu_so_huu"}:
        return "badge-success"
    if val in {"đã đỗ", "bị khóa", "mất", "hết hạn", "đã quá hạn", "quá hạn",
               "thất bại", "đóng băng", "thiếu số dư", "lỗi", "đã đóng", "lệch - cần kiểm tra", "đang tạm khóa",
               "treo quá 30 phút", "sai mật khẩu", "không tồn tại"}:
        return "badge-danger"
    if val in {"chờ xử lý", "đang giải quyết", "tạm khóa", "sắp hết hạn",
               "đã hoàn", "đã thu hồi", "tạm ngưng", "nhiều lần sai mật khẩu", "đăng nhập từ nhiều địa chỉ ip",
               "đang chờ cổng thanh toán", "đang đỗ"}:
        return "badge-warning"
    if val in {"online", "tự động", "tại quầy", "nạp tiền", "thanh toán vé tháng", "hoàn tiền", "thanh_vien", "xem_lich_su"}:
        return "badge-primary" if val in {"online", "tự động", "nạp tiền"} else "badge-info"
    return "badge-info"


def create_app():
    app = Flask(__name__)
    # Không hard-code khóa ký session (N7); thiếu biến môi trường thì sinh khóa ngẫu nhiên cho mỗi lần chạy
    app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY") or secrets.token_hex(32)
    app.config["SESSION_COOKIE_HTTPONLY"] = True
    app.config["SESSION_COOKIE_SAMESITE"] = "Lax"
    app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(minutes=30)
    app.jinja_env.filters["format_cell"] = format_cell
    app.jinja_env.filters["vnd"] = format_vnd
    app.jinja_env.filters["cell_class"] = cell_class
    app.jinja_env.filters["status_badge_class"] = status_badge_class
    app.jinja_env.tests["status_col"] = is_status_column
    app.register_blueprint(bp)
    app.register_blueprint(kh_bp)
    return app
