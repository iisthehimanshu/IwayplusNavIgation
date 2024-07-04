class Cell{
  int node;
  int x;
  int y;
  double lat;
  double lng;
  final Function(double angle, {int? currPointer,int? totalCells}) move;
  bool ttsEnabled;
  String? bid;

  Cell(this.node, this.x, this.y, this.move, this.lat, this.lng,this.bid, {this.ttsEnabled = true});

}