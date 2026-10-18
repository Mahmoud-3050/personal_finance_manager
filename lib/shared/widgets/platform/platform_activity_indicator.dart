import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import 'platform_target.dart';

/// A busy indicator that follows the phone platform.
class PlatformActivityIndicator extends StatelessWidget {
  const PlatformActivityIndicator({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? context.colors.primary;
    if (usesIosComponents(context)) {
      return CupertinoActivityIndicator(color: tint);
    }
    return CircularProgressIndicator(color: tint);
  }
}
