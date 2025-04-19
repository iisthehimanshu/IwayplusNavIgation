import 'package:hive/hive.dart';
import '../DATABASEMODEL/LandMarkApiModel.dart';

class LandMarkApiModelBox{
  static dynamic getData() => Hive.box<LandMarkApiModel>('LandMarkApiModelFile');
}