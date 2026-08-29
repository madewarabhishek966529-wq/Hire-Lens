import 'package:flutter_test/flutter_test.dart';
import 'package:hirelens/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('HireLens App launches cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HireLensApp()));
    await tester.pumpAndSettle();
    expect(find.textContaining('HireLens'), findsWidgets);
  });
}
