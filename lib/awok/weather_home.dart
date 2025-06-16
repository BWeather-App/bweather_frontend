// weather_home.dart

import 'package:flutter/material.dart';
import 'home_top_widget.dart';
import 'weather_detail_sheet.dart';
// import 'dart:ui';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D1B2A), // Biru tua
                  Color(0xFF1B263B), // Lebih gelap
                ],
              ),
            ),
          ),

          // LAYER 1: Cuaca sekarang
          const HomeTopWidget(),

          // LAYER 2: Sheet bawah
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return WeatherDetailSheet(scrollController: scrollController);
            },
          ),
        ],
      ),
    );
  }
}
