import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/car_model.dart';
import '../models/driver_model.dart';

enum ApiLibrary { http, dio }

class CarApiService {
  final String _baseUrl = "https://68fdf91a7c700772bb126dd9.mockapi.io/api/v1";
  
  // Siapkan instance Dio di sini agar kita bisa menambahkan interceptor
  final Dio _dio;

  // Constructor
  CarApiService() : _dio = Dio() {
    // --- TUGAS 2: AKTIFKAN LOG INTERCEPTOR DIO ---
    // Ini akan otomatis print semua request & response Dio ke konsol
    // Sesuai dengan poin "logging otomatis" di modul [cite: 171]
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      responseHeader: true,
      responseBody: true,
      requestBody: true,
    ));
  }


  // --- TUGAS 1: Implementasi HTTP ---
  Future<Map<String, dynamic>> getAllCarsWithHttp() async {
    final url = Uri.parse("$_baseUrl/mobil");
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(url);
      stopwatch.stop();
      if (response.statusCode == 200) {
        final cars = carModelFromJson(response.body);
        return {'data': cars, 'duration': stopwatch.elapsedMilliseconds};
      } else {
        // --- TUGAS 2: HTTP Error Handling ---
        // Kita print manual pesannya
        debugPrint("HTTP Error: Status Code ${response.statusCode}");
        throw Exception("Gagal memuat data (HTTP Status ${response.statusCode})");
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint("HTTP Catch Error: $e");
      throw Exception("Error: $e");
    }
  }

  // --- TUGAS 1: Implementasi DIO ---
  Future<Map<String, dynamic>> getAllCarsWithDio() async {
    final url = "$_baseUrl/mobil";
    final stopwatch = Stopwatch()..start();
    try {
      // Gunakan instance _dio yang sudah ada interceptor-nya
      final response = await _dio.get(url);
      stopwatch.stop();
      
      // Dio otomatis melempar error jika status code bukan 2xx, 
      // jadi kita tidak perlu cek 'if (response.statusCode == 200)'
      List<CarModel> cars = List<CarModel>.from(
        response.data.map((item) => CarModel.fromJson(item)),
      );
      return {'data': cars, 'duration': stopwatch.elapsedMilliseconds};

    } on DioException catch (e) {
      // --- TUGAS 2: DIO Error Handling ---
      // DioException memberi kita info lebih banyak, termasuk 'response'
      stopwatch.stop();
      debugPrint("DIO Catch Error: ${e.response?.statusCode} - ${e.message}");
      throw Exception("Error: $e");
    }
  }

  // --- TUGAS 2: FUNGSI UNTUK MENDAPATKAN ERROR ---
  Future<void> getCarDetail(ApiLibrary library, String carId) async {
    final url = "$_baseUrl/mobil/$carId";

    if (library == ApiLibrary.http) {
      // --- UJI ERROR HTTP ---
      debugPrint("\n--- Menguji Error HTTP (ID: $carId) ---");
      final response = await http.get(Uri.parse(url));
      
      // Cek manual, karena http tidak melempar error untuk 404
      if (response.statusCode != 200) {
        debugPrint("HTTP Error: Status ${response.statusCode}, Body: ${response.body}");
        throw Exception("HTTP Gagal mendapat detail: ${response.statusCode}");
      }
      // Jika sukses (tidak akan terjadi jika ID-nya 999)
      debugPrint("HTTP Sukses");
      
    } else {
      // --- UJI ERROR DIO ---
      debugPrint("\n--- Menguji Error DIO (ID: $carId) ---");
      // Dio akan otomatis melempar DioException jika status 404
      // Interceptor akan otomatis mencetak log detailnya
      await _dio.get(url);
      
      // Jika sukses (tidak akan terjadi jika ID-nya 999)
      debugPrint("DIO Sukses");
    }
  }

  // ... (setelah fungsi getCarDetail) ...

  // --- TUGAS 3: Fungsi untuk mengambil detail 1 mobil ---
  Future<CarModel> getSingleCar(String carId) async {
    final url = "$_baseUrl/mobil/$carId";
    try {
      final response = await _dio.get(url);
      
      // --- PERBAIKAN DIMULAI DI SINI ---
      dynamic responseData = response.data;
      Map<String, dynamic> carJson;

      if (responseData is List) {
        // Jika API mengembalikan array [{}], ambil elemen pertama
        carJson = responseData.first as Map<String, dynamic>;
      } else {
        // Jika API mengembalikan object {}
        carJson = responseData as Map<String, dynamic>;
      }
      
      // Ubah JSON Map menjadi CarModel
      return CarModel.fromJson(carJson);
      // --- PERBAIKAN SELESAI ---

    } on DioException catch (e) {
      print("DIO Catch Error (getSingleCar): ${e.message}");
      throw Exception("Gagal mendapat detail mobil: $e");
    }
  }
 
   // --- TUGAS 3: Fungsi untuk mengambil detail 1 driver ---
  Future<DriverModel> getDriverDetail(String driverId) async {
    final url = "$_baseUrl/driver/$driverId";
    try {
      final response = await _dio.get(url);
      
      // --- PERBAIKAN DIMULAI DI SINI ---
      dynamic responseData = response.data;
      Map<String, dynamic> driverJson;

      if (responseData is List) {
        // Jika API mengembalikan array [{}], ambil elemen pertama
        driverJson = responseData.first as Map<String, dynamic>;
      } else {
        // Jika API mengembalikan object {}
        driverJson = responseData as Map<String, dynamic>;
      }

      // Ubah JSON Map menjadi DriverModel
      return DriverModel.fromJson(driverJson);
      // --- PERBAIKAN SELESAI ---

    } on DioException catch (e) {
      print("DIO Catch Error (getDriverDetail): ${e.message}");
      throw Exception("Gagal mendapat detail driver: $e");
    }
  }
}