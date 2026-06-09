class TimeHelper {
  TimeHelper._();

  static String formatFromSeconds(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String formatFromString(String? dateTimeString) {
    if (dateTimeString == null) return '--:--';
    try {
      final dt = DateTime.parse(dateTimeString);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}
