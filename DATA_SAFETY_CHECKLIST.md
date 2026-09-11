# Data Safety Declaration Checklist — Google Play Console

Isian untuk form **Play Console -> Policy -> App content -> Data safety**,
dipetakan dari kode aktual yang dipakai di app (bukan tebakan).

## Data yang Dikumpulkan

| Kategori | Data | Dikumpulkan? | Dibagikan ke 3rd party? | Wajib/Opsional | Alasan |
|---|---|---|---|---|---|
| Personal info | Nama | Ya | Tidak | Wajib | Daftar akun (`register_screen.dart`) |
| Personal info | Email | Ya | Tidak | Wajib | Autentikasi (`auth_repository_supabase_impl.dart`) |
| Personal info | Nomor telepon | Ya | Tidak | Opsional | Field pendaftaran (belum wajib divalidasi) |
| App activity | Riwayat transaksi | Ya | Tidak | Wajib | Fitur inti (`waste_repository_hive_impl.dart`) |
| App info & performance | Crash logs | Tidak* | - | - | *aktifkan kalau nanti pakai Firebase Crashlytics |

## Keamanan Data
- [x] Data dienkripsi saat transit (HTTPS, bawaan Supabase client)
- [x] Kredensial sesi & status langganan dienkripsi saat disimpan
      (flutter_secure_storage -> Android Keystore/iOS Keychain)
- [ ] User bisa minta hapus data (isi mekanismenya sebelum submit —
      lihat PRIVACY_POLICY.md bagian 4, saat ini baru manual via kontak email)

## Practices
- [x] Data dipakai HANYA untuk fungsi app (bukan untuk iklan pihak ketiga)
- [x] User bisa hapus sesi/akun-nya sendiri lewat halaman Profil

## Sebelum Submit ke Play Console — Checklist Akhir

- [ ] URL Privacy Policy sudah live & publik (lihat `PRIVACY_POLICY.md`)
- [ ] Isi form Data Safety persis sesuai tabel di atas
- [ ] Screenshot app (minimal 2 per jenis device) sudah disiapkan
- [ ] Ikon app 512x512 & feature graphic 1024x500 sudah disiapkan
- [ ] Deskripsi singkat & lengkap app sudah ditulis
- [ ] Kategori app dipilih (mis. "Lifestyle" atau "Tools")
- [ ] Target audience & content rating questionnaire sudah diisi
- [ ] AAB sudah di-upload ke jalur **Internal testing** dulu (bukan langsung
      Production) untuk uji coba internal sebelum rilis publik

## Catatan Audit Keamanan (Praktikum CPMK 6)

- [x] Obfuscation aktif (`minifyEnabled true` + `shrinkResources true` di
      `android/app/build.gradle`)
- [x] ProGuard rules ada (`android/app/proguard-rules.pro`)
- [x] Tidak ada API key/secret hardcoded di kode (`supabase_config.dart`
      pakai `String.fromEnvironment`, diisi lewat `.env` yang di-gitignore)
- [x] Keystore & `key.properties` di-gitignore, tidak pernah masuk repo
- [x] CI/CD merekonstruksi secrets dari GitHub Secrets, bukan file di repo
