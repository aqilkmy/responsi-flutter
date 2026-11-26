import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  final WeatherApiService? apiService;
  final LocalStorageService? storageService;

  const WeatherApp({
    super.key,
    this.apiService,
    this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedApiService = apiService ?? WeatherApiService();
    final resolvedStorageService = storageService ?? LocalStorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(
            apiService: resolvedApiService,
            storageService: resolvedStorageService,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationViewModel(
            apiService: resolvedApiService,
            storageService: resolvedStorageService,
          )..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Info Cuaca',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
