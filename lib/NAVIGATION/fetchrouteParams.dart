class fetchrouteParams {
  final int destinationX;
  final int destinationY;
  final int sourceX;
  final int sourceY;
  final int floor;
  final String? bid;
  final String? liftName;
  bool renderSource;
  bool renderDestination;

  fetchrouteParams({
    required this.sourceX,
    required this.sourceY,
    required this.destinationX,
    required this.destinationY,
    required this.floor,
    required this.bid,
    this.renderSource = true,
    this.liftName,
    this.renderDestination = true
  });

  Map<String, dynamic> toMap() {
    print({
      'sourceX': sourceX,
      'sourceY': sourceY,
      'destinationX': destinationX,
      'destinationY': destinationY,
      'floor': floor,
      'bid': bid,
      'liftName': liftName,
      'renderSource': renderSource,
      'renderDestination': renderDestination,
    });
    return {
      'sourceX': sourceX,
      'sourceY': sourceY,
      'destinationX': destinationX,
      'destinationY': destinationY,
      'floor': floor,
      'bid': bid,
      'liftName': liftName,
      'renderSource': renderSource,
      'renderDestination': renderDestination,
    };
  }

  static fetchrouteParams fromMap(Map<String, dynamic> map) {
    return fetchrouteParams(
      sourceX: map['sourceX'],
      sourceY: map['sourceY'],
      destinationX: map['destinationX'],
      destinationY: map['destinationY'],
      floor: map['floor'],
      bid: map['bid'],
      liftName: map['liftName'],
      renderSource: map['renderSource'],
      renderDestination: map['renderDestination'],
    );
  }

}