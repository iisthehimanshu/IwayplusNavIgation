class pathState{
  String sourcePolyID = "";
  String destinationPolyID = "";
  String sourceName = "";
  String destinationName = "";
  int sourceX;
  int sourceY;
  int destinationX;
  int destinationY;
  int sourceFloor;
  int destinationFloor;
  List<List<int>> path = [];

  pathState(this.sourceX,this.sourceY,this.sourceFloor,this.destinationX,this.destinationY,this.destinationFloor);
}