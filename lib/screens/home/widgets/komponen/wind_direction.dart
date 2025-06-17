import 'package:flutter/material.dart';
// import 'package:flutter_cuaca/route.dart';
import 'dart:math' as math;

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw compass directions
    final directions = ['U', 'T', 'S', 'B'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + (radius - 15) * math.cos(angle - math.pi / 2);
      final y = center.dy + (radius - 15) * math.sin(angle - math.pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw wind direction indicator (pointing West)
    final windPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final windAngle = 270 * math.pi / 180; // West
    final windX = center.dx + (radius - 25) * math.cos(windAngle - math.pi / 2);
    final windY = center.dy + (radius - 25) * math.sin(windAngle - math.pi / 2);

    canvas.drawLine(center, Offset(windX, windY), windPaint);

    // Draw arrow head
    final arrowPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(windX, windY), 3, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
