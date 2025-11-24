package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.BEAN.User;
import model.BO.LoginBO;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String username = (String) session.getAttribute("username");
		
		if (username == null) {
			response.sendRedirect("index.jsp");
			return;
		}
		
		LoginBO loginBO = new LoginBO();
		User user = loginBO.getUserInfo(username);
		
		if (user != null) {
			request.setAttribute("user", user);
			request.getRequestDispatcher("profile.jsp").forward(request, response);
		} else {
			response.sendRedirect("index.jsp");
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String username = (String) session.getAttribute("username");
		
		if (username == null) {
			response.sendRedirect("index.jsp");
			return;
		}
		
		String email = request.getParameter("email");
		String fullName = request.getParameter("fullName");
		String phone = request.getParameter("phone");
		String dateOfBirth = request.getParameter("dateOfBirth");
		String address = request.getParameter("address");
		String gender = request.getParameter("gender");
		
		User user = new User();
		user.setUsername(username);
		user.setEmail(email);
		user.setFullName(fullName);
		user.setPhone(phone);
		user.setDateOfBirth(dateOfBirth);
		user.setAddress(address);
		user.setGender(gender);
		
		LoginBO loginBO = new LoginBO();
		boolean success = loginBO.updateProfile(user);
		
		if (success) {
			request.setAttribute("success", true);
			request.setAttribute("message", "Profile updated successfully!");
		} else {
			request.setAttribute("error", true);
			request.setAttribute("message", "Failed to update profile. Please try again.");
		}
		
		request.setAttribute("user", user);
		request.getRequestDispatcher("profile.jsp").forward(request, response);
	}
}
