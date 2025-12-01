import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../controllers/experiment_controller.dart';
import 'static_experiment_view.dart';
import 'moving_experiment_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(LocationController());
    Get.put(ExperimentController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking Experiments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pilih Eksperimen:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildExperimentCard(
              context,
              'Eksperimen 1 & 2: Statis',
              'Uji akurasi Network vs GPS. Lakukan di posisi Anda saat ini (indoor atau outdoor)',
              Icons.location_on,
              Colors.green,
              () => Get.to(() => const StaticExperimentView()),
            ),
            const SizedBox(height: 16),
            _buildExperimentCard(
              context,
              'Eksperimen 3: Bergerak (Real-time)',
              'Tracking pergerakan dengan Network dan GPS',
              Icons.directions_run,
              Colors.blue,
              () => Get.to(() => const MovingExperimentView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

