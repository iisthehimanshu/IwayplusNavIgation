import 'package:hive/hive.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';

import '../DATABASEMODEL/SignINAPIModel.dart';


class SignINAPIModelBox{
  static Box<SignINAPIModel> getData() => Hive.box<SignINAPIModel>('SignINAPIModelFile');
}