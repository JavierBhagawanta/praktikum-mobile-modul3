class DriverModel {
  String id;
  String namaDriver;
  String noHp;
  String alamat;
  String status;
  double rating;

  DriverModel({
    required this.id,
    required this.namaDriver,
    required this.noHp,
    required this.alamat,
    required this.status,
    required this.rating,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json["id"] ?? '',
        namaDriver: json["nama_driver"] ?? '',
        noHp: json["no_hp"] ?? '',
        alamat: json["alamat"] ?? '',
        status: json["status"] ?? '',
        rating: (json["rating"] ?? 0.0).toDouble(),
      );
}