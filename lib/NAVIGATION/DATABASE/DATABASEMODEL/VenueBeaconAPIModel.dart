import 'package:hive/hive.dart';
part 'VenueBeaconAPIModel.g.dart';


@HiveType(typeId: 55)
class VenueBeaconAPIModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  VenueBeaconAPIModel({required this.responseBody});
}