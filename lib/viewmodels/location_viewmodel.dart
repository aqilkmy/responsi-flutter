import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class LocationViewModel extends ChangeNotifier {
  final WeatherApiService apiService;
  final LocalStorageService storageService;

  LocationViewModel({
    required this.apiService,
    required this.storageService,
  });

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;
  String _lastQuery = '';
  Timer? _debounce;

  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  Future<void> initialize() async {
    _favorites = await storageService.getFavorites();
    _searchHistory = await storageService.getSearchHistory();
    notifyListeners();
  }

  void onSearchQueryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }
    if (trimmed.length < 2) {
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchCities(trimmed);
    });
  }

  Future<void> searchCities(String query) async {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _lastQuery = trimmed;
    _isSearching = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await apiService.searchLocations(trimmed);
    } catch (e) {
      _searchResults = [];
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _hasSearched = false;
    _errorMessage = null;
    _lastQuery = '';
    notifyListeners();
  }

  bool isFavorite(LocationModel location) {
    return _favorites.contains(location);
  }

  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites.removeWhere((item) => item == location);
    } else {
      _favorites.insert(0, location);
    }
    notifyListeners();
    await storageService.saveFavorites(_favorites);
  }

  Future<void> addToHistory(LocationModel location) async {
    _searchHistory.removeWhere((item) => item == location);
    _searchHistory.insert(0, location);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    notifyListeners();
    await storageService.saveSearchHistory(_searchHistory);
  }

  Future<void> removeFromHistory(LocationModel location) async {
    _searchHistory.removeWhere((item) => item == location);
    notifyListeners();
    await storageService.saveSearchHistory(_searchHistory);
  }

  Future<void> clearHistory() async {
    _searchHistory.clear();
    notifyListeners();
    await storageService.saveSearchHistory(_searchHistory);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
