//
//  BluetoothDevice.swift
//  Runner
//
//  Created by Wilson on 14/01/25.
//

import Foundation

class BluetoothDevice {
    var NAME: String?
    var RSSI: String?

    init(NAME: String?, RSSI: String?) {
        self.NAME = NAME
        self.RSSI = RSSI
    }
}
