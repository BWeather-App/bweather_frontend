// lib/screens/home/widgets/hourly_forecast_chart.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/settings_provider.dart';
import 'package:flutter_cuaca/helpers/time_helper.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class HourlyForecastChart extends StatefulWidget {
  final List? todayData;

  const HourlyForecastChart({Key? key, this.todayData}) : super(key: key);

  @override
  State<HourlyForecastChart> createState() => _HourlyForecastChartState();
}

class _HourlyForecastChartState extends State<HourlyForecastChart> {
  // Index slot yang sedang dipilih (null = slot pertama / jam terdekat)
  int? _tappedIndex;

  // ScrollController untuk chart horizontal
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todayData == null || widget.todayData!.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();

    // ── Ambil semua data 24 jam ke depan, per jam ──────────────────────────
    final slots =
        widget.todayData!
            .where((hourData) {
              final timeStr = hourData['waktu'] as String?;
              if (timeStr == null) return false;
              try {
                final time = DateTime.parse(timeStr);
                return time.isAfter(now) &&
                    time.isBefore(now.add(const Duration(hours: 24)));
              } catch (_) {
                return false;
              }
            })
            .cast<Map<String, dynamic>>()
            .toList();

    if (slots.length < 2) return const SizedBox.shrink();

    final temps =
        slots.map<double>((e) => (e['suhu']?.toDouble() ?? 25.0)).toList();

    // Reset tappedIndex jika di luar range
    if (_tappedIndex != null && _tappedIndex! >= slots.length) {
      _tappedIndex = null;
    }

