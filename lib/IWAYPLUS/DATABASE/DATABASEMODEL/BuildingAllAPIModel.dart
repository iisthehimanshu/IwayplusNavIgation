import 'package:hive/hive.dart';
part 'BuildingAllAPIModel.g.dart';

@HiveType(typeId: 3)
class BuildingAllAPIModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  BuildingAllAPIModel({required this.responseBody});
}