import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_data.dart';

class LocationMap extends StatefulWidget {
  final LocationData? currentLocation;
  final List<LocationData> locationHistory;
  final bool showPath;
  final bool autoFollow;

  const LocationMap({
    super.key,
    this.currentLocation,
    this.locationHistory = const [],
    this.showPath = true,
    this.autoFollow = true,
  });

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final MapController _mapController = MapController();
  LatLng? _lastCenter;

  @override
  void didUpdateWidget(LocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-follow current location
    if (widget.autoFollow &&
        widget.currentLocation != null &&
        widget.currentLocation != oldWidget.currentLocation) {
      final newCenter = LatLng(
        widget.currentLocation!.latitude,
        widget.currentLocation!.longitude,
      );

      // Smooth animation ke lokasi baru
      _mapController.move(newCenter, _mapController.camera.zoom);
      _lastCenter = newCenter;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LatLng center = widget.currentLocation != null
        ? LatLng(
            widget.currentLocation!.latitude,
            widget.currentLocation!.longitude,
          )
        : _lastCenter ?? const LatLng(-6.2088, 106.8456); // Default: Jakarta

    List<LatLng> pathPoints = widget.locationHistory
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    // Smooth path dengan mengurangi noise
    List<LatLng> smoothedPath = _smoothPath(pathPoints);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
        minZoom: 5.0,
        maxZoom: 18.0,
        onMapReady: () {
          if (widget.currentLocation != null) {
            _mapController.move(
              LatLng(
                widget.currentLocation!.latitude,
                widget.currentLocation!.longitude,
              ),
              15.0,
            );
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tes',
        ),
        if (widget.showPath && smoothedPath.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: smoothedPath,
                strokeWidth: 4.0,
                color: Colors.blue.withValues(alpha: 0.7),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (widget.currentLocation != null)
              Marker(
                point: LatLng(
                  widget.currentLocation!.latitude,
                  widget.currentLocation!.longitude,
                ),
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle untuk animasi
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.currentLocation!.provider == 'network'
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    // Icon utama
                    Icon(
                      Icons.location_on,
                      color: widget.currentLocation!.provider == 'network'
                          ? Colors.orange
                          : Colors.red,
                      size: 40,
                    ),
                  ],
                ),
              ),
            // Show only recent history markers untuk performa
            ...widget.locationHistory
                .skip(
                  widget.locationHistory.length > 50
                      ? widget.locationHistory.length - 50
                      : 0,
                )
                .map((loc) {
                  return Marker(
                    point: LatLng(loc.latitude, loc.longitude),
                    width: 8,
                    height: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: loc.provider == 'network'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ],
    );
  }

  // Simple smoothing untuk mengurangi noise pada path
  List<LatLng> _smoothPath(List<LatLng> path) {
    if (path.length < 3) return path;

    List<LatLng> smoothed = [path.first];

    for (int i = 1; i < path.length - 1; i++) {
      // Simple moving average
      final prev = path[i - 1];
      final curr = path[i];
      final next = path[i + 1];

      final smoothedLat = (prev.latitude + curr.latitude + next.latitude) / 3;
      final smoothedLng =
          (prev.longitude + curr.longitude + next.longitude) / 3;

      smoothed.add(LatLng(smoothedLat, smoothedLng));
    }

    smoothed.add(path.last);
    return smoothed;
  }
}
