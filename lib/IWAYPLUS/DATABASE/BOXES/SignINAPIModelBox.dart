import 'package:hive/hive.dart';
import '../DATABASEMODEL/SignINAPIModel.dart';


class SignINAPIModelBox{
  static Box<SignINAPIModel> getData() => Hive.box<SignINAPIModel>('SignINAPIModelFile');
}