const workers = new Map();
const pollers = new Map();
const taskMetadata = new Map();
const ACTIVE_TASKS_KEY = "multiConvertTasks";

// ===== MAIN FEATURE: PDF Preview =====
let pdfDoc = null;
let currentPage = 1;
let totalPages = 0;
let currentFile = null;
let pdfjsLib = null;

// ==================================
// 📁 Persist danh sách task
// ==================================
function restoreTasksFromSession() {
    try {
        const raw = sessionStorage.getItem(ACTIVE_TASKS_KEY);
        if (!raw) return;
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) {
            parsed.forEach(item => {
                if (item && item.taskId && item.fileName) {
                    taskMetadata.set(item.taskId, item.fileName);
                }
            });
        }
    } catch (err) {
        console.warn("Không đọc được danh sách task từ sessionStorage", err);
    }
}

function persistTasksToSession() {
    const data = Array.from(taskMetadata.entries()).map(([taskId, fileName]) => ({
        taskId,
        fileName
    }));
    sessionStorage.setItem(ACTIVE_TASKS_KEY, JSON.stringify(data));
}

function registerTask(taskId, fileName) {
    taskMetadata.set(taskId, fileName);
    persistTasksToSession();
}

function unregisterTask(taskId) {
    taskMetadata.delete(taskId);
    persistTasksToSession();
}

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

function createTaskId() {
    if (window.crypto && window.crypto.randomUUID) {
        return "task_" + window.crypto.randomUUID();
    }
    return "task_" + Date.now() + "_" + Math.floor(Math.random() * 100000);
}

function isPdfFile(file) {
    if (!file) return false;
    if (file.type) {
        return file.type === "application/pdf";
    }
    return file.name && file.name.toLowerCase().endsWith(".pdf");
}



