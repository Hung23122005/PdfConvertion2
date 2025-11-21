package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import model.BEAN.User;
import model.BO.LoginBO;
import utils.Utils;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LoginServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) return;

        switch (action) {
            case "check-login":
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                checkLogin(request, response, username, password);
                break;

            case "sign-up":
                username = request.getParameter("username");
                password = request.getParameter("password");
                signUp(request, response, username, password);
                break;

            case "invalidate-session":
                request.getSession().removeAttribute("username");
                request.getSession().removeAttribute("login-status");
                Utils.redirectToPage(request, response, "/index.jsp");
                break;

            case "logout":
                logout(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private void checkLogin(HttpServletRequest request, HttpServletResponse response,
                            String username, String password) throws IOException, ServletException {
        User user = new LoginBO().checkLogin(username, password);

        if (user != null) {
            request.getSession().setAttribute("login-status", true);
            request.getSession().setAttribute("username", username);
        } else {
            request.getSession().setAttribute("login-status", false);
            request.getSession().removeAttribute("username");
        }

        Utils.redirectToPage(request, response, "/index.jsp");
    }

    private void signUp(HttpServletRequest request, HttpServletResponse response,
            String username, String password) throws IOException, ServletException {

		boolean status = new LoginBO().createAccount(username, password);
		request.getSession().setAttribute("signup-status", status);
		if (status) {
	        request.getSession().setAttribute("login-status", false);
	    }
		Utils.redirectToPage(request, response, "/index.jsp");
	}


    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        request.getSession().removeAttribute("username");
        request.getSession().removeAttribute("login-status");
        request.getSession().removeAttribute("signup-status");
        Utils.redirectToPage(request, response, "/index.jsp");
    }
}
