import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ecobank_sampah/data/local/hive_service.dart';
import 'package:ecobank_sampah/main.dart';

void main() {
  late Directory tempDir;

  // EcoBankSampahApp membaca Hive box saat widget di-build (untuk
  // TransaksiProvider), jadi Hive harus sudah siap SEBELUM pumpWidget,
  // walau hanya widget smoke test biasa.
  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_widget_test_');
    Hive.init(tempDir.path);
    await Hive.openBox<Map>(HiveBoxes.wasteTransactions);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets('EcoBank Sampah menampilkan splash screen sesuai desain', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoBankSampahApp());
    expect(find.text('EcoBank'), findsOneWidget);
    expect(find.text('Ubah Sampah Jadi Berharga'), findsOneWidget);
  });
}
