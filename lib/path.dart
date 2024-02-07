class Node {
  int index;
  int x, y;
  int g = 0, h = 0, f = 0;
  Node? parent;

  Node(this.index, this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Node &&
              runtimeType == other.runtimeType &&
              index == other.index;

  @override
  int get hashCode => index.hashCode;
}

List<int> findPath(
    int numRows,
    int numCols,
    List<int> nonWalkableCells,
    int sourceIndex,
    int destinationIndex,
    ) {
  sourceIndex -= 1;
  destinationIndex -= 1;

  if (sourceIndex < 0 ||
      sourceIndex >= numRows * numCols ||
      destinationIndex < 0 ||
      destinationIndex >= numRows * numCols) {
    print("Invalid source or destination index.");
    return [];
  }

  List<Node> nodes = List.generate(numRows * numCols, (index) {
    int x = index % numCols + 1;
    int y = index ~/ numCols + 1;
    return Node(index + 1, x, y);
  });

  Set<int> nonWalkableSet = nonWalkableCells.toSet();
  List<int> openSet = [sourceIndex];
  Set<int> closedSet = {};

  while (openSet.isNotEmpty) {
    int currentIdx = openSet.removeAt(0);
    closedSet.add(currentIdx);

    if (currentIdx == destinationIndex) {
      List<int> path = [];
      Node current = nodes[currentIdx];
      while (current.parent != null) {
        path.insert(0, current.index);
        current = current.parent!;
      }
      path.insert(0, sourceIndex + 1);
      return path;
    }

    for (int neighborIndex
    in getNeighbors(currentIdx, numRows, numCols, nonWalkableSet)) {
      if (closedSet.contains(neighborIndex)) continue;

      Node neighbor = nodes[neighborIndex];
      int tentativeG = nodes[currentIdx].g + getMovementCost(nodes[currentIdx], neighbor);

      if (!openSet.contains(neighborIndex) || tentativeG < neighbor.g) {
        neighbor.parent = nodes[currentIdx];
        neighbor.g = tentativeG;
        neighbor.h = heuristic(neighbor, nodes[destinationIndex]);
        neighbor.f = neighbor.g + neighbor.h;

        if (!openSet.contains(neighborIndex)) {
          openSet.add(neighborIndex);
          openSet.sort((a, b) {
            int compare = nodes[a].f.compareTo(nodes[b].f);
            if (compare == 0) {
              return nodes[a].h.compareTo(nodes[b].h);
            }
            return compare;
          });
        }
      }
    }
  }

  return [];
}

List<int> getNeighbors(
    int index, int numRows, int numCols, Set<int> nonWalkableSet) {
  int x = (index % numCols) + 1;
  int y = (index ~/ numCols) + 1;
  List<int> neighbors = [];

  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) {
        continue;
      }

      int newX = x + dx;
      int newY = y + dy;

      if (newX >= 1 && newX <= numCols && newY >= 1 && newY <= numRows) {
        int neighborIndex = (newY - 1) * numCols + (newX - 1);
        if (!nonWalkableSet.contains(neighborIndex + 1)) {
          neighbors.add(neighborIndex);
        }
      }
    }
  }

  return neighbors;
}

int heuristic(Node a, Node b) {
  double distance =
  ((a.x - b.x).abs() + (a.y - b.y).abs()).toDouble();
  return distance.round();
}

int getMovementCost(Node a, Node b) {
  return (a.x != b.x && a.y != b.y) ? 14 : 10;
}



void main(){
  // int numRows = 275; //floor breadth
  // int numCols = 282; //floor length
  // int sourceIndex = 22043;
  // int destinationIndex = 69896;
  //
  // List<int> path = findPath(
  //   numRows,
  //   numCols,
  //   building.nonWalkable[0]!,
  //   sourceIndex,
  //   destinationIndex,
  // );
  //
  // if (path.isNotEmpty) {
  //   print("Path found: $path");
  // } else {
  //   print("No path found.");
  // }
  //
  // List<LatLng> coordinates = [];
  // for (int node in path) {
  //   if(!building.nonWalkable[0]!.contains(node)){
  //     int row = (node % 282); //divide by floor length
  //     int col = (node ~/ 282); //divide by floor length
  //     print("[$row,$col]");
  //     coordinates.add(LatLng(tools.localtoglobal(row, col)[0], tools.localtoglobal(row, col)[1]));
  //   }
  //
  // }
  // setState(() {
  //   singleroute.add(gmap.Polyline(
  //     polylineId: PolylineId("route"),
  //     points: coordinates,
  //     color: Colors.red,
  //     width: 1,
  //   ));
  // });
}