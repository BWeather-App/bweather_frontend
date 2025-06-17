import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../services/search_history_helper.dart';

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _searchHistory = [];
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  bool _selectMode = false;
  Set<String> _selectedHistory = {};

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _onSearch(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await saveSearchHistory(city);
    await _loadSearchHistory();

    try {
      final encodedCity = Uri.encodeComponent(city);
      final response = await http.get(
        Uri.parse('https://myporto.site/api/suggestions?query=$encodedCity'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestions = data;
        });
      }
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _clearAllHistory() async {
    await clearSearchHistory();
    _selectedHistory.clear();
    _selectMode = false;
    _loadSearchHistory();
  }

  Future<void> _deleteSelectedHistory() async {
    final updated = List<String>.from(_searchHistory)
      ..removeWhere((item) => _selectedHistory.contains(item));
    await updateSearchHistory(updated);
    _selectedHistory.clear();
    _selectMode = false;
    _loadSearchHistory();
  }

  Widget _buildCityItem(
    String city,
    String region,
    Color textColor,
    Color subtitleColor,
    Color cardColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(
          city,
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          region,
          style: GoogleFonts.poppins(
            color: subtitleColor,
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
        ),
        trailing: Icon(Icons.add, color: iconColor),
        onTap: () async {
          await saveSearchHistory(city);
          Navigator.pushNamed(context, '/city-weather', arguments: city);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = Colors.transparent;
    final blurBackgroundColor =
        isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05);
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final inputBoxColor =
        isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.05);
    final cardColor =
        isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03);
    final selectedCardColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1);

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: blurBackgroundColor),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: iconColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: inputBoxColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: iconColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari lokasi',
                              hintStyle: GoogleFonts.poppins(
                                color: hintColor,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _onSearch,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: hintColor),
                          onPressed: () => _controller.clear(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator(color: textColor)),
                  if (!_isLoading && _suggestions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final item = _suggestions[index];
                          return _buildCityItem(
                            item['name'],
                            item['full'] ?? item['name'],
                            textColor,
                            subtitleColor,
                            cardColor,
                            iconColor,
                          );
                        },
                      ),
                    ),
                  if (isKeyboardVisible &&
                      !_isLoading &&
                      _suggestions.isEmpty &&
                      _searchHistory.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Riwayat Pencarian",
                            style: GoogleFonts.poppins(
                              color: subtitleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchHistory.length,
                              itemBuilder: (context, index) {
                                final city = _searchHistory[index];
                                final isSelected = _selectedHistory.contains(
                                  city,
                                );

                                return GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _selectMode = true;
                                      _selectedHistory.add(city);
                                    });
                                  },
                                  onTap: () {
                                    if (_selectMode) {
                                      setState(() {
                                        isSelected
                                            ? _selectedHistory.remove(city)
                                            : _selectedHistory.add(city);
                                        if (_selectedHistory.isEmpty)
                                          _selectMode = false;
                                      });
                                    } else {
                                      _controller.text = city;
                                      _onSearch(city);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? selectedCardColor
                                              : cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.history, color: iconColor),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            city,
                                            style: GoogleFonts.poppins(
                                              color: textColor,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _clearAllHistory,
                                icon: Icon(
                                  Icons.delete_sweep,
                                  color: iconColor,
                                ),
                                label: Text(
                                  "Hapus Semua",
                                  style: GoogleFonts.poppins(
                                    color: iconColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (_selectMode)
                                TextButton.icon(
                                  onPressed: _deleteSelectedHistory,
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  label: Text(
                                    "Hapus Terpilih",
                                    style: GoogleFonts.poppins(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
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
