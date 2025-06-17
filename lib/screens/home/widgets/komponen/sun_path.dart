// import 'dart:math';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SunPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Draw sun path arc
    path.moveTo(0, height * 0.8);
    path.quadraticBezierTo(width / 2, height * 0.2, width, height * 0.8);
    
    canvas.drawPath(path, paint);

    // Draw sun position
    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(width * 0.6, height * 0.4),
      6,
      sunPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}