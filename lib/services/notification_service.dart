import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('ic_stat_bweather');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    try {
      await _plugin.initialize(initSettings);
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  static Future<void> showCuacaEkstrem(String kota, String info) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'cuaca_channel',
          'Peringatan Cuaca',
          channelDescription: 'Notifikasi cuaca ekstrem',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    try {
      await _plugin.show(
        id,
        '⚠️ Cuaca Ekstrem di $kota',
        info,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('NotificationService show failed: $e');
    }
  }
}
