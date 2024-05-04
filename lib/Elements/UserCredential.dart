
class UserCredentials{
  static String RefreshToken = "";
  static String AccessToken = "";
  static List<dynamic> Roles = [];
  static String UserId = "";

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