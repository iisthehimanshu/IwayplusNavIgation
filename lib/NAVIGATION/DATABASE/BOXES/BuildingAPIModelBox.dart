import 'package:hive/hive.dart';

import '../DATABASEMODEL/BuildingAPIModel.dart';

class BuildingAPIModelBox{
  static Box<BuildingAPIModel> getData() => Hive.box<BuildingAPIModel>('BuildingAPIModelFile');
}