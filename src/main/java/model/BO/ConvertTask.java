// src/model/BO/ConvertTask.java
package model.BO;

import javax.servlet.http.HttpSession;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

public class ConvertTask extends Thread {
    private final String taskId;
    private final String inputPath;
    private final String originalName;
    private final HttpSession session;

    private volatile String status = "queued";
    private volatile int progress = 0;
    private volatile String message = "Đang chờ xử lý...";
    private volatile String outputFileName = null;

    // NEW: theo dõi phần / tổng phần để front-end hiển thị
    private volatile int totalParts = 0;
    private volatile int currentPart = 0;

    public ConvertTask(String taskId, String inputPath, String originalName, HttpSession session) {
        this.taskId = taskId;
        this.inputPath = inputPath;
        this.originalName = originalName;
        this.session = session;
    }

    @Override
    public void run() {
        try {
            // 1) Splitting PDF
            update("splitting_pdf", 10, "Đang chia PDF thành từng phần nhỏ...");

            ArrayList<String> chunks = PdfConvertionHelper.splitPdf(inputPath);
            int totalChunks = chunks.size();
            if (totalChunks == 0) throw new Exception("Không chia được file");

            this.totalParts = totalChunks;
            AtomicInteger completed = new AtomicInteger(0);

            // 2) Converting từng chunk
            update("converting", 20, "Đang chuyển đổi " + totalChunks + " phần...");

            PdfConvertionHelper.convertChunkPdfToDocxWithProgress(chunks, docxPath -> {
                int done = completed.incrementAndGet();
                int total = this.totalParts;

                this.currentPart = done;

                // 40–90%: convert
                int percent = 20 + (int) ((done * 75.0) / total);
                if (percent > 95) percent = 95;

                update(
                    "converting_part_" + done,
                    percent,
                    "Đang chuyển đổi phần " + done + "/" + total
                );
            });

            // 3) Merging
            update("merging", 96, "Đang gộp các file Word lại...");

            String outputPath = inputPath.replace(".pdf", ".docx");

            ArrayList<String> docxPaths = chunks.stream()
                    .map(p -> p.replace(".pdf", ".docx"))
                    .sorted()
                    .collect(Collectors.toCollection(ArrayList::new));

            CombineDocx.combineFiles(docxPaths, outputPath);
            this.outputFileName = Paths.get(outputPath).getFileName().toString();

            // 4) Lưu lịch sử
            update("saving_to_db", 98, "Đang lưu thông tin vào hệ thống...");

            String username = (String) session.getAttribute("username");
            if (username != null) {
                new ConverterBO().saveHistory(
                        username,
                        originalName,
                        originalName.replace(".pdf", ".docx"),
                        outputFileName
                );
            }

            // 5) Done
            update("done", 100, "Hoàn thành! Bấm vào nút để tải file.");

        } catch (Exception e) {
            e.printStackTrace();
            update("error", 0, "Lỗi: " + e.getMessage());
        } finally {
            // Có thể remove task ở đây nếu muốn dọn rác
            // TaskManager.remove(taskId);
        }
    }

    private void update(String st, int prog, String msg) {
        this.status = st;
        this.progress = prog;
        this.message = msg;
    }

    public String getStatus() { return status; }
    public int getProgress() { return progress; }
    public String getMessage() { return message; }
    public String getOutputFileName() { return outputFileName; }

    public int getTotalParts() { return totalParts; }
    public int getCurrentPart() { return currentPart; }
}
