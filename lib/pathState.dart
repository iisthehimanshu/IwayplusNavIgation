class pathState {
  String sourcePolyID = "";
  String destinationPolyID = "";
  String sourceName = "";
  String destinationName = "";
  int sourceX = 0;
  int sourceY = 0;
  int destinationX = 0;
  int destinationY = 0;
  int sourceFloor = 0;
  int destinationFloor = 0;
  Map<int, List<int>> path = {};
  List<Map<String, int>> directions = [];
  int numCols = 0;
  int index = 0;
  String sourceBid = "";
  String destinationBid = "";

  // Default constructor without arguments
  pathState();

  // Additional constructor with named parameters for creating instances with specific values
  pathState.withValues(
      this.sourceX, this.sourceY, this.sourceFloor, this.destinationX, this.destinationY, this.destinationFloor, this.numCols, this.index);


  void swap() {
    // Swap source and destination information
    String tempPolyID = sourcePolyID;
    sourcePolyID = destinationPolyID;
    destinationPolyID = tempPolyID;

    String tempsourceBid = sourceBid;
    sourceBid = destinationBid;
    destinationBid = tempsourceBid;

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