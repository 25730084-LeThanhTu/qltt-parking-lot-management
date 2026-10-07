"""Cổng khách hàng /kh (UPGRADE_PLAN.md mục 12.4).

Mỗi request mở một kết nối riêng dưới quyền r_KhachHang (get_kh_connection): SESSION_CONTEXT read-only theo
tài khoản trong session, RLS lọc dữ liệu, mọi thao tác ghi đi qua sp_KH_*. Riêng callback của cổng thanh toán
giả lập chạy bằng kết nối hệ thống, giống cổng thanh toán thật gọi về máy chủ.
"""
import os
import secrets
import time
from datetime import date

from flask import Blueprint, abort, current_app, flash, g, redirect, render_template, request, session, url_for

from .db import execute_query, execute_script_return_sets, get_kh_connection
from .errors import friendly_error

kh_bp = Blueprint("kh", __name__, url_prefix="/kh")

SESSION_TIMEOUT_SECONDS = 30 * 60
PUBLIC_ENDPOINTS = {"kh.dang_nhap", "kh.dang_ky"}
SO_THANG_CHON = (1, 3, 6, 12)
MAT_KHAU_DEMO = "Khach@2026"


# ------------------------------------------------------------------------------------
# Kết nối, phiên đăng nhập, CSRF
# ------------------------------------------------------------------------------------
def _rows(cursor):
    if not cursor.description:
        return []
    cols = [c[0] for c in cursor.description]
    return [dict(zip(cols, r)) for r in cursor.fetchall()]


def query(sql, params=()):
    cursor = g.kh_conn.cursor()
    cursor.execute(sql, params)
    return _rows(cursor)


def execute(sql, params=()):
    """Chạy thủ tục, trả về result set đầu tiên có dữ liệu (thủ tục sp_KH_* trả một dòng kết quả)."""
    cursor = g.kh_conn.cursor()
    cursor.execute(sql, params)
    while True:
        if cursor.description:
            return _rows(cursor)
        if not cursor.nextset():
            return []


def _dang_xuat_session():
    for key in ("kh_ma_tk", "kh_ma_kh", "kh_ho_ten", "kh_last"):
        session.pop(key, None)


@kh_bp.before_request
def _truoc_request():
    if "kh_csrf" not in session:
        session["kh_csrf"] = secrets.token_urlsafe(32)
    if request.method == "POST" and request.form.get("csrf_token") != session["kh_csrf"]:
        abort(400, description="Phiên làm việc không hợp lệ (CSRF). Hãy tải lại trang.")

    if request.endpoint in PUBLIC_ENDPOINTS:
        return None

    if not session.get("kh_ma_tk"):
        return redirect(url_for("kh.dang_nhap", next=request.path))
    if time.time() - session.get("kh_last", 0) > SESSION_TIMEOUT_SECONDS:
        _dang_xuat_session()
        flash("Phiên đăng nhập đã hết hạn sau 30 phút không thao tác. Vui lòng đăng nhập lại.", "warning")
        return redirect(url_for("kh.dang_nhap"))
    session["kh_last"] = time.time()
    session.permanent = True

    try:
        g.kh_conn = get_kh_connection(session["kh_ma_tk"], session["kh_ma_kh"])
        ho_so = query("SELECT * FROM dbo.vw_KH_HoSoCuaToi;")
    except Exception as exc:
        return render_template("kh/loi.html", error=str(exc)), 503
    if not ho_so:
        _dang_xuat_session()
        flash("Không tìm thấy tài khoản, vui lòng đăng nhập lại.", "warning")
        return redirect(url_for("kh.dang_nhap"))
    g.ho_so = ho_so[0]
    return None


@kh_bp.teardown_request
def _sau_request(_exc):
    conn = g.pop("kh_conn", None)
    if conn is not None:
        conn.close()


@kh_bp.context_processor
def _bien_template():
    return {"csrf_token": session.get("kh_csrf", ""), "ho_so": g.get("ho_so")}


def _bao_loi(exc):
    code, message = friendly_error(exc)
    flash(f"{message} (mã lỗi {code})" if code else message, "error")


def _ngay(value):
    try:
        return date.fromisoformat(value) if value else None
    except ValueError:
        return None


