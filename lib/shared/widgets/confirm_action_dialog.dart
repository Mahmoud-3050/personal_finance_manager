import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/language/strings.dart';
import 'platform/platform_target.dart';

Future<bool> confirmAccountAction(
  BuildContext context, {
  required String message,
}) async {
  final bool? confirmed = usesIosComponents(context)
      ? await _iosConfirm(context, message)
      : await _androidConfirm(context, message);
  return confirmed ?? false;
}

Future<bool?> _iosConfirm(BuildContext context, String message) {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(Strings.fenzoCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(Strings.fenzoConfirm),
          ),
        ],
      );
    },
  );
}

Future<bool?> _androidConfirm(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(Strings.fenzoCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(Strings.fenzoConfirm),
          ),
        ],
      );
    },
  );
}
