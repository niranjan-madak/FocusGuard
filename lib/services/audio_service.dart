import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final _focus = AudioPlayer();
  final _brk   = AudioPlayer();
  final _click = AudioPlayer();
  final _tick  = AudioPlayer();

  Future<void> init() async {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(isSpeakerphoneOn: false, audioFocus: AndroidAudioFocus.none),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ),
    );
  }

  Future<void> playAlarm(bool isFocus, double volume) async {
    final p = isFocus ? _brk : _focus; // entering focus = break alarm just ended
    await p.setVolume(volume);
    await p.play(AssetSource(isFocus ? 'sounds/break_alarm.wav' : 'sounds/focus_alarm.wav'));
  }

  Future<void> playClick(double volume) async {
    await _click.setVolume(volume);
    await _click.play(AssetSource('sounds/click.wav'));
  }

  Future<void> playTick(double volume) async {
    await _tick.setVolume(volume);
    await _tick.play(AssetSource('sounds/tick.wav'));
  }

  void dispose() {
    _focus.dispose(); _brk.dispose(); _click.dispose(); _tick.dispose();
  }
}
