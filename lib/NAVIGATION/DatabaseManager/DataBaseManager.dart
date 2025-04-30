import 'package:hive/hive.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/VenueBeaconAPIModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingByVenueAPIModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import '../../IWAYPLUS/DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import '../DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import '../DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import '../DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import '../DATABASE/DATABASEMODEL/GlobalAnnotationAPIModel.dart';
import '../DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import '../DATABASE/DATABASEMODEL/OutDoorModel.dart';
import '../DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import '../DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import '../DATABASE/DATABASEMODEL/WayPointModel.dart';
import '../DataBaseManager/DBManager.dart';
import '../Network/APIDetails.dart';


class DataBaseManager<T> implements DBManager<T>{

  static void init() async {
    Hive.registerAdapter(LandMarkApiModelAdapter());
    await Hive.openBox<LandMarkApiModel>('LandMarkApiModelFile');
    Hive.registerAdapter(PatchAPIModelAdapter());
    await Hive.openBox<PatchAPIModel>('PatchAPIModelFile');
    Hive.registerAdapter(PolyLineAPIModelAdapter());
    await Hive.openBox<PolyLineAPIModel>("PolyLineAPIModelFile");
    Hive.registerAdapter(BuildingAllAPIModelAdapter());
    await Hive.openBox<BuildingAllAPIModel>("BuildingAllAPIModelFile");
    Hive.registerAdapter(FavouriteDataBaseModelAdapter());
    await Hive.openBox<FavouriteDataBaseModel>("FavouriteDataBaseModelFile");
    Hive.registerAdapter(BeaconAPIModelAdapter());
    await Hive.openBox<BeaconAPIModel>('BeaconAPIModelFile');
    Hive.registerAdapter(BuildingAPIModelAdapter());
    await Hive.openBox<BuildingAPIModel>('BuildingAPIModelFile');
    Hive.registerAdapter(SignINAPIModelAdapter());
    await Hive.openBox<SignINAPIModel>('SignINAPIModelFile');
    Hive.registerAdapter(OutDoorModelAdapter());
    await Hive.openBox<OutDoorModel>('OutDoorModelFile');
    Hive.registerAdapter(WayPointModelAdapter());
    await Hive.openBox<WayPointModel>('WayPointModelFile');
    Hive.registerAdapter(DataVersionLocalModelAdapter());
    await Hive.openBox<DataVersionLocalModel>('DataVersionLocalModelFile');
    Hive.registerAdapter(LocalNotificationAPIDatabaseModelAdapter());
    await Hive.openBox<LocalNotificationAPIDatabaseModel>('LocalNotificationAPIDatabaseModel');
    Hive.registerAdapter(BuildingByVenueAPIModelAdapter());
    await Hive.openBox<BuildingByVenueAPIModel>('BuildingByVenueModelFile');
    Hive.registerAdapter(GlobalAnnotationAPIModelAdapter());
    await Hive.openBox<GlobalAnnotationAPIModel>('GlobalAnnotationAPIModelFile');
    Hive.registerAdapter(VenueBeaconAPIModelAdapter());
    await Hive.openBox<VenueBeaconAPIModel>('VenueBeaconAPIModelFile');

    await Hive.openBox('Favourites');
    await Hive.openBox('UserInformation');
    await Hive.openBox('Filters');
    await Hive.openBox('SignInDatabase');
    await Hive.openBox('LocationPermission');
    await Hive.openBox('VersionData');

  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<T> updateData() {
    // TODO: implement getData
    throw UnimplementedError();
  }

  @override
  Future<void> saveData(T dataModel,Detail details,String bID) async {
    final databaseBox = details.dataBaseGetData!();
    databaseBox.put(bID,dataModel);
  }

  @override
  T getData(Detail details,String bID) {
    final databaseBox = details.dataBaseGetData!();
    final data = databaseBox.get(bID);
    return data;
  }

  @override
  String getAccessToken(){
    var signInBox = Hive.box('SignInDatabase');
    String accessToken = signInBox.get("accessToken");
    return accessToken;
  }

  @override
  void updateAccessToken(String newAccessToken){
    var signInBox = Hive.box('SignInDatabase');
    signInBox.delete("accessToken");
    signInBox.put("accessToken", newAccessToken);
  }

  @override
  String getRefreshToken(){
    var signInBox = Hive.box('SignInDatabase');
    String refreshToken = signInBox.get("refreshToken");
    return refreshToken;
  }

  @override
  void updateRefreshToken(String newRefreshToken){
    var signInBox = Hive.box('SignInDatabase');
    signInBox.delete("refreshToken");
    signInBox.put("refreshToken", newRefreshToken);
  }
}