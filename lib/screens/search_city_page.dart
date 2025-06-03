import 'package:flutter/material.dart';
import '../favorite_city_helper.dart';

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> allCities = [
    {"city": "Surabaya", "region": "Jawa Timur, Indonesia"},
    {"city": "Surabaya", "region": "Lampung, Indonesia"},
    {"city": "Surabaya", "region": "Nusa Tenggara Barat, Indonesia"},
    {"city": "Jakarta", "region": "DKI Jakarta, Indonesia"},
    {"city": "Denpasar", "region": "Bali, Indonesia"},
    {"city": "Bandung", "region": "Jawa Barat, Indonesia"},
    {"city": "Bekasi", "region": "Jawa Barat, Indonesia"},
    {"city": "Palembang", "region": "Sumatera Selatan, Indonesia"},
    {"city": "Jambi", "region": "Jambi, Indonesia"},
    {"city": "Makassar", "region": "Sulawesi Selatan, Indonesia"},
    {"city": "Kediri", "region": "Jawa Timur, Indonesia"},
    {"city": "Lampung", "region": "Lampung, Indonesia"},
  ];

  List<Map<String, String>> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCities = allCities;
  }

  void _onSearch(String value) {
    setState(() {
      filteredCities = allCities
          .where((city) =>
              city["city"]!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cari Kota',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isLight
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: textColor),
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: "Cari kota...",
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, color: subTextColor),
                    onPressed: () {
                      _controller.clear();
                      _onSearch('');
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_controller.text.isEmpty) ...[
              Text(
                "Kota Populer",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CityChip(label: "Yogyakarta", isLocation: true, isLight: isLight),
                  _CityChip(label: "Jakarta", isLight: isLight),
                  _CityChip(label: "Denpasar", isLight: isLight),
                  _CityChip(label: "Bandung", isLight: isLight),
                  _CityChip(label: "Surabaya", isLight: isLight),
                  _CityChip(label: "Balikpapan", isLight: isLight),
                  _CityChip(label: "Bekasi", isLight: isLight),
                  _CityChip(label: "Palembang", isLight: isLight),
                  _CityChip(label: "Jambi", isLight: isLight),
                  _CityChip(label: "Makassar", isLight: isLight),
                  _CityChip(label: "Kediri", isLight: isLight),
                  _CityChip(label: "Lampung", isLight: isLight),
                  _CityChip(label: "Batam", isLight: isLight),
                ],
              ),
            ] else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isLight
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: ListTile(
                        title: Text(
                          city["city"]!,
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          city["region"]!,
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                        trailing: Icon(Icons.add, color: subTextColor),
                        onTap: () async {
                          await FavoriteCityHelper.addFavoriteCity(city["city"]!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${city["city"]} ditambahkan ke favorit')),
                          );
                        },
                      ),
                    );
                  },
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

  const _CityChip({required this.label, this.isLocation = false, required this.isLight});

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
            Icon(Icons.location_on, color: textColor.withOpacity(0.7), size: 16),
          if (isLocation) const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor)),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isLight ? 2 : 0,
      shadowColor: isLight ? Colors.black.withOpacity(0.04) : Colors.transparent,
    );
  }
}