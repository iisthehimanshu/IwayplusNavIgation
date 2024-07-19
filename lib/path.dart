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
//     //print("Invalid source or destination index.");
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
//   //   //print("Path found: $path");
//   // } else {
//   //   //print("No path found.");
//   // }
//   //
//   // List<LatLng> coordinates = [];
//   // for (int node in path) {
//   //   if(!building.nonWalkable[0]!.contains(node)){
//   //     int row = (node % 282); //divide by floor length
//   //     int col = (node ~/ 282); //divide by floor length
//   //     //print("[$row,$col]");
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

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:iwaymaps/buildingState.dart';
import 'package:iwaymaps/pathState.dart';

import 'APIMODELS/landmark.dart';
import 'Cell.dart';
import 'navigationTools.dart';

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

Future<List<int>> findBestPathAmongstBoth(
    int numRows,
    int numCols,
    List<int> nonWalkableCells,
    int sourceIndex,
    int destinationIndex,
    Building building,
    int floor,
    String Bid)async{
  int sourceX = sourceIndex % numCols;
  int sourceY = sourceIndex ~/ numCols;
  int destinationX = destinationIndex % numCols;
  int destinationY = destinationIndex ~/ numCols;

  // List<int> p1 = findPath(
  //     numRows, numCols, nonWalkableCells, sourceIndex, destinationIndex);
  // p1 = await getFinalOptimizedPath(p1, nonWalkableCells, numCols, sourceX, sourceY,
  //     destinationX, destinationY, building, floor,Bid);
  // List<int> p2 = findPath(
  //     numRows, numCols, nonWalkableCells, destinationIndex, sourceIndex);
  // p2 = await getFinalOptimizedPath(p2, nonWalkableCells, numCols, destinationX,
  //     destinationY, sourceX, sourceY, building, floor,Bid);

  List<int> p1 = await findPath(numRows, numCols, nonWalkableCells, sourceIndex, destinationIndex);
  p1 = getFinalOptimizedPath(p1, nonWalkableCells, numCols,  sourceX,    sourceY,    destinationX,    destinationY);
  List<int> p2 = await findPath(numRows, numCols, nonWalkableCells, destinationIndex, sourceIndex);
  p2 = getFinalOptimizedPath(p2, nonWalkableCells, numCols,destinationX,    destinationY,  sourceX,    sourceY);

  Map<int, int> p1turns = tools.getTurnMap(p1, numCols);
  Map<int, int> p2turns = tools.getTurnMap(p2, numCols);

  //print("p1 length ${p1.length}");
  //print("p2 length ${p2.length}");
  //print("p1 turns ${p1turns}");
  //print("p2 turns ${p2turns}");

  //print("pathp1 ${p1.length}  ${p1turns.length}  $p1");
  //print("pathp2 ${p2.length}  ${p2turns.length}  $p2");

// If either path is empty, return the other path
  if (p1.isEmpty) {
    return p2.reversed.toList();
  } else if (p2.isEmpty) {
    return p1;
  }

  // Check if both paths start and end at the correct indices
  bool p1Valid = p1.first == sourceIndex && p1.last == destinationIndex;
  bool p2Valid = p2.first == destinationIndex && p2.last == sourceIndex;

  if (p1Valid && !p2Valid) {
    return p1;
  } else if (!p1Valid && p2Valid) {
    return p2.reversed.toList();
  }

  // Compare the number of turns
  if (p1turns.length < p2turns.length) {
    return p1;
  } else if (p1turns.length > p2turns.length) {
    return p2.reversed.toList();
  }

  // If the number of turns is the same, compare the length of the paths
  if (p1.length < p2.length) {
    return p1;
  } else if (p1.length > p2.length) {
    return p2.reversed.toList();
  } else{
    return p1;
  }

  // If all else fails, return an empty list
  return [];

}

