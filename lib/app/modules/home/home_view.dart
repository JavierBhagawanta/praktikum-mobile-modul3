import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../../data/providers/car_api_service.dart';
import '../../routes/app_pages.dart'; // <-- TAMBAHKAN BARIS INI

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Judulnya akan berubah otomatis
        title: Obx(() => Text(
          'Daftar Mobil (via ${controller.currentLibrary.value.name.toUpperCase()})'
        )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- INI BAGIAN BARU: TOMBOL KONTROL ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => controller.fetchCars(ApiLibrary.http),
                  child: const Text("Uji HTTP"),
                ),
                ElevatedButton(
                  onPressed: () => controller.fetchCars(ApiLibrary.dio),
                  child: const Text("Uji DIO"),
                ),
                // --- TOMBOL BARU UNTUK TUGAS 2 ---
                ElevatedButton(
                  onPressed: controller.testErrorHandling, // Panggil fungsi error
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                  child: const Text("Uji Error 404"),
                ),
                // ---------------------------------
              ],
            ),
          ),
          // --- INI BAGIAN BARU: TAMPILAN WAKTU ---
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  controller.isLoading.value
                      ? "Mengukur waktu..."
                      : "Waktu Eksekusi: ${controller.executionTime.value} ms",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )),
          
          const Divider(),

          // --- INI BAGIAN LAMA: LISTVIEW ---
          // Kita bungkus dengan Expanded agar list-nya tidak error
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.carList.isEmpty) {
                return const Center(child: Text("Tidak ada data mobil."));
              }
              return ListView.builder(
                itemCount: controller.carList.length,
                itemBuilder: (context, index) {
                  final car = controller.carList[index];
                  return ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(car.namaMobil),
                    subtitle: Text(car.tipeMobil),
                    trailing: Text(
                      "Rp ${car.hargaSewa}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                  Get.toNamed(
                    Routes.DETAILS,
                    // --- PERBAIKI BAGIAN INI ---
                    // Kirim HANYA carId
                    arguments: car.id, 
                    // --------------------------
                  );
                },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}