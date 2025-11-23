// src/controller/StatusServlet.java
package controller;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import model.BO.ConvertTask;
import model.BO.TaskManager;

public class StatusServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String taskId = req.getParameter("taskId");
        ConvertTask task = TaskManager.get(taskId);

        if (task == null) {
            resp.getWriter().write("{\"status\":\"notfound\"}");
            return;
        }

        String safeMsg = task.getMessage() == null ? "" :
                task.getMessage().replace("\"", "\\\"");

        String fileName = task.getOutputFileName() != null
                ? task.getOutputFileName()
                : "";

        String json = String.format(
            "{" +
                "\"status\":\"%s\"," +
                "\"progress\":%d," +
                "\"message\":\"%s\"," +
                "\"file\":\"%s\"," +
                "\"currentPart\":%d," +
                "\"totalPart\":%d" +
            "}",
            task.getStatus(),
            task.getProgress(),
            safeMsg,
            fileName,
            task.getCurrentPart(),
            task.getTotalParts()
        );

        resp.getWriter().write(json);
    }
}
