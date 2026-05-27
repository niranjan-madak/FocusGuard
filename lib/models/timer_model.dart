import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

class TimerModel extends ChangeNotifier {
  final AudioService audio;
  final NotificationService notif;

  int focusMins = 75;
  int breakMins = 20;

  bool running = false;
  bool paused  = false;
  bool isFocus = true;
  late int secsLeft;
  int sessionsCompleted = 0;
  int totalFocusSecs    = 0;
  int cycles            = 0;
  List<String> history  = [];
  bool alarmActive  = false;
  bool soundEnabled = true;
  bool autoStart    = true;
  double volume     = 0.7;

  Timer? _ticker;

  TimerModel({required this.audio, required this.notif}) {
    secsLeft = focusMins * 60;
  }

  // ── Derived ─────────────────────────────────────────────────────────────────
  int    get totalSecs  => (isFocus ? focusMins : breakMins) * 60;
  double get progress   => totalSecs > 0 ? secsLeft / totalSecs : 0;
  String get timeStr {
    final m = secsLeft ~/ 60, s = secsLeft % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
  String get focusTimeStr {
    final h = totalFocusSecs ~/ 3600;
    final m = (totalFocusSecs % 3600) ~/ 60;
    return '${h}h ${m}m';
  }
  String get statusText {
    if (paused)    return 'PAUSED';
    if (!running)  return 'READY';
    if (isFocus)   return 'FOCUSING';
    return 'ON BREAK';
  }

  // ── Controls ─────────────────────────────────────────────────────────────────
  void toggleStartStop() {
    if (!running)      { _start(); }
    else if (!paused)  { _pause(); }
    else               { _resume(); }
    if (soundEnabled) audio.playClick(volume);
  }

  void skip() {
    _recordSession();
    isFocus  = !isFocus;
    secsLeft = (isFocus ? focusMins : breakMins) * 60;
    running  = false;
    paused   = false;
    _ticker?.cancel();
    if (soundEnabled) audio.playClick(volume);
    notifyListeners();
  }

  Future<void> reset() async {
    _ticker?.cancel();
    running = false; paused = false; isFocus = true;
    secsLeft = focusMins * 60;
    sessionsCompleted = 0; totalFocusSecs = 0; cycles = 0;
    history = []; alarmActive = false;
    if (soundEnabled) audio.playClick(volume);
    notifyListeners();
  }

  void dismissAlarm() {
    alarmActive = false;
    notifyListeners();
  }

  void applySettings({required int focusM, required int breakM}) {
    focusMins = focusM;
    breakMins = breakM;
    reset();
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
    notifyListeners();
  }

  void setVolume(double v) {
    volume = v;
    notifyListeners();
  }

  void setAutoStart(bool v) {
    autoStart = v;
    notifyListeners();
  }

  // ── Internal ─────────────────────────────────────────────────────────────────
  void _start() {
    running = true; paused = false;
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void _pause() {
    paused = true;
    notifyListeners();
  }

  void _resume() {
    paused = false;
    notifyListeners();
  }

  void _tick(Timer _) {
    if (!running || paused) return;
    if (secsLeft > 0) {
      secsLeft--;
      if (isFocus) totalFocusSecs++;
      if (secsLeft <= 10 && secsLeft > 0 && soundEnabled) audio.playTick(volume);
      notifyListeners();
    } else {
      _onSessionEnd();
    }
  }

  void _recordSession() {
    history.add(isFocus ? 'focus' : 'break');
    if (isFocus) sessionsCompleted++;
    cycles = history.where((h) => h == 'break').length;
  }

  void _onSessionEnd() {
    _ticker?.cancel();
    running = false;
    _recordSession();
    isFocus  = !isFocus;
    secsLeft = (isFocus ? focusMins : breakMins) * 60;
    alarmActive = true;

    if (soundEnabled) audio.playAlarm(isFocus, volume);

    notif.show(
      isFocus ? 'Break Over — Time to Focus!'    : 'Session Done — Take a Break!',
      isFocus ? 'Start your $focusMins-min focus session.' : 'Rest for $breakMins minutes.',
    );

    notifyListeners();

    if (autoStart) {
      Future.delayed(Duration(milliseconds: isFocus ? 3200 : 4000), () {
        if (!running && autoStart) _start();
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
