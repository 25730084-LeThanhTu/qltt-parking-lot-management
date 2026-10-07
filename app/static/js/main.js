// ==========================================================================
// CLIENT JAVASCRIPT HỖ TRỢ TƯƠNG TÁC GIAO DIỆN (chỉ xử lý hiển thị, không đổi nghiệp vụ)
// ==========================================================================

const ICON_COPY = '<svg class="ico" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="12" height="12" rx="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';
const ICON_CHECK = '<svg class="ico" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"></path></svg>';

document.addEventListener("DOMContentLoaded", function () {
    // 1. Tự động cuộn tới kết quả sau khi thực thi form POST
    const executeOutput = document.getElementById("execute-output");
    if (executeOutput) {
        executeOutput.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    // 2. Thông báo Flash: đóng thủ công hoặc tự ẩn sau 6 giây
    document.querySelectorAll(".flash-item").forEach((el) => {
        const dismiss = () => {
            el.classList.add("is-leaving");
            setTimeout(() => el.remove(), 350);
        };
        const btn = el.querySelector("[data-dismiss]");
        if (btn) btn.addEventListener("click", dismiss);
        setTimeout(dismiss, 6000);
    });

    // 3. Menu sidebar trên màn hình nhỏ
    const toggleNav = (open) => document.body.classList.toggle("nav-open", open);
    document.querySelectorAll("[data-nav-toggle]").forEach((b) =>
        b.addEventListener("click", () => toggleNav(!document.body.classList.contains("nav-open")))
    );
    document.querySelectorAll("[data-nav-close]").forEach((b) => b.addEventListener("click", () => toggleNav(false)));
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") toggleNav(false);
    });

    // 4. Chuyển giao diện Sáng / Tối (lưu lựa chọn trên trình duyệt)
    document.querySelectorAll("[data-theme-toggle]").forEach((btn) => {
        btn.addEventListener("click", () => {
            const root = document.documentElement;
            const current = root.getAttribute("data-theme") ||
                (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
            const next = current === "dark" ? "light" : "dark";
            root.setAttribute("data-theme", next);
            try { localStorage.setItem("sp-theme", next); } catch (e) {}
        });
    });

    // 5. Tự động thêm nút "Sao chép" cho tất cả thẻ <pre><code>
    document.querySelectorAll("pre code").forEach((codeEl) => {
        const pre = codeEl.parentElement;
        if (pre.classList.contains("no-copy")) return;

        const wrapper = document.createElement("div");
        wrapper.className = "code-block-wrapper";
        pre.parentNode.insertBefore(wrapper, pre);
        wrapper.appendChild(pre);

        const copyBtn = document.createElement("button");
        copyBtn.type = "button";
        copyBtn.className = "code-copy-btn";
        copyBtn.innerHTML = `${ICON_COPY}<span>Sao chép</span>`;
        copyBtn.addEventListener("click", () => {
            copyText(codeEl.innerText).then(() => {
                copyBtn.innerHTML = `${ICON_CHECK}<span>Đã chép</span>`;
                setTimeout(() => { copyBtn.innerHTML = `${ICON_COPY}<span>Sao chép</span>`; }, 2000);
            });
        });
        wrapper.appendChild(copyBtn);
    });
});

// Sao chép văn bản vào clipboard và hiện toast xác nhận
function copyText(text, message) {
    return navigator.clipboard.writeText(text).then(() => {
        showToast(message || "Đã sao chép câu lệnh SQL vào clipboard!");
    }).catch((err) => {
        console.error("Lỗi khi sao chép:", err);
        showToast("Trình duyệt không cho phép sao chép tự động.");
    });
}

// Hàm hiển thị Toast thông báo nổi
function showToast(message) {
    const container = document.getElementById("toast-container");
    if (!container) return;

    const toast = document.createElement("div");
    toast.className = "toast";
    toast.innerHTML = ICON_CHECK;
    const span = document.createElement("span");
    span.textContent = message;
    toast.appendChild(span);
    container.appendChild(toast);

    setTimeout(() => {
        toast.classList.add("is-leaving");
        setTimeout(() => toast.remove(), 300);
    }, 2500);
}

// Chuẩn hóa chuỗi tiếng Việt để tìm kiếm không phân biệt dấu / hoa thường
function normalizeVi(text) {
    return String(text || "")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[̀-ͯ]/g, "")
        .replace(/đ/g, "d")
        .replace(/_/g, " ")   // VI_DIEN_TU khớp với "vi dien tu"
        .trim();
}

// Lọc danh sách phần tử theo từ khóa (dùng thuộc tính data-lot-text)
function filterByText(items, query, emptyEl) {
    const q = normalizeVi(query);
    let shown = 0;
    items.forEach((el) => {
        const match = !q || normalizeVi(el.getAttribute("data-lot-text")).includes(q);
        el.hidden = !match;
        if (match) shown++;
    });
    if (emptyEl) emptyEl.hidden = shown > 0;
    return shown;
}

