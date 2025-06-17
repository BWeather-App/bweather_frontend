import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backdrop Fullscreen Blur',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearchOpen = false;

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Cuaca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tampilan utama
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("🌤️", style: TextStyle(fontSize: 80)),
                SizedBox(height: 10),
                Text("Cuaca Hari Ini", style: TextStyle(fontSize: 24)),
              ],
            ),
          ),

          // Layer Blur dan Search Page Fullscreen
          if (_isSearchOpen)
            Positioned.fill(
              child: Stack(
                children: [
                  // Efek blur background
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),

                  // Fullscreen SearchPage
                  SearchPage(onClose: _toggleSearch),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final VoidCallback onClose;

  const SearchPage({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Supaya blur kelihatan
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari kota...',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Konten Pencarian (Contoh)
            const Expanded(
              child: Center(
                child: Text(
                  'Hasil Pencarian Akan Ditampilkan Di Sini',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}