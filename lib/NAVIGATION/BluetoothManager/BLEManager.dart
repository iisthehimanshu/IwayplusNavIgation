import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwaymaps/IWAYPLUS/Elements/HelperClass.dart';
import '../APIMODELS/beaconData.dart';
import '../ELEMENTS/BluetoothDevice.dart';
import '../Repository/RepositoryManager.dart';
import '../buildingState.dart';


class BLEManager{

  static final BLEManager _instance = BLEManager._internal();

  factory BLEManager() {
    return _instance;
  }

  BLEManager._internal();

  static const methodChannel = MethodChannel('com.example.bluetooth/scan');
  static const eventChannel = EventChannel('com.example.bluetooth/scanUpdates');
  RepositoryManager networkManager = RepositoryManager();
  final StreamController<Map<String, dynamic>> _bufferedDeviceStreamController =
  StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get bufferedDeviceStream => _bufferedDeviceStreamController.stream;
  static StreamSubscription? _scanSubscription;

  Timer? _bufferEmitTimer;
  Timer? _manualStopTimer;
  Timer? trimBufferTimer;

  Map<String,Map<DateTime,String>> buffer = Map();


  void startScanning({
    required int bufferSize,
    required int streamFrequency,
    int? duration,
  }) {
    // stopScanning(); // cancel previous

    listenToScanUpdates(Building.apibeaconmap);

    // Start emitting data to stream every [streamFrequency] seconds
    startBufferedEmission(bufferSizeInSeconds: streamFrequency);

    if (duration != null) {
      _manualStopTimer = Timer(Duration(seconds: duration), () {
        stopScanning();
      });
    }
  }


  void startBufferedEmission({required int bufferSizeInSeconds}) {
    print("📚 Call Stack:\n${StackTrace.current}");

    if(kDebugMode) print("startBufferEmission");
    _bufferEmitTimer?.cancel(); // cancel previous if any
    _bufferEmitTimer = Timer.periodic(Duration(seconds: bufferSizeInSeconds), (_) {

      final dataToSend = buffer;
      print("dataToSend}");
      printFull(dataToSend.toString());
      // _bufferedDeviceStreamController.
      _bufferedDeviceStreamController.add(dataToSend);
    });
  }
  void printFull(String text) {
    const int chunkSize = 800; // Console limit-safe size
    for (var i = 0; i < text.length; i += chunkSize) {
      print(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }


  Future<void> startScan() async {
    try{
      await methodChannel.invokeMethod('startScan');
      // isScanning = true;
    } on PlatformException catch(e){
      print("Failed to start scan: ${e.message}");
    }
  }

  Future<void> stopScanning() async {
    try {
      await methodChannel.invokeMethod('stopScan');
      //cancel _scanSubscription of native scanning
      _scanSubscription?.cancel();
      _scanSubscription = null;

      //cancel buffer Emission
      _bufferEmitTimer?.cancel();

      // trimBuffer Timer
      trimBufferTimer?.cancel();
      //timer for manual scanning stop
      _manualStopTimer?.cancel();
      //dataStructure buffer clean
      buffer.clear();

    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
    }
  }

  void listenToScanUpdates(HashMap<String, beacon> apibeaconmap) {
    startScan();
    trimBuffer();
    if (kDebugMode) print("listenToScanUpdates");
    _scanSubscription = eventChannel.receiveBroadcastStream().listen((device) {
      if (kDebugMode) print("deviceDetail $device");
      BluetoothDevice deviceDetails = HelperClass().parseDeviceDetails(device);
      buffer.putIfAbsent(deviceDetails.DeviceName, () => <DateTime, String>{});
      buffer[deviceDetails.DeviceName]![DateTime.now()] = deviceDetails.DeviceRssi;
    }, onError: (error) {
      if (kDebugMode) print('Error receiving device updates: $error');
    });
  }

  void trimBuffer(){
    trimBufferTimer = Timer.periodic(Duration(seconds: 2), (timer)  {
      if (kDebugMode) print("startCleanupTimer");
      buffer.forEach((beaconName,beaconRespVal){
        final toRemove = <DateTime>[];
        beaconRespVal.forEach((beaconDateTime, beaconRSSI){
          if(DateTime.now().difference(beaconDateTime) > Duration(seconds: 5)){
            toRemove.add(beaconDateTime);
          }
        });
        for(final beaconDateTime in toRemove){
          beaconRespVal.remove(beaconDateTime);
        }
      });
      final keysToRemove = <String>[];
      buffer.forEach((key, value) {
        if (value.isEmpty) {
          keysToRemove.add(key);
        }
      });
      for (final key in keysToRemove) {
        buffer.remove(key);
      }
      doCalculationForNearestBeacon();
    });
  }

  void doCalculationForNearestBeacon(){
    Map<String,double> weightAvg = {};
    buffer.forEach((beaconName, beaconResponseValues){
      double totalWeight = 0.0;
      int divideBySize = 0;
      beaconResponseValues.forEach((dateTime,rSSI){
        totalWeight+= HelperClass().getBinWeight(int.parse(rSSI).abs());
        divideBySize+=1;
      });
      weightAvg[beaconName] = totalWeight/divideBySize;
    });
    String finalName = "";
    double finalWeight = double.negativeInfinity;
    weightAvg.forEach((name,weight){
        if(weight>finalWeight){
          finalWeight = weight;
          finalName = name;
        }
    });
    
    if (kDebugMode) print("Reposition on $finalName $finalWeight $weightAvg");
  }
}