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
    private var devicesRssi: [String: [NSNumber]] = [:]
    private var weights: [String: [Double]] = [:]
    private var resultCallback: FlutterResult?
    private var lastSeenTimestamps: [String: Date] = [:]
    private var weightAverage : [String: Double] = [:]

    private var timer: Timer?
    private var cleanUpTimer: Timer?
    
    private var sendDeviceData: String?
    public var bestDevice: String?
    
    

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan(result: @escaping FlutterResult) {
        devices.removeAll()
        devicesRssi.removeAll()
        weights.removeAll()
        resultCallback = result
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.processClosestDevice()
        }
        cleanUpTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.startCleanupTimer()
        }
        
    }

    func stopScan() {
        centralManager?.stopScan()
        timer?.invalidate()
        timer = nil
        
        cleanUpTimer?.invalidate()
        cleanUpTimer = nil
    }
    
    @objc func getBestDevice(result: @escaping FlutterResult) {
        result(sendDeviceData ?? "No device found")
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
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss" // Time format: Hours:Minutes:Seconds
        let currentTimeString = dateFormatter.string(from: currentTime)
        
        // Check if the device name contains "IW" and RSSI is not nil
        if singledeviceName.contains("IW") {
            let rssiString = rssiValue.stringValue // Convert RSSI to String
            
            devices.append("Advertisement Name: \(singledeviceName), RSSI: \(rssiString) ")
            if devicesRssi[singledeviceName] == nil {
                devicesRssi[singledeviceName] = []
                weights[singledeviceName] = []
            }
            devicesRssi[singledeviceName]?.append(rssiValue)
            weights[singledeviceName]?.append(getWeight(for: NSNumber(value: abs(rssiValue.int32Value))))
            
            lastSeenTimestamps[singledeviceName] = currentTime


            // Limit to the last 7 values
            if let rssiList = devicesRssi[singledeviceName], rssiList.count > 7 {
                devicesRssi[singledeviceName]?.removeFirst()
            }

            if let weightList = weights[singledeviceName], weightList.count > 7 {
                weights[singledeviceName]?.removeFirst()
            }
            
        } else {
            //print("Advertisement Name does not contain 'IW' or RSSI is nil. Skipping device.")
        }
//        print(devicesRssi)
//        print(weights)
        
        //resultCallback?(devices)
        
    }
    
    private func startCleanupTimer() {
        print("startCleanupTimer")
        let currentTime = Date()
        for (device, timestamp) in self.lastSeenTimestamps {
            if currentTime.timeIntervalSince(timestamp) > 2.0 {
                if let rssiList = self.devicesRssi[device], !rssiList.isEmpty {
                    self.devicesRssi[device]?.removeFirst()
                }
                if let weightList = weights[device], !weightList.isEmpty{
                    weights[device]?.removeFirst()
                }
            }
        }
    }
    
    
    private func processClosestDevice() {
        weightAverage.removeAll()
        print(weights)
        var bestDevice: String? = nil
        var highestAverageWeight: Double = -.greatestFiniteMagnitude
        
        for (device, weightList) in weights {
            guard !weightList.isEmpty else { continue }

            let totalWeight = weightList.reduce(0, +)
            
            let averageWeight = totalWeight / Double(weightList.count)
            print("device \(device) averageWeight \(averageWeight)")
            
            weightAverage[device] = averageWeight

            if averageWeight > highestAverageWeight {
                highestAverageWeight = averageWeight
                bestDevice = device
            }
        }
        sendDeviceData = "\(bestDevice) \(highestAverageWeight)"
        print("Best Device: \(bestDevice) with Average Weight: \(highestAverageWeight)")
    }
    
    private func calculateWeightedAverage(rssiList: [Double], weightList: [Double]) -> Double {
        let totalWeight = weightList.reduce(0, +)
        let weightedSum = zip(rssiList, weightList).map { $0 * $1 }.reduce(0, +)
        return totalWeight > 0 ? weightedSum / totalWeight : .greatestFiniteMagnitude
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
    
    
    func getWeight(for num: NSNumber) -> Double {
        let value = num.doubleValue // Convert NSNumber to Double
        switch value {
        case ..<65: // Less than 65
            return 12.0
        case 65...75: // Between 65 and 75
            return 6.0
        case 76...80: // Between 76 and 80
            return 4.0
        case 81...85: // Between 81 and 85
            return 0.5
        case 86...90: // Between 86 and 90
            return 0.25
        case 91...95: // Between 91 and 95
            return 0.15
        default: // Greater than 95
            return 0.0
        }
    }
    
    
    //---------Initial Localization-------
    
    private var IL_Timer: Timer?

    
    
    
    func initialLocalization(result: @escaping FlutterResult){
        devices.removeAll()
        devicesRssi.removeAll()
        weights.removeAll()
        resultCallback = result
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        IL_Timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.performAdditionalTask()
        }
    }
    
    
    private func performAdditionalTask() {
        // Replace with your actual task
        print(devices);
        print(weights );
        
        print("Performing additional task after 6 seconds.")
        
        // Example: Stop scanning
        stopScan()
        
        var IL_nearestDevice: String? = nil
        var IL_nearestDeviceWeight: Double = -.greatestFiniteMagnitude
        
        for (device, weightList) in weights {
            guard !weightList.isEmpty else { continue }

            let totalWeight = weightList.reduce(0, +)
            
            let averageWeight = totalWeight / Double(weightList.count)
            print("device \(device) averageWeight \(averageWeight)")
            
            weightAverage[device] = averageWeight

            if averageWeight > IL_nearestDeviceWeight {
                IL_nearestDeviceWeight = averageWeight
                IL_nearestDevice = device
            }
        }
         
        print("Best Device: \(IL_nearestDevice) with Average Weight: \(IL_nearestDeviceWeight)")
        
        devices.removeAll()
        devicesRssi.removeAll()
        weights.removeAll()
        weightAverage.removeAll()

        resultCallback?(IL_nearestDevice)
    }
}
