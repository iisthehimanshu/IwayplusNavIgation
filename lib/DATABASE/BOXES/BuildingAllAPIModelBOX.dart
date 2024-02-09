import 'package:hive/hive.dart';
import '../DATABASEMODEL/BuildingAllAPIModel.dart';
import '../DATABASEMODEL/LandMarkApiModel.dart';

class BuildingAllAPIModelBOX{
  static Box<BuildingAllAPIModel> getData() => Hive.box<BuildingAllAPIModel>('BuildingAllAPIModelFile');
}