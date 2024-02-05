import 'package:hive/hive.dart';
import '../DATABASEMODEL/PolyLineAPIModel.dart';

class PolylineAPIModelBOX{
  static Box<PolyLineAPIModel> getData() => Hive.box<PolyLineAPIModel>('PolyLineAPIModelFile');
}