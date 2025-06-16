import 'package:flutter/material.dart';
import 'dart:ui';
import 'weekly_forecast.dart';

class WeatherDetailSheet extends StatelessWidget {
  final ScrollController scrollController;

  const WeatherDetailSheet({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: const BorderRadius.vertical(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          // decoration: BoxDecoration(
          //   color: Colors.white.withOpacity(0.1), // transparan + blur
          //   borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          //   border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
          // ),
          child: ListView(
            controller: scrollController,
            children: const [
              Center(
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white70),
              ),
              SizedBox(height: 16),
              // tambahkan WeeklyForecast atau konten lain di sini
              WeeklyForecast(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
