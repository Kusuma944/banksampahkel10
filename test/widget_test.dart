import 'package:flutter_test/flutter_test.dart';
import 'package:ecobank_sampah/main.dart';

void main() {
  testWidgets('EcoBank Sampah app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoBankSampahApp());
    expect(find.text('EcoBank Sampah'), findsOneWidget);
    expect(find.text('Kelola Sampah, Raih Nilai Ekonomi'), findsOneWidget);
  });
}
