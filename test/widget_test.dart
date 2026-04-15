import 'package:flutter_test/flutter_test.dart';

import 'package:ideas_app/main.dart';

void main() {
  testWidgets('Ideas app shows the main screen title', (WidgetTester tester) async {
    await tester.pumpWidget(const IdeasApp());

    expect(find.text('Ideas App'), findsOneWidget);
  });
}
