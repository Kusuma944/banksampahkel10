# EcoBank — Aplikasi Bank Sampah Digital

Prototype Milestone 1 (CPMK 1) — Mata Kuliah Pemrograman Mobile.

## Isi Repo Ini

| File/Folder | Isi |
|---|---|
| `PRD.md` | Product Requirements Document v1.0 (Problem, Solution, Persona, Business Model) |
| `PROMPT_SPEC.md` | Standar prompt SCI untuk AI-assisted coding (Cursor/Copilot) |
| `ENVIRONMENT_SETUP.md` | Panduan setup Flutter tanpa Android Studio penuh (`flutter doctor` clean) |
| `lib/` | Source code Flutter (splash screen + home screen prototype) |
| `pubspec.yaml` | Dependency project |

## Cara Menjalankan

1. Pastikan sudah ikuti `ENVIRONMENT_SETUP.md` sampai `flutter doctor` clean
2. Dari folder project:
   ```
   flutter pub get
   flutter run
   ```
3. Pilih device (HP fisik via USB debugging direkomendasikan, lihat `ENVIRONMENT_SETUP.md`)

## Status

- [x] Splash screen
- [x] Home screen (data dummy)
- [ ] Integrasi backend/API
- [ ] Fitur setor sampah (form input)
- [ ] Autentikasi nasabah/petugas

Dokumen ini akan disesuaikan lagi begitu Project Charter kelompok final.
