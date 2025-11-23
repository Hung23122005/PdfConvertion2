let worker = null;
let smoothProgress = 0;

document.addEventListener("DOMContentLoaded", function () {

    // ================================
    // 🔥 1. Resume progress khi reload
    // ================================
    const resumeTaskId = sessionStorage.getItem("activeTaskId");
    if (resumeTaskId) {
        console.log("🔄 Resume task:", resumeTaskId);
        showProgress("Đang tiếp tục chuyển đổi...");
        startPolling(resumeTaskId);
    }


    const uploadLink = document.getElementById("uploadLink");
    if (!uploadLink) return;

    uploadLink.addEventListener("click", function (e) {
        e.preventDefault();

        const input = document.createElement("input");
        input.type = "file";
        input.accept = ".pdf";

        input.onchange = function () {
            const file = this.files[0];
            if (!file) return;

            const taskId = "task_" + Date.now();
            smoothProgress = 0;
            showProgress(file.name);

            if (worker) worker.terminate();

            worker = new Worker(contextPath + "/js/uploadWorker.js");

            worker.onmessage = function (e) {
                if (e.data.type === 'progress') {

                    updateProgress(e.data.percent);
                    updateMessage("Đang upload file...");

                } else if (e.data.type === 'uploaded') {

                    updateMessage("Upload xong! Đang chuyển sang bước xử lý trên server...");

                    // 🔥 LƯU TASK ID ĐỂ RESUME SAU NẾU RỜI TRANG
                    sessionStorage.setItem("activeTaskId", taskId);

                    startPolling(taskId);

                } else if (e.data.type === 'error') {

                    alert("Lỗi upload: " + e.data.message);
                    hideProgress();
                }
            };

            worker.postMessage({
                file: file,
                taskId: taskId,
                contextPath: contextPath
            });
        };

        input.click();
    });
});


function showProgress(fileName) {
    let box = document.getElementById("progressContainer");
    if (!box) {
        box = document.createElement("div");
        box.id = "progressContainer";
        box.innerHTML = `
            <div style="margin:50px auto; max-width:700px; padding:25px; background:#fff; border-radius:12px; box-shadow:0 5px 15px rgba(0,0,0,0.1); text-align:center;">
                <p style="margin-bottom:15px;"><strong>Đang xử lý:</strong> <span id="progFileName">${fileName}</span></p>
                <div style="width:100%; height:40px; background:#eee; border-radius:10px; overflow:hidden; margin-bottom:15px;">
                    <div id="progBar" style="width:0%; height:100%; background:#fa4f0b; transition:width 0.3s ease; color:white; line-height:40px; font-weight:bold;">0%</div>
                </div>
                <p id="progMsg" style="color:#555; font-size:15px;">Đang chuẩn bị...</p>
            </div>
        `;
        document.querySelector(".content").appendChild(box);
    } else {
        box.style.display = "block";
        document.getElementById("progFileName").textContent = fileName;
        smoothProgress = 0;
        updateProgress(0);
        updateMessage("Đang chuẩn bị...");
    }
}

function updateProgress(targetPercent) {
    if (targetPercent < smoothProgress) {
        targetPercent = smoothProgress;
    }

    const bar = document.getElementById("progBar");
    if (!bar) return;

    const step = () => {
        if (smoothProgress < targetPercent) {
            smoothProgress += 1;
            if (smoothProgress > targetPercent) smoothProgress = targetPercent;

            bar.style.width = smoothProgress + "%";
            bar.textContent = smoothProgress + "%";

            requestAnimationFrame(step);
        }
    };

    requestAnimationFrame(step);
}

function updateMessage(msg) {
    const el = document.getElementById("progMsg");
    if (el) el.innerHTML = msg;
}

function updateStatus(state, msg, part, total) {
    const el = document.getElementById("progMsg");
    if (!el) return;

    switch (true) {
        case state === "queued":
            el.innerHTML = "Đang xếp hàng xử lý trên server...";
            break;

        case state === "splitting_pdf":
            el.innerHTML = "Đang tách file PDF thành từng phần nhỏ...";
            break;

        case state.startsWith("converting_part_"):
            el.innerHTML = `Đang chuyển đổi phần <b>${part}/${total}</b>...`;
            break;

        case state === "merging":
            el.innerHTML = "Đang gộp các file Word lại thành một file duy nhất...";
            break;

        case state === "saving_to_db":
            el.innerHTML = "Đang lưu thông tin vào hệ thống...";
            break;

        default:
            el.innerHTML = msg;
            break;
    }
}

function hideProgress() {
    const box = document.getElementById("progressContainer");
    if (box) box.style.display = "none";
}


function startPolling(taskId) {

    const interval = setInterval(() => {

        fetch(contextPath + "/status?taskId=" + encodeURIComponent(taskId) + "&_=" + Date.now(), {
            cache: "no-cache"
        })
        .then(r => r.json())
        .then(data => {

            if (typeof data.progress === "number") {
                updateProgress(data.progress);
            }

            if (data.status) {
                updateStatus(
                    data.status,
                    data.message,
                    data.currentPart,
                    data.totalPart
                );
            }

            if (data.status === "done" && data.file) {

                clearInterval(interval);

                updateProgress(100);

                // 🔥 XOÁ TASK ID — đã xử lý xong!
                sessionStorage.removeItem("activeTaskId");

                const el = document.getElementById("progMsg");
                if (el) {
                    el.innerHTML = `
                        Hoàn thành! 🎉<br/>
                        <a href="${contextPath}/download?file=${data.file}"
                           style="display:inline-block; margin-top:10px; background:#28a745;color:white;
                                  padding:10px 22px;border-radius:8px;text-decoration:none;font-weight:bold;">
                           Tải file Word ngay
                        </a>
                    `;
                }
            }

            if (data.status === "error") {
                clearInterval(interval);
                updateMessage("Có lỗi xảy ra: " + (data.message || "Unknown error"));
            }

        })
        .catch(() => {});
    }, 1200);
}
