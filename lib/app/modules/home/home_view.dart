import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
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
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.loadMockCars,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Muat Data"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol untuk load dari Hive
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Tidak ada data mobil.",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.loadMockCars,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Muat Data'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.loadCarsFromHive,
                        icon: const Icon(Icons.storage),
                        label: const Text('Muat dari Hive'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[100],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.carList.length,
                itemBuilder: (context, index) {
                  final car = controller.carList[index];
                  // Capture semua data yang diperlukan di luar GetBuilder
                  final carId = car.id;
                  final carName = car.namaMobil;
                  
                  return ListTile(
                    key: ValueKey('car_$carId'), // Key unik untuk setiap item
                    leading: const Icon(Icons.directions_car),
                    title: Text(carName),
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
                          id: 'bookmark_$carId',
                          builder: (ctrl) {
                            final isSaved = ctrl.isCarSaved(carId);
                            final currentCar = controller.carList[index];
                            
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Hive
                                IconButton(
                                  icon: Icon(
                                    isSaved ? Icons.storage : Icons.storage_outlined,
                                    color: isSaved ? Colors.green : Colors.grey,
                                  ),
                                  tooltip: isSaved ? 'Sudah di Hive' : 'Simpan ke Hive',
                                  onPressed: isSaved
                                      ? () {
                                          Get.dialog(
                                            AlertDialog(
                                              title: const Text('Hapus dari Hive?'),
                                              content: Text('Apakah Anda yakin ingin menghapus ${currentCar.namaMobil}?'),
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
                                      : () => ctrl.saveCarToLocal(currentCar),
                                ),
                                const SizedBox(width: 4),
                                // Tombol Cloud (toggle save/delete) with status indicator
                                Builder(builder: (context) {
                                  final isCloudSaved = ctrl.isCarSavedInCloud(carId);
                                  return IconButton(
                                    icon: Icon(
                                      isCloudSaved ? Icons.cloud_done : Icons.cloud_upload_outlined,
                                      color: isCloudSaved ? Colors.blue : Colors.blueGrey,
                                    ),
                                    tooltip: isCloudSaved ? 'Hapus dari Cloud' : 'Simpan ke Cloud',
                                    onPressed: () => ctrl.toggleCloudSave(currentCar),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.toNamed(
                        Routes.DETAILS,
                        arguments: carId,
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