# ------------------------------------------------------------------------------------
# Đăng nhập / đăng ký / đăng xuất
# ------------------------------------------------------------------------------------
def _tai_khoan_demo():
    """Danh sách tài khoản mẫu để bấm điền nhanh khi demo (KH_DEMO_ACCOUNTS=0 để ẩn)."""
    if os.getenv("KH_DEMO_ACCOUNTS", "1") == "0":
        return []
    try:
        return execute_query("""
            SELECT tk.TenDangNhap, kh.HoTen, tk.TrangThai,
                   (SELECT COUNT(*) FROM dbo.VE_THANG v WHERE v.MaKH = tk.MaKH) AS SoVe,
                   (SELECT COUNT(*) FROM dbo.UY_QUYEN_VE u WHERE u.MaTKDuocUyQuyen = tk.MaTK AND u.TrangThai = N'Hiệu lực') AS SoVeDuocChiaSe
            FROM dbo.TAI_KHOAN_KH tk INNER JOIN dbo.KHACH_HANG kh ON kh.MaKH = tk.MaKH
            ORDER BY tk.MaTK;
        """)
    except Exception:
        return []


@kh_bp.route("/dang-nhap", methods=["GET", "POST"])
def dang_nhap():
    if session.get("kh_ma_tk") and request.method == "GET":
        return redirect(url_for("kh.tong_quan"))

    ten_dang_nhap = request.form.get("ten_dang_nhap", "").strip()
    if request.method == "POST":
        try:
            g.kh_conn = get_kh_connection()
            rows = execute(
                "EXEC dbo.sp_KH_DangNhap @TenDangNhap = ?, @MatKhau = ?, @DiaChiIP = ?, @ThietBi = ?, @KhoaNguCanh = 1;",
                (ten_dang_nhap, request.form.get("mat_khau", ""), request.remote_addr,
                 (request.user_agent.string or "")[:200]),
            )
            ket_qua = rows[0]
            session["kh_ma_tk"] = ket_qua["MaTK"]
            session["kh_ma_kh"] = ket_qua["MaKH"]
            session["kh_ho_ten"] = ket_qua["HoTen"]
            session["kh_last"] = time.time()
            session["kh_csrf"] = secrets.token_urlsafe(32)
            session.permanent = True
            flash(f"Xin chào {ket_qua['HoTen']}!", "success")
            dich = request.args.get("next", "")
            return redirect(dich if dich.startswith("/kh") else url_for("kh.tong_quan"))
        except Exception as exc:
            _bao_loi(exc)

    return render_template("kh/dang_nhap.html", ten_dang_nhap=ten_dang_nhap,
                           tai_khoan_demo=_tai_khoan_demo(), mat_khau_demo=MAT_KHAU_DEMO)


@kh_bp.route("/dang-ky", methods=["GET", "POST"])
def dang_ky():
    form = {k: request.form.get(k, "").strip() for k in ("sdt", "cmnd", "email")}
    if request.method == "POST":
        if request.form.get("mat_khau") != request.form.get("nhap_lai"):
            flash("Mật khẩu nhập lại không khớp.", "error")
        else:
            try:
                g.kh_conn = get_kh_connection()
                execute("EXEC dbo.sp_KH_DangKyTaiKhoan @SDT = ?, @CMND = ?, @MatKhau = ?, @Email = ?;",
                        (form["sdt"], form["cmnd"], request.form.get("mat_khau", ""), form["email"] or None))
                flash("Tạo tài khoản thành công. Hãy đăng nhập bằng số điện thoại và mật khẩu vừa tạo.", "success")
                return redirect(url_for("kh.dang_nhap"))
            except Exception as exc:
                _bao_loi(exc)
    return render_template("kh/dang_ky.html", form=form)


@kh_bp.route("/dang-xuat", methods=["POST"])
def dang_xuat():
    _dang_xuat_session()
    flash("Đã đăng xuất.", "success")
    return redirect(url_for("kh.dang_nhap"))


# ------------------------------------------------------------------------------------
# Tổng quan và vé
# ------------------------------------------------------------------------------------
def _quyen_theo_ve():
    quyen = {}
    for r in query("SELECT MaVe, MaQuyen FROM dbo.vw_KH_QuyenTrenVe;"):
        quyen.setdefault(r["MaVe"], set()).add(r["MaQuyen"])
    return quyen


@kh_bp.route("/")
def tong_quan():
    ve = query("SELECT * FROM dbo.vw_KH_VeThangCuaToi ORDER BY CASE WHEN MaVaiTroCuaToi = 'CHU_SO_HUU' THEN 0 ELSE 1 END, NgayHetHan;")
    return render_template(
        "kh/tong_quan.html",
        ve=ve,
        quyen=_quyen_theo_ve(),
        thong_bao=query("SELECT TOP 3 * FROM dbo.vw_KH_ThongBao ORDER BY DaDoc, ThoiGianTao DESC;"),
        luot_gui=query("SELECT TOP 5 * FROM dbo.vw_KH_LichSuDoXe ORDER BY ThoiGianVao DESC;"),
    )


