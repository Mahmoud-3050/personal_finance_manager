import 'package:finzomanager/config/themes/app_theme.dart';
import 'package:finzomanager/config/themes/colors_palettes.dart';
import 'package:finzomanager/shared/widgets/confirm_action_dialog.dart';
import 'package:finzomanager/shared/widgets/finance_menu_field.dart';
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

  testWidgets('ios action sheet uses the dark surface', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      FinanceMenuField<String>(
        value: 'cash',
        label: 'Account',
        items: <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(value: 'cash', child: Text('Cash')),
          DropdownMenuItem<String>(value: 'bank', child: Text('Bank')),
        ],
        onChanged: _ignoreChange,
      ),
    );

    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();

    expect(
      _sheetLuminance(tester, find.byType(CupertinoActionSheet)),
      lessThan(0.5),
    );
  });

  testWidgets('ios confirm dialog uses the dark surface', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      Builder(
        builder: (BuildContext context) {
          return TextButton(
            onPressed: () => confirmAccountAction(context, message: 'Delete'),
            child: const Text('Open'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      _sheetLuminance(tester, find.byType(CupertinoAlertDialog)),
      lessThan(0.5),
    );
  });
}

void _ignoreChange(String? value) {}

double _sheetLuminance(WidgetTester tester, Finder modal) {
  final ColoredBox surface = tester.widget<ColoredBox>(
    find.descendant(of: modal, matching: find.byType(ColoredBox)).first,
  );
  return surface.color.computeLuminance();
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: appTheme(
            ColorsPalettes.config.light,
            Brightness.light,
          ).copyWith(platform: TargetPlatform.iOS),
          home: Scaffold(body: home),
        );
      },
    ),
  );
}
