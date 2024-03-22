
import 'package:hive/hive.dart';
// part 'SignINAPIModel.g.dart';

@HiveField(7)
class SignINAPIModel extends HiveObject{
  @HiveField(0)
  String name;

  SignINAPIModel({required this.name});

}