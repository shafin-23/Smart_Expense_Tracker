
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/app.dart';

void main() {
testWidgets('Expense Tracker app loads successfully',
(WidgetTester tester) async {
await tester.pumpWidget(
const ProviderScope(
child: SmartExpenseApp(),
),
);

await tester.pumpAndSettle();

// Verify that the app loads successfully.
expect(find.byType(SmartExpenseApp), findsOneWidget);
});
}
