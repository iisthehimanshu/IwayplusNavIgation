import 'package:hive/hive.dart';
part 'BuildingAPIModel.g.dart';

@HiveType(typeId: 6)
class BuildingAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  BuildingAPIModel({required this.responseBody});
}