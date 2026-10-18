import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';

import '../../core/utils/values/text_styles.dart';

const double _switchTitleSize = 16;

/// A labeled switch that follows the phone platform.
///
/// iOS uses [CupertinoSwitch]. Android uses the Material [SwitchListTile].
class PlatformSwitchTile extends StatelessWidget {
  const PlatformSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Text titleText = Text(
      title,
      style: TextStyles.of(size: _switchTitleSize),
    );
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return _IosSwitchTile(
        title: titleText,
        value: value,
        onChanged: onChanged,
      );
    }
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: titleText,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _IosSwitchTile extends StatelessWidget {
  const _IosSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final Widget title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<bool>? toggle = onChanged;
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: toggle == null ? null : () => toggle(!value),
                child: title,
              ),
            ),
            CupertinoSwitch(value: value, onChanged: toggle),
          ],
        ),
      ),
    );
  }
}
