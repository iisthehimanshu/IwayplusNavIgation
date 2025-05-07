import 'package:hive/hive.dart';
part 'DB2DataVersionLocalModel.g.dart';

@HiveType(typeId: 63)
class DB2DataVersionLocalModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2DataVersionLocalModel({required this.responseBody});
}