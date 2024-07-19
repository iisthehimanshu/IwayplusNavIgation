class OutBuildingModel {
  final List<List<double>> path;
  final double distanceMeter;
  final String pathId;

  OutBuildingModel({
    required this.path,
    required this.distanceMeter,
    required this.pathId,
  });

  // Factory method to create a PathModel from a JSON map
  factory OutBuildingModel.fromJson(Map<String, dynamic> json) {
    List<List<double>> path = (json['path'] as List)
        .map((e) => (e as List).map((item) => double.parse(item)).toList())
        .toList();

    return OutBuildingModel(
      path: path,
      distanceMeter: double.parse(json['distanceMeter']),
      pathId: json['pathId'],
    );
  }

  // Method to convert a PathModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'path': path.map((e) => e.map((item) => item.toString()).toList()).toList(),
      'distanceMeter': distanceMeter.toString(),
      'pathId': pathId,
    };
  }
}