import 'package:hive/hive.dart';
import '../DATABASEMODEL/PatchAPIModel.dart';

class PatchAPIModelBox{
  static Box<PatchAPIModel> getData() => Hive.box<PatchAPIModel>('PatchAPIModelFile');
}