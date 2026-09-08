// ==========================================================================
// CLIENT JAVASCRIPT HỖ TRỢ TƯƠNG TÁC GIAO DIỆN
// ==========================================================================

document.addEventListener("DOMContentLoaded", function () {
    // Tự động cuộn tới kết quả sau khi submit form
    const executeOutput = document.getElementById("execute-output");
    if (executeOutput) {
        executeOutput.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    // Tự động ẩn thông báo Flash sau 6 giây
    const flashMessages = document.querySelectorAll(".flash");
    flashMessages.forEach((el) => {
        setTimeout(() => {
            el.style.opacity = "0";
            el.style.transition = "opacity 0.5s ease";
            setTimeout(() => el.remove(), 500);
        }, 6000);
    });
});