def _lay_ve(ma_ve):
    rows = query("SELECT * FROM dbo.vw_KH_VeThangCuaToi WHERE MaVe = ?;", (ma_ve,))
    if not rows:
        abort(404, description="Không tìm thấy vé hoặc bạn không có quyền xem vé này.")
    return rows[0]


@kh_bp.route("/ve/<ma_ve>")
def chi_tiet_ve(ma_ve):
    ve = _lay_ve(ma_ve)
    uy_quyen = [u for u in execute("EXEC dbo.sp_KH_DanhSachUyQuyen;") if u["MaVe"] == ma_ve]
    return render_template(
        "kh/ve.html",
        ve=ve,
        quyen=_quyen_theo_ve().get(ma_ve, set()),
        hoa_don=query("SELECT * FROM dbo.vw_KH_HoaDonCuaToi WHERE MaVe = ? ORDER BY NgayThanhToan DESC;", (ma_ve,)),
        luot_gui=query("SELECT TOP 5 * FROM dbo.vw_KH_LichSuDoXe WHERE MaVe = ? ORDER BY ThoiGianVao DESC;", (ma_ve,)),
        uy_quyen=uy_quyen,
        so_thang_chon=SO_THANG_CHON,
    )


@kh_bp.route("/ve/<ma_ve>/tu-dong-gia-han", methods=["POST"])
def tu_dong_gia_han(ma_ve):
    bat = request.form.get("bat_tat") == "1"
    try:
        execute("EXEC dbo.sp_KH_CaiDatTuDongGiaHan @MaVe = ?, @BatTat = ?, @SoThang = ?;",
                (ma_ve, 1 if bat else 0, int(request.form.get("so_thang", "1"))))
        flash("Đã bật tự động gia hạn." if bat else "Đã tắt tự động gia hạn.", "success")
    except Exception as exc:
        _bao_loi(exc)
    return redirect(url_for("kh.chi_tiet_ve", ma_ve=ma_ve))


@kh_bp.route("/ve/<ma_ve>/bao-mat-the", methods=["POST"])
def bao_mat_the(ma_ve):
    try:
        execute("EXEC dbo.sp_KH_BaoMatThe @MaVe = ?;", (ma_ve,))
        flash("Đã khóa thẻ và ghi nhận báo mất. Vui lòng đến quầy để được cấp thẻ mới.", "success")
    except Exception as exc:
        _bao_loi(exc)
    return redirect(url_for("kh.chi_tiet_ve", ma_ve=ma_ve))


@kh_bp.route("/ve/<ma_ve>/gia-han", methods=["GET", "POST"])
def gia_han(ma_ve):
    ve = _lay_ve(ma_ve)
    quyen = _quyen_theo_ve().get(ma_ve, set())
    try:
        so_thang = int(request.values.get("so_thang", "1"))
    except ValueError:
        so_thang = 1
    if so_thang not in SO_THANG_CHON:
        so_thang = 1

    if request.method == "POST":
        try:
            kq = execute("EXEC dbo.sp_KH_GiaHanBangVi @MaVe = ?, @SoThang = ?;", (ma_ve, so_thang))[0]
            flash(f"Gia hạn thành công: hóa đơn {kq['MaHoaDon']}, hạn mới {kq['HanMoi']:%d/%m/%Y}, "
                  f"đã trừ {current_app.jinja_env.filters['vnd'](kq['SoTienThanhToan'])}.", "success")
            return redirect(url_for("kh.chi_tiet_ve", ma_ve=ma_ve))
        except Exception as exc:
            _bao_loi(exc)

    phi = query("SELECT dbo.f_KH_TinhPhiGiaHan(?, ?) AS Phi;", (ma_ve, so_thang))[0]["Phi"]
    so_du = g.ho_so["SoDu"] or 0
    return render_template(
        "kh/gia_han.html",
        ve=ve,
        co_quyen="VE.GIAHAN" in quyen,
        so_thang=so_thang,
        so_thang_chon=SO_THANG_CHON,
        phi=phi,
        so_du=so_du,
        thieu=(phi - so_du) if phi is not None and phi > so_du else 0,
    )


