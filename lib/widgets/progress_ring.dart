import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final bool isFocus;
  final String timeStr;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.isFocus,
    required this.timeStr,
    this.size = 230,
  });

  @override
  Widget build(BuildContext context) {
    final scale = size / 230;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress, isFocus: isFocus),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeStr, style: orbitron(40 * scale, FontWeight.w700, C.text)),
              const SizedBox(height: 4),
              Text('REMAINING', style: mono(11 * scale, C.text3)),
              const SizedBox(height: 6),
              Text(
                isFocus ? 'FOCUS SESSION' : 'BREAK TIME',
                style: orbitron(9 * scale, FontWeight.w700, C.mc(isFocus)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isFocus;

  const _RingPainter({required this.progress, required this.isFocus});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 20) / 2;
    final strokeW = size.width * (12.0 / 230.0);
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawCircle(
      Offset(cx, cy), radius,
      Paint()
        ..color = C.ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Progress arc
    if (progress > 0) {
      final mc = C.mc(isFocus);
      canvas.drawArc(
        rect,
        -pi / 2,
        -2 * pi * (1 - progress),
        false,
        Paint()
          ..color = mc
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isFocus != isFocus;
}
