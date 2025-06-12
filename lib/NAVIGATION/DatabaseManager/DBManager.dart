import '../Network/APIDetails.dart';

abstract class DBManager {
  Future updateData();

  Future<void> saveData(dynamic dataModel, Detail details, String bID);
  Future<void> saveDataDB2(dynamic dataModel, Detail details, String bID);

  dynamic getData(Detail details, String bID);
  dynamic getDataDB2(Detail details, String bID);

  dynamic getDataBaseKeys(Detail details);
  dynamic getDataBaseKeysDB2(Detail details);

  dynamic getDataBaseValues(Detail details);
  dynamic getDataBaseValuesDB2(Detail details);

  Future<void> delete(int id);

  String getAccessToken();
  void updateAccessToken(String newAccessToken);

  String getRefreshToken();
  void updateRefreshToken(String newRefreshToken);
}

