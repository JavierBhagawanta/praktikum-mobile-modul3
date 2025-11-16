import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/car_model.dart';
import '../../../data/providers/car_api_service.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/models/hive_car_model.dart';
import '../settings/settings_controller.dart';

// Enum untuk melacak library apa yang sedang dipakai

class HomeController extends GetxController {
  final CarApiService _carApiService = CarApiService();
  final HiveService _hiveService = Get.find<HiveService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  var isLoading = true.obs;
  var carList = <CarModel>[].obs;
  
  // Variabel untuk menyimpan hasil eksperimen
  var currentLibrary = ApiLibrary.http.obs;
  var executionTime = 0.obs; // Waktu eksekusi dalam milidetik
  
  // List untuk menyimpan ID mobil yang sudah disimpan di Hive
  final _savedCarIds = <String>[].obs;
  
  // Getter untuk saved car IDs sebagai Set
  Set<String> get savedCarIds => _savedCarIds.toSet();

  @override
  void onInit() {
    super.onInit();
    // Load saved car IDs dari Hive
    _loadSavedCarIds();
    // Panggil fungsi http saat pertama kali dibuka
    fetchCars(ApiLibrary.http); 
  }

  // Load saved car IDs dari Hive
  void _loadSavedCarIds() {
    try {
      final savedCars = _hiveService.getAllCars();
      _savedCarIds.value = savedCars.map((car) => car.id).toList();
    } catch (e) {
      debugPrint('Error loading saved car IDs: $e');
    }
  }

  // Check apakah mobil sudah disimpan (reactive)
  bool isCarSaved(String carId) {
    // RxList sudah reactive, langsung check contains
    return _savedCarIds.contains(carId);
  }

  // Fungsi ini sekarang menerima parameter library mana yang mau dipakai
  void fetchCars(ApiLibrary library) async {
    try {
      isLoading(true);
      currentLibrary(library); // Set library yang sedang aktif
      carList.clear(); // Kosongkan list dulu

      Map<String, dynamic> result;

      // Logika untuk memilih fungsi berdasarkan parameter
      if (library == ApiLibrary.http) {
        result = await _carApiService.getAllCarsWithHttp();
      } else {
        result = await _carApiService.getAllCarsWithDio();
      }

      // Ambil data dan durasi dari Map
      final cars = result['data'] as List<CarModel>;
      final duration = result['duration'] as int;

      carList.assignAll(cars);
      executionTime(duration); // Simpan durasinya

    } catch (e) {
      debugPrint("Error mengambil data: $e");
      Get.snackbar("Error", "Gagal memuat data mobil: $e");
    } finally {
      isLoading(false);
    }
  }

  // ... (Tepat di bawah fungsi fetchCars) ...

  // --- TUGAS 2: FUNGSI UNTUK TEST ERROR ---
  void testErrorHandling() async {
    const String badId = "999"; // ID yang pasti tidak ada
    final library = currentLibrary.value; // Pakai library yang sedang dipilih

    Get.snackbar(
      "Memulai Uji Error ${library.name.toUpperCase()}",
      "Mencoba mengambil ID $badId. Cek konsol debug Anda.",
      snackPosition: SnackPosition.BOTTOM,
    );
    
    try {
      // Panggil fungsi yang akan gagal
      await _carApiService.getCarDetail(library, badId);
      
      // Ini tidak akan terpanggil jika error
      Get.snackbar(
        "Sukses", 
        "Aneh, ID $badId ditemukan.",
        backgroundColor: const Color(0xFF4CAF50),
      ); // <-- Pastikan ada ); di sini

    } catch (e) {
      // Tangkap error dan tampilkan
      Get.snackbar(
        "Error Tertangkap!",
        "Gagal: ${e.toString()}",
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
      ); // <-- Pastikan ada ); di sini
    }
  }

  // Save car to local storage (Hive)
  Future<void> saveCarToLocal(CarModel car) async {
    try {
      final hiveCar = HiveCarModel.fromCarModel(car);
      await _hiveService.saveCar(hiveCar);
      // Update saved car IDs
      if (!_savedCarIds.contains(car.id)) {
        _savedCarIds.add(car.id);
      }
      // Update hanya item spesifik ini dengan GetBuilder
      update(['bookmark_${car.id}']);
      // Update settings controller if it exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.updateLocalCarCount();
      } catch (e) {
        // Settings controller might not be initialized yet, ignore
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save car to local storage: $e');
    }
  }

  // Delete car from local storage (Hive)
  Future<void> deleteCarFromLocal(String carId) async {
    try {
      await _hiveService.deleteCar(carId);
      // Update saved car IDs
      _savedCarIds.remove(carId);
      // Update hanya item spesifik ini dengan GetBuilder
      update(['bookmark_$carId']);
      // Update settings controller if it exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.updateLocalCarCount();
      } catch (e) {
        // Settings controller might not be initialized yet, ignore
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete car from local storage: $e');
    }
  }

  // Save car to cloud storage
  Future<void> saveCarToCloud(CarModel car) async {
    try {
      if (!_supabaseService.isAuthenticated) {
        Get.snackbar('Error', 'Please sign in first to save to cloud');
        return;
      }
      
      final hiveCar = HiveCarModel.fromCarModel(car);
      await _supabaseService.saveCarToCloud(hiveCar);
      Get.snackbar('Success', '${car.namaMobil} saved to cloud storage');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save to cloud: ${e.toString()}');
    }
  }

  // Load cars from cloud storage
  Future<void> loadCarsFromCloud() async {
    try {
      if (!_supabaseService.isAuthenticated) {
        Get.snackbar('Error', 'Please sign in first to load from cloud');
        return;
      }
      
      isLoading(true);
      final cloudCars = await _supabaseService.getAllCarsFromCloud();
      
      // Convert dari Map ke CarModel
      final cars = cloudCars.map((map) => CarModel(
        id: map['id']?.toString() ?? '',
        namaMobil: map['nama_mobil'] ?? '',
        tipeMobil: map['tipe_mobil'] ?? '',
        gambarUrl: map['gambar_url'] ?? '',
        hargaSewa: int.tryParse(map['harga_sewa']?.toString() ?? '0') ?? 0,
        driverId: map['driver_id']?.toString() ?? '',
      )).toList();
      
      carList.assignAll(cars);
      currentLibrary(ApiLibrary.http);
      executionTime(0);
      
      // Update saved car IDs dari cloud
      _loadSavedCarIds();
      
      Get.snackbar('Success', 'Loaded ${cars.length} cars from cloud storage');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load from cloud: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Load cars from Hive
  Future<void> loadCarsFromHive() async {
    try {
      isLoading(true);
      final hiveCars = _hiveService.getAllCars();
      
      // Convert HiveCarModel ke CarModel
      final cars = hiveCars.map((hiveCar) => CarModel(
        id: hiveCar.id,
        namaMobil: hiveCar.namaMobil,
        tipeMobil: hiveCar.tipeMobil,
        gambarUrl: hiveCar.gambarUrl,
        hargaSewa: hiveCar.hargaSewa,
        driverId: hiveCar.driverId,
      )).toList();
      
      carList.assignAll(cars);
      _savedCarIds.value = hiveCars.map((car) => car.id).toList();
      // Update semua bookmark setelah load dari Hive
      for (final car in cars) {
        update(['bookmark_${car.id}']);
      }
      currentLibrary(ApiLibrary.http); // Set default library
      executionTime(0); // Reset execution time
      
      Get.snackbar('Success', 'Loaded ${cars.length} cars from local storage');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load cars from local storage: $e');
    } finally {
      isLoading(false);
    }
  }
}