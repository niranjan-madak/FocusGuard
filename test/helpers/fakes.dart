import 'package:focusguard/services/audio_service.dart';
import 'package:focusguard/services/notification_service.dart';

class FakeAudioService implements AudioService {
  @override Future<void> init() async {}
  @override Future<void> playAlarm(bool isFocus, double volume) async {}
  @override Future<void> playClick(double volume) async {}
  @override Future<void> playTick(double volume) async {}
  @override void dispose() {}
}

class FakeNotificationService implements NotificationService {
  @override Future<void> init() async {}
  @override Future<void> show(String title, String body) async {}
}
