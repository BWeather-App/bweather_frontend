// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_cuaca/route.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
// // import 'dart:ui';

// class WeatherHomePage extends StatefulWidget {
//   final VoidCallback onToggleTheme;
//   final bool isDarkMode;

//   const WeatherHomePage({
//     super.key,
//     required this.onToggleTheme,
//     required this.isDarkMode,
//   });

//   @override
//   State<WeatherHomePage> createState() => _WeatherHomePageState();
// }

// class _WeatherHomePageState extends State<WeatherHomePage> {
//   late Box _weatherBox;
//   late FavoriteService _favoriteService;

//   List<Map<String, String>> _favoriteCities = [];
//   List<Map<String, dynamic>> _favoriteWeathers = [];

//   @override
//   void initState() {
//     super.initState();
//     _initHiveAndLoadFavorites();
//     WeatherModel.loadWeatherData(context);
//   }

//   Future<void> _initHiveAndLoadFavorites() async {
//     if (!Hive.isBoxOpen('weatherBox')) {
//       final dir = await path_provider.getApplicationDocumentsDirectory();
//       Hive.init(dir.path);
//       _weatherBox = await Hive.openBox('weatherBox');
//     } else {
//       _weatherBox = Hive.box('weatherBox');
//     }

//     // Inisialisasi instance FavoriteService dengan box yang sudah dibuka
//     _favoriteService = FavoriteService();

//     final saved = _weatherBox.get('favorites', defaultValue: []);

//     if (saved is List) {
//       final favorites = List<Map<String, String>>.from(
//         saved.map((e) => Map<String, String>.from(e)),
//       );

//       setState(() {
//         _favoriteCities = favorites;
//       });

//       if (_favoriteCities.isNotEmpty) {
//         await _loadFavoriteWeatherData();
//       }
//     }
//   }

//   Future<void> _loadFavoriteWeatherData() async {
//     final weathers = await _favoriteService.loadFavoriteWeather();
//     setState(() {
//       _favoriteWeathers = weathers;
//     });
//   }

//   String formatTimeFromString(String? t) {
//     if (t == null) return '-';
//     final dt = DateTime.tryParse(t);
//     return dt != null ? DateFormat.Hm().format(dt) : '-';
//   }

//   String formatTimeFromTimestamp(int timestamp) {
//     final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     return DateFormat.Hm().format(dt);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLight = Theme.of(context).brightness == Brightness.light;
//     final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
//     final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: ValueListenableBuilder<bool>(
//           valueListenable: WeatherModel.isLoading,
//           builder: (context, isLoading, _) {
//             return ValueListenableBuilder<Map<String, dynamic>?>(
//               valueListenable: WeatherModel.weatherData,
//               builder: (context, weatherData, _) {
//                 final rawWeather = weatherData?['weather'];
//                 final weather =
//                     (rawWeather is Map && rawWeather['cuaca_saat_ini'] is Map)
//                         ? Map<String, dynamic>.from(
//                           rawWeather['cuaca_saat_ini'],
//                         )
//                         : <String, dynamic>{};

//                 final forecastList = <Map<String, dynamic>>[];

//                 if (rawWeather is Map) {
//                   final keys = [
//                     'kemarin',
//                     'hari_ini',
//                     'besok',
//                     'lusa',
//                     'hari_ke_3',
//                   ];
//                   for (final key in keys) {
//                     final item = rawWeather[key];
//                     if (item is Map) {
//                       forecastList.add(Map<String, dynamic>.from(item));
//                     }
//                   }
//                 }

//                 // final current = weatherData?['weather'];
//                 // final lat = weatherData?['location']?['lat'];
//                 // final lon = weatherData?['location']?['lon'];

//                 // final description = WeatherModel.getWeatherDescription(weather);

//                 // final mainCondition = weather['main'] ?? description;

