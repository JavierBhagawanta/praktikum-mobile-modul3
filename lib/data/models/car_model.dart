import 'dart:convert';

// Helper function untuk mengubah List<dynamic> menjadi List<CarModel>
List<CarModel> carModelFromJson(String str) =>
    List<CarModel>.from(json.decode(str).map((x) => CarModel.fromJson(x)));

class CarModel {
  String id;
  String namaMobil;
  String tipeMobil;
  String gambarUrl;
  int hargaSewa;
  String driverId;

  CarModel({
    required this.id,
    required this.namaMobil,
    required this.tipeMobil,
    required this.gambarUrl,
    required this.hargaSewa,
    required this.driverId,
  });

  // Factory constructor untuk membuat objek CarModel dari Map (JSON)
factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
        // "id" diambil dari JSON "id", jika null pakai string kosong
        id: json["id"] ?? '', 
        
        // "namaMobil" (CamelCase) diambil dari JSON "nama_mobil" (Snake Case)
        namaMobil: json["nama_mobil"] ?? '', 
        tipeMobil: json["tipe_mobil"] ?? '',
        gambarUrl: json["gambar_url"] ?? '',
        
        // Konversi ke int (ini sudah aman dari error sebelumnya)
        hargaSewa: int.tryParse(json["harga_sewa"].toString()) ?? 0, 
        
        driverId: json["driverId"] ?? '',
      );
}