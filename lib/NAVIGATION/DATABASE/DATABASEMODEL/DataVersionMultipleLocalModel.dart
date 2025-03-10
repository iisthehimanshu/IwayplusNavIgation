import 'package:hive/hive.dart';
import '../../APIMODELS/DataVersionApiMultipleModel.dart';
part 'DataVersionMultipleLocalModel.g.dart';

@HiveType(typeId: 40)
class DataVersionMultipleLocalModel extends HiveObject{
  @HiveField(0)
  dynamic responseBody;

  DataVersionMultipleLocalModel({required this.responseBody});
}