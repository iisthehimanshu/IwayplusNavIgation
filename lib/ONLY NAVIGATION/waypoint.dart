class PathModel {
  final String id;
  final String buildingID;
  final int floor;
  final Map<String, List<dynamic>> pathNetwork;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  PathModel({
    required this.id,
    required this.buildingID,
    required this.floor,
    required this.pathNetwork,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory PathModel.fromJson(Map<dynamic, dynamic> json) {
    return PathModel(
      id: json['_id'],
      buildingID: json['building_ID'],
      floor: json['floor'],
      pathNetwork: Map<String, List<dynamic>>.from(
        json['pathNetwork']??{}.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}

class PathLine {
  final List<List<int>> points;

  PathLine({required this.points});

  factory PathLine.fromJson(List<dynamic> json) {
    List<List<int>> points = [];
    for (var point in json) {
      points.add(List<int>.from(point));
    }
    return PathLine(points: points);
  }

  List<dynamic> toJson() {
    return points.map((point) => point.map((p) => p).toList()).toList();
  }
}

class PathNetwork {
  final Map<String, List<String>> network;

  PathNetwork({required this.network});

  factory PathNetwork.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> network = {};
    json.forEach((key, value) {
      network[key] = List<String>.from(value);
    });
    return PathNetwork(network: network);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    network.forEach((key, value) {
      json[key] = value.map((v) => v).toList();
    });
    return json;
  }
}

class BuildingPath {
  final String id;
  final String buildingId;
  final int floor;
  final List<PathLine> pathLines;
  final PathNetwork pathNetwork;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  BuildingPath({
    required this.id,
    required this.buildingId,
    required this.floor,
    required this.pathLines,
    required this.pathNetwork,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory BuildingPath.fromJson(Map<String, dynamic> json) {
    var pathLinesJson = json['pathLines'] as List;
    List<PathLine> pathLines = pathLinesJson.map((e) => PathLine.fromJson(e)).toList();

    return BuildingPath(
      id: json['_id'],
      buildingId: json['building_ID'],
      floor: json['floor'],
      pathLines: pathLines,
      pathNetwork: PathNetwork.fromJson(json['pathNetwork']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'building_ID': buildingId,
      'floor': floor,
      'pathLines': pathLines.map((line) => line.toJson()).toList(),
      'pathNetwork': pathNetwork.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}
