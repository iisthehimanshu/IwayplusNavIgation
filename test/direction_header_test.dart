import 'package:flutter_test/flutter_test.dart';
import 'package:iwaymaps/NAVIGATION/ELEMENTS/DirectionHeader.dart';
import 'package:iwaymaps/NAVIGATION/UserState.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

class MockUserState extends Mock implements UserState {}
class MockDirectionHeader extends Mock implements DirectionHeader {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late DirectionHeader widget;
  late DirectionHeader oldWidget;
  late MockUserState user;
  late BuildContext context;

  setUp(() {
    user = MockUserState();
    widget = DirectionHeader(user: user);
    oldWidget = DirectionHeader(user: user);
    context = MockBuildContext();
  });

  testWidgets('should not proceed if user is at source connection', (tester) async {
    when(() => user.floor).thenReturn(1);
    when(() => user.pathobj.sourceFloor).thenReturn(1);
    when(() => user.pathobj.connections).thenReturn({
      'AC-01': {1: 34}
    });
    when(() => user.bid).thenReturn('AC-01');
    when(() => user.showcoordX).thenReturn(2);
    when(() => user.showcoordY).thenReturn(1);
    when(() => UserState.cols).thenReturn(17); // so Y * cols + X = 1*17 + 2 = 19 ≠ 34

    final state = widget.createState();
    state.didUpdateWidget(oldWidget);

    // no direction update expected
    expect(widget.direction, isNull);
  });

  testWidgets('should update direction when path has remaining steps', (tester) async {
    when(() => user.path).thenReturn([Cell(...), Cell(...)]);
    when(() => user.cellPath).thenReturn([...]);
    when(() => user.pathobj.index).thenReturn(0);
    when(() => user.pathobj.numCols).thenReturn({
      'AC-01': {1: 20}
    });
    when(() => user.bid).thenReturn('AC-01');
    when(() => user.floor).thenReturn(1);
    when(() => user.theta).thenReturn(90);
    when(() => user.showcoordX).thenReturn(1);
    when(() => user.showcoordY).thenReturn(1);

    // More mocks here...

    final state = widget.createState();
    state.didUpdateWidget(oldWidget);

    // Expect direction to be updated to something other than null
    expect(widget.direction, isNotNull);
  });

  testWidgets('should handle vibration and tts when direction changes from Straight', (tester) async {
    // setup mocks where direction changes from Straight to Left or Right
    oldWidget.direction = 'Straight';
    widget.direction = 'Right';

    final state = widget.createState();
    state.didUpdateWidget(oldWidget);

    // assert that vibration and speak were triggered
    // Here, you'll have to mock static methods like `Vibration.vibrate` or `speak`
  });

  testWidgets('should handle approaching destination', (tester) async {
    // setup user such that they are 7 steps from destination
    when(() => user.pathobj.destinationX).thenReturn(5);
    when(() => user.pathobj.destinationY).thenReturn(10);
    when(() => user.pathobj.numCols).thenReturn({'AC-01': {1: 20}});
    when(() => user.path).thenReturn([...]);
    when(() => user.cellPath).thenReturn([...]);
    when(() => user.pathobj.index).thenReturn(0);
    when(() => user.bid).thenReturn('AC-01');
    when(() => user.floor).thenReturn(1);

    widget.distance = 7;

    final state = widget.createState();
    state.didUpdateWidget(oldWidget);

    // Check if speak and move were called
  });

  testWidgets('should speak approaching turn with landmark', (tester) async {
    // mock that user is 7 steps from a turn, and landmark exists for the turn
    when(() => user.pathobj.associateTurnWithLandmark).thenReturn({
      someTurnCell: Landmark(name: 'Restroom')
    });

    widget.distance = UserState.stepSize * 7;

    final state = widget.createState();
    state.didUpdateWidget(oldWidget);

    // Check speak is called with 'You are approaching ... from Restroom'
  });
}
