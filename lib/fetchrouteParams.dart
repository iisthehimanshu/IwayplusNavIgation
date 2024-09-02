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
}