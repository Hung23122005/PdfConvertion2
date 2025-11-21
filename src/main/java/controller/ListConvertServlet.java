package controller;

import java.io.IOException;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import model.BEAN.Upload;
import model.BO.ConverterBO;
import utils.Utils;

public class ListConvertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public ListConvertServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("username");
        if (username != null) {
            ArrayList<Upload> uploads = new ConverterBO().getListFileConvert(username);
            request.getSession().setAttribute("uploads", uploads);
        }
        Utils.redirectToPage(request, response, "/viewListConvert.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}