package model.Task;

import java.io.File;
import java.sql.*;
import java.time.*;
import java.util.Timer;
import java.util.TimerTask;

public class CleanupScheduler {

    public static void start(String uploadDir) {

        System.out.println("[CLEANUP] Scheduler initialized!");

        Timer timer = new Timer(true); // chạy ngầm

        long oneDay = 24L * 60 * 60 * 1000;

        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                cleanupOldFiles(uploadDir);
            }
        }, 0, oneDay);
    }

    private static void cleanupOldFiles(String uploadDir) {

        System.out.println("[CLEANUP] Running cleanup job...");

        // 🔥 FIX LỖI JDBC 100%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/pdf_convertion", "root", "")) {

            String sql = "SELECT id, fileNameOutputInServer, date FROM uploads";
            PreparedStatement ps = conn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                int id = rs.getInt("id");
                String outFile = rs.getString("fileNameOutputInServer");
                Timestamp ts = rs.getTimestamp("date");

                long hours = Duration.between(
                        ts.toLocalDateTime(),
                        LocalDateTime.now()
                ).toHours();

                if (hours >= 24) {

                    File f = new File(uploadDir + File.separator + outFile);

                    if (f.exists()) {
                        f.delete();
                        System.out.println("[CLEANUP] Deleted file: " + outFile);
                    }

                    PreparedStatement del = conn.prepareStatement(
                            "DELETE FROM uploads WHERE id = ?"
                    );
                    del.setInt(1, id);
                    del.executeUpdate();

                    System.out.println("[CLEANUP] Deleted DB record id=" + id);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
