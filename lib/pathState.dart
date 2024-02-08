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

  void swap() {
    // Swap source and destination information
    String tempPolyID = sourcePolyID;
    sourcePolyID = destinationPolyID;
    destinationPolyID = tempPolyID;

    String tempName = sourceName;
    sourceName = destinationName;
    destinationName = tempName;

    int tempX = sourceX;
    sourceX = destinationX;
    destinationX = tempX;

    int tempY = sourceY;
    sourceY = destinationY;
    destinationY = tempY;

    int tempFloor = sourceFloor;
    sourceFloor = destinationFloor;
    destinationFloor = tempFloor;

  }
}