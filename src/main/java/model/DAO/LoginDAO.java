package model.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import model.BEAN.User;
import utils.Utils;

public class LoginDAO {
	public User checkLogin(String username, String password) {
		User user = null;
		try {
			Connection connection = Utils.getConnection();
			if (connection != null) {
				String query = "select username from users where username = ? and password = ?";
				PreparedStatement pst = connection.prepareStatement(query);
				pst.setString(1, username);
				pst.setString(2, password);
				ResultSet rs = pst.executeQuery();
				if (rs.next()) {
					user = new User();
					user.setUsername(rs.getString("username"));
				}
			}
		} catch (Exception e) {
			System.err.println("checkLogin: " + e.getMessage());
		}
		return user;
	}

	public boolean createAccount(String username, String password, String email, String fullName,
								 String phone, String dateOfBirth, String address, String gender) {
		try {
			Connection connection = Utils.getConnection();
			if (connection != null) {
				String query = "INSERT INTO users(username, password, email, full_name, phone, date_of_birth, address, gender) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
				PreparedStatement pst = connection.prepareStatement(query);
				pst.setString(1, username);
				pst.setString(2, password);
				pst.setString(3, email);
				pst.setString(4, fullName);
				pst.setString(5, phone);
				// Xử lý dateOfBirth: nếu rỗng thì set NULL
				if (dateOfBirth != null && !dateOfBirth.trim().isEmpty()) {
					pst.setString(6, dateOfBirth);
				} else {
					pst.setNull(6, java.sql.Types.DATE);
				}
				pst.setString(7, address);
				pst.setString(8, gender);
				return pst.executeUpdate() > 0;
			}
		} catch (Exception e) {
			System.err.println("createAccount: " + e.getMessage());
		}
		return false;
	}

	public User getUserByUsername(String username) {
		User user = null;
		try {
			Connection connection = Utils.getConnection();
			if (connection != null) {
				String query = "SELECT * FROM users WHERE username = ?";
				PreparedStatement pst = connection.prepareStatement(query);
				pst.setString(1, username);
				ResultSet rs = pst.executeQuery();
				if (rs.next()) {
					user = new User();
					user.setUsername(rs.getString("username"));
					user.setPassword(rs.getString("password"));
					user.setEmail(rs.getString("email"));
					user.setFullName(rs.getString("full_name"));
					user.setPhone(rs.getString("phone"));
					user.setDateOfBirth(rs.getString("date_of_birth"));
					user.setAddress(rs.getString("address"));
					user.setGender(rs.getString("gender"));
				}
			}
		} catch (Exception e) {
			System.err.println("getUserByUsername: " + e.getMessage());
		}
		return user;
	}

	public boolean updateUserProfile(User user) {
		try {
			Connection connection = Utils.getConnection();
			if (connection != null) {
				String query = "UPDATE users SET email=?, full_name=?, phone=?, date_of_birth=?, address=?, gender=? WHERE username=?";
				PreparedStatement pst = connection.prepareStatement(query);
				pst.setString(1, user.getEmail());
				pst.setString(2, user.getFullName());
				pst.setString(3, user.getPhone());
				if (user.getDateOfBirth() != null && !user.getDateOfBirth().trim().isEmpty()) {
					pst.setString(4, user.getDateOfBirth());
				} else {
					pst.setNull(4, java.sql.Types.DATE);
				}
				pst.setString(5, user.getAddress());
				pst.setString(6, user.getGender());
				pst.setString(7, user.getUsername());
				return pst.executeUpdate() > 0;
			}
		} catch (Exception e) {
			System.err.println("updateUserProfile: " + e.getMessage());
		}
		return false;
	}

	public boolean updatePassword(String username, String newPassword) {
		try {
			Connection connection = Utils.getConnection();
			if (connection != null) {
				String query = "UPDATE users SET password=? WHERE username=?";
				PreparedStatement pst = connection.prepareStatement(query);
				pst.setString(1, newPassword);
				pst.setString(2, username);
				return pst.executeUpdate() > 0;
			}
		} catch (Exception e) {
			System.err.println("updatePassword: " + e.getMessage());
		}
		return false;
	}
}
