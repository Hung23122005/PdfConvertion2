let worker = null;

document.addEventListener("DOMContentLoaded", function () {
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
            showProgress(file.name);

            if (worker) worker.terminate();
            
            // SỬA DÒNG NÀY: DÙNG contextPath TỪ index.jsp
            worker = new Worker(contextPath + "/js/uploadWorker.js");

            worker.onmessage = function (e) {
                if (e.data.type === 'progress') {
                    updateProgress(e.data.percent);
                } else if (e.data.type === 'uploaded') {
                    updateMessage("Đang chuyển đổi sang Word... Vui lòng chờ");
                    startPolling(taskId);
                } else if (e.data.type === 'error') {
                    alert("Lỗi upload: " + e.data.message);
                    hideProgress();
                }
            };

            // SỬA DÒNG NÀY: TRUYỀN contextPath VÀO WORKER
            worker.postMessage({ 
                file: file, 
                taskId: taskId,
                contextPath: contextPath 
            });
        };

        input.click();
    });
});

// CÁC HÀM KHÁC GIỮ NGUYÊN
function showProgress(fileName) {
    let box = document.getElementById("progressContainer");
    if (!box) {
        box = document.createElement("div");
        box.id = "progressContainer";
        box.innerHTML = `
            <div style="margin:50px auto; max-width:700px; padding:25px; background:#fff; border-radius:12px; box-shadow:0 5px 15px rgba(0,0,0,0.1); text-align:center;">
                <p style="margin-bottom:15px;"><strong>Đang xử lý:</strong> <span id="progFileName">${fileName}</span></p>
                <div style="width:100%; height:40px; background:#eee; border-radius:10px; overflow:hidden; margin-bottom:15px;">
                    <div id="progBar" style="width:0%; height:100%; background:#fa4f0b; transition:width 0.6s ease; color:white; line-height:40px; font-weight:bold;">0%</div>
                </div>
                <p id="progMsg" style="color:#555; font-size:15px;">Đang upload...</p>
            </div>
        `;
        document.querySelector(".content").appendChild(box);
    } else {
        box.style.display = "block";
        document.getElementById("progFileName").textContent = fileName;
        updateProgress(0);
        updateMessage("Đang upload...");
    }
}

function updateProgress(percent) {
    const bar = document.getElementById("progBar");
    if (bar) {
        bar.style.width = percent + "%";
        bar.textContent = percent + "%";
    }
}

function updateMessage(msg) {
    const el = document.getElementById("progMsg");
    if (el) el.innerHTML = msg;
}

function hideProgress() {
    const box = document.getElementById("progressContainer");
    if (box) box.style.display = "none";
}

function startPolling(taskId) {
    const interval = setInterval(() => {
        fetch(contextPath + "/status?taskId=" + taskId)
            .then(r => r.json())
            .then(data => {
                if (data.status === "done") {
                    clearInterval(interval);
                    updateProgress(100);
                    updateMessage(`Hoàn thành! <a href="${contextPath}/download?file=${data.file}" style="color:#fa4f0b; font-weight:bold; text-decoration:underline;">Tải file Word ngay</a>`);
                } else if (data.status === "processing") {
                    const fake = 70 + Math.random() * 25;
                    updateProgress(Math.min(fake, 98));
                }
            })
            .catch(() => {});
    }, 3000);
}