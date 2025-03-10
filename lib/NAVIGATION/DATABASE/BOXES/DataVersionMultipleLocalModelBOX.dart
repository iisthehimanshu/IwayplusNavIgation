import 'package:hive/hive.dart';

import '../DATABASEMODEL/DataVersionMultipleLocalModel.dart';

class DataVersionMultipleLocalModelBOX{
  static Box<DataVersionMultipleLocalModel> getData() => Hive.box<DataVersionMultipleLocalModel>('DataVersionLocalMultipleModelFile');
}