let worker = null;

// ===== NEW FEATURE: Smooth progress =====
let smoothProgress = 0;

// ===== MAIN FEATURE: PDF Preview =====
let pdfDoc = null;
let currentPage = 1;
let totalPages = 0;
let currentFile = null;
let pdfjsLib = null;


// ==================================
// 🔥 Load PDF.js
// ==================================
async function loadPdfJs() {
    if (pdfjsLib) return pdfjsLib;

    try {
        if (typeof window.pdfjsLib !== "undefined") {
            pdfjsLib = window.pdfjsLib;
        } else {
            const pdfjsModule = await import(contextPath + "/pdfjs/build/pdf.mjs");
            pdfjsLib = pdfjsModule;
            window.pdfjsLib = pdfjsLib;
        }

        if (pdfjsLib.GlobalWorkerOptions) {
            pdfjsLib.GlobalWorkerOptions.workerSrc = contextPath + "/pdfjs/build/pdf.worker.mjs";
        }

        return pdfjsLib;

    } catch (error) {
        console.error("Error loading PDF.js:", error);
        throw error;
    }
}



// ==================================
// ⏳ Khi trang load – kiểm tra resume task
// ==================================
document.addEventListener("DOMContentLoaded", function () {

    const resumeTaskId = sessionStorage.getItem("activeTaskId");
    if (resumeTaskId) {
        console.log("🔄 Resume task:", resumeTaskId);
        showProgress("Đang tiếp tục chuyển đổi...");
        startPolling(resumeTaskId);
    }

    setupPreviewModal();

    const uploadLink = document.getElementById("uploadLink");
    if (!uploadLink) return;

    uploadLink.addEventListener("click", function (e) {
        e.preventDefault();

        const input = document.createElement("input");
        input.type = "file";
        input.accept = ".pdf";

        input.onchange = async function () {
            const file = this.files[0];
            if (!file) return;

            currentFile = file;   // Giữ file để convert sau
            await showPdfPreview(file); // Hiện preview PDF
        };

        input.click();
    });
});



// ==================================
// 📌 PREVIEW PDF – GỘP TỪ MAIN
// ==================================
function setupPreviewModal() {
    const modal = document.getElementById("pdfPreviewModal");
    const closeBtn = document.getElementById("pdfPreviewClose");
    const cancelBtn = document.getElementById("pdfCancelBtn");
    const convertBtn = document.getElementById("pdfConvertBtn");
    const prevBtn = document.getElementById("pdfPrevPage");
    const nextBtn = document.getElementById("pdfNextPage");

    [closeBtn, cancelBtn].forEach(btn => {
        if (btn) btn.addEventListener("click", closePdfPreview);
    });

    if (convertBtn) {
        convertBtn.addEventListener("click", () => {
            if (currentFile) {
                closePdfPreview();
                startConvert(currentFile);
            }
        });
    }

    if (prevBtn) {
        prevBtn.addEventListener("click", () => {
            if (currentPage > 1) {
                currentPage--;
                renderPage(currentPage);
            }
        });
    }

    if (nextBtn) {
        nextBtn.addEventListener("click", () => {
            if (currentPage < totalPages) {
                currentPage++;
                renderPage(currentPage);
            }
        });
    }

    if (modal) {
        modal.addEventListener("click", (e) => {
            if (e.target === modal) closePdfPreview();
        });
    }
}

async function showPdfPreview(file) {
    const modal = document.getElementById("pdfPreviewModal");
    const title = document.getElementById("pdfPreviewTitle");
    const container = document.getElementById("pdfCanvasContainer");

    modal.classList.add("show");
    title.textContent = "Xem trước: " + file.name;
    container.innerHTML = "<div style='padding:40px;text-align:center;'>Đang tải PDF...</div>";

    try {
        const pdfjs = await loadPdfJs();
        const arrayBuffer = await file.arrayBuffer();
        const loadingTask = pdfjs.getDocument({ data: arrayBuffer });
        pdfDoc = await loadingTask.promise;

        totalPages = pdfDoc.numPages;
        currentPage = 1;
		document.getElementById("pdfConvertBtn").style.display = "inline-block";
        await renderPage(1);

		} catch (err) {
		    console.error(err);
		    container.innerHTML = "<div style='padding:40px;text-align:center;color:red;'>Lỗi tải PDF.</div>";

		    // 🔥 ẨN NÚT "Chuyển đổi sang Word" khi file không phải PDF hoặc PDF lỗi
			document.getElementById("pdfConvertBtn").style.setProperty("display", "none", "important");


		    return;
		}

}

