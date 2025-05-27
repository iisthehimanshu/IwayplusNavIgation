package com.iwayplus.navigation

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
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
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.SystemClock



class MainActivity : FlutterActivity() {

    private lateinit var bluetoothAdapter: BluetoothAdapter
    private lateinit var bluetoothLeScanner: BluetoothLeScanner
    private val deviceDetailsList = mutableListOf<String>()
    private var isScanning = false
    private var gravityValues = FloatArray(3)
    private var magneticValues = FloatArray(3)
    private var rotationVectorValue = FloatArray(5)

    private var lastUpdateTime: Long = 0
    private val COMPASS_UPDATE_RATE_MS:Long = 100L


    private val METHOD_CHANNEL = "com.example.bluetooth/scan"
    private val EVENT_CHANNEL = "com.example.bluetooth/scanUpdates"

    //implemented magnetometere streams
    private val COMPASS_CHANNEL = "com.example.navigation/compass"


    private var eventSink: EventChannel.EventSink? = null

    private var eventSinkCompass: EventChannel.EventSink? = null

    private fun lowPassFilter(input: FloatArray, output: FloatArray?): FloatArray {
        val alpha = 0.25f
        if (output == null) return input
        for (i in input.indices) {
            output[i] = output[i] + alpha * (input[i] - output[i])
        }
        return output
    }


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

