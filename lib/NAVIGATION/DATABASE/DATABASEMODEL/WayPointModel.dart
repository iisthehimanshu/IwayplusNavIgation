import 'package:hive/hive.dart';
part 'WayPointModel.g.dart';

@HiveType(typeId: 9)
class WayPointModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  WayPointModel({required this.responseBody});
}