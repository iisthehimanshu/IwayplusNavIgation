// import 'dart:math';
//
// class Node {
//   int index;
//   int x, y;
//   int g = 0, h = 0, f = 0;
//   Node? parent;
//
//   Node(this.index, this.x, this.y);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is Node &&
//               runtimeType == other.runtimeType &&
//               index == other.index;
//
//   @override
//   int get hashCode => index.hashCode;
// }
//
// List<int> findPath(
//     int numRows,
//     int numCols,
//     List<int> nonWalkableCells,
//     int sourceIndex,
//     int destinationIndex,
//     ) {
//   sourceIndex -= 1;
//   destinationIndex -= 1;
//
//   if (sourceIndex < 0 ||
//       sourceIndex >= numRows * numCols ||
//       destinationIndex < 0 ||
//       destinationIndex >= numRows * numCols) {
//     print("Invalid source or destination index.");
//     return [];
//   }
//
//   List<Node> nodes = List.generate(numRows * numCols, (index) {
//     int x = index % numCols + 1;
//     int y = index ~/ numCols + 1;
//     return Node(index + 1, x, y);
//   });
//
//   Set<int> nonWalkableSet = nonWalkableCells.toSet();
//   List<int> openSet = [sourceIndex];
//   Set<int> closedSet = {};
//
//   while (openSet.isNotEmpty) {
//     int currentIdx = openSet.removeAt(0);
//     closedSet.add(currentIdx);
//
//     if (currentIdx == destinationIndex) {
//       List<int> path = [];
//       Node current = nodes[currentIdx];
//       while (current.parent != null) {
//         path.insert(0, current.index);
//         current = current.parent!;
//       }
//       path.insert(0, sourceIndex + 1);
//       return path;
//     }
//
//     for (int neighborIndex
//     in getNeighbors(currentIdx, numRows, numCols, nonWalkableSet)) {
//       if (closedSet.contains(neighborIndex)) continue;
//
//       Node neighbor = nodes[neighborIndex];
//       int tentativeG = nodes[currentIdx].g + getMovementCost(nodes[currentIdx], neighbor);
//
//       if (!openSet.contains(neighborIndex) || tentativeG < neighbor.g) {
//         neighbor.parent = nodes[currentIdx];
//         neighbor.g = tentativeG;
//         neighbor.h = heuristic(neighbor, nodes[destinationIndex]);
//         neighbor.f = neighbor.g + neighbor.h;
//
//         if (!openSet.contains(neighborIndex)) {
//           openSet.add(neighborIndex);
//           openSet.sort((a, b) {
//             int compare = nodes[a].f.compareTo(nodes[b].f);
//             if (compare == 0) {
//               return nodes[a].h.compareTo(nodes[b].h);
//             }
//             return compare;
//           });
//         }
//       }
//     }
//   }
//
//   return [];
// }
//
// List<int> getNeighbors(
//     int index, int numRows, int numCols, Set<int> nonWalkableSet) {
//   int x = (index % numCols) + 1;
//   int y = (index ~/ numCols) + 1;
//   List<int> neighbors = [];
//
//   for (int dx = -1; dx <= 1; dx++) {
//     for (int dy = -1; dy <= 1; dy++) {
//       if (dx == 0 && dy == 0) {
//         continue;
//       }
//
//       int newX = x + dx;
//       int newY = y + dy;
//
//       if (newX >= 1 && newX <= numCols && newY >= 1 && newY <= numRows) {
//         int neighborIndex = (newY - 1) * numCols + (newX - 1);
//         if (!nonWalkableSet.contains(neighborIndex + 1)) {
//           neighbors.add(neighborIndex);
//         }
//       }
//     }
//   }
//
//   return neighbors;
// }
//
// int heuristic(Node a, Node b) {
//   double dx = (a.x - b.x).toDouble();
//   double dy = (a.y - b.y).toDouble();
//   return sqrt(dx * dx + dy * dy).round();
// }
//
// int getMovementCost(Node a, Node b) {
//   return (a.x != b.x && a.y != b.y) ? 15 : 10;
// }
//
//
//
// //rdp code
//
// List<Node> rdp(List<Node> points, double epsilon) {
//   if (points.length < 3) return points;
//
//   // Find the point with the maximum distance
//   int dmax = 0;
//   int index = 0;
//   int end = points.length - 1;
//   for (int i = 1; i < end; i++) {
//     int d = perpendicularDistance(points[i], points[0], points[end]);
//     if (d > dmax) {
//       index = i;
//       dmax = d;
//     }
//   }
//
//   // If max distance is greater than epsilon, recursively simplify
//   List<Node> result = [];
//   if (dmax > epsilon) {
//     List<Node> recursiveResults1 = rdp(points.sublist(0, index + 1), epsilon);
//     List<Node> recursiveResults2 = rdp(points.sublist(index, end + 1), epsilon);
//     result = [...recursiveResults1.sublist(0, recursiveResults1.length - 1), ...recursiveResults2];
//   } else {
//     result = [points[0], points[end]];
//   }
//
//   return result;
// }
//
// int perpendicularDistance(Node point, Node lineStart, Node lineEnd) {
//    int dx = lineEnd.x - lineStart.x;
//    int dy = lineEnd.y - lineStart.y;
//   int mag = dx * dx + dy * dy;
//   int u = (((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / mag) as int;
//   int ix, iy;
//   if (u < 0) {
//     ix = lineStart.x;
//     iy = lineStart.y;
//   } else if (u > 1) {
//     ix = lineEnd.x;
//     iy = lineEnd.y;
//   } else {
//     ix = lineStart.x + u * dx;
//     iy = lineStart.y + u * dy;
//   }
//   int dx2 = point.x - ix;
//   int dy2 = point.y - iy;
//   return  sqrt(dx2 * dx2 + dy2 * dy2) as int;
// }
//
//
//
//
// void main(){
//   // int numRows = 275; //floor breadth
//   // int numCols = 282; //floor length
//   // int sourceIndex = 22043;
//   // int destinationIndex = 69896;
//   //
//   // List<int> path = findPath(
//   //   numRows,
//   //   numCols,
//   //   building.nonWalkable[0]!,
//   //   sourceIndex,
//   //   destinationIndex,
//   // );
//   //
//   // if (path.isNotEmpty) {
//   //   print("Path found: $path");
//   // } else {
//   //   print("No path found.");
//   // }
//   //
//   // List<LatLng> coordinates = [];
//   // for (int node in path) {
//   //   if(!building.nonWalkable[0]!.contains(node)){
//   //     int row = (node % 282); //divide by floor length
//   //     int col = (node ~/ 282); //divide by floor length
//   //     print("[$row,$col]");
//   //     coordinates.add(LatLng(tools.localtoglobal(row, col)[0], tools.localtoglobal(row, col)[1]));
//   //   }
//   //
//   // }
//   // setState(() {
//   //   singleroute.add(gmap.Polyline(
//   //     polylineId: PolylineId("route"),
//   //     points: coordinates,
//   //     color: Colors.red,
//   //     width: 1,
//   //   ));
//   // });
// }


