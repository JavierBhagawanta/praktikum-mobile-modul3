# Setup Environment Variables (.env)

File `.env` digunakan untuk menyimpan kredensial Supabase secara aman.

## Cara Setup

1. **Buka file `.env` di root project** (atau copy dari `env.example` jika belum ada)

2. **Dapatkan kredensial Supabase Anda:**
   - Login ke [Supabase Dashboard](https://app.supabase.com)
   - Pilih project Anda
   - Buka **Settings** > **API**
   - Copy **Project URL** dan **anon/public key**

3. **Isi file `.env` dengan format berikut:**
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

4. **Contoh file `.env`:**
   ```env
   SUPABASE_URL=https://abcdefghijklmnop.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNjIzOTAyMiwiZXhwIjoxOTMxODE1MDIyfQ.example
   ```

## Penting!

- ✅ File `.env` sudah ditambahkan ke `.gitignore` sehingga tidak akan di-commit ke repository
- ✅ Jangan share file `.env` Anda ke publik
- ✅ File `env.example` adalah template yang aman untuk di-commit

## Troubleshooting

Jika aplikasi error saat initialize Supabase:
- Pastikan file `.env` ada di root project (sama level dengan `pubspec.yaml`)
- Pastikan format file `.env` benar (tidak ada spasi sebelum/ setelah `=`)
- Pastikan tidak ada tanda kutip di sekitar value
- Restart aplikasi setelah mengubah file `.env`

