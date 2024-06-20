import 'dart:collection';
import 'dart:math';

import 'package:iwaymaps/navigationTools.dart';
import 'package:iwaymaps/path.dart';

import 'APIMODELS/Building.dart';

class Graph {
  Map<String, List<dynamic>> adjList;

  Graph(this.adjList);

  void addEdge(String start, String end) {
    if (adjList[start] == null) {
      adjList[start] = [];
    }
    adjList[start]!.add(end);
  }



  List<List<int>> bfs(int sourceX, int sourceY, int destinationX, int destinationY, Map<String, List<dynamic>> pathNetwork, int numRows,
      int numCols,
      List<int> nonWalkableCells){

    List<String> findNearestVertices(
        Map<String, List<dynamic>> pathNetwork,
        List<int> coord1,
        List<int> coord2,
        ) {
      String nearestToCoord1 = '';
      String nearestToCoord2 = '';
      double minDistToCoord1 = double.infinity;
      double minDistToCoord2 = double.infinity;

      // Iterate through each vertex in the pathNetwork
      pathNetwork.forEach((vertex, neighbors) {
        List<int> v = vertex.split(',').map((e) => int.parse(e)).toList();

        // Calculate distances from coord1 and coord2 to vertex v
        double distToCoord1 = sqrt(pow(v[0] - coord1[0], 2) + pow(v[1] - coord1[1], 2));
        double distToCoord2 = sqrt(pow(v[0] - coord2[0], 2) + pow(v[1] - coord2[1], 2));

        // Update nearest vertices
        if (distToCoord1 < minDistToCoord1) {
          minDistToCoord1 = distToCoord1;
          nearestToCoord1 = vertex;
        }

        if (distToCoord2 < minDistToCoord2) {
          minDistToCoord2 = distToCoord2;
          nearestToCoord2 = vertex;
        }
      });

      return [nearestToCoord1, nearestToCoord2];
    }
    List<int> tpath = [];
    List<String> states = findNearestVertices(pathNetwork, [sourceX,sourceY], [destinationX,destinationY]);
    List<int> ws = states[0].split(',').map(int.parse).toList();
    List<int> we = states[1].split(',').map(int.parse).toList();

    String start = states[0];
    String goal = states[1];


    Queue<String> queue = Queue();
    Map<String, String?> cameFrom = {};

    queue.add(start);
    cameFrom[start] = null;

    while (queue.isNotEmpty) {
      var current = queue.removeFirst();

      if (current == goal) {
        break;
      }

      for (var neighbor in adjList[current] ?? []) {
        if (!cameFrom.containsKey(neighbor)) {
          queue.add(neighbor);
          cameFrom[neighbor] = current;
        }
      }
    }
    List<List<int>> temppath = addCoordinatesBetweenVertices(reconstructPath(cameFrom, start, goal));
    int s = 0;
    int e = temppath.length -1;
    double d1 = 10000000;
    double d2 = 10000000;
    for(int i = 0 ; i< temppath.length ; i++){
      if(tools.calculateDistance(temppath[i], [sourceX,sourceY])<d1){
        d1 = tools.calculateDistance(temppath[i], [sourceX,sourceY]);
        s = i;
      }
      if(tools.calculateDistance(temppath[i], [destinationX,destinationY])<d2){
        d2 = tools.calculateDistance(temppath[i], [destinationX,destinationY]);
        e = i;
      }
    }
    // findPath(numRows, numCols, nonWalkableCells, ((sourceY*numCols) + sourceX), ((temppath[s][0]*numCols)+temppath[s][1])).then((value){
    //   tpath.addAll(value);
    // });
    for(int i = s ; i<=e; i++){
      tpath.add((temppath[i][1]*numCols) + temppath[i][0]);
    }
    // findPath(numRows, numCols, nonWalkableCells, ((temppath[e][0]*numCols)+temppath[e][1]), ((destinationY*numCols) + destinationX)).then((value){
    //   tpath.addAll(value);
    // });
    return temppath.sublist(s,e+1);

  }

  List<List<int>> reconstructPath(Map<String, String?> cameFrom, String start, String goal) {
    List<List<int>> path = [];

    if (!cameFrom.containsKey(goal)) {
      return path; // no path found
    }

    for (String? at = goal; at != null; at = cameFrom[at]) {
      var coordinates = at.split(',').map((coord) => int.parse(coord)).toList();
      path.add(coordinates);
    }
    path = path.reversed.toList();

    if (path[0].join(',') == start) {
      return path;
    }
    return []; // no path found
  }

  List<int> toindex (List<List<int>> path,int numcols){
    List<int> indexpath = [];
    path.forEach((element) {
      indexpath.add((element[1]*numcols )+ element[0]);
    });
    return indexpath;
  }

  List<List<int>> addCoordinatesBetweenVertices(List<List<int>> coordinates) {
    var newCoordinates = <List<int>>[];

    for (var i = 0; i < coordinates.length - 1; i++) {
      var startX = coordinates[i][0];
      var startY = coordinates[i][1];
      var endX = coordinates[i + 1][0];
      var endY = coordinates[i + 1][1];

      // Determine the direction of increment for x and y
      var signX = startX < endX ? 1 : -1;
      var signY = startY < endY ? 1 : -1;

      // Add the starting point
      if(newCoordinates.isNotEmpty && newCoordinates.last[0] != startX && newCoordinates.last[1] != startY){
        newCoordinates.add([startX, startY]);
      }

      // Add intermediate points
      var x = startX;
      var y = startY;
      while (x != endX || y != endY) {
        if (x != endX) {
          x += signX;
        }
        if (y != endY) {
          y += signY;
        }
        newCoordinates.add([x, y]);
      }
    }

    // Add the last coordinate
    newCoordinates.add([coordinates.last[0], coordinates.last[1]]);

    return newCoordinates;
  }


}