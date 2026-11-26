import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../utils/weather_code_helper.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearchScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  String _formatDate(DateTime date, int index) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName';
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final selected = weatherVm.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Cuaca'),
        actions: [
          if (selected != null)
            IconButton(
              tooltip: locationVm.isFavorite(selected)
                  ? 'Hapus dari favorit'
                  : 'Simpan ke favorit',
              onPressed: () => locationVm.toggleFavorite(selected),
              icon: Icon(
                locationVm.isFavorite(selected)
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: locationVm.isFavorite(selected)
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          IconButton(
            tooltip: 'Cari Lokasi',
            onPressed: () => _openSearchScreen(context),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          if (locationVm.favorites.isNotEmpty)
            _FavoritesBar(
              favorites: locationVm.favorites,
              selected: selected,
              onSelect: (loc) => weatherVm.selectLocation(loc),
            ),
          Expanded(
            child: _buildBody(context, weatherVm),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel weatherVm) {
    if (weatherVm.selectedLocation == null && !weatherVm.isLoading) {
      return _EmptyLocationState(
        onSearchPressed: () => _openSearchScreen(context),
      );
    }

    if (weatherVm.isLoading && weatherVm.weather == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data cuaca...'),
          ],
        ),
      );
    }

    if (weatherVm.errorMessage != null && weatherVm.weather == null) {
      return _ErrorState(
        message: weatherVm.errorMessage!,
        onRetry: () => weatherVm.loadWeather(),
      );
    }

    final weather = weatherVm.weather;
    final location = weatherVm.selectedLocation;
    if (weather == null || location == null) {
      return _EmptyLocationState(
        onSearchPressed: () => _openSearchScreen(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => weatherVm.loadWeather(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (weatherVm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MaterialBanner(
                    content: Text(weatherVm.errorMessage!),
                    actions: [
                      TextButton(
                        onPressed: () => weatherVm.loadWeather(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _CurrentWeatherCard(
                            location: location,
                            current: weather.current,
                          ),
                          const SizedBox(height: 16),
                          _WeatherDetailsGrid(
                            current: weather.current,
                            todayForecast: weather.daily.isNotEmpty
                                ? weather.daily.first
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _DailyForecastSection(
                        daily: weather.daily,
                        dateFormatter: _formatDate,
                      ),
                    ),
                  ],
                )
              else ...[
                _CurrentWeatherCard(
                  location: location,
                  current: weather.current,
                ),
                const SizedBox(height: 16),
                _WeatherDetailsGrid(
                  current: weather.current,
                  todayForecast:
                      weather.daily.isNotEmpty ? weather.daily.first : null,
                ),
                const SizedBox(height: 20),
                _DailyForecastSection(
                  daily: weather.daily,
                  dateFormatter: _formatDate,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FavoritesBar extends StatelessWidget {
  final List<LocationModel> favorites;
  final LocationModel? selected;
  final ValueChanged<LocationModel> onSelect;

  const _FavoritesBar({
    required this.favorites,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = favorites[index];
          final isSelected = item == selected;
          return ChoiceChip(
            label: Text(item.name),
            selected: isSelected,
            onSelected: (_) => onSelect(item),
          );
        },
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather current;

  const _CurrentWeatherCard({
    required this.location,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location.name,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (location.displaySubtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Text(
                  location.displaySubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperature2m.round()}°C',
                      style: textTheme.displayLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      WeatherCodeHelper.getDescription(current.weatherCode),
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terasa seperti ${current.apparentTemperature.round()}°C',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                Icon(
                  WeatherCodeHelper.getIcon(current.weatherCode),
                  size: 72,
                  color: colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetailsGrid extends StatelessWidget {
  final CurrentWeather current;
  final DailyForecast? todayForecast;

  const _WeatherDetailsGrid({
    required this.current,
    required this.todayForecast,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItemData(
        icon: Icons.water_drop_rounded,
        label: 'Kelembapan',
        value: '${current.relativeHumidity2m}%',
      ),
      _DetailItemData(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value: '${current.windSpeed10m.toStringAsFixed(1)} km/jam',
      ),
      _DetailItemData(
        icon: Icons.grain_rounded,
        label: 'Curah Hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
      ),
      _DetailItemData(
        icon: Icons.umbrella_rounded,
        label: 'Peluang Hujan',
        value: todayForecast != null
            ? '${todayForecast!.precipitationProbabilityMax}%'
            : '-',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailItemData {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItemData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _DailyForecastSection extends StatelessWidget {
  final List<DailyForecast> daily;
  final String Function(DateTime, int) dateFormatter;

  const _DailyForecastSection({
    required this.daily,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perkiraan Cuaca Harian',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (daily.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Data perkiraan harian tidak tersedia.'),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daily.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final item = daily[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          dateFormatter(item.date, index),
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        WeatherCodeHelper.getIcon(item.weatherCode),
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.precipitationProbabilityMax}%',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.temperature2mMin.round()}° / ${item.temperature2mMax.round()}°',
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyLocationState extends StatelessWidget {
  final VoidCallback onSearchPressed;

  const _EmptyLocationState({required this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_searching_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kota dipilih',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cari dan pilih kota terlebih dahulu untuk menampilkan informasi cuaca terkini dan perkiraan harian.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onSearchPressed,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Cari Lokasi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Cuaca',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
