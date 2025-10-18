import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_app/services/permission_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    // In platform view lifecycle, sometimes onResume happens before onPlatformViewCreated
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: FutureBuilder<bool>(
        future: Provider.of<PermissionService>(context, listen: false).hasCameraPermission(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Column(
              children: <Widget>[
                Expanded(flex: 4, child: _buildQrView(context)),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        if (result != null)
                          Text(
                              'Data: ${result!.code}   ')
                        else
                          const Text('Scan a code'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(margin: const EdgeInsets.all(8), child: _buildFlashButton()),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Camera permission is required to scan QR codes.'),
                  ElevatedButton(
                    onPressed: () async {
                      await Provider.of<PermissionService>(context, listen: false).requestCameraPermission();
                      setState(() {});
                    },
                    child: const Text('Request Permission'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  Widget _buildFlashButton() {
    return FutureBuilder(future: controller?.getFlashStatus(), builder: (context, snapshot) {
      return ElevatedButton(
          onPressed: () async {
            await controller?.toggleFlash();
            setState(() {});
          },
          child: FutureBuilder(future: controller?.getFlashStatus(), builder: (context, snapshot) {
            return Text('Flash: ${snapshot.data}');
          }));
    });
  }


  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      controller.pauseCamera();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('QR Code Result'),
            content: Text(result!.code!),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.resumeCamera();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
