import 'package:flutter/material.dart';
import '../favorite_city_helper.dart';
import '../services/weather_service.dart';
import 'dart:async';

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> filteredCities = [];
  final List<Map<String, String>> popularCities = [
    {"city": "Jakarta", "region": "Indonesia"},
    {"city": "Yogyakarta", "region": "Indonesia"},
    {"city": "Bandung", "region": "Indonesia"},
    {"city": "Surabaya", "region": "Indonesia"},
    {"city": "Denpasar", "region": "Indonesia"},
    {"city": "Balikpapan", "region": "Indonesia"},
    {"city": "Bekasi", "region": "Indonesia"},
    {"city": "Palembang", "region": "Indonesia"},
    {"city": "Jambi", "region": "Indonesia"},
    {"city": "Makassar", "region": "Indonesia"},
    {"city": "Kediri", "region": "Indonesia"},
    {"city": "Lampung", "region": "Indonesia"},
    {"city": "Batam", "region": "Indonesia"},
  ];

  Future<List<Map<String, String>>> searchCities(String query) async {
    await Future.delayed(Duration(milliseconds: 500)); // simulasi delay

    return [
      {"city": "Surabaya", "region": "Jawa Timur", "country": "Indonesia"},
      {"city": "Sukabumi", "region": "Jawa Barat", "country": "Indonesia"},
    ];
  }

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String value) async {
    if (value.isEmpty) {
      setState(() => filteredCities = []);
      return;
    }

    try {
      final results = await WeatherService().searchCities(value);
      setState(() => filteredCities = results);
    } catch (e) {
      print('Search Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    final isSearching = _controller.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cari Kota', style: TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow:
                    isLight
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearch,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Cari kota...",
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  suffixIcon:
                      _controller.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.close, color: subTextColor),
                            onPressed: () {
                              _controller.clear();
                              _onSearch('');
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // === KOTA POPULER (jika input kosong) ===
            if (!isSearching) ...[
              Text(
                "Kota Populer",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CityChip(
                    label: "Cari lokasi",
                    isLocation: true,
                    isLight: isLight,
                  ),
                  ...popularCities.map(
                    (city) => GestureDetector(
                      onTap: () {
                        _controller.text = city["city"]!;
                        _onSearch(city["city"]!);
                      },
                      child: _CityChip(label: city["city"]!, isLight: isLight),
                    ),
                  ),
                ],
              ),
            ],

            // === HASIL PENCARIAN (jika input ada) ===
            if (isSearching) ...[
              const SizedBox(height: 10),
              Expanded(
                child:
                    isSearching
                        ? (filteredCities.isEmpty
                            ? const Center(
                              child: Text("Tidak ada hasil ditemukan."),
                            )
                            : ListView.builder(
                              itemCount: filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = filteredCities[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow:
                                        isLight
                                            ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 16,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      city["city"]!,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${city["region"]}, ${city["country"] ?? "Indonesia"}',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: subTextColor,
                                      ),
                                      onPressed: () async {
                                        await FavoriteCityHelper.addFavoriteCity(
                                          city["city"]!,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${city["city"]} ditambahkan ke favorit',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ))
                        : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kota Populer",
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _CityChip(
                                    label: "Cari lokasi",
                                    isLocation: true,
                                    isLight: isLight,
                                  ),
                                  ...popularCities.map(
                                    (city) => GestureDetector(
                                      onTap: () {
                                        _controller.text = city["city"]!;
                                        _onSearch(city["city"]!);
                                      },
                                      child: _CityChip(
                                        label: city["city"]!,
                                        isLight: isLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isLocation;
  final bool isLight;

  const _CityChip({
    required this.label,
    this.isLocation = false,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.08);

    return Chip(
      backgroundColor: cardColor,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocation)
            Icon(
              Icons.location_on,
              color: textColor.withOpacity(0.7),
              size: 16,
            ),
          if (isLocation) const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor)),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isLight ? 2 : 0,
      shadowColor:
          isLight ? Colors.black.withOpacity(0.04) : Colors.transparent,
    );
  }
}
