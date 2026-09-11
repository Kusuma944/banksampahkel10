# Architectural Deployment Prompt (CPMK 6)

Prompt SCI (Structured, Clear, Impactful) yang dipakai untuk generate
`.github/workflows/build-release.yml` lewat AI coding assistant —
sesuai standar `PROMPT_SPEC.md` di Milestone 1.

```
### CONTEXT
Project Flutter bernama "EcoBank Sampah" (package: ecobank_sampah),
repo GitHub, target rilis Android App Bundle (AAB) ke Google Play.
Secrets (Supabase URL/key) diakses lewat --dart-define-from-file=.env,
signing pakai key.properties + keystore .jks. Kedua file itu TIDAK ada
di repo (di .gitignore), harus direkonstruksi dari GitHub Secrets saat
CI jalan.

### TASK
Buatkan GitHub Actions workflow (.github/workflows/build-release.yml)
dengan 2 job berurutan:
1. "analyze_and_test": checkout, setup Flutter stable, flutter pub get,
   flutter analyze, flutter test. Job build TIDAK BOLEH lanjut kalau
   job ini gagal.
2. "build_signed_aab": setup Flutter lagi, rekonstruksi file .env dan
   android/key.properties + keystore .jks dari GitHub Secrets (base64
   decode untuk keystore), build `flutter build appbundle --release
   --dart-define-from-file=.env`, upload hasil .aab sebagai artifact.

### CONSTRAINTS
- Trigger: push ke branch main, dan manual (workflow_dispatch)
- TIDAK ADA credential/password/key literal di file workflow — semua
  lewat ${{ secrets.NAMA_SECRET }}
- Tulis komentar di bagian atas file: daftar nama secrets yang wajib
  diisi manual di GitHub Settings, dan artinya masing-masing

### OUTPUT FORMAT
File YAML lengkap siap pakai untuk .github/workflows/build-release.yml
```

## Cara Pakai

1. Isi GitHub Secrets (Settings -> Secrets and variables -> Actions) sesuai
   daftar di komentar atas `build-release.yml`
2. Push ke branch `main` -> workflow jalan otomatis
3. Cek tab **Actions** di GitHub -> download artifact `app-release-aab`
   kalau build sukses

## Kenapa 2 Job Terpisah?

Supaya build AAB (yang mahal secara waktu & butuh secrets sensitif)
TIDAK dijalankan kalau kode belum lolos `flutter analyze`/`flutter test`
— menghemat waktu CI dan mencegah biner buruk ter-upload tanpa sengaja.
