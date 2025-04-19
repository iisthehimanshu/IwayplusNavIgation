
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iwaymaps/IWAYPLUS/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import 'package:iwaymaps/IWAYPLUS/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import 'package:iwaymaps/IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import 'package:iwaymaps/IWAYPLUS/DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'package:iwaymaps/IWAYPLUS/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/APIS/SignInAPI.dart';
import 'package:iwaymaps/IWAYPLUS/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/OutDoorModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/WayPointModel.dart';
import 'package:iwaymaps/main.dart';
import 'package:path_provider/path_provider.dart';



const MethodChannel _channel = MethodChannel('plugins.flutter.io/path_provider');

void setupPathProviderMock() {

  _channel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      // final String? path = await _platform.getApplicationDocumentsPath();

      return '/mocked/path';
    }
    return null;
  });
}

void main(){
  setupPathProviderMock();
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if(kIsWeb){
      await Hive.initFlutter();
    }else {
      var directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }
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

    await navigationManager.initialize();

    await Hive.openBox('Favourites');
    await Hive.openBox('UserInformation');
    await Hive.openBox('Filters');
    await Hive.openBox('SignInDatabase');
    await Hive.openBox('LocationPermission');
    await Hive.openBox('VersionData');
  });

  late SignInAPI signin;
  setUp((){
    signin = SignInAPI();
  });

  //given what then
  test("testing landmark API when running fetchLandmarkData and getting response 200", () async {
    //Arrange
    //Act
    final responseData = await signin.signIN("danielwilson71935@gmail.com","12345678");
    //Assert
    expect(responseData, isA<SignInApiModel>());
  });
}