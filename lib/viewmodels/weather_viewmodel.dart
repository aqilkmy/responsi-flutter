import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService apiService;
  final LocalStorageService storageService;

  WeatherViewModel({
    required this.apiService,
    required this.storageService,
  });

  LocationModel? _selectedLocation;
  WeatherResponse? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel? get selectedLocation => _selectedLocation;
  WeatherResponse? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedLocation = await storageService.getSelectedLocation();
      if (_selectedLocation != null) {
        await loadWeather();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat lokasi tersimpan';
      notifyListeners();
    }
  }

  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await storageService.saveSelectedLocation(location);
    await loadWeather();
  }

  Future<void> loadWeather() async {
    final location = _selectedLocation;
    if (location == null) {
      _weather = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await apiService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