// ==================================
// ⏳ Khi trang load – kiểm tra resume task
// ==================================
document.addEventListener("DOMContentLoaded", function () {
    restoreTasksFromSession();

    taskMetadata.forEach((fileName, taskId) => {
        showProgress(taskId, fileName, true);
        startPolling(taskId);
    });

    setupPreviewModal();

    const uploadLink = document.getElementById("uploadLink");
    if (!uploadLink) return;

    uploadLink.addEventListener("click", function (e) {
        e.preventDefault();

        const input = document.createElement("input");
        input.type = "file";
        input.accept = ".pdf";
        input.multiple = true;

        input.onchange = async function () {
            const files = Array.from(this.files || []);
            if (!files.length) return;

            if (files.length === 1) {
                const file = files[0];
                if (!isPdfFile(file)) {
                    alert("Vui lòng chọn đúng file PDF.");
                    return;
                }
                currentFile = file;
                await showPdfPreview(file);
                return;
            }

            files.forEach(file => {
                if (isPdfFile(file)) {
                    startConvert(file);
                } else {
                    alert(`"${file.name}" không phải tệp PDF hợp lệ.`);
                }
            });
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
function cleanupWorker(taskId) {
    const worker = workers.get(taskId);
    if (worker) {
        worker.terminate();
        workers.delete(taskId);
    }
}

function stopPolling(taskId) {
    const interval = pollers.get(taskId);
    if (interval) {
        clearInterval(interval);
        pollers.delete(taskId);
    }
}

function startConvert(file) {
    const taskId = createTaskId();

    registerTask(taskId, file.name);
    showProgress(taskId, file.name);
    updateMessage(taskId, "Đang tải lên...");
    updateProgress(taskId, 1);

    const worker = new Worker(contextPath + "/js/uploadWorker.js");
    workers.set(taskId, worker);

    worker.onmessage = function (e) {
        if (e.data.type === "progress") {
            updateProgress(taskId, e.data.percent);
        } else if (e.data.type === "uploaded") {
            cleanupWorker(taskId);
            updateMessage(taskId, "Upload xong! Đang chuyển đổi...");
            startPolling(taskId);
        } else if (e.data.type === "error") {
            cleanupWorker(taskId);
            updateMessage(taskId, "Lỗi upload: " + (e.data.message || ""));
        }
    };

    worker.onerror = function (err) {
        cleanupWorker(taskId);
        updateMessage(taskId, "Có lỗi khi upload: " + err.message);
    };

    worker.postMessage({
        file: file,
        taskId: taskId,
        contextPath: contextPath
    });

    return taskId;
}



// ==================================
// UI PROGRESS – HỖ TRỢ NHIỀU TASK
// ==================================
function ensureProgressList() {
    let list = document.getElementById("progressList");
    if (!list) {
        list = document.createElement("div");
        list.id = "progressList";
        list.className = "progress-list";
        const container = document.querySelector(".content");
        if (container) {
            container.appendChild(list);
        }
    }
    return list;
}

function buildProgressCard(taskId, fileName) {
    const card = document.createElement("div");
    card.className = "progress-card";
    card.id = `progress-${taskId}`;
    card.innerHTML = `
        <h4 id="progFileName-${taskId}"></h4>
        <div class="progress-bar-shell">
            <div class="progress-bar-fill" id="progBar-${taskId}">0%</div>
        </div>
        <p class="progress-message" id="progMsg-${taskId}">Đang chuẩn bị...</p>
    `;
    const title = card.querySelector(`#progFileName-${taskId}`);
    if (title) {
        title.textContent = fileName;
    }
    return card;
}

function showProgress(taskId, fileName, isResume = false) {
    const list = ensureProgressList();
    if (!list) return;

    let card = document.getElementById(`progress-${taskId}`);
    if (!card) {
        card = buildProgressCard(taskId, fileName);
        list.appendChild(card);
    } else {
        const title = document.getElementById(`progFileName-${taskId}`);
        if (title) title.textContent = fileName;
    }

    updateProgress(taskId, isResume ? 5 : 0);
    updateMessage(taskId, isResume ? "Đang kiểm tra trạng thái..." : "Đang chuẩn bị...");
}

function updateProgress(taskId, percent) {
    const bar = document.getElementById(`progBar-${taskId}`);
    if (!bar) return;
    const safePercent = Math.max(0, Math.min(100, Math.round(percent || 0)));
    bar.style.width = safePercent + "%";
    bar.textContent = safePercent + "%";
}

function updateMessage(taskId, msg) {
    const el = document.getElementById(`progMsg-${taskId}`);
    if (el) el.innerHTML = msg || "";
}

function updateStatus(taskId, state, msg, part, total) {
    if (state === "queued") {
        updateMessage(taskId, "Đang xếp hàng xử lý...");
    } else if (state === "splitting_pdf") {
        updateMessage(taskId, "Đang tách PDF...");
    } else if (state && state.startsWith("converting_part_")) {
        updateMessage(taskId, `Đang xử lý phần ${part}/${total}...`);
    } else if (state === "merging") {
        updateMessage(taskId, "Đang gộp file...");
    } else if (state === "saving_to_db") {
        updateMessage(taskId, "Đang lưu dữ liệu...");
    } else if (state === "error") {
        updateMessage(taskId, msg || "Đã xảy ra lỗi.");
    } else {
        updateMessage(taskId, msg || "Đang xử lý...");
    }
}

function hideProgress(taskId) {
    const card = document.getElementById(`progress-${taskId}`);
    if (card) {
        card.remove();
    }
}



// ==================================
// 🔄 POLLING = FULL NEW VERSION
// ==================================
function startPolling(taskId) {
    if (pollers.has(taskId)) return;

    const interval = setInterval(() => {
        fetch(contextPath + "/status?taskId=" + encodeURIComponent(taskId) + "&_=" + Date.now())
            .then(r => r.json())
            .then(data => {
                if (!data) return;

                if (typeof data.progress === "number") {
                    updateProgress(taskId, data.progress);
                }

                if (data.status === "notfound") {
                    stopPolling(taskId);
                    unregisterTask(taskId);
                    updateMessage(taskId, "Task không còn tồn tại hoặc đã hết hạn.");
                    return;
                }

                if (data.status) {
                    updateStatus(taskId, data.status, data.message, data.currentPart, data.totalPart);
                }

                if (data.status === "done" && data.file) {
                    stopPolling(taskId);
                    unregisterTask(taskId);
                    updateProgress(taskId, 100);
                    const downloadUrl = `${contextPath}/download?file=${encodeURIComponent(data.file)}`;
                    updateMessage(taskId, `
                        Hoàn thành! 🎉<br/>
                        <a href="${downloadUrl}"
                           style="display:inline-block; margin-top:10px; background:#28a745; color:white; padding:10px 22px; border-radius:8px; font-weight:bold;">
                            Tải file Word
                        </a>
                    `);
                    return;
                }

                if (data.status === "error") {
                    stopPolling(taskId);
                    unregisterTask(taskId);
                    updateMessage(taskId, "Có lỗi xảy ra: " + (data.message || ""));
                }
            })
            .catch(() => {
                updateMessage(taskId, "Mất kết nối tới máy chủ, đang thử lại...");
            });

    }, 1200);

    pollers.set(taskId, interval);
}
