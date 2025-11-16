import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../../app/controllers/theme_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle between dark and light theme'),
                    value: themeController.isDarkMode,
                    onChanged: (value) => controller.toggleTheme(),
                    secondary: Icon(
                      themeController.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Local Storage (Hive) Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local Storage (Hive)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Cars in Local Storage'),
                    subtitle: Text('${controller.localCarCount.value} cars saved'),
                  )),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final cars = controller.getLocalCars();
                      if (cars.isEmpty) {
                        Get.snackbar('Info', 'Tidak ada mobil yang disimpan di local storage');
                        return;
                      }
                      Get.dialog(
                        AlertDialog(
                          title: Text('Local Cars (${cars.length})'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: cars.length,
                              itemBuilder: (context, index) {
                                final car = cars[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: const Icon(Icons.directions_car),
                                    title: Text(car.namaMobil),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(car.tipeMobil),
                                        Text(
                                          'Disimpan: ${_formatDate(car.savedAt)}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Rp ${car.hargaSewa}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            Get.dialog(
                                              AlertDialog(
                                                title: const Text('Hapus Mobil?'),
                                                content: Text('Hapus ${car.namaMobil} dari local storage?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await controller.deleteCarFromLocal(car.id);
                                                      Get.back();
                                                      // Refresh dialog
                                                      final updatedCars = controller.getLocalCars();
                                                      if (updatedCars.isEmpty) {
                                                        Get.back(); // Close dialog jika sudah kosong
                                                      } else {
                                                        // Rebuild dialog dengan data baru
                                                        Get.back();
                                                        controller.updateLocalCarCount();
                                                      }
                                                    },
                                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Local Cars'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Clear Local Storage'),
                          content: const Text(
                            'Are you sure you want to clear all local storage? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.clearLocalStorage();
                                Get.back();
                              },
                              child: const Text('Clear', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Local Storage'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cloud Storage (Supabase) Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cloud Storage (Supabase)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => ListTile(
                    leading: const Icon(Icons.cloud),
                    title: const Text('Authentication Status'),
                    subtitle: Text(
                      controller.isAuthenticated.value
                          ? 'Signed in as: ${controller.currentUserEmail.value.isEmpty ? "Unknown" : controller.currentUserEmail.value}'
                          : 'Not signed in',
                    ),
                    trailing: Icon(
                      controller.isAuthenticated.value
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: controller.isAuthenticated.value
                          ? Colors.green
                          : Colors.red,
                    ),
                  )),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.isAuthenticated.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => controller.signOut(),
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => ElevatedButton.icon(
                            onPressed: controller.isSyncing.value
                                ? null
                                : () => controller.syncToCloud(),
                            icon: controller.isSyncing.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(controller.isSyncing.value
                                ? 'Syncing...'
                                : 'Sync to Cloud'),
                          )),
                          const SizedBox(height: 8),
                    Obx(() => OutlinedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => _showCloudCarsDialog(context),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download),
                      label: Text(controller.isLoading.value
                          ? 'Loading...'
                          : 'View Cloud Cars'),
                    )),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showSignInDialog(context),
                            icon: const Icon(Icons.login),
                            label: const Text('Sign In'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showSignUpDialog(context),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Sign Up'),
                          ),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'example@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Minimal 6 karakter',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    await controller.signIn(
                      emailController.text,
                      passwordController.text,
                    );
                    if (controller.isAuthenticated.value) {
                      Get.back();
                    }
                  },
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign In'),
          )),
        ],
      ),
    );
  }

  void _showSignUpDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Sign Up'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'example@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Minimal 6 karakter',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    await controller.signUp(
                      emailController.text,
                      passwordController.text,
                    );
                    if (controller.isAuthenticated.value) {
                      Get.back();
                    }
                  },
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign Up'),
          )),
        ],
      ),
    );
  }

  // Helper method untuk format tanggal
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Show cloud cars dialog
  Future<void> _showCloudCarsDialog(BuildContext context) async {
    try {
      final cars = await controller.fetchFromCloud();
      
      if (cars.isEmpty) {
        Get.snackbar('Info', 'No cars found in cloud storage');
        return;
      }
      
      // Tampilkan dialog dengan list cars dari cloud
      Get.dialog(
        AlertDialog(
          title: Text('Cloud Cars (${cars.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(car['nama_mobil'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(car['tipe_mobil'] ?? ''),
                        if (car['saved_at'] != null)
                          Text(
                            'Saved: ${_formatDate(DateTime.parse(car['saved_at']))}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    trailing: Text(
                      'Rp ${car['harga_sewa'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch from cloud: ${e.toString()}');
    }
  }
}

