import 'package:hive/hive.dart';

import '../DATABASEMODEL/OutDoorModel.dart';

class OutDoorModeBOX{
  static Box<OutDoorModel> getData() => Hive.box<OutDoorModel>('OutDoorModelFile');
}