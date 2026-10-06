import 'package:flutter/material.dart';

import '../../config/language/strings.dart';

Future<bool> confirmAccountAction(
  BuildContext context, {
  required String message,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(Strings.fenzoConfirm),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(Strings.fenzoCancel),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
