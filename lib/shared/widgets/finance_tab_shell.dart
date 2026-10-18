import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquidify/liquidify.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../config/routes/app_routes.dart';
import 'platform/platform_target.dart';

/// Tab bar for the four top-level book screens.
///
/// iOS uses [NativeLiquidGlassTabBar] from liquidify, the native UITabBar
/// with UIGlassEffect. The `.liquidGlass()` extension maps only a short list
/// of Material icons to SF Symbols, so these book tabs pass symbol names.
class FinanceTabShell extends StatelessWidget {
  const FinanceTabShell({required this.child, super.key});

  final Widget child;

  static const List<String> paths = <String>[
    AppRoutes.dashboard,
    AppRoutes.accounts,
    AppRoutes.transactions,
    AppRoutes.reports,
  ];

  @override
  Widget build(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    final int index = paths.indexOf(path);
    if (index < 0) {
      return child;
    }
    final ThemeColors colors = context.colors;
    return Scaffold(
      body: child,
      bottomNavigationBar: usesIosComponents(context)
          ? SafeArea(
              top: false,
              child: NativeLiquidGlassTabBar(
                currentIndex: index,
                onTap: (int value) => context.go(paths[value]),
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.textSecondary,
                items: <NativeTabBarItem>[
                  NativeTabBarItem(
                    label: Strings.fenzoTitle,
                    icon: 'creditcard',
                    activeIcon: 'creditcard.fill',
                  ),
                  NativeTabBarItem(
                    label: Strings.fenzoAccounts,
                    icon: 'building.2',
                    activeIcon: 'building.2.fill',
                  ),
                  NativeTabBarItem(
                    label: Strings.fenzoTransactions,
                    icon: 'doc.text',
                    activeIcon: 'doc.text.fill',
                  ),
                  NativeTabBarItem(
                    label: Strings.fenzoReports,
                    icon: 'chart.pie',
                    activeIcon: 'chart.pie.fill',
                  ),
                ],
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: NavigationBar(
                selectedIndex: index,
                backgroundColor: colors.background,
                surfaceTintColor: colors.background,
                elevation: 0,
                height: 64.h,
                indicatorColor: colors.primary.withValues(alpha: 0.12),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                onDestinationSelected: (int value) => context.go(paths[value]),
                destinations: <NavigationDestination>[
                  NavigationDestination(
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: const Icon(Icons.account_balance_wallet),
                    label: Strings.fenzoTitle,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.account_balance_outlined),
                    selectedIcon: const Icon(Icons.account_balance),
                    label: Strings.fenzoAccounts,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long),
                    label: Strings.fenzoTransactions,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.pie_chart_outline),
                    selectedIcon: const Icon(Icons.pie_chart),
                    label: Strings.fenzoReports,
                  ),
                ],
              ),
            ),
    );
  }
}
