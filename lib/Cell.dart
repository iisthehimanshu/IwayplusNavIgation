class Cell{
  int node;
  int x;
  int y;
  double lat;
  double lng;
  final Function(double angle) move;

  Cell(this.node, this.x, this.y, this.move, this.lat, this.lng);
}