import 'package:flutter_test/flutter_test.dart';
import 'package:sewa_mitra/app.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SewaMitraApp());

    // Verify that "SewaMitra" text is present (or part of it)
    expect(find.textContaining('Sewa'), findsOneWidget);
  });
}