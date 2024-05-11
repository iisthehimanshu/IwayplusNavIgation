
import 'package:hive/hive.dart';

class UserCredentials{
   static var userInformationBox = Hive.box('UserInformation');

  static String RefreshToken = "";
  static String AccessToken = "";
  static List<dynamic> Roles = [];
  static String UserId = "";
  static String UserHeight = "";
  static String UserPersonWithDisability = "";
  static String UserNavigationModeSetting = "";
  static String UserOrentationSetting = "";
  static String UserPathDetails = '';


  static void setUserHeight(String userheight){
    userInformationBox.put('UserHeight', userheight);

  }
  static String getUserHeight(){
    UserHeight = userInformationBox.get('UserHeight')?? '5.8';
    return UserHeight;
  }

  static void setUserPersonWithDisability(String userdisabilitytype){
    userInformationBox.put('UserDisabilityType', userdisabilitytype);

  }
  static String getUserPersonWithDisability(){
    UserHeight = userInformationBox.get('UserDisabilityType');
    return UserHeight;
  }

  static void setUserNavigationModeSetting(String userNavigationModeSetting){
    userInformationBox.put('UserNavigationModeSetting', userNavigationModeSetting);
  }
  static String getuserNavigationModeSetting(){
    UserNavigationModeSetting = userInformationBox.get('UserNavigationModeSetting');
    return UserNavigationModeSetting;
  }

  static void setUserOrentationSetting(String userOrentationSetting){
    userInformationBox.put('UserOrentationSetting', userOrentationSetting);
  }
  static String getUserOrentationSetting(){
    UserOrentationSetting = userInformationBox.get('UserOrentationSetting');
    return UserOrentationSetting;
  }

  static void setUserPathDetails(String userUserPathDetails){
    userInformationBox.put('UserPathDetails', userUserPathDetails);
  }
   static String getUserPathDetails(){
     UserPathDetails = userInformationBox.get('UserPathDetails');
     return UserPathDetails;
   }







  static bool containsAccessToken(){
    return AccessToken.length!=0;
  }

  static String getRefreshToken(){
    return RefreshToken;
  }
  static void setRefreshToken(String refreshToken){
    RefreshToken = refreshToken;
  }

  static String getAccessToken(){
    return AccessToken;
  }
  static void setAccessToken(String accessToken) async {
    AccessToken = accessToken;
  }

  static List<dynamic> getRoles(){
    return Roles;
  }
  static void setRoles(List<dynamic> roles){
    Roles = roles;
  }

  static String getUserId(){
    return UserId;
  }
  static void setUserId(String userId){
    UserId = userId;
  }
}