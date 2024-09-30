
import 'package:hive/hive.dart';
import '../DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';

class LocalNotificationAPIDatabaseModelBOX{
  static Box<LocalNotificationAPIDatabaseModel> getData() => Hive.box<LocalNotificationAPIDatabaseModel>('LocalNotificationAPIDatabaseModel');
}