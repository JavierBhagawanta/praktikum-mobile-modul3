import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/supabase_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize ThemeController
    Get.put(ThemeController(), permanent: true);
    
    // Initialize HiveService
    Get.put(HiveService(), permanent: true);
    
    // Initialize SupabaseService
    Get.put(SupabaseService(), permanent: true);
  }
}

