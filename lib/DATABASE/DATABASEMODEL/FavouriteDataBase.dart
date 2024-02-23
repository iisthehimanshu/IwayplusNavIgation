import 'package:hive/hive.dart';
part 'FavouriteDataBase.g.dart';

@HiveType(typeId: 4)
class FavouriteDataBaseModel extends HiveObject{
  @HiveField(0)
  String venueBuildingName="";

  @HiveField(1)
  String venueBuildingLocation="";

  FavouriteDataBaseModel({required this.venueBuildingName,required this.venueBuildingLocation});

}