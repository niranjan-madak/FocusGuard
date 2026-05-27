import 'package:flutter/material.dart';
import '../theme.dart';

class TimelineDots extends StatelessWidget {
  final List<String> history;
  final bool running;
  final bool isFocus;

  const TimelineDots({
    super.key,
    required this.history,
    required this.running,
    required this.isFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TIMELINE', style: mono(12, C.text3)),
        const SizedBox(height: 7),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            ...history.map((h) => _Dot(
              color: h == 'focus' ? C.focus : C.brk,
              pulse: false,
            )),
            if (running) _Dot(color: C.mc(isFocus), pulse: true),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _Dot({required this.color, required this.pulse});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: 26, height: 7,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: widget.pulse ? 1.0 : 0.65),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: widget.color.withValues(alpha: 0.8)),
      ),
    );

    if (!widget.pulse) return dot;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: 0.4 + 0.6 * _ctrl.value,
        child: child,
      ),
      child: dot,
    );
  }
}
