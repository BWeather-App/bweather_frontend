import 'package:flutter/material.dart';
import '../favorite_city_helper.dart';

class ManageCityPage extends StatefulWidget {
  const ManageCityPage({super.key});

  @override
  State<ManageCityPage> createState() => _ManageCityPageState();
}

class _ManageCityPageState extends State<ManageCityPage> {
  List<String> favoriteCities = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final cities = await FavoriteCityHelper.getFavoriteCities();
    setState(() {
      favoriteCities = cities;
    });
  }

  Future<void> _removeCity(String city) async {
    await FavoriteCityHelper.removeFavoriteCity(city);
    _loadFavorites();
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
          'Kelola Kota',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: favoriteCities.isEmpty
            ? Center(
                child: Text(
                  "Belum ada kota favorit",
                  style: TextStyle(color: subTextColor),
                ),
              )
            : ListView.builder(
                itemCount: favoriteCities.length,
                itemBuilder: (context, index) {
                  final city = favoriteCities[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
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
                        city,
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: subTextColor),
                        onPressed: () => _removeCity(city),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}