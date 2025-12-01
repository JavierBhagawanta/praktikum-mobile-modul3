import 'package:get/get.dart';
import '../models/location_data.dart';
import 'location_controller.dart';

class ExperimentController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();
  
  final RxList<LocationData> networkData = <LocationData>[].obs;
  final RxList<LocationData> gpsData = <LocationData>[].obs;
  
  final RxBool isRecording = false.obs;
  final RxString experimentType = ''.obs; // 'outdoor', 'indoor', 'moving'

  void startExperiment(String type) {
    experimentType.value = type;
    networkData.clear();
    gpsData.clear();
    isRecording.value = true;
  }

  void stopExperiment() {
    isRecording.value = false;
    locationController.stopTracking();
  }

  void recordNetworkLocation(LocationData location) {
    networkData.add(location);
  }

  void recordGpsLocation(LocationData location) {
    gpsData.add(location);
  }

  Map<String, dynamic> getComparisonData() {
    if (networkData.isEmpty && gpsData.isEmpty) {
      return {};
    }

    double? networkAvgAccuracy;
    double? gpsAvgAccuracy;
    
    if (networkData.isNotEmpty) {
      networkAvgAccuracy = networkData
          .where((d) => d.accuracy != null)
          .map((d) => d.accuracy!)
          .reduce((a, b) => a + b) / 
          networkData.where((d) => d.accuracy != null).length;
    }
    
    if (gpsData.isNotEmpty) {
      gpsAvgAccuracy = gpsData
          .where((d) => d.accuracy != null)
          .map((d) => d.accuracy!)
          .reduce((a, b) => a + b) / 
          gpsData.where((d) => d.accuracy != null).length;
    }

    return {
      'network_count': networkData.length,
      'gps_count': gpsData.length,
      'network_avg_accuracy': networkAvgAccuracy,
      'gps_avg_accuracy': gpsAvgAccuracy,
      'network_locations': networkData.map((d) => d.toJson()).toList(),
      'gps_locations': gpsData.map((d) => d.toJson()).toList(),
    };
  }

  void clearData() {
    networkData.clear();
    gpsData.clear();
    experimentType.value = '';
  }
}


