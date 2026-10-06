import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../shared/widgets/finance/summary_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.settings)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        children: const <Widget>[_CategoriesLink(), _BackupLink()],
      ),
    );
  }
}

class _CategoriesLink extends StatelessWidget {
  const _CategoriesLink();

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: Strings.fenzoCategories,
      leading: const _SettingsMark(icon: Icons.category_outlined),
      onTap: () => context.push(AppRoutes.categories),
    );
  }
}

class _BackupLink extends StatelessWidget {
  const _BackupLink();

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: Strings.backup,
      leading: const _SettingsMark(icon: Icons.cloud_outlined),
      onTap: () => context.push(AppRoutes.backup),
    );
  }
}

class _SettingsMark extends StatelessWidget {
  const _SettingsMark({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.textSecondary.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 44.r,
        child: Icon(icon, color: colors.textSecondary, size: 20.r),
      ),
    );
  }
}
