import 'package:flutter/material.dart';

class WeatherCodeHelper {
  static String getDescription(int code) {
    if (code == 0) return 'Cerah';
    if (code == 1) return 'Cerah Berawan';
    if (code == 2) return 'Berawan Sebagian';
    if (code == 3) return 'Mendung';
    if (code == 45 || code == 48) return 'Berkabut';
    if (code >= 51 && code <= 55) return 'Gerimis';
    if (code == 56 || code == 57) return 'Gerimis Beku';
    if (code >= 61 && code <= 65) return 'Hujan';
    if (code == 66 || code == 67) return 'Hujan Beku';
    if (code >= 71 && code <= 77) return 'Salju';
    if (code >= 80 && code <= 82) return 'Hujan Deras';
    if (code == 85 || code == 86) return 'Hujan Salju';
    if (code >= 95 && code <= 99) return 'Badai Petir';
    return 'Tidak Diketahui';
  }

  static IconData getIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1 || code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain_rounded;
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.umbrella_rounded;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 95 && code <= 99) return Icons.thunderstorm_rounded;
    return Icons.cloud_queue_rounded;
  }
}
