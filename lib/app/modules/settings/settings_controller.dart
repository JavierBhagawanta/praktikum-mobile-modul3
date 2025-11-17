import 'package:get/get.dart';
import '../../../app/controllers/theme_controller.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/models/hive_car_model.dart';
import '../../../data/models/car_model.dart';

class SettingsController extends GetxController {
  final ThemeController _themeController = Get.find<ThemeController>();
  final HiveService _hiveService = Get.find<HiveService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable variables
  var localCarCount = 0.obs;
  var isAuthenticated = false.obs;
  var currentUserEmail = ''.obs;

  // Getters
  bool get isDarkMode => _themeController.isDarkMode;

  @override
  void onInit() {
    super.onInit();
    _updateLocalCarCount();
    _updateAuthStatus();
  }

  @override
  void onReady() {
    super.onReady();
    // Update data setiap kali view dibuka
    _updateLocalCarCount();
    _updateAuthStatus();
  }

  // Update local car count (public untuk bisa dipanggil dari controller lain)
  void updateLocalCarCount() {
    localCarCount.value = _hiveService.getCarCount();
  }

  // Private method untuk internal use
  void _updateLocalCarCount() {
    updateLocalCarCount();
  }

  // Update auth status (public untuk bisa dipanggil dari service)
  void updateAuthStatus() {
    isAuthenticated.value = _supabaseService.isAuthenticated;
    currentUserEmail.value = _supabaseService.currentUser?.email ?? '';
  }
  
  // Private method untuk internal use
  void _updateAuthStatus() {
    updateAuthStatus();
  }

  // Observable untuk loading states
  var isSyncing = false.obs;
  var isLoading = false.obs;

  // Toggle theme
  void toggleTheme() {
    _themeController.toggleTheme();
  }

  // Save car to local storage (Hive)
  Future<void> saveCarToLocal(CarModel car) async {
    try {
      final hiveCar = HiveCarModel.fromCarModel(car);
      await _hiveService.saveCar(hiveCar);
      _updateLocalCarCount(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to save car to local storage: $e');
    }
  }

  // Get all cars from local storage
  List<HiveCarModel> getLocalCars() {
    return _hiveService.getAllCars();
  }

  // Delete car from local storage
  Future<void> deleteCarFromLocal(String id) async {
    try {
      await _hiveService.deleteCar(id);
      _updateLocalCarCount(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete car: $e');
    }
  }

  // Clear local storage
  Future<void> clearLocalStorage() async {
    try {
      await _hiveService.clearAllCars();
      _updateLocalCarCount(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear local storage: $e');
    }
  }

  // Sign in to Supabase
  Future<void> signIn(String email, String password) async {
    try {
      isLoading(true);
      await _supabaseService.signIn(email, password);
      _updateAuthStatus(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Sign up to Supabase
  Future<void> signUp(String email, String password) async {
    try {
      isLoading(true);
      await _supabaseService.signUp(email, password);
      _updateAuthStatus(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign up: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Sign out from Supabase
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _updateAuthStatus(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: ${e.toString()}');
    }
  }

  // Sync local data to cloud
  Future<void> syncToCloud() async {
    try {
      if (!isAuthenticated.value) {
        Get.snackbar('Error', 'Please sign in first to sync to cloud');
        return;
      }

      isSyncing(true);
      final localCars = getLocalCars();
      await _supabaseService.syncToCloud(localCars);
      _updateLocalCarCount(); // Update observable
    } catch (e) {
      Get.snackbar('Error', 'Failed to sync to cloud: ${e.toString()}');
    } finally {
      isSyncing(false);
    }
  }

  // Get cars from cloud
  Future<List<Map<String, dynamic>>> fetchFromCloud() async {
    try {
      if (!isAuthenticated.value) {
        Get.snackbar('Error', 'Please sign in first to fetch from cloud');
        return [];
      }

      isLoading(true);
      final cars = await _supabaseService.getAllCarsFromCloud();
      return cars;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch from cloud: ${e.toString()}');
      return [];
    } finally {
      isLoading(false);
    }
  }
}

