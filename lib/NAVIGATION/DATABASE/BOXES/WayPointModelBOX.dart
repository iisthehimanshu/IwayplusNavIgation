import 'package:hive/hive.dart';

import '../DATABASEMODEL/WayPointModel.dart';


class WayPointModeBOX{
  static Box<WayPointModel> getData() => Hive.box<WayPointModel>('WayPointModelFile');
}