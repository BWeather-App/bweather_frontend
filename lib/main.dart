import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'services/favorite_service.dart';
import 'providers/weather_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home/weather_home.dart';
import 'screens/search/search_city_preview.dart';
import 'utils/restart_widget.dart';

Future<void> _mintaIzinNotifikasi() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Future.wait([
    initializeDateFormatting('id_ID', null),
    Hive.initFlutter(),
  ]);

  Intl.defaultLocale = 'id_ID';
  await Hive.openBox('weatherBox');
  await FavoriteService.init();
  await NotificationService.init();
  await _mintaIzinNotifikasi();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('theme_is_dark') ?? true;

  runApp(RestartWidget(child: MyApp(initialDarkMode: isDarkMode)));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  const MyApp({super.key, required this.initialDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialDarkMode;
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      await PermissionService.requestLocationPermission();
    });
  }

  Future<void> toggleTheme() async {
    setState(() => isDarkMode = !isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_is_dark', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // WeatherProvider — state cuaca GPS
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BWeather',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFCFAF6),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
            surface: const Color(0xFFFCFAF6),
            onSurface: const Color(0xFF232B3E),
            primary: const Color(0xFF232B3E),
            onPrimary: const Color(0xFF232B3E),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF232B3E)),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF232B3E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routes: {'/city-weather': (context) => const CityWeatherPreviewPage()},
        home: WeatherHomePage(
          onToggleTheme: toggleTheme,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }
}
