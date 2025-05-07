import 'package:hive/hive.dart';
part 'DB2PolyLineAPIModel.g.dart';

@HiveType(typeId: 61)
class DB2PolyLineAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2PolyLineAPIModel({required this.responseBody});
}