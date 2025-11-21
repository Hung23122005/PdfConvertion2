package model.BO;

import javax.servlet.http.HttpSession;
import java.nio.file.*;

public class ConvertTask extends Thread {
    private final String taskId;
    private final String inputPath;
    private final String originalName;
    private final HttpSession session;
    private String status = "processing";
    private String outputFileName = null;

    public ConvertTask(String taskId, String inputPath, String originalName, HttpSession session) {
        this.taskId = taskId;
        this.inputPath = inputPath;
        this.originalName = originalName;
        this.session = session;
    }

    @Override
    public void run() {
        try {
            String outputPath = inputPath.replace(".pdf", ".docx");
            PdfConvertionHelper.convertPdfToDoc(inputPath, outputPath);

            this.outputFileName = Paths.get(outputPath).getFileName().toString();
            this.status = "done";

            String username = (String) session.getAttribute("username");
            if (username != null) {
                new ConverterBO().saveHistory(
                    username,
                    originalName,
                    originalName.replace(".pdf", ".docx"),
                    outputFileName
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
            this.status = "error";
        }
    }

    public String getStatus() { return status; }
    public String getOutputFileName() { return outputFileName; }
}