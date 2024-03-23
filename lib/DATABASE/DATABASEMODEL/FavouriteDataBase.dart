import 'package:hive/hive.dart';

import '../../LOGIN SIGNUP/LOGIN SIGNUP APIS/MODELS/SignInAPIModel.dart';
part 'FavouriteDataBase.g.dart';

@HiveType(typeId: 4)
class FavouriteDataBaseModel extends HiveObject{
  @HiveField(0)
  FavouriteDataBaseModel favouriteDataBaseModel;

  FavouriteDataBaseModel({required this.favouriteDataBaseModel});

}