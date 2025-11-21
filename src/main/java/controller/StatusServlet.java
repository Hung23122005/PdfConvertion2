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
        String taskId = req.getParameter("taskId");

        ConvertTask task = TaskManager.get(taskId);   // ĐÚNG RỒI!

        String json = task == null
            ? "{\"status\":\"notfound\"}"
            : "{\"status\":\"" + task.getStatus() +
              "\",\"file\":\"" + 
              (task.getOutputFileName() != null ? task.getOutputFileName() : "") + "\"}";

        resp.getWriter().write(json);
    }
}