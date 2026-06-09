import 'package:shared_preferences/shared_preferences.dart';

const String _searchHistoryKey = 'search_history';

/// Menyimpan kota ke riwayat pencarian.
/// Tidak menyimpan duplikat dan hanya menyimpan maksimal 10 item terbaru.
Future<void> saveSearchHistory(String cityName) async {
  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList(_searchHistoryKey) ?? [];

  final updatedHistory = List<String>.from(history)..remove(cityName);
  updatedHistory.insert(0, cityName);

  if (updatedHistory.length > 10) {
    updatedHistory.removeRange(10, updatedHistory.length);
  }

  await prefs.setStringList(_searchHistoryKey, updatedHistory);
}

/// Mengambil daftar riwayat pencarian.
Future<List<String>> getSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_searchHistoryKey) ?? [];
}

/// Memperbarui seluruh daftar riwayat pencarian.
Future<void> updateSearchHistory(List<String> updatedList) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_searchHistoryKey, updatedList);
}

/// Menghapus seluruh riwayat pencarian.
Future<void> clearSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_searchHistoryKey);
}
