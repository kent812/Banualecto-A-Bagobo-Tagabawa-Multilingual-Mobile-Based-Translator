import 'package:flutter_test/flutter_test.dart';
import 'package:banualecto/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const BanualectoApp());
    await tester.pumpAndSettle();

    expect(find.text('Enter Dictionary'), findsOneWidget);
  });
}
