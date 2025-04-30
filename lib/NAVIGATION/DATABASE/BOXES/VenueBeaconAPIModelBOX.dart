
import 'package:hive/hive.dart';
import '../DATABASEMODEL/VenueBeaconAPIModel.dart';

class VenueBeaconAPIModelBOX{
  static Box<VenueBeaconAPIModel> getData() => Hive.box<VenueBeaconAPIModel>('VenueBeaconAPIModelFile');
}