import 'dart:async';

class EventManager {
  // Singleton setup
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();

  final Map<String, StreamController<dynamic>> _controllers = {};

  // Listen to an event
  Stream<T> on<T>(String eventName) {
    _controllers.putIfAbsent(eventName, () => StreamController<T>.broadcast());
    return _controllers[eventName]!.stream as Stream<T>;
  }

  // Emit an event
  void emit(String eventName, dynamic data) {
    if (_controllers.containsKey(eventName)) {
      _controllers[eventName]!.add(data);
    }
  }

  // Dispose all controllers
  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
