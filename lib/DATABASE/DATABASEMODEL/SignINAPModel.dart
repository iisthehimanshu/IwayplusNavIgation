import 'package:hive/hive.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';
//part 'SignINAPIModel.g.dart';

@HiveType(typeId: 7)
class SignINAPIModel extends HiveObject{
  @HiveField(0)
  SignInAPIModel signInAPIModel;

  SignINAPIModel({required this.signInAPIModel});
}