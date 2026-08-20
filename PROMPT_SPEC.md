# PROMPT_SPEC.md
## Architectural Prompting — Standar SCI (Structured, Clear, Impactful)
### Project: EcoBank — Aplikasi Bank Sampah Digital

Dokumen ini adalah spesifikasi prompt yang dipakai untuk mengoperasikan IDE berbasis AI (Cursor / GitHub Copilot / sejenisnya) secara konsisten selama pengembangan EcoBank. Setiap prompt yang dikirim ke AI pairing tool sebaiknya mengikuti struktur di bawah ini.

---

## 1. Prinsip SCI

| Prinsip | Arti | Penerapan di Project Ini |
|---|---|---|
| **Structured** | Prompt punya format tetap: Context → Task → Constraints → Output Format | Semua prompt below ikut template di Bagian 3 |
| **Clear** | Tidak ambigu, sebutkan nama file, package, dan konvensi penamaan secara eksplisit | Gunakan nama variabel & struktur folder yang sudah ditentukan di Bagian 2 |
| **Impactful** | Prompt menghasilkan output yang langsung bisa dipakai / merge, bukan draft kasar | Selalu minta AI sertakan null-safety, error handling dasar, dan komentar singkat |

---

## 2. Project Context (disertakan di setiap sesi AI baru)

```
Nama Project: EcoBank
Platform: Flutter (Dart), target Android utama
Tema: Aplikasi Bank Sampah — nasabah menyetor sampah anorganik (plastik, kertas,
logam, kaca) ke petugas bank sampah, dikonversi jadi saldo tabungan.
Tahap: Prototype Milestone 1 (CPMK 1) — fokus UI dasar (Splash + Home),
belum ada backend/API sungguhan, data masih dummy/mock.
State management: setState() dulu untuk prototype (belum Provider/Riverpod)
Struktur folder:
  lib/
    main.dart
    screens/       -> semua halaman (splash_screen.dart, home_screen.dart, dst)
    theme/         -> app_theme.dart (warna, tipografi terpusat)
    models/        -> model data (mis. WasteTransaction, Nasabah)
Konvensi penamaan: camelCase untuk variabel/fungsi, PascalCase untuk class/widget,
snake_case untuk nama file.
Warna tema: hijau (#2E7D32 primer) dan putih, mencerminkan tema lingkungan/daur ulang.
```

---

## 3. Template Prompt Standar

Gunakan format ini setiap kali meminta AI (Cursor/Copilot Chat) generate atau modifikasi kode:

```
### CONTEXT
[Tempel Project Context dari Bagian 2, atau ringkasannya jika sudah di system prompt IDE]

### TASK
[Satu tugas spesifik, contoh: "Buatkan widget StatCard yang menampilkan total
saldo nasabah dan total kg sampah yang sudah disetor bulan ini."]

### CONSTRAINTS
- Gunakan null safety (Dart >=3.0)
- Tidak menambah dependency baru tanpa disebutkan eksplisit
- Ikuti struktur folder & konvensi penamaan di atas
- Widget harus stateless kecuali disebutkan butuh state
- Sertakan komentar singkat untuk logic yang tidak trivial

### OUTPUT FORMAT
- Kode Dart lengkap, siap tempel ke file yang disebutkan
- Jika perlu file baru, sebutkan nama & lokasi file di baris pertama sebagai komentar
- Jelaskan singkat (maks 3 kalimat) apa yang berubah, di luar blok kode
```

---

## 4. Contoh Prompt Siap Pakai (Milestone 1)

### 4.1 Membuat Splash Screen
```
### CONTEXT
Project EcoBank, Flutter, prototype milestone 1. Struktur folder: lib/screens/splash_screen.dart.

### TASK
Buatkan SplashScreen (StatefulWidget) yang menampilkan ikon daur ulang, nama
"EcoBank", tagline "Sampahmu, Tabunganmu", dengan background hijau (#2E7D32),
lalu otomatis pindah ke HomeScreen setelah 2 detik.

### CONSTRAINTS
- Gunakan Navigator.pushReplacement
- Tidak pakai package eksternal untuk animasi, cukup AnimatedOpacity bawaan Flutter

### OUTPUT FORMAT
Kode Dart lengkap untuk lib/screens/splash_screen.dart
```

### 4.2 Membuat Home Screen dengan Data Dummy
```
### CONTEXT
Project EcoBank, Flutter, prototype milestone 1. Model data Nasabah &
WasteTransaction sudah ada di lib/models/.

### TASK
Buatkan HomeScreen yang menampilkan: nama nasabah, saldo (format Rupiah),
total kg sampah tersetor, dan list riwayat 5 setoran terakhir dari data dummy.

### CONSTRAINTS
- Gunakan ListView.builder untuk riwayat
- Format Rupiah manual (tanpa package intl) cukup dengan string formatting sederhana
- UI mengikuti tema warna hijau yang sudah didefinisikan di app_theme.dart

### OUTPUT FORMAT
Kode Dart lengkap untuk lib/screens/home_screen.dart
```

---

## 5. Checklist Sebelum Commit Hasil AI

- [ ] Sudah dijalankan `flutter analyze` tanpa error
- [ ] Sudah dicoba `flutter run` di device/emulator, tidak crash
- [ ] Penamaan file & folder sesuai konvensi Bagian 2
- [ ] Tidak ada dependency baru yang nyelip tanpa izin tim
- [ ] Komentar/README diperbarui jika ada fitur baru

---

## 6. Catatan Revisi

Spesifikasi ini akan disesuaikan begitu Project Charter kelompok selesai —
khususnya bagian nama fitur/istilah agar konsisten dengan dokumen tim.
