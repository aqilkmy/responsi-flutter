import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch() {
    FocusScope.of(context).unfocus();
    context.read<LocationViewModel>().searchCities(_controller.text);
  }

  Future<void> _selectLocation(LocationModel location) async {
    final locationVm = context.read<LocationViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await locationVm.addToHistory(location);
    await weatherVm.selectLocation(location);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari & Lokasi Favorit'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                    onChanged: (value) {
                      setState(() {});
                      context
                          .read<LocationViewModel>()
                          .onSearchQueryChanged(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kota (misal: Yogyakarta)',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _controller.clear();
                                locationVm.clearSearch();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _performSearch,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(context, locationVm),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LocationViewModel locationVm) {
    if (locationVm.hasSearched) {
      if (locationVm.isSearching) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mencari lokasi...'),
            ],
          ),
        );
      }

      if (locationVm.errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  locationVm.errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      }

      if (locationVm.searchResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'Lokasi "${locationVm.lastQuery}" tidak ditemukan.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: locationVm.searchResults.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final loc = locationVm.searchResults[index];
          return _LocationCard(
            location: loc,
            isFavorite: locationVm.isFavorite(loc),
            onTap: () => _selectLocation(loc),
            onToggleFavorite: () => locationVm.toggleFavorite(loc),
          );
        },
      );
    }

    if (locationVm.favorites.isEmpty && locationVm.searchHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.travel_explore_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Cari Kota',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Ketik nama kota pada kolom pencarian untuk melihat cuaca atau menyimpannya ke favorit.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (locationVm.favorites.isNotEmpty) ...[
          Text(
            'Lokasi Favorit',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...locationVm.favorites.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LocationCard(
                location: loc,
                isFavorite: true,
                onTap: () => _selectLocation(loc),
                onToggleFavorite: () => locationVm.toggleFavorite(loc),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (locationVm.searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Pencarian',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => locationVm.clearHistory(),
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...locationVm.searchHistory.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LocationCard(
                location: loc,
                isFavorite: locationVm.isFavorite(loc),
                onTap: () => _selectLocation(loc),
                onToggleFavorite: () => locationVm.toggleFavorite(loc),
                onRemoveHistory: () => locationVm.removeFromHistory(loc),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemoveHistory;

  const _LocationCard({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.onRemoveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Icon(
          Icons.location_city_rounded,
          color: colorScheme.primary,
        ),
        title: Text(
          location.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          location.displaySubtitle.isNotEmpty
              ? '${location.displaySubtitle} (${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)})'
              : '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? colorScheme.primary : null,
              ),
            ),
            if (onRemoveHistory != null)
              IconButton(
                tooltip: 'Hapus dari riwayat',
                onPressed: onRemoveHistory,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
