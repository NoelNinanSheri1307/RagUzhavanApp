import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/main.dart';

void main() {
  testWidgets('RagUzhavanApp initializes cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const RagUzhavanApp());
    await tester.pumpAndSettle();

    expect(find.text('RagUzhavan'), findsWidgets);
  });
}
