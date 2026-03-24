import 'package:flutter_test/flutter_test.dart';
import 'package:earthquest/main.dart';

void main() {
  testWidgets('EarthQuest app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EarthQuestApp());
    expect(find.text('EarthQuest'), findsOneWidget);
  });
}
