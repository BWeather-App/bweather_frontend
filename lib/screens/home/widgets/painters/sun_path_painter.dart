// lib/screens/home/widgets/painters/sun_path_painter.dart
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'dart:ui' as ui;

class SunPathPainter extends CustomPainter {
  final String sunrise;
  final String sunset;
  final bool isDark;

  const SunPathPainter({
    required this.sunrise,
    required this.sunset,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final arcColor = AppColors.sunPathArc_static(isDark);
    final sunColor = AppColors.sunIcon(isDark);

    // ── Layout zones ──────────────────────────────────────────────────────
    // horizonY: garis tengah, kurva melintasinya di kiri dan kanan
    final horizonY = size.height * 0.54;
    // Puncak kurva: lebih tinggi agar busur terlihat tinggi seperti Figma
    final peakY = size.height * 0.06;
    // Titik keluar kurva di kiri & kanan canvas (sedikit di luar viewport)
    final exitBelowY = horizonY + size.height * 0.28;
    final leftExitX = -size.width * 0.06;
    final rightExitX = size.width * 1.06;

    // ── Titik-titik kunci kurva ───────────────────────────────────────────
    // P0: kiri bawah (keluar canvas)
    // P1: titik horizon kiri  (~22% width)
    // P2: puncak (~50% width)
    // P3: titik horizon kanan (~78% width)
    // P4: kanan bawah (keluar canvas)
    final p0 = Offset(leftExitX, exitBelowY);
    final p1 = Offset(size.width * 0.22, horizonY);
    final p2 = Offset(size.width * 0.50, peakY);
    final p3 = Offset(size.width * 0.78, horizonY);
    final p4 = Offset(rightExitX, exitBelowY);

    // ── Bangun path dengan Catmull-Rom agar sambungan perfectly smooth ────
    // Catmull-Rom: control point dihitung otomatis dari 5 titik kunci,
    // hasilnya G1-continuous (tangent mulus di setiap titik sambungan).
    final fullPath = _catmullRomPath([p0, p1, p2, p3, p4]);

    // ── Clip canvas menjadi dua area: atas dan bawah horizon ─────────────
    // Area atas horizon → opacity penuh
    // Area bawah horizon → opacity rendah (seperti Figma)

    // 1. Gambar bagian ATAS horizon (clip rect atas)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, horizonY));
    canvas.drawPath(
      fullPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(leftExitX, 0),
          Offset(rightExitX, 0),
          [
            arcColor.withValues(alpha: 0.25),
            arcColor.withValues(alpha: 0.70),
            arcColor.withValues(alpha: 1.00),
            arcColor.withValues(alpha: 0.70),
            arcColor.withValues(alpha: 0.25),
          ],
          [0.0, 0.18, 0.50, 0.82, 1.0],
        )
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // 2. Gambar bagian BAWAH horizon (lebih transparan)
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
    );
    canvas.drawPath(
      fullPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(leftExitX, 0),
          Offset(rightExitX, 0),
          [
            arcColor.withValues(alpha: 0.10),
            arcColor.withValues(alpha: 0.28),
            arcColor.withValues(alpha: 0.38),
            arcColor.withValues(alpha: 0.28),
            arcColor.withValues(alpha: 0.10),
          ],
          [0.0, 0.18, 0.50, 0.82, 1.0],
        )
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // ── Garis horizon ─────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      Paint()
        ..color = arcColor.withValues(alpha: 0.30)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    // ── Posisi matahari saat ini ──────────────────────────────────────────
    final now = _currentTimeInMinutes();
    final sunriseMin = _parseTimeToMinutes(sunrise);
    final sunsetMin = _parseTimeToMinutes(sunset);

    double ratio;
    if (sunsetMin <= sunriseMin) {
      ratio = 0.5;
    } else if (now <= sunriseMin) {
      ratio = 0.0;
    } else if (now >= sunsetMin) {
      ratio = 1.0;
    } else {
      ratio = (now - sunriseMin) / (sunsetMin - sunriseMin);
    }

    // Remap ratio [0,1] → t [t_p1, t_p3] pada kurva Catmull-Rom
    // P1 (horizon kiri) ≈ t=0.25, P3 (horizon kanan) ≈ t=0.75
    final t = 0.25 + ratio * 0.50;
    final sunPos = _catmullRomPoint([p0, p1, p2, p3, p4], t);

    // Glow samar di sekitar matahari
    canvas.drawCircle(
      sunPos,
      11.0,
      Paint()
        ..color = sunColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..style = PaintingStyle.fill,
    );

    // Ring matahari (hollow circle kuning)
    canvas.drawCircle(
      sunPos,
      8.0,
      Paint()
        ..color = sunColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Catmull-Rom: buat Path dari list titik ────────────────────────────────
  // Menggunakan Catmull-Rom spline yang dikonversi ke cubic Bezier.
  // Hasilnya perfectly smooth (G1) di setiap titik sambungan.
  Path _catmullRomPath(List<Offset> pts) {
    assert(pts.length >= 2);
    final path = Path();
    path.moveTo(pts.first.dx, pts.first.dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[0] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts.last;

      // Catmull-Rom → Bezier control points (alpha = 0.5 = centripetal)
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6.0,
        p1.dy + (p2.dy - p0.dy) / 6.0,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6.0,
        p2.dy - (p3.dy - p1.dy) / 6.0,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  // ── Evaluasi posisi titik pada kurva Catmull-Rom pada parameter t [0,1] ──
  Offset _catmullRomPoint(List<Offset> pts, double t) {
    // t dibagi rata per segmen
    final n = pts.length - 1; // jumlah segmen
    final segT = t * n;
    final segIndex = segT.floor().clamp(0, n - 1);
    final localT = segT - segIndex;

    final p0 = segIndex == 0 ? pts[0] : pts[segIndex - 1];
    final p1 = pts[segIndex];
    final p2 = pts[segIndex + 1];
    final p3 = segIndex + 2 < pts.length ? pts[segIndex + 2] : pts.last;

    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6.0,
      p1.dy + (p2.dy - p0.dy) / 6.0,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6.0,
      p2.dy - (p3.dy - p1.dy) / 6.0,
    );

    // Evaluasi cubic Bezier
    final lt = localT;
    final mt = 1.0 - lt;
    return p1 * (mt * mt * mt) +
        cp1 * (3 * mt * mt * lt) +
        cp2 * (3 * mt * lt * lt) +
        p2 * (lt * lt * lt);
  }

  double _parseTimeToMinutes(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return (hour * 60 + minute).toDouble();
    } catch (_) {
      return 360.0;
    }
  }

  double _currentTimeInMinutes() {
    final now = DateTime.now();
    return (now.hour * 60 + now.minute).toDouble();
  }

  @override
  bool shouldRepaint(covariant SunPathPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.sunrise != sunrise ||
      oldDelegate.sunset != sunset;
}
