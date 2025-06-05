import '../Network/APIDetails.dart';

abstract class DBManager {
  Future updateData();

  Future<void> saveData(dynamic dataModel, Detail details, String bID);
  Future<void> saveData2(dynamic dataModel, Detail details, String bID);

  dynamic getData(Detail details, String bID);
  dynamic getData2(Detail details, String bID);

  dynamic getDataBaseKeysDB(Detail details);
  dynamic getDataBaseKeysDB2(Detail details);

  dynamic getDataBaseKeys(Detail details);
  dynamic getDataBaseValues(Detail details);

  Future<void> delete(int id);

  String getAccessToken();
  void updateAccessToken(String newAccessToken);

  String getRefreshToken();
  void updateRefreshToken(String newRefreshToken);
}

