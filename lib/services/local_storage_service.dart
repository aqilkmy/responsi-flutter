import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _historyKey = 'search_history';
  static const String _selectedLocationKey = 'selected_location';

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_favoritesKey) ?? [];
    return rawList
        .map((e) => LocationModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_favoritesKey, rawList);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_historyKey) ?? [];
    return rawList
        .map((e) => LocationModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, rawList);
  }

  Future<LocationModel?> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocationKey, jsonEncode(location.toJson()));
  }
}
