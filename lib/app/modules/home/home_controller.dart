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

  // List untuk menyimpan ID mobil yang sudah tersimpan di Cloud (Supabase)
  final _cloudSavedIds = <String>[].obs;

  // Getter untuk cloud saved IDs sebagai Set
  Set<String> get cloudSavedIds => _cloudSavedIds.toSet();

  // Check apakah mobil sudah tersimpan di cloud
  bool isCarSavedInCloud(String carId) {
    return _cloudSavedIds.contains(carId);
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved car IDs dari Hive
    _loadSavedCarIds();
    // Load data mobil manual
    loadMockCars();
    // Load cloud saved IDs (jika ada session)
    // jangan await agar tidak block UI
    loadCloudSavedIds();
  }

  // Load semua ID mobil yang tersimpan di Supabase (cloud)
  Future<void> loadCloudSavedIds() async {
    try {
      // Jika Supabase belum di-auth, kosongkan list
      if (!_supabaseService.isAuthenticated) {
        _cloudSavedIds.clear();
        return;
      }

      final cloudCars = await _supabaseService.getAllCarsFromCloud();
      final ids = cloudCars
          .map((map) => map['id']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      _cloudSavedIds.clear();
      _cloudSavedIds.addAll(ids);
      debugPrint('Loaded ${ids.length} saved cloud IDs: $ids');
    } catch (e) {
      debugPrint('Error loading cloud saved IDs: $e');
    }
  }

  // Load saved car IDs dari Hive
  void _loadSavedCarIds() {
    try {
      final savedCars = _hiveService.getAllCars();
      final savedIds = savedCars.map((car) => car.id).toList();
      // Clear dan set ulang untuk memastikan tidak ada duplikasi
      _savedCarIds.clear();
      _savedCarIds.addAll(savedIds);
      debugPrint('Loaded ${savedIds.length} saved car IDs from Hive: $savedIds');
      debugPrint('Current _savedCarIds list: ${_savedCarIds.toList()}');
    } catch (e) {
      debugPrint('Error loading saved car IDs: $e');
    }
  }

  // Check apakah mobil sudah disimpan (reactive)
  bool isCarSaved(String carId) {
    // Hanya check di list, jangan check di Hive setiap kali
    // karena akan slow dan bisa menyebabkan masalah
    // Hive check hanya dilakukan saat load atau save
    return _savedCarIds.contains(carId);
  }
  
  // Method untuk refresh saved car IDs dari Hive
  void refreshSavedCarIds() {
    _loadSavedCarIds();
  }

  // Fungsi ini sekarang menerima parameter library mana yang mau dipakai
  void fetchCars(ApiLibrary library) async {
    try {
      isLoading(true);
      currentLibrary(library); // Set library yang sedang aktif
      carList.clear(); // Kosongkan list dulu
      
      debugPrint('=== Fetching cars from API ===');
      debugPrint('Library: ${library.name.toUpperCase()}');
      debugPrint('Base URL: https://68fdf91a7c700772bb126dd9.mockapi.io/api/v1/mobil');

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

      debugPrint('Cars fetched: ${cars.length}');
      debugPrint('Duration: ${duration}ms');
      
      // Debug print setiap mobil yang di-fetch
      for (var car in cars) {
        debugPrint('  - ${car.namaMobil} (ID: ${car.id})');
      }

      carList.assignAll(cars);
      executionTime(duration); // Simpan durasinya
      
      // Refresh saved car IDs setelah fetch cars baru
      _loadSavedCarIds();
      
      // Update hanya bookmark untuk mobil yang ada di list saat ini
      // Ini memastikan UI sync dengan data Hive
      Future.microtask(() {
        for (final car in cars) {
          update(['bookmark_${car.id}']);
        }
      });
      
      if (cars.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data mobil dari API');
      }

    } catch (e) {
      debugPrint("Error mengambil data: $e");
      debugPrint("Stack trace: ${StackTrace.current}");
      Get.snackbar("Error", "Gagal memuat data mobil: $e");
      
      // Sebagai fallback, load dari Hive jika ada error
      debugPrint("Attempting to load from Hive as fallback...");
      await loadCarsFromHive();
    } finally {
      isLoading(false);
    }
  }

  // Load mock/hardcoded cars data
  void loadMockCars() {
    try {
      isLoading(true);
      currentLibrary(ApiLibrary.http);
      executionTime(0);
      
      // Data mobil hardcoded/manual
      final mockCars = [
        CarModel(
          id: '1',
          namaMobil: 'Toyota Avanza',
          tipeMobil: 'Keluarga',
          gambarUrl: 'https://via.placeholder.com/300x200?text=Toyota+Avanza',
          hargaSewa: 150000,
          driverId: 'drv_001',
        ),
        CarModel(
          id: '2',
          namaMobil: 'Honda CR-V',
          tipeMobil: 'SUV',
          gambarUrl: 'https://via.placeholder.com/300x200?text=Honda+CR-V',
          hargaSewa: 250000,
          driverId: 'drv_002',
        ),
        CarModel(
          id: '3',
          namaMobil: 'Suzuki Ertiga',
          tipeMobil: 'MPV',
          gambarUrl: 'https://via.placeholder.com/300x200?text=Suzuki+Ertiga',
          hargaSewa: 180000,
          driverId: 'drv_003',
        ),
        CarModel(
          id: '4',
          namaMobil: 'Daihatsu Xenia',
          tipeMobil: 'Keluarga',
          gambarUrl: 'https://via.placeholder.com/300x200?text=Daihatsu+Xenia',
          hargaSewa: 120000,
          driverId: 'drv_004',
        ),
        CarModel(
          id: '5',
          namaMobil: 'Mitsubishi Pajero',
          tipeMobil: 'SUV Mewah',
          gambarUrl: 'https://via.placeholder.com/300x200?text=Mitsubishi+Pajero',
          hargaSewa: 350000,
          driverId: 'drv_005',
        ),
        CarModel(
          id: '6',
          namaMobil: 'Toyota Fortuner',
          tipeMobil: 'SUV',
          gambarUrl: 'https://via.placeholder.com/300x200?text=Toyota+Fortuner',
          hargaSewa: 300000,
          driverId: 'drv_006',
        ),
      ];
      
      carList.assignAll(mockCars);
      _loadSavedCarIds();
      
      // Update semua bookmark
      Future.microtask(() {
        for (final car in mockCars) {
          update(['bookmark_${car.id}']);
        }
      });
      
      debugPrint('Mock cars loaded: ${mockCars.length} cars');
      
    } catch (e) {
      debugPrint('Error loading mock cars: $e');
      Get.snackbar('Error', 'Gagal memuat data: $e');
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
      // Check if car already saved
      if (isCarSaved(car.id)) {
        Get.snackbar('Info', '${car.namaMobil} sudah disimpan di local storage');
        return;
      }
      
      // Check di Hive juga
      if (_hiveService.carExists(car.id)) {
        // Update saved car IDs jika ada di Hive tapi belum di list
        if (!_savedCarIds.contains(car.id)) {
          _savedCarIds.add(car.id);
          update(['bookmark_${car.id}']);
        }
        Get.snackbar('Info', '${car.namaMobil} sudah disimpan di local storage');
        return;
      }
      
      final hiveCar = HiveCarModel.fromCarModel(car);
      await _hiveService.saveCar(hiveCar);
      
      // Verify bahwa mobil benar-benar tersimpan di Hive
      if (!_hiveService.carExists(car.id)) {
        throw Exception('Failed to verify car was saved');
      }
      
      // Update saved car IDs - hanya tambahkan ID mobil yang benar-benar tersimpan
      // Pastikan ID belum ada di list sebelum ditambahkan
      if (!_savedCarIds.contains(car.id)) {
        _savedCarIds.add(car.id);
        debugPrint('Added car ID to saved list: ${car.id}');
        debugPrint('Current saved car IDs: ${_savedCarIds.toList()}');
      }
      
      // Update HANYA item spesifik ini dengan GetBuilder
      // Jangan update semua item, hanya yang ID-nya sesuai
      update(['bookmark_${car.id}']);
      debugPrint('Updated bookmark for car: ${car.id}, Total saved: ${_savedCarIds.length}');
      
      // Update settings controller if it exists
      try {
        final settingsController = Get.find<SettingsController>();
        settingsController.updateLocalCarCount();
      } catch (e) {
        // Settings controller might not be initialized yet, ignore
      }
      
      Get.snackbar('Success', '${car.namaMobil} berhasil disimpan ke local storage');
    } catch (e) {
      final errorMessage = e.toString().contains('already saved')
          ? '${car.namaMobil} sudah disimpan sebelumnya'
          : 'Gagal menyimpan: ${e.toString()}';
      Get.snackbar('Error', errorMessage);
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

  // Toggle save/delete car in cloud
  Future<void> toggleCloudSave(CarModel car) async {
    try {
      if (!_supabaseService.isAuthenticated) {
        Get.snackbar('Error', 'Please sign in first to use cloud features');
        return;
      }

      // Check if car exists in cloud
      final existing = await _supabaseService.getCarByIdFromCloud(car.id);
      if (existing != null) {
        // Ask for confirmation to delete
        final confirmed = await Get.dialog<bool>(AlertDialog(
          title: const Text('Hapus dari Cloud?'),
          content: Text('Mobil ${car.namaMobil} sudah ada di cloud. Hapus dari cloud?'),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
            TextButton(onPressed: () => Get.back(result: true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
          ],
        ));

        if (confirmed == true) {
          await _supabaseService.deleteCarFromCloud(car.id);
          // Update cache ids
          _cloudSavedIds.remove(car.id);
          update(['bookmark_${car.id}']);
          Get.snackbar('Success', '${car.namaMobil} deleted from cloud');
        }
      } else {
        // Not found: save to cloud
        final hiveCar = HiveCarModel.fromCarModel(car);
        await _supabaseService.saveCarToCloud(hiveCar);
        // Update cache ids
        if (!_cloudSavedIds.contains(car.id)) {
          _cloudSavedIds.add(car.id);
          update(['bookmark_${car.id}']);
        }
        Get.snackbar('Success', '${car.namaMobil} saved to cloud');
      }
    } catch (e) {
      Get.snackbar('Error', 'Cloud operation failed: ${e.toString()}');
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