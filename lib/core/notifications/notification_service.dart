/// ============================================================
/// MODUL PUSH NOTIFICATION (CPMK 5) — SIAP PAKAI, BELUM DIAKTIFKAN
/// ============================================================
///
/// File ini SENGAJA belum disambungkan ke main.dart dan
/// firebase_messaging BELUM ditambahkan ke pubspec.yaml.
///
/// Kenapa? Karena package Firebase butuh file `google-services.json`
/// dari project Firebase Console SEBELUM app bisa di-build sama sekali
/// (beda dengan Supabase yang cuma butuh URL+key saat runtime). Kalau
/// dependency ini ditambah sekarang tanpa file itu, `flutter run` akan
/// GAGAL TOTAL untuk SELURUH app — termasuk fitur CPMK 1-4 yang sudah
/// jalan. Makanya modul ini dipisah dulu, supaya tidak mengganggu apa
/// yang sudah berfungsi.
///
/// CARA MENGAKTIFKAN (lihat juga CLOUD_SETUP.md bagian Push Notification):
/// 1. Bikin project di https://console.firebase.google.com
/// 2. Tambah app Android dengan package name `com.ecobank.sampah`
///    (cek android/app/build.gradle kalau sudah berubah)
/// 3. Download `google-services.json`, taruh di `android/app/`
/// 4. Tambah ke android/build.gradle (level root):
///      dependencies { classpath 'com.google.gms:google-services:4.4.2' }
/// 5. Tambah ke android/app/build.gradle (baris paling bawah):
///      apply plugin: 'com.google.gms.google-services'
/// 6. Tambah ke pubspec.yaml:
///      firebase_core: ^3.6.0
///      firebase_messaging: ^15.1.3
/// 7. Uncomment kode di bawah, dan panggil `FirebaseNotificationService().init()`
///    di main.dart setelah `Firebase.initializeApp()`.
library;

/// Kontrak abstrak — supaya presentation layer tidak tahu apakah
/// notifikasi datang dari Firebase Cloud Messaging, OneSignal, atau
/// provider lain.
abstract class NotificationService {
  Future<void> init();
  Future<String?> getToken();
  Stream<String> get onMessageReceived;
}

// ============================================================
// IMPLEMENTASI FIREBASE CLOUD MESSAGING (aktifkan setelah setup di atas)
// ============================================================
//
// import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class FirebaseNotificationService implements NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final _controller = StreamController<String>.broadcast();
//
//   @override
//   Future<void> init() async {
//     await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // Notifikasi yang datang SAAT APP TERBUKA (foreground).
//     FirebaseMessaging.onMessage.listen((message) {
//       final judul = message.notification?.title ?? 'Notifikasi';
//       final isi = message.notification?.body ?? '';
//       _controller.add('$judul: $isi');
//     });
//   }
//
//   @override
//   Future<String?> getToken() => _messaging.getToken();
//
//   @override
//   Stream<String> get onMessageReceived => _controller.stream;
// }
//
// ============================================================
// CONTOH PEMAKAIAN DI main.dart (setelah Firebase.initializeApp()):
// ============================================================
//
// final notificationService = FirebaseNotificationService();
// await notificationService.init();
// final token = await notificationService.getToken();
// // Simpan `token` ke kolom di tabel Supabase (mis. `profiles.fcm_token`)
// // supaya backend/dosen bisa kirim notifikasi test ke device kamu.
