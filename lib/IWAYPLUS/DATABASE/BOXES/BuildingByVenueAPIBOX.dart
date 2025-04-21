
import 'package:hive/hive.dart';

import '../DATABASEMODEL/BuildingByVenueAPIModel.dart';

class BuildingByVenueAPIBOX{
  static Box<BuildingByVenueAPIModel> getData() => Hive.box<BuildingByVenueAPIModel>('BuildingByVenueModelFile');
}