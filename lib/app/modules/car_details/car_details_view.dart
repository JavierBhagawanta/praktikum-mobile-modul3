import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'car_details_controller.dart';

class CarDetailsView extends GetView<CarDetailsController> {
  const CarDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mobil & Driver'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Tombol Kontrol untuk Eksperimen ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: controller.fetchDetailsAsyncAwait,
                  child: const Text("Uji Async-Await"),
                ),
                ElevatedButton(
                  onPressed: controller.fetchDetailsCallback,
                  child: const Text("Uji Callback"),
                ),
              ],
            ),
            const Divider(height: 30),

            // --- Tampilan Data ---
            Obx(() {
              // 1. Saat Loading
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Jika Ada Error
              if (controller.errorMessage.value != null) {
                return Center(
                  child: Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // 3. Jika Data Sukses (pastikan tidak null)
              if (controller.car.value != null &&
                  controller.driver.value != null) {
                final car = controller.car.value!;
                final driver = controller.driver.value!;

                // Tampilan data sederhana
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.namaMobil,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp ${car.hargaSewa} / hari",
                      style: const TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Detail Driver:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(driver.namaDriver),
                      subtitle: Text("Rating: ${driver.rating}"),
                    )
                  ],
                );
              }

              // 4. Jika state tidak terduga (seharusnya tidak terjadi)
              return const Center(child: Text("Data tidak ditemukan."));
            }),
          ],
        ),
      ),
    );
  }
}