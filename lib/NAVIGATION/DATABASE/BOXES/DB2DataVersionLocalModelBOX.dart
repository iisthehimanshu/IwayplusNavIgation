import 'package:hive/hive.dart';

import '../DATABASEMODEL/DB2DataVersionLocalModel.dart';

class DB2DataVersionLocalModelBOX{
  static Box<DB2DataVersionLocalModel> getData() => Hive.box<DB2DataVersionLocalModel>('DB2DataVersionLocalModelFile');
}