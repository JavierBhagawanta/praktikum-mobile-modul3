# Perubahan Hive Storage - ID Auto-Generation

## Masalah
Ketika menyimpan mobil ke Hive local storage, field `id` sering kosong karena:
1. API response mungkin tidak memiliki field `id` yang konsisten
2. `CarModel.fromJson()` bisa menerima ID kosong

## Solusi
Implementasi auto-generation UUID untuk ID yang kosong di `HiveCarModel`:

### Perubahan 1: Update Constructor `HiveCarModel`
- Mengubah parameter `id` dari `required` menjadi `String?` (optional)
- Menambahkan logic di initializer list untuk generate UUID jika ID kosong atau null:
  ```dart
  }) : id = id?.isEmpty ?? true ? const Uuid().v4() : id!;
  ```

### Perubahan 2: Update Factory Method `fromMap()`
- Menambahkan logic untuk generate UUID jika ID kosong:
  ```dart
  final id = (map['id'] ?? '').isEmpty ? const Uuid().v4() : map['id'];
  ```

### Perubahan 3: Tambah Dependency
- Menambahkan package `uuid: ^4.0.0` ke `pubspec.yaml`

## Keuntungan
✅ Setiap mobil yang disimpan ke Hive otomatis mendapat ID unik  
✅ Tidak perlu khawatir tentang ID kosong  
✅ Mempermudah tracking dan sync ke Supabase  
✅ Kompatibel dengan API yang tidak menyediakan ID

## Cara Penggunaan
Tidak ada perubahan pada cara penggunaan:
```dart
// Cara lama tetap berjalan
final hiveCar = HiveCarModel.fromCarModel(car);
await _hiveService.saveCar(hiveCar);

// ID akan otomatis di-generate jika kosong
```

## Testing
Untuk test fitur ini:
1. Pastikan mobil yang disimpan tidak memiliki ID (atau ID kosong)
2. Simpan mobil ke Hive
3. Periksa bahwa setiap mobil memiliki UUID unik di Hive

