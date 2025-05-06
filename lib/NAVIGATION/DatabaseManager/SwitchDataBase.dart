
class SwitchDataBase{

  static final SwitchDataBase _instance = SwitchDataBase._internal();

  SwitchDataBase._internal();

  factory SwitchDataBase() {
    return _instance;
  }

  bool greenDataBase = true;

  bool isGreenDataBaseActive(){
    return greenDataBase;
  }

  void switchGreenDataBase(bool value){
    greenDataBase = value;
    print("greenDataBase $greenDataBase");
    print(isGreenDataBaseActive());
  }
}