    // displayIndex = yang di-tap, atau default slot pertama (jam terdekat)
    final displayIndex = _tappedIndex ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: AppColors.textSecondary(context),
              size: AppDimensions.iconSection,
            ),
            const SizedBox(width: AppDimensions.spaceXS),
            Text('Ramalan 24 Jam', style: AppTextStyles.sectionLabel(context)),
          ],
        ),
        const SizedBox(height: AppDimensions.cardPadding),

        // ── Chart scrollable ───────────────────────────────────────────────
        SizedBox(
          height: AppDimensions.chartHeight,
          child: _ScrollableChart(
            slots: slots,
            temps: temps,
            displayIndex: displayIndex,
            isDark: isDark,
            scrollController: _scrollController,
            onTap: (index) {
              setState(() {
                _tappedIndex = (_tappedIndex == index) ? null : index;
              });
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart scrollable: semua 24 slot, tampil 4 di layar, geser untuk lihat lainnya
// ─────────────────────────────────────────────────────────────────────────────
class _ScrollableChart extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final List<double> temps;
  final int displayIndex;
  final bool isDark;
  final ScrollController scrollController;
  final ValueChanged<int> onTap;

  // Lebar per slot (jarak antar titik di canvas)
  static const double _slotWidth = 80.0;
  // Padding kiri-kanan canvas total
  static const double _sidePad = 32.0;

  const _ScrollableChart({
    required this.slots,
    required this.temps,
    required this.displayIndex,
    required this.isDark,
    required this.scrollController,
    required this.onTap,
  });

  // Total lebar canvas = slot * slotWidth + padding kiri & kanan
  double get _totalWidth => (slots.length - 1) * _slotWidth + _sidePad * 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewWidth = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Auto-scroll agar displayIndex terlihat di tengah
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scrollController.hasClients) return;
          final targetX = _sidePad + displayIndex * _slotWidth - viewWidth / 2;
          final maxScroll = scrollController.position.maxScrollExtent;
          final clampedX = targetX.clamp(0.0, maxScroll);
          scrollController.animateTo(
            clampedX,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });

        return SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final tapX = details.localPosition.dx;
              final tapY = details.localPosition.dy;

              // Cari slot terdekat berdasarkan posisi x tap
              int nearest = 0;
              double minDist = double.infinity;
              for (int i = 0; i < slots.length; i++) {
                final slotX = _sidePad + i * _slotWidth;
                final slotY = _getYForIndex(i, h);
                final dist = math.sqrt(
                  math.pow(tapX - slotX, 2) + math.pow(tapY - slotY, 2),
                );
                if (dist < minDist) {
                  minDist = dist;
                  nearest = i;
                }
              }
              onTap(nearest);
            },
            child: SizedBox(
              width: _totalWidth,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Kurva + titik + garis putus
                  CustomPaint(
                    size: Size(_totalWidth, h),
                    painter: _ChartPainter(
                      slots: slots,
                      temps: temps,
                      displayIndex: displayIndex,
                      isDark: isDark,
                      slotWidth: _slotWidth,
                      sidePad: _sidePad,
                    ),
                  ),
                  // Label suhu di atas titik aktif
                  _buildTempLabel(context, h),
                  // Label waktu di bawah setiap slot
                  ..._buildTimeLabels(context, h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hitung Y untuk slot ke-i (sama dengan painter) — margin kecil agar gelombang dramatis
  double _getYForIndex(int i, double h) {
    const topPad = 52.0;
    const bottomPad = 28.0;
    final minRaw = temps.reduce(math.min);
    final maxRaw = temps.reduce(math.max);
    final range = maxRaw - minRaw;
    final margin = range < 2.0 ? 0.3 : 0.2;
    final minT = minRaw - margin;
    final maxT = maxRaw + margin;
    final usable = h - topPad - bottomPad;
    if (maxT == minT) return topPad + usable / 2;
    return topPad + usable * (1 - (temps[i] - minT) / (maxT - minT));
  }

  Widget _buildTempLabel(BuildContext context, double h) {
    final settings = context.watch<SettingsProvider>();
    final x = _sidePad + displayIndex * _slotWidth;
    final y = _getYForIndex(displayIndex, h);
    final temp = settings.convertTemp(temps[displayIndex]).round();

    return Positioned(
      left: x - 44,
      top: y - 58,
      width: 88,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$temp',
              style: AppTextStyles.windSpeed(context).copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            TextSpan(
              text: settings.unitSymbol,
              style: AppTextStyles.windUnit(
                context,
              ).copyWith(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeLabels(BuildContext context, double h) {
    return List.generate(slots.length, (i) {
      final x = _sidePad + i * _slotWidth;
      final isDisplay = i == displayIndex;
      final timeStr = TimeHelper.formatFromString(slots[i]['waktu']);

      return Positioned(
        bottom: 0,
        left: x - 30,
        width: 60,
        child: Text(
          timeStr,
          textAlign: TextAlign.center,
          style: AppTextStyles.chartAxisLabel(context).copyWith(
            color:
                isDisplay
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
            fontWeight: isDisplay ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter: kurva smooth + titik per jam + garis putus-putus
// ─────────────────────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> slots;
  final List<double> temps;
  final int displayIndex;
  final bool isDark;
  final double slotWidth;
  final double sidePad;

  static const double _topPad = 52.0;
  static const double _bottomPad = 28.0;

  const _ChartPainter({
    required this.slots,
    required this.temps,
    required this.displayIndex,
    required this.isDark,
    required this.slotWidth,
    required this.sidePad,
  });

  // Gunakan margin kecil agar perbedaan suhu kecil sekalipun
  // terlihat dramatis di canvas (amplitudo gelombang lebih besar).
  // Minimum range 2° agar tidak flat total jika semua suhu sama.
  double get _minTemp {
    final min = temps.reduce(math.min);
    final max = temps.reduce(math.max);
    final range = max - min;
    // Jika range kecil, beri sedikit margin ekstra di bawah
    final margin = range < 2.0 ? 0.3 : 0.2;
    return min - margin;
  }

  double get _maxTemp {
    final min = temps.reduce(math.min);
    final max = temps.reduce(math.max);
    final range = max - min;
    final margin = range < 2.0 ? 0.3 : 0.2;
    return max + margin;
  }

  double _getX(int index) => sidePad + index * slotWidth;

  double _getY(double temp, double height) {
    final usable = height - _topPad - _bottomPad;
    final minT = _minTemp;
    final maxT = _maxTemp;
    if (maxT == minT) return _topPad + usable / 2;
    return _topPad + usable * (1 - (temp - minT) / (maxT - minT));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final points = List.generate(
      slots.length,
      (i) => Offset(_getX(i), _getY(temps[i], size.height)),
    );

    final displayPoint = points[displayIndex];
    final displayX = displayPoint.dx;
    final totalW = size.width;

    final curveColor = isDark ? Colors.white : AppColors.darkBackground;
    final dotColor = isDark ? Colors.white70 : AppColors.darkBackground;

    // ── Kurva smooth (Catmull-Rom → Bezier) ──────────────────────────────
    final curvePath = _buildSmoothPath(points);

    canvas.drawPath(
      curvePath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, size.height / 2),
          Offset(totalW, size.height / 2),
          [
            curveColor.withValues(alpha: 0.30),
            curveColor.withValues(alpha: 0.55),
            curveColor.withValues(alpha: 0.90),
            curveColor,
          ],
          [
            0.0,
            (displayX / totalW * 0.6).clamp(0.0, 0.6),
            (displayX / totalW).clamp(0.0, 1.0),
            1.0,
          ],
        )
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Titik kecil di setiap jam ─────────────────────────────────────────
    for (int i = 0; i < points.length; i++) {
      if (i == displayIndex) continue;
      canvas.drawCircle(
        points[i],
        2.8,
        Paint()
          ..color = dotColor.withValues(alpha: i < displayIndex ? 0.35 : 0.55)
          ..style = PaintingStyle.fill,
      );
    }

    // ── Garis putus-putus vertikal dari titik aktif ke label bawah ────────
    _drawDashedLine(
      canvas,
      displayPoint,
      Offset(displayPoint.dx, size.height - _bottomPad + 4),
      Paint()
        ..color = curveColor.withValues(alpha: 0.50)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // ── Titik aktif: hollow circle ────────────────────────────────────────
    canvas.drawCircle(
      displayPoint,
      6.5,
      Paint()
        ..color = curveColor.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      displayPoint,
      6.5,
      Paint()
        ..color = curveColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    if (points.length == 1) {
      path.moveTo(points[0].dx, points[0].dy);
      return path;
    }
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[0] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      const alpha = 0.5;
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * alpha / 3,
        p1.dy + (p2.dy - p0.dy) * alpha / 3,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * alpha / 3,
        p2.dy - (p3.dy - p1.dy) * alpha / 3,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashLength = 4.0;
    const dashSpace = 4.0;
    final dir = to - from;
    final total = dir.distance;
    if (total == 0) return;
    final unit = dir / total;
    double drawn = 0.0;
    bool drawing = true;
    Offset cur = from;
    while (drawn < total) {
      final seg = drawing ? dashLength : dashSpace;
      final end = (drawn + seg).clamp(0.0, total);
      final endPt = from + unit * end;
      if (drawing) canvas.drawLine(cur, endPt, paint);
      drawn = end;
      cur = endPt;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.displayIndex != displayIndex ||
      old.isDark != isDark ||
      old.temps != temps;
}
