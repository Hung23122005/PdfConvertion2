// WebContent/js/uploadWorker.js
self.onmessage = function(e) {
    const { file, taskId, contextPath = '' } = e.data;

    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    formData.append("file", file);
    // taskId gửi qua URL, không cần append vào form

    xhr.upload.onprogress = function(event) {
        if (event.lengthComputable) {
            // Map 0–100% upload -> 0–10% tổng
            const rawPercent = (event.loaded / event.total) * 10;
            const percent = Math.round(rawPercent);
            self.postMessage({ type: 'progress', percent });
        }
    };

    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                self.postMessage({ type: 'uploaded', taskId });
            } else {
                self.postMessage({
                    type: 'error',
                    message: 'Upload failed: ' + xhr.status
                });
            }
        }
    };

    const uploadUrl = (contextPath || '') + "/convert?taskId=" + encodeURIComponent(taskId);
    xhr.open("POST", uploadUrl, true);
    xhr.send(formData);
};