# ------------------------------------------------------------------------------------
# Nạp tiền và cổng thanh toán giả lập
# ------------------------------------------------------------------------------------
@kh_bp.route("/nap-tien", methods=["GET", "POST"])
def nap_tien():
    if request.method == "POST":
        try:
            so_tien = int(request.form.get("so_tien", "0").replace(".", "").replace(",", ""))
        except ValueError:
            so_tien = 0
        try:
            kq = execute(
                "DECLARE @MaGD VARCHAR(16); EXEC dbo.sp_KH_NapTien_KhoiTao @SoTien = ?, @MaPTTT = ?, @MaGD = @MaGD OUTPUT;",
                (so_tien, request.form.get("ma_pttt", "")),
            )[0]
            return redirect(url_for("kh.cong_thanh_toan", ma_gd=kq["MaGD"]))
        except Exception as exc:
            _bao_loi(exc)

    han_muc = query("SELECT * FROM dbo.vw_KH_HanMucNap;")
    return render_template(
        "kh/nap_tien.html",
        phuong_thuc=query("SELECT * FROM dbo.vw_KH_PhuongThucNapVi ORDER BY CASE WHEN TrangThai = N'Hoạt động' THEN 0 ELSE 1 END, PhiPhanTram;"),
        han_muc=han_muc[0] if han_muc else None,
        so_tien_goi_y=request.args.get("so_tien", ""),
        chon_nhanh=(100000, 200000, 500000, 1000000),
    )


def _giao_dich_cua_toi(ma_gd):
    rows = query("SELECT * FROM dbo.vw_KH_LichSuGiaoDich WHERE MaGD = ?;", (ma_gd,))
    if not rows or rows[0]["LoaiGD"] != "Nạp tiền":
        abort(404, description="Không tìm thấy lệnh nạp tiền của bạn.")
    return rows[0]


@kh_bp.route("/nap-tien/<ma_gd>/cong-thanh-toan", methods=["GET", "POST"])
def cong_thanh_toan(ma_gd):
    gd = _giao_dich_cua_toi(ma_gd)
    if request.method == "POST":
        thanh_cong = request.form.get("ket_qua") == "1"
        try:
            # Callback từ cổng thanh toán: chạy bằng quyền hệ thống (khách bị DENY sp_KH_NapTien_XacNhan).
            # Mã tham chiếu cố định theo MaGD nên bấm "Gửi lại callback" minh họa được tính idempotent.
            sets = execute_script_return_sets(
                "EXEC dbo.sp_KH_NapTien_XacNhan @MaGD = ?, @MaThamChieu = ?, @ThanhCong = ?;",
                (ma_gd, f"SIM-{ma_gd}", 1 if thanh_cong else 0),
                commit=True,
            )
            ket_qua = sets[0]["rows"][0]["KetQua"] if sets and sets[0]["rows"] else "Đã gửi callback"
            flash(ket_qua, "success")
        except Exception as exc:
            _bao_loi(exc)
        return redirect(url_for("kh.cong_thanh_toan", ma_gd=ma_gd))
    return render_template("kh/cong_thanh_toan.html", gd=gd)


# ------------------------------------------------------------------------------------
# Lịch sử, thông báo, ủy quyền, bảo mật
# ------------------------------------------------------------------------------------
@kh_bp.route("/lich-su-do-xe")
def lich_su_do_xe():
    loc = {"ma_ve": request.args.get("ma_ve", ""), "tu": request.args.get("tu", ""), "den": request.args.get("den", "")}
    sql = "SELECT * FROM dbo.vw_KH_LichSuDoXe WHERE 1 = 1"
    params = []
    if loc["ma_ve"]:
        sql += " AND MaVe = ?"
        params.append(loc["ma_ve"])
    if _ngay(loc["tu"]):
        sql += " AND ThoiGianVao >= ?"
        params.append(_ngay(loc["tu"]))
    if _ngay(loc["den"]):
        sql += " AND ThoiGianVao < DATEADD(DAY, 1, CAST(? AS DATE))"
        params.append(_ngay(loc["den"]))
    return render_template(
        "kh/lich_su_do_xe.html",
        luot_gui=query(sql + " ORDER BY ThoiGianVao DESC;", tuple(params)),
        ve=query("SELECT MaVe, BienSo FROM dbo.vw_KH_VeThangCuaToi ORDER BY MaVe;"),
        loc=loc,
    )


