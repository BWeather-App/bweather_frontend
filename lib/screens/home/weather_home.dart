import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/providers/weather_provider.dart';
import 'package:flutter_cuaca/providers/favorite_provider.dart';
import 'package:flutter_cuaca/screens/search/search_city.dart';
import 'package:flutter_cuaca/widgets/error_view.dart';

import 'widgets/weather_header.dart';
import 'widgets/weather_detail_sheet.dart';
import 'widgets/weather_main_view.dart';
import 'widgets/favorite_weather_view.dart';

class WeatherHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const WeatherHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  // Hanya UI state yang boleh ada di sini
  int _currentPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load data setelah frame pertama selesai render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeatherData();
      context.read<FavoriteProvider>().loadFavoriteWeatherData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  Map<String, dynamic>? _getCurrentLocation() {
    final weatherProvider = context.read<WeatherProvider>();
    final favoriteProvider = context.read<FavoriteProvider>();

    if (_currentPageIndex == 0) {
      return weatherProvider.location;
    }

    final favoriteIndex = _currentPageIndex - 1;
    final cityWeather = favoriteProvider.getFavoriteAt(favoriteIndex);
    if (cityWeather == null) return null;

    final cityInfo = cityWeather['city_info'] ?? {};
    final location = cityWeather['location'] ?? {};

    return {
      'city': cityInfo['name'] ?? cityInfo['full'],
      'region': location['region'] ?? '',
      'country': location['country'] ?? '',
    };
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ watch — rebuild otomatis saat state berubah
    final weatherProvider = context.watch<WeatherProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final weather = context.read<WeatherProvider>();
            final favorite = context.read<FavoriteProvider>();
            // ignore: use_build_context_synchronously
            await Future.wait([weather.refresh(), favorite.loadFavoriteWeatherData()]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──────────────────────────────────────
                  WeatherHeader(
                    location: _getCurrentLocation(),
                    isLight: !widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                    onAddCity: _onAddCity,
                  ),

                  // ── PageView ─────────────────────────────────────
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        AppDimensions.pageViewHeightFactor,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: favoriteProvider.totalPages,
                      onPageChanged: (index) {
                        setState(() => _currentPageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildGpsPage(weatherProvider);
                        }
                        return _buildFavoritePage(favoriteProvider, index - 1);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Halaman 0: Cuaca GPS
  // ─────────────────────────────────────────────

  Widget _buildGpsPage(WeatherProvider provider) {
    // Loading
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (provider.hasError) {
      return ErrorView(
        message: provider.errorMessage,
        onRetry: () => context.read<WeatherProvider>().refresh(),
      );
    }

    // Success
    return Stack(
      children: [
        // Tampilan suhu & kondisi utama
        WeatherMainView(
          weather: provider.current ?? {},
          isDarkMode: widget.isDarkMode,
        ),

        // Detail sheet (draggable)
        DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.25,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return WeatherDetailSheet(
              scrollController: scrollController,
              weatherData: provider.weatherData,
              isLight: !widget.isDarkMode,
              cardColor: AppColors.cardBackgroundHome(context),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Halaman 1+: Kota Favorit
  // ─────────────────────────────────────────────

  Widget _buildFavoritePage(FavoriteProvider provider, int favoriteIndex) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cityWeather = provider.getFavoriteAt(favoriteIndex);
    if (cityWeather == null) {
      return Center(
        child: Text(
          'Data tidak tersedia',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
      );
    }

    return FavoriteWeatherView(
      cityWeather: cityWeather,
      isDarkMode: widget.isDarkMode,
    );
  }

  // ─────────────────────────────────────────────
  // Add City — buka SearchCityPage
  // ─────────────────────────────────────────────

  Future<void> _onAddCity() async {
    await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => const SearchCityPage(),
      transitionBuilder: (context, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );

    if (mounted) {
      context.read<FavoriteProvider>().loadFavoriteWeatherData();
    }
  }
}
