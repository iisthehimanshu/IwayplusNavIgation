
import 'package:hive/hive.dart';
part 'LocalNotificationAPIDatabaseModel.g.dart';


@HiveType(typeId: 25)
class LocalNotificationAPIDatabaseModel extends HiveObject{
  @HiveField(0)
  Map<String,dynamic> responseBody;

  LocalNotificationAPIDatabaseModel({required this.responseBody});
}