Future<List<int>> findPath(
  int numRows,
  int numCols,
  List<int> nonWalkableCells,
  int sourceIndex,
  int destinationIndex,
)async{
  sourceIndex -= 1;
  destinationIndex -= 1;

  if (sourceIndex < 0 ||
      sourceIndex >= numRows * numCols ||
      destinationIndex < 0 ||
      destinationIndex >= numRows * numCols) {
    //print("Invalid source or destination index.");
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


 Future<List<List<List<int>>>> optimizeDiagonalEntry(Building building,List<int> path,int numCols,int floor,String Bid,List<int> nonWalkableCells)async{
  List<List<List<int>>> res = [];
  List<Landmarks> nearbyLandmarks = [];
  await building.landmarkdata!.then((value){
   nearbyLandmarks = tools.findNearbyLandmark(

        path, value.landmarksMap!, 5, numCols, floor, Bid!);

  });


    res = findDoorAndPathTurnCoords(nearbyLandmarks, path, numCols);

    //print(res);
// for(int i=0;i<res.length;i++)
//   {
//     if(res.isNotEmpty){
//       //print("p1-----p2");
//       //print("door cords${res[i][0]}");
//       //print("turn corrds");
//       //print(res[i][1]);
//       //print(res[i][2]);
//     }
//
//   }

List<List<List<int>>> result=[];
    for (int i = 0; i < res.length; i++) {
      List<List<int>> p1 = findIntersection(
          res[i][1],
          res[i][2],
          res[i][0],
          res[i][3],
          res[i][4], nonWalkableCells,numCols

      );
      //print("p1-----p2");
      //print(p1);
      result.add(p1);

    }
    return result;
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
//     //print("Invalid source or destination index.");
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
List<int> skipConsecutiveTurns(
    List<int> path, int numRows, int numCols, Set<int> nonWalkableSet) {
  List<int> optimizedPath = [];
  optimizedPath.add(path.first);

  for (int i = 1; i < path.length - 1; i++) {
    int prev = path[i - 1];
    int current = path[i];
    int next = path[i + 1];

    // Check if the points form a turn
    if (!isTurn(prev, current, next, numRows, numCols) ||
        nonWalkableSet.contains(current)) {
      optimizedPath.add(current);
    }
  }

  optimizedPath.add(path.last);
  //print("optimizedPath $optimizedPath");
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
  return (prevRow == currentRow && nextCol == currentCol) ||
      (prevCol == currentCol && nextRow == currentRow);
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

// List<Node> findOptimizedPath(
//   int numRows,
//   int numCols,
//   List<int> nonWalkableCells,
//   int sourceIndex,
//   int destinationIndex,
//   double epsilon,
// ) {
//   List<int> pathIndices = findBestPathAmongstBoth(
//     numRows,
//     numCols,
//     nonWalkableCells,
//     sourceIndex,
//     destinationIndex,
//
//   );
//
//   List<Node> nodes = List.generate(numRows * numCols, (index) {
//     int x = index % numCols;
//     int y = index ~/ numCols;
//     return Node(index, x, y);
//   });
//
//   List<Node> pathNodes = pathIndices.map((index) => nodes[index - 1]).toList();
//
//   List<Node> turnPoints = getTurnpoints(pathNodes, numCols);
//   //Apply RDP optimization to the path
//   Set<int> nonWalkableSet = nonWalkableCells.toSet();
//   List<Node> optimizedPath = rdp(pathNodes, epsilon, nonWalkableSet);
//
// //
//   //print("turnPointts: ${turnPoints[0].index}");
//
//   List<Node> pt = [];
//   for (int i = 0; i < turnPoints.length - 1; i++) {
//     int x1 = (turnPoints[i].index % numCols);
//     int y1 = (turnPoints[i].index ~/ numCols);
//     if (turnPoints[i + 1] == turnPoints[i]) {
//       pt.add(turnPoints[i + 1]);
//     }
//   }
//
//   for (int i = 0; i < pt.length; i++) {
//     if (optimizedPath[pt[i].x + 1].x == optimizedPath[pt[i].x].x) {
//       optimizedPath[pt[i].y].y = optimizedPath[pt[i].y - 1].y;
//     } else if (optimizedPath[pt[i].y + 1].y == optimizedPath[pt[i].y].y) {
//       optimizedPath[pt[i].x].x = optimizedPath[pt[i].x - 1].x;
//     }
//   }
//
//   return optimizedPath;
// }

List<Node> getTurnpoints(List<Node> pathNodes, int numCols) {
  List<Node> res = [];

  for (int i = 1; i < pathNodes.length - 1; i++) {
    Node currPos = pathNodes[i];
    Node nextPos = pathNodes[i + 1];
    Node prevPos = pathNodes[i - 1];

    int x1 = (currPos.index % numCols);
    int y1 = (currPos.index ~/ numCols);

    int x2 = (nextPos.index % numCols);
    int y2 = (nextPos.index ~/ numCols);

    int x3 = (prevPos.index % numCols);
    int y3 = (prevPos.index ~/ numCols);

    int prevDeltaX = x1 - x3;
    int prevDeltaY = y1 - y3;
    int nextDeltaX = x2 - x1;
    int nextDeltaY = y2 - y1;

    if ((prevDeltaX != nextDeltaX) || (prevDeltaY != nextDeltaY)) {
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

double pointLineDistance(Node point, Node start, Node end) {
  if (start.x == end.x && start.y == end.y) {
    return distance(point, start);
  } else {
    double n = ((end.x - start.x) * (start.y - point.y) -
                (start.x - point.x) * (end.y - start.y))
            .abs() +
        0.0;
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

List<int> getIntersectionPoints(int currX, int currY, int prevX, int prevY,
    int nextX, int nextY, int nextNextX, int nextNextY) {
  double x1 = currX + 0.0, y1 = currY + 0.0;
  double x2 = prevX + 0.0, y2 = prevY + 0.0;
  double x3 = nextX + 0.0, y3 = nextY + 0.0;
  double x4 = nextNextX + 0.0, y4 = nextNextY + 0.0;

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

  return [intersectionX.toInt(), intersectionY.toInt()];
}

double perpendicularDistance(Node point, Node lineStart, Node lineEnd) {
  double dx = (lineEnd.x - lineStart.x) + 0.0;
  double dy = (lineEnd.y - lineStart.y) + 0.0;
  double mag = dx * dx + dy * dy;
  double u =
      ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / mag;
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

List<int> getOptiPath(Map<int, int> getTurns, int numCols, List<int> path) {
  Map<int, int> pt = {};
  var keys = getTurns.keys.toList();
  for (int i = 0; i < keys.length - 1; i++) {
    if (keys[i + 1] - 1 == keys[i]) {
      pt[keys[i + 1]] = getTurns[keys[i + 1]]!;
    }
  }

  var ptKeys = pt.keys.toList();
  for (int i = 0; i < pt.length; i++) {
    int curr = path[ptKeys[i]];
    int next = path[ptKeys[i] + 1];
    int prev = path[ptKeys[i] - 1];
    int nextNext = path[ptKeys[i] + 2];

    int currX = curr % numCols;
    int currY = curr ~/ numCols;

    int nextX = next % numCols;
    int nextY = next ~/ numCols;

    int prevX = prev % numCols;
    int prevY = prev ~/ numCols;

    int nextNextX = nextNext % numCols;
    int nextNextY = nextNext ~/ numCols;

    if (nextX == currX) {
      currY = prevY;
      int newIndexY = currY * numCols + currX;
      path[ptKeys[i]] = newIndexY;
    } else if (nextY == currY) {
      currX = prevX;
      int newIndexX = currY * numCols + currX;
      path[ptKeys[i]] = newIndexX;
    }
  }

  return path;
}

// Future<List<int>> getFinalOptimizedPath(
//     List<int> path,
//     List<int> nonWalkableCells,
//     int numCols,
//     int sourceX,
//     int sourceY,
//     int destinationX,
//     int destinationY,
//     Building building,
//     int floor,String Bid) async {
//   List<List<int>> getPoints = [];
//   Map<int, int> getTurns = tools.getTurnMap(path, numCols);
//
//
//   path = getOptiPath(getTurns, numCols, path);
//
//
//   List<int> turns = tools.getTurnpoints(path, numCols);
//
//
//   for (int i = 0; i < turns.length; i++) {
//     int x = turns[i] % numCols;
//     int y = turns[i] ~/ numCols;
//
//     getPoints.add([x, y]);
//   }
// //optimizing turnsss
//   for (int i = 0; i < getPoints.length - 1; i++) {
//     if (getPoints[i][0] != getPoints[i + 1][0] &&
//         getPoints[i][1] != getPoints[i + 1][1]) {
//       int dist =
//           tools.calculateDistance(getPoints[i], getPoints[i + 1]).toInt();
//       if (dist <= 15) {
//
//         //points of prev turn
//         int index1 = getPoints[i][0] + getPoints[i][1] * numCols;
//         int ind1 = path.indexOf(index1);
//
//         int prev = path[ind1 - 1];
//
//         int currX = index1 % numCols;
//         int currY = index1 ~/ numCols;
//
//         int prevX = prev % numCols;
//         int prevY = prev ~/ numCols;
//
//
//         //straight line eqautaion1
//         //y-prevY=(currY-prevY)/(currX-prevX)*(x-prevX);
//
//         //points of next turn;
//         int index2 = getPoints[i + 1][0] + getPoints[i + 1][1] * numCols;
//         int ind2 = path.indexOf(index2);
//         int next = path[ind2 + 1];
//
//         int nextX = index2 % numCols;
//         int nextY = index2 ~/ numCols;
//
//         int nextNextX = next % numCols;
//         int nextNextY = next ~/ numCols;
//
//
//         int ind3 = path.indexOf(index1 - 1);
//
//         List<int> intersectPoints = getIntersectionPoints(
//             currX, currY, prevX, prevY, nextX, nextY, nextNextX, nextNextY);
//
//         if (intersectPoints.isNotEmpty) {
//           //non walkabkle check
//
//           //first along the x plane
//
//           //intersecting points
//           int x1 = intersectPoints[0];
//           int y1 = intersectPoints[1];
//
//           //next point
//           int x2 = nextX;
//           int y2 = nextY;
//
//           bool isNonWalkablePoint = false;
//
//           while (x1 <= x2) {
//             int pointIndex = x1 + y1 * numCols;
//             if (nonWalkableCells.contains(pointIndex)) {
//               isNonWalkablePoint = true;
//               break;
//             }
//             x1 = x1 + 1;
//           }
//
//           //along the y-axis
//
//           //next point
//           int x3 = currX;
//           int y3 = currY;
//
//           while (y1 >= y3) {
//             int pointIndex = x3 + y1 * numCols;
//             if (nonWalkableCells.contains(pointIndex)) {
//               isNonWalkablePoint = true;
//               break;
//             }
//             y1 = y1 - 1;
//           }
//
//           if (isNonWalkablePoint == false) {
//             path.removeRange(ind1, ind2);
//
//             int newIndex = intersectPoints[0] + intersectPoints[1] * numCols;
//
//
//             path[ind1] = newIndex;
//
//             getPoints[i] = [intersectPoints[0], intersectPoints[1]];
//
//             getPoints.removeAt(i + 1);
//           }
//         }
//
//
//         //print("${ind1}  ${ind2}  ${ind3}");
//
//         //path=getOptiPath(getTurns, numCols, path);
//       }
//     }
//   }
//
//   List<int> tu = [];
//   tu.add(sourceX + sourceY * numCols);
//   tu.addAll(tools.getTurnpoints(path, numCols));
//   tu.add(destinationX + destinationY * numCols);
//   //print("ressssssssss");
//   //creating a new array and gearting the path from it.
//   //  path.clear();
//   // //
//   List<List<List<int>>> res=[];
//   await optimizeDiagonalEntry(building,path,numCols,floor,Bid,nonWalkableCells).then((value){
//     res=value;
//   });
//   //print(res);
//
//   //print("turns array before optimization");
//   for(int i=0;i<tu.length;i++){
//     int x=tu[i] % numCols;
//     int y = tu[i] ~/ numCols;
//     //print("${x}-----${y}");
//   }
//
//
//   //removing prev turn points with new turn points.
//   if(res.isNotEmpty){
//     for(int i=0;i<res.length;i++)
//     {
//       int oldIndexAtTurn1=res[i][2][0]+res[i][2][1]*numCols;
//       int oldIndexAtTurn2=res[i][3][0]+res[i][3][1]*numCols;
//
//       //print(oldIndexAtTurn1);
//       //print(oldIndexAtTurn2);
//       int oldArrayIndexAtTurn1=tu.indexOf(oldIndexAtTurn1);
//       int oldArrayIndexAtTurn2=tu.indexOf(oldIndexAtTurn2);
//
//       //turns array updated
//       tu[oldArrayIndexAtTurn1]=res[i][0][0]+res[i][0][1]*numCols;
//       tu[oldArrayIndexAtTurn2]=res[i][1][0]+res[i][1][1]*numCols;
//       //print(res[i][0][0]+res[i][0][1]*numCols);
//       //print(res[i][1][0]+res[i][1][1]*numCols);
//
//
//     }
//
//     // for(int i=0;i<tu.length;i++){
//     //   if(tu.contains(tu[i]+1)){
//     //
//     //     tu.removeAt(2);
//     //     tu.removeAt(3);
//     //     tu.removeAt(4);
//     //
//     //   }
//     // }
//   }
//
//   //print("turns array after optimization");
//   for(int i=0;i<tu.length-1;i++){
//     int x1=tu[i] % numCols;
//     int y1 = tu[i] ~/ numCols;
//     int x2=tu[i+1] % numCols;
//     int y2 = tu[i+1] ~/ numCols;
//
//
//     if(x1+1==x2 || x1-1==x2){
//       int oldindex=x2+y2*numCols;
//       x2=x2-1;
//       int index=x2+y2*numCols;
//      int oldInd= tu.indexOf(oldindex);
//      tu[oldInd]=index;
//     }
//     if(y1+1==y2 || y1-1==y2){
//       int oldindex=x2+y2*numCols;
//       y2=y2-1;
//       int index=x2+y2*numCols;
//       int oldInd= tu.indexOf(oldindex);
//       tu[oldInd]=index;
//     }
//   }
//
//
//   path = tools.generateCompletePath(tu, numCols, nonWalkableCells);
//
//
//
//
// // Future.delayed(Duration(milliseconds: 2000));
//
//   return path;
// }



List<int> getFinalOptimizedPath(List<int> path, List<int> nonWalkableCells,
    int numCols, int sourceX, int sourceY, int destinationX, int destinationY) {

  List<List<int>> getPoints = [];
  Map<int, int> getTurns = tools.getTurnMap(path, numCols);


  path = getOptiPath(getTurns, numCols, path);


  List<int> turns = tools.getTurnpoints(path, numCols);


  for (int i = 0; i < turns.length; i++) {
    int x = turns[i] % numCols;
    int y = turns[i] ~/ numCols;

    getPoints.add([x, y]);
  }
//optimizing turnsss
  for (int i = 0; i < getPoints.length - 1; i++) {
    if (getPoints[i][0] != getPoints[i + 1][0] &&
        getPoints[i][1] != getPoints[i + 1][1]) {
      int dist =
      tools.calculateDistance(getPoints[i], getPoints[i + 1]).toInt();
      if (dist <= 15) {

        //points of prev turn
        int index1 = getPoints[i][0] + getPoints[i][1] * numCols;
        int ind1 = path.indexOf(index1);

        int prev = path[ind1 - 1];

        int currX = index1 % numCols;
        int currY = index1 ~/ numCols;

        int prevX = prev % numCols;
        int prevY = prev ~/ numCols;


        //straight line eqautaion1
        //y-prevY=(currY-prevY)/(currX-prevX)*(x-prevX);

        //points of next turn;
        int index2 = getPoints[i + 1][0] + getPoints[i + 1][1] * numCols;
        int ind2 = path.indexOf(index2);
        int next = path[ind2 + 1];

        int nextX = index2 % numCols;
        int nextY = index2 ~/ numCols;

        int nextNextX = next % numCols;
        int nextNextY = next ~/ numCols;


        int ind3 = path.indexOf(index1 - 1);

        List<int> intersectPoints = getIntersectionPoints(
            currX, currY, prevX, prevY, nextX, nextY, nextNextX, nextNextY);

        if (intersectPoints.isNotEmpty) {
          //non walkabkle check

          //first along the x plane

          //intersecting points
          int x1 = intersectPoints[0];
          int y1 = intersectPoints[1];

          //next point
          int x2 = nextX;
          int y2 = nextY;

          bool isNonWalkablePoint = false;

          while (x1 <= x2) {
            int pointIndex = x1 + y1 * numCols;
            if (nonWalkableCells.contains(pointIndex)) {
              isNonWalkablePoint = true;
              break;
            }
            x1 = x1 + 1;
          }

          //along the y-axis

          //next point
          int x3 = currX;
          int y3 = currY;

          while (y1 >= y3) {
            int pointIndex = x3 + y1 * numCols;
            if (nonWalkableCells.contains(pointIndex)) {
              isNonWalkablePoint = true;
              break;
            }
            y1 = y1 - 1;
          }

          if (isNonWalkablePoint == false) {
            path.removeRange(ind1, ind2);

            int newIndex = intersectPoints[0] + intersectPoints[1] * numCols;


            path[ind1] = newIndex;

            getPoints[i] = [intersectPoints[0], intersectPoints[1]];

            getPoints.removeAt(i + 1);
          }
        }


        print("${ind1}  ${ind2}  ${ind3}");

        //path=getOptiPath(getTurns, numCols, path);
      }
    }
  }
  List<int> tu = [];
  tu.add(sourceX + sourceY * numCols);
  tu.addAll(tools.getTurnpoints(path, numCols));
  tu.add(destinationX + destinationY * numCols);

  //creating a new array and gearting the path from it.
  //  path.clear();
  // //
  path = tools.generateCompletePath(tu, numCols,nonWalkableCells);






  return path;
}




// List<int> findIntersection(List<int> p1, List<int> p2, List<int> p3, double m) {
//   // Slope of the line passing through P3
//   double m_prime = -1 / m; // assuming the perpendicular slope
//
//   // y-intercepts of the lines passing through P1 and P2
//   double b1 = p1[1] - m * p1[0];
//   double b2 = p2[1] - m * p2[0];
//   double c = p3[1] - m_prime * p3[0];
//
//   // Intersection with the line through P1
//   double x1_prime = (b1 - c) / (m_prime - m);
//   double y1_prime = m * x1_prime + b1;
//
//   // Intersection with the line through P2
//   double x2_prime = (b2 - c) / (m_prime - m);
//   double y2_prime = m * x2_prime + b2;
//
//   return [x1_prime.toInt(), y1_prime.toInt()];
// }

List<List<int>> findIntersection(List<int> p1, List<int> p2, List<int> p3,List<int> p11,List<int> p22,List<int> nonWalkableCells,int numCols) {
 double m1=(p11[1]-p1[1])/(p11[0]-p1[0]);
 double m2=(p22[1]-p2[1])/(p22[0]-p2[0]);
//print("m1----m2");
if(m1.isInfinite || m1.isNaN){
  m1=p1[0]+0.0;
}
 if(m2.isInfinite || m2.isNaN){
   m2=p2[0]+0.0;
 }
//print(m1);
//print(m2);
 //eq of parallel lines
 double node1=(m1);
 double node2=(m2);

 //checking vertical and horizontal condition


 List<List<int>> intersections =[
   [node1.toInt(), p3[1]],
   [node2.toInt(), p3[1]]];

 int index1=intersections[0][0]+intersections[0][1]*numCols;
 int index2=intersections[1][0]+intersections[1][1]*numCols;
 //print(index1);
 //print(index2);
 if(nonWalkableCells.contains(index1)|| nonWalkableCells.contains(index2)){
   node1=p1[1]+0.0;
   node2=p2[1]+0.0;
   intersections=[[p3[0], node1.toInt()],
     [p3[0],node2.toInt()],[p1[0],p1[1]],[p2[0],p2[1]]];
 }else{
   intersections=[
     [node1.toInt(), p3[1]],
     [node2.toInt(), p3[1]],
     [p1[0],p1[1]],[p2[0],p2[1]]
   ];
 }
 //noww new points areeee

  return intersections;
}

List<List<List<int>>> findDoorAndPathTurnCoords(
    List<Landmarks> nearbyPathLandmarks, List<int> path, int numCols) {
  List<List<List<int>>> res = [];
  // List<int> turns= tools.getTurnpoints(path, numCols);
  // //print("turns pointsss");
  // //print(turns);
  List<int> turns = tools.getTurnpoints(path, numCols);
  for (int i = 0; i < nearbyPathLandmarks.length; i++) {
    List<List<int>> temp1 = [];
    //print("dorrr cordsss");
    //print(
    //     "${nearbyPathLandmarks[i].coordinateX}-----${nearbyPathLandmarks[i].coordinateY}");

    for (int j = 0; j < turns.length - 1; j++) {
      int x1 = (turns[j] % numCols);
      int y1 = (turns[j] ~/ numCols);
      //now a path point before this turn
      int ind1 = path.indexOf(x1 + y1 * numCols);
      int index1 = path[ind1 - 1];

      int x11 = (index1 % numCols);
      int y11 = (index1 ~/ numCols);

      int x2 = (turns[j + 1] % numCols);
      int y2 = (turns[j + 1] ~/ numCols);

      //now a path point before this turn
      int ind2 = path.indexOf(x2 + y2 * numCols);
      int index2 = path[ind2 + 1];

      int x22 = (index2 % numCols);
      int y22 = (index2 ~/ numCols);

      bool iswithinRange = isWithinRange([
        nearbyPathLandmarks[i].coordinateX!,
        nearbyPathLandmarks[i].coordinateY!
      ], [
        x1,
        y1
      ], [
        x2,
        y2
      ], 10);
      if (iswithinRange && (x1!=x2 && y1!=y2)) {
        //print("turnn pointsss");
        //print("${x1}---${y1}");
        //print("${x2}---${y2}");
        //print(
        //     "${nearbyPathLandmarks[i].coordinateX!}--${nearbyPathLandmarks[i].coordinateY!}");
        temp1.add([
          nearbyPathLandmarks[i].coordinateX!,
          nearbyPathLandmarks[i].coordinateY!
        ]);
        temp1.add([x1, y1]);
        temp1.add([x2, y2]);
        temp1.add([x11, y11]);
        temp1.add([x22, y22]);

        res.add(temp1);
        break;
      }
    }
  }
  return res;
}

// Function to calculate the distance between two points
double calculateDistance(List<int> p1, List<int> p2) {
  return sqrt(pow((p2[0] - p1[0]), 2) + pow((p2[1] - p1[1]), 2));
}

// Function to check if a point (x, y) is within range of P1 or P2
bool isWithinRange(List<int> target, List<int> p1, List<int> p2, double range) {
  double distanceToP1 = calculateDistance(target, p1);
  double distanceToP2 = calculateDistance(target, p2);
  return distanceToP1 <= range && distanceToP2 <= range;
}

List<Cell> findCorridorSegments(
    List<int> path, List<int> nonWalkable, int numCols,String? bid, int floor) {
  List<Cell> single = [];
  List<int> turnPoints = tools.getTurnpoints(path, numCols);
  for (int i = 0; i < path.length; i++) {
    int pos = path[i];
    int row = pos % numCols;
    int col = pos ~/ numCols;

    int nextrow = row;
    int nextcol = col;

    List<double> v = tools.localtoglobal(row, col);
    double lat = v[0];
    double lng = v[1];
    if (i + 1 < path.length) {
      nextrow = path[i + 1] % numCols;
      nextcol = path[i + 1] ~/ numCols;
    }

    bool northCollision =
    checkDirection(nonWalkable, row, col, numCols, -1, 0, 8);
    bool southCollision =
    checkDirection(nonWalkable, row, col, numCols, 1, 0, 8);
    bool eastCollision =
    checkDirection(nonWalkable, row, col, numCols, 0, 1, 8);
    bool westCollision =
    checkDirection(nonWalkable, row, col, numCols, 0, -1, 8);

    int collisionCount = (northCollision ? 1 : 0) +
        (southCollision ? 1 : 0) +
        (eastCollision ? 1 : 0) +
        (westCollision ? 1 : 0);

    // Check if any two opposite directions collide with non-walkable cells
    if (i == 0) {
      //print("$pos with first cell");
      single.add(Cell(pos, row, col, tools.eightcelltransition, lat, lng,bid,floor));
    } else if (nextrow != row && nextcol != col) {
      //print("$pos with first eight");
      single.add(Cell(pos, row, col, tools.eightcelltransitionforTurns, lat, lng,bid,floor,ttsEnabled: false));
    } else if (turnPoints.contains(pos)) {
      //print("$pos with first eight");
      single.add(Cell(pos, row, col, tools.eightcelltransitionforTurns, lat, lng,bid,floor,ttsEnabled: false));
    } else if ((northCollision && southCollision)) {
      print("$pos with twoverticle");
      if(nextcol>col){
        single
            .add(Cell(pos, row, col, tools.twocelltransitionvertical, lat, lng,bid,floor));
      }else if(nextcol<col){
        single
            .add(Cell(pos, row, col, tools.twocelltransitionvertical, lat, lng,bid,floor));
      }else{
        single
            .add(Cell(pos, row, col, tools.twocelltransitionvertical, lat, lng,bid,floor));
      }

    } else if ((eastCollision && westCollision)) {
      print("$pos with twohorizontal");
      if(nextrow>row){
        single.add(
            Cell(pos, row, col, tools.twocelltransitionhorizontal, lat, lng,bid,floor));
      }else if(nextrow<row){
        single.add(
            Cell(pos, row, col, tools.twocelltransitionhorizontal, lat, lng,bid,floor));
      }else{
        single.add(
            Cell(pos, row, col, tools.twocelltransitionhorizontal, lat, lng,bid,floor));
      }

    } else if (collisionCount == 1) {
      //print("$pos with four");
      single.add(Cell(pos, row, col, tools.fourcelltransition, lat, lng,bid,floor));
    } else if ((!northCollision && !southCollision) &&
        (!eastCollision && !westCollision)) {
      //print("$pos with four");
      single.add(Cell(pos, row, col, tools.fourcelltransition, lat, lng,bid,floor));
    } else {
      //print("$pos with second eight");
      single.add(Cell(pos, row, col, tools.eightcelltransition, lat, lng,bid,floor));
    }
  }

  return single;
}


bool checkDirection(List<int> nonWalkable, int row, int col, int width,
    int rowInc, int colInc, int depth) {
  for (int i = 1; i <= depth; i++) {
    int newRow = row + i * rowInc;
    int newCol = col + i * colInc;
    if (newRow >= 0 && newCol >= 0) {
      int newIndex = newCol * width + newRow;
      if (row == 60 && col == 111) {
        //print("checking for [$newRow,$newCol]");
      }
      if (nonWalkable.contains(newIndex)) {
        return true;
      }
    }
  }
  return false;
}
