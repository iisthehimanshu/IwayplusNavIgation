import 'package:hive/hive.dart';
part 'GlobalAnnotationAPIModel.g.dart';

@HiveType(typeId: 21)
class GlobalAnnotationAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  GlobalAnnotationAPIModel({required this.responseBody});
}