async function renderPage(pageNum) {
    if (!pdfDoc) return;

    const container = document.getElementById("pdfCanvasContainer");
    const pageInfo = document.getElementById("pdfPageInfo");

    const page = await pdfDoc.getPage(pageNum);
    const viewport = page.getViewport({ scale: 1.5 });

    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");

    canvas.width = viewport.width;
    canvas.height = viewport.height;

    container.innerHTML = "";
    container.appendChild(canvas);

    await page.render({ canvasContext: ctx, viewport: viewport }).promise;

    pageInfo.textContent = `Trang ${pageNum} / ${totalPages}`;
}

function closePdfPreview() {
    const modal = document.getElementById("pdfPreviewModal");
    modal.classList.remove("show");

    if (pdfDoc) pdfDoc.destroy();
    pdfDoc = null;

    currentPage = 1;
    totalPages = 0;
}



// ==================================
// 🚀 BẮT ĐẦU UPLOAD + CONVERT = GỘP
// ==================================
function startConvert(file) {
    const taskId = "task_" + Date.now();

    showProgress(file.name);

    if (worker) worker.terminate();

    worker = new Worker(contextPath + "/js/uploadWorker.js");

    worker.onmessage = function (e) {

        if (e.data.type === "progress") {
            updateProgress(e.data.percent);

        } else if (e.data.type === "uploaded") {

            updateMessage("Upload xong! Đang chuyển đổi...");

            sessionStorage.setItem("activeTaskId", taskId);

            startPolling(taskId);

        } else if (e.data.type === "error") {
            alert("Lỗi upload: " + e.data.message);
            hideProgress();
        }
    };

    worker.postMessage({
        file: file,
        taskId: taskId,
        contextPath: contextPath
    });
}



// ==================================
// UI PROGRESS – GỘP MỚI + CŨ
// ==================================
function showProgress(fileName) {
    let box = document.getElementById("progressContainer");

    if (!box) {
        box = document.createElement("div");
        box.id = "progressContainer";

        box.innerHTML = `
            <div style="margin:50px auto; max-width:700px; padding:25px; background:#fff; border-radius:12px; text-align:center;">
                <p><strong>Đang xử lý:</strong> <span id="progFileName">${fileName}</span></p>
                <div style="width:100%; height:40px; background:#eee; border-radius:10px; overflow:hidden;">
                    <div id="progBar"
                         style="width:0%; height:100%; background:#fa4f0b; line-height:40px; color:white; font-weight:bold;">0%</div>
                </div>
                <p id="progMsg" style="margin-top:10px;">Đang chuẩn bị...</p>
            </div>
        `;

        document.querySelector(".content").appendChild(box);
    }

    smoothProgress = 0;
    updateProgress(0);
}

function updateProgress(targetPercent) {
    if (targetPercent < smoothProgress) {
        targetPercent = smoothProgress;
    }

    const bar = document.getElementById("progBar");
    if (!bar) return;

    const step = () => {
        if (smoothProgress < targetPercent) {
            smoothProgress++;
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

    if (state === "queued") el.innerHTML = "Đang xếp hàng xử lý...";
    else if (state === "splitting_pdf") el.innerHTML = "Đang tách PDF...";
    else if (state.startsWith("converting_part_"))
        el.innerHTML = `Đang xử lý phần ${part}/${total}...`;
    else if (state === "merging") el.innerHTML = "Đang gộp file...";
    else if (state === "saving_to_db") el.innerHTML = "Đang lưu dữ liệu...";
    else el.innerHTML = msg;
}

function hideProgress() {
    const box = document.getElementById("progressContainer");
    if (box) box.style.display = "none";
}



// ==================================
// 🔄 POLLING = FULL NEW VERSION
// ==================================
function startPolling(taskId) {
    const interval = setInterval(() => {

        fetch(contextPath + "/status?taskId=" + encodeURIComponent(taskId) + "&_=" + Date.now())
            .then(r => r.json())
            .then(data => {

                if (typeof data.progress === "number") {
                    updateProgress(data.progress);
                }

                if (data.status) {
                    updateStatus(data.status, data.message, data.currentPart, data.totalPart);
                }

                if (data.status === "done" && data.file) {
                    clearInterval(interval);
                    updateProgress(100);

                    sessionStorage.removeItem("activeTaskId");

                    updateMessage(`
                        Hoàn thành! 🎉<br/>
                        <a href="${contextPath}/download?file=${data.file}"
                           style="display:inline-block; margin-top:10px; background:#28a745; color:white; padding:10px 22px; border-radius:8px; font-weight:bold;">
                            Tải file Word
                        </a>
                    `);
                }

                if (data.status === "error") {
                    clearInterval(interval);
                    updateMessage("Có lỗi xảy ra: " + data.message);
                }
            })
            .catch(() => {});

    }, 1200);
}
