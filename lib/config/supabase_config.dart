import 'package:flutter_dotenv/flutter_dotenv.dart';

// Konfigurasi Supabase
// Membaca dari file .env
// Dapatkan URL dan anon key dari: https://app.supabase.com/project/_/settings/api

class SupabaseConfig {
  // Get URL dari .env file
  static String get url {
    final envUrl = dotenv.env['SUPABASE_URL'];
    if (envUrl == null || envUrl.isEmpty || envUrl == 'YOUR_SUPABASE_URL') {
      throw Exception(
        'SUPABASE_URL tidak ditemukan di file .env. '
        'Pastikan file .env sudah dibuat dan berisi SUPABASE_URL=your_url'
      );
    }
    return envUrl;
  }
  
  // Get anon key dari .env file
  static String get anonKey {
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (envKey == null || envKey.isEmpty || envKey == 'YOUR_SUPABASE_ANON_KEY') {
      throw Exception(
        'SUPABASE_ANON_KEY tidak ditemukan di file .env. '
        'Pastikan file .env sudah dibuat dan berisi SUPABASE_ANON_KEY=your_key'
      );
    }
    return envKey;
  }
}

