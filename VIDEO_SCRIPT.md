# Script Video Penjelasan Kode - Aplikasi Info Cuaca (Responsi Flutter)

## 1. Pembukaan dan Demo Singkat (00:00 - 00:40)

**Tampilan layar:** Aplikasi berjalan di emulator/perangkat.

> Halo, saya [Nama Anda] dengan NIM [NIM Anda]. Video ini menjelaskan aplikasi Info Cuaca berbasis Flutter yang menggunakan arsitektur MVVM, state management Provider, penyimpanan lokal SharedPreferences, serta REST API Open-Meteo.
>
> Aplikasi memiliki dua screen utama:
> 1. **Home Screen** untuk menampilkan cuaca terkini, detail parameter cuaca, perkiraan harian, dan akses cepat kota favorit.
> 2. **Search Screen** untuk mencari kota secara real-time ke API Open-Meteo, menyimpan favorit, dan melihat riwayat pencarian.

---

## 2. Entry Point dan Arsitektur MVVM (00:40 - 01:25)

**Tampilan layar:** Buka folder `lib/` dan file `lib/main.dart`.

> Proyek ini menerapkan pola **Model-View-ViewModel (MVVM)** yang dipisah ke folder `models/`, `services/`, `viewmodels/`, `views/`, `theme/`, dan `utils/`.
>
> Di `lib/main.dart`, `WeatherApp` membungkus `MaterialApp` dengan `MultiProvider` yang mendaftarkan dua `ChangeNotifierProvider`:
> - `WeatherViewModel` untuk data cuaca dan kota aktif.
> - `LocationViewModel` untuk pencarian kota, favorit, dan riwayat.
>
> Keduanya langsung memanggil `..initialize()` saat aplikasi berjalan agar kota terakhir, daftar favorit, dan riwayat pencarian yang tersimpan di perangkat langsung dimuat. `MaterialApp` juga menggunakan `AppTheme.lightTheme` dari `lib/theme/app_theme.dart` yang mengatur skema warna Material 3, `CardThemeData`, `InputDecorationTheme`, dan `TextTheme` secara konsisten.

---

## 3. Model dan Service: Open-Meteo API & SharedPreferences (01:25 - 02:55)

**Tampilan layar:** Buka `lib/models/location_model.dart`, `lib/models/weather_model.dart`, `lib/services/weather_api_service.dart`, dan `lib/services/local_storage_service.dart`.

> Pertama pada **Model**:
> - `LocationModel` di `location_model.dart` menyimpan `id`, `name`, `latitude`, `longitude`, `country`, dan `admin1`. Factory `fromGeocodingJson` mem-parsing respons Geocoding API, sedangkan `toJson` dan `fromJson` dipakai untuk serialisasi ke penyimpanan lokal. Operator `==` dan `hashCode` di-override berdasarkan `id`, `latitude`, dan `longitude` agar pengecekan status favorit akurat.
> - `weather_model.dart` berisi `CurrentWeather`, `DailyForecast`, dan `WeatherResponse`. `CurrentWeather.fromJson` memetakan `temperature_2m`, `relative_humidity_2m`, `apparent_temperature`, `precipitation`, `weather_code`, dan `wind_speed_10m`. `WeatherResponse.fromJson` juga menggabungkan array `time`, `weather_code`, `temperature_2m_max`, `temperature_2m_min`, dan `precipitation_probability_max` menjadi list `DailyForecast`.
>
> Kedua pada **Service**:
> - Di `weather_api_service.dart`, `fetchWeather()` mengirim HTTP `GET` ke `api.open-meteo.com/v1/forecast` dengan parameter `latitude`, `longitude`, `current`, `daily`, dan `timezone=auto`, serta timeout 15 detik. `searchLocations()` mengirim HTTP `GET` ke `geocoding-api.open-meteo.com/v1/search` dengan `count=15` dan `language=id`. Jika `statusCode != 200`, service melempar `Exception` untuk ditangkap ViewModel.
> - Di `local_storage_service.dart`, `LocalStorageService` menyimpan list favorit, riwayat pencarian, dan lokasi terpilih ke `SharedPreferences` dalam format JSON string melalui `setStringList` dan `setString`.

---

## 4. ViewModel dan Rekomendasi Otomatis (02:55 - 04:00)

**Tampilan layar:** Buka `lib/viewmodels/weather_viewmodel.dart` dan `lib/viewmodels/location_viewmodel.dart`.

> Pada **ViewModel**:
> - `WeatherViewModel` menyimpan state `_selectedLocation`, `_weather`, `_isLoading`, dan `_errorMessage`. Saat `selectLocation(location)` dipanggil, lokasi disimpan ke `LocalStorageService`, lalu `loadWeather()` mengambil data dari API, menangani loading dan error di blok `try-catch-finally`, dan memanggil `notifyListeners()`.
> - `LocationViewModel` mengelola `_searchResults`, `_favorites`, `_searchHistory`, `_isSearching`, dan `_hasSearched`. Untuk pencarian real-time, method `onSearchQueryChanged` menggunakan `Timer` debounce 400 milidetik: jika input kosong hasil dibersihkan lewat `clearSearch()`, dan jika minimal 2 karakter maka `searchCities()` otomatis dijalankan tanpa harus menekan Enter. Selain itu, `toggleFavorite()` dan `addToHistory()` langsung memperbarui state sekaligus menyimpannya ke `SharedPreferences`.

---

## 5. View dan Pengujian (04:00 - 05:15)

**Tampilan layar:** Buka `lib/utils/weather_code_helper.dart`, `lib/views/home_screen.dart`, `lib/views/search_screen.dart`, dan `test/widget_test.dart`.

> Pada **View**:
> - `HomeScreen` membaca state dengan `context.watch<WeatherViewModel>()` dan `context.watch<LocationViewModel>()`. Di AppBar terdapat tombol toggle favorit dan tombol pencarian. Jika ada favorit, `_FavoritesBar` menampilkan `ChoiceChip` untuk pindah kota dengan cepat. Body menangani empat kondisi: lokasi kosong (`_EmptyLocationState`), loading (`CircularProgressIndicator`), error (`_ErrorState` dengan tombol Coba Lagi), dan data cuaca yang dibungkus `RefreshIndicator` serta `LayoutBuilder` agar layout responsif di layar sempit maupun lebar. Kode cuaca dikonversi menggunakan `WeatherCodeHelper.getDescription()` dan `getIcon()`.
> - `SearchScreen` memakai `TextField` yang memanggil `onSearchQueryChanged` pada `onChanged` dan `searchCities` saat submit. Saat hasil pencarian dipilih, `_selectLocation` memanggil `addToHistory()`, `selectLocation()`, lalu menutup screen kembali ke `HomeScreen`. Jika belum ada pencarian, screen menampilkan daftar Lokasi Favorit dan Riwayat Pencarian.
>
> Terakhir di `test/widget_test.dart`, terdapat 4 pengujian menggunakan `MockClient` dan `SharedPreferences.setMockInitialValues` untuk memverifikasi parsing `LocationModel`, respons `fetchWeather`, penanganan error/kosong pada `searchLocations`, serta navigasi dari `HomeScreen` ke `SearchScreen`. Seluruh test lulus tanpa error.
>
> Sekian penjelasan kode aplikasi Info Cuaca ini. Terima kasih.
