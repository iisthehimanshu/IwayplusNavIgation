import 'package:hive/hive.dart';
part 'LandMarkApiModel.g.dart';

@HiveType(typeId: 0)
class LandMarkApiModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  LandMarkApiModel({required this.responseBody});
}