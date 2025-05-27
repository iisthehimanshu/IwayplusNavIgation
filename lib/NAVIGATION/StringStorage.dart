import 'package:shared_preferences/shared_preferences.dart';

class StringStorage {
  static const String _key = 'stored_strings';

  /// Adds a new string, keeping only the latest 2
  static Future<void> addString(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];

    if (current.contains(value)) {
      current.remove(value); // Avoid duplication
    }

    current.add(value);

    // Keep only the latest 2
    if (current.length > 2) {
      current.removeAt(0);
    }

    await prefs.setStringList(_key, current);
  }

  /// Gets the stored strings (latest two)
  static Future<List<String>> getStrings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Clears all stored strings
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
