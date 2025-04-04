class MappingElement {
  final String? id;
  final String? sId;
  final String? buildingID;
  final Geometry? geometry;
  final Properties? properties;
  final List<dynamic>? associatedPolygons;
  final List<dynamic>? associatedPoints;
  final String? type;
  final String? createdBy;
  final String? updatedBy;

  MappingElement({
    required this.id,
    required this.sId,
    required this.buildingID,
    required this.geometry,
    required this.properties,
    required this.associatedPolygons,
    required this.associatedPoints,
    required this.type,
    required this.createdBy,
    this.updatedBy,
  });

  factory MappingElement.fromJson(Map<dynamic, dynamic> json) {
    if(json['id'] == "866bc2c6b0f89ed5c3ecce2f38e317c0"){
      print(json);
    }
    return MappingElement(
      id: json['id'],
      sId: json['_id'],
      buildingID: json['building_ID'],
      geometry: json['geometry'] != null?Geometry.fromJson(json['geometry']):json['geometry'],
      properties: json['properties'] != null?Properties.fromJson(json['properties']):json['properties'],
      associatedPoints: json['associatedPoints'],
      associatedPolygons: json['associatedPolygons'],
      type: json['type'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'id': id,
      'building_ID': buildingID,
      'geometry': geometry?.toJson(),
      'properties': properties?.toJson(),
      'associatedPoints': associatedPoints,
      'associatedPolygons': associatedPolygons,
      'type': type,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}

class Properties {
  String? name;
  String? fillOpacity;
  String? height;
  int? level;
  String? fillColor;
  String? strokeColor;
  String? strokeOpacity;

  Properties(
      {this.name,
        this.fillOpacity,
        this.height,
        this.level,
        this.fillColor,
        this.strokeColor,
        this.strokeOpacity});

  Properties.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    fillOpacity = json['fillOpacity'];
    height = json['height'];
    level = json['level'];
    fillColor = json['fillColor'];
    strokeColor = json['strokeColor'];
    strokeOpacity = json['strokeOpacity'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fillOpacity'] = this.fillOpacity;
    data['height'] = this.height;
    data['level'] = this.level;
    data['fillColor'] = this.fillColor;
    data['strokeColor'] = this.strokeColor;
    data['strokeOpacity'] = this.strokeOpacity;
    return data;
  }
}


class Geometry {
  final List<dynamic>? coordinates;
  final String? type;
  final List<dynamic>? coordinatesLocal;

  Geometry({
    required this.coordinates,
    required this.type,
    this.coordinatesLocal,
  });

  factory Geometry.fromJson(Map<dynamic, dynamic> json) {
    return Geometry(
      coordinates: json['coordinates'],
      type: json['type'],
      coordinatesLocal: json['coordinnatesLocal'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'type': type,
      'coordinnatesLocal': coordinatesLocal,
    };
  }
}

class PathNetwork {
  final Map<String, List<dynamic>>? pathNetworkGlobal;
  final Map<String, List<dynamic>>? pathNetwork;
  final Map<String, List<dynamic>>? masterGraph;

  PathNetwork({
    required this.pathNetworkGlobal,
    required this.pathNetwork,
    required this.masterGraph,
  });

  factory PathNetwork.fromJson(Map<dynamic, dynamic> json) {
    return PathNetwork(
      pathNetworkGlobal: Map<String, List<dynamic>>.from(
        json['pathNetworkGlobal']??{}.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      pathNetwork: Map<String, List<dynamic>>.from(
        json['pathNetwork']??{}.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      masterGraph: Map<String, List<dynamic>>.from(
        json['masterGraph']??{}.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'pathNetworkGlobal': pathNetworkGlobal,
      'pathNetwork': pathNetwork,
      'masterGraph': masterGraph,
    };
  }
}

class EntriesNetwork {
  final String id;
  final String campusId;
  final Map<String, List<Entry>> entries;

  EntriesNetwork({
    required this.id,
    required this.campusId,
    required this.entries,
  });

  factory EntriesNetwork.fromJson(Map<dynamic, dynamic> json) {
    return EntriesNetwork(
      id: json['_id'],
      campusId: json['campusId'],
      entries: (json['entriesNetwork'] as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(
          key,
          (value as List).map((e) => Entry.fromJson(e)).toList(),
        ),
      ),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      '_id': id,
      'campusId': campusId,
      'entriesNetwork': entries.map(
            (key, value) => MapEntry(
          key,
          value.map((e) => e.toJson()).toList(),
        ),
      ),
    };
  }
}

class Entry {
  final String entryId;
  final double distance;
  final int height;
  final List<PathPoint> path;

  Entry({
    required this.entryId,
    required this.distance,
    required this.height,
    required this.path,
  });

  factory Entry.fromJson(Map<dynamic, dynamic> json) {
    return Entry(
      entryId: json['entryId'],
      distance: double.parse(json['distance']),
      height: json['height'],
      path: (json['path'] as List).map((e) => PathPoint.fromJson(e)).toList(),
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'entryId': entryId,
      'distance': distance.toString(),
      'height': height,
      'path': path.map((e) => e.toJson()).toList(),
    };
  }
}

class PathPoint {
  final List<int> localCoords;
  final String buildingId;
  final int floor;

  PathPoint({
    required this.localCoords,
    required this.buildingId,
    required this.floor,
  });

  factory PathPoint.fromJson(Map<dynamic, dynamic> json) {
    return PathPoint(
      localCoords: List<int>.from(json['localCoords']),
      buildingId: json['building_ID'],
      floor: json['floor'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'localCoords': localCoords,
      'building_ID': buildingId,
      'floor': floor,
    };
  }
}

class GlobalModel {
  final List<MappingElement>? mappingElements;
  final PathNetwork? pathNetwork;
  final String? buildingName;
  final String? venueName;
  final EntriesNetwork? entriesNetwork;


  GlobalModel({
    required this.mappingElements,
    required this.pathNetwork,
    required this.buildingName,
    required this.venueName,
    required this.entriesNetwork
  });

  factory GlobalModel.fromJson(Map<dynamic, dynamic> json) {
    print("got mastergraph ${json['masterGraph']}");
    return GlobalModel(
        mappingElements: (json['mappingElements'] as List<dynamic>)
            .map((e) => MappingElement.fromJson(e))
            .toList(),
        pathNetwork: PathNetwork.fromJson({
          'pathNetworkGlobal': json['pathNetworkGlobal'],
          'pathNetwork': json['pathNetwork'],
          'masterGraph': json['masterGraph'],
        }),
        buildingName: json['buildingName'],
        venueName: json['venueName'],
        entriesNetwork: json['entriesNetwork'] != null?EntriesNetwork.fromJson(json['entriesNetwork']):json['entriesNetwork']
    );
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['mappingElements'] =this.mappingElements;
    data['pathNetwork'] = this.pathNetwork;
    data['buildingName'] = this.buildingName;
    data['venueName'] = this.venueName;
    data['entriesNetwork'] =  this.entriesNetwork;
    return data;
  }
}
