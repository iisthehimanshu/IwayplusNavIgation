import 'package:hive/hive.dart';
part 'DB2LandMarkApiModel.g.dart';

@HiveType(typeId: 62)
class DB2LandMarkApiModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2LandMarkApiModel({required this.responseBody});
}