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
}
