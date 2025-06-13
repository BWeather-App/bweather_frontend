import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/permission_service.dart';
import 'screens/weather_home.dart';
import 'screens/city_weather_page.dart'; // sesuaikan path kalau berbeda

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermission();
    });
  }

  void _checkPermission() async {
    await PermissionService.requestLocationPermission(context);
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
      routes: {'/city-weather': (context) => const CityWeatherPage()},
      home: WeatherHomePage(onToggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}
