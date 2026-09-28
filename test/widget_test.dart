import 'package:flutter_test/flutter_test.dart';
import 'package:palash_vaani/main.dart';

void main() {
  testWidgets('PalashVaani smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PalashVaaniApp());
    expect(find.text('पलाश-वाणी'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
    expect(find.text('पलाश-वाणी'), findsWidgets);
  });
}
