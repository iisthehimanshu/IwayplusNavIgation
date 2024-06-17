import 'package:collection/collection.dart';

import 'APIMODELS/polylinedata.dart';


class GridNode {
  int x, y;
  double cost;
  GridNode? parent;

  GridNode(this.x, this.y, [this.cost = double.infinity, this.parent]);

  int getIndex(int numColumns) {
    return calculateIndex(x, y, numColumns);
  }
}

int calculateIndex(int x, int y, int numColumns) {
  return y * numColumns + x;
}

List<GridNode> getNeighbors(GridNode node, int numColumns, int numRows, List<int> nonWalkable) {
  List<GridNode> neighbors = [];
  List<List<int>> directions = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ];

  for (var dir in directions) {
    int newX = node.x + dir[0];
    int newY = node.y + dir[1];
    if (newX >= 0 && newX < numColumns && newY >= 0 && newY < numRows) {
      int index = calculateIndex(newX, newY, numColumns);
      if (!nonWalkable.contains(index)) {
        neighbors.add(GridNode(newX, newY));
      }
    }
  }

  return neighbors;
}

int heuristic(int x1, int y1, int x2, int y2) {
  return (x1 - x2).abs() + (y1 - y2).abs();
}

class PriorityQueue<T> {
  final List<T> _elements = [];
  final int Function(T, T) _comparator;

  PriorityQueue(this._comparator);

  bool get isNotEmpty => _elements.isNotEmpty;

  void add(T element) {
    _elements.add(element);
    _elements.sort(_comparator);
  }

  T removeFirst() {
    if (_elements.isEmpty) {
      throw StateError('No elements');
    }
    return _elements.removeAt(0);
  }

  bool contains(T element) {
    return _elements.contains(element);
  }
}

List<GridNode> aStarPathfinding(int startX, int startY, int endX, int endY, int numColumns, int numRows, List<int> nonWalkable) {
  List<GridNode> path = [];
  Map<int, GridNode> openSet = {};
  Set<int> closedSet = {};

  GridNode startNode = GridNode(startX, startY, 0);
  GridNode endNode = GridNode(endX, endY);

  PriorityQueue<GridNode> priorityQueue = PriorityQueue((a, b) => a.cost.compareTo(b.cost));
  priorityQueue.add(startNode);
  openSet[startNode.getIndex(numColumns)] = startNode;

  while (priorityQueue.isNotEmpty) {
    GridNode? currentNode = priorityQueue.removeFirst();
    int currentIndex = currentNode.getIndex(numColumns);

    if (currentNode.x == endX && currentNode.y == endY) {
      while (currentNode != null) {
        path.insert(0, currentNode);
        currentNode = currentNode.parent;
      }
      break;
    }

    closedSet.add(currentIndex);
    openSet.remove(currentIndex);

    for (var neighbor in getNeighbors(currentNode, numColumns, numRows, nonWalkable)) {
      int neighborIndex = neighbor.getIndex(numColumns);
      if (closedSet.contains(neighborIndex)) continue;

      double tentativeGCost = currentNode.cost + 1; // assuming uniform cost for simplicity
      if (!openSet.containsKey(neighborIndex) || tentativeGCost < neighbor.cost) {
        neighbor.cost = tentativeGCost;
        neighbor.parent = currentNode;
        openSet[neighborIndex] = neighbor;

        if (!priorityQueue.contains(neighbor)) {
          neighbor.cost += heuristic(neighbor.x, neighbor.y, endX, endY);
          priorityQueue.add(neighbor);
        }
      }
    }
  }

  return path;
}

List<int> findPathWithWaypoints(int sourceX, int sourceY, int destinationX, int destinationY, List<int> nonWalkable, List<Nodes> wayPoints, int numColumns, int numRows) {
  List<int> finalPath = [];

  List<int> points = [
    sourceX,
    sourceY,
    for (var waypoint in wayPoints) waypoint.coordx!,
    for (var waypoint in wayPoints) waypoint.coordy!,
    destinationX,
    destinationY
  ];

  for (int i = 0; i < points.length - 2; i += 2) {
    List<GridNode> pathSegment = aStarPathfinding(
      points[i],
      points[i + 1],
      points[i + 2],
      points[i + 3],
      numColumns,
      numRows,
      nonWalkable,
    );

    for (var gridNode in pathSegment) {
      finalPath.add(calculateIndex(gridNode.x, gridNode.y, numColumns));
    }
  }

  return finalPath;
}