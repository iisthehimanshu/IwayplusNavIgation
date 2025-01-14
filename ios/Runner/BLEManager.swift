//
//  BLEManager.swift
//  Runner
//
//  Created by Wilson on 14/01/25.
//

import Foundation
import CoreBluetooth

@objc class BLEManager: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager?
    private var devices: [String] = []
    private var resultCallback: FlutterResult?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan(result: @escaping FlutterResult) {
        devices.removeAll()
        resultCallback = result
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScan() {
        centralManager?.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            showBluetoothAlert()
        } else {
            centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if let singledeviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            //print("Advertisement Name: \(singledeviceName)")
        }
        
        guard let singledeviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            //print("Advertisement Name is nil")
            return
        }

        let rssiValue = RSSI // RSSI is of type NSNumber
        
        // Check if the device name contains "IW" and RSSI is not nil
        if singledeviceName.contains("IW") {
            let rssiString = rssiValue.stringValue // Convert RSSI to String

            print("Advertisement Name: \(singledeviceName)")
            print("RSSI: \(rssiString)")

                    
            devices.append("Advertisement Name: \(singledeviceName), RSSI: \(rssiString) ")
            print("NewLength \(devices.count)")
            resultCallback?(devices)
            // Proceed with logic using the bluetoothDevice object
        } else {
            //print("Advertisement Name does not contain 'IW' or RSSI is nil. Skipping device.")
        }

        

//        let deviceName = peripheral.name ?? "Unnamed Device"
//        let deviceUUID = peripheral.identifier.description
//
////        print("Advertisement Data:")
////        advertisementData.forEach { key, value in
////            print("  • \(key): \(value)")
////        }
//        // Add the device if it isn't already listed
//        if !devices.contains(deviceUUID) && !deviceName.contains("IW"){
//            print("Found device:")
//            print("Name: \(deviceName)")
//            print("UUID: \(deviceUUID)")
//            print("RSSI: \(RSSI)")
//            devices.append(deviceUUID)
//            resultCallback?(devices)
//        }
    }
    
    func showBluetoothAlert() {
        let alertController = UIAlertController(
            title: "Bluetooth is Off",
            message: "Please enable Bluetooth to scan for devices.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Ensure this is presented from the top-most view controller
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
}
