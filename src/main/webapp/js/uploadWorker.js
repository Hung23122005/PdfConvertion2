// WebContent/js/uploadWorker.js
self.onmessage = function(e) {
    const { file, taskId, contextPath = '' } = e.data;

    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    formData.append("file", file);
    formData.append("taskId", taskId);

    xhr.upload.onprogress = function(event) {
        if (event.lengthComputable) {
            const percent = Math.round((event.loaded / event.total) * 100);
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

    // ĐƯỜNG DẪN ĐÚNG 100% – DÙ PROJECT NAME LÀ GÌ CŨNG CHẠY!!!
    const uploadUrl = (contextPath || '') + "/convert";
    xhr.open("POST", uploadUrl, true);
    xhr.send(formData);
};