import 'package:hive/hive.dart';
part 'PatchAPIModel.g.dart';

@HiveType(typeId: 1)
class PatchAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  PatchAPIModel({required this.responseBody});
}