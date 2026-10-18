import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import 'platform_target.dart';

const double _iosNavigationBarHeight = 44;

/// Navigation bar that follows the phone platform.
///
/// iOS uses [CupertinoNavigationBar]. Android uses [AppBar].
class PlatformAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlatformAppBar({
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize {
    final double height = defaultTargetPlatform == TargetPlatform.iOS
        ? _iosNavigationBarHeight
        : kToolbarHeight;
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    if (!usesIosComponents(context)) {
      return AppBar(
        title: title,
        leading: leading,
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    }
    final ThemeColors colors = context.colors;
    return CupertinoNavigationBar(
      backgroundColor: colors.background,
      border: Border(bottom: BorderSide(color: colors.divider)),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      middle: title,
      trailing: _trailing(),
    );
  }

  Widget? _trailing() {
    final List<Widget> buttons = actions ?? const <Widget>[];
    if (buttons.isEmpty) {
      return null;
    }
    if (buttons.length == 1) {
      return buttons.first;
    }
    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}

/// Back control for the current platform.
class PlatformBackButton extends StatelessWidget {
  const PlatformBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!usesIosComponents(context)) {
      return BackButton(onPressed: onPressed);
    }
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(CupertinoIcons.back, color: context.colors.primary),
    );
  }
}
