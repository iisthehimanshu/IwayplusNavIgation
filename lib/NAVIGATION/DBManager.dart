import 'package:hive/hive.dart';

import '../IWAYPLUS/DATABASE/DATABASEMODEL/BuildingAllAPIModel.dart';
import '../IWAYPLUS/DATABASE/DATABASEMODEL/FavouriteDataBase.dart';
import '../IWAYPLUS/DATABASE/DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';
import '../IWAYPLUS/DATABASE/DATABASEMODEL/SignINAPIModel.dart';
import 'DATABASE/BOXES/LandMarkApiModelBox.dart';
import 'DATABASE/DATABASEMODEL/BeaconAPIModel.dart';
import 'DATABASE/DATABASEMODEL/BuildingAPIModel.dart';
import 'DATABASE/DATABASEMODEL/DataVersionLocalModel.dart';
import 'DATABASE/DATABASEMODEL/LandMarkApiModel.dart';
import 'DATABASE/DATABASEMODEL/OutDoorModel.dart';
import 'DATABASE/DATABASEMODEL/PatchAPIModel.dart';
import 'DATABASE/DATABASEMODEL/PolyLineAPIModel.dart';
import 'DATABASE/DATABASEMODEL/WayPointModel.dart';

abstract class DBManager<T>{
  Future<T> getData();
  Future<void> saveData(T dataModel);
  Future<void> update(T item);
  Future<void> delete(int id);
}

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
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<T> getData() {
    // TODO: implement getData
    throw UnimplementedError();
  }

  @override
  Future<void> saveData(T dataModel) async {

  }



  @override
  Future<void> update(T item) {
    // TODO: implement update
    throw UnimplementedError();
  }
}