import 'package:hive/hive.dart';
part 'PolyLineAPIModel.g.dart';

@HiveType(typeId: 2)
class PolyLineAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  PolyLineAPIModel({required this.responseBody});
}