let worker = null;
let pdfDoc = null;
let currentPage = 1;
let totalPages = 0;
let currentFile = null;

// PDF.js will be loaded as a module
// We'll access it via window.pdfjsLib after it loads
let pdfjsLib = null;

async function loadPdfJs() {
    if (pdfjsLib) return pdfjsLib;
    
    try {
        // Wait for PDF.js to be available
        // PDF.js is loaded as a module, so we need to access it differently
        if (typeof window.pdfjsLib !== 'undefined') {
            pdfjsLib = window.pdfjsLib;
        } else {
            // Try dynamic import
            const pdfjsModule = await import(contextPath + '/pdfjs/build/pdf.mjs');
            pdfjsLib = pdfjsModule;
            window.pdfjsLib = pdfjsLib;
        }
        
        // Set worker path
        if (pdfjsLib && pdfjsLib.GlobalWorkerOptions) {
            pdfjsLib.GlobalWorkerOptions.workerSrc = contextPath + '/pdfjs/build/pdf.worker.mjs';
        }
        
        return pdfjsLib;
    } catch (error) {
        console.error('Error loading PDF.js:', error);
        // Fallback: try to use global pdfjsLib if available
        if (typeof pdfjsLib === 'undefined' && typeof window.pdfjsLib !== 'undefined') {
            pdfjsLib = window.pdfjsLib;
            return pdfjsLib;
        }
        throw error;
    }
}

document.addEventListener("DOMContentLoaded", function () {
    const uploadLink = document.getElementById("uploadLink");
    if (!uploadLink) return;

    // Setup preview modal controls
    setupPreviewModal();

    uploadLink.addEventListener("click", function (e) {
        e.preventDefault();

        const input = document.createElement("input");
        input.type = "file";
        input.accept = ".pdf";

        input.onchange = async function () {
            const file = this.files[0];
            if (!file) return;

            currentFile = file;
            await showPdfPreview(file);
        };

        input.click();
    });
});

// Setup preview modal event listeners
function setupPreviewModal() {
    const modal = document.getElementById("pdfPreviewModal");
    const closeBtn = document.getElementById("pdfPreviewClose");
    const cancelBtn = document.getElementById("pdfCancelBtn");
    const convertBtn = document.getElementById("pdfConvertBtn");
    const prevBtn = document.getElementById("pdfPrevPage");
    const nextBtn = document.getElementById("pdfNextPage");

    // Close modal
    [closeBtn, cancelBtn].forEach(btn => {
        if (btn) {
            btn.addEventListener("click", () => {
                closePdfPreview();
            });
        }
    });

    // Convert button
    if (convertBtn) {
        convertBtn.addEventListener("click", () => {
            if (currentFile) {
                closePdfPreview();
                startConvert(currentFile);
            }
        });
    }

    // Page navigation
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

    // Close on outside click
    if (modal) {
        modal.addEventListener("click", (e) => {
            if (e.target === modal) {
                closePdfPreview();
            }
        });
    }
}

// Show PDF preview
async function showPdfPreview(file) {
    const modal = document.getElementById("pdfPreviewModal");
    const title = document.getElementById("pdfPreviewTitle");
    const container = document.getElementById("pdfCanvasContainer");

    if (!modal || !container) return;

    // Show modal
    modal.classList.add("show");
    if (title) {
        title.textContent = 'Xem trước: ' + file.name;
    }

    // Show loading
    container.innerHTML = '<div style="padding: 40px; text-align: center; color: #666;">Đang tải PDF...</div>';

    try {
        // Load PDF.js
        const pdfjs = await loadPdfJs();

        // Read file as array buffer
        const arrayBuffer = await file.arrayBuffer();

        // Load PDF document
        const loadingTask = pdfjs.getDocument({ data: arrayBuffer });
        pdfDoc = await loadingTask.promise;
        totalPages = pdfDoc.numPages;
        currentPage = 1;

        // Render first page
        await renderPage(1);

    } catch (error) {
        console.error("Error loading PDF:", error);
        container.innerHTML =
            '<div style="padding: 40px; text-align: center; color: #e74c3c;">' +
                '<p style="font-size: 18px; margin-bottom: 10px;">Lỗi khi tải PDF</p>' +
                '<p style="font-size: 14px; color: #666;">' + error.message + '</p>' +
            '</div>';
    }
}

