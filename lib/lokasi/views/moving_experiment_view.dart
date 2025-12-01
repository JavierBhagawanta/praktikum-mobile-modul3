import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/location_controller.dart';
import '../controllers/experiment_controller.dart';
import '../services/location_service.dart';
import '../widgets/location_map.dart';

class MovingExperimentView extends StatelessWidget {
  const MovingExperimentView({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController =
        Get.find<LocationController>();
    final ExperimentController experimentController =
        Get.find<ExperimentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksperimen 3: Bergerak (Real-time)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => locationController.isTracking.value
                ? IconButton(
                    icon: Icon(
                      locationController.isPaused.value
                          ? Icons.play_arrow
                          : Icons.pause,
                    ),
                    onPressed: () {
                      if (locationController.isPaused.value) {
                        locationController.resumeTracking();
                      } else {
                        locationController.pauseTracking();
                      }
                    },
                    tooltip: locationController.isPaused.value
                        ? 'Resume'
                        : 'Pause',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            // Map
            Expanded(
              child: LocationMap(
                currentLocation: locationController.currentLocation.value,
                locationHistory: locationController.locationHistory,
                showPath: true,
                autoFollow: true,
              ),
            ),

            // Controls and Info
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Provider Selection
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                locationController.isTracking.value &&
                                    locationController.currentProvider.value ==
                                        LocationProvider.network
                                ? null
                                : () async {
                                    if (locationController.isTracking.value) {
                                      await locationController.switchProvider(
                                        LocationProvider.network,
                                      );
                                    } else {
                                      await locationController.startTracking(
                                        LocationProvider.network,
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.wifi),
                            label: const Text('Network'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                locationController.isTracking.value &&
                                    locationController.currentProvider.value ==
                                        LocationProvider.gps
                                ? null
                                : () async {
                                    if (locationController.isTracking.value) {
                                      await locationController.switchProvider(
                                        LocationProvider.gps,
                                      );
                                    } else {
                                      await locationController.startTracking(
                                        LocationProvider.gps,
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.satellite),
                            label: const Text('GPS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Control Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: locationController.isTracking.value
                                ? () => locationController.stopTracking()
                                : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              locationController.clearHistory();
                              experimentController.clearData();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status indicator dengan update counter
                    if (locationController.isTracking.value)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: locationController.isPaused.value
                              ? Colors.orange[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated icon untuk menunjukkan tracking aktif
                            if (!locationController.isPaused.value)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                child: const SizedBox(),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              locationController.isPaused.value
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              color: locationController.isPaused.value
                                  ? Colors.orange
                                  : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              locationController.isPaused.value
                                  ? 'Paused'
                                  : 'Tracking Active - Continuous Updates',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: locationController.isPaused.value
                                    ? Colors.orange[900]
                                    : Colors.green[900],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Current Location Info
                    if (locationController.currentLocation.value != null)
                      _buildLocationInfo(
                        locationController.currentLocation.value!,
                      ),

                    const SizedBox(height: 8),

                    // Enhanced Statistics
                    _buildEnhancedStatistics(locationController),

                    if (locationController.errorMessage.value.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          locationController.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(location) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  location.provider == 'network' ? Icons.wifi : Icons.satellite,
                  size: 16,
                  color: location.provider == 'network'
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Current Location (${location.provider.toUpperCase()})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Lat: ${location.latitude.toStringAsFixed(6)}'),
            Text('Lng: ${location.longitude.toStringAsFixed(6)}'),
            Text(
              'Accuracy: ${location.accuracy?.toStringAsFixed(2) ?? "N/A"} m',
            ),
            Text('Time: ${DateFormat('HH:mm:ss').format(location.timestamp)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatistics(LocationController controller) {
    final history = controller.locationHistory;
    final firstTime = controller.firstPositionTime;
    final duration = controller.getTrackingDuration();

    String? timeToFirstFix;
    if (firstTime != null && history.isNotEmpty) {
      final fixDuration = history.first.timestamp.difference(firstTime);
      timeToFirstFix = '${fixDuration.inSeconds}s';
    }

    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Points',
                    '${history.length}',
                    Icons.location_on,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Distance',
                    controller.getFormattedDistance(),
                    Icons.straighten,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Speed',
                    controller.getFormattedSpeed(),
                    Icons.speed,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Update Rate',
                    '${controller.averageUpdateRate.value.toStringAsFixed(2)}/s',
                    Icons.update,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            if (timeToFirstFix != null)
              Text('Time to First Fix: $timeToFirstFix'),
            if (duration != null)
              Text('Duration: ${_formatDuration(duration)}'),
            if (controller.currentProvider.value != null)
              Text(
                'Mode: ${controller.currentProvider.value == LocationProvider.network ? "Network" : "GPS"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
