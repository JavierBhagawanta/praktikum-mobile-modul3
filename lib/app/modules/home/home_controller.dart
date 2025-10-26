import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/car_model.dart';
import '../../../data/providers/car_api_service.dart';

// Enum untuk melacak library apa yang sedang dipakai

class HomeController extends GetxController {
  final CarApiService _carApiService = CarApiService();

  var isLoading = true.obs;
  var carList = <CarModel>[].obs;
  
  // Variabel untuk menyimpan hasil eksperimen
  var currentLibrary = ApiLibrary.http.obs;
  var executionTime = 0.obs; // Waktu eksekusi dalam milidetik

  @override
  void onInit() {
    super.onInit();
    // Panggil fungsi http saat pertama kali dibuka
    fetchCars(ApiLibrary.http); 
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
}