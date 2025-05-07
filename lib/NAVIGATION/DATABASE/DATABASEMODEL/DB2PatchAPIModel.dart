import 'package:hive/hive.dart';
part 'DB2PatchAPIModel.g.dart';

@HiveType(typeId: 60)
class DB2PatchAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2PatchAPIModel({required this.responseBody});
}