//                 return Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     WeatherHeader(
//                       location: weatherData?['location'],
//                       isLight: isLight,
//                       onAddCity: () async {
//                         final result = await showGeneralDialog<String>(
//                           context: context,
//                           barrierDismissible: true,
//                           barrierLabel: "Search",
//                           barrierColor: Colors.transparent,
//                           pageBuilder: (_, __, ___) => const SearchCityPage(),
//                           transitionBuilder: (context, animation, __, child) {
//                             return FadeTransition(
//                               opacity: animation,
//                               child: child,
//                             );
//                           },
//                           transitionDuration: const Duration(milliseconds: 200),
//                         );

//                         if (result != null && result.isNotEmpty) {
//                           print("Kota dipilih: $result");
//                         }
//                       },
//                       onToggleTheme: widget.onToggleTheme,
//                     ),
//                     Expanded(
//                       child: PageView.builder(
//                         itemCount:
//                             1 + _favoriteWeathers.length, // 1 = data utama
//                         itemBuilder: (context, index) {
//                           final isMain = index == 0;
//                           final data =
//                               isMain
//                                   ? weatherData
//                                   : _favoriteWeathers[index - 1];
//                           final weatherRoot = data?['weather'];
//                           final weather =
//                               (weatherRoot is Map &&
//                                       weatherRoot['cuaca_saat_ini'] is Map)
//                                   ? Map<String, dynamic>.from(
//                                     weatherRoot['cuaca_saat_ini'],
//                                   )
//                                   : <String, dynamic>{};

//                           if (data == null) {
//                             return const Center(
//                               child: Text("Gagal memuat data."),
//                             );
//                           }

//                           // final weather = data['weather'] ?? {};
//                           final mainCondition = weather['cuaca'];
//                           // final current = data['current'];
//                           // final forecastList = data['forecast'];
//                           final currentRaw = data['current'];
//                           final current =
//                               (currentRaw is Map)
//                                   ? Map<String, dynamic>.from(currentRaw)
//                                   : <String, dynamic>{};

//                           final forecastList = List<Map<String, dynamic>>.from(
//                             data['forecast'] ?? [],
//                           );

//                           return Stack(
//                             children: [
//                               Center(
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     if (mainCondition != null) ...[
//                                       Image.asset(
//                                         WeatherModel.getIconAsset(
//                                           mainCondition,
//                                           !isLight,
//                                         ),
//                                         width: 80,
//                                         height: 70,
//                                       ),
//                                       const SizedBox(height: 10),
//                                     ],
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "${(weather['suhu'] is num ? weather['suhu'] : 0).round()}",
//                                           style: TextStyle(
//                                             color: textColor,
//                                             fontSize: 80,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                             top: 12,
//                                           ),
//                                           child: Text(
//                                             "°C",
//                                             style: TextStyle(
//                                               color: textColor,
//                                               fontSize: 22,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       WeatherModel.getWeatherDescription(
//                                         weather,
//                                       ),
//                                       style: TextStyle(
//                                         color: textColor,
//                                         fontSize: 18,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     const SizedBox(height: 20),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.air,
//                                           color: textColor,
//                                           size: 24,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           "Angin",
//                                           style: TextStyle(color: textColor),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           "${weather['kecepatan_angin'] ?? '-'} m/s",
//                                           style: TextStyle(color: textColor),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               DraggableScrollableSheet(
//                                 initialChildSize: 0.25,
//                                 minChildSize: 0.25,
//                                 maxChildSize: 1.0,
//                                 builder: (context, scrollController) {
//                                   return WeatherDetailSheet(
//                                     scrollController: scrollController,
//                                     forecastList: forecastList,
//                                     current: current,
//                                     isLight: isLight,
//                                     cardColor: cardColor,
//                                     getWeatherDescription:
//                                         WeatherModel.getWeatherDescription,
//                                     formatTime: formatTimeFromTimestamp,
//                                     getIconAsset: WeatherModel.getIconAsset,
//                                     lat: data['lat'],
//                                     lon: data['lon'],
//                                   );
//                                 },
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
