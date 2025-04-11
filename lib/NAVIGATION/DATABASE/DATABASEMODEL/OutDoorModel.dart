import 'package:hive/hive.dart';
part 'OutDoorModel.g.dart';

@HiveType(typeId: 8)
class OutDoorModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  OutDoorModel({required this.responseBody});
}