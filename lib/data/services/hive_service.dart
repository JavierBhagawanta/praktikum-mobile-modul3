import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/hive_car_model.dart';

class HiveService extends GetxService {
  static const String _boxName = 'carsBox';
  Box<Map>? _box;

  // Getter untuk box
  Box<Map>? get box => _box;

  // Initialize Hive
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Open box dengan type Map untuk fleksibilitas
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<Map>(_boxName);
      } else {
        _box = Hive.box<Map>(_boxName);
      }
      
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  // Check if car already exists
  bool carExists(String carId) {
    try {
      return _box?.containsKey(carId) ?? false;
    } catch (e) {
      debugPrint('Error checking car existence: $e');
      return false;
    }
  }

  // Save car to local storage
  Future<void> saveCar(HiveCarModel car) async {
    try {
      // Check if car already exists
      if (carExists(car.id)) {
        throw Exception('Car already saved in local storage');
      }
      
      // Save ke Hive
      await _box?.put(car.id, car.toMap());
      
      // Verify bahwa data benar-benar tersimpan
      final saved = _box?.get(car.id);
      if (saved == null) {
        throw Exception('Failed to verify car was saved');
      }
      
      debugPrint('Car saved to local storage: ${car.namaMobil} (ID: ${car.id})');
      debugPrint('Total cars in Hive: ${_box?.length ?? 0}');
    } catch (e) {
      debugPrint('Failed to save car: $e');
      rethrow;
    }
  }

  // Get all cars from local storage
  List<HiveCarModel> getAllCars() {
    try {
      if (_box == null) return [];
      return _box!.values
          .map((map) => HiveCarModel.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    } catch (e) {
      debugPrint('Error getting cars: $e');
      return [];
    }
  }

  // Get car by id
  HiveCarModel? getCarById(String id) {
    try {
      final map = _box?.get(id);
      if (map == null) return null;
      return HiveCarModel.fromMap(Map<String, dynamic>.from(map));
    } catch (e) {
      debugPrint('Error getting car: $e');
      return null;
    }
  }

  // Delete car from local storage
  Future<void> deleteCar(String id) async {
    try {
      await _box?.delete(id);
      Get.snackbar('Success', 'Car deleted from local storage');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete car: $e');
      rethrow;
    }
  }

  // Clear all cars
  Future<void> clearAllCars() async {
    try {
      await _box?.clear();
      Get.snackbar('Success', 'All cars cleared from local storage');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear cars: $e');
      rethrow;
    }
  }

  // Get count of cars
  int getCarCount() {
    return _box?.length ?? 0;
  }
}

