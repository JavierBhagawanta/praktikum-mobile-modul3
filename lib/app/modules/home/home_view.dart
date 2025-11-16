import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../../data/providers/car_api_service.dart';
import '../../routes/app_pages.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // --- INI BAGIAN BARU: TOMBOL KONTROL ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 8),
                // Tombol untuk load dari Hive dan Cloud
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.loadCarsFromHive,
                        icon: const Icon(Icons.storage),
                        label: Obx(() => Text(
                          'Hive (${controller.savedCarIds.length})'
                        )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.loadCarsFromCloud,
                        icon: const Icon(Icons.cloud),
                        label: const Text('Cloud'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                        ),
                      ),
                    ),
                  ],
                ),
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
                  final carId = car.id; // Capture carId untuk digunakan di dalam Obx
                  return ListTile(
                    key: ValueKey(car.id), // Key unik untuk setiap item
                    leading: const Icon(Icons.directions_car),
                    title: Text(car.namaMobil),
                    subtitle: Text(car.tipeMobil),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Rp ${car.hargaSewa}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        GetBuilder<HomeController>(
                          id: 'bookmark_$carId', // ID unik per item
                          builder: (ctrl) {
                            final isSaved = ctrl.isCarSaved(carId);
                            return PopupMenuButton<String>(
                              icon: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: isSaved ? Colors.blue : null,
                              ),
                              tooltip: isSaved
                                  ? 'Sudah disimpan - Pilih aksi'
                                  : 'Simpan ke Storage',
                              onSelected: (value) {
                                if (value == 'save_local') {
                                  ctrl.saveCarToLocal(car);
                                } else if (value == 'save_cloud') {
                                  ctrl.saveCarToCloud(car);
                                } else if (value == 'delete_local') {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Hapus dari Local Storage?'),
                                      content: Text('Apakah Anda yakin ingin menghapus ${car.namaMobil} dari local storage?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ctrl.deleteCarFromLocal(carId);
                                            Get.back();
                                          },
                                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                if (!isSaved) ...[
                                  const PopupMenuItem(
                                    value: 'save_local',
                                    child: Row(
                                      children: [
                                        Icon(Icons.storage, size: 20),
                                        SizedBox(width: 8),
                                        Text('Simpan ke Hive'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'save_cloud',
                                    child: Row(
                                      children: [
                                        Icon(Icons.cloud, size: 20),
                                        SizedBox(width: 8),
                                        Text('Simpan ke Cloud'),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  const PopupMenuItem(
                                    value: 'delete_local',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Hapus dari Hive', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.toNamed(
                        Routes.DETAILS,
                        arguments: car.id,
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