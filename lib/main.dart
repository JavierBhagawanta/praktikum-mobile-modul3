import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart'; // File ini akan kita buat

void main() {
  runApp(
    GetMaterialApp(
      title: "Sewa Mobil App",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL, // Halaman awal
      getPages: AppPages.routes,     // Daftar semua halaman
    ),
  );
}