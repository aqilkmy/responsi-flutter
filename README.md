# Aplikasi Info Cuaca (Responsi Flutter)

Aplikasi informasi cuaca berbasis Flutter menggunakan arsitektur Model-View-ViewModel (MVVM), REST API Open-Meteo, pengelolaan state dengan Provider, serta penyimpanan lokal menggunakan SharedPreferences.

## Struktur Aplikasi

```text
lib/
├── main.dart
├── models/
│   ├── location_model.dart
│   └── weather_model.dart
├── services/
│   ├── local_storage_service.dart
│   └── weather_api_service.dart
├── theme/
│   └── app_theme.dart
├── utils/
│   └── weather_code_helper.dart
├── viewmodels/
│   ├── location_viewmodel.dart
│   └── weather_viewmodel.dart
└── views/
    ├── home_screen.dart
    └── search_screen.dart
```

## Penerapan Arsitektur MVVM

- **Model (`lib/models/`)**: Merepresentasikan struktur data `LocationModel`, `CurrentWeather`, `DailyForecast`, dan `WeatherResponse` beserta konversi JSON (`fromJson`, `fromGeocodingJson`, `toJson`).
- **Service (`lib/services/`)**: Menangani komunikasi eksternal melalui `WeatherApiService` (HTTP GET ke API Open-Meteo) dan persistensi data lokal melalui `LocalStorageService` (SharedPreferences untuk lokasi favorit, riwayat pencarian, dan lokasi terakhir yang dipilih).
- **ViewModel (`lib/viewmodels/`)**: `WeatherViewModel` dan `LocationViewModel` mewarisi `ChangeNotifier` untuk mengelola state aplikasi (loading, data kosong, error, serta daftar lokasi favorit dan riwayat) dan memisahkan logika bisnis dari UI.
- **View (`lib/views/`)**: `HomeScreen` dan `SearchScreen` hanya bertugas merender tampilan berdasarkan state dari ViewModel menggunakan `Provider` (`context.watch` dan `context.read`).

## Implementasi API Open-Meteo

1. **Geocoding API** (`https://geocoding-api.open-meteo.com/v1/search`)
   - Digunakan pada `SearchScreen` untuk mencari kota berdasarkan kata kunci pengguna (`name`).
2. **Weather Forecast API** (`https://api.open-meteo.com/v1/forecast`)
   - Parameter utama: `latitude`, `longitude`, `current`, `daily`, dan `timezone=auto`.
   - Field `current`: `temperature_2m`, `relative_humidity_2m`, `apparent_temperature`, `precipitation`, `weather_code`, `wind_speed_10m`.
   - Field `daily`: `weather_code`, `temperature_2m_max`, `temperature_2m_min`, `precipitation_probability_max`.

## Screenshot Aplikasi

Tambahkan screenshot masing-masing screen di folder `screenshots/` lalu tautkan di bagian ini:

- **Home / Weather Screen**: `screenshots/home_screen.png`
- **Search / Location Screen**: `screenshots/search_screen.png`
