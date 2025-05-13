
class Localization{
  static final Localization _instance = Localization._internal();

  factory Localization() {
    return _instance;
  }

  Localization._internal();

  String _nearestBeacon = "";
  String? get nearestBeacon => _nearestBeacon;

  set nearestBeacon(String? value) {
    _nearestBeacon = value ?? "";
  }

}