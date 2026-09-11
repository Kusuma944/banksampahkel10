# RELEASE_GUIDE.md — Panduan Rilis CPMK 6

Kode & konfigurasi sudah siap (obfuscation, signing config, CI/CD,
dokumen kepatuhan). Langkah di bawah ini **wajib kamu eksekusi
sendiri** karena melibatkan file rahasia (keystore) dan akun
berbayar (Play Console) yang tidak bisa saya buatkan.

## 1. Generate Keystore (WAJIB, hanya sekali)

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Jalankan dari folder `android/`. Ikuti prompt (isi password, nama,
organisasi — bebas). **SIMPAN password ini baik-baik, kalau hilang
kamu TIDAK BISA update app yang sudah pernah dirilis.**

Lalu:
```bash
cp android/key.properties.example android/key.properties
```
Edit `android/key.properties`, isi password & alias sesuai yang barusan dibuat.

## 2. Siapkan `.env`

```bash
cp .env.example .env
```
Isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` (lihat `CLOUD_SETUP.md` kalau belum punya).

## 3. Build AAB Bertanda Tangan (Lokal)

```bash
flutter build appbundle --release --dart-define-from-file=.env
```

Hasil ada di `build/app/outputs/bundle/release/app-release.aab`.
Cek ukurannya lebih kecil dari build debug — bukti obfuscation/shrinking jalan.

## 4. Setup CI/CD (GitHub Actions)

1. Push project ke GitHub (kalau belum)
2. Isi **GitHub Secrets** (repo -> Settings -> Secrets and variables -> Actions):
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY` — dari `.env` kamu
   - `KEYSTORE_BASE64` — hasil dari: `base64 -i android/upload-keystore.jks | pbcopy` (Mac)
     atau `certutil -encode android/upload-keystore.jks keystore.b64` (Windows)
   - `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` — dari `key.properties` kamu
3. Push ke branch `main` — workflow di `.github/workflows/build-release.yml`
   otomatis jalan, hasil AAB bisa didownload dari tab **Actions**

## 5. Daftar Google Play Console

1. Buka https://play.google.com/console, bayar biaya pendaftaran developer
   **sekali seumur hidup** (~$25 USD, pakai kartu debit/kredit)
2. Bikin app baru, isi nama "EcoBank Sampah"
3. Buka **Policy -> App content** — isi semua sesuai `DATA_SAFETY_CHECKLIST.md`
4. Publish `PRIVACY_POLICY.md` ke URL publik (GitHub Pages termudah), masukkan
   URL-nya ke form Privacy Policy
5. Buka **Testing -> Internal testing** — upload `app-release.aab`, tambahkan
   email penguji/dosen sebagai tester
6. Kirim link opt-in internal testing ke dosen/penguji buat instal & coba

## 6. Sebelum Presentasi/Demo

- [ ] Coba install AAB dari jalur Internal Testing di HP fisik — pastikan jalan
- [ ] Siapkan skenario demo: daftar akun -> setor sampah -> lihat saldo ->
      coba offline (matiin WiFi, setor lagi, nyalain WiFi, tunjukkan auto-sync) ->
      coba langganan premium (alur payment simulasi)
- [ ] Siapkan jawaban untuk pertanyaan "kenapa payment masih simulasi" —
      jawaban jujur: sandbox Midtrans/Xendit butuh pendaftaran akun merchant
      terpisah, arsitekturnya sudah siap tinggal ganti implementasi
- [ ] Siapkan jawaban soal monetisasi: model komisi + langganan sudah
      didesain dari PRD.md Milestone 1, sekarang sudah ada alur teknisnya
