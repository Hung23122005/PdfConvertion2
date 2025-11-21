package model.BO;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class TaskManager {

    // Dùng ConcurrentHashMap để nhiều luồng truy cập an toàn
    private static final Map<String, ConvertTask> tasks = new ConcurrentHashMap<>();

    // THÊM METHOD NÀY → LỖI BIẾN MẤT NGAY!
    public static void add(String taskId, ConvertTask task) {
        tasks.put(taskId, task);
    }

    // Dùng để lấy task khi polling status
    public static ConvertTask get(String taskId) {
        return tasks.get(taskId);
    }

    // Xóa khi xong (tùy chọn – để dọn rác)
    public static void remove(String taskId) {
        tasks.remove(taskId);
    }
}