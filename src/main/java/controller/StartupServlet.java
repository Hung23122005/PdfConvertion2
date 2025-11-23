package controller;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import model.Task.CleanupScheduler;

public class StartupServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {

        // Lấy đúng đường dẫn upload trong server
        String uploadDir = getServletContext().getRealPath("/upload");

        System.out.println("[INIT] Upload dir = " + uploadDir);

        // Khởi động scheduler
        CleanupScheduler.start(uploadDir);

        System.out.println("[INIT] CleanupScheduler STARTED!");
    }
}
