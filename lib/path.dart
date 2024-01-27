class Node {
  int index;
  int x, y;
  int g = 0, h = 0, f = 0;
  Node? parent;

  Node(this.index, this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Node && runtimeType == other.runtimeType && index == other.index;

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
  // Adjusting source and destination indices to start from 0
  sourceIndex -= 1;
  destinationIndex -= 1;

  if (sourceIndex < 0 || sourceIndex >= numRows * numCols ||
      destinationIndex < 0 || destinationIndex >= numRows * numCols) {
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

  // Inside the while loop of findPath function
  // Inside the while loop of findPath function
  while (openSet.isNotEmpty) {
    int currentIdx = openSet.removeAt(0);
    closedSet.add(currentIdx);

    if (currentIdx == destinationIndex) {
      // Reconstruct the path
      List<int> path = [];
      Node current = nodes[currentIdx];
      while (current.parent != null) {
        path.insert(0, current.index);
        current = current.parent!;
      }
      return path;
    }

    for (int neighborIndex
    in getNeighbors(currentIdx, numRows, numCols, nonWalkableSet)) {
      if (closedSet.contains(neighborIndex)) continue;

      Node neighbor = nodes[neighborIndex];
      int tentativeG = nodes[currentIdx].g + 1;

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
              // Use heuristic as a tie-breaker
              return nodes[a].h.compareTo(nodes[b].h);
            }
            return compare;
          });

        }
      }
    }
  }



  // No path found
  return [];
}

List<int> getNeighbors(
    int index, int numRows, int numCols, Set<int> nonWalkableSet) {
  int x = (index % numCols) + 1;
  int y = (index ~/ numCols) + 1;
  List<int> neighbors = [];

  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if ((dx == 0 || dy == 0) && !(dx == 0 && dy == 0)) {
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
  }

  return neighbors;
}
List<int> rdp(List<int> points, double epsilon) {
  if (points.length < 3) {
    return points;
  }

  int dmax = 0;
  int index = 0;
  int end = points.length - 1;

  for (int i = 1; i < end; i++) {
    int d = perpendicularDistance(points[i], points[0], points[end]);
    if (d > dmax) {
      index = i;
      dmax = d;
    }
  }

  if (dmax > epsilon) {
    List<int> recursiveResults1 = rdp(points.sublist(0, index + 1), epsilon);
    List<int> recursiveResults2 = rdp(points.sublist(index, end + 1), epsilon);

    List<int> result = [...recursiveResults1, ...recursiveResults2.sublist(1)];
    return result;
  } else {
    return [points[0], points[end]];
  }
}

int perpendicularDistance(int point, int lineStart, int lineEnd) {
  int x = (point - lineStart) % 4;
  int y = (point - lineStart) ~/ 4;

  int dx = (lineEnd - lineStart) % 4;
  int dy = (lineEnd - lineStart) ~/ 4;

  int d = (x * dy - y * dx).abs();
  return d;
}





int heuristic(Node a, Node b) {
  // Euclidean distance
  double distance = ((a.x - b.x).abs() + (a.y - b.y).abs()).toDouble();
  return distance.round();
}


void main(){
  // int numRows = 587;
  // int numCols = 1079;
  // int sourceIndex = 381859;
  // int destinationIndex = 420861;
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
  //     int row = (node % 1079);
  //     int col = (node ~/ 1079);
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