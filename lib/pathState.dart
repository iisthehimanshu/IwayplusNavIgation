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
  Map<int,List<int>> path = {};
  List<Map<String,int>> directions = [];

  pathState(this.sourceX,this.sourceY,this.sourceFloor,this.destinationX,this.destinationY,this.destinationFloor);
}