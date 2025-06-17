import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home_top_widget.dart';
import 'weather_detail_sheet.dart';
// import 'city_weather_preview_page.dart'; // jika sudah ada

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Cuaca',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFFCFAF6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          background: const Color(0xFFFCFAF6),
          onBackground: const Color(0xFF232B3E),
          primary: const Color(0xFF232B3E),
          onPrimary: const Color(0xFF232B3E),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF232B3E)),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF232B3E)),
          bodyLarge: TextStyle(color: Color(0xFF232B3E)),
          bodySmall: TextStyle(color: Color(0xFF232B3E)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFF232B3E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/city-weather': (context) =>
            const Placeholder(), // Ganti dengan CityWeatherPreviewPage jika ada
      },
      home: WeatherHomePage(
        onToggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

/// Tambahan widget pembungkus `WeatherHome`
class WeatherHomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const WeatherHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherHome(), // dari file awalmu
      // floatingActionButton: FloatingActionButton(
      //   onPressed: onToggleTheme,
      //   child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
      // ),
    );
  }
}

/// Widget utama (dari file pertama)
class WeatherHome extends StatelessWidget {
  const WeatherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B263B),
                ],
              ),
            ),
          ),
          // Cuaca sekarang
          const HomeTopWidget(),

          // Bottom Sheet cuaca detail
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return WeatherDetailSheet(scrollController: scrollController);
            },
          ),
        ],
      ),
    );
  }
}
