import 'package:flutter/material.dart';

class HomeTopWidget extends StatelessWidget {
  const HomeTopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const SearchCityPage()),
                    // );
                  },
                ),
                Text(
                  "Kota Kediri, Jawa Timur, Indonesia",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              "Cerah Berawan",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Text(
              "28°C",
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "12:30 WIB, Selasa",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
