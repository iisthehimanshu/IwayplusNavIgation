class MappingElement {
  final String id;
  final String buildingID;
  final Geometry geometry;
  final String type;
  final String createdBy;
  final String? updatedBy;

  MappingElement({
    required this.id,
    required this.buildingID,
    required this.geometry,
    required this.type,
    required this.createdBy,
    this.updatedBy,
  });

  factory MappingElement.fromJson(Map<String, dynamic> json) {
    return MappingElement(
      id: json['id'],
      buildingID: json['building_ID'],
      geometry: Geometry.fromJson(json['geometry']),
      type: json['type'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_ID': buildingID,
      'geometry': geometry.toJson(),
      'type': type,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }
}

class Geometry {
  final List<dynamic> coordinates;
  final String type;
  final List<dynamic>? coordinatesLocal;

  Geometry({
    required this.coordinates,
    required this.type,
    this.coordinatesLocal,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      coordinates: json['coordinates'],
      type: json['type'],
      coordinatesLocal: json['coordinnatesLocal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'type': type,
      'coordinnatesLocal': coordinatesLocal,
    };
  }
}

class PathNetwork {
  final Map<String, dynamic> pathNetwork;
  final Map<String, dynamic> pathNetworkLocal;

  PathNetwork({
    required this.pathNetwork,
    required this.pathNetworkLocal,
  });

  factory PathNetwork.fromJson(Map<String, dynamic> json) {
    return PathNetwork(
      pathNetwork: Map<String, dynamic>.from(json['pathNetwork']),
      pathNetworkLocal: Map<String, dynamic>.from(json['pathNetworkLocal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pathNetwork': pathNetwork,
      'pathNetworkLocal': pathNetworkLocal,
    };
  }
}

class MainModel {
  final List<dynamic> mappingElements;
  final PathNetwork pathNetwork;

  MainModel({
    required this.mappingElements,
    required this.pathNetwork,
  });

  factory MainModel.fromJson(Map<String, dynamic> json) {
    return MainModel(
      mappingElements: (json['mappingElements'] as List<dynamic>)
          .map((e) => MappingElement.fromJson(e))
          .toList(),
      pathNetwork: PathNetwork.fromJson({
        'pathNetwork': json['pathNetwork'],
        'pathNetworkLocal': json['pathNetworkLocal'],
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mappingElements': mappingElements.map((e) => e.toJson()).toList(),
      'pathNetwork': pathNetwork.toJson(),
    };
  }
}
