import 'package:flutter/material.dart';
import '../theme.dart';

class StatsBar extends StatelessWidget {
  final int sessions;
  final String focusTime;
  final int cycles;
  final bool isFocus;

  const StatsBar({
    super.key,
    required this.sessions,
    required this.focusTime,
    required this.cycles,
    required this.isFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _Stat(value: '$sessions',  label: 'DONE',    isFocus: isFocus),
          Container(width: 1, height: 48, color: C.border),
          _Stat(value: focusTime,    label: 'FOCUSED',  isFocus: isFocus),
          Container(width: 1, height: 48, color: C.border),
          _Stat(value: '$cycles',   label: 'CYCLES',   isFocus: isFocus),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool isFocus;

  const _Stat({required this.value, required this.label, required this.isFocus});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: C.bg3,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: orbitron(20, FontWeight.w700, C.mc(isFocus))),
            const SizedBox(height: 3),
            Text(label, style: mono(12, C.text3)),
          ],
        ),
      ),
    );
  }
}