            // Extract device name
            if (device.name != null && device.name.contains("IW")) {
//                Log.d("BluetoothScan","Device Info $result");
                val scanRecord = result.scanRecord

                val scanRecord1 = result.scanRecord
                val deviceName1 = device.name ?: scanRecord1?.deviceName ?: "Unknown"
                val address = device.address
                val timestampNanos = result.timestampNanos
                val advBytes = scanRecord1?.bytes
                val manufacturerData1 = scanRecord1?.manufacturerSpecificData

//                Log.d("BluetoothScan", "Device Name: $deviceName1")
//                Log.d("BluetoothScan", "Address: $address")
//                Log.d("BluetoothScan", "RSSI: $rssi dBm")
//                Log.d("BluetoothScan", "Timestamp: $timestampNanos") // You can convert it to time if needed

                // Extract Manufacturer ID and Data
                for (i in 0 until (manufacturerData1?.size() ?: 0)) {
                    val id = manufacturerData1?.keyAt(i)
                    val data = id?.let { manufacturerData1?.get(it) }
                    val hexData = data?.joinToString("-") { "%02X".format(it) }
                    //Log.d("BluetoothScan", "Manufacturer ID: ${String.format("%04X", id)}")
                    //Log.d("BluetoothScan", "Manufacturer Data: $hexData")
                }

                // Get Raw Bytes
                val rawData = advBytes?.joinToString("-") { String.format("%02X", it) }
                //Log.d("BluetoothScan", "Raw Data: $rawData")

                val deviceDetails = """
                Device Name: $deviceName1
                Address: ${address}
                RSSI: $rssi
                Manufacturer Data: $manufacturerData1
                Raw Data: $rawData""".trimIndent()


                //Log.d("BluetoothScan--", "New Device Found: $deviceDetails")
                eventSink?.success(deviceDetails)
            }
        }

        override fun onScanFailed(errorCode: Int) {
            Log.e("BluetoothScan", "Scan failed with error code: $errorCode")
            eventSink?.error("SCAN_FAILED", "Scan failed with error code: $errorCode", null)
        }
    }

    private val discoveryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action: String? = intent.action
            if (BluetoothDevice.ACTION_FOUND == action) {
                val device: BluetoothDevice? =
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                device?.let {
                    val deviceDetails = "Device Name: ${"Unknown"}\nAddress: ${it.address}"
                    if (!deviceDetailsList.contains(deviceDetails)) {
                        deviceDetailsList.add(deviceDetails)
                        eventSink?.success(deviceDetails)
                    }
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
        bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner
        Log.d("bluetooth adapter","valuees${bluetoothAdapter},${bluetoothLeScanner}")
        if (bluetoothAdapter != null && bluetoothAdapter.isEnabled) {
            bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner
        } else {
            // Handle gracefully — maybe prompt to enable Bluetooth
            Log.w("BLE", "Bluetooth is OFF or unavailable")
        }

        if (!hasPermissions()) {
            requestPermissions()
        }

        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        registerReceiver(discoveryReceiver, filter)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
                else -> result.notImplemented()
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger,EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })


        EventChannel(flutterEngine.dartExecutor.binaryMessenger, COMPASS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private lateinit var sensorManager: SensorManager
                private lateinit var sensorListener: SensorEventListener

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSinkCompass = events
                    sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager

                    val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
                    val magnetometer = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
                    val rotationVectorSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)

                    sensorListener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent?) {
                            if (event == null) return

                            when (event.sensor.type) {
                                Sensor.TYPE_ROTATION_VECTOR -> {
                                    rotationVectorValue = lowPassFilter(event.values.clone(), rotationVectorValue)
                                }

                                Sensor.TYPE_ACCELEROMETER -> {
                                    gravityValues = lowPassFilter(event.values.clone(), gravityValues)
                                }

                                Sensor.TYPE_MAGNETIC_FIELD -> {
                                    magneticValues = lowPassFilter(event.values.clone(), magneticValues)
                                }
                            }

                            val currentTime = SystemClock.elapsedRealtime()
                            if (currentTime - lastUpdateTime > COMPASS_UPDATE_RATE_MS) {
                                lastUpdateTime = currentTime
                                val heading = updateHeading()
                                heading?.let {
//                                    Log.d("HeadingPlugin", "Heading: $it")
                                    eventSinkCompass?.success(it)
                                }
                            }
                        }

                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }

                    // ✅ Register all three sensors
                    sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_GAME)
                    sensorManager.registerListener(sensorListener, magnetometer, SensorManager.SENSOR_DELAY_GAME)
                    sensorManager.registerListener(sensorListener, rotationVectorSensor, SensorManager.SENSOR_DELAY_GAME)
                }

                override fun onCancel(arguments: Any?) {
                    sensorManager.unregisterListener(sensorListener)
                }
            }
        )

    }

    private fun updateHeading(): Double? {
        val rotationMatrix = FloatArray(9)
        val orientation = FloatArray(3)
        var heading: Float
        if (rotationVectorValue != null) {
            SensorManager.getRotationMatrixFromVector(rotationMatrix, rotationVectorValue)
            SensorManager.getOrientation(rotationMatrix, orientation)
            heading = Math.toDegrees(orientation[0].toDouble()).toFloat()
            if (heading > 180) {
                heading -= 360
            }

            // Log.d("Rotation", "Using rotation vector: $heading")
            return heading.toDouble()
        }
        if (gravityValues != null && magneticValues != null &&
            SensorManager.getRotationMatrix(rotationMatrix, null, gravityValues, magneticValues)) {

            val remappedMatrix = FloatArray(9)
            SensorManager.remapCoordinateSystem(rotationMatrix, SensorManager.AXIS_X, SensorManager.AXIS_Z, remappedMatrix)
            SensorManager.getOrientation(remappedMatrix, orientation)
            heading = Math.toDegrees(orientation[0].toDouble()).toFloat()
            if (heading > 180) {
                heading -= 360
            }

            //  Log.d("Rotation", "Using accel + mag: $heading")
            return heading.toDouble()
        }

        return null
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

            Log.d("BluetoothScan", "Starting BLE scan...")
            bluetoothLeScanner.startScan(scanCallback)

            isScanning = true
        }
    }

    private fun stopScan() {
        try {
            if (isScanning) {
                // Check if the required permission is granted
                if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED) {
                    bluetoothLeScanner.stopScan(scanCallback)
                    isScanning = false
                    Log.d("BluetoothScan", "Scanning stopped")
                } else {
                    Log.e("BluetoothScan", "Permission not granted for stopping the scan")
                    requestPermissions()
                }
            } else {
                Log.d("BluetoothScan", "Scan is not running, no need to stop")
            }
        } catch (e: SecurityException) {
            Log.e("BluetoothScan", "SecurityException: ${e.message}")
            Toast.makeText(this, "Failed to stop scanning due to missing permissions", Toast.LENGTH_SHORT).show()
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

        return permissions.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
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

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(discoveryReceiver)
    }




}