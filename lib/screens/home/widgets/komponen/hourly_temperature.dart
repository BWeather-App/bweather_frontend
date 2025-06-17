// hourly_chart_syncfusion.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HourlyData {
  final int hour;
  final double temperature;

  HourlyData(this.hour, this.temperature);
}

class HourlyTemperatureChart extends StatelessWidget {
  const HourlyTemperatureChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<HourlyData> data = [
      HourlyData(20, 21),
      HourlyData(21, 25),
      HourlyData(22, 22),
      HourlyData(23, 28),
    ];

    final currentHour = DateTime.now().hour;
    final selectedIndex = data.indexWhere((d) => d.hour == currentHour);
    final selectedData = selectedIndex != -1 ? data[selectedIndex] : data[1];

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            backgroundColor: Colors.transparent,
            primaryXAxis: NumericAxis(
              minimum: 20,
              maximum: 23,
              interval: 1,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              axisLine: const AxisLine(width: 0),
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
              minimum: 20,
              maximum: 30,
            ),
            series: <CartesianSeries>[
              // Garis latar abu-abu
              SplineSeries<HourlyData, int>(
                dataSource: data,
                xValueMapper: (d, _) => d.hour,
                yValueMapper: (d, _) => d.temperature,
                color: Colors.grey[700],
                width: 2,
                markerSettings: const MarkerSettings(isVisible: false),
              ),

              // Garis efek gradasi putih
              SplineSeries<HourlyData, int>(
                dataSource: data,
                xValueMapper: (d, _) => d.hour,
                yValueMapper: (d, _) => d.temperature,
                pointColorMapper: (d, i) {
                  if (i == 0 || i == data.length - 1)
                    return Colors.white.withOpacity(0.2);
                  if (i == 1) return Colors.white;
                  return Colors.white70;
                },
                width: 2,
                markerSettings: const MarkerSettings(isVisible: false),
              ),

              // Dot aktif di atas line
              SplineSeries<HourlyData, int>(
                dataSource: [selectedData],
                xValueMapper: (d, _) => d.hour,
                yValueMapper: (d, _) => d.temperature,
                color: Colors.transparent,
                width: 0,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  color: Color(0xFF3D404D), // ubah wwarna ini
                  borderColor: Colors.white,
                  borderWidth: 2,
                  shape: DataMarkerType.circle,
                  width: 12,
                  height: 12,
                ),
              ),
            ],
            annotations: <CartesianChartAnnotation>[
              // Temperature label
              CartesianChartAnnotation(
                widget: Text(
                  '${selectedData.temperature.toInt()}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                coordinateUnit: CoordinateUnit.point,
                region: AnnotationRegion.chart,
                x: selectedData.hour,
                y: selectedData.temperature + 1.5,
              ),
              // Vertical line (dotted)
              CartesianChartAnnotation(
                widget: Container(
                  width: 1,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.white30,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                coordinateUnit: CoordinateUnit.point,
                region: AnnotationRegion.chart,
                x: selectedData.hour,
                y: selectedData.temperature - 1.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
