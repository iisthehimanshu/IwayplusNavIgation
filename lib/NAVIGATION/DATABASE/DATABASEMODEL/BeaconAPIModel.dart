import 'package:hive/hive.dart';
part 'BeaconAPIModel.g.dart';

@HiveType(typeId: 5)
class BeaconAPIModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  BeaconAPIModel({required this.responseBody});
}