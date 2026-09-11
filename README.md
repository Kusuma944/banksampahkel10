# EcoBank Sampah

Aplikasi Bank Sampah Digital — SDG 12 (Responsible Consumption and Production).

## Alur Layar

Splash Screen → Onboarding (3 slide) → Masuk (login nomor telepon) →
Verifikasi OTP → Daftar Akun → Beranda (bottom nav: Beranda/Setor/Harga/Aktivitas/Profil)

## Arsitektur (CPMK 3 — Clean Architecture + Provider)

```
lib/
  domain/                 <- Business Logic murni (tanpa dependency Flutter)
    entities/              waste_transaction.dart (entity + flag `synced`)
    repositories/          waste_repository.dart (kontrak abstrak)
    usecases/              setor_sampah_usecase.dart, sync_pending_usecase.dart
  data/                   <- Sumber data
    repositories/          waste_repository_hive_impl.dart (persistent, offline-first)
                           waste_repository_dummy_impl.dart (in-memory, contoh dependency inversion)
    local/                 hive_service.dart, secure_session_storage.dart
  presentation/           <- UI + State Management (Provider)
    providers/              setor_sampah_provider.dart, transaksi_provider.dart
    screens/                setor_sampah_screen.dart, profile_screen.dart
  core/
    theme/                  app_theme.dart (design tokens Material 3)
    network/                connectivity_service.dart
  screens/                <- Screen umum di luar fitur setor sampah
    splash_screen.dart, onboarding_screen.dart, login_screen.dart,
    otp_screen.dart, register_screen.dart, home_screen.dart
  models/                  waste_transaction.dart (dummy data untuk saldo awal Beranda)
```

## Persistent Data & Offline-First (CPMK 4)

- **Database lokal:** Hive (`waste_repository_hive_impl.dart`) — riwayat transaksi
  tersimpan permanen di disk HP, bukan cuma di memory.
- **Offline-First:** setor sampah SELALU berhasil tersimpan lokal dulu, apapun
  status koneksinya. Kalau offline, transaksi ditandai `synced: false` dan
  otomatis disinkron begitu koneksi kembali (didengarkan lewat `connectivity_plus`
  di `TransaksiProvider`).
- **Kredensial & status langganan terenkripsi:** `secure_session_storage.dart`
  pakai `flutter_secure_storage` (Android Keystore / iOS Keychain) — BUKAN
  SharedPreferences biasa. Sesi login persisten lintas restart app (cek di
  `splash_screen.dart`), status langganan bisa di-toggle di halaman Profil.

**Cara ganti dummy jadi API asli nanti:** cukup buat class baru yang implement
`WasteRepository` (mis. `WasteRepositoryApiImpl`), lalu ganti satu baris di
`main.dart` — layer domain & presentation tidak perlu disentuh.

**Unit test:**
- `test/domain/usecases/setor_sampah_usecase_test.dart` — validasi & hitung nilai
- `test/domain/usecases/sync_pending_usecase_test.dart` — orkestrasi sync
- `test/data/repositories/waste_repository_hive_impl_test.dart` — CRUD +
  skenario offline/online pakai Hive sungguhan di direktori sementara

Jalankan semua dengan:
```
flutter test
```

## Cara Menjalankan

```
flutter pub get
flutter run
```

**Sebelum fitur cloud (CPMK 5) bisa dipakai**, ikuti `CLOUD_SETUP.md` untuk
bikin akun Supabase & isi API key. Tanpa itu, app tetap jalan normal
(tidak crash) — fitur cloud cuma menampilkan pesan "belum dikonfigurasi".

## Integration Engine — Cloud, Auth & Payment (CPMK 5)

```
lib/core/
  error/                   failure.dart (kategori error), result.dart (Success/ResultFailure)
  network/                 network_resilience.dart (retry + exponential backoff + timeout)
  config/                  supabase_config.dart (isi URL & anon key di sini)
  notifications/           notification_service.dart (siap pakai, BELUM diaktifkan — lihat CLOUD_SETUP.md)
lib/domain/
  entities/                app_user.dart, payment_result.dart
  repositories/            auth_repository.dart, payment_repository.dart
  usecases/                sign_up/sign_in/sign_in_google/sign_out, subscribe_premium_usecase.dart
lib/data/repositories/
  auth_repository_supabase_impl.dart      <- Supabase Auth SDK sungguhan
  payment_repository_simulated_impl.dart  <- simulasi Payment Gateway (siap ganti Midtrans/Xendit)
lib/presentation/
  providers/               auth_provider.dart, payment_provider.dart
  screens/                 subscription_screen.dart (checkout langganan)
```