document.addEventListener("DOMContentLoaded", function () {
    // Bộ chọn bãi đỗ (lot picker): tìm kiếm, điều hướng phím, đóng khi bấm ra ngoài
    document.querySelectorAll("[data-lot-picker]").forEach((picker) => {
        const search = picker.querySelector("[data-lot-search]");
        const options = Array.from(picker.querySelectorAll(".lot-opt"));
        const emptyEl = picker.querySelector("[data-lot-empty]");
        const visible = () => options.filter((o) => !o.hidden);

        picker.addEventListener("toggle", () => {
            if (!picker.open) return;
            if (search) {
                search.value = "";
                filterByText(options, "", emptyEl);
                search.focus();
            }
            const active = picker.querySelector(".lot-opt.active");
            if (active) active.scrollIntoView({ block: "nearest" });
        });

        if (search) {
            search.addEventListener("input", () => filterByText(options, search.value, emptyEl));
            search.addEventListener("keydown", (e) => {
                if (e.key === "ArrowDown") {
                    e.preventDefault();
                    const first = visible()[0];
                    if (first) first.focus();
                } else if (e.key === "Enter") {
                    const list = visible();
                    if (list.length === 1) {
                        e.preventDefault();
                        window.location.href = list[0].href;
                    }
                }
            });
        }

        picker.addEventListener("keydown", (e) => {
            if (e.key === "Escape") {
                picker.open = false;
                picker.querySelector("summary").focus();
                return;
            }
            if (e.key !== "ArrowDown" && e.key !== "ArrowUp") return;
            const list = visible();
            const idx = list.indexOf(document.activeElement);
            if (idx === -1) return;
            e.preventDefault();
            const next = e.key === "ArrowDown" ? list[idx + 1] : list[idx - 1];
            if (next) next.focus();
            else if (e.key === "ArrowUp" && search) search.focus();
        });
    });

    document.addEventListener("click", (e) => {
        document.querySelectorAll("[data-lot-picker][open]").forEach((picker) => {
            if (!picker.contains(e.target)) picker.open = false;
        });
    });

    // Ô tìm kiếm danh bạ chi nhánh trên trang chủ
    document.querySelectorAll("[data-lot-dir-search]").forEach((input) => {
        const dir = document.getElementById(input.getAttribute("data-lot-dir-search"));
        if (!dir) return;
        const cards = Array.from(dir.querySelectorAll("[data-lot-text]"));
        const emptyEl = document.querySelector(`[data-lot-dir-empty="${dir.id}"]`);
        input.addEventListener("input", () => {
            filterByText(cards, input.value, emptyEl);
            // Ẩn nhóm danh mục không còn thẻ nào khớp (trang Bảng dữ liệu / Báo cáo)
            dir.querySelectorAll(".catalog-group").forEach((group) => {
                group.hidden = !group.querySelector("[data-lot-text]:not([hidden])");
            });
        });
    });
});

// Xác nhận trước khi gửi form có tiền hoặc không hoàn tác được (UPGRADE_PLAN 12.1)
// data-confirm="..."                  : hỏi nguyên văn
// data-confirm-amount="... {amount} ...": chèn số tiền từ ô so_tien đã định dạng
document.addEventListener("submit", (e) => {
    const form = e.target;
    if (!(form instanceof HTMLFormElement)) return;
    let message = form.getAttribute("data-confirm");
    const amountTemplate = form.getAttribute("data-confirm-amount");
    if (amountTemplate) {
        const input = form.querySelector("[name='so_tien']");
        const amount = Number(input ? input.value : 0);
        message = amountTemplate.replace("{amount}", amount.toLocaleString("vi-VN"));
    }
    if (message && !window.confirm(message)) e.preventDefault();
});

// Cổng khách hàng /kh: menu thả xuống, hiện/ẩn mật khẩu, chính sách mật khẩu, điền nhanh tài khoản demo và số tiền
document.addEventListener("DOMContentLoaded", function () {
    const dropdowns = document.querySelectorAll("[data-dropdown]");
    document.addEventListener("click", (e) => {
        dropdowns.forEach((d) => { if (d.open && !d.contains(e.target)) d.open = false; });
    });
    document.addEventListener("keydown", (e) => {
        if (e.key !== "Escape") return;
        dropdowns.forEach((d) => {
            if (d.open) { d.open = false; d.querySelector("summary").focus(); }
        });
    });

    document.querySelectorAll("[data-toggle-password]").forEach((btn) => {
        const input = document.getElementById(btn.getAttribute("data-toggle-password"));
        if (!input) return;
        btn.addEventListener("click", () => {
            const show = input.type === "password";
            input.type = show ? "text" : "password";
            btn.setAttribute("aria-pressed", String(show));
            btn.setAttribute("aria-label", show ? "Ẩn mật khẩu" : "Hiện mật khẩu");
        });
    });

    const PASSWORD_RULES = {
        len: (v) => v.length >= 8,
        upper: (v) => /[A-Z]/.test(v),
        lower: (v) => /[a-z]/.test(v),
        digit: (v) => /[0-9]/.test(v),
        special: (v) => /[^A-Za-z0-9]/.test(v),
    };
    document.querySelectorAll("[data-password-policy]").forEach((input) => {
        const list = document.getElementById(input.getAttribute("data-password-policy"));
        if (!list) return;
        const update = () => list.querySelectorAll("[data-rule]").forEach((li) => {
            const rule = PASSWORD_RULES[li.getAttribute("data-rule")];
            li.classList.toggle("is-ok", Boolean(rule && rule(input.value)));
        });
        input.addEventListener("input", update);
        update();
    });

    document.querySelectorAll("[data-fill-login]").forEach((btn) => {
        btn.addEventListener("click", () => {
            const user = document.getElementById("ten_dang_nhap");
            const pass = document.getElementById("mat_khau");
            if (user) user.value = btn.getAttribute("data-fill-login");
            if (pass) {
                pass.value = btn.getAttribute("data-fill-password") || "";
                pass.focus();
            }
        });
    });

    document.querySelectorAll("[data-fill-amount]").forEach((btn) => {
        btn.addEventListener("click", () => {
            const input = document.getElementById(btn.getAttribute("data-target"));
            if (!input) return;
            input.value = btn.getAttribute("data-fill-amount");
            input.focus();
        });
    });
});
