import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_flutter/main.dart';
import 'package:responsi_flutter/models/location_model.dart';
import 'package:responsi_flutter/services/weather_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Model & API Service Tests', () {
    test('LocationModel parses geocoding JSON and serializes correctly', () {
      final json = {
        'id': 1621177,
        'name': 'Yogyakarta',
        'latitude': -7.7956,
        'longitude': 110.3695,
        'country': 'Indonesia',
        'admin1': 'Daerah Istimewa Yogyakarta',
      };

      final location = LocationModel.fromGeocodingJson(json);
      expect(location.name, 'Yogyakarta');
      expect(location.displaySubtitle, 'Daerah Istimewa Yogyakarta, Indonesia');
      expect(LocationModel.fromJson(location.toJson()), location);
    });

    test('WeatherApiService.fetchWeather parses Open-Meteo response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.queryParameters['timezone'], 'auto');
        return http.Response(
          jsonEncode({
            'timezone': 'Asia/Jakarta',
            'current': {
              'time': '2026-11-26T04:00',
              'temperature_2m': 26.5,
              'relative_humidity_2m': 82,
              'apparent_temperature': 29.1,
              'precipitation': 0.0,
              'weather_code': 2,
              'wind_speed_10m': 7.5,
            },
            'daily': {
              'time': ['2026-11-26', '2026-11-27'],
              'weather_code': [2, 61],
              'temperature_2m_max': [31.2, 29.8],
              'temperature_2m_min': [23.4, 22.9],
              'precipitation_probability_max': [30, 80],
            },
          }),
          200,
        );
      });

      final service = WeatherApiService(client: mockClient);
      final result = await service.fetchWeather(
        latitude: -7.7956,
        longitude: 110.3695,
      );

      expect(result.current.temperature2m, 26.5);
      expect(result.current.relativeHumidity2m, 82);
      expect(result.current.apparentTemperature, 29.1);
      expect(result.current.windSpeed10m, 7.5);
      expect(result.daily.length, 2);
      expect(result.daily[1].precipitationProbabilityMax, 80);
    });

    test('WeatherApiService.searchLocations handles empty and error responses',
        () async {
      final emptyClient = MockClient((_) async {
        return http.Response(jsonEncode({'generationtime_ms': 0.5}), 200);
      });
      final emptyService = WeatherApiService(client: emptyClient);
      expect(await emptyService.searchLocations('KotaTidakAda'), isEmpty);

      final errorClient = MockClient((_) async {
        return http.Response('Server Error', 500);
      });
      final errorService = WeatherApiService(client: errorClient);
      expect(
        () => errorService.searchLocations('Jakarta'),
        throwsException,
      );
    });
  });

  group('Widget Tests', () {
    testWidgets('WeatherApp renders empty state and navigates to SearchScreen',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      expect(find.text('Info Cuaca'), findsOneWidget);
      expect(find.text('Belum ada kota dipilih'), findsOneWidget);
      expect(find.text('Cari Lokasi'), findsOneWidget);

      await tester.tap(find.text('Cari Lokasi'));
      await tester.pumpAndSettle();

      expect(find.text('Cari & Lokasi Favorit'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
