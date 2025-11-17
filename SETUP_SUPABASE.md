# Setup Supabase Database

Panduan untuk setup database Supabase untuk aplikasi Sewa Mobil.

## 1. Buat Project Supabase

1. Buka [Supabase Dashboard](https://app.supabase.com)
2. Klik "New Project"
3. Isi detail project:
   - Name: `sewa-mobil-app` (atau nama lain)
   - Database Password: (buat password yang kuat)
   - Region: Pilih region terdekat
4. Tunggu hingga project selesai dibuat (sekitar 2 menit)

## 2. Dapatkan API Credentials

1. Di project dashboard, buka **Settings** > **API**
2. Copy **Project URL** dan **anon/public key**
3. Paste ke file `.env`:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

## 3. Buat Table `cars`

1. Di Supabase dashboard, buka **Table Editor**
2. Klik **New Table**
3. Isi detail table:
   - Name: `cars`
   - Description: `Table untuk menyimpan data mobil`
4. Tambahkan kolom-kolom berikut:

| Column Name | Type | Default Value | Nullable | Primary Key |
|------------|------|---------------|----------|-------------|
| id | text | - | NO | YES |
| nama_mobil | text | - | NO | NO |
| tipe_mobil | text | - | NO | NO |
| gambar_url | text | - | YES | NO |
| harga_sewa | integer | - | NO | NO |
| driver_id | text | - | YES | NO |
| saved_at | timestamptz | now() | NO | NO |
| user_id | uuid | - | YES | NO |

5. Klik **Save**

## 4. Setup Row Level Security (RLS)

1. Di table `cars`, buka tab **Policies**
2. Klik **New Policy**
3. Pilih **For full customization**
4. Buat policy untuk INSERT:
   - Policy name: `Users can insert their own cars`
   - Allowed operation: `INSERT`
   - Target roles: `authenticated`
   - USING expression: `auth.uid() = user_id`
   - WITH CHECK expression: `auth.uid() = user_id`

5. Buat policy untuk SELECT:
   - Policy name: `Users can view their own cars`
   - Allowed operation: `SELECT`
   - Target roles: `authenticated`
   - USING expression: `auth.uid() = user_id`

6. Buat policy untuk UPDATE:
   - Policy name: `Users can update their own cars`
   - Allowed operation: `UPDATE`
   - Target roles: `authenticated`
   - USING expression: `auth.uid() = user_id`
   - WITH CHECK expression: `auth.uid() = user_id`

7. Buat policy untuk DELETE:
   - Policy name: `Users can delete their own cars`
   - Allowed operation: `DELETE`
   - Target roles: `authenticated`
   - USING expression: `auth.uid() = user_id`

## 5. (Optional) Buat Index untuk Performance

1. Di Supabase dashboard, buka **SQL Editor**
2. Jalankan query berikut:

```sql
-- Index untuk user_id untuk query yang lebih cepat
CREATE INDEX IF NOT EXISTS idx_cars_user_id ON cars(user_id);

-- Index untuk saved_at untuk sorting
CREATE INDEX IF NOT EXISTS idx_cars_saved_at ON cars(saved_at DESC);
```

## 6. Test Connection

1. Restart aplikasi Flutter
2. Buka Settings di aplikasi
3. Sign up/Sign in dengan email dan password
4. Coba sync data ke cloud

## Troubleshooting

### Error: "relation 'cars' does not exist"
- Pastikan table `cars` sudah dibuat di Supabase
- Pastikan nama table sama persis: `cars` (lowercase)

### Error: "new row violates row-level security policy"
- Pastikan RLS policies sudah dibuat dengan benar
- Pastikan user sudah sign in
- Pastikan `user_id` di data sama dengan `auth.uid()`

### Error: "permission denied for table cars"
- Pastikan RLS policies sudah dibuat
- Pastikan user sudah authenticated
- Check apakah anon key sudah benar

### Data tidak muncul setelah sync
- Check apakah user sudah sign in
- Check apakah RLS policies sudah benar
- Check console untuk error messages
- Pastikan `user_id` di data sama dengan user yang sedang login

## SQL Script Lengkap (Alternatif)

Jika ingin membuat table dengan SQL langsung, jalankan script ini di SQL Editor:

```sql
-- Buat table cars
CREATE TABLE IF NOT EXISTS public.cars (
    id text PRIMARY KEY,
    nama_mobil text NOT NULL,
    tipe_mobil text NOT NULL,
    gambar_url text,
    harga_sewa integer NOT NULL,
    driver_id text,
    saved_at timestamptz NOT NULL DEFAULT now(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.cars ENABLE ROW LEVEL SECURITY;

-- Policy untuk INSERT
CREATE POLICY "Users can insert their own cars"
ON public.cars
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy untuk SELECT
CREATE POLICY "Users can view their own cars"
ON public.cars
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy untuk UPDATE
CREATE POLICY "Users can update their own cars"
ON public.cars
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy untuk DELETE
CREATE POLICY "Users can delete their own cars"
ON public.cars
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Index untuk performance
CREATE INDEX IF NOT EXISTS idx_cars_user_id ON public.cars(user_id);
CREATE INDEX IF NOT EXISTS idx_cars_saved_at ON public.cars(saved_at DESC);
```

## Catatan Penting

1. **user_id**: Kolom ini akan otomatis diisi dengan UUID user yang sedang login. Pastikan aplikasi mengirim `user_id` saat save data.

2. **RLS**: Row Level Security memastikan user hanya bisa melihat/mengubah data miliknya sendiri.

3. **Authentication**: Pastikan user sudah sign in sebelum melakukan operasi database.

4. **Error Handling**: Aplikasi sudah dilengkapi dengan error handling, tapi pastikan Supabase sudah dikonfigurasi dengan benar.