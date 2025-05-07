import 'package:hive/hive.dart';

class DB2PolylineAPIModelBOX{
  static Box<DB2PolylineAPIModelBOX> getData() => Hive.box<DB2PolylineAPIModelBOX>('DB2PolyLineAPIModelFile');
}