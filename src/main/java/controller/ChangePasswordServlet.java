package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.BO.LoginBO;

@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String username = (String) session.getAttribute("username");
		
		if (username == null) {
			response.sendRedirect("index.jsp");
			return;
		}
		
		String oldPassword = request.getParameter("oldPassword");
		String newPassword = request.getParameter("newPassword");
		String confirmPassword = request.getParameter("confirmPassword");
		
		if (!newPassword.equals(confirmPassword)) {
			session.setAttribute("password-error", "New password and confirmation do not match!");
			response.sendRedirect("profile");
			return;
		}
		
		LoginBO loginBO = new LoginBO();
		boolean success = loginBO.changePassword(username, oldPassword, newPassword);
		
		if (success) {
			session.setAttribute("password-success", "Password changed successfully!");
		} else {
			session.setAttribute("password-error", "Incorrect old password or failed to change password!");
		}
		
		response.sendRedirect("profile");
	}
}
