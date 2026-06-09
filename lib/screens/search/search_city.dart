import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_cuaca/constants/constants.dart';
import 'package:flutter_cuaca/services/weather_service.dart';
import 'package:flutter_cuaca/services/favorite_service.dart';
import 'package:flutter_cuaca/helpers/search_history_helper.dart';

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  bool _selectMode = false;
  Set<String> _selectedHistory = {};
  bool _selectFavoriteMode = false;
  Set<String> _selectedFavorites = {};

  List<Map<String, dynamic>> _favoriteCities = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _initFavorites();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initFavorites() {
    final result = FavoriteService.getFavorites(); // Tidak perlu await
    setState(() {
      _favoriteCities = result;
    });
  }

  Future<void> _removeFromFavorites(String fullName) async {
    await FavoriteService.removeFavorite(fullName);
    _initFavorites();
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
      final data = await WeatherService.instance.getSuggestions(city);
      setState(() {
        _suggestions = data;
      });
    } on WeatherApiException catch (e) {
      debugPrint('Search error: ${e.userMessage}');
    } catch (e) {
      debugPrint('Search error: $e');
    }

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
    Map<String, dynamic> item,
    Color textColor,
    Color subtitleColor,
    Color cardColor,
    Color iconColor,
  ) {
    final city = item['name'];
    final region = item['full'] ?? item['name'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spaceS),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(
          city,
          style: AppTextStyles.searchTitle(context),
        ),
        subtitle: Text(
          region,
          style: AppTextStyles.searchSubtitle(context),
        ),
        onTap: () async {
          await saveSearchHistory(city);
          Navigator.pushNamed(context, '/city-weather', arguments: city);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.transparent;
    final blurBackgroundColor = AppColors.blurBackground(context);
    final textColor = AppColors.textPrimary(context);
    final hintColor = AppColors.textHint(context);
    final iconColor = AppColors.icon(context);
    final subtitleColor = AppColors.textSecondary(context);
    final inputBoxColor = AppColors.inputBackground(context);
    final cardColor = AppColors.cardBackground(context);
    final selectedCardColor = AppColors.selectedCardBackground(context);

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: blurBackgroundColor),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.spaceL,
                right: AppDimensions.spaceL,
                top: AppDimensions.spaceXL,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.spaceXL,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceL),
                    decoration: BoxDecoration(
                      color: inputBoxColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.cardBorder(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: iconColor),
                        const SizedBox(width: AppDimensions.spaceS),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: AppTextStyles.searchInput(context),
                            decoration: InputDecoration(
                              hintText: 'Cari lokasi',
                              hintStyle: AppTextStyles.searchHint(context),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _onSearch,
                            onChanged: (value) {
                              if (value.trim().length >= 2) {
                                _onSearch(value);
                              } else {
                                setState(() => _suggestions = []);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: hintColor),
                          onPressed: () => _controller.clear(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceL),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator(color: textColor)),
                  if (!_isLoading && _suggestions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final item = _suggestions[index];
                          return _buildCityItem(
                            item, // kirim seluruh item
                            textColor,
                            subtitleColor,
                            cardColor,
                            iconColor,
                          );
                        },
                      ),
                    ),
                  if (!_isLoading &&
                      !isKeyboardVisible &&
                      _favoriteCities.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lokasi Favorit",
                            style: AppTextStyles.searchSection(context),
                          ),
                          const SizedBox(height: AppDimensions.spaceS),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _favoriteCities.length,
                              itemBuilder: (context, index) {
                                final city = _favoriteCities[index];
                                final isSelected = _selectedFavorites.contains(
                                  city['full'],
                                );

                                return GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _selectFavoriteMode = true;
                                      _selectedFavorites.add(city['full']);
                                    });
                                  },
                                  onTap: () {
                                    if (_selectFavoriteMode) {
                                      setState(() {
                                        isSelected
                                            ? _selectedFavorites.remove(
                                              city['full'],
                                            )
                                            : _selectedFavorites.add(
                                              city['full'],
                                            );
                                        if (_selectedFavorites.isEmpty) {
                                          _selectFavoriteMode = false;
                                        }
                                      });
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/city-weather',
                                        arguments: city['full'],
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? selectedCardColor
                                              : cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListTile(
                                      leading: IconButton(
                                        icon: Icon(
                                          Icons.star,
                                          color: Colors.amber.shade600,
                                        ),
                                        onPressed: () async {
                                          await _removeFromFavorites(
                                            city['full'],
                                          );
                                        },
                                      ),
                                      title: Text(
                                        city['name'] ?? '',
                                        style: AppTextStyles.searchListTitle(context),
                                      ),
                                      subtitle: Text(
                                        city['full'] ?? '',
                                        style: AppTextStyles.searchListSubtitle(context),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_selectFavoriteMode)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    for (final fullName in _selectedFavorites) {
                                      await _removeFromFavorites(fullName);
                                    }

                                    setState(() {
                                      _selectedFavorites.clear();
                                      _selectFavoriteMode = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  label: Text(
                                    "Hapus Favorit Terpilih",
                                    style: AppTextStyles.searchActionDelete(context),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                  if (!_isLoading &&
                      isKeyboardVisible &&
                      _suggestions.isEmpty &&
                      _searchHistory.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Riwayat Pencarian",
                            style: AppTextStyles.searchSection(context),
                          ),
                          const SizedBox(height: AppDimensions.spaceS),
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
                                        if (_selectedHistory.isEmpty) {
                                          _selectMode = false;
                                        }
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
                                        const SizedBox(width: AppDimensions.spaceM),
                                        Expanded(
                                          child: Text(
                                            city,
                                            style: AppTextStyles.searchListTitle(context),
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
                                  style: AppTextStyles.searchListLabel(context),
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
                                    style: AppTextStyles.searchActionDelete(context),
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
