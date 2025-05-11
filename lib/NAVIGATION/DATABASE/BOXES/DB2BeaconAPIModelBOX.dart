import 'package:hive/hive.dart';

import '../DATABASEMODEL/DB2BeaconAPIModel.dart';

class DB2BeaconAPIModelBOX{
  static Box<DB2BeaconAPIModel> getData() => Hive.box<DB2BeaconAPIModel>('DB2BeaconAPIModelFile');
}