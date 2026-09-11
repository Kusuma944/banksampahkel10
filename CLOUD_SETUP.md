# CLOUD_SETUP.md — Panduan Aktivasi CPMK 5

Kode integrasi cloud (Supabase Auth, database, dst) sudah lengkap di
project ini. Yang belum: **API key sungguhan**, karena itu harus dari
akun kamu sendiri, bukan dari saya. Ikuti langkah di bawah.

---

## 1. Bikin Akun & Project Supabase (~10 menit)

1. Buka https://supabase.com → Sign up (gratis, bisa pakai akun GitHub/Google)
2. Klik **New Project**
3. Isi:
   - **Name**: `ecobank-sampah` (bebas)
   - **Database Password**: bikin password kuat, **simpan** — dipakai kalau nanti akses database langsung
   - **Region**: pilih **Southeast Asia (Singapore)** biar latensi rendah dari Indonesia
4. Tunggu ~2 menit sampai project selesai di-provision

## 2. Ambil URL & Anon Key

1. Di dashboard project, buka **Project Settings** (ikon gear) → **API**
2. Copy dua nilai ini:
   - **Project URL** (contoh: `https://xxxxxxxxxxxx.supabase.co`)
   - **anon public** key (string panjang diawali `eyJ...`)
3. Buka file `lib/core/config/supabase_config.dart` di project, isi:
   ```dart
   static const String url = 'https://xxxxxxxxxxxx.supabase.co';
   static const String anonKey = 'eyJhbGciOi...';
   ```
4. **PENTING:** jangan commit file ini kalau isinya sudah diisi ke repo publik
   sembarangan — untuk tugas kuliah biasanya tidak masalah, tapi kalau mau
   rapi, tambahkan `lib/core/config/supabase_config.dart` ke `.gitignore` dan
   buat `supabase_config.example.dart` sebagai template kosong untuk teman
   sekelompok.

## 3. Bikin Tabel `waste_transactions`

1. Di dashboard Supabase, buka **SQL Editor** → **New query**
2. Paste dan **Run**:
   ```sql
   create table waste_transactions (
     id uuid primary key default gen_random_uuid(),
     jenis_sampah text not null,
     berat_kg numeric not null,
     nilai_rupiah integer not null,
     tanggal timestamptz not null,
     created_at timestamptz default now()
   );

   -- Row Level Security: wajib diaktifkan di Supabase, tapi untuk
   -- prototype kita izinkan semua orang insert/select dulu.
   -- NANTI kalau sudah ada auth per-user, ganti policy ini supaya
   -- user hanya bisa akses datanya sendiri.
   alter table waste_transactions enable row level security;

   create policy "Izinkan semua insert (prototype)"
     on waste_transactions for insert
     with check (true);

   create policy "Izinkan semua select (prototype)"
     on waste_transactions for select
     using (true);
   ```
3. Cek di **Table Editor** — tabel `waste_transactions` harus sudah muncul

## 4. Aktifkan Email Auth (biasanya sudah default ON)

1. Buka **Authentication** → **Providers**
2. Pastikan **Email** berstatus **Enabled**
3. (Opsional, buat testing lebih cepat) di **Authentication** → **Settings**,
   matikan **Confirm email** sementara supaya akun langsung aktif tanpa
   perlu klik link verifikasi di inbox — aktifkan lagi kalau sudah mau demo final

## 5. Aktifkan Google Sign-In

1. Buka **Authentication** → **Providers** → **Google** → toggle **Enable**
2. Kamu butuh **Google OAuth Client ID & Secret**:
   - Buka https://console.cloud.google.com → bikin project baru (atau pakai yang ada)
   - **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**
   - Application type: **Web application**
   - Authorized redirect URI: copy dari Supabase (ada di halaman provider Google
     tadi, biasanya formatnya `https://xxxxx.supabase.co/auth/v1/callback`)
   - Copy **Client ID** dan **Client Secret**, paste ke form provider Google di Supabase
3. Simpan

> Catatan: kode di app (`AuthRepositorySupabaseImpl`) sudah pakai redirect URL
> `io.supabase.ecobanksampah://login-callback` dan konfigurasi native
> (AndroidManifest.xml + Info.plist) untuk deep link-nya **sudah saya
> siapkan** — kamu tidak perlu edit itu lagi kecuali ganti nama package app.

## 6. Test

```bash
flutter pub get
flutter run
```

Coba **Daftar Akun** (email+password) atau **Masuk dengan Google** di
halaman Login. Cek juga di dashboard Supabase → **Authentication** →
**Users**, akun baru harus muncul di situ.

Coba juga **Setor Sampah** — kalau device online, transaksi akan otomatis
ter-upload ke tabel `waste_transactions` (cek di **Table Editor**).

---

## 7. Push Notification (Firebase — Opsional, Belum Diaktifkan)

Modul kode untuk push notification **sudah ditulis lengkap** di
`lib/core/notifications/notification_service.dart`, tapi sengaja
**belum diaktifkan** (package Firebase butuh file konfigurasi native
`google-services.json` yang belum ada — kalau ditambah sekarang tanpa
file itu, `flutter run` akan gagal untuk SELURUH app).

Langkah aktivasinya ada lengkap sebagai komentar di dalam file itu.
Ringkasnya: bikin project di Firebase Console → download
`google-services.json` → taruh di `android/app/` → tambah 2 dependency
di `pubspec.yaml` → uncomment kode di file tersebut.

---

## Kalau Ada Error

- **"Supabase belum dikonfigurasi"** muncul di app → berarti langkah 1-2
  belum selesai / salah tempel. App tetap jalan normal (tidak crash),
  cuma fitur cloud-nya nonaktif sementara.
- **Google Sign-In gagal balik ke app** → cek lagi redirect URI di Google
  Cloud Console sama persis dengan yang di Supabase, dan pastikan
  `applicationId` di `android/app/build.gradle` masih `com.ecobank.sampah`
  (kalau diganti, redirect scheme di AndroidManifest.xml & Info.plist
  juga perlu disesuaikan).
- **RLS policy error saat insert** → pastikan SQL di langkah 3 sudah
  di-run dengan benar, cek di **Authentication** → **Policies**.
