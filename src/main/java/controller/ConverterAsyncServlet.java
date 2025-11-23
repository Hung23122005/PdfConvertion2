package controller;

import java.io.*;
import java.nio.file.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import model.BO.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 10,  // 10MB
    maxFileSize = 1024 * 1024 * 100,       // 100MB
    maxRequestSize = 1024 * 1024 * 150
)
public class ConverterAsyncServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // LẤY taskId TỪ URL (do worker gửi qua ?taskId=...)
        String taskId = req.getParameter("taskId");
        if (taskId == null || taskId.trim().isEmpty()) {
            taskId = "task_" + System.currentTimeMillis();
        }

        Part part = req.getPart("file");
        if (part == null || part.getSize() == 0) {
            resp.getWriter().write("{\"error\":\"Không có file\"}");
            return;
        }

        String origName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (!origName.toLowerCase().endsWith(".pdf")) {
            resp.getWriter().write("{\"error\":\"Chỉ chấp nhận file PDF\"}");
            return;
        }

        String uploadDir = req.getServletContext().getRealPath("/upload");
        new File(uploadDir).mkdirs();
        System.out.println("UPLOAD PATH = " + uploadDir);


        String serverFileName = taskId + "_" + origName;
        String fullPath = uploadDir + File.separator + serverFileName;
        part.write(fullPath);

        // TẠO TASK + ĐĂNG KÝ VÀO TASKMANAGER TRƯỚC KHI START
        ConvertTask task = new ConvertTask(taskId, fullPath, origName, req.getSession());
        TaskManager.add(taskId, task);   // DÒNG QUAN TRỌNG NHẤT
        task.start();                    // BÂY GIỜ MỚI START

        // TRẢ JSON CHO FRONTEND
        resp.getWriter().write("{\"taskId\":\"" + taskId + "\"}");
    }
}