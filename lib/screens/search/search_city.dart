// search_city.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;

  Future<void> fetchSuggestions(String query) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://myporto.site/api/suggestions?query=$query'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _suggestions =
              data.map<Map<String, String>>((e) {
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

  void onCitySelected(String name) {
    Navigator.pushNamed(context, '/city-weather', arguments: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blur background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (value) {
                            if (value.length >= 3) {
                              fetchSuggestions(value);
                            } else {
                              setState(() => _suggestions.clear());
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Cari nama kota',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _suggestions.clear());
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFF323247),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                        child:
                            _suggestions.isEmpty && _controller.text.length >= 3
                                ? const Center(
                                  child: Text(
                                    "Tidak ada hasil ditemukan.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: _suggestions.length,
                                  itemBuilder: (context, index) {
                                    final item = _suggestions[index];
                                    return ListTile(
                                      title: Text(
                                        item['name'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        item['region'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onTap:
                                          () => onCitySelected(
                                            item['name'] ?? '',
                                          ),
                                    );
                                  },
                                ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
