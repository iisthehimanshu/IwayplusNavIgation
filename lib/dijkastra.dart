// Function to calculate Euclidean distance between two points
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:iwaymaps/path.dart';

import 'navigationTools.dart';

// Function to calculate Euclidean distance between two points
double euclideanDistance(String point1, String point2) {
  var p1 = point1.split(',').map((e) => double.parse(e)).toList();
  var p2 = point2.split(',').map((e) => double.parse(e)).toList();
  return sqrt(pow((p2[0] - p1[0]), 2) + pow((p2[1] - p1[1]), 2));
}

// Dijkstra's algorithm to find the shortest path
Future<List<List<int>>> dijkstra(Map<String, List<dynamic>> graph, String start, String goal, int col, {bool isoutdoorPath = false})async{




  var distances = <String, double>{};
  var previous = <String, String>{};
  var unvisited = PriorityQueue<MapEntry<String, double>>((a, b) => a.value.compareTo(b.value));

  for (var node in graph.keys) {
    distances[node] = double.infinity;
  }
  distances[start] = 0;

  unvisited.add(MapEntry(start, 0));

  while (unvisited.isNotEmpty) {
    var currentNode = unvisited.removeFirst().key;

    if (currentNode == goal) {
      var path = <List<int>>[];
      while (previous.containsKey(currentNode)) {
        path.add(currentNode.split(',').map(int.parse).toList());
        currentNode = previous[currentNode]!;
      }
      path.add(currentNode.split(',').map(int.parse).toList()); // Add the start node
      // if(isoutdoorPath){
        //return path.reversed.toList();
      // }
      if(isoutdoorPath){
        return path.reversed.toList();
      }
      return addCoordinatesBetweenVertices(path.reversed.toList(), col);
    }

    if (graph.containsKey(currentNode)) {
      for (var neighbor in graph[currentNode]!) {
        var newDist = distances[currentNode]! + euclideanDistance(currentNode, neighbor);

        if (newDist < distances[neighbor]!) {
          distances[neighbor] = newDist;
          previous[neighbor] = currentNode;
          unvisited.add(MapEntry(neighbor, newDist));
        }
      }
    }
  }

  return []; // Return an empty list if there's no path
}

