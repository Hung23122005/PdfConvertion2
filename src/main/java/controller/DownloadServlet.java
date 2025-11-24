package controller;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;

public class DownloadServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String file = req.getParameter("file");
        if (file == null) return;

        String path = req.getServletContext().getRealPath("/upload") + "/" + file;
        File f = new File(path);
        if (!f.exists()) return;

        resp.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + file.substring(file.indexOf("_") + 1) + "\"");

        Files.copy(Paths.get(path), resp.getOutputStream());
        
    }
}