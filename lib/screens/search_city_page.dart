import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchCityPage extends StatefulWidget {
  @override
  _SearchCityPageState createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> with AutomaticKeepAliveClientMixin<SearchCityPage> {
  static const String _favoriteCitiesKey = 'favorite_cities';
  late SharedPreferences _prefs;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  List<String> favoriteCities = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavoriteCities();
  }

  void _loadFavoriteCities() {
    setState(() {
      favoriteCities = _prefs.getStringList(_favoriteCitiesKey) ?? [];
    });
  }

  Future<void> _addFavoriteCity(String city) async {
    if (!favoriteCities.contains(city)) {
      favoriteCities.add(city);
      await _prefs.setStringList(_favoriteCitiesKey, favoriteCities);
      _loadFavoriteCities();
    }
  }

  Future<void> _removeFavoriteCity(String city) async {
    if (favoriteCities.contains(city)) {
      favoriteCities.remove(city);
      await _prefs.setStringList(_favoriteCitiesKey, favoriteCities);
      _loadFavoriteCities();
    }
  }

  Future<void> fetchSuggestions(String query) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('https://myporto.site/api/suggestions?query=$query'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (!mounted) return;
        setState(() {
          _suggestions = data.map<Map<String, String>>((e) {
            return {
              'name': e['name'].toString(),
              'region': e['full'].toString(),
            };
          }).toList();
        });
      } else {
        throw Exception('Gagal mengambil saran lokasi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil saran lokasi")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (value.length >= 3) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        fetchSuggestions(value);
      });
    } else {
      setState(() => _suggestions.clear());
    }
  }

  List<Widget> _buildEmptySearchContent(Color textColor, Color subTextColor, Color cardColor, bool isLight) {
    if (favoriteCities.isNotEmpty) {
      return [
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: favoriteCities.length,
            itemBuilder: (context, index) {
              final city = favoriteCities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: isLight
                        ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16.0, offset: Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.orangeAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(city, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                            Text("Jawa Timur, Indonesia", style: TextStyle(fontSize: 13, color: subTextColor)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: subTextColor),
                        onPressed: () => _removeFavoriteCity(city),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ];
    } else {
      return [
        const SizedBox(height: 20),
        Center(
          child: Text(
            "Belum ada kota favorit. Cari dan tambahkan kota favorit Anda.",
            textAlign: TextAlign.center,
            style: TextStyle(color: subTextColor),
          ),
        ),
      ];
    }
  }

  Widget _buildSearchResultsContent(Color textColor, Color subTextColor, Color cardColor, bool isLight) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_suggestions.isEmpty && _searchController.text.length >= 3) {
      return Center(child: Text("Tidak ada hasil ditemukan.", style: TextStyle(color: subTextColor)));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final item = _suggestions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16.0, offset: Offset(0, 4))] : [],
            ),
            child: ListTile(
              title: Text(item['name'] ?? '', style: TextStyle(color: textColor)),
              subtitle: Text(item['region'] ?? '', style: TextStyle(color: subTextColor, fontSize: 12)),
              trailing: Icon(Icons.add, color: subTextColor),
              onTap: () {
                _addFavoriteCity(item['name'] ?? '');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item['name']} ditambahkan ke favorit')));
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF232B3E) : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white54;
    final cardColor = isLight ? Colors.white : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text('Kelola Kota', style: TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16.0, offset: Offset(0, 4))] : [],
              ),
              child: TextField(
                controller: _searchController,
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
                      _searchController.clear();
                      _onSearch('');
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_searchController.text.isEmpty)
              ..._buildEmptySearchContent(textColor, subTextColor, cardColor, isLight)
            else
              _buildSearchResultsContent(textColor, subTextColor, cardColor, isLight),
          ],
        ),
      ),
    );
  }
}
