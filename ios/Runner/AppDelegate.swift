import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA0U_ddvL7t0gRdteVw_9MpVER1N0oqfY8")
      // This is required to make any communication available in the action isolate.
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
      }

      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }
          
      let controller = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "ble_scanner", binaryMessenger: controller.binaryMessenger)
      let bleManager = BLEManager()

      
      channel.setMethodCallHandler { (call, result) in
          switch call.method {
          case "startScan":
              bleManager.startScan(result: result)
          case "stopScan":
              bleManager.stopScan()
              result("Scanning stopped.")
          case "initialLocalization":
              bleManager.initialLocalization(result: result)
          case "getBestDevice":
              bleManager.getBestDevice(result: result)
          default:
              result(FlutterMethodNotImplemented)
          }
      }
  // Register generated plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}