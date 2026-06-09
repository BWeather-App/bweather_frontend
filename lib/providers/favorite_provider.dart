import 'package:flutter/foundation.dart';
import 'package:flutter_cuaca/services/favorite_service.dart';

enum FavoriteStatus { initial, loading, success, error }

class FavoriteProvider extends ChangeNotifier {
  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────

  FavoriteStatus _status = FavoriteStatus.initial;
  List<Map<String, dynamic>> _favoriteWeatherList = [];
  String _errorMessage = '';

  // ─────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────

  FavoriteStatus get status => _status;
  List<Map<String, dynamic>> get favoriteWeatherList => _favoriteWeatherList;
  String get errorMessage => _errorMessage;

  bool get isLoading => _status == FavoriteStatus.loading;
  bool get hasError => _status == FavoriteStatus.error;
  bool get isEmpty => _favoriteWeatherList.isEmpty;

  /// Jumlah total halaman di PageView (1 GPS + n favorit)
  int get totalPages => 1 + _favoriteWeatherList.length;

  // ─────────────────────────────────────────────
  // Load semua cuaca kota favorit
  //
  // Pakai FavoriteService.getFavoriteWeatherData()
  // yang menggunakan lat/lon — lebih akurat dari nama kota
  // ─────────────────────────────────────────────

  Future<void> loadFavoriteWeatherData() async {
    _setLoading();

    try {
      final data = await FavoriteService.getFavoriteWeatherData();
      _setSuccess(data);
    } catch (e) {
      _setError('Gagal memuat data kota favorit.');
      debugPrint('FavoriteProvider error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Tambah kota favorit & reload
  // ─────────────────────────────────────────────

  Future<void> addFavorite(Map<String, dynamic> cityData) async {
    await FavoriteService.addFavorite(cityData);
    await loadFavoriteWeatherData();
  }

  // ─────────────────────────────────────────────
  // Hapus kota favorit & reload
  // ─────────────────────────────────────────────

  Future<void> removeFavorite(String fullName) async {
    await FavoriteService.removeFavorite(fullName);
    await loadFavoriteWeatherData();
  }

  // ─────────────────────────────────────────────
  // Ambil data cuaca 1 kota favorit berdasarkan index
  // ─────────────────────────────────────────────

  Map<String, dynamic>? getFavoriteAt(int index) {
    if (index < 0 || index >= _favoriteWeatherList.length) return null;
    return _favoriteWeatherList[index];
  }

  // ─────────────────────────────────────────────
  // Private: State Setters
  // ─────────────────────────────────────────────

  void _setLoading() {
    _status = FavoriteStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess(List<Map<String, dynamic>> data) {
    _status = FavoriteStatus.success;
    _favoriteWeatherList = data;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status = FavoriteStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
