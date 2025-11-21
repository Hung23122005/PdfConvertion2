package controller;

import java.io.*;
import java.nio.file.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;  // BẮT BUỘC PHẢI CÓ
import model.BO.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 10,   // 10MB
    maxFileSize = 1024 * 1024 * 100,        // 100MB giới hạn file
    maxRequestSize = 1024 * 1024 * 150      // tổng request
)
public class ConverterAsyncServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // DÒNG TEST ĐỂ BIẾT FILE ĐÃ QUA SERVER CHƯA
        resp.setContentType("text/plain");
        resp.getWriter().println("OK - FILE ĐÃ ĐẾN SERVER THÀNH CÔNG! TASKID: " + req.getParameter("taskId"));

        Part part = req.getPart("file");
        String taskId = req.getParameter("taskId");

        if (part == null || taskId == null) {
            resp.getWriter().println("ERROR: Thiếu file hoặc taskId");
            return;
        }

        String origName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (!origName.toLowerCase().endsWith(".pdf")) {
            resp.getWriter().println("{\"error\":\"Chỉ chấp nhận file PDF\"}");
            return;
        }

        String uploadDir = req.getServletContext().getRealPath("/upload");
        new File(uploadDir).mkdirs();

        String serverName = taskId + "_" + origName;
        String fullPath = uploadDir + File.separator + serverName;
        part.write(fullPath);

        ConvertTask task = new ConvertTask(taskId, fullPath, origName, req.getSession());
        TaskManager.add(taskId, task);
        task.start();

        resp.getWriter().println("{\"taskId\":\"" + taskId + "\"}");
    }
}