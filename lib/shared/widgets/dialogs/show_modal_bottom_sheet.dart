import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';

Future<dynamic> showAppModalBottomSheet({
  required BuildContext context,
  required Widget child,
  double? borderRadius,
  bool isDismissible = true,
  double? height,
}) {
  return showModalBottomSheet<dynamic>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    enableDrag: isDismissible,
    isDismissible: isDismissible,
    shape: RoundedRectangleBorder(
      borderRadius: .circular(borderRadius ?? 20.r),
    ),
    builder: (BuildContext context) {
      final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
      final double homeInset = MediaQuery.viewPaddingOf(context).bottom;
      final double bottomInset = keyboardInset > homeInset
          ? keyboardInset
          : homeInset;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: PopScope(
          canPop: isDismissible,
          child: Builder(
            builder: (BuildContext context) {
              if (height == null) {
                return child;
              }
              return SizedBox(height: height, child: child);
            },
          ),
        ),
      );
    },
  );
}
