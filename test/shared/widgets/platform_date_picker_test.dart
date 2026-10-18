import 'package:finzomanager/config/language/strings.dart';
import 'package:finzomanager/config/themes/colors_palettes.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/widgets/platform_date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language/language.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await Language.instance.init();
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  testWidgets('android opens the material date dialog', (
    WidgetTester tester,
  ) async {
    await _openPicker(tester, TargetPlatform.android);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.byType(CupertinoDatePicker), findsNothing);
  });

  testWidgets('ios opens the cupertino date wheel', (
    WidgetTester tester,
  ) async {
    await _openPicker(tester, TargetPlatform.iOS);
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(find.text(Strings.done), findsOneWidget);
    expect(find.byType(DatePickerDialog), findsNothing);
  });
}

Future<void> _openPicker(WidgetTester tester, TargetPlatform platform) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: ThemeData(platform: platform),
          home: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  showPlatformDatePicker(
                    context: context,
                    initialDate: const CalendarDate(2026, 10, 18),
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        );
      },
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
