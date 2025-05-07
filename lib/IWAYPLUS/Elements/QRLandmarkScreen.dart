
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../API/QRDataAPI.dart';
import '../API/buildingAllApi.dart';
import '/IWAYPLUS/APIMODELS/QRDataAPIModel.dart';
import '/NAVIGATION/Navigation.dart';
import '/NAVIGATION/pathState.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;

import 'HelperClass.dart';

class QRViewExample extends StatefulWidget {
  final bool frmMainPage;
  QRViewExample({Key? key, required this.frmMainPage}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isDeepLinkHandled = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    controller!.pauseCamera();
    // if (Platform.isAndroid) {
    //
    // }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          // Expanded(
          //   flex: 1,
          //   child: FittedBox(
          //     fit: BoxFit.contain,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: <Widget>[
          //         if (result != null)
          //           Text('Barcode Type: ${result!.code}')
          //         else
          //           const Text('Scan a code'),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: <Widget>[
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                   onPressed: () async {
          //                     await controller?.toggleFlash();
          //                     setState(() {});
          //                   },
          //                   child: FutureBuilder(
          //                     future: controller?.getFlashStatus(),
          //                     builder: (context, snapshot) {
          //                       return Text('Flash: ${snapshot.data}');
          //                     },
          //                   )),
          //             ),
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                   onPressed: () async {
          //                     await controller?.flipCamera();
          //                     setState(() {});
          //                   },
          //                   child: FutureBuilder(
          //                     future: controller?.getCameraInfo(),
          //                     builder: (context, snapshot) {
          //                       if (snapshot.data != null) {
          //                         return Text(
          //                             'Camera facing ${describeEnum(snapshot.data!)}');
          //                       } else {
          //                         return const Text('loading');
          //                       }
          //                     },
          //                   )),
          //             )
          //           ],
          //         ),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: <Widget>[
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                 onPressed: () async {
          //                   await controller?.pauseCamera();
          //                 },
          //                 child: const Text('pause',
          //                     style: TextStyle(fontSize: 20)),
          //               ),
          //             ),
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                 onPressed: () async {
          //                   await controller?.resumeCamera();
          //                 },
          //                 child: const Text('resume',
          //                     style: TextStyle(fontSize: 20)),
          //               ),
          //             )
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.tealAccent,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isDeepLinkHandled) return;
      _isDeepLinkHandled = true;
      try {
        final scannedUrl = scanData.code ?? '';
        print("Scanned QR code: $scannedUrl");

        final landmarkId = extractLandmarkId(scannedUrl);
        if (landmarkId != null) {
          print("Navigating via landmarkId: $landmarkId");
          Navigator.pop(context, landmarkId);
          return;
        }

        final qrCode = getQrCodeFromUrl(scannedUrl);
        print("CMS QR Code: $qrCode");

        final qrDataList = await QRDataAPI().fetchQRData(buildingAllApi.allBuildingID.keys.toList());

        for(int i = 0; i<qrDataList!.length; i++){
          if(qrDataList[i].code == qrCode){
            print("Navigating via CMS: ${qrDataList[i].landmarkId!}");
            Navigator.pop(context, qrDataList[i].landmarkId!);
            return;
          }
        }

        controller.stopCamera();
        HelperClass.showToast("Invalid/Unassigned QR");
        print("qr pop");
        Navigator.pop(context);
        return;
      } catch (e) {
        print('Error while handling QR scan: $e');
      }
    });
  }

  String? extractLandmarkId(String url) {
    try {
      final uri = Uri.parse(url);
      final parts = uri.fragment.split('/');

      final index = parts.indexOf('landmarkId');
      if (index != -1 && index + 1 < parts.length) {
        return parts[index + 1];
      }
    } catch (_) {}
    return null;
  }

  String getQrCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.fragment.split('/').last;
    } catch (_) {
      return '';
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}