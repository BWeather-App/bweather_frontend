import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SunPathWithIndicator extends StatelessWidget {
  final double sunPositionX;

  const SunPathWithIndicator({super.key, required this.sunPositionX});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final sunX = sunPositionX.clamp(0.0, 1.0);
          final sunY = -4 * (sunX - 0.5) * (sunX - 0.5) + 1;

          final left = sunX * width;
          final top = (1 - sunY) * height;

          return Stack(
            children: [
              const SunPathChart(),
              Positioned(
                top: height * 0.5,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: -5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: left - 8,
                top: top - 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFFDCB700),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SunPathChart extends StatelessWidget {
  const SunPathChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 1,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _generateSunPath(),
            isCurved: true,
            barWidth: 4,
            color: Colors.white,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  List<FlSpot> _generateSunPath() {
    return List.generate(21, (i) {
      final x = i / 20.0;
      final y = -4 * pow(x - 0.5, 2).toDouble() + 1;
      return FlSpot(x, y);
    });
  }
}