import 'package:hive/hive.dart';
import '../DATABASEMODEL/DB2PatchAPIModel.dart';

class DB2PatchAPIModelBOX{
  static Box<DB2PatchAPIModel> getData() => Hive.box<DB2PatchAPIModel>('DB2PatchAPIModelFile');
}