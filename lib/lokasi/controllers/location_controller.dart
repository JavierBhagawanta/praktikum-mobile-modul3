import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  
  final Rx<LocationData?> currentLocation = Rx<LocationData?>(null);
  final RxList<LocationData> locationHistory = <LocationData>[].obs;
  final RxBool isTracking = false.obs;
  final RxBool isPaused = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LocationProvider?> currentProvider = Rx<LocationProvider?>(null);
  
  StreamSubscription<LocationData>? _locationSubscription;
  DateTime? _firstPositionTime;
  DateTime? _trackingStartTime;
  
  // Statistics
  final RxDouble totalDistance = 0.0.obs; // in meters
  final RxDouble currentSpeed = 0.0.obs; // in m/s
  final RxInt updateCount = 0.obs;
  final RxDouble averageUpdateRate = 0.0.obs; // updates per second
  
  DateTime? get firstPositionTime => _firstPositionTime;
  
  static const int maxHistorySize = 1000; // Limit history untuk optimasi memory

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    bool hasPermission = await _locationService.requestPermissions();
    if (!hasPermission) {
      errorMessage.value = 'Location permissions denied';
    }
  }

  Future<void> startTracking(LocationProvider provider) async {
    try {
      // Stop any existing tracking first
      await stopTracking();
      
      // Wait a bit to ensure previous stream is fully closed
      await Future.delayed(const Duration(milliseconds: 300));
      
      isTracking.value = true;
      isPaused.value = false;
      currentProvider.value = provider;
      locationHistory.clear();
      _firstPositionTime = null;
      _trackingStartTime = DateTime.now();
      errorMessage.value = '';
      
      // Reset statistics
      totalDistance.value = 0.0;
      currentSpeed.value = 0.0;
      updateCount.value = 0;
      averageUpdateRate.value = 0.0;

      // Subscribe to location stream - akan terus update sampai stopTracking dipanggil
      _locationSubscription = _locationService.getLocationStream(provider).listen(
        (LocationData location) {
          // Skip jika paused, tapi tetap terima update untuk memastikan stream aktif
          if (isPaused.value) {
            // Tetap update current location meski paused (untuk UI)
            currentLocation.value = location;
            return;
          }
          
          final now = DateTime.now();
          final previousLocation = currentLocation.value;
          
          // Update location - ini akan terus terjadi selama stream aktif
          currentLocation.value = location;
          
          // Limit history size untuk optimasi memory
          if (locationHistory.length >= maxHistorySize) {
            locationHistory.removeAt(0);
          }
          locationHistory.add(location);
          
          _firstPositionTime ??= now;
          updateCount.value++;
          
          // Calculate distance and speed
          if (previousLocation != null) {
            final distance = Geolocator.distanceBetween(
              previousLocation.latitude,
              previousLocation.longitude,
              location.latitude,
              location.longitude,
            );
            totalDistance.value += distance;
            
            // Calculate speed (m/s)
            final timeDiff = location.timestamp.difference(previousLocation.timestamp).inSeconds;
            if (timeDiff > 0) {
              currentSpeed.value = distance / timeDiff;
            }
          }
          
          // Calculate average update rate
          if (_trackingStartTime != null) {
            final elapsed = now.difference(_trackingStartTime!).inSeconds;
            if (elapsed > 0) {
              averageUpdateRate.value = updateCount.value / elapsed;
            }
          }
          
          // Clear error jika berhasil dapat update
          if (errorMessage.value.isNotEmpty) {
            errorMessage.value = '';
          }
        },
        onError: (error) {
          errorMessage.value = 'Error: $error';
          // Jangan stop tracking, stream akan terus mencoba
          debugPrint('Location stream error: $error - Continuing...');
        },
        cancelOnError: false, // Terus listening meski ada error
        onDone: () {
          // Stream selesai (tidak seharusnya terjadi kecuali stopTracking dipanggil)
          debugPrint('Location stream done');
          if (isTracking.value) {
            errorMessage.value = 'Location stream ended unexpectedly';
            isTracking.value = false;
          }
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to start tracking: $e';
      isTracking.value = false;
      debugPrint('Failed to start tracking: $e');
    }
  }

  Future<void> stopTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationService.stopLocationStream();
    isTracking.value = false;
    isPaused.value = false;
    currentProvider.value = null;
    _trackingStartTime = null;
  }
  
  void pauseTracking() {
    isPaused.value = true;
  }
  
  void resumeTracking() {
    isPaused.value = false;
  }
  
  Future<void> switchProvider(LocationProvider newProvider) async {
    if (!isTracking.value) return;
    
    final currentHistory = List<LocationData>.from(locationHistory);
    final currentDistance = totalDistance.value;
    
    await stopTracking();
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Restore history and distance
    locationHistory.value = currentHistory;
    totalDistance.value = currentDistance;
    
    await startTracking(newProvider);
  }

  Future<LocationData?> getSingleLocation(LocationProvider provider) async {
    try {
      errorMessage.value = '';
      LocationData? location = await _locationService.getCurrentLocation(provider);
      if (location != null) {
        currentLocation.value = location;
      }
      return location;
    } catch (e) {
      errorMessage.value = 'Failed to get location: $e';
      return null;
    }
  }

  void clearHistory() {
    locationHistory.clear();
    currentLocation.value = null;
    _firstPositionTime = null;
    _trackingStartTime = null;
    totalDistance.value = 0.0;
    currentSpeed.value = 0.0;
    updateCount.value = 0;
    averageUpdateRate.value = 0.0;
  }
  
  // Helper methods untuk statistik
  String getFormattedDistance() {
    if (totalDistance.value < 1000) {
      return '${totalDistance.value.toStringAsFixed(1)} m';
    } else {
      return '${(totalDistance.value / 1000).toStringAsFixed(2)} km';
    }
  }
  
  String getFormattedSpeed() {
    // Convert m/s to km/h
    final speedKmh = currentSpeed.value * 3.6;
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }
  
  Duration? getTrackingDuration() {
    if (_trackingStartTime == null) return null;
    return DateTime.now().difference(_trackingStartTime!);
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}

