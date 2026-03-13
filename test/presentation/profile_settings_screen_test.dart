import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/presentation/screens/profile_settings_screen.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  testWidgets('profile settings screen switches locale to Chinese', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfileSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('locale-zh')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('设置'), findsWidgets);
    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(ProfileSettingsScreen)),
      ).read(appLocaleProvider),
      AppLocale.zh,
    );
  });
}