import 'dart:math';

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
      int tentativeG =
          nodes[currentIdx].g + getMovementCost(nodes[currentIdx], neighbor);

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

// List<int> findPath(
//     int numRows,
//     int numCols,
//     List<int> nonWalkableCells,
//     int sourceIndex,
//     int destinationIndex,
//     ) {
//   sourceIndex -= 1;
//   destinationIndex -= 1;
//
//   if (sourceIndex < 0 ||
//       sourceIndex >= numRows * numCols ||
//       destinationIndex < 0 ||
//       destinationIndex >= numRows * numCols) {
//     print("Invalid source or destination index.");
//     return [];
//   }
//
//   List<Node> nodes = List.generate(numRows * numCols, (index) {
//     int x = index % numCols + 1;
//     int y = index ~/ numCols + 1;
//     return Node(index + 1, x, y);
//   });
//
//   Set<int> nonWalkableSet = nonWalkableCells.toSet();
//   List<int> openSet = [sourceIndex];
//   Set<int> closedSet = {};
//
//   while (openSet.isNotEmpty) {
//     int currentIdx = openSet.removeAt(0);
//     closedSet.add(currentIdx);
//
//     if (currentIdx == destinationIndex) {
//       List<int> path = [];
//       Node current = nodes[currentIdx];
//       while (current.parent != null) {
//         path.insert(0, current.index);
//         current = current.parent!;
//       }
//       path.insert(0, sourceIndex + 1);
//
//       // Optimization: Skip points between consecutive turns
//       List<int> optimizedPath = skipConsecutiveTurns(path, numRows, numCols, nonWalkableSet);
//
//       return optimizedPath;
//     }
//
//     for (int neighborIndex
//     in getNeighbors(currentIdx, numRows, numCols, nonWalkableSet)) {
//       if (closedSet.contains(neighborIndex)) continue;
//
//       Node neighbor = nodes[neighborIndex];
//       int tentativeG =
//           nodes[currentIdx].g + getMovementCost(nodes[currentIdx], neighbor);
//
//       if (!openSet.contains(neighborIndex) || tentativeG < neighbor.g) {
//         neighbor.parent = nodes[currentIdx];
//         neighbor.g = tentativeG;
//         neighbor.h = heuristic(neighbor, nodes[destinationIndex]);
//         neighbor.f = neighbor.g + neighbor.h;
//
//         if (!openSet.contains(neighborIndex)) {
//           openSet.add(neighborIndex);
//           openSet.sort((a, b) {
//             int compare = nodes[a].f.compareTo(nodes[b].f);
//             if (compare == 0) {
//               return nodes[a].h.compareTo(nodes[b].h);
//             }
//             return compare;
//           });
//         }
//       }
//     }
//   }
//
//   return [];
// }

