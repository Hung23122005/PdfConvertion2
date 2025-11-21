package model.BO;

import java.util.ArrayList;
import model.BEAN.Upload;
import model.DAO.ConverterDAO;

public class ConverterBO {

    public ArrayList<Upload> getListFileConvert(String username) {
        return (new ConverterDAO()).getListFileConvert(username);
    }

    // ĐÃ SỬA: NHẬN ĐỦ 4 THAM SỐ
    public void saveHistory(String username, String fileNameUpload, String fileNameOutput, String fileNameOutputInServer) {
        (new ConverterDAO()).saveHistory(username, fileNameUpload, fileNameOutput, fileNameOutputInServer);
    }
}