- **Backend & Auth:** Supabase — Email sign up/in dan Google Sign-In beneran
  lewat Supabase Auth SDK, disambungkan ke `login_screen.dart` &
  `register_screen.dart`. Kalau Supabase belum di-setup, pendaftaran tetap
  jalan secara lokal saja (fallback aman, tidak memblokir demo CPMK 1-4).
- **Cloud Database:** transaksi setor sampah yang tersimpan di Hive (CPMK 4)
  otomatis di-upload ke tabel `waste_transactions` di Supabase saat online —
  lihat parameter `remoteSync` di `waste_repository_hive_impl.dart`. Gagal
  upload TIDAK menghapus data lokal, transaksi tetap `synced: false` dan
  dicoba lagi nanti (offline-first + error handling menyatu).
- **Payment Gateway:** disimulasikan dulu (`PaymentRepositorySimulatedImpl`)
  sesuai keputusan milestone ini — alur & kontraknya dibuat semirip mungkin
  Midtrans Snap API (create transaction -> polling status), supaya tinggal
  ganti satu class untuk pakai gateway sungguhan nanti.
- **Error Handling & Network Resilience:** SEMUA panggilan cloud (auth,
  sync, payment) dibungkus `NetworkResilience.guard()` — retry otomatis
  untuk timeout/tidak ada koneksi/error server 5xx (dengan backoff),
  TIDAK retry untuk error 4xx (percuma diulang, mis. salah password).
  Tidak ada exception yang bocor sampai ke widget.
- **Push Notification:** kode FCM sudah ditulis lengkap tapi sengaja belum
  diaktifkan (butuh `google-services.json` dari project Firebase kamu
  sendiri — kalau ditambah sekarang tanpa file itu, build Android gagal
  total). Panduan aktivasi ada di `CLOUD_SETUP.md` bagian 7.

**Unit test tambahan:**
- `test/core/network_resilience_test.dart` — retry, backoff, timeout, dan
  bukti tidak ada exception yang bocor ke pemanggil
- `test/domain/usecases/sign_up_with_email_usecase_test.dart` — validasi
  input sebelum menyentuh network
- `test/domain/usecases/subscribe_premium_usecase_test.dart` — orkestrasi
  alur pembayaran (sukses & gagal)

## Status

- [x] Splash, Onboarding, Login, OTP, Daftar Akun, Beranda (sesuai desain Figma)
- [x] Setor Sampah dengan state management Provider (Initial/Loading/Success/Error)
- [x] Clean Architecture (domain/data/presentation)
- [x] Persistent local database (Hive) + Offline-First + auto-sync
- [x] Sesi login & status langganan tersimpan di secure storage terenkripsi
- [x] Auth cloud (Supabase): Email sign up/in + Google Sign-In
- [x] Sinkronisasi transaksi ke cloud database (Supabase)
- [x] Payment Gateway (simulasi, arsitektur siap Midtrans/Xendit asli)
- [x] Error handling & network resilience (retry + backoff + timeout) di semua panggilan cloud
- [x] Unit test menyeluruh (business logic, offline-first, network resilience, auth, payment)
- [ ] Push Notification (kode siap, butuh setup Firebase Console sendiri — lihat CLOUD_SETUP.md)
- [ ] Payment Gateway sungguhan (Midtrans/Xendit sandbox nyata)
- [ ] Halaman Harga, Aktivitas (masih placeholder di bottom nav)

## Security, CI/CD & Rilis (CPMK 6)

- **Obfuscation:** `minifyEnabled true` + `shrinkResources true` di
  `android/app/build.gradle`, rules custom di `proguard-rules.pro`
- **Secrets:** TIDAK ADA hardcoded di kode — `SupabaseConfig` pakai
  `String.fromEnvironment`, diisi lewat `.env` (gitignored). Signing pakai
  `key.properties` + keystore `.jks` (gitignored, harus digenerate sendiri)
- **CI/CD:** `.github/workflows/build-release.yml` (dijelaskan lewat prompt
  di `ARCHITECTURAL_DEPLOYMENT_PROMPT.md`) — analyze & test dulu, baru build
  signed AAB, secrets direkonstruksi dari GitHub Secrets
- **Dokumen rilis:** `PRIVACY_POLICY.md`, `DATA_SAFETY_CHECKLIST.md`

**Panduan eksekusi lengkap (generate keystore, isi secrets, submit ke Play
Console) ada di `RELEASE_GUIDE.md`** — ini bagian yang wajib kamu jalankan
sendiri karena melibatkan file rahasia & akun berbayar.
