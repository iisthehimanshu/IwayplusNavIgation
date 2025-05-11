import 'package:hive/hive.dart';
part 'DB2BeaconAPIModel.g.dart';

@HiveType(typeId: 64)
class DB2BeaconAPIModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  DB2BeaconAPIModel({required this.responseBody});
}