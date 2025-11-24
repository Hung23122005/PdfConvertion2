package model.DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

import model.BEAN.File;
import utils.Utils;

public class ConverterDAO {
	public ArrayList<File> getListFileConvert(String username) {
		ArrayList<File> files = new ArrayList<>();
		try {
			Connection connection = Utils.getConnection();
			if (connection != null) {
				String query = "select * from files where username = '" + username + "'";
				Statement st = connection.createStatement();
				ResultSet rs = st.executeQuery(query);
				while (rs.next()) {
					File file = new File(rs.getString("fileNameUpload"), rs.getString("fileNameOutput"),
							rs.getString("fileNameOutputInServer"), rs.getString("date"));
					files.add(file);
				}
			}
		} catch (Exception e) {
			System.err.println("getListFileConvert: " + e.getMessage());
		}
		return files;
	}

	public void saveHistory(String username, String fileNameUpload, String fileNameOutput,
			String fileNameOutputInServer) {
		try {
			Connection connection = Utils.getConnection();
			String sql = "insert into files(username, fileNameUpload, fileNameOutput, fileNameOutputInServer) "
					+ "values(?,?,?,?)";
			PreparedStatement pst = connection.prepareStatement(sql);
			pst.setString(1, username);
			pst.setString(2, fileNameUpload);
			pst.setString(3, fileNameOutput);
			pst.setString(4, fileNameOutputInServer);
			pst.executeUpdate();
		} catch (Exception e) {
			System.err.println("saveHistory: " + e.getMessage());
		}
	}
}
