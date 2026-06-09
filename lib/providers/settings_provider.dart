import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'settings_box';
  static const _unitKey = 'use_fahrenheit';

  late Box _box;
  bool _useFahrenheit = false;

  bool get useFahrenheit => _useFahrenheit;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    _useFahrenheit = _box.get(_unitKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleUnit() async {
    _useFahrenheit = !_useFahrenheit;
    await _box.put(_unitKey, _useFahrenheit);
    notifyListeners();
  }

  String get unitSymbol => _useFahrenheit ? '°F' : '°C';

  double convertTemp(num celsius) {
    if (_useFahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius.toDouble();
  }
}
