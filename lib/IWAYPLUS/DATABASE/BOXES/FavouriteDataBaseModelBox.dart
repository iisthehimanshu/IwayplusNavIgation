import 'package:hive/hive.dart';
import '../DATABASEMODEL/BuildingAllAPIModel.dart';
import '../DATABASEMODEL/FavouriteDataBase.dart';

class FavouriteDataBaseModelBox{
  static Box<FavouriteDataBaseModel> getData() => Hive.box<FavouriteDataBaseModel>("FavouriteDataBaseModelFile");
}