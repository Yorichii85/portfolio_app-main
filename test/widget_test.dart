import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:portfolio_app/main.dart';
import 'package:portfolio_app/state/app_state.dart';

void main() {
  testWidgets('portfolio app shows the home screen with the default user', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
    );

    expect(find.text('My Portfolio'), findsWidgets);
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
  });
}
