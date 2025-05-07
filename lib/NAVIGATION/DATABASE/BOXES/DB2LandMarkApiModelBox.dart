import 'package:hive/hive.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/DB2LandMarkApiModel.dart';

class DB2LandMarkApiModelBox{
  static dynamic getData() => Hive.box<DB2LandMarkApiModel>('DB2LandMarkApiModelFile');
}