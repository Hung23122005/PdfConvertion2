package model.BO;

import model.BEAN.User;
import model.DAO.LoginDAO;

public class LoginBO {
	public User checkLogin(String username, String password) {
		return (new LoginDAO()).checkLogin(username, password);
	}

	public boolean createAccount(String username, String password, String email, String fullName, 
								  String phone, String dateOfBirth, String address, String gender) {
		return (new LoginDAO()).createAccount(username, password, email, fullName, phone, dateOfBirth, address, gender);
	}

	public User getUserInfo(String username) {
		return (new LoginDAO()).getUserByUsername(username);
	}

	public boolean updateProfile(User user) {
		return (new LoginDAO()).updateUserProfile(user);
	}

	public boolean changePassword(String username, String oldPassword, String newPassword) {
		User user = checkLogin(username, oldPassword);
		if (user != null) {
			return (new LoginDAO()).updatePassword(username, newPassword);
		}
		return false;
	}
}