@kh_bp.route("/giao-dich")
def giao_dich():
    loc = {k: request.args.get(k, "") for k in ("loai", "trang_thai", "tu", "den")}
    rows = []
    if g.ho_so["MaVi"]:
        sql = "SELECT * FROM dbo.f_KH_SaoKeVi(?, ?, ?) WHERE 1 = 1"
        params = [g.ho_so["MaVi"], _ngay(loc["tu"]), _ngay(loc["den"])]
        if loc["loai"]:
            sql += " AND LoaiGD = ?"
            params.append(loc["loai"])
        if loc["trang_thai"]:
            sql += " AND TrangThai = ?"
            params.append(loc["trang_thai"])
        rows = query(sql + " ORDER BY ThoiGianTao DESC, MaGD DESC;", tuple(params))
    return render_template(
        "kh/giao_dich.html",
        giao_dich=rows,
        loc=loc,
        loai_gd=("Nạp tiền", "Thanh toán vé tháng", "Hoàn tiền"),
        trang_thai=("Thành công", "Chờ xử lý", "Thất bại", "Đã hoàn"),
    )


@kh_bp.route("/thong-bao", methods=["GET", "POST"])
def thong_bao():
    if request.method == "POST":
        ma_tb = request.form.get("ma_tb")
        try:
            execute("EXEC dbo.sp_KH_DanhDauDaDoc @MaTB = ?;", (int(ma_tb) if ma_tb else None,))
        except Exception as exc:
            _bao_loi(exc)
        return redirect(url_for("kh.thong_bao"))
    return render_template("kh/thong_bao.html",
                           thong_bao=query("SELECT * FROM dbo.vw_KH_ThongBao ORDER BY DaDoc, ThoiGianTao DESC;"))


@kh_bp.route("/uy-quyen", methods=["GET", "POST"])
def uy_quyen():
    if request.method == "POST":
        try:
            execute(
                "EXEC dbo.sp_KH_UyQuyenVe @MaVe = ?, @TenDangNhapNguoiNhan = ?, @MaVaiTro = ?, @NgayKetThuc = ?;",
                (request.form.get("ma_ve", ""), request.form.get("nguoi_nhan", "").strip(),
                 request.form.get("ma_vai_tro", ""), _ngay(request.form.get("ngay_ket_thuc"))),
            )
            flash("Đã chia sẻ vé. Người nhận sẽ thấy vé trong cổng khách hàng của họ.", "success")
            return redirect(url_for("kh.uy_quyen"))
        except Exception as exc:
            _bao_loi(exc)

    quyen = _quyen_theo_ve()
    ve_co_the_chia_se = [v for v in query("SELECT MaVe, BienSo, NgayHetHan, TrangThai FROM dbo.vw_KH_VeThangCuaToi ORDER BY MaVe;")
                         if "VE.UYQUYEN" in quyen.get(v["MaVe"], set())]
    return render_template(
        "kh/uy_quyen.html",
        uy_quyen=execute("EXEC dbo.sp_KH_DanhSachUyQuyen;"),
        ve_co_the_chia_se=ve_co_the_chia_se,
        vai_tro=query("SELECT * FROM dbo.vw_KH_VaiTroUyQuyen ORDER BY MaVaiTro;"),
        form=request.form,
    )


@kh_bp.route("/uy-quyen/<int:ma_uy_quyen>/thu-hoi", methods=["POST"])
def thu_hoi_uy_quyen(ma_uy_quyen):
    try:
        execute("EXEC dbo.sp_KH_ThuHoiUyQuyen @MaUyQuyen = ?;", (ma_uy_quyen,))
        flash("Đã thu hồi chia sẻ vé.", "success")
    except Exception as exc:
        _bao_loi(exc)
    quay_lai = request.form.get("quay_lai", "")
    return redirect(quay_lai if quay_lai.startswith("/kh") else url_for("kh.uy_quyen"))


@kh_bp.route("/bao-mat", methods=["GET", "POST"])
def bao_mat():
    if request.method == "POST":
        if request.form.get("mat_khau_moi") != request.form.get("nhap_lai"):
            flash("Mật khẩu mới nhập lại không khớp.", "error")
        else:
            try:
                execute("EXEC dbo.sp_KH_DoiMatKhau @MatKhauCu = ?, @MatKhauMoi = ?;",
                        (request.form.get("mat_khau_cu", ""), request.form.get("mat_khau_moi", "")))
                flash("Đã đổi mật khẩu.", "success")
                return redirect(url_for("kh.bao_mat"))
            except Exception as exc:
                _bao_loi(exc)
    return render_template("kh/bao_mat.html",
                           nhat_ky=query("SELECT TOP 10 * FROM dbo.vw_KH_NhatKyDangNhap ORDER BY ThoiGian DESC;"))


@kh_bp.errorhandler(404)
@kh_bp.errorhandler(400)
def _loi_kh(exc):
    return render_template("kh/loi.html", error=getattr(exc, "description", str(exc))), exc.code
