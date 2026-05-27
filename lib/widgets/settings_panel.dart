import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class SettingsPanel extends StatefulWidget {
  final int focusMins;
  final int breakMins;
  final void Function({required int focusM, required int breakM}) onApply;

  const SettingsPanel({
    super.key,
    required this.focusMins,
    required this.breakMins,
    required this.onApply,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late final TextEditingController _focusCtrl;
  late final TextEditingController _breakCtrl;

  @override
  void initState() {
    super.initState();
    _focusCtrl = TextEditingController(text: '${widget.focusMins}');
    _breakCtrl = TextEditingController(text: '${widget.breakMins}');
  }

  @override
  void dispose() {
    _focusCtrl.dispose(); _breakCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final fd = (int.tryParse(_focusCtrl.text) ?? 75).clamp(1, 240);
    final bd = (int.tryParse(_breakCtrl.text) ?? 20).clamp(1, 120);
    // Reflect the clamped value back so the user sees what was applied.
    _focusCtrl.text = '$fd';
    _breakCtrl.text = '$bd';
    widget.onApply(focusM: fd, breakM: bd);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.bg3,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SETTINGS', style: orbitron(10, FontWeight.w400, C.text3)),
          const SizedBox(height: 12),
          _Row(label: 'Focus Duration', ctrl: _focusCtrl, unit: 'min', range: '1 – 240'),
          const SizedBox(height: 10),
          _Row(label: 'Break Duration', ctrl: _breakCtrl, unit: 'min', range: '1 – 120'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _apply,
              style: TextButton.styleFrom(
                backgroundColor: C.focDim,
                foregroundColor: C.focus,
                side: const BorderSide(color: C.focus),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: exo(13, FontWeight.w600, C.focus, spacing: 1.5).let(
                (s) => Text('APPLY & RESET', style: s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String unit;
  final String range;

  const _Row({required this.label, required this.ctrl, required this.unit, required this.range});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: exo(12.5, FontWeight.w400, C.text2))),
        SizedBox(
          width: 68,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: orbitron(13, FontWeight.w400, C.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: C.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              helperText: range,
              helperStyle: orbitron(9, FontWeight.w400, C.text3),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: C.border2),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: C.focus),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(unit, style: mono(11, C.text3)),
      ],
    );
  }
}

// tiny extension so we can .let() to avoid extra variables
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
