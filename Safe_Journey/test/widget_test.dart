import 'package:flutter_test/flutter_test.dart';
import 'package:safe_journey/main.dart';

void main() {
  testWidgets('Safe Journey home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeJourneyApp());
    expect(find.text('Safe Journey'), findsWidgets);
    expect(find.text('Start Safe Journey'), findsOneWidget);
    expect(find.text('SOS — Emergency Alert'), findsOneWidget);
  });
}
