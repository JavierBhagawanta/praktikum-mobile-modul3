class HiveCarModel {
  String id;
  String namaMobil;
  String tipeMobil;
  String gambarUrl;
  int hargaSewa;
  String driverId;
  DateTime savedAt;

  HiveCarModel({
    required this.id,
    required this.namaMobil,
    required this.tipeMobil,
    required this.gambarUrl,
    required this.hargaSewa,
    required this.driverId,
    required this.savedAt,
  });

  // Convert dari CarModel ke HiveCarModel
  factory HiveCarModel.fromCarModel(dynamic carModel) {
    return HiveCarModel(
      id: carModel.id,
      namaMobil: carModel.namaMobil,
      tipeMobil: carModel.tipeMobil,
      gambarUrl: carModel.gambarUrl,
      hargaSewa: carModel.hargaSewa,
      driverId: carModel.driverId,
      savedAt: DateTime.now(),
    );
  }

  // Convert ke Map untuk Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaMobil': namaMobil,
      'tipeMobil': tipeMobil,
      'gambarUrl': gambarUrl,
      'hargaSewa': hargaSewa,
      'driverId': driverId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  // Convert dari Map
  factory HiveCarModel.fromMap(Map<String, dynamic> map) {
    return HiveCarModel(
      id: map['id'] ?? '',
      namaMobil: map['namaMobil'] ?? '',
      tipeMobil: map['tipeMobil'] ?? '',
      gambarUrl: map['gambarUrl'] ?? '',
      hargaSewa: map['hargaSewa'] ?? 0,
      driverId: map['driverId'] ?? '',
      savedAt: DateTime.parse(map['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert ke Map untuk Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'nama_mobil': namaMobil,
      'tipe_mobil': tipeMobil,
      'gambar_url': gambarUrl,
      'harga_sewa': hargaSewa,
      'driver_id': driverId,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}

