# Kebijakan Privasi — EcoBank Sampah

**Terakhir diperbarui:** [ISI TANGGAL SEBELUM PUBLISH]

EcoBank Sampah ("kami") menghormati privasi pengguna. Dokumen ini
menjelaskan data apa yang dikumpulkan, bagaimana digunakan, dan hak
pengguna atas data tersebut.

## 1. Data yang Dikumpulkan
- **Data akun**: nama lengkap, alamat email, nomor telepon (saat
  daftar/masuk lewat Email atau Google Sign-In)
- **Data transaksi**: jenis sampah, berat (kg), nilai rupiah, tanggal
  setoran — tersimpan lokal di perangkat dan disinkronkan ke server
  cloud (Supabase) saat perangkat terhubung internet
- **Status langganan**: status aktif/nonaktif langganan premium

## 2. Cara Data Digunakan
Data dipakai untuk: menjalankan fitur inti aplikasi (autentikasi,
riwayat transaksi, saldo), dan tidak dibagikan ke pihak ketiga untuk
tujuan iklan.

## 3. Penyimpanan & Keamanan
- Kredensial sesi & status langganan disimpan di penyimpanan
  terenkripsi milik OS (Android Keystore / iOS Keychain)
- Data transaksi disimpan lokal (Hive) dan di database cloud (Supabase)
  dengan Row Level Security aktif
- Komunikasi ke server memakai koneksi HTTPS terenkripsi

## 4. Hak Pengguna
Pengguna dapat menghapus akun & data dengan menghubungi
[ISI EMAIL KONTAK KAMU] atau lewat menu Profil -> Keluar (menghapus
sesi lokal).

## 5. Kontak
Pertanyaan seputar privasi: [ISI EMAIL KONTAK KAMU]

---
**CATATAN BUAT KAMU (hapus sebelum publish):** dokumen ini template
dasar untuk keperluan tugas kuliah/prototype. Sebelum benar-benar
publish ke Play Store, isi bagian [ISI ...], dan publish dokumen ini
ke URL publik (GitHub Pages paling gampang: aktifkan di repo Settings
-> Pages -> pilih branch, dokumen ini otomatis bisa diakses lewat URL).
URL itu yang dimasukkan ke Play Console -> Policy -> Privacy Policy.
