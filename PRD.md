# Product Requirements Document (PRD) v1.0
## EcoBank — Aplikasi Bank Sampah Digital

**Milestone:** CPMK 1 — Ideasi SDG, Strategi Monetisasi, & Setup Environment
**Tema:** Pemrograman Mobile — Bank Sampah
**Status:** Draft v1.0 (Prototype)

---

## 1. SDG Alignment

**SDG Utama:** SDG 12 — Responsible Consumption and Production
**SDG Sekunder:** SDG 11 — Sustainable Cities and Communities

Bank sampah digital mendorong pola konsumsi dan produksi yang bertanggung jawab dengan mengubah sampah anorganik (plastik, kertas, logam, kaca) dari beban lingkungan menjadi aset ekonomi yang tercatat dan terukur, sekaligus mendukung pengelolaan sampah kota yang lebih rapi (SDG 11).

---

## 2. Problem Statement

Bank sampah konvensional di Indonesia masih banyak yang beroperasi secara manual:

- Pencatatan setoran sampah dan saldo nasabah masih pakai buku tulis/Excel, rawan hilang dan salah hitung.
- Nasabah tidak punya visibilitas real-time terhadap saldo tabungan sampahnya.
- Tidak ada standar harga yang transparan antar bank sampah, sehingga nasabah kadang merasa dirugikan.
- Minim insentif — banyak warga malas memilah sampah karena prosesnya dianggap ribet dan hasilnya tidak terasa langsung.
- Bank sampah kesulitan menemukan pengepul/industri daur ulang dengan harga terbaik karena jaringan masih manual dari mulut ke mulut.

## 3. Solution Novelty

**EcoBank** adalah aplikasi mobile yang mendigitalkan seluruh siklus bank sampah:

1. **Setor & Timbang Digital** — Petugas bank sampah input jenis & berat sampah nasabah langsung dari HP, saldo otomatis terupdate real-time (bukan proto pertama: bisa manual input dulu, tanpa hardware timbangan IoT).
2. **Dompet Digital Sampah** — Nasabah bisa lihat saldo, riwayat setor, dan estimasi nilai rupiah dari sampah yang sudah disetor.
3. **Marketplace Pengepul (future)** — Bank sampah bisa membandingkan harga dari beberapa pengepul terdaftar sebelum jual massal.
4. **Gamifikasi (future)** — Badge/level nasabah berdasarkan total kontribusi, mendorong partisipasi berkelanjutan.

Yang membedakan dari kompetitor sejenis: fokus pada kesederhanaan alur untuk petugas bank sampah tingkat RW/kelurahan yang belum melek teknologi tinggi, bukan hanya untuk nasabah individu di kota besar.

## 4. User Persona

### Persona 1 — Nasabah (Ibu Rumah Tangga / Warga)
- Nama: Bu Sri, 42 tahun, ibu rumah tangga di kompleks perumahan
- Kebutuhan: ingin tahu saldo tabungan sampahnya tanpa harus datang ke pos bank sampah
- Pain point: sering lupa sudah setor berapa kilo minggu ini

### Persona 2 — Petugas Bank Sampah (Admin RW)
- Nama: Pak Joko, 50 tahun, pengurus bank sampah tingkat RW
- Kebutuhan: pencatatan cepat saat nasabah antre setor sampah, laporan bulanan otomatis
- Pain point: capek rekap manual pakai buku besar tiap akhir bulan

### Persona 3 — Pengepul/Industri Daur Ulang
- Nama: CV Daur Ulang Makmur
- Kebutuhan: sumber pasokan sampah terpilah dengan volume dan jadwal yang jelas
- Pain point: sulit dapat pasokan konsisten dari bank sampah kecil yang tersebar

## 5. Business Model / Monetisasi

| Sumber Pendapatan | Deskripsi |
|---|---|
| **Komisi Transaksi** | Fee 2-5% dari setiap transaksi jual sampah terkumpul ke pengepul mitra |
| **Kemitraan Pengepul Berbayar** | Pengepul membayar biaya listing untuk masuk marketplace prioritas di aplikasi |
| **Sponsorship CSR** | Kerja sama dengan brand/perusahaan (program CSR lingkungan) untuk sponsor campaign bank sampah di suatu wilayah |
| **Laporan & Analitik Premium** | Fitur laporan dashboard lanjutan untuk bank sampah skala besar (kelurahan/kecamatan), berlangganan bulanan |

**Catatan:** Untuk prototype milestone 1, fokus dulu ke fitur inti (setor sampah, saldo, riwayat) — model monetisasi di atas jadi acuan arah bisnis di dokumen, belum diimplementasi teknis.

## 6. Scope Milestone 1 (Prototype)

- Splash screen bertema EcoBank
- Home screen dengan info saldo nasabah (dummy data)
- Struktur folder dasar aplikasi Flutter
- Setup environment `flutter doctor` clean
- PROMPT_SPEC.md untuk AI-assisted coding di tahap berikutnya

> Catatan revisi: dokumen ini akan disesuaikan dengan Project Charter kelompok begitu teman-teman selesai menyusunnya, tanpa mengubah fondasi teknis yang sudah dibangun.
