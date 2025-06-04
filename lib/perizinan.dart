import 'package:geolocator/geolocator.dart';

class PerizinanHandler {
  /// Meminta izin lokasi dari user.
  static Future<bool> mintaIzinLokasi() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin ditolak
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak permanen
      return false;
    }

    // Izin diberikan
    return true;
  }

  /// Mengecek apakah layanan lokasi aktif.
  static Future<bool> layananLokasiAktif() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}