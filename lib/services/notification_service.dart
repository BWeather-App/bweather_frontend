import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> showCuacaEkstrem(String kota, String info) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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

    await _plugin.show(
      0,
      '⚠️ Cuaca Ekstrem di $kota',
      info,
      notificationDetails,
    );
  }
}