// Function to skip points between consecutive turns in the path
List<int> skipConsecutiveTurns(List<int> path, int numRows, int numCols, Set<int> nonWalkableSet) {
  List<int> optimizedPath = [];
  optimizedPath.add(path.first);

  for (int i = 1; i < path.length - 1; i++) {
    int prev = path[i - 1];
    int current = path[i];
    int next = path[i + 1];

    // Check if the points form a turn
    if (!isTurn(prev, current, next, numRows, numCols) || nonWalkableSet.contains(current)) {
      optimizedPath.add(current);
    }
  }

  optimizedPath.add(path.last);
  print("optimizedPath $optimizedPath");
  return optimizedPath;
}

// Function to check if the given points form a turn
bool isTurn(int prev, int current, int next, int numRows, int numCols) {
  int prevRow = prev ~/ numCols;
  int prevCol = prev % numCols;
  int currentRow = current ~/ numCols;
  int currentCol = current % numCols;
  int nextRow = next ~/ numCols;
  int nextCol = next % numCols;

  // Check if the points form a turn
  return (prevRow == currentRow && nextCol == currentCol) || (prevCol == currentCol && nextRow == currentRow);
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
  double dx = (a.x - b.x).toDouble();
  double dy = (a.y - b.y).toDouble();
  return sqrt(dx * dx + dy * dy).round();
}

int getMovementCost(Node a, Node b) {
  return (a.x != b.x && a.y != b.y) ? 15 : 10;
}

List<Node> findOptimizedPath(
    int numRows,
    int numCols,
    List<int> nonWalkableCells,
    int sourceIndex,
    int destinationIndex,
    double epsilon,
    ) {


  List<int> pathIndices = findPath(
    numRows,
    numCols,
    nonWalkableCells,
    sourceIndex,
    destinationIndex,
  );

  List<Node> nodes = List.generate(numRows * numCols, (index) {
    int x = index % numCols;
    int y = index ~/ numCols;
    return Node(index, x, y);
  });

  List<Node> pathNodes = pathIndices.map((index) => nodes[index - 1]).toList();











 List<Node> turnPoints= getTurnpoints(pathNodes,numCols);
  //Apply RDP optimization to the path
 Set<int> nonWalkableSet = nonWalkableCells.toSet();
  List<Node> optimizedPath = rdp(pathNodes, epsilon,nonWalkableSet);

//
print("turnPointts: ${turnPoints[0].index}");

  List<Node> pt=[];
  for(int i=0;i<turnPoints.length-1;i++){
    int x1 = (turnPoints[i].index % numCols);
    int y1 = (turnPoints[i].index ~/ numCols);
    if(turnPoints[i+1]==turnPoints[i]){
      pt.add(turnPoints[i+1]);
    }
  }

  for(int i=0;i<pt.length;i++){

    if(optimizedPath[pt[i].x+1].x==optimizedPath[pt[i].x].x){
      optimizedPath[pt[i].y].y=optimizedPath[pt[i].y-1].y;
    }else if(optimizedPath[pt[i].y+1].y==optimizedPath[pt[i].y].y){
      optimizedPath[pt[i].x].x=optimizedPath[pt[i].x-1].x;
    }
  }

  return optimizedPath;
}

