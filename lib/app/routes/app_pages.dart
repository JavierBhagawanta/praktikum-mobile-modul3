import 'package:get/get.dart';
// --- IMPORT FILE BARU KITA ---
import '../modules/car_details/car_details_binding.dart';
import '../modules/car_details/car_details_view.dart';
// ------------------------------
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // --- TAMBAHKAN GETPAGE BARU INI ---
    GetPage(
      name: _Paths.DETAILS,
      page: () => const CarDetailsView(),
      binding: CarDetailsBinding(),
    ),
    // ----------------------------------
  ];
}