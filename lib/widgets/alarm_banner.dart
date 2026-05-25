import 'package:flutter/material.dart';
import '../theme.dart';

class AlarmBanner extends StatelessWidget {
  final bool isFocus;
  final int focusMins;
  final int breakMins;
  final VoidCallback onDismiss;

  const AlarmBanner({
    super.key,
    required this.isFocus,
    required this.focusMins,
    required this.breakMins,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final mc = C.mc(isFocus);
    final md = C.md(isFocus);
    final icon = isFocus ? '⚡' : '🌿';
    final msg  = isFocus
        ? 'Break over! Focus for $focusMins minutes.'
        : 'Session done! Rest for $breakMins minutes.';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: md,
        border: Border.all(color: mc),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(color: mc, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Text('✕', style: TextStyle(color: mc, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