List<Node> getTurnpoints(List<Node> pathNodes,int numCols){
  List<Node> res=[];



  for(int i=1;i<pathNodes.length-1;i++){



    Node currPos=pathNodes[i];
    Node nextPos=pathNodes[i+1];
    Node prevPos=pathNodes[i-1];

    int x1 = (currPos.index % numCols);
    int y1 = (currPos.index ~/ numCols);

    int x2 = (nextPos.index % numCols);
    int y2 = (nextPos.index ~/ numCols);

    int x3 = (prevPos.index % numCols);
    int y3 = (prevPos.index ~/ numCols);

    int prevDeltaX=x1-x3;
    int prevDeltaY=y1-y3;
    int nextDeltaX=x2-x1;
    int nextDeltaY=y2-y1;

    if((prevDeltaX!=nextDeltaX)|| (prevDeltaY!=nextDeltaY)){

      res.add(currPos);
    }



  }
  return res;
}


// List<Node> rdp(List<Node> points, double epsilon, Set<int> nonWalkableIndices) {
//   double dmax = 0.0;
//   int index = 0;
//   for (int i = 0; i < points.length - 1; i++) {
//     double d =
//     pointLineDistance(points[i], points[0], points[points.length - 1]);
//     if (d > dmax) {
//       index = i;
//       dmax = d;
//     }
//   }
//
//   List<Node> results = [];
//   if (points.length < 3) {
//     return List<Node>.from(points);
//   }
//
//   if (dmax >= epsilon) {
//     List<Node> temp1 = rdp(points.sublist(0, index + 1), epsilon, nonWalkableIndices);
//     temp1 = temp1.sublist(0, temp1.length - 1);
//     List<Node> temp2 = rdp(points.sublist(index, points.length), epsilon, nonWalkableIndices);
//     results.addAll(temp1);
//     results.addAll(temp2);
//   } else {
//     results.add(points[0]);
//     results.add(points[points.length - 1]);
//   }
//
//   // Remove non-walkable points from the simplified path
//   results.removeWhere((point) => nonWalkableIndices.contains(points.indexOf(point)));
//
//   return results;
// }

// List<Node> rdp(List<Node> points, double epsilon,Set<int> nonWalkableIndices ) {
//   if (points.length < 2) return points;
//
//   // Find the point with the maximum perpendicular distance
//   double dmax = 0.0;
//   int index = 0;
//   int end = points.length - 1;
//   for (int i = 1; i < end; i++) {
//     double d = pointLineDistance(points[i], points[0], points[end]);
//     if (d > dmax) {
//       index = i;
//       dmax = d;
//     }
//   }
//
//   // If max distance is greater than epsilon, recursively simplify
//   List<Node> result = [];
//   if (dmax > epsilon) {
//     List<Node> recursiveResults1 = rdp(points.sublist(0, index + 1), epsilon,nonWalkableIndices);
//     List<Node> recursiveResults2 = rdp(points.sublist(index, end + 1), epsilon,nonWalkableIndices);
//     // Skip adding points between consecutive turns
//     if (points[index - 1] != recursiveResults2.first) {
//       result.addAll(recursiveResults1.sublist(0, recursiveResults1.length - 1));
//     } else {
//       result.addAll(recursiveResults1);
//     }
//     result.addAll(recursiveResults2);
//   } else {
//     result = [points[0], points[end]];
//   }
//   // Remove non-walkable points from the simplified path
//   result.removeWhere((point) => nonWalkableIndices.contains(points.indexOf(point)));
//
//   return result;
// }

double pointLineDistance( Node point, Node start, Node end) {
if (start.x == end.x && start.y == end.y) {
return distance(point, start);
} else {
double n = ((end.x - start.x) * (start.y - point.y) -
(start.x - point.x) * (end.y - start.y))
    .abs()+0.0;
double d = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2));
return n / d;
}
}
double distance(Node a, Node b) {
  return sqrt(pow(a.y - b.x, 2) + pow(a.y - b.x, 2));
}

