package com.iwayplus.navigation

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var bluetoothAdapter: BluetoothAdapter
    private lateinit var bluetoothLeScanner: BluetoothLeScanner
    private val deviceDetailsList = mutableListOf<String>()
    private var isScanning = false

    private val METHOD_CHANNEL = "com.example.bluetooth/scan"
    private val EVENT_CHANNEL = "com.example.bluetooth/scanUpdates"
    private var eventSink: EventChannel.EventSink? = null

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device
            val rssi = result.rssi

            if (ActivityCompat.checkSelfPermission(
                    this@MainActivity,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return
            }
            if (device.name != null && device.name.contains("IW")) {
                val deviceDetails = "Device Name: ${device.name}\nAddress: ${device.address}\nRSSI: $rssi"
                val device = BluetoothDevice(device.name,device.address,rssi.toString())
                Log.d("deviceInfo","${device.DeviceAddress} ${device.DeviceName} ${device.DeviceRssi}")
                //Log.d("deviceDetails","${deviceDetails}")
                if (!deviceDetailsList.contains(deviceDetails)) {
                    deviceDetailsList.add(deviceDetails)
                    Log.d("BluetoothScan", "New Device Found: $deviceDetails")
                    eventSink?.success(deviceDetails) // Send real-time updates to Flutterdetails.run
                }
                Log.d("deviceInfo",deviceDetailsList.size.toString());


                eventSink?.success(deviceDetails)

            }
        }

        override fun onScanFailed(errorCode: Int) {
            Log.e("BluetoothScan", "Scan failed with error code: $errorCode")
            eventSink?.error("SCAN_FAILED", "Scan failed with error code: $errorCode", null)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner

        // Request permissions if not already granted
        if (!hasPermissions()) {
            requestPermissions()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "MethodChannel and EventChannel initialized")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startScan" -> {
                    startScan()
                    result.success("Scanning started")
                }
                "stopScan" -> {
                    stopScan()
                    result.success("Scanning stopped")
                }
                "getScannedDevices" -> {
                    result.success(deviceDetailsList)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private fun startScan() {
        if (!isScanning) {
            if (!bluetoothAdapter.isEnabled) {
                Toast.makeText(this, "Bluetooth is not enabled", Toast.LENGTH_SHORT).show()
                return
            }

            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions()
                return
            }

            Log.d("BluetoothScan", "Starting scan...")
            bluetoothLeScanner.startScan(scanCallback)
            isScanning = true
        }
    }

    private fun stopScan() {
        if (isScanning) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions()
                return
            }

            Log.d("BluetoothScan", "Stopping scan...")
            bluetoothLeScanner.stopScan(scanCallback)
            isScanning = false
        }
    }

    private fun hasPermissions(): Boolean {
        val permissions = mutableListOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_CONNECT
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.add(Manifest.permission.BLUETOOTH_ADVERTISE)
        }

        return permissions.all { permission ->
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_CONNECT
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.add(Manifest.permission.BLUETOOTH_ADVERTISE)
        }

        ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 101)
    }
}