List<List<int>> addCoordinatesBetweenVertices(List<List<int>> coordinates, int col) {
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

List<String> findNearestAndSecondNearestVertices(
    Map<String, List<dynamic>> pathNetwork,
    List<int> coord1,
    List<int> coord2) {
  String nearestToCoord1 = '';
  String secondNearestToCoord1 = '';
  String nearestToCoord2 = '';
  String secondNearestToCoord2 = '';
  double minDistToCoord1 = double.infinity;
  double secondMinDistToCoord1 = double.infinity;
  double minDistToCoord2 = double.infinity;
  double secondMinDistToCoord2 = double.infinity;

  // Iterate through each vertex in the pathNetwork
  pathNetwork.forEach((vertex, neighbors) {
    List<int> v = vertex.split(',').map((e) => int.parse(e)).toList();

    // Calculate distances from coord1 and coord2 to vertex v
    double distToCoord1 = sqrt(pow(v[0] - coord1[0], 2) + pow(v[1] - coord1[1], 2));
    double distToCoord2 = sqrt(pow(v[0] - coord2[0], 2) + pow(v[1] - coord2[1], 2));

    // Update nearest and second nearest vertices for coord1
    if (distToCoord1 < minDistToCoord1) {
      secondMinDistToCoord1 = minDistToCoord1;
      secondNearestToCoord1 = nearestToCoord1;
      minDistToCoord1 = distToCoord1;
      nearestToCoord1 = vertex;
    } else if (distToCoord1 < secondMinDistToCoord1) {
      secondMinDistToCoord1 = distToCoord1;
      secondNearestToCoord1 = vertex;
    }

    // Update nearest and second nearest vertices for coord2
    if (distToCoord2 < minDistToCoord2) {
      secondMinDistToCoord2 = minDistToCoord2;
      secondNearestToCoord2 = nearestToCoord2;
      minDistToCoord2 = distToCoord2;
      nearestToCoord2 = vertex;
    } else if (distToCoord2 < secondMinDistToCoord2) {
      secondMinDistToCoord2 = distToCoord2;
      secondNearestToCoord2 = vertex;
    }
  });

  if(nearestToCoord1 == "${coord1[0]},${coord1[1]}"){
    secondNearestToCoord1 = nearestToCoord1;
  }
  if(nearestToCoord2 == "${coord2[0]},${coord2[1]}"){
    secondNearestToCoord2 = nearestToCoord2;
  }
  return [
    nearestToCoord1,
    secondNearestToCoord1,
    nearestToCoord2,
    secondNearestToCoord2
  ];
}

List<int> mergeLists(List<int> l1, List<int> l2, List<int> l3) {
  List<int> result = [];

  // Helper function to find the first intersection
  int findFirstIntersection(List<int> list1, List<int> list2) {
    for (int element in list1) {
      if (list2.contains(element)) {
        return element;
      }
    }
    return -1;
  }

  if (l1.isEmpty) {
    // If l1 is empty, merge l2 and l3
    int intersectionL2L3 = findFirstIntersection(l2, l3);

    if (intersectionL2L3 == -1) {
      // No intersection, just add all elements of l2 and l3
      result.addAll(l2);
      result.addAll(l3);
    } else {
      // Add elements of l2 till the intersection
      for (int i = 0; i < l2.length && l2[i] != intersectionL2L3; i++) {
        result.add(l2[i]);
      }
      result.add(intersectionL2L3);

      // Add elements of l3 after the intersection till the end
      int indexL2L3 = l3.indexOf(intersectionL2L3);
      for (int i = indexL2L3 + 1; i < l3.length; i++) {
        result.add(l3[i]);
      }
    }

  } else if (l3.isEmpty) {
    // If l3 is empty, merge l1 and l2
    int intersectionL1L2 = findFirstIntersection(l1, l2);

    if (intersectionL1L2 == -1) {
      // No intersection, just add all elements of l1 and l2
      result.addAll(l1);
      result.addAll(l2);
    } else {
      // Add elements of l1 till the intersection
      for (int i = 0; i < l1.length && l1[i] != intersectionL1L2; i++) {
        result.add(l1[i]);
      }
      result.add(intersectionL1L2);

      // Add elements of l2 after the intersection till the end
      int indexL1L2 = l2.indexOf(intersectionL1L2);
      for (int i = indexL1L2 + 1; i < l2.length; i++) {
        result.add(l2[i]);
      }
    }

  } else {
    // If neither l1 nor l3 is empty, perform the original merging logic
    int intersectionL1L2 = findFirstIntersection(l1, l2);

    if (intersectionL1L2 == -1) return result;

    // Add elements of l1 till the intersection
    for (int i = 0; i < l1.length && l1[i] != intersectionL1L2; i++) {
      result.add(l1[i]);
    }
    result.add(intersectionL1L2);

    // Find the first intersection of l2 and l3 after the intersection with l1
    int intersectionL2L3 = findFirstIntersection(l2.sublist(l2.indexOf(intersectionL1L2) + 1), l3);

    if (intersectionL2L3 == -1) return result;

    // Add elements of l2 after the first intersection till the next intersection
    int indexL1L2 = l2.indexOf(intersectionL1L2);
    for (int i = indexL1L2 + 1; i < l2.length && l2[i] != intersectionL2L3; i++) {
      result.add(l2[i]);
    }
    result.add(intersectionL2L3);

    // Add elements of l3 after the intersection till the end
    int indexL2L3 = l3.indexOf(intersectionL2L3);
    for (int i = indexL2L3 + 1; i < l3.length; i++) {
      result.add(l3[i]);
    }
  }

  return result;
}


Future<List<int>> findShortestPath (Map<String, List<dynamic>> graph, int sourceX, int sourceY, int destinationX, int destinationY, List<int> nonWalkableCells, int col, int row, {bool isoutdoorPath = false})async{
  List<String> states = findNearestAndSecondNearestVertices(graph, [sourceX,sourceY], [destinationX,destinationY]);
  String start1 = states[0];
  String start2 = states[1];
  String goal1 = states[2];
  String goal2 = states[3];

  List<List<int>> temppath1 = await dijkstra(graph,start1,goal1,col,isoutdoorPath: isoutdoorPath);
  List<List<int>> temppath2 = await dijkstra(graph,start2,goal2,col, isoutdoorPath: isoutdoorPath);

  List<List<int>> temppath =[];
  if(temppath1.length>temppath2.length){
    temppath = temppath2;
  }else{
    temppath = temppath1;
  }

  if(tools.calculateDistance(temppath.first, [sourceX,sourceY])==1){
    temppath.insert(0, [sourceX,sourceY]);
  }

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
  List<int>l1 = [];
  List<int>l2 = [];
  List<int>l3 = [];
  if((sourceY*col)+sourceX != (temppath[s][1]*col)+temppath[s][0] && !isoutdoorPath){
    await findPath(row, col, nonWalkableCells, ((sourceY*col) + sourceX), ((temppath[s][1]*col)+temppath[s][0])).then((value){
      //value = getFinalOptimizedPath(value, nonWalkableCells, numCols, sourceX, sourceY, destinationX, destinationY);
      // print("path inside 1  between ${((sourceY*col) + sourceX)} and ${((temppath[s][1]*col)+temppath[s][0])} is $value");
      l1 = value;
      // print("l1 $l1");
    });
  }
  for(int i = s ; i<=e; i++){
    l2.add((temppath[i][1]*col) + temppath[i][0]);
  }
  // print("l2 $l2");
  if((temppath[e][1]*col)+temppath[e][0] != (destinationY*col)+destinationX && !isoutdoorPath){

    await findPath(row, col, nonWalkableCells, ((temppath[e][1]*col)+temppath[e][0]), ((destinationY*col) + destinationX)).then((value){
      //value = getFinalOptimizedPath(value, nonWalkableCells, numCols, sourceX, sourceY, destinationX, destinationY);
      // print("path inside 2 $value");
      l3 = value;
      // print("l3 $l3");
    });


  }

  if(l1.isNotEmpty || l3.isNotEmpty){
    return getFinalOptimizedPath(mergeLists(l1, l2, l3), nonWalkableCells, col, sourceX, sourceY, destinationX, destinationY);
  }else{
    return mergeLists(l1, l2, l3);
  }

}