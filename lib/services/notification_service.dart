import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    const linux   = LinuxInitializationSettings(defaultActionName: 'Open');

    await _plugin.initialize(
      const InitializationSettings(
        android: android, iOS: ios, linux: linux,
      ),
    );

    // Request permissions on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> show(String title, String body) async {
    const android = AndroidNotificationDetails(
      'focusguard_timer', 'Timer Alerts',
      importance: Importance.high, priority: Priority.high,
      playSound: false,
    );
    const ios  = DarwinNotificationDetails(presentSound: false);
    const linux = LinuxNotificationDetails();

    await _plugin.show(
      0, title, body,
      const NotificationDetails(
        android: android, iOS: ios, linux: linux,
      ),
    );
  }
}
