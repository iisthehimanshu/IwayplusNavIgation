import 'package:hive/hive.dart';
import 'package:iwayplusnav/DATABASE/DATABASEMODEL/BeaconAPIModel.dart';

import '../DATABASEMODEL/SignINAPModel.dart';

class SignINAPIModelBox{
  static Box<SignINAPIModel> getData() => Hive.box<SignINAPIModel>('SignINAPIModelFile');
}