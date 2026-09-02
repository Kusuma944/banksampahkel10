# EcoBank Sampah

Aplikasi Bank Sampah Digital — SDG 12 (Responsible Consumption and Production).

## Alur Layar

Splash Screen → Onboarding (3 slide) → Masuk (login nomor telepon) →
Verifikasi OTP → Daftar Akun → Beranda (bottom nav: Beranda/Setor/Harga/Aktivitas/Profil)

## Arsitektur (CPMK 3 — Clean Architecture + Provider)

```
lib/
  domain/                 <- Business Logic murni (tanpa dependency Flutter)
    entities/              waste_transaction.dart, enum JenisSampah
    repositories/          waste_repository.dart (kontrak abstrak)
    usecases/              setor_sampah_usecase.dart (validasi + hitung nilai)
  data/                   <- Sumber data
    repositories/          waste_repository_dummy_impl.dart (implementasi dummy)
  presentation/           <- UI + State Management (Provider)
    providers/              setor_sampah_provider.dart (state: initial/loading/success/error)
    screens/                setor_sampah_screen.dart
  screens/                <- Screen umum di luar fitur setor sampah
    splash_screen.dart, onboarding_screen.dart, login_screen.dart,
    otp_screen.dart, register_screen.dart, home_screen.dart
  core/theme/              app_theme.dart (design tokens Material 3)
  models/                  waste_transaction.dart (dummy data untuk Beranda)
```

**Cara ganti dummy jadi API asli nanti:** cukup buat class baru yang implement
`WasteRepository` (mis. `WasteRepositoryApiImpl`), lalu ganti satu baris di
`main.dart` — layer domain & presentation tidak perlu disentuh.

**Unit test:** `test/domain/usecases/setor_sampah_usecase_test.dart` — menguji
`SetorSampahUseCase` langsung tanpa perlu menjalankan Flutter app. Jalankan dengan:
```
flutter test
```

## Cara Menjalankan

```
flutter pub get
flutter run
```

## Status

- [x] Splash, Onboarding, Login, OTP, Daftar Akun, Beranda (sesuai desain Figma)
- [x] Setor Sampah dengan state management Provider (Initial/Loading/Success/Error)
- [x] Clean Architecture (domain/data/presentation)
- [x] Unit test business logic (SetorSampahUseCase)
- [ ] Integrasi backend/API sungguhan
- [ ] Halaman Harga, Aktivitas, Profil (masih placeholder di bottom nav)
