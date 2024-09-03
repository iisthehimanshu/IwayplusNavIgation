import 'package:shared_preferences/shared_preferences.dart';

class userdata{

  Future<bool> isDataPresent(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);

    // Check if 'username' key exists and has a non-null value
    if (value != null) {
      return true; // Data is present
    } else {
      return false; // Data is not present
    }
  }

  Future<void> savedata(String key,String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> delete(String key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<String> retrievedata(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    if (value != null) {
      return value; // Data is present
    } else {
      return "error"; // Data is not present
    }
  }
}