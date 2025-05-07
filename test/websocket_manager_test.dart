import 'package:iwaymaps/NAVIGATION/Network/WebsocketManager.dart';
import 'package:test/test.dart';

void main() {
  group('WebSocketManager', () {
    late WebSocketManager manager;

    setUp(() {
      manager = WebSocketManager();
    });

    test('Initial userId is empty', () {
      expect(manager.currentMessage['userId'], '');
    });

    test('Update userId', () {
      manager.updateUserId('test_user');
      expect(manager.currentMessage['userId'], 'test_user');
    });

    test('Update sensor status', () {
      manager.updateSensorStatus(ble: true, compass: true);
      final sensors = manager.currentMessage['deviceInfo']['sensors'];
      expect(sensors['BLE'], true);
      expect(sensors['compass'], true);
    });

    test('Update permissions', () {
      manager.updatePermissions(location: true);
      final permissions = manager.currentMessage['deviceInfo']['permissions'];
      expect(permissions['location'], true);
    });

    test('Update device manufacturer', () {
      manager.updateDeviceManufacturer('TestBrand');
      expect(manager.currentMessage['deviceInfo']['deviceManufacturer'], 'TestBrand');
    });

    test('Update user position', () {
      manager.updateUserPosition(x: 10, y: 20, floor: 1);
      final pos = manager.currentMessage['userPosition'];
      expect(pos['X'], 10);
      expect(pos['Y'], 20);
      expect(pos['floor'], 1);
    });

    test('Update path info', () {
      manager.updatePath(source: 'A', destination: 'B', didPathForm: true);
      final path = manager.currentMessage['path'];
      expect(path['source'], 'A');
      expect(path['destination'], 'B');
      expect(path['didPathForm'], true);
    });

    test('Update AppInitialization', () {
      manager.updateInitialization(
        bid: 'BID001',
        buildingName: 'AC-01',
        localizedOn: '2025-04-21T12:00',
      );

      final init = manager.currentMessage['AppInitialization'];
      expect(init['BID'], 'BID001');
      expect(init['buildingName'], 'AC-01');
      expect(init['localizedOn'], '2025-04-21T12:00');
    });

    test('Add to bleScanResults and nearByDevices', () {
      manager.updateInitialization(
        bleScanResults: MapEntry('beacon1', {'rssi': -70}),
        nearByDevices: MapEntry('device1', {'distance': 3}),
      );

      final init = manager.currentMessage['AppInitialization'];
      expect(init['bleScanResults']['beacon1'], isNotNull);
      expect(init['nearByDevices']['device1'], isNotNull);
    });
  });
}
