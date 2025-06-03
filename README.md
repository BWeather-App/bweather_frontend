# Weather App (Search Feature Only)

This Flutter project implements the **search functionality** of a weather app using custom API integration.

## 🌤️ Features Implemented
- Search for cities and fetch weather data using custom API
- Display city name, temperature (in Celsius), and weather description
- Use of `Provider` for state management
- HTTP integration using `http` package

## 📦 Folder Structure (Only Relevant to Search)
```
lib/
├── models/
│   ├── city.dart
│   └── weather_info.dart
├── providers/
│   └── city_provider.dart
├── services/
│   └── weather_service.dart
├── views/
│   ├── screens/
│   │   ├── manage_city_screen.dart
│   │   └── search_city_screen.dart
│   └── widgets/
│       ├── search_field.dart
│       └── city_tile.dart
└── main.dart
```

## 🛠️ API Used
```
Base URL: https://myporto.site/bweather-backend/public/index.php
Search Endpoint: ?endpoint=search&query={city}
Weather Endpoint: ?endpoint=weather&latitude={lat}&longitude={lon}
```

## 🚀 Run Project
```bash
flutter pub get
flutter run
```

⚠️ If you're running on Flutter Web, be aware of potential **CORS issues** when accessing the API.

---

© 2025 Weather App - Search Team