class CurrentWeather {
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final String time;

  const CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m:
          (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      time: (json['time'] as String?) ?? '',
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperature2mMax;
  final double temperature2mMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });
}

class WeatherResponse {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String timezone;

  const WeatherResponse({
    required this.current,
    required this.daily,
    required this.timezone,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>? ?? {};
    final dailyMap = json['daily'] as Map<String, dynamic>? ?? {};

    final times = (dailyMap['time'] as List<dynamic>? ?? []).cast<String>();
    final codes = (dailyMap['weather_code'] as List<dynamic>? ?? []);
    final maxTemps = (dailyMap['temperature_2m_max'] as List<dynamic>? ?? []);
    final minTemps = (dailyMap['temperature_2m_min'] as List<dynamic>? ?? []);
    final precipProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>? ?? []);

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < times.length; i++) {
      forecasts.add(
        DailyForecast(
          date: DateTime.tryParse(times[i]) ?? DateTime.now(),
          weatherCode:
              i < codes.length && codes[i] != null ? (codes[i] as num).toInt() : 0,
          temperature2mMax: i < maxTemps.length && maxTemps[i] != null
              ? (maxTemps[i] as num).toDouble()
              : 0.0,
          temperature2mMin: i < minTemps.length && minTemps[i] != null
              ? (minTemps[i] as num).toDouble()
              : 0.0,
          precipitationProbabilityMax:
              i < precipProbs.length && precipProbs[i] != null
                  ? (precipProbs[i] as num).toInt()
                  : 0,
        ),
      );
    }

    return WeatherResponse(
      current: CurrentWeather.fromJson(currentMap),
      daily: forecasts,
      timezone: (json['timezone'] as String?) ?? 'auto',
    );
  }
}
