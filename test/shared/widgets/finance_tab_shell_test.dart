import 'package:finzomanager/config/routes/app_routes.dart';
import 'package:finzomanager/config/themes/app_theme.dart';
import 'package:finzomanager/config/themes/colors_palettes.dart';
import 'package:finzomanager/shared/widgets/finance_tab_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:language/language.dart';
import 'package:liquidify/liquidify.dart';
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

  testWidgets('ios book tabs use the native liquid glass bar', (
    WidgetTester tester,
  ) async {
    await _pump(tester, TargetPlatform.iOS);
    expect(find.byType(NativeLiquidGlassTabBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('android book tabs keep the material bar', (
    WidgetTester tester,
  ) async {
    await _pump(tester, TargetPlatform.android);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NativeLiquidGlassTabBar), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, TargetPlatform platform) async {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return FinanceTabShell(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (BuildContext context, GoRouterState state) {
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          theme: appTheme(
            ColorsPalettes.config.light,
            Brightness.light,
          ).copyWith(platform: platform),
          routerConfig: router,
        );
      },
    ),
  );
  await tester.pumpAndSettle();
}
