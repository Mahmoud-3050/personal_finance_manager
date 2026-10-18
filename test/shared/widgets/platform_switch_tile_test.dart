import 'package:finzomanager/config/themes/colors_palettes.dart';
import 'package:finzomanager/shared/widgets/platform_switch_tile.dart';
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

  testWidgets('android shows the material switch', (WidgetTester tester) async {
    await _pumpTile(tester, TargetPlatform.android);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsNothing);
  });

  testWidgets('ios shows the cupertino switch', (WidgetTester tester) async {
    await _pumpTile(tester, TargetPlatform.iOS);
    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
  });
}

Future<void> _pumpTile(WidgetTester tester, TargetPlatform platform) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: PlatformSwitchTile(
              title: 'Include in total',
              value: true,
              onChanged: (_) {},
            ),
          ),
        );
      },
    ),
  );
}
