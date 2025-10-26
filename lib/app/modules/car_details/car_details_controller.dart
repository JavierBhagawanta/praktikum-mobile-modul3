import 'package:get/get.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/providers/car_api_service.dart';

class CarDetailsController extends GetxController {
  final CarApiService _apiService = CarApiService();

  // Ambil carId yang dikirim dari halaman home
  final String carId = Get.arguments;

  // Variabel observable untuk state
  var isLoading = true.obs;
  // Kita buat nullable, karena datanya belum ada di awal
  var car = Rxn<CarModel>();
  var driver = Rxn<DriverModel>();
  var errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    // Jalankan versi async-await saat halaman pertama dibuka
    fetchDetailsAsyncAwait();
  }

  // --- TUGAS 3: Implementasi Async-Await ---
  void fetchDetailsAsyncAwait() async {
    print("--- Menjalankan Chained Request (Async-Await) ---");
    try {
      isLoading(true);
      errorMessage(null); // Bersihkan error lama
      car(null); // Bersihkan data lama
      driver(null); // Bersihkan data lama

      // 1. Panggilan Pertama: Ambil data mobil
      final carResult = await _apiService.getSingleCar(carId);
      car(carResult); // Simpan data mobil

      // 2. Panggilan Kedua: Ambil data driver (BERDASARKAN hasil pertama)
      final driverResult = await _apiService.getDriverDetail(carResult.driverId);
      driver(driverResult); // Simpan data driver

    } catch (e) {
      print("Error (Async-Await): $e");
      errorMessage("Gagal memuat detail: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- TUGAS 3: Implementasi Callback Chaining (.then) ---
  void fetchDetailsCallback() {
    print("--- Menjalankan Chained Request (Callback) ---");
    isLoading(true);
    errorMessage(null);
    car(null);
    driver(null);

    // 1. Panggilan Pertama
    _apiService.getSingleCar(carId).then((carResult) {
      // Sukses panggilan pertama
      car(carResult);

      // 2. Panggilan Kedua (di dalam .then pertama)
      return _apiService.getDriverDetail(carResult.driverId).then((driverResult) {
        // Sukses panggilan kedua
        driver(driverResult);
        
      }).catchError((e) {
        // Gagal di panggilan kedua (driver)
        print("Error (Callback-Driver): $e");
        errorMessage("Gagal memuat driver: $e");
      });

    }).catchError((e) {
      // Gagal di panggilan pertama (mobil)
      print("Error (Callback-Mobil): $e");
      errorMessage("Gagal memuat mobil: $e");
      
    }).whenComplete(() {
      // Ini seperti 'finally'
      isLoading(false);
    });
  }
}