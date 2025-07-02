// Expanded(
                    //   child: PageView.builder(
                    //     itemCount:
                    //         1 +
                    //         favoriteWeatherList
                    //             .length, // 1 lokasi saat ini + max 3 favorite
                    //     itemBuilder: (context, index) {
                    //       if (index == 0) {
                    //         Stack(
                    //           children: [
                    //             if (!isLoading && weatherData != null)
                    //               Center(
                    //                 child: Column(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   children: [
                    //                     if (mainCondition != null) ...[
                    //                       Image.asset(
                    //                         WeatherModel.getIconAsset(
                    //                           mainCondition,
                    //                           !isLight,
                    //                         ),
                    //                         width: 80,
                    //                         height: 70,
                    //                       ),
                    //                       const SizedBox(height: 10),
                    //                     ],
                    //                     Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.start,
                    //                       children: [
                    //                         const SizedBox(height: 10),
                    //                         Text(
                    //                           "${(weather['suhu'] ?? 0).round()}",
                    //                           style: TextStyle(
                    //                             color: textColor,
                    //                             fontSize: 80,
                    //                             fontWeight: FontWeight.bold,
                    //                           ),
                    //                         ),
                    //                         Padding(
                    //                           padding: const EdgeInsets.only(
                    //                             top: 12,
                    //                           ),
                    //                           child: Text(
                    //                             "°C",
                    //                             style: TextStyle(
                    //                               color: textColor,
                    //                               fontSize: 22,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                     const SizedBox(height: 8),
                    //                     Text(
                    //                       WeatherModel.getWeatherDescription(
                    //                         weather,
                    //                       ),
                    //                       style: TextStyle(
                    //                         color: textColor,
                    //                         fontSize: 18,
                    //                       ),
                    //                       textAlign: TextAlign.center,
                    //                     ),
                    //                     const SizedBox(height: 20),
                    //                     Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         Icon(
                    //                           Icons.air,
                    //                           color: textColor,
                    //                           size: 24,
                    //                         ),
                    //                         const SizedBox(width: 8),
                    //                         Text(
                    //                           "Angin",
                    //                           style: TextStyle(
                    //                             color: textColor,
                    //                           ),
                    //                         ),
                    //                         const SizedBox(width: 8),
                    //                         Text(
                    //                           "${weather['kecepatan_angin'] ?? '-'} m/s",
                    //                           style: TextStyle(
                    //                             color: textColor,
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),

                    //             if (isLoading)
                    //               const Center(
                    //                 child: CircularProgressIndicator(),
                    //               ),

                    //             if (!isLoading && weatherData == null)
                    //               Center(
                    //                 child: Text(
                    //                   "Gagal memuat data cuaca.",
                    //                   style: TextStyle(color: textColor),
                    //                 ),
                    //               ),

                    //             if (!isLoading && weatherData != null)
                    //               DraggableScrollableSheet(
                    //                 initialChildSize: 0.25,
                    //                 minChildSize: 0.25,
                    //                 maxChildSize: 1.0,
                    //                 builder: (context, scrollController) {
                    //                   return WeatherDetailSheet(
                    //                     scrollController: scrollController,
                    //                     forecastList: forecastList,
                    //                     current: current ?? {},
                    //                     isLight: isLight,
                    //                     cardColor: cardColor,
                    //                     getWeatherDescription:
                    //                         WeatherModel.getWeatherDescription,
                    //                     formatTime: formatTimeFromTimestamp,
                    //                     getIconAsset:
                    //                         (condition, isDark) =>
                    //                             WeatherModel.getIconAsset(
                    //                               condition,
                    //                               isDark,
                    //                             ),
                    //                     lat: lat,
                    //                     lon: lon,
                    //                   );
                    //                 },
                    //               ),
                    //           ],
                    //         );
                    //       } else {
                    //         final cityWeather = favoriteWeatherList[index - 1];
                    //         return buildFavoriteWeatherView(
                    //           cityWeather,
                    //         ); // Kota favorit ke-(index)
                    //       }
                    //     },
                    //   ),
                    // ),