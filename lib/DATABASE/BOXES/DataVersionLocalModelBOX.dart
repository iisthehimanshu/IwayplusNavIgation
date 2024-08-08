import 'package:hive/hive.dart';
import '../../APIMODELS/DataVersion.dart';
import '../DATABASEMODEL/DataVersionLocalModel.dart';

class DataVersionLocalModelBOX{
  static Box<DataVersionLocalModel> getData() => Hive.box<DataVersionLocalModel>('DataVersionLocalModelFile');
}