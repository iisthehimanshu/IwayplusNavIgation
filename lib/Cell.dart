class Cell{
  int node;
  int x;
  int y;
  double lat;
  double lng;
  final Function(double angle, {int? currPointer,int? totalCells}) move;
  bool ttsEnabled;
  String? bid;
  int floor;
  int numCols;
  bool imaginedCell;

  Cell(this.node, this.x, this.y, this.move, this.lat, this.lng,this.bid, this.floor, this.numCols, {this.ttsEnabled = true, this.imaginedCell = false});

  static void printList(List<Cell> list){
    List<List<int>> intList = [];
    for(Cell c in list){
      intList.add([c.x,c.y]);
    }
    print(intList);
  }

}