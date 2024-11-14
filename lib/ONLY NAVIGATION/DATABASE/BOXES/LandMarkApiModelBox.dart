import 'package:hive/hive.dart';
import '../DATABASEMODEL/LandMarkApiModel.dart';

class LandMarkApiModelBox{
  static Box<LandMarkApiModel> getData() => Hive.box<LandMarkApiModel>('LandMarkApiModelFile');
}