List<Node> rdp(List<Node> points, double epsilon, Set<int> nonWalkableIndices) {
  if (points.length < 3) return points;

  // Find the point with the maximum distance
  double dmax = 0;
  int index = 0;
  int end = points.length - 1;
  for (int i = 1; i < end; i++) {
    double d = perpendicularDistance(points[i], points[0], points[end]);
    if (d > dmax) {
      index = i;
      dmax = d;
    }
  }

  // If max distance is greater than epsilon, recursively simplify
  List<Node> result = [];
  if (dmax > epsilon) {
    List<Node> recursiveResults1 =
    rdp(points.sublist(0, index + 1), epsilon, nonWalkableIndices);
    List<Node> recursiveResults2 =
    rdp(points.sublist(index, end + 1), epsilon, nonWalkableIndices);
    result = [
      ...recursiveResults1.sublist(0, recursiveResults1.length - 1),
      ...recursiveResults2
    ];
  } else {
    // Ensure rectilinear path by including only points that align with the grid
    result = [points[0]]; // Start node is always included
    Node previousPoint = points[0];
    for (int i = 1; i < end; i++) {
      if (points[i].x == previousPoint.x || points[i].y == previousPoint.y) {
        if (!nonWalkableIndices.contains(points[i].index)) {
          result.add(points[i]);
          previousPoint = points[i];
        }
      }
    }
    result.add(points[end]); // End node is always included
  }

  return result;
}

List<int> getIntersectionPoints( int currX,
          int currY,
          int prevX,
          int prevY, int nextX,
          int nextY,
          int nextNextX,
          int nextNextY){
  
    double x1 = currX+0.0, y1 = currY+0.0;
    double x2 = prevX+0.0, y2 = prevY+0.0;
    double x3 = nextX+0.0, y3 = nextY+0.0;
    double x4 = nextNextX+0.0, y4 = nextNextY+0.0;

    double determinant = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

    if (determinant == 0) {
      // Lines are parallel, no intersection
      return [];
    }

    double intersectionX =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
            determinant;
    double intersectionY =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
            determinant;

    return [intersectionX.toInt(),intersectionY.toInt()];
  }

  





double perpendicularDistance(Node point, Node lineStart, Node lineEnd) {
  double dx = (lineEnd.x - lineStart.x)+0.0;
  double dy = (lineEnd.y - lineStart.y)+0.0;
  double mag = dx * dx + dy * dy;
  double u = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / mag;
  double ix, iy;
  if (u < 0) {
    ix = lineStart.x.toDouble();
    iy = lineStart.y.toDouble();
  } else if (u > 1) {
    ix = lineEnd.x.toDouble();
    iy = lineEnd.y.toDouble();
  } else {
    ix = (lineStart.x + u * dx).toDouble();
    iy = (lineStart.y + u * dy).toDouble();
  }
  double dx2 = point.x - ix;
  double dy2 = point.y - iy;
  return sqrt(dx2 * dx2 + dy2 * dy2);
}


List<int> getOptiPath(Map<int,int> getTurns,int numCols,List<int> path){
  Map<int,int> pt={};
  var keys=getTurns.keys.toList();
  for(int i=0;i<keys.length-1;i++){
    if(keys[i+1]-1==keys[i]){
      pt[keys[i+1]]=getTurns[keys[i+1]]!;
    }
  }

  var ptKeys=pt.keys.toList();
  for(int i=0;i<pt.length;i++){
    int curr=path[ptKeys[i]];
    int next=path[ptKeys[i]+1];
    int prev=path[ptKeys[i]-1];
    int nextNext=path[ptKeys[i]+2];


    int currX=curr%numCols;
    int currY=curr~/numCols;

    int nextX=next%numCols;
    int nextY=next~/numCols;

    int prevX=prev%numCols;
    int prevY=prev~/numCols;


    int nextNextX=nextNext%numCols;
    int nextNextY=nextNext~/numCols;



    if(nextX==currX){
      currY=prevY;
      int newIndexY=currY*numCols+currX;
      path[ptKeys[i]]=newIndexY;
    }else if(nextY==currY){
      currX=prevX;
      int newIndexX=currY*numCols+currX;
      path[ptKeys[i]]=newIndexX;
    }
  }

  return path;
}
