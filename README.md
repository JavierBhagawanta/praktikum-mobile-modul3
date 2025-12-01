# Location Tracking Experiments

Aplikasi Flutter untuk eksperimen tracking lokasi menggunakan provider Network dan GPS. Solusi ini mengadopsi arsitektur modular (service, controller, view), state management GetX, dan visualisasi real-time dengan FlutterMap + OpenStreetMap.

## Fitur Utama

- **Live Real-time Tracking (Network & GPS)**: Lokasi terus diperbarui otomatis hingga pengguna menekan Stop.
- **Auto-follow Map**: Peta otomatis mengikuti pergerakan lokasi terkini.
- **Statistik Lengkap**: Jarak tempuh, kecepatan (km/h), update rate, time-to-fix, dan durasi tracking.
- **Pause/Resume**: Tracking dapat dijeda tanpa menghapus data atau path yang telah terekam.
- **Switch Provider**: Bisa berpindah mode (Network/GPS) tanpa kehilangan histori pergerakan.
- **Optimasi Memory**: Jumlah riwayat path dibatasi agar performa tetap ringan.
- **UI Modern**: Marker dan jalur halus dengan visualisasi jelas.
- **Catatan**: Mode eksperimen statis (diam, bebas di mana saja)
- **Aplikasi akan menyesuaikan hasil tergantung posisi pengguna (indoor/outdoor)**

## Perbedaan Network vs GPS

| Provider | Kelebihan | Kekurangan | Use Case |   
|----------|-----------|------------|----------|   
| **Network** | Cepat respons, tidak selalu butuh GPS, lebih hemat baterai. Coverage lebih baik indoor (asal ada WiFi/BTS). | Akurasi rendah (10-100 meter, bisa lebih). Dipengaruhi kualitas sinyal seluler/WiFi. | Lokasi kasar, aplikasi delivery, penemuan perangkat, tracking kasar saat bergerak cepat.
| **GPS** | Akurasi tinggi (1-10 meter), cocok eksperimen presisi, rute/jalur/jarak. | Lambat time-to-fix (butuh waktu "menangkap" satelit), boros baterai, bisa gagal indoor/gedung tebal/area tertutup. | Navigasi kendaraan, rekam olahraga, eksperimen presisi jalur & akurasi.

### Catatan Penggunaan   
- **Network**: Cukup aktifkan internet dan izinkan lokasi, langsung mulai. Lebih stabil di dalam gedung/area wifi.
- **GPS**: Aktifkan GPS, keluar gedung untuk fix lebih cepat/akurat. Cocok untuk tracking di lapangan luas.
- Pengguna bisa langsung berpindah mode di halaman real-time untuk membandingkan jalur, respons, dan kehalusan path.
- Tracking akan terus berjalan dan terus update hingga Anda menekan tombol Stop.

## Eksperimen

### Eksperimen 1 & 2: Statis
- Tidak ada UI pemilihan indoor/outdoor; lakukan eksperimen di mana saja.
- Catat lokasi Network dan GPS, lalu bandingkan.
- Cocok untuk menguji selisih akurasi di dalam vs luar ruangan.

### Eksperimen 3: Bergerak (Live Real-time Tracking)
- Tracking berjalan terus (interval optimal: network ~2 detik, GPS ~1 detik), marker dan jalur bergerak mengikuti posisi user.
- Mode bisa diganti kapan saja tanpa kehilangan data/history.
- Uji jalur, update rate, time-to-fix, serta kehalusan marker di map.

## Struktur Proyek

```
lib/
├── controllers/
│    ├── location_controller.dart
│    └── experiment_controller.dart
├── models/
│    └── location_data.dart
├── services/
│    └── location_service.dart
├── views/
│    ├── home_view.dart
│    ├── static_experiment_view.dart
│    └── moving_experiment_view.dart
├── widgets/
│    └── location_map.dart
└── main.dart
```

## Dependencies
- `geolocator`, `permission_handler`, `get`, `flutter_map`, `latlong2`, `intl`

## Setup
1. Jalankan: `flutter pub get`
2. Permissions lokasi sudah lengkap di Android/iOS
3. Mulai: `flutter run`

## Penggunaan
1. Pilih eksperimen Statis (diam) atau Bergerak (live tracking)
2. Mode Statis: Catat lokasi Network/GPS dengan posisi yang Anda inginkan
3. Mode Bergerak: Tracking terus real-time hingga ditekan Stop (bisa pindah Network-GPS tanpa reset data)

## Catatan Tambahan
- Pengukuran akurasi serta kelambatan/kelembutan pergerakan marker sangat dipengaruhi kualitas provider (Network/GPS), kekuatan sinyal, dan lokasi fisik pengguna.
- Cobalah berpindah (indoor/outdoor) dan bandingkan hasil masing-masing provider!
