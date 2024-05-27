import 'package:hive/hive.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';

class BeaconAPIModelBOX{
  static Box<BeaconAPIModel> getData() => Hive.box<BeaconAPIModel>('BeaconAPIModelFile');
}