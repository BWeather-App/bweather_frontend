import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static bool _isRequesting = false; // Tambahkan ini sebagai pengunci

  static Future<bool> requestLocationPermission(BuildContext context) async {
    // Jika sedang request, langsung batalin
    if (_isRequesting) return false;
    _isRequesting = true;

    try {
      final status = await Permission.locationWhenInUse.request();

      if (status.isGranted) {
        return true;
      } else {
        // Tampilkan dialog jika tidak diizinkan
        if (status.isPermanentlyDenied) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Izin Lokasi Diperlukan"),
              content: const Text(
                "Silakan aktifkan izin lokasi secara manual dari pengaturan.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          await openAppSettings();
        }
        return false;
      }
    } finally {
      // Pastikan flag dimatikan meski ada error
      _isRequesting = false;
    }
  }
}