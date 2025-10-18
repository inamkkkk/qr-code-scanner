import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends ChangeNotifier {
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      notifyListeners();
    }
  }
}
