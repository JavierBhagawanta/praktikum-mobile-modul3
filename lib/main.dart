import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/controllers/theme_controller.dart';
import 'data/services/hive_service.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('File .env berhasil dimuat');
  } catch (e) {
    debugPrint('Warning: File .env tidak ditemukan. Pastikan file .env sudah dibuat di root project.');
    debugPrint('Copy env.example menjadi .env dan isi dengan kredensial Supabase Anda.');
  }
  
  // Initialize services
  final initialBinding = InitialBinding();
  initialBinding.dependencies();
  
  // Initialize Hive
  try {
    final hiveService = Get.find<HiveService>();
    await hiveService.init();
  } catch (e) {
    debugPrint('Error initializing Hive: $e');
  }
  
  // Initialize Supabase (optional - bisa di-comment jika belum setup)
  try {
    final supabaseService = Get.find<SupabaseService>();
    await supabaseService.init();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    debugPrint('Note: Supabase initialization failed. Please configure your Supabase URL and key.');
  }
  
  // Get theme controller
  final themeController = Get.find<ThemeController>();
  
  runApp(
    GetMaterialApp(
      title: "Sewa Mobil App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeController.themeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: initialBinding,
    ),
  );
}