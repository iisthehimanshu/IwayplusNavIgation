import '../Network/APIDetails.dart';

abstract class DBManager {
  Future updateData();
  Future<void> saveData(dynamic dataModel, Detail details, String bID);
  dynamic getData(Detail details, String bID);
  Future<void> delete(int id);
  String getAccessToken();
  void updateAccessToken(String newAccessToken);
  String getRefreshToken();
  void updateRefreshToken(String newRefreshToken);
}

