import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Simpan data dummy sekali jika belum ada
  final box = await Hive.openBox('weatherBox');
  if (box.get('mainLocation') == null) {
    await box.put('mainLocation', {
      'name': 'Jakarta',
      'temp': 31,
      'desc': 'Cerah Berawan',
      'icon': Icons.wb_sunny.codePoint,
      'wind': 3.2,
    });
  }

  if (box.get('favoriteCities') == null) {
    await box.put('favoriteCities', [
      {
        'name': 'Surabaya',
        'temp': 29,
        'desc': 'Berawan',
        'icon': Icons.cloud.codePoint,
        'wind': 2.7,
      },
      {
        'name': 'Bandung',
        'temp': 24,
        'desc': 'Hujan Ringan',
        'icon': Icons.beach_access.codePoint,
        'wind': 3.8,
      },
      {
        'name': 'Yogyakarta',
        'temp': 27,
        'desc': 'Sebagian Cerah',
        'icon': Icons.cloud_queue.codePoint,
        'wind': 3.0,
      },
    ]);
  }

  runApp(const MaterialApp(
    home: WeatherHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations() async {
    final box = Hive.box('weatherBox');

    final main = box.get('mainLocation') as Map?;
    final favorites = box.get('favoriteCities') as List?;

    List<Map<String, dynamic>> result = [];

    if (main != null) {
      result.add(Map<String, dynamic>.from(main));
    }

    if (favorites != null && favorites.isNotEmpty) {
      final sliced =
          favorites.take(3).map((e) => Map<String, dynamic>.from(e)).toList();
      result.addAll(sliced);
    }

    setState(() {
      locations = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? Colors.black : Colors.white;
    final bgColor = isLight ? Colors.white : const Color(0xFF1B1B2F);

    return Scaffold(
      backgroundColor: bgColor,
      body: locations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                final icon = IconData(loc['icon'], fontFamily: 'MaterialIcons');
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 64, color: textColor),
                        const SizedBox(height: 16),
                        Text(
                          loc['name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc['desc'],
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${loc['temp']}°C',
                              style: TextStyle(
                                fontSize: 64,
                                color: textColor,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.thermostat, color: textColor),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.air, color: textColor),
                            const SizedBox(width: 6),
                            Text(
                              '${loc['wind']} m/s',
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}