# BWeather

<p align="center">
  <b>Modern Weather App</b> — Android · Flutter · Laravel
</p>

A sleek, real-time weather application with GPS location detection, 5-day forecast, interactive charts, favorite cities, and dark/light mode.

## Features

- **Real-time weather** — current conditions with UV index, humidity, wind direction, feels-like
- **5-day forecast** — daily weather outlook with interactive temperature chart
- **Hourly forecast** — 24-hour chart with tappable data points
- **Favorite cities** — save up to 5 locations with weather snapshots
- **City search** — autocomplete search with history
- **Dark/Light mode** — persistent theme toggle
- **°C / °F** — toggle temperature units
- **Extreme weather alerts** — local push notifications

## Tech Stack

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `hive_flutter` | Local storage (favorites, cache) |
| `geolocator` | GPS location |
| `google_fonts` | Poppins & Montserrat |
| `fl_chart` | Interactive charts |
| `flutter_svg` | SVG icons |
| `shared_preferences` | Theme persistence |
| `flutter_local_notifications` | Extreme weather alerts |

## Folder Structure

```
lib/
├── constants/          # Colors, text styles, dimensions, weather icons
├── providers/          # WeatherProvider, FavoriteProvider, SettingsProvider
├── repositories/       # WeatherRepository (HTTP layer)
├── services/           # WeatherService, FavoriteService, LocationService, etc.
├── helpers/            # TimeHelper, SearchHistoryHelper
├── screens/
│   ├── home/
│   │   └── widgets/    # Cards, charts, compass, painters
│   └── search/         # Search city, preview, action button
├── widgets/            # Reusable widgets (ErrorView)
└── main.dart
```

## Getting Started

```bash
# 1. Clone & install
flutter pub get

# 2. Configure .env
# API_BASE_URL=http://YOUR_BACKEND_URL

# 3. Run
flutter run
```

## Build

```bash
# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

## License

MIT — Built as a portfolio project.
