import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/location_data.dart';

enum LocationProvider { network, gps }

class LocationService {
  Stream<LocationData>? _locationStream;
  StreamSubscription<Position>? _positionSubscription;
  StreamController<LocationData>? _streamController;
  LocationProvider? _currentProvider;

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Request background location if needed
    await Permission.locationAlways.request();
    
    return true;
  }

  Stream<LocationData> getLocationStream(LocationProvider provider) {
    // Stop existing stream first
    stopLocationStream();
    
    _currentProvider = provider;
    
    // Create location settings without cache
    LocationSettings locationSettings;
    
    if (Platform.isAndroid) {
      if (provider == LocationProvider.network) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 5, // meters - lebih sensitif untuk tracking
          forceLocationManager: false, // Use network provider
          intervalDuration: const Duration(seconds: 2), // Update lebih cepat
        );
      } else {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3, // meters - lebih presisi untuk GPS
          forceLocationManager: true, // Force GPS, don't use network
          intervalDuration: const Duration(seconds: 1), // Update lebih cepat untuk GPS
        );
      }
    } else {
      // iOS settings
      if (provider == LocationProvider.network) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.low,
          distanceFilter: 5,
        );
      } else {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 3,
        );
      }
    }

    // Create stream controller for better control
    _streamController = StreamController<LocationData>.broadcast();
    
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        // Always add position updates - stream akan terus berjalan
        // Terima semua update dari stream, tidak ada filter karena stream sudah fresh
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.add(
            LocationData(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
              timestamp: position.timestamp,
              provider: provider == LocationProvider.network ? 'network' : 'gps',
            ),
          );
        }
      },
      onError: (error) {
        // Log error tapi jangan stop stream
        debugPrint('Location stream error: $error');
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.addError(error);
        }
      },
      cancelOnError: false, // Terus berjalan meski ada error
      onDone: () {
        // Stream selesai, tutup controller
        debugPrint('Location stream done');
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.close();
        }
      },
    );

    _locationStream = _streamController!.stream;
    return _locationStream!;
  }

  Future<LocationData?> getCurrentLocation(LocationProvider provider) async {
    try {
      LocationSettings locationSettings;
      
      if (Platform.isAndroid) {
        if (provider == LocationProvider.network) {
          locationSettings = AndroidSettings(
            accuracy: LocationAccuracy.low,
            forceLocationManager: false,
          );
        } else {
          locationSettings = AndroidSettings(
            accuracy: LocationAccuracy.high,
            forceLocationManager: true, // Force GPS
          );
        }
      } else {
        // iOS
        if (provider == LocationProvider.network) {
          locationSettings = AppleSettings(
            accuracy: LocationAccuracy.low,
          );
        } else {
          locationSettings = AppleSettings(
            accuracy: LocationAccuracy.best,
          );
        }
      }

      // Get fresh location, don't use cache
      // Settings already configured to get fresh location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // Verify position is fresh (not cached)
      final now = DateTime.now();
      final positionTime = position.timestamp;
      final age = now.difference(positionTime).inSeconds;
      
      // Reject if position is older than 5 seconds and try again
      if (age > 5) {
        // Try to get a new one with fresh settings
        position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
        provider: provider == LocationProvider.network ? 'network' : 'gps',
      );
    } catch (e) {
      return null;
    }
  }

  void stopLocationStream() {
    // Cancel subscription terlebih dahulu
    _positionSubscription?.cancel();
    _positionSubscription = null;
    
    // Close stream controller jika masih terbuka
    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.close();
    }
    _streamController = null;
    _locationStream = null;
    _currentProvider = null;
    
    debugPrint('Location stream stopped');
  }

  LocationProvider? get currentProvider => _currentProvider;
}

