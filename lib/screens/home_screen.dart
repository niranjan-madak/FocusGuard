import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/timer_model.dart';
import '../theme.dart';
import '../widgets/progress_ring.dart';
import '../widgets/alarm_banner.dart';
import '../widgets/stats_bar.dart';
import '../widgets/timeline_dots.dart';
import '../widgets/settings_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _settingsOpen = false;

  @override
  Widget build(BuildContext context) {
    final m = context.watch<TimerModel>();

    // Keep screen on during active focus
    WakelockPlus.toggle(enable: m.running && !m.paused && m.isFocus);

    // Update window title (best-effort, no-op on mobile)
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: '${m.timeStr} — ${m.isFocus ? "Focus" : "Break"} | FocusGuard',
      ),
    );

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (e) => _handleKey(e, m),
      child: Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 800) {
                return _buildDesktopLayout(m, constraints);
              }
              return _buildMobileLayout(m);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(TimerModel m) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: Column(
            children: [
              _Header(),
              const SizedBox(height: 12),
              _StatusBadge(m),
              const SizedBox(height: 16),
              _MainCard(m, _settingsOpen, () => setState(() => _settingsOpen = !_settingsOpen)),
              const SizedBox(height: 16),
              _ShortcutsBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(TimerModel m, BoxConstraints constraints) {
    final ringSize = (constraints.maxWidth * 0.22).clamp(260.0, 340.0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: branding + ring + shortcuts
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 40, 24, 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(),
                  const SizedBox(height: 48),
                  ProgressRing(
                    progress: m.progress,
                    isFocus: m.isFocus,
                    timeStr: m.timeStr,
                    size: ringSize,
                  ),
                  const SizedBox(height: 40),
                  _ShortcutsBar(),
                ],
              ),
            ),
          ),
        ),
        // Right: status badge + controls card
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 48, 40),
            child: Column(
              children: [
                _StatusBadge(m),
                _ControlsCard(m, _settingsOpen, () => setState(() => _settingsOpen = !_settingsOpen)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleKey(KeyEvent e, TimerModel m) {
    if (e is! KeyDownEvent) return;
    final ctrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (e.logicalKey == LogicalKeyboardKey.space && !ctrl) {
      m.toggleStartStop();
    } else if (e.logicalKey == LogicalKeyboardKey.keyK && ctrl) {
      m.skip();
    } else if (e.logicalKey == LogicalKeyboardKey.keyR && ctrl) {
      m.reset();
    } else if (e.logicalKey == LogicalKeyboardKey.keyM && ctrl) {
      m.toggleSound();
    }
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: 'FOCUS', style: orbitron(22, FontWeight.w900, C.focus)),
              TextSpan(text: '|', style: orbitron(22, FontWeight.w400, C.text2)),
              TextSpan(text: 'GUARD', style: orbitron(22, FontWeight.w900, C.focus)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('DEEP WORK · FOCUS SESSIONS', style: mono(11, C.text3)),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatefulWidget {
  final TimerModel m;
  const _StatusBadge(this.m);
  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    final mc = C.mc(m.isFocus);
    final md = C.md(m.isFocus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
        color: md,
        border: Border.all(color: mc),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Opacity(
              opacity: m.paused ? 0.4 : (0.25 + 0.75 * _ctrl.value),
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(color: mc, shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(m.statusText, style: orbitron(11, FontWeight.w700, mc)),
        ],
      ),
    );
  }
}

// ── Main card ─────────────────────────────────────────────────────────────────
class _MainCard extends StatelessWidget {
  final TimerModel m;
  final bool settingsOpen;
  final VoidCallback toggleSettings;

  const _MainCard(this.m, this.settingsOpen, this.toggleSettings);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      decoration: BoxDecoration(
        color: C.surface,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: C.mg(m.isFocus), blurRadius: 40, spreadRadius: 0)],
      ),
      child: Column(
        children: [
          // Top accent line
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, C.mc(m.isFocus), Colors.transparent]),
            ),
          ),

          // Progress ring
          ProgressRing(progress: m.progress, isFocus: m.isFocus, timeStr: m.timeStr),
          const SizedBox(height: 20),

          // Alarm banner
          if (m.alarmActive) AlarmBanner(
            isFocus: m.isFocus, focusMins: m.focusMins, breakMins: m.breakMins,
            onDismiss: m.dismissAlarm,
          ),

          // Controls
          _Controls(m),
          const SizedBox(height: 14),

          // Stats
          StatsBar(
            sessions: m.sessionsCompleted,
            focusTime: m.focusTimeStr,
            cycles: m.cycles,
            isFocus: m.isFocus,
          ),

          // Timeline
          TimelineDots(history: m.history, running: m.running, isFocus: m.isFocus),
          const SizedBox(height: 14),

          // Options
          _Options(m, toggleSettings),

          // Settings panel
          if (settingsOpen) SettingsPanel(
            focusMins: m.focusMins,
            breakMins: m.breakMins,
            onApply: ({required focusM, required breakM}) =>
                m.applySettings(focusM: focusM, breakM: breakM),
          ),
        ],
      ),
    );
  }
}

