import 'package:hive/hive.dart';
part 'BuildingByVenueAPIModel.g.dart';

@HiveType(typeId: 20)
class BuildingByVenueAPIModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  BuildingByVenueAPIModel({required this.responseBody});
}