// Render a specific page
async function renderPage(pageNum) {
    if (!pdfDoc) return;

    const container = document.getElementById("pdfCanvasContainer");
    const pageInfo = document.getElementById("pdfPageInfo");
    const prevBtn = document.getElementById("pdfPrevPage");
    const nextBtn = document.getElementById("pdfNextPage");

    try {
        // Get page
        const page = await pdfDoc.getPage(pageNum);
        const viewport = page.getViewport({ scale: 1.5 });

        // Create canvas
        const canvas = document.createElement("canvas");
        const context = canvas.getContext("2d");
        canvas.height = viewport.height;
        canvas.width = viewport.width;

        // Clear container and add canvas
        container.innerHTML = "";
        container.appendChild(canvas);

        // Render PDF page
        const renderContext = {
            canvasContext: context,
            viewport: viewport
        };

        await page.render(renderContext).promise;

        // Update page info
        if (pageInfo) {
            pageInfo.textContent = 'Trang ' + pageNum + ' / ' + totalPages;
        }

        // Update navigation buttons
        if (prevBtn) {
            prevBtn.disabled = pageNum <= 1;
        }
        if (nextBtn) {
            nextBtn.disabled = pageNum >= totalPages;
        }

    } catch (error) {
        console.error("Error rendering page:", error);
        if (container) {
            container.innerHTML =
                '<div style="padding: 40px; text-align: center; color: #e74c3c;">' +
                    'Lỗi khi hiển thị trang ' + pageNum +
                '</div>';
        }
    }
}

// Close PDF preview
function closePdfPreview() {
    const modal = document.getElementById("pdfPreviewModal");
    if (modal) {
        modal.classList.remove("show");
    }

    // Dọn PDF khỏi bộ nhớ
    if (pdfDoc) {
        pdfDoc.destroy();
        pdfDoc = null;
    }

    currentPage = 1;
    totalPages = 0;

    // ❌ Không được reset currentFile
    // Nếu reset thì startConvert(currentFile) sẽ null → convert fail
}



// =======================
// ⚡ BẮT ĐẦU UPLOAD & CONVERT
// =======================
function startConvert(file) {
    const taskId = "task_" + Date.now();

    showProgress(file.name);

    if (worker) worker.terminate();
    worker = new Worker(contextPath + "/js/uploadWorker.js");

    worker.onmessage = function (e) {
        if (e.data.type === "progress") {
            updateProgress(e.data.percent);

        } else if (e.data.type === "uploaded") {
            updateMessage("Đang chuyển đổi sang Word...");
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



// =======================
// ⚡ PROGRESS UI
// =======================
function showProgress(fileName) {
    let box = document.getElementById("progressContainer");
    if (!box) {
        box = document.createElement("div");
        box.id = "progressContainer";

        box.innerHTML =
            '<div style="margin:50px auto; max-width:700px; padding:25px; background:#fff; border-radius:12px; box-shadow:0 5px 15px rgba(0,0,0,0.1); text-align:center;">' +
                '<p><strong>Đang xử lý:</strong> <span id="progFileName">' + fileName + '</span></p>' +
                '<div style="width:100%; height:40px; background:#eee; border-radius:10px; overflow:hidden;">' +
                    '<div id="progBar" style="width:0%; height:100%; background:#fa4f0b; transition:width .6s ease; color:white; line-height:40px; font-weight:bold;">' +
                        '0%' +
                    '</div>' +
                '</div>' +
                '<p id="progMsg" style="color:#555; font-size:15px;">Đang upload...</p>' +
            '</div>';

        document.querySelector(".content").appendChild(box);
    } else {
        box.style.display = "block";
        document.getElementById("progFileName").textContent = fileName;
    }

    updateProgress(0);
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

// =======================
// ⚡ POLLING CHECK STATUS
// =======================
function startPolling(taskId) {
    const interval = setInterval(() => {
        fetch(contextPath + "/status?taskId=" + taskId)
            .then(r => r.json())
            .then(data => {
                if (data.status === "done") {
                    clearInterval(interval);
                    updateProgress(100);

                    updateMessage(
                        'Hoàn thành! ' +
                        '<a href="' + contextPath + '/download?file=' + data.file + '" ' +
                           'style="color:#fa4f0b; font-weight:bold;">' +
                           'Tải file Word ngay' +
                        '</a>'
                    );

                } else if (data.status === "processing") {
                    const fake = 70 + Math.random() * 25;
                    updateProgress(Math.min(fake, 98));
                }
            })
            .catch(() => {});
    }, 3000);
}