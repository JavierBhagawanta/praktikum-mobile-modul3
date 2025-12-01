import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/location_controller.dart';
import '../controllers/experiment_controller.dart';
import '../services/location_service.dart';
import '../widgets/location_map.dart';

class StaticExperimentView extends StatelessWidget {
  const StaticExperimentView({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find<LocationController>();
    final ExperimentController experimentController = Get.find<ExperimentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksperimen Statis'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Obx(() => SingleChildScrollView(
        child: Column(
          children: [
            // Map
            SizedBox(
              height: 300,
              child: LocationMap(
                currentLocation: locationController.currentLocation.value,
                locationHistory: [
                  ...experimentController.networkData,
                  ...experimentController.gpsData,
                ],
                showPath: false,
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Eksperimen Statis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Catat lokasi untuk Network dan GPS.\n'
                            'Lakukan eksperimen di posisi Anda saat ini (indoor atau outdoor).',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final location = await locationController
                                .getSingleLocation(LocationProvider.network);
                            if (location != null) {
                              experimentController.recordNetworkLocation(location);
                            }
                          },
                          icon: const Icon(Icons.wifi),
                          label: const Text('Record Network'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final location = await locationController
                                .getSingleLocation(LocationProvider.gps);
                            if (location != null) {
                              experimentController.recordGpsLocation(location);
                            }
                          },
                          icon: const Icon(Icons.satellite),
                          label: const Text('Record GPS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (locationController.errorMessage.value.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        locationController.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Network Data
                  _buildDataSection(
                    'Network Location',
                    experimentController.networkData,
                    Colors.orange,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // GPS Data
                  _buildDataSection(
                    'GPS Location',
                    experimentController.gpsData,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Comparison
                  if (experimentController.networkData.isNotEmpty &&
                      experimentController.gpsData.isNotEmpty)
                    _buildComparisonSection(experimentController),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: () {
                      experimentController.clearData();
                      locationController.clearHistory();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear Data'),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildDataSection(String title, List data, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            if (data.isEmpty)
              const Text('No data recorded yet')
            else
              ...data.map((location) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
                    Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
                    Text('Accuracy: ${location.accuracy?.toStringAsFixed(2) ?? "N/A"} m'),
                    Text('Time: ${DateFormat('HH:mm:ss').format(location.timestamp)}'),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(ExperimentController controller) {
    final network = controller.networkData;
    final gps = controller.gpsData;
    
    double? networkAvgAccuracy;
    double? gpsAvgAccuracy;
    
    if (network.isNotEmpty) {
      final accuracies = network.where((d) => d.accuracy != null).map((d) => d.accuracy!);
      if (accuracies.isNotEmpty) {
        networkAvgAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;
      }
    }
    
    if (gps.isNotEmpty) {
      final accuracies = gps.where((d) => d.accuracy != null).map((d) => d.accuracy!);
      if (accuracies.isNotEmpty) {
        gpsAvgAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;
      }
    }

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perbandingan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Network - Count: ${network.length}, Avg Accuracy: ${networkAvgAccuracy?.toStringAsFixed(2) ?? "N/A"} m'),
            Text('GPS - Count: ${gps.length}, Avg Accuracy: ${gpsAvgAccuracy?.toStringAsFixed(2) ?? "N/A"} m'),
            if (networkAvgAccuracy != null && gpsAvgAccuracy != null)
              Text(
                'Difference: ${(gpsAvgAccuracy - networkAvgAccuracy).abs().toStringAsFixed(2)} m',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
