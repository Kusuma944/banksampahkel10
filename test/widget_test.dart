import 'package:flutter_test/flutter_test.dart';
import 'package:ecobank_sampah/main.dart';

void main() {
  testWidgets('EcoBank Sampah menampilkan splash screen sesuai desain', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoBankSampahApp());
    expect(find.text('EcoBank'), findsOneWidget);
    expect(find.text('Ubah Sampah Jadi Berharga'), findsOneWidget);
  });
}
