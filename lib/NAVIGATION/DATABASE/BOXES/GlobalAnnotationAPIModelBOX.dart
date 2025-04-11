import 'package:hive/hive.dart';
import '../DATABASEMODEL/GlobalAnnotationAPIModel.dart';


class GlobalAnnotationAPIModelBox{
  static Box<GlobalAnnotationAPIModel> getData() => Hive.box<GlobalAnnotationAPIModel>('GlobalAnnotationAPIModelFile');
}