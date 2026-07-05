import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/core/services/location_service.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerArgs {
  const LocationPickerArgs({this.point, this.title});
  final LatLng? point;
  final String? title;
}

/// Free OSM map (no API key): tap or drag the pin, search an address, or
/// jump to the device position. Pops with the chosen [LatLng].
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({this.initial, super.key});

  final LocationPickerArgs? initial;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  static const _fallbackCenter = LatLng(18.5601, -68.3725); // Punta Cana

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _picked;
  List<GeocodeResult> _results = const [];
  bool _searching = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial?.point;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final position = await ref.read(locationServiceProvider).currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Device location unavailable here — search the address or tap the map instead.'),
      ));
      return;
    }
    setState(() => _picked = position);
    _mapController.move(position, 15);
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searching = true);
    try {
      final results = await ref.read(locationServiceProvider).search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
      if (results.length == 1) _selectResult(results.first);
    } catch (_) {
      if (!mounted) return;
      setState(() => _searching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address search failed — check your connection.')),
      );
    }
  }

  void _selectResult(GeocodeResult result) {
    setState(() {
      _picked = result.point;
      _results = const [];
    });
    _mapController.move(result.point, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initial?.title ?? 'Pin the business location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search address or place',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _searching ? null : _search,
                  child: _searching
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Search'),
                ),
              ],
            ),
          ),
          if (_results.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView(
                children: [
                  for (final result in _results)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(result.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _selectResult(result),
                    ),
                ],
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _picked ?? _fallbackCenter,
                initialZoom: _picked == null ? 5 : 14,
                onTap: (tapPosition, point) => setState(() => _picked = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.johannes.google_business_profile_manager',
                ),
                if (_picked != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _picked!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 44),
                    ),
                  ]),
                const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _locating ? null : _locate,
                    icon: _locating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                    label: const Text('Use my location'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _picked == null ? null : () => Navigator.of(context).pop(_picked),
                    icon: const Icon(Icons.check),
                    label: const Text('Use this spot'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
