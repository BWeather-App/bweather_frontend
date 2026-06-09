import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_cuaca/services/weather_service.dart';
import 'package:flutter_cuaca/services/location_service.dart';
import 'package:flutter_cuaca/services/permission_service.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  static const _cacheKey = 'cached_weather';

  WeatherStatus _status = WeatherStatus.initial;
  Map<String, dynamic> _weatherData = {};
  String _errorMessage = '';

  WeatherStatus get status => _status;
  Map<String, dynamic> get weatherData => _weatherData;
  String get errorMessage => _errorMessage;

  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasError => _status == WeatherStatus.error;
  bool get hasData => _status == WeatherStatus.success;

  Map<String, dynamic>? get current =>
      _weatherData['weather']?['cuaca_saat_ini'] as Map<String, dynamic>?;

  Map<String, dynamic>? get location =>
      _weatherData['location'] as Map<String, dynamic>?;

  Map<String, dynamic>? get weather =>
      _weatherData['weather'] as Map<String, dynamic>?;

  double? get lat => location?['lat']?.toDouble();
  double? get lon => location?['lon']?.toDouble();

  Future<void> _loadCached() async {
    final box = Hive.box('weatherBox');
    final cached = box.get(_cacheKey);
    if (cached != null && cached is Map) {
      _weatherData = Map<String, dynamic>.from(cached);
      _status = WeatherStatus.success;
      notifyListeners();
    }
  }

  Future<void> loadWeatherData() async {
    _setLoading();

    await _loadCached();

    final granted = await PermissionService.requestLocationPermission();
    if (!granted) {
      if (_weatherData.isEmpty) {
        _setError('Izin lokasi diperlukan untuk menampilkan cuaca.');
      }
      return;
    }

    try {
      final position = await LocationService().getCurrentLocation();

      final data = await WeatherService.instance.getWeatherByLocation(
        lat: position.latitude,
        lon: position.longitude,
      );

      final box = Hive.box('weatherBox');
      await box.put(_cacheKey, data);

      _setSuccess(data);
    } on WeatherApiException catch (e) {
      if (_weatherData.isEmpty) _setError(e.userMessage);
    } catch (e) {
      if (_weatherData.isEmpty) {
        _setError('Tidak dapat terhubung ke server. Periksa koneksi internet.');
      }
      debugPrint('WeatherProvider error: $e');
    }
  }

  Future<void> refresh() => loadWeatherData();

  void _setLoading() {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess(Map<String, dynamic> data) {
    _status = WeatherStatus.success;
    _weatherData = data;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status = WeatherStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
