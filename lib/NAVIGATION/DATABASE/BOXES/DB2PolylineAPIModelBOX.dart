import 'package:hive/hive.dart';
import 'package:iwaymaps/NAVIGATION/DATABASE/DATABASEMODEL/DB2PolyLineAPIModel.dart';

class DB2PolylineAPIModelBOX{
  static Box<DB2PolyLineAPIModel> getData() => Hive.box<DB2PolyLineAPIModel>('DB2PolyLineAPIModelFile');
}