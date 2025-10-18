import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_app/screens/qr_scanner_screen.dart';
import 'package:qr_code_scanner_app/services/permission_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => PermissionService(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRScannerScreen(),
    );
  }
}
