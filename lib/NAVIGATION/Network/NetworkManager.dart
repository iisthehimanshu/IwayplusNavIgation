import 'APIManager.dart';
import 'WebsocketManager.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;

  late final Apimanager api;
  late final WebSocketManager ws;

  NetworkManager._internal() {
    api = Apimanager();
    ws = WebSocketManager();
  }
}
