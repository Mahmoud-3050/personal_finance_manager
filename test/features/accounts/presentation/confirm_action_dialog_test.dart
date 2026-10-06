import 'package:finzomanager/shared/widgets/confirm_action_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language/language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cancel leaves the action unconfirmed', (WidgetTester tester) async {
    await Language.instance.init();
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: LanguageLocalizationsSetup.localizationsDelegates,
        supportedLocales: LanguageLocalizationsSetup.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () async {
                  result = await confirmAccountAction(context, message: 'حذف');
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
