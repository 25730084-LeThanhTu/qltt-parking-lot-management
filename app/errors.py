"""Bản đồ mã lỗi nghiệp vụ SQL Server (THROW 50xxx) -> thông báo thân thiện (UPGRADE_PLAN.md mục 12.6).

Dùng cho màn hình nhân viên và cổng khách hàng. Trang demo giữ nguyên lỗi gốc để minh họa trigger.
"""
import re

ERROR_MESSAGES = {
    50017: "Vé chưa có biểu phí tại bãi tính giá, vui lòng liên hệ quầy.",
    50019: "Thẻ đã báo mất, cần cấp thẻ mới tại quầy trước khi gia hạn.",
    50030: "Số điện thoại và CCCD không khớp hồ sơ khách hàng. Vui lòng đăng ký vé tại quầy trước.",
    50031: "Số dư ví không đủ để thực hiện giao dịch.",
    50032: "Khách hàng này đã có tài khoản. Vui lòng đăng nhập.",
    50033: "Ví không tồn tại hoặc đang bị đóng băng (khách cần tạo tài khoản cổng khách hàng trước).",
    50034: "Mật khẩu cần tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, chữ số và ký tự đặc biệt.",
    50035: "Phương thức thanh toán không khả dụng.",
    50036: "Số tiền thấp hơn mức tối thiểu của phương thức thanh toán.",
    50037: "Vượt hạn mức nạp tiền trong ngày.",
    50038: "Giao dịch không tồn tại.",
    50039: "Mã tham chiếu cổng thanh toán không hợp lệ.",
    50040: "Tên đăng nhập hoặc mật khẩu không đúng.",
    50041: "Tài khoản đang tạm khóa do đăng nhập sai nhiều lần.",
    50042: "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.",
    50043: "Tài khoản đã đóng.",
    50044: "Mật khẩu hiện tại không đúng.",
    50045: "Số tháng gia hạn phải từ 1 đến 12.",
    50047: "Không tìm thấy tài khoản hoặc tài khoản không ở trạng thái phù hợp.",
    50048: "Vai trò chia sẻ vé không hợp lệ.",
    50049: "Ủy quyền đã tồn tại hoặc đã được thu hồi.",
    50050: "Tài khoản không có quyền thực hiện thao tác này.",
    50051: "Không thể chia sẻ vé cho chính chủ vé.",
    50052: "Chỉ chủ vé mới được chia sẻ vé.",
    50053: "Mỗi vé chỉ được chia sẻ tối đa 3 tài khoản.",
    50054: "Vé đã hết hạn, không thể chia sẻ.",
    50060: "Không được xóa giao dịch khỏi sổ cái.",
    50061: "Sổ cái bất biến: không được sửa giao dịch đã ghi.",
    50062: "Không được sửa trực tiếp số dư ví.",
    50063: "Chỉ hoàn tiền cho khoản thanh toán vé tháng đã thành công và chưa xuất hóa đơn (phải nhập lý do).",
    50065: "Thẻ đang gắn với một vé tháng còn hiệu lực, hãy dùng thẻ khác.",
    50066: "Thẻ của vé này đã được cấp cho vé tháng khác, vé cũ không gia hạn được.",
}

DEFAULT_MESSAGE = "Đã xảy ra lỗi, vui lòng thử lại."

# pyodbc trả lỗi dạng "... [SQL Server]Lỗi: <nội dung> (50031) (SQLExecDirectW)"
_CODE_PATTERN = re.compile(r"\((50\d{3})\)")
_SERVER_MESSAGE_PATTERN = re.compile(r"\[SQL Server\](.*?)\s*\(50\d{3}\)", re.DOTALL)


def friendly_error(exc):
    """Trả về (mã lỗi, thông báo thân thiện). Ưu tiên nội dung chi tiết do thủ tục ném ra (có số tiền, thời điểm)."""
    text = str(exc)
    match = _CODE_PATTERN.search(text)
    if not match:
        return None, DEFAULT_MESSAGE
    code = int(match.group(1))
    detail = _SERVER_MESSAGE_PATTERN.search(text)
    if detail:
        message = detail.group(1).strip()
        if message.startswith("Lỗi:"):
            message = message[len("Lỗi:"):].strip()
        if message:
            return code, message
    return code, ERROR_MESSAGES.get(code, DEFAULT_MESSAGE)
