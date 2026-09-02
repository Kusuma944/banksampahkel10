import 'package:hive_flutter/hive_flutter.dart';

/// Nama box Hive dipusatkan di sini supaya tidak ada typo string
/// tersebar di banyak file.
class HiveBoxes {
  static const String wasteTransactions = 'waste_transactions_box';
}

/// Inisialisasi Hive sekali di awal aplikasi (dipanggil dari `main()`
/// sebelum `runApp`). Box dibuka di sini supaya siap dipakai
/// synchronous oleh repository begitu app jalan.
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(HiveBoxes.wasteTransactions);
  }

  static Box<Map> get wasteTransactionsBox =>
      Hive.box<Map>(HiveBoxes.wasteTransactions);
}
