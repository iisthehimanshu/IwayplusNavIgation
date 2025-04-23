import '../Network/APIDetails.dart';

abstract class DBManager<T>{
  Future updateData();
  Future<void> saveData(T dataModel,Detail details,String bID);
  T getData(Detail details,String bID);
  Future<void> delete(int id);
  String getAccessToken();
  void updateAccessToken(String newAccessToken);
  String getRefreshToken();
  void updateRefreshToken(String newRefreshToken);
}
