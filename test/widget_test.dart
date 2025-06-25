// This is a basic Flutter widget test for AuraWalk app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura_walk/main.dart';

void main() {
  testWidgets('AuraWalk app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AuraWalkApp(),
      ),
    );

    // Wait for initial async operations to complete
    await tester.pump();

    // Verify that the app loads and shows navigation
    expect(find.text('AuraWalk'), findsOneWidget);
    
    // Check that main navigation tabs are present
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Aura'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);

    // Pump to complete any pending timers
    await tester.pumpAndSettle();
  });
}
