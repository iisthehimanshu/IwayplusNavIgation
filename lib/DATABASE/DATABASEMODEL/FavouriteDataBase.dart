import 'package:hive/hive.dart';

import '../../LOGIN SIGNUP/LOGIN SIGNUP APIS/MODELS/SignInAPIModel.dart';
part 'FavouriteDataBase.g.dart';

@HiveType(typeId: 4)
class FavouriteDataBaseModel extends HiveObject{
  @HiveField(0)
  SignInAPIModel signInAPIModel;
  // String venueBuildingName="";
  //
  // @HiveField(1)
  // String venueBuildingLocation="";

  FavouriteDataBaseModel({required this.signInAPIModel});

}