# Environment Setup — Flutter (Ringan, Tanpa Android Studio Penuh)

Target: `flutter doctor` 100% clean tanpa install Android Studio full (hemat SSD & RAM).
Cocok untuk testing langsung ke HP fisik.

---

## 1. Install Flutter SDK

1. Download Flutter SDK (Stable channel) dari https://docs.flutter.dev/get-started/install/windows (sesuaikan OS kamu)
2. Extract ke folder tanpa spasi/karakter aneh, contoh: `C:\src\flutter` (Windows) atau `~/development/flutter` (Linux/Mac)
3. Tambahkan `flutter/bin` ke PATH environment variable
4. Cek dengan:
   ```
   flutter --version
   ```

## 2. Install Android SDK Tanpa Android Studio (Command Line Tools Only)

1. Buka https://developer.android.com/studio → scroll ke bawah ke bagian **"Command line tools only"**
2. Download sesuai OS (jauh lebih kecil, ~150MB vs Android Studio ~1GB+)
3. Extract ke folder, contoh: `C:\Android\cmdline-tools\latest` atau `~/Android/cmdline-tools/latest`
   - Penting: struktur foldernya harus `cmdline-tools/latest/bin`, bukan langsung `cmdline-tools/bin`
4. Set environment variable:
   ```
   ANDROID_HOME=C:\Android        (atau path kamu)
   ANDROID_SDK_ROOT=C:\Android
   ```
   Tambahkan ke PATH:
   ```
   %ANDROID_HOME%\cmdline-tools\latest\bin
   %ANDROID_HOME%\platform-tools
   ```
5. Install komponen SDK yang dibutuhkan lewat `sdkmanager`:
   ```
   sdkmanager --licenses
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```
   Terima semua lisensi dengan ketik `y` saat diminta.

## 3. Setel Flutter Agar Kenal Android SDK

```
flutter config --android-sdk "C:\Android"
```
(ganti path sesuai lokasi instalasi kamu)

## 4. Terima Lisensi Android via Flutter

```
flutter doctor --android-licenses
```
Ketik `y` untuk semua.

## 5. Install VS Code + Extension

1. Install VS Code dari https://code.visualstudio.com
2. Buka Extensions (Ctrl+Shift+X), install:
   - **Flutter** (otomatis narik extension **Dart**)

## 6. Cek Hasil Akhir

```
flutter doctor -v
```

Target: semua centang hijau ✓. Item **Android Studio** boleh tetap silang/warning
selama item **Android toolchain** dan **VS Code** sudah centang — dosen membebaskan
pakai Android Studio atau tidak, yang penting toolchain-nya lengkap dan project jalan nyata.

## 7. Testing ke HP Fisik (Rekomendasi — Tanpa Emulator Sama Sekali)

1. Di HP Android: **Settings → About Phone** → tap **Build Number** 7x sampai muncul
   pesan "Anda sekarang developer"
2. Masuk **Settings → System → Developer Options** → aktifkan **USB Debugging**
3. Colok HP ke laptop via kabel USB, pilih mode **File Transfer/MTP** kalau muncul prompt
4. Di HP akan muncul popup "Allow USB Debugging?" → tap **Allow**
5. Cek dari terminal:
   ```
   flutter devices
   ```
   Nama HP kamu harus muncul di list.
6. Jalankan project:
   ```
   flutter run
   ```

Dengan cara ini kamu sama sekali tidak perlu emulator, jadi RAM & SSD tetap aman.

## 8. Inisialisasi Git Repository Kelompok

Dari folder root project:
```
git init
git add .
git commit -m "chore: initial scaffold EcoBank - splash screen & home screen"
git branch -M main
git remote add origin <URL_REPO_KELOMPOK>
git push -u origin main
```

Pastikan `.gitignore` sudah ada (sudah disediakan di project ini) agar folder
`build/`, `.dart_tool/`, dan file environment lokal tidak ikut ter-commit.
