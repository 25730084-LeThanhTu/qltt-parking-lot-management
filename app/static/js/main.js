// ==========================================================================
// CLIENT JAVASCRIPT HỖ TRỢ TƯƠNG TÁC GIAO DIỆN CAO CẤP
// ==========================================================================

document.addEventListener("DOMContentLoaded", function () {
    // 1. Tự động cuộn tới kết quả sau khi thực thi form POST
    const executeOutput = document.getElementById("execute-output");
    if (executeOutput) {
        executeOutput.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    // 2. Tự động làm mờ và ẩn thông báo Flash sau 5 giây
    const flashMessages = document.querySelectorAll(".flash");
    flashMessages.forEach((el) => {
        setTimeout(() => {
            el.style.opacity = "0";
            el.style.transform = "translateY(-10px)";
            el.style.transition = "all 0.4s ease";
            setTimeout(() => el.remove(), 400);
        }, 5000);
    });

    // 3. Tự động thêm nút "Sao chép SQL" cho tất cả thẻ <pre><code>
    const codeBlocks = document.querySelectorAll("pre code");
    codeBlocks.forEach((codeEl) => {
        const pre = codeEl.parentElement;
        if (!pre.classList.contains("no-copy")) {
            // Bao bọc trong wrapper
            const wrapper = document.createElement("div");
            wrapper.className = "code-block-wrapper";
            pre.parentNode.insertBefore(wrapper, pre);
            wrapper.appendChild(pre);

            // Nút sao chép
            const copyBtn = document.createElement("button");
            copyBtn.type = "button";
            copyBtn.className = "code-copy-btn";
            copyBtn.innerHTML = `
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                <span>Sao chép</span>
            `;

            copyBtn.addEventListener("click", () => {
                const text = codeEl.innerText;
                navigator.clipboard.writeText(text).then(() => {
                    copyBtn.innerHTML = `
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#34d399" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        <span style="color: #34d399;">Đã chép!</span>
                    `;
                    showToast("Đã sao chép câu lệnh SQL vào clipboard!");
                    setTimeout(() => {
                        copyBtn.innerHTML = `
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                            <span>Sao chép</span>
                        `;
                    }, 2000);
                }).catch(err => {
                    console.error("Lỗi khi sao chép:", err);
                });
            });

            wrapper.appendChild(copyBtn);
        }
    });
});

// Hàm hiển thị Toast thông báo nổi
function showToast(message) {
    const container = document.getElementById("toast-container");
    if (!container) return;

    const toast = document.createElement("div");
    toast.className = "toast";
    toast.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
        <span>${message}</span>
    `;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = "0";
        toast.style.transform = "translateY(10px)";
        toast.style.transition = "all 0.3s ease";
        setTimeout(() => toast.remove(), 300);
    }, 2500);
}
