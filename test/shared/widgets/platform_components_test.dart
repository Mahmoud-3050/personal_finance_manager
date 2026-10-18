import 'package:finzomanager/config/themes/colors_palettes.dart';
import 'package:finzomanager/shared/widgets/platform/platform_activity_indicator.dart';
import 'package:finzomanager/shared/widgets/platform/platform_app_bar.dart';
import 'package:finzomanager/shared/widgets/platform/platform_button.dart';
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

  testWidgets('android chrome uses material components', (
    WidgetTester tester,
  ) async {
    await _pump(tester, TargetPlatform.android);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsNothing);
  });

  testWidgets('ios chrome uses cupertino components', (
    WidgetTester tester,
  ) async {
    await _pump(tester, TargetPlatform.iOS);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(CupertinoButton), findsWidgets);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, TargetPlatform platform) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            appBar: const PlatformAppBar(title: Text('Book')),
            body: Column(
              children: <Widget>[
                PlatformButton(label: 'Save', onPressed: () {}),
                const PlatformActivityIndicator(),
              ],
            ),
          ),
        );
      },
    ),
  );
}