// ── Desktop controls card (no ring) ──────────────────────────────────────────
class _ControlsCard extends StatelessWidget {
  final TimerModel m;
  final bool settingsOpen;
  final VoidCallback toggleSettings;

  const _ControlsCard(this.m, this.settingsOpen, this.toggleSettings);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      decoration: BoxDecoration(
        color: C.surface,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: C.mg(m.isFocus), blurRadius: 40, spreadRadius: 0)],
      ),
      child: Column(
        children: [
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, C.mc(m.isFocus), Colors.transparent]),
            ),
          ),
          if (m.alarmActive) AlarmBanner(
            isFocus: m.isFocus, focusMins: m.focusMins, breakMins: m.breakMins,
            onDismiss: m.dismissAlarm,
          ),
          _Controls(m),
          const SizedBox(height: 20),
          StatsBar(
            sessions: m.sessionsCompleted,
            focusTime: m.focusTimeStr,
            cycles: m.cycles,
            isFocus: m.isFocus,
          ),
          TimelineDots(history: m.history, running: m.running, isFocus: m.isFocus),
          const SizedBox(height: 20),
          _Options(m, toggleSettings),
          if (settingsOpen) SettingsPanel(
            focusMins: m.focusMins,
            breakMins: m.breakMins,
            onApply: ({required focusM, required breakM}) =>
                m.applySettings(focusM: focusM, breakM: breakM),
          ),
        ],
      ),
    );
  }
}

// ── Controls ─────────────────────────────────────────────────────────────────
class _Controls extends StatelessWidget {
  final TimerModel m;
  const _Controls(this.m);

  @override
  Widget build(BuildContext context) {
    final mc = C.mc(m.isFocus);
    final md = C.md(m.isFocus);
    final label = !m.running ? 'START' : m.paused ? 'RESUME' : 'PAUSE';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip
        _Btn(
          label: 'SKIP',
          small: true,
          onTap: m.skip,
          color: C.text2,
          bg: C.bg3,
          border: C.border2,
        ),
        const SizedBox(width: 10),
        // Start/Pause/Resume (primary)
        _Btn(
          label: label,
          small: false,
          onTap: m.toggleStartStop,
          color: mc,
          bg: md,
          border: mc,
          minWidth: 120,
        ),
        const SizedBox(width: 10),
        // Reset
        _Btn(
          label: 'RESET',
          small: true,
          onTap: m.reset,
          color: C.danger,
          bg: C.bg3,
          border: C.dangerDim,
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool small;
  final VoidCallback onTap;
  final Color color, bg, border;
  final double minWidth;

  const _Btn({
    required this.label, required this.small, required this.onTap,
    required this.color, required this.bg, required this.border,
    this.minWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.symmetric(
          horizontal: small ? 14 : 20,
          vertical: small ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: exo(small ? 12.5 : 13.5, FontWeight.w600, color, spacing: 1),
        ),
      ),
    );
  }
}

// ── Options row ───────────────────────────────────────────────────────────────
class _Options extends StatelessWidget {
  final TimerModel m;
  final VoidCallback toggleSettings;
  const _Options(this.m, this.toggleSettings);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Toggle(label: 'Auto-start next session', value: m.autoStart,
            onChanged: m.setAutoStart, isFocus: m.isFocus),
        const SizedBox(height: 8),
        _Toggle(label: 'Sound enabled', value: m.soundEnabled,
            onChanged: (_) => m.toggleSound(), isFocus: m.isFocus),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(m.volume < 0.01 ? Icons.volume_off : Icons.volume_up,
                color: C.text3, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: SliderComponentShape.noOverlay,
                  activeTrackColor: C.mc(m.isFocus),
                  inactiveTrackColor: C.ring,
                  thumbColor: C.mc(m.isFocus),
                ),
                child: Slider(
                  value: m.volume,
                  onChanged: m.setVolume,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: toggleSettings,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: C.border2),
              borderRadius: BorderRadius.circular(8),
              color: C.bg3,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune, color: C.text2, size: 15),
                const SizedBox(width: 6),
                Text('CUSTOMIZE', style: exo(12, FontWeight.w600, C.text2, spacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFocus;

  const _Toggle({
    required this.label, required this.value,
    required this.onChanged, required this.isFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: exo(12, FontWeight.w400, C.text2)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: C.mc(isFocus),
          activeTrackColor: C.md(isFocus),
          inactiveThumbColor: C.text3,
          inactiveTrackColor: C.bg3,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

// ── Shortcuts bar (desktop hint) ──────────────────────────────────────────────
class _ShortcutsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14, runSpacing: 6,
      children: const [
        _Key(kbd: 'SPACE', label: 'pause'),
        _Key(kbd: 'Ctrl+K', label: 'skip'),
        _Key(kbd: 'Ctrl+R', label: 'reset'),
        _Key(kbd: 'Ctrl+M', label: 'mute'),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  final String kbd, label;
  const _Key({required this.kbd, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: C.bg3,
            border: Border.all(color: C.border2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(kbd, style: mono(12, C.text2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: mono(12, C.text3)),
      ],
    );
  }
}
