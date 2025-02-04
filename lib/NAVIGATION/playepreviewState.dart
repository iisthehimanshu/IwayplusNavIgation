class PlayePreviewState {
  final String buildingId;
  final Map<int, List<int>> pathByFloor; // Floor ID → Path nodes
  final Map<int, int> colsByFloor; // Floor ID → Column count
  final Map<int, List<String>> polylineIdsByFloor; // Floor ID → Polyline IDs
  int currentFloor;
  PlayePreviewState({
    required this.buildingId,
    required this.pathByFloor,
    required this.colsByFloor,
    required this.polylineIdsByFloor,
    required this.currentFloor,
  });
  // CopyWith for updates
  PlayePreviewState copyWith({
    String? buildingId,
    Map<int, List<int>>? pathByFloor,
    Map<int, int>? colsByFloor,
    Map<int, List<String>>? polylineIdsByFloor,
    int? currentFloor,
  }) {
    return PlayePreviewState(
      buildingId: buildingId ?? this.buildingId,
      pathByFloor: pathByFloor ?? this.pathByFloor,
      colsByFloor: colsByFloor ?? this.colsByFloor,
      polylineIdsByFloor: polylineIdsByFloor ?? this.polylineIdsByFloor,
      currentFloor: currentFloor ?? this.currentFloor,
    );
  }
}
