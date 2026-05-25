import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/timer_model.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audio = AudioService();
  final notif = NotificationService();

  await audio.init();
  await notif.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TimerModel(audio: audio, notif: notif),
      child: const FocusGuardApp(),
    ),
  );
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusGuard',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
