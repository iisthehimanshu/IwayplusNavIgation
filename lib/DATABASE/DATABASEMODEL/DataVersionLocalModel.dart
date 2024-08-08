import 'package:hive/hive.dart';

import '../../APIMODELS/DataVersion.dart';
part 'DataVersionLocalModel.g.dart';

@HiveType(typeId: 10)
class DataVersionLocalModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DataVersionLocalModel({required this.responseBody});
}