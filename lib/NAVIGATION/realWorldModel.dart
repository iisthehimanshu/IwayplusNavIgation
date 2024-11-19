class RealWorld{
  static late String _campusID;
  static late List<List<double>> _realWorldCoordinates;
  static late String _entryBid;
  static late String _exitBid;
  static late int _entryX;
  static late int _entryY;
  static late int _exitX;

  String get campusID => _campusID;

  set campusID(String value) {
    _campusID = value;
  }

  late int _exitY;

  List<List<double>> get realWorldCoordinates => _realWorldCoordinates;

  set realWorldCoordinates(List<List<double>> value) {
    _realWorldCoordinates = value;
  }

  String get entryBid => _entryBid;

  set entryBid(String value) {
    _entryBid = value;
  }

  String get exitBid => _exitBid;

  set exitBid(String value) {
    _exitBid = value;
  }

  int get entryX => _entryX;

  set entryX(int value) {
    _entryX = value;
  }

  int get entryY => _entryY;

  set entryY(int value) {
    _entryY = value;
  }

  int get exitX => _exitX;

  set exitX(int value) {
    _exitX = value;
  }

  int get exitY => _exitY;

  set exitY(int value) {
    _exitY